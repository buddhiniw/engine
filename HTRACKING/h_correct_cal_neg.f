*=======================================================================
      function h_correct_cal_neg(x,y,abort,errmsg)
*=======================================================================
*-
*-      Purpose: Returns the impact point correction factor. This
*-               factor is to be applied to the energy depositions.
*-               This correction for single "NEG_PMT" readout from 
*-               LG-blocks. The final energy is the ADC value TIMES 
*-               the correction factor.
*-
*-      Input Parameters: x,y - impact point coordinates
*-
*-      Created 09 October 1997      H. Mkrtchyan
*
* $Log$
* Revision 1.2  1999/01/29 17:33:56  saw
* Cosmetic changes
*
* Revision 1.1  1999/01/21 21:40:13  saw
* Extra shower counter tube modifications
*
*
*
*-----------------------------------------------------------------------
*
      implicit none
      save
*
      logical abort
      character*(*) errmsg
      character*17 here
      parameter (here='H_CORRECT_CAL_NEG')
*
*
      real*4 x,y         !Impact point coordinates
      real*4 h_correct_cal_neg
*
      include 'hms_data_structures.cmn'
      include 'hms_calorimeter.cmn'
*
*   ! Here  I was used some preliminary function 
*
      h_correct_cal_neg=exp(-y/200.)      !200 cm atten length. 
      h_correct_cal_neg=h_correct_cal_neg*(1. + y*y/8000.) 
*   
      return
      end

