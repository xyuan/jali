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
#  jali
#    statemanager
#

# Jali module, include files found in JALI_MODULE_PATH
include(PrintVariable)

#
# Define a project name
# After this command the following varaibles are defined
#   JALI_STATE_SOURCE_DIR
#   JALI_STATE_BINARY_DIR
# Other projects (subdirectories) can reference this directory
# through these variables.
project(JALI_STATE)

# Jali include directories
include_directories(${DBC_SOURCE_DIR})
include_directories(${GEOMETRY_SOURCE_DIR})
include_directories(${MESH_SOURCE_DIR})

include_directories(${Boost_INCLUDE_DIRS})

#
# Library: 
#
add_Jali_library(jali_state 
  SOURCE JaliStateVector.h JaliState.h JaliState.cc 
  LINK_LIBS mesh)

#
# Install Header files
#
file(GLOB state_inc_files "*.h")
add_install_include_file(${state_inc_files})


if (BUILD_TESTS)

    # Include dirs for test
    include_directories(${JALI_STATE_SOURCE_DIR})
    include_directories(${MESH_SOURCE_DIR})
    include_directories(${MESH_FACTORY_SOURCE_DIR})
    include_directories(${GEOMETRY_SOURCE_DIR})

    # Add UnitTest ExodusII include directories
    include_directories(${UnitTest_INCLUDE_DIRS})

    # Need to copy files for the tests 
    if (NOT (${JALI_STATE_SOURCE_DIR} EQUAL ${JALI_STATE_BINARY_DIR}))
      execute_process(COMMAND ${CMAKE_COMMAND} -E 
        copy_directory ${JALI_STATE_SOURCE_DIR}/test ${JALI_STATE_BINARY_DIR}/test) 
    endif()

    # Test link libraries
    set(test_link_libs jali_state mesh mstk_mesh mesh_factory ${UnitTest_LIBRARIES})

    # Test state vectors

    set(test_src_files test/Main.cc test/test_jali_state_vector.cc)

    add_Jali_test(jali_state_vectors test_jali_state_vectors
                    KIND unit
		    SOURCE ${test_src_files}
		    LINK_LIBS ${test_link_libs})

    # Test state

    set(test_src_files test/Main.cc test/test_jali_state.cc)

    add_Jali_test(jali_state test_jali_state
                  KIND unit
		  SOURCE ${test_src_files}
		  LINK_LIBS ${test_link_libs})

endif()
  
