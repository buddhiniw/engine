      subroutine g_decode_config(ABORT, error, fname)
*----------------------------------------------------------------------------------
*
*     Purpose and Methods:
*
*     Build a table that maps (ROC, Slot, Subadd) to (Detector ID, Plane,
*     Counter, Signal type).  Also saves a mask for each slot that is used
*     to extract value from fastbus word.
*
*     Inputs:
*
*     fname      Name of file
*     -          Allowed keywords. roc, slot, detector, nsubadd, mask
*     -          Numerical lines: Subadd, Plane, Counter, Signal
*
*     Outputs:
*
*     ABORT
*     error
*
*     Created  16-NOV-1993   Stephen Wood, CEBAF
*     Modified  3-Dec-1993   Kevin Beard, Hampton Univ.; rewrote parsing
*-    $Log$
*-    Revision 1.2  1994/04/06 18:22:02  cdaq
*-    (SAW) Revert to pre-initial version that doesn't use UTILSUBS string
*-    manipulation routines.  Added BSUB keyword for # of bits to shift to get
*-    the channel number from a lecroy FB word.  Some validity checking should
*-    be added back in.
*-
* Revision 1.1  1994/02/01  20:38:10  cdaq
* Initial revision
*
*----------------------------------------------------------------------------------
      implicit none
      SAVE
*
      character*30 here
      parameter (here= 'g_decode_config')
*
      character*(*) error
      logical ABORT
      character*(*) fname
*
      include 'gen_detectorids.cmn'
      include 'gen_decode_common.cmn'
      integer SPAREID                           ! Need a LUN handler?
      parameter (SPAREID=67)
      integer MAXLINE
      parameter (MAXLINE=300)
*
      character*(MAXLINE) line    
      logical OK,echo,debug,override,text
      data echo/.FALSE./
      data debug,override/2*.FALSE./
*
      integer llen,lp,lpcom, lpeq, m                          ! Line pointers
      character*1 tab
      integer*4 roc, slot, subadd, mask
      integer*4 did, plane, counter, signal, nsubadd, bsubadd
      integer*4 lastroc, lastslot
      integer N_lines_read
*
      character*26 lo,HI
      data lo/'abcdefghijklmnopqrstuvwxyz'/
      data HI/'ABCDEFGHIJKLMNOPQRSTUVWXYZ'/
*********************************************************************************
*     Valid data lines are
*    
*     roc=
*     slot=
*     detector=
*     nsubadd=
*     A line with 4 comma separated numbers, Subadd, plane, "wire #", sigtyp
*     sigtyp may be left blank (e.g. for wire chambers) in which case zero
*     is assumed.
*********************************************************************************
      ABORT= .TRUE.
*     Need to pass this file name as an argument or through a common block.
      open(unit=SPAREID,type='OLD',READONLY,file=fname,err=999)
*
      tab = char(9)
      roc = -1
      slot = -1
      lastroc = -1
      lastslot = -1
      N_lines_read= 0
      mask = 'FFF'x                     ! Default data mask
      bsubadd = 17                      ! Default LSB of channel field
*
      OK= .TRUE.
      DO WHILE (OK)
*
         OK= .FALSE.
         error= ':error reading'
         read(SPAREID, '(a)',err=555,end=666) line
         OK= .TRUE.
         error= ' '
555      N_lines_read= N_lines_read+1
*
         If(OK) Then
*
            if(echo) call g_log_message(line)
*
            llen = len(line)		! Remove comments (; or !)
            lpcom = index(line(1:llen),';')
            if(lpcom.gt.0) llen = lpcom - 1
            if(llen.gt.0) then
               lpcom = index(line(1:llen),'!')
               if(lpcom.gt.0) llen = lpcom - 1
            endif
*
            if(llen.gt.0) then
               do while((line(llen:llen).eq.' '.or.line(llen:llen).eq.tab)
     $              .and.llen.gt.1)
                  llen = llen - 1       ! Strip whitespace off end of string
               enddo
            endif
*
            if(llen.gt.0) then
               text = .false.
               do lp=1,llen		! Shift to upper case
                  m = index(lo,line(lp:lp))
                  if(m.gt.0) then
                     line(lp:lp) = HI(m:m)
                     text = .true.
                  else if(index(HI,line(lp:lp)).gt.0) then
                     text = .true.
                  endif
               enddo
*               
               if(text) then
                  lpeq = index(line(1:llen),'=')
*     
                  if(lpeq.gt.0) then
                     if(index(line(1:lpeq-1),'ROC').gt.0) then
                        lastroc = roc
                        read(line(lpeq+1:llen),'(i10)') roc
                     else if(index(line(1:lpeq-1),'SLOT').gt.0) then
                        lastslot = slot
                        read(line(lpeq+1:llen),'(i10)') slot
                     else if(index(line(1:lpeq-1),'DET').gt.0) then
                        read(line(lpeq+1:llen),'(i10)') did
                     else if(index(line(1:lpeq-1),'NSUB').gt.0) then
                        read(line(lpeq+1:llen),'(i10)') nsubadd
                     else if(index(line(1:lpeq-1),'BSUB').gt.0) then
                        read(line(lpeq+1:llen),'(i10)') bsubadd
                     else if(index(line(1:lpeq-1),'MASK').gt.0) then
                        lp = index(line(lpeq+1:llen),'X')
                        if(lp.gt.0) llen = lpeq+lp-1
                        read(line(lpeq+1:llen),'(z10)') mask
                     endif
                  else
                     if(index(line(1:llen),'NOECHO').gt.0) then
                        echo = .false.
                     else if(index(line(1:llen),'ECHO').gt.0) then
                        echo = .true.
                     endif
                  endif
               else
                  read(line(1:llen),'(4i15)') subadd, plane, counter,
     $                 signal
                  If(OK .and. roc.ne.lastroc.or.slot.ne.lastslot) Then
                     if(g_decode_slotpointer(roc+1,slot).eq.0) then
                        g_decode_slotpointer(roc+1,slot) =
     &                       g_decode_nextpointer
                        g_decode_subaddcnt(roc+1,slot) = nsubadd
                        g_decode_subaddbit(roc+1,slot) = bsubadd
                        g_decode_slotmask(roc+1,slot) = mask
                        g_decode_nextpointer = g_decode_nextpointer +
     &                       nsubadd
                     endif
                  EndIf
*     
                  If(OK) Then
                     g_decode_didmap( g_decode_slotpointer(roc+1,slot)
     &                    +subadd ) = did
                     g_decode_planemap( g_decode_slotpointer(roc+1,slot)
     &                    +subadd ) = plane
                     g_decode_countermap( g_decode_slotpointer(roc+1,slot)
     &                    +subadd ) = counter
                     g_decode_sigtypmap( g_decode_slotpointer(roc+1,slot)
     &                    +subadd ) = signal
                  EndIf
*     
               endif
            endif
         endif
      enddo
*  
888   ABORT= .NOT.OK
      IF(ABORT) THEN
        call G_add_path(here,error)
      ELSE
        error= ' '
      ENDIF
      close(unit=SPAREID)
      return
*
666   OK= N_lines_read.GT.0
      error= ':no lines read before End-of-File'
      GOTO 888                       !normal end-of-file?
*
999   continue
      error = ':Unable to open file "'//fname//'"'
      call G_add_path(here,error)
      return
      end
