/*
Copyright (c) 2017, Los Alamos National Security, LLC
All rights reserved.

Copyright 2017. Los Alamos National Security, LLC. This software was
produced under U.S. Government contract DE-AC52-06NA25396 for Los
Alamos National Laboratory (LANL), which is operated by Los Alamos
National Security, LLC for the U.S. Department of Energy. The
U.S. Government has rights to use, reproduce, and distribute this
software.  NEITHER THE GOVERNMENT NOR LOS ALAMOS NATIONAL SECURITY,
LLC MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LIABILITY
FOR THE USE OF THIS SOFTWARE.  If software is modified to produce
derivative works, such modified software should be clearly marked, so
as not to confuse it with the version available from LANL.
 
Additionally, redistribution and use in source and binary forms, with
or without modification, are permitted provided that the following
conditions are met:

1.  Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2.  Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3.  Neither the name of Los Alamos National Security, LLC, Los Alamos
National Laboratory, LANL, the U.S. Government, nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY LOS ALAMOS NATIONAL SECURITY, LLC AND
CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LOS
ALAMOS NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


/**
 * @file   PlaneRegion.hh
 * @author Rao Garimella
 * @date
 *
 * @brief  Declaration of PlaneRegion class
 *
 *
 */

#ifndef _PlaneRegion_hh_
#define _PlaneRegion_hh_

#include "Region.hh"

namespace JaliGeometry {

// -------------------------------------------------------------
//  class PlaneRegion
// -------------------------------------------------------------
/// A planar (infinite) region in space, defined by a point and a plane

class PlaneRegion : public Region {
public:

  /// Default constructor uses point and normal

  PlaneRegion(const std::string name, const unsigned int id, const Point& p,
              const Point& normal,
              const LifeCycle_type lifecycle = LifeCycle_type::PERMANENT);

  /// Protected copy constructor to avoid unwanted copies.
  PlaneRegion(const PlaneRegion& old);

  /// Destructor
  ~PlaneRegion(void);

  // Type of the region
  inline Region_type type() const { return Region_type::PLANE; }

  /// Get the point defining the plane
  const Point& point(void) const { return p_; }

  /// Get the normal point defining the plane
  const Point& normal(void) const { return n_; }

  /// Is the specified point inside this region - in this case it
  /// means on the plane

  bool inside(const Point& p) const;

protected:

  const Point p_;              /* point on the plane */
  const Point n_;              /* normal to the plane */

};

/// A smart pointer to PlaneRegion instances
// typedef Teuchos::RCP<PlaneRegion> PlaneRegionPtr;

// RVG: I am not able to correctly code a region factory using smart
// pointers so I will revert to a simpler definition

typedef PlaneRegion *PlaneRegionPtr;

} // namespace JaliGeometry


#endif
