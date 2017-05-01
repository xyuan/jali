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
# Build TPL:  ZLIB 
#   

# --- Define all the directories and common external project flags
define_external_project_args(ZLIB
                             TARGET zlib
                             BUILD_IN_SOURCE)


# add version version to the autogenerated tpl_versions.h file
Jali_tpl_version_write(FILENAME ${TPL_VERSIONS_INCLUDE_FILE}
  PREFIX ZLIB
  VERSION ${ZLIB_VERSION_MAJOR} ${ZLIB_VERSION_MINOR} ${ZLIB_VERSION_PATCH})
  
# --- Define the CMake configure parameters
# Note:
#      CMAKE_CACHE_ARGS requires -DVAR:<TYPE>=VALUE syntax
#      CMAKE_ARGS -DVAR=VALUE OK
# NO WHITESPACE between -D and VAR. Parser blows up otherwise.
set(ZLIB_CMAKE_CACHE_ARGS
                  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
                  -DCMAKE_INSTALL_PREFIX:STRING=<INSTALL_DIR>
                  -DBUILD_SHARED_LIBS:BOOL=FALSE)

# --- Add external project build and tie to the ZLIB build target
ExternalProject_Add(${ZLIB_BUILD_TARGET}
                    DEPENDS   ${ZLIB_PACKAGE_DEPENDS}             # Package dependency target
                    TMP_DIR   ${ZLIB_tmp_dir}                     # Temporary files directory
                    STAMP_DIR ${ZLIB_stamp_dir}                   # Timestamp and log directory
                    # -- Download and URL definitions
                    DOWNLOAD_DIR ${TPL_DOWNLOAD_DIR}              # Download directory
                    URL          ${ZLIB_URL}                      # URL may be a web site OR a local file
                    URL_MD5      ${ZLIB_MD5_SUM}                  # md5sum of the archive file
                    # -- Configure
                    SOURCE_DIR       ${ZLIB_source_dir}               # Source directory
                    CMAKE_CACHE_ARGS ${ZLIB_CMAKE_CACHE_ARGS}         # CMAKE_CACHE_ARGS or CMAKE_ARGS => CMake configure
                                     ${Jali_CMAKE_C_COMPILER_ARGS}  # Ensure uniform build
                                     -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
                    # -- Build
                    BINARY_DIR        ${ZLIB_build_dir}           # Build directory 
                    BUILD_COMMAND     $(MAKE)                     # $(MAKE) enables parallel builds through make
                    BUILD_IN_SOURCE   ${ZLIB_BUILD_IN_SOURCE}     # Flag for in source builds
                    # -- Install
                    INSTALL_DIR      ${TPL_INSTALL_PREFIX}        # Install directory
                    # -- Output control
                    ${ZLIB_logging_args})

# --- Useful variables that depend on ZlIB (HDF5, NetCDF)
include(BuildLibraryName)
build_library_name(z ZLIB_LIBRARIES APPEND_PATH ${TPL_INSTALL_PREFIX}/lib)
set(ZLIB_INCLUDE_DIRS ${TPL_INSTALL_PREFIX}/include)
