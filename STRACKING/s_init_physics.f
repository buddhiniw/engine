      SUBROUTINE s_init_physics(ABORT,err)
*--------------------------------------------------------
*-
*-   Purpose and Methods : Initialize constants for s_physics
*-                              
*-
*-   Output: ABORT           - success or failure
*-         : err             - reason for failure, if any
*- 
*-   Created 6-6-94          D. F. Geesaman
* $Log$
* Revision 1.4  1996/01/24 16:07:34  saw
* (JRA) Change upper case to lower case, cebeam to gebeam
*
* Revision 1.3  1995/05/22 19:45:41  cdaq
* (SAW) Split gen_data_data_structures into gen, hms, sos, and coin parts"
*
* Revision 1.2  1995/05/11  17:07:14  cdaq
* (SAW) Fix SOS to be in plane, beam left
*
* Revision 1.1  1994/06/14  04:09:12  cdaq
* Initial revision
*
*--------------------------------------------------------
      IMPLICIT NONE
      SAVE
*
      character*50 here
      parameter (here= 's_init_physics')
*
      logical ABORT
      character*(*) err
*
      INCLUDE 'gen_data_structures.cmn'
      INCLUDE 'sos_data_structures.cmn'
      INCLUDE 'gen_constants.par'
      INCLUDE 'gen_units.par'
      INCLUDE 'sos_physics_sing.cmn'
*
*     local variables 
*--------------------------------------------------------
*
      ABORT= .FALSE.
      err= ' '
*
*     Fix SOS to be in plane, beam left
*
      sphi_lab = tt/2
*
      cossthetas = cos(stheta_lab)
      sinsthetas = sin(stheta_lab)
*     Constants for elastic kinematics calcultion
      sphysicsa = 2.*gebeam*gtarg_mass(gtarg_num) -
     $     mass_electron**2 - spartmass**2
      sphysicsb = 2. * (gtarg_mass(gtarg_num) - gebeam)
      sphysicab2 = sphysicsa**2 * sphysicsb**2
      sphysicsm3b = spartmass**2 * sphysicsb**2
      return
      end
