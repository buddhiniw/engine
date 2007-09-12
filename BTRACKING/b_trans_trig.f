      subroutine b_trans_trig(ABORT,err)
      
      implicit none
      save
      
      logical ABORT
      character*(*) err
      
      character*12 here
      parameter (here='b_trans_trig')

      include 'bigcal_data_structures.cmn'
      include 'bigcal_tof_parms.cmn'
      include 'bigcal_gain_parms.cmn'
      include 'bigcal_bypass_switches.cmn'
      include 'bigcal_hist_id.cmn'

      integer*4 ihit,jhit
      real*4 hit_time,ph,esum      
      integer*4 irow64,icol64,icell64,ngood,thitnum
      integer*4 jrow64,jcol64,jcell64
      integer*4 irow8,icol8,icell8
      

*     find trigger logic groups with good ADC/TDC values
      call b_strip_trig(ABORT,err)
      if(ABORT) then
         call g_add_path(here,err)
         return
      endif

      if(bigcal_atrig_ngood.gt.0)then
        do ihit=1,bigcal_atrig_ngood
          irow64 = bigcal_atrig_good_igroup(ihit)
          icol64 = bigcal_atrig_good_ihalf(ihit)
          icell64 = icol64 + 2*(irow64 - 1)
          bigcal_atrig_esum(ihit) = bigcal_trig_cfac(icell64) *
     $         bigcal_atrig_adc_good(ihit)*bigcal_trig_gain_cor(icell64)

          bigcal_atrig_good_det(icell64) = bigcal_atrig_esum(ihit)
          if(bid_bcal_tadcvsum64.gt.0) then
             call hf2(bid_bcal_tadcvsum64,bigcal_atrig_sum64(icell64),
     $            bigcal_atrig_adc_good(ihit),1.0)
          endif
          if(bigcal_iymax_adc.ne.0.and.bigcal_ixmax_adc.ne.0.and.
     $         bid_bcal_trchvmax64.gt.0) then
             jrow64 = (bigcal_iymax_adc-1)/3 + 1
             if(bigcal_iymax_adc.le.bigcal_prot_ny) then
                jcol64 = (bigcal_ixmax_adc-1)/16 + 1
             else
                jcol64 = bigcal_ixmax_adc/16 + 1
             endif

             jcell64 = jcol64 + 2*(jrow64-1)
             
             if(mod(bigcal_iymax_adc-1,3).eq.0) then ! overlap row
c     pick closest group between jcell64 and jcell64-2, the other group to which
c     the maximum belongs
                
                if(abs(jcell64-icell64).lt.abs(jcell64-2-icell64)) then
                   call hf2(bid_bcal_trchvmax64,float(jcell64),
     $                  float(icell64),1.0)
                else
                   call hf2(bid_bcal_trchvmax64,float(jcell64-2),
     $                  float(icell64),1.0)
                endif
             else ! not overlap, group of max is unique 
                call hf2(bid_bcal_trchvmax64,float(jcell64),
     $               float(icell64),1.0)
             endif
          endif
        enddo
      endif

      ngood = 0

      if(bigcal_ttrig_ndecoded.gt.0) then
         do ihit=1,bigcal_ttrig_ndecoded
            irow64 = bigcal_ttrig_dec_igroup(ihit)
            icol64 = bigcal_ttrig_dec_ihalf(ihit)
            icell64 = icol64 + 2*(irow64-1)
            if(bbypass_prot.ne.0.and.bbypass_rcs.ne.0.and.icell64
     $           .le.bigcal_atrig_maxhits) then
               ph = bigcal_atrig_sum64(icell64)
            else
               ph = 0.
            endif
            hit_time = bigcal_ttrig_tdc_dec(ihit) * bigcal_tdc_to_time
            hit_time = hit_time - bigcal_g64_time_offset(icell64)
            hit_time = hit_time - bigcal_g64_phc_coeff(icell64) * 
     $           sqrt(max(0.,(ph/bigcal_g64_minph(icell64)-1.)))
            if(abs(hit_time - bigcal_window_center).le.bigcal_window_slop) 
     $           then
               ngood = ngood + 1
               bigcal_ttrig_good_igroup(ngood) = irow64
               bigcal_ttrig_good_ihalf(ngood) = icol64
               bigcal_ttrig_time_good(ngood) = hit_time
               bigcal_ttrig_tdc_good(ngood) = bigcal_ttrig_tdc_dec(ihit)
c     fill trig tdc histogram
               
               if(bid_bttdc(icell64).gt.0) call hf1(bid_bttdc(icell64),hit_time,1.0)
               
               if(bigcal_ttrig_det_ngood(icell64).lt.8) then
                  bigcal_ttrig_det_ngood(icell64) = 
     $                 bigcal_ttrig_det_ngood(icell64) + 1
                  thitnum = bigcal_ttrig_det_ngood(icell64)
                  bigcal_ttrig_good_det(icell64,thitnum) = hit_time
               endif
               
               if(bbypass_sum8.eq.0.and.bigcal_time_ngood.gt.0.and.
     $              bid_bcal_ttdcvtdc.gt.0) then
                  do jhit=1,bigcal_time_ngood
                     irow8 = bigcal_time_irow(jhit)
                     icol8 = bigcal_time_igroup(jhit)
                     icell8 = icol8 + 4*(irow8-1)
c     check if the two hits match: 
                     if( (icol8-1)/2 + 1 .eq. icol64 ) then
                        if( (irow8-1)/3 + 1 .eq. irow64 .or.(irow8-1)/3-1
     $                       .eq. irow64) then
                           call hf2(bid_bcal_ttdcvtdc,
     $                          bigcal_hit_time(jhit),hit_time,1.0)
                        endif
                     endif
                  enddo
               endif
            endif
         enddo
      endif
      
      bigcal_ttrig_ngood = ngood
      
      return 
      end