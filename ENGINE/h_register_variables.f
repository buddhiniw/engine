      subroutine h_register_variables(ABORT,err)
*----------------------------------------------------------------------
*
*     CTP variable registration routine for the HMS
*
*     Purpose : Register all variables that are to be used by CTP, that are
*     connected with the HMS.  This includes externally configured
*     parameters/contants, event data that can be a histogram source, and
*     possible test results and scalers.
*
*     Output: ABORT      - success or failure
*           : err        - reason for failure, if any
*
*     Created: 9-Feb-1994  Stephen A. Wood
*     $Log$
*     Revision 1.6  1994/06/16 03:43:47  cdaq
*     (SAW) Register filenames for reports
*
* Revision 1.5  1994/04/12  17:25:03  cdaq
* (KBB) Add ntuple call
*
* Revision 1.4  1994/02/22  19:37:53  cdaq
* (SAW) Remove CTP register calls to fortran PARAMETER's
*
* Revision 1.3  1994/02/22  18:56:45  cdaq
* (SAW) Make a call to h_register_param
*
* Revision 1.2  1994/02/11  18:36:17  cdaq
* Split off CTP variables registration from initialize routines
*
* Revision 1.1  1994/02/11  04:18:24  cdaq
* Initial revision
*
*
*----------------------------------------------------------------------
      implicit none
      save
*
      character*20 here
      parameter (here='h_register_variables')
*
      logical ABORT
      character*(*) err
*
      INCLUDE 'gen_data_structures.cmn'
      INCLUDE 'hms_filenames.cmn'
      INCLUDE 'gen_routines.dec'
*
      integer ierr
*--------------------------------------------------------
      err= ' '
      ABORT = .FALSE.
*
      ierr = regparmstring('h_recon_coeff_filename'
     $     ,h_recon_coeff_filename,0)
      if(ierr.ne.0) call g_append(err,',"h_recon_coeff_filename"')
      ABORT = ierr.ne.0.or.ABORT
*
      ierr = regparmstring('h_report_template_filename'
     $     ,h_report_template_filename,0)
      if(ierr.ne.0) call g_append(err,',"h_report_template_filename"')
      ABORT = ierr.ne.0.or.ABORT
*
      ierr = regparmstring('h_report_blockname'
     $     ,h_report_blockname,0)
      if(ierr.ne.0) call g_append(err,',"h_report_blockname"')
      ABORT = ierr.ne.0.or.ABORT
*
      if(.not.ABORT) call h_register_param(ABORT,err) ! TRACKING ROUTINE
*
      if(.not.ABORT) call h_ntuple_register(ABORT,err)
*
      if(ABORT) then
         call g_add_path(here,err)
      endif
*
      return
      end
