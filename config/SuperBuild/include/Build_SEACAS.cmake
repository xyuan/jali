# Copyright (c) 2017, Los Alamos National Security, LLC
# All rights reserved.

# Copyright 2017. Los Alamos National Security, LLC. This software was
# produced under U.S. Government contract DE-AC52-06NA25396 for Los
# Alamos National Laboratory (LANL), which is operated by Los Alamos
# National Security, LLC for the U.S. Department of Energy. The
# U.S. Government has rights to use, reproduce, and distribute this
# software.  NEITHER THE GOVERNMENT NOR LOS ALAMOS NATIONAL SECURITY,
# LLC MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LIABILITY
# FOR THE USE OF THIS SOFTWARE.  If software is modified to produce
# derivative works, such modified software should be clearly marked, so
# as not to confuse it with the version available from LANL.
 
# Additionally, redistribution and use in source and binary forms, with
# or without modification, are permitted provided that the following
# conditions are met:

# 1.  Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3.  Neither the name of Los Alamos National Security, LLC, Los Alamos
# National Laboratory, LANL, the U.S. Government, nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
 
# THIS SOFTWARE IS PROVIDED BY LOS ALAMOS NATIONAL SECURITY, LLC AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LOS
# ALAMOS NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#
# Build TPL: SEACAS 
#    
# --- Define all the directories and common external project flags

# SEACAS does not call MPI directly, however HDF5 requires
# MPI and to resolve links we need MPI compile wrappers.
define_external_project_args(SEACAS
                             TARGET seacas
                             DEPENDS ${MPI_PROJECT} HDF5 NetCDF Trilinos)


# add version version to the autogenerated tpl_versions.h file
Jali_tpl_version_write(FILENAME ${TPL_VERSIONS_INCLUDE_FILE}
  PREFIX SEACAS
  VERSION ${SEACAS_VERSION_MAJOR} ${SEACAS_VERSION_MINOR} ${SEACAS_VERSION_PATCH})
  
# --- Define the configure parameters

# Compile flags
set(seacas_cflags_list -I${TPL_INSTALL_PREFIX}/include ${Jali_COMMON_CFLAGS})
build_whitespace_string(seacas_cflags ${seacas_cflags_list})

set(seacas_cxxflags_list -I${TPL_INSTALL_PREFIX}/include ${Jali_COMMON_CXXFLAGS})
build_whitespace_string(seacas_cflags ${seacas_cxxflags_list})

set(seacas_fcflags_list -I${TPL_INSTALL_PREFIX}/include ${Jali_COMMON_FCFLAGS})
build_whitespace_string(seacas_fcflags ${seacas_fcflags_list})

# Build the NetCDF libraries string
include(BuildLibraryName)
build_library_name(netcdf seacas_netcdf_library STATIC APPEND_PATH ${TPL_INSTALL_PREFIX}/lib)
build_library_name(hdf5_hl seacas_hdf5_hl_library STATIC APPEND_PATH ${TPL_INSTALL_PREFIX}/lib)
build_library_name(hdf5 seacas_hdf5_library STATIC APPEND_PATH ${TPL_INSTALL_PREFIX}/lib)
build_library_name(z seacas_z_library STATIC APPEND_PATH ${TPL_INSTALL_PREFIX}/lib)
set(seacas_netcdf_libraries
       ${seacas_netcdf_library}
       ${seacas_hdf5_hl_library}
       ${seacas_hdf5_library}
       ${seacas_z_library})
if ( (NOT BUILD_MPI) AND (NOT MPI_WRAPPERS_IN_USE) AND (MPI_C_LIBRARIES) )
  list(APPEND seacas_netcdf_libraries ${MPI_C_LIBRARIES})
endif()

# The CMake cache args
set(SEACAS_CMAKE_CACHE_ARGS
                    -DCMAKE_INSTALL_PREFIX:FILEPATH=<INSTALL_DIR>
                    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
                    ${Jali_CMAKE_C_COMPILER_ARGS}
                    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER_USE}
                    ${Jali_CMAKE_CXX_COMPILER_ARGS}
                    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER_USE}
                    ${Jali_CMAKE_Fortran_COMPILER_ARGS}
                    -DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER_USE}
                    -DCMAKE_EXE_LINKER_FLAGS:STRING=-L${TPL_INSTALL_PREFIX}/lib
                    -DTrilinos_ENABLE_ALL_PACKAGES:BOOL=FALSE
                    -DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=FALSE
                    -DTrilinos_ENABLE_SEACAS:BOOL=TRUE
                    -DTPL_ENABLE_Matio:BOOL=OFF
                    -DTPL_Netcdf_LIBRARIES:STRING=${seacas_netcdf_libraries}
                    -DNetcdf_INCLUDE_DIRS:STRING=${TPL_INSTALL_PREFIX}/include
                    -DTPL_ENABLE_X11:BOOL=FALSE
                    )

# --- Add external project build and tie to the SEACAS build target
ExternalProject_Add(${SEACAS_BUILD_TARGET}
                    DEPENDS   ${SEACAS_PACKAGE_DEPENDS}             # Package dependency target
                    TMP_DIR   ${SEACAS_tmp_dir}                     # Temporary files directory
                    STAMP_DIR ${SEACAS_stamp_dir}                   # Timestamp and log directory
                    # -- Download and URL definitions
                    DOWNLOAD_DIR ${TPL_DOWNLOAD_DIR}                # Download directory
                    URL          ${SEACAS_URL}                      # URL may be a web site OR a local file
                    URL_MD5      ${SEACAS_MD5_SUM}                  # md5sum of the archive file
                    # -- Configure
                    SOURCE_DIR       ${SEACAS_source_dir}           # Source directory
                    CMAKE_CACHE_ARGS ${SEACAS_CMAKE_CACHE_ARGS}
                    # -- Build
                    BINARY_DIR        ${SEACAS_build_dir}           # Build directory 
                    BUILD_COMMAND     $(MAKE)                       # $(MAKE) enables parallel builds through make
                    BUILD_IN_SOURCE   ${SEACAS_BUILD_IN_SOURCE}     # Flag for in source builds
                    # -- Install
                    INSTALL_DIR      ${TPL_INSTALL_PREFIX}/SEACAS   # Install directory, NOT in the usual place!
                    # -- Output control
                    ${SEACAS_logging_args})
