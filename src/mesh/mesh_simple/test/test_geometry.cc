#include <iostream>
#include <vector>
#include <iterator>

#include "cmath"  // for M_PI in spherical mesh test

#include "UnitTest++.h"
#include "../Mesh_simple.hh"

TEST(MESH_GEOMETRY) {
  // Construct a 2x2x2 cell mesh and check cell volumes and face areas
  const int numcells = 8;
  const int numnodes = 27;
  const int numfaces = 36;
  const int numfaces_per_cell = 6;
  Jali::Mesh_simple mesh(0.0, 0.0, 0.0, 2.0, 2.0, 2.0,
                         2, 2, 2,
                         MPI_COMM_WORLD);

  CHECK_EQUAL(numcells, mesh.num_entities(Jali::CELL, Jali::OWNED));
  CHECK_EQUAL(numnodes, mesh.num_entities(Jali::NODE, Jali::OWNED));
  CHECK_EQUAL(numfaces, mesh.num_entities(Jali::FACE, Jali::OWNED));

  // move the one domain boundary's nodes
  mesh.node_set_coordinates(2, {3.0, 0.0, 0.0});
  mesh.node_set_coordinates(5, {3.0, 1.0, 0.0});
  mesh.node_set_coordinates(8, {3.0, 2.0, 0.0});
  mesh.node_set_coordinates(11, {3.0, 0.0, 1.0});
  mesh.node_set_coordinates(14, {3.0, 1.0, 1.0});
  mesh.node_set_coordinates(17, {3.0, 2.0, 1.0});
  mesh.node_set_coordinates(20, {3.0, 0.0, 2.0});
  mesh.node_set_coordinates(23, {3.0, 1.0, 2.0});
  mesh.node_set_coordinates(26, {3.0, 2.0, 2.0});

  // the expected cell volume for each cell
  // the small cells are 1.0^3
  // the big cells are 1.0x1.0x2.0
  std::vector<double> exp_cell_vol = {1.0, 2.0,
                                      1.0, 2.0,
                                      1.0, 2.0,
                                      1.0, 2.0};

  // the expected face areas
  // small faces are 1x1
  // big faces are 2x1
  std::vector<double> exp_face_area = {1.0, 2.0, 1.0, 2.0,
                                       1.0, 2.0, 1.0, 2.0,
                                       1.0, 2.0, 1.0, 2.0,

                                       1.0, 2.0, 1.0, 2.0,
                                       1.0, 2.0, 1.0, 2.0,
                                       1.0, 2.0, 1.0, 2.0,

                                       1.0, 1.0, 1.0, 1.0,
                                       1.0, 1.0, 1.0, 1.0,
                                       1.0, 1.0, 1.0, 1.0};

  // the expected face direction for each face in each cell
  // faces are returned in Exodus II convention; for this mesh type, on a unit
  // cube, the ordering would be the following planes:
  //  y=0, x=1, y=1, x=0, z=0, z=1
  // The direction convention is that +1 corresponds to a vector pointing out of
  // of the cell, and -1 corresponds to into a cell
  //
  // 3D SimpleMesh appears to set things up such that all vectors orthogonal to
  // x-planes point in the +x direction, y-planes point in the -y direction, and
  // z=planes point in the +z direction; this gives all cells the same
  // orientation
  int exp_cell_face_dir[numcells][numfaces_per_cell] = {{1, 1, -1, -1, -1, 1},
                                                        {1, 1, -1, -1, -1, 1},
                                                        {1, 1, -1, -1, -1, 1},
                                                        {1, 1, -1, -1, -1, 1},
                                                        {1, 1, -1, -1, -1, 1},
                                                        {1, 1, -1, -1, -1, 1},
                                                        {1, 1, -1, -1, -1, 1},
                                                        {1, 1, -1, -1, -1, 1}};
  // check the cell volume and direction of faces for each cell
  Jali::Entity_ID_List faces;
  std::vector<int> face_dirs;
  for (Jali::Entity_ID c = 0; c < numcells; ++c) {
    CHECK_EQUAL(exp_cell_vol[c], mesh.cell_volume(c));

    mesh.cell_get_faces_and_dirs(c, &faces, &face_dirs);
    CHECK_ARRAY_EQUAL(exp_cell_face_dir[c], face_dirs, numfaces_per_cell);
  }

  // check the face areas
  for (int i = 0; i < numfaces; ++i) {
    CHECK_EQUAL(exp_face_area[i], mesh.face_area(i));
  }
}


