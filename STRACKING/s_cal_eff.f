      SUBROUTINE S_CAL_EFF(ABORT,errmsg)
*--------------------------------------------------------
*-
*-   Purpose and Methods : Analyze calorimeter statistics for each track 
*-
*-      Required Input BANKS     SOS_CALORIMETER
*-                               GEN_DATA_STRUCTURES
*-
*-   Output: ABORT           - success or failure
*-         : err             - reason for failure, if any
*- 
* author: John Arrington
* created: 2/17/95
*
* s_cal_eff calculates efficiencies for the hodoscope.
*
* $Log$
* Revision 1.2  1995/04/01 20:39:32  cdaq
* (SAW) Fix typos
*
* Revision 1.1  1995/02/23  15:42:27  cdaq
* Initial revision
*
*--------------------------------------------------------
      IMPLICIT NONE
*
      character*50 here
      parameter (here= 'S_CAL_EFF')
*
      logical ABORT
      character*(*) errmsg
*
      INCLUDE 'gen_data_structures.cmn'
      INCLUDE 'gen_constants.par'
      INCLUDE 'gen_units.par'
      include 'sos_calorimeter.cmn'
      include 'sos_statistics.cmn'

      integer col,row,blk
      integer hit_row(smax_cal_columns)
      integer nhit
      real    adc
      real    hit_pos(smax_cal_columns),hit_dist(smax_cal_columns)
      save

* find counters on track, and distance from center.

      if (sschi2perdeg.le.sstat_cal_maxchisq)
     &       sstat_cal_numevents=sstat_cal_numevents+1

      hit_pos(1)=ssx_fp + ssxp_fp*(scal_1pr_zpos+0.5*scal_1pr_thick)
      hit_row(1)=nint((hit_pos(1)-scal_block_xc(1))
     &          /scal_block_xsize)+1
      hit_row(1)=max(min(hit_row(1),smax_cal_rows),1)
      hit_dist(1)=hit_pos(1)-(scal_block_xsize*(hit_row(1)-1)
     &           +scal_block_xc(1))

      hit_pos(2)=ssx_fp + ssxp_fp*(scal_2ta_zpos+0.5*scal_2ta_thick)
      hit_row(2)=nint((hit_pos(2)-scal_block_xc(smax_cal_rows+1))
     &          /scal_block_xsize)+1
      hit_row(2)=max(min(hit_row(2),smax_cal_rows),1)
      hit_dist(2)=hit_pos(2)-(scal_block_xsize*(hit_row(2)-1)
     &           +scal_block_xc(smax_cal_rows+1))

      hit_pos(3)=ssx_fp + ssxp_fp*(scal_3ta_zpos+0.5*scal_3ta_thick)
      hit_row(3)=nint((hit_pos(3)-scal_block_xc(2*smax_cal_rows+1))
     &          /scal_block_xsize)+1
      hit_row(3)=max(min(hit_row(3),smax_cal_rows),1)
      hit_dist(3)=hit_pos(3)-(scal_block_xsize*(hit_row(3)-1)
     &           +scal_block_xc(2*smax_cal_rows+1))

      hit_pos(4)=ssx_fp + ssxp_fp*(scal_4ta_zpos+0.5*scal_4ta_thick)
      hit_row(4)=nint((hit_pos(4)-scal_block_xc(3*smax_cal_rows+1))
     &          /scal_block_xsize)+1
      hit_row(4)=max(min(hit_row(4),smax_cal_rows),1)
      hit_dist(4)=hit_pos(3)-(scal_block_xsize*(hit_row(4)-1)
     &           +scal_block_xc(3*smax_cal_rows+1))

*   increment 'should have hit' counters
      do col=1,smax_cal_columns
        if(abs(hit_dist(col)).le.sstat_cal_slop .and.    !hit in middle of blk.
     &           sschi2perdeg.le.sstat_cal_maxchisq) then
          sstat_cal_trk(col,hit_row(col))=sstat_cal_trk(col,hit_row(col))+1
        endif
      enddo

      do nhit=1,scal_num_hits
        row=scal_rows(nhit)
        col=scal_cols(nhit)
        adc=scal_adcs(nhit)
        blk=row+smax_cal_rows*(col-1)

*  Record the hits if track is near center of block and the chisquared of the 
*  track is good
        if(abs(hit_dist(col)).le.sstat_cal_slop .and. row.eq.hit_row(col)) then
          if (sschi2perdeg.le.sstat_cal_maxchisq) then
            sstat_cal_hit(col,hit_row(col))=sstat_cal_hit(col,hit_row(col))+1
          endif     !was it a good track.
        endif     !if hit was on track.
      enddo

      return
      end