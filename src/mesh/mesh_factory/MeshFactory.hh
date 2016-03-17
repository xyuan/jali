/* -*-  mode: c++; c-default-style: "google"; indent-tabs-mode: nil -*- */
// -------------------------------------------------------------
/**
 * @file   MeshFactory.hh
 * @author William A. Perkins
 * @date Wed Sep 28 09:10:15 2011
 * 
 * @brief  declaration of the MeshFactory class
 * 
 * 
 */
// -------------------------------------------------------------
// -------------------------------------------------------------
// Created March 10, 2011 by William A. Perkins
// Last Change: Wed Sep 28 09:10:15 2011 by William A. Perkins <d3g096@PE10900.pnl.gov>
// -------------------------------------------------------------

#ifndef _MeshFactory_hh_
#define _MeshFactory_hh_

#include <string>
#include <vector>
#include <mpi.h>

#include "MeshException.hh"
#include "MeshFramework.hh"
#include "Mesh.hh"

#include "GeometricModel.hh"

namespace Jali {

// -------------------------------------------------------------
//  class MeshFactory
// -------------------------------------------------------------
class MeshFactory {
 protected:

  /// The parallel environment
  const MPI_Comm my_comm;

  /// A list of preferred mesh frameworks to consider
  FrameworkPreference my_preference;

 private:

  /// private, undefined copy constructor to avoid unwanted copies
  MeshFactory(MeshFactory& old);

  /// Create a mesh by reading the specified file (or set of files)
  std::shared_ptr<Mesh> create(const std::string& filename, 
                               const JaliGeometry::GeometricModelPtr &gm = 
                               (JaliGeometry::GeometricModelPtr) NULL,
                               const bool request_faces = true,
                               const bool request_edges = false,
                               const bool request_wedges=false,
                               const bool request_corners=false);


  /// Create a hexahedral mesh of the specified dimensions
  std::shared_ptr<Mesh> create(double x0, double y0, double z0,
                               double x1, double y1, double z1,
                               int nx, int ny, int nz,
                               const JaliGeometry::GeometricModelPtr &gm =
                               (JaliGeometry::GeometricModelPtr) NULL,
                               const bool request_faces = true,
                               const bool request_edges = false,
                               const bool request_wedges=false,
                               const bool request_corners=false);


  /// Create a quadrilateral mesh of the specified dimensions
  std::shared_ptr<Mesh> create(double x0, double y0,
                               double x1, double y1,
                               int nx, int ny,
                               const JaliGeometry::GeometricModelPtr &gm =
                               (JaliGeometry::GeometricModelPtr) NULL,
                               const bool request_faces = true,
                               const bool request_edges = false,
                               const bool request_wedges = false,
                               const bool request_corners = false);


  /// Create a 1d mesh
  std::shared_ptr<Mesh> create(std::vector<double> x,
                               const JaliGeometry::GeometricModelPtr &gm =
                               (JaliGeometry::GeometricModelPtr) NULL,
                               const bool request_faces = true,
                               const bool request_edges = false,
                               const bool request_wedges=false,
                               const bool request_corners=false,
                               const Jali::Geom_type geom_type=Jali::CARTESIAN);


  /// Create a mesh by extract subsets of entities from an existing mesh
  std::shared_ptr<Mesh> create(const std::shared_ptr<Mesh> inmesh,
                               const std::vector<std::string> setnames,
                               const Entity_kind setkind,
                               const bool flatten = false,
                               const bool extrude = false,
                               const bool request_faces = true,
                               const bool request_edges = false,
                               const bool request_wedges = false,
                               const bool request_corners = false);

 public:

  /// Default constructor.
  explicit MeshFactory(const MPI_Comm& communicator);

  /// Destructor
  ~MeshFactory(void);

  /// Get the framework preference
  const FrameworkPreference& preference(void) const
  { return my_preference; }

  /// Set the framework preference
  void preference(const FrameworkPreference& pref);