TEST(MESH_GEOMETRY_1D) {
  // Construct a 2 cell mesh and check cell volumes and face areas
  const int numcells = 2;
  const int numnodes = 3;
  const int numfaces = 3;
  const int numfaces_per_cell = 2;
  std::vector<double> node_pts = {0.0, 1.0, 3.0};
  Jali::Mesh_simple mesh(node_pts, MPI_COMM_WORLD, NULL,
                         true, true, true, true, JaliGeometry::CARTESIAN);

  CHECK_EQUAL(numcells, mesh.num_entities(Jali::CELL, Jali::OWNED));
  CHECK_EQUAL(numnodes, mesh.num_entities(Jali::NODE, Jali::OWNED));
  CHECK_EQUAL(numfaces, mesh.num_entities(Jali::FACE, Jali::OWNED));

  // the expected cell volume for each cell
  // the small cell is 1.0^3
  // the big cell is 1.0x1.0x2.0
  std::vector<double> exp_cell_vol = {1.0, 2.0};

  // the expected face areas
  // all faces are 1x1
  std::vector<double> exp_face_area = {1.0, 1.0, 1.0};

  // the expected face direction for each face in each cell
  //
  // the left face of a zone always points in the -1 direction
  // the right face of a zone always points in the +1 direction
  int exp_cell_face_dir[numcells][numfaces_per_cell] = {{-1, 1},
                                                        {-1, 1}};

  // check the cell volume and direction of faces for each cell
  Jali::Entity_ID_List faces;
  std::vector<int> face_dirs;
  for (Jali::Entity_ID c = 0; c < numcells; ++c) {
    CHECK_EQUAL(exp_cell_vol[c], mesh.cell_volume(c));

    mesh.cell_get_faces_and_dirs(c, &faces, &face_dirs);
    CHECK_ARRAY_EQUAL(exp_cell_face_dir[c], face_dirs, numfaces_per_cell);
  }

  // check the face areas
  for (int i = 0; i < numfaces; ++i) {
    CHECK_EQUAL(exp_face_area[i], mesh.face_area(i));
  }
}


TEST(MESH_GEOMETRY_1D_SPHERICAL) {
  // Construct a 2 cell mesh and check cell volumes and face areas
  // a spherical mesh volume has differences of cubes of radii; hence we
  // use a tolerance to do the UnitTest++ check for equality
  const double tolerance = 1e-12;
  const int numcells = 2;
  const int numnodes = 3;
  const int numfaces = 3;
  const int numfaces_per_cell = 2;
  std::vector<double> node_pts = {0.0, 1.0, 3.0};
  Jali::Mesh_simple mesh(node_pts, MPI_COMM_WORLD, NULL,
                         true, true, true, true, JaliGeometry::SPHERICAL);

  CHECK_EQUAL(numcells, mesh.num_entities(Jali::CELL, Jali::OWNED));
  CHECK_EQUAL(numnodes, mesh.num_entities(Jali::NODE, Jali::OWNED));
  CHECK_EQUAL(numfaces, mesh.num_entities(Jali::FACE, Jali::OWNED));

  // the expected cell volume for each cell
  // the small cell is (4/3)*PI*1.0^3
  // the big cell is (4/3)*PI*(3.0^3-1.0^3)
  std::vector<double> exp_cell_vol = {(4.0/3.0)*M_PI,
                                      (4.0/3.0)*M_PI*26.0};

  // the expected face areas
  // all faces are 4.0*PI*r^2
  std::vector<double> exp_face_area = {0.0,
                                       4.0*M_PI,
                                       4.0*M_PI*9.0};

  // the expected face direction for each face in each cell
  //
  // the left face of a zone always points in the -1 direction
  // the right face of a zone always points in the +1 direction
  int exp_cell_face_dir[numcells][numfaces_per_cell] = {{-1, 1},
                                                        {-1, 1}};

  // check the cell volume and direction of faces for each cell
  Jali::Entity_ID_List faces;
  std::vector<int> face_dirs;
  for (Jali::Entity_ID c = 0; c < numcells; ++c) {
    CHECK_CLOSE(exp_cell_vol[c], mesh.cell_volume(c), tolerance);

    mesh.cell_get_faces_and_dirs(c, &faces, &face_dirs);
    CHECK_ARRAY_EQUAL(exp_cell_face_dir[c], face_dirs, numfaces_per_cell);
  }

  // check the face areas
  for (int i = 0; i < numfaces; ++i) {
    CHECK_EQUAL(exp_face_area[i], mesh.face_area(i));
  }
}


