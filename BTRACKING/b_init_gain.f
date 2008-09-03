      subroutine b_init_gain(ABORT,err)

      implicit none
      save
      
      character*11 here
      parameter(here='b_init_gain')

      logical ABORT
      character*(*) err

      include 'bigcal_data_structures.cmn'
      include 'bigcal_gain_parms.cmn'
      include 'bigcal_bypass_switches.cmn'

      integer ix,iy,icell,ig64,ih64,ilogic,i,j,roc,slot,pln,cntr,thresh
      integer istart
      real gainold,gainnew

      abort=.false.
      err=' '
c     check whether user has defined bigcal_prot_min_peds:
      bigcal_prot_min_peds=500
      bigcal_rcs_min_peds=500
      bigcal_trig_min_peds=500

c     initialize threshold limits: define sensible values if the user hasn't

c      write(*,*) 'bigcal_prot_cfac=',bigcal_prot_cfac
c      write(*,*) 'bigcal_rcs_cfac=',bigcal_rcs_cfac

c     initialize ped_limit:
      do i=1,bigcal_all_maxhits
         if(i.le.1024) then
            bigcal_prot_ped_limit(i) = 1500
            
c     set defaults to values read in from CTP parm file:
            bigcal_prot_ped_mean_default(i) = bigcal_prot_ped_mean(i) 
            bigcal_prot_ped_rms_default(i) = bigcal_prot_ped_rms(i)
            bigcal_prot_adc_thresh_default(i) = bigcal_prot_adc_threshold(i)
         else
c     write(*,*) 'rcs ped limit(',i-1024,')=',bigcal_rcs_ped_limit(i-1024)
            
            bigcal_rcs_ped_limit(i-1024) = 1500
            
c     write(*,*) 'rcs ped limit(',i-1024,')=',bigcal_rcs_ped_limit(i-1024)
         endif
      enddo
c     trigger ADCs have WIDE pedestals (summing effect of all the noise)
      do i=1,bigcal_atrig_maxhits
         bigcal_trig_ped_limit(i) = 1500
         bigcal_trig_cfac(i) = 1. ! don't use anything other than 1. for the trigger
         bigcal_trig_gain_cor(i) = 1.
      enddo

c     uncomment the following if you want to override the param file with some
c     values.

c$$$      do i=1,bigcal_prot_maxhits
c$$$         bigcal_prot_cfac(i) = 1./950.79
c$$$      enddo
c$$$      do i=1,bigcal_rcs_maxhits
c$$$         bigcal_rcs_cfac(i) = 1./911.57
c$$$      enddo

c     calculate gain correction factors. hopefully last and current gain factors
c     are correctly read in from CTP parm files

c$$$      do ix=1,BIGCAL_PROT_NX
c$$$         do iy=1,BIGCAL_PROT_NY
c$$$            icell=ix + (iy-1)*BIGCAL_PROT_NX
c$$$           
c$$$            gainold = bigcal_prot_gain_last(icell)
c$$$            gainnew = bigcal_prot_gain_now(icell)
c$$$
c$$$            bigcal_prot_gain_cor(icell) = gainnew / gainold
c$$$
c$$$         enddo
c$$$      enddo
c$$$
c$$$      do ix=1,BIGCAL_RCS_NX
c$$$         do iy=1,BIGCAL_RCS_NY
c$$$            icell = ix + (iy-1)*BIGCAL_RCS_NX
c$$$
c$$$            gainold = bigcal_rcs_gain_last(icell)
c$$$            gainnew = bigcal_rcs_gain_now(icell)
c$$$
c$$$            bigcal_rcs_gain_cor(icell) = gainnew / gainold
c$$$            
c$$$         enddo
c$$$      enddo
c$$$
c$$$      do ilogic=1,BIGCAL_ATRIG_MAXHITS
c$$$         gainold = bigcal_trig_gain_last(ilogic)
c$$$         gainnew = bigcal_trig_gain_now(ilogic)
c$$$         bigcal_trig_gain_cor(ilogic) = gainnew / gainold
c$$$      enddo

c     Decided gain_last, gain_now are redundant. Just use cfac and gain_cor!!!!

c      b_ped_jump_first_time = .true.
      b_ped_jump_njump_run = 0
      b_ped_jump_in_progress = .false.

      do icell=1,64
         b_ped_jump_nped(icell) = 0
         b_ped_jump_sum(icell) = 0
         b_ped_jump_sum2(icell) = 0
c         bigcal_prot_ped_mean(icell+28*32) = b_mean_ped_jump
         b_ped_jump_new_mean(icell) = 0.
         b_ped_jump_new_rms(icell) = 0.
      enddo

      return 
      end
