      function H_DPSIFUN(ray,iplane)
*     this function calculates the psi coordinate of the intersection
*     of a ray (defined by ray) with a hms wire chamber plane. the geometry
*     of the plane is contained in the coeff array calculated in the
*     array hplane_coeff
*     Note it is call by MINUIT via H_FCNCHISQ and so uses double precision
*     variables
*
*     the ray is defined by
*     x = (z-zt)*tan(xp) + xt
*     y = (z-zt)*tan(yp) + yt
*      at some fixed value of zt*
*     ray(1) = xt
*     ray(2) = yt
*     ray(3) = tan(xp)
*     ray(4) = tan(yp)
*
*     d.f. geesaman                   17 January 1994
* $Log$
* Revision 1.1  1994/02/19 06:13:29  cdaq
* Initial revision
*
*
      implicit none
      include "gen_data_structures.cmn"
      include "hms_geometry.cmn"
*
*     input
      real*8 ray(4)           ! xt,yt,xpt,ypt
      integer*4 iplane        ! plane number
*     output
      real*8 H_DPSIFUN         ! value of psi coordinate of hit of ray in plane
*
*     local variables   
      real*8 denom,infinity,cinfinity
      parameter (infinity = 1.0d20)
      parameter (cinfinity = 1/infinity)
*
      H_DPSIFUN =  ray(3)*ray(2)*dfloat(hplane_coeff(1,iplane)) 
     &        + ray(4)*ray(1)*dfloat(hplane_coeff(2,iplane))
     &        + ray(3)*dfloat(hplane_coeff(3,iplane)) 
     &        + ray(4)*dfloat(hplane_coeff(4,iplane))
     &        + ray(1)*dfloat(hplane_coeff(5,iplane))
     &        + ray(2)*dfloat(hplane_coeff(6,iplane))
*
      denom = ray(3)*dfloat(hplane_coeff(7,iplane)) 
     &      + ray(4)*dfloat(hplane_coeff(8,iplane))  
     &      + dfloat(hplane_coeff(9,iplane))
*
      if(abs(denom).lt.cinfinity) then
          H_DPSIFUN=infinity
      else
          H_DPSIFUN = H_DPSIFUN/denom
      endif
      return
      end  