  /// Create a mesh by reading the specified file (or set of files) -- operator
  std::shared_ptr<Mesh> operator() (const std::string& filename, 
                                    const JaliGeometry::GeometricModelPtr &gm = 
                                    (JaliGeometry::GeometricModelPtr) NULL,
                                    const bool request_faces = true,
                                    const bool request_edges = false,
                                    const bool request_wedges = false,
                                    const bool request_corners = false) {

    return create(filename, gm, request_faces, request_edges, request_wedges,
                  request_corners);
  }
  
  /// Create a hexahedral mesh of the specified dimensions -- operator
  std::shared_ptr<Mesh> operator() (double x0, double y0, double z0,
                                    double x1, double y1, double z1,
                                    int nx, int ny, int nz, 
                                    const JaliGeometry::GeometricModelPtr &gm = 
                                    (JaliGeometry::GeometricModelPtr) NULL,
                                    const bool request_faces = true,
                                    const bool request_edges = false,
                                    const bool request_wedges = false,
                                    const bool request_corners = false) {
    
    return create(x0, y0, z0, x1, y1, z1, nx, ny, nz, gm, request_faces,
                  request_edges, request_wedges, request_corners);
  }

  /// Create a quadrilateral mesh of the specified dimensions -- operator
  std::shared_ptr<Mesh> operator() (double x0, double y0,
                                    double x1, double y1,
                                    int nx, int ny,
                                    const JaliGeometry::GeometricModelPtr &gm = 
                                    (JaliGeometry::GeometricModelPtr) NULL,
                                    const bool request_faces = true,
                                    const bool request_edges = false,
                                    const bool request_wedges = false,
                                    const bool request_corners = false)  {
 
    return create(x0, y0, x1, y1, nx, ny, gm, request_faces, request_edges,
                  request_wedges, request_corners);
  }

  /// Create a 1d mesh -- operator
  std::unique_ptr<Mesh> operator() (std::vector<double> x,
                    const JaliGeometry::GeometricModelPtr &gm = 
                    (JaliGeometry::GeometricModelPtr) NULL,
                    const bool request_faces = true,
                    const bool request_edges = false,
                    const bool request_wedges=false,
                    const bool request_corners=false,
                    const Jali::Geom_type geom_type=Jali::CARTESIAN)  {
 
    return std::unique_ptr<Mesh>(create(x, gm, request_faces, request_edges,
                                        request_wedges, request_corners,
                                        geom_type));
  }

  /// Create a 1d mesh -- operator
  std::unique_ptr<Mesh> operator() (double x0, double x1,
                    int nx,
                    const JaliGeometry::GeometricModelPtr &gm = 
                    (JaliGeometry::GeometricModelPtr) NULL,
                    const bool request_faces = true,
                    const bool request_edges = false,
                    const bool request_wedges=false,
                    const bool request_corners=false,
                    const Jali::Geom_type geom_type=Jali::CARTESIAN) {

    double dX = (x1-x0)/((double)nx);
    double myX = x0;

    std::vector<double> x(nx);
    for(auto it = x.begin(); it != x.end(); it++) {
      *it = myX;
      myX += dX;
    }

    return std::unique_ptr<Mesh>(create(x, gm, request_faces, request_edges,
                                        request_wedges, request_corners,
                                        geom_type));
  }

  /// Create a mesh by extract subsets of entities from an existing mesh
  std::shared_ptr<Mesh> operator() (const std::shared_ptr<Mesh> inmesh,
                                    const std::vector<std::string> setnames,
                                    const Entity_kind setkind,
                                    const bool flatten = false,
                                    const bool extrude = false,
                                    const bool request_faces = true,
                                    const bool request_edges = false,
                                    const bool request_wedges = false,
                                    const bool request_corners = false) {
    
    return create(inmesh, setnames, setkind, flatten, extrude, request_faces,
                  request_edges, request_wedges, request_corners);
  }

};

} // namespace Jali

#endif
