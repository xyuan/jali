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

# - FindHDF5.cmake 
#
#  The FindHDF5 module with the CMake distribution will not work if
#  the HDF5 compilers are not installed or if more the one hdf5 is on the
#  system. The search logic also depends on an environment variable
#  HDF5_ROOT. This module removes both requirements and insteead relies on the 
#  libhdf5.settings file found in the library installation directory
#
#  This module will ONLY work for HDF5 configured through the GNU 
#  autoconf script configure. When built through CMake, the *config.cmake
#  files should be used.
#
#

# CMake includes
include(FindPackageHandleStandardArgs)

include(PrintVariable)
include(AddImportedLibrary)

# ---------------------------------------------------------------------------- #
# Functions/Macros
#
#
macro(_HDF5_BOOLEAN_CONVERT _var)
  string(TOUPPER ${${_var}} _var_UC)
  if(_var_UC)
    set(${_var} TRUE)
  else()
    set(${_var} FALSE)
  endif()  
endmacro(_HDF5_BOOLEAN_CONVERT)

function(_HDF5_CHOMP_STRING old_str new_str_var)

  string(REGEX REPLACE "[\t\r\n]" " " _tmp "${old_str}")
  #string(REGEX REPLACE " " "S" _tmp "${_tmp}")
  string(REGEX REPLACE "^ +" "" _tmp "${_tmp}")
  string(REGEX REPLACE " +$" "" _tmp "${_tmp}")

  set(${new_str_var} ${_tmp} PARENT_SCOPE)

endfunction(_HDF5_CHOMP_STRING)

function(_HDF5_PARSE_SETTINGS_FILE _file _key _value)
  
  set(_tmp ${_value}-NOTFOUND)
  file(STRINGS ${_file} _output 
       REGEX "^[ \t]*${_key}:|^${_key}")
  
  if(_output)
    # _HDF5_CHOMP_STRING will remove all tabs, newlines and returns
    # It also removes leading  and trailing whitespace
    _HDF5_CHOMP_STRING(${_output} _output)
    # Remove the key signature
    string(REGEX REPLACE "${_key}:" "" _output "${_output}")
    # CHOMP again to remove leading and trailing whitespace
    if (_output)
      _HDF5_CHOMP_STRING(${_output} _output)
    endif()  
    # Entry is non-empty if ANY non-space character is left
    if ( "${_output}" MATCHES "[^ ]" )
      set(_tmp ${_output})
    endif()
  endif()
  
  set(${_value} ${_tmp} PARENT_SCOPE)

endfunction(_HDF5_PARSE_SETTINGS_FILE)

function(_HDF5_DEFINE_VERSION _file _var)

  set(_search_key "HDF5 Version")
  _HDF5_PARSE_SETTINGS_FILE(${_file} ${_search_key} _tmp)

  set(${_var} ${_tmp} PARENT_SCOPE)
  
endfunction(_HDF5_DEFINE_VERSION _var)

function(_HDF5_DEFINE_PARALLEL_BUILD _file _var)

  set(_search_key "Parallel HDF5")
  _HDF5_PARSE_SETTINGS_FILE(${_file} ${_search_key} _tmp)
  _HDF5_BOOLEAN_CONVERT(_tmp)

  set(${_var} ${_tmp} PARENT_SCOPE)

endfunction(_HDF5_DEFINE_PARALLEL_BUILD _file _var)

function(_HDF5_EXTRA_LIBRARY_DIRS _file _var)

  # Settings file has several locations to list LDFLAGS
  # We'll pick them all and sort out later.
  set(_search_ldflags_keys "AM_LDFLAGS;H5_LDFLAGS;LDFLAGS;Extra libraries")
  set(_ldflags "")
  foreach ( _key ${_search_ldflags_keys})
    _HDF5_PARSE_SETTINGS_FILE(${_file} ${_key} _tmp)
    if ( _tmp )
      set(_ldflags "${_ldflags} ${_tmp}")
    endif()
  endforeach()  

  # Now match all the -L flags
  string(REGEX MATCHALL "-L([^\" ]+|\"[^\"]+\")" _lib_path_flags ${_ldflags})

  # Loop through each
  set(_directories)
  foreach(_dir ${_lib_path_flags})
    string(REGEX REPLACE "^-L" "" _dir ${_dir})
    string(REGEX REPLACE "//" "/" _dir ${_dir})
    list(APPEND _directories ${_dir})
  endforeach()  

  if(_directories)
    list(REMOVE_DUPLICATES _directories)
  endif()  
  set(${_var} ${_directories} PARENT_SCOPE)

endfunction(_HDF5_EXTRA_LIBRARY_DIRS _file _var)

function(_HDF5_EXTRA_LIBRARIES _file _var)

  # Find all the extra libraries defined in the file
  set(_search_key "Extra libraries")
  set(_libraries)
  _HDF5_PARSE_SETTINGS_FILE(${_file} ${_search_key} _library_flags)
  string( REGEX MATCHALL "[, ]-l([^\", ]+)|^-l([^\", ]+)" _library_name_flags ${_library_flags})
  foreach ( _lib ${_library_name_flags} )
    _HDF5_CHOMP_STRING(${_lib} _lib_chomp)
    string( REGEX REPLACE "^[,]-l|^-l" "" _lib_chomp ${_lib_chomp})
    list(APPEND _libraries ${_lib_chomp})
  endforeach()

  # Grab all the extra library paths to build a search list
  _HDF5_EXTRA_LIBRARY_DIRS(${_file} _search_list)

  # Loop through each library
  #  (1) find_library with the search list for hints
  #  (2) Add library name if find succeeds, otherwise
  #      add the name to the list. 
  set(_return_list)
  foreach( _lib ${_libraries})

    # Search with hints
    set(_lib_name _lib_name-NOTFOUND)
    find_library(_lib_name
                 NAMES ${_lib}
   HINTS ${_search_list}
   )
    # Search without hints if the first search fails        
    if ( NOT _lib_name )
      find_library(_lib_name NAMES ${_lib})
    endif()   

    # Add the full library name if either find succeeded
    # otherwise add the library name.
    if(_lib_name)
      list(APPEND _return_list ${_lib_name})
    else()
      list(APPEND _return_list ${_lib})
    endif()
   
  endforeach()

  set(${_var} ${_return_list} PARENT_SCOPE)

endfunction(_HDF5_EXTRA_LIBRARIES _file _var)

function(_HDF5_EXTRA_INCLUDE_DIRS _file _var)

  # Settings file has several locations to list LDFLAGS
  # We'll pick them all and sort out later.

  # Keys in the file changed around version 1.8.3
  set(_search_cflags_keys "CFLAGS;H5_CFLAGS;AM_CFLAGS;CPPFLAGS;H5_CPPFLAGS;AM_CPPFLAGS")

  if ( HDF5_VERSION_STRING )
    if ( "${HDF5_VERSION_STRING}" VERSION_LESS "1.8.3")
      set(_search_cflags_keys "CFLAGS/H5_CFLAGS;AM_CFLAGS;CPPFLAGS/H5_CPPFLAGS;AM_CPPFLAGS")
    endif()
  endif()

  set(_cflags "")
  foreach ( _key ${_search_cflags_keys})
    _HDF5_PARSE_SETTINGS_FILE(${_file} ${_key} _tmp)
    if ( _tmp )
      set(_cflags "${_cflags} ${_tmp}")
    endif()
  endforeach()  

  # Now match all the -I flags
  string(REGEX MATCHALL "-I([^\" ]+|\"[^\"]+\")" _inc_path_flags ${_cflags})

  # Loop through each
  set(_directories)
  foreach(_dir ${_inc_path_flags})
    string(REGEX REPLACE "^-I" "" _dir ${_dir})
    string(REGEX REPLACE "//" "/" _dir ${_dir})
    list(APPEND _directories ${_dir})
  endforeach()  

  if(_directories)
    list(REMOVE_DUPLICATES _directories)
  endif()  
  set(${_var} ${_directories} PARENT_SCOPE)

endfunction(_HDF5_EXTRA_INCLUDE_DIRS _file _var)

#
# End Functions/Macros
# ---------------------------------------------------------------------------- #

# ------------------------------------ #
# Initialize search paths and criteria #
# ------------------------------------ #

# If HDF5_ROOT was defined in the environment, use it.
# Definition from the command line will take precedence.
if (NOT HDF5_ROOT AND NOT $ENV{HDF5_ROOT} STREQUAL "")
  set(HDF5_ROOT $ENV{HDF5_ROOT})
endif()

# HDF5_DIR is DEPRECATED WARN THE USER if it is set
if (NOT HDF5_ROOT AND HDF5_DIR )
  message(WARNING "The configuration parameter HDF5_DIR is deprecated."
                  " Please use HDF5_ROOT instead to define the HDF5 installation")
  set(HDF5_ROOT ${HDF5_DIR})
endif()  

# Add the usual paths for searching using the HDF5_ROOT variable
if (HDF5_ROOT)
  list(APPEND _hdf5_INCLUDE_SEARCH_DIRS 
              ${HDF5_ROOT}/include
              ${HDF5_ROOT})
 
  list(APPEND _hdf5_LIBRARY_SEARCH_DIRS 
              ${HDF5_ROOT}/lib
              ${HDF5_ROOT})
  
            list(APPEND _hdf5_BINARY_SEARCH_DIRS 
              ${HDF5_ROOT}/bin
              ${HDF5_ROOT})
endif()
 
# Restrict the search to HDF5_ROOT if user does not want other
# directories searched.
if ( HDF5_NO_SYSTEM_PATHS )
  set(_hdf5_FIND_OPTIONS NO_CMAKE_SYSTEM_PATH)
endif()

# A list of valid components
set(HDF5_VALID_COMPONENTS C CXX Fortran HL Fortran_HL)

# A list of requested components, invalid components are ignored.
if ( NOT HDF5_FIND_COMPONENTS )
  set(HDF5_SEARCH_COMPONENTS "C")
else()
  foreach ( component ${HDF5_FIND_COMPONENTS} )
    list(FIND HDF5_VALID_COMPONENTS ${component} component_idx)
    if ( ${component_idx} EQUAL -1 )
      message(SEND_ERROR "${component} is not a valid HDF5 component")
    else()
      list(APPEND HDF5_SEARCH_COMPONENTS ${component})
    endif()
  endforeach()
endif()  


# ------------------------------------ #
# Preform CMake Search                 #
# ------------------------------------ #



if ( HDF5_INCLUDE_DIRS AND HDF5_LIBRARIES )
  # Do nothing is the user has defined these
else()

  # --- Target names used in both the CMake configure files
  #     and here to create targets
  set( HDF5_C_TARGET hdf5 )
  set( HDF5_CXX_TARGET hdf5_cpp )
  set( HDF5_HL_TARGET hdf5_hl )
  set( HDF5_Fortran_TARGET hdf5_fortran )
  set( HDF5_Fortran_HL_TARGET hdf5_hl_fortran )

  # ------------------------------------------------------ #
  # Search Logic
  # (1) Look for a CMake configuration file(s)
  # (2) If the above fails, search by name the include and
  #     library files.
  # Step one will be bypassed if HDF5_NO_HDF5_CMAKE is set
  
  # --- Search for a CMake Configuration 
  if ( NOT HDF5_NO_HDF5_CMAKE )

    # Call find package only looking for CMake config files
    find_package(HDF5 
                 HINTS ${_hdf5_INCLUDE_SEARCH_DIRS} ${_hdf5_LIBRARY_SEARCH_DIRS}
                 QUIET
                 NO_MODULE)

    # If located a HDF5 configuration file
    if (HDF5_FOUND)

      message(STATUS "Found CMake configuration file HDF5 ( directory ${HDF5_DIR} )")

      # Want consistency between this module and the CMake file
      set(HDF5_VERSION      ${HDF5_VERSION_STRING})
      set(HDF5_IS_PARALLEL  ${HDF5_ENABLE_PARALLEL})
      set(HDF5_INCLUDE_DIRS ${HDF5_INCLUDE_DIR})

      # Loop through each possible target and 
      # build the HDF5_LIBRARIES.
      # Target names set by the HDF5 configuration file
      set(HDF5_LIBRARIES)

      foreach( _component ${HDF5_VALID_COMPONENTS} )
        set(target ${HDF5_${_component}_TARGET})
	if ( TARGET ${target} )
	  set(HDF5_${_component}_LIBRARY ${target})
	  list(APPEND HDF5_LIBRARIES ${HDF5_${_component}_LIBRARY})
	endif()  
      endforeach()

      # Define HDF5_C_LIBRARIES to contain hdf5 and hdf5_hl C libraries
      set(HDF5_C_LIBRARIES ${HDF5_C_LIBRARY} ${HDF5_HL_LIBRARY})

    endif(HDF5_FOUND)  
    
  endif(NOT HDF5_NO_HDF5_CMAKE)

  # --- If HDF5 is NOT found search for the settings file installed with the libraries
  #     Will allow the user to define the HDF5_SETTINGS_FILE before attempting a search. 
  if ( NOT HDF5_FOUND AND ( NOT HDF5_SETTINGS_FILE ) )
    find_file(HDF5_SETTINGS_FILE
              NAMES libhdf5.settings
              HINTS ${_hdf5_LIBRARY_SEARCH_DIRS}
              ${_hdf5_FIND_OPTIONS})
  endif()    
     

  # --- Now search by file name. HDF5_INCLUDE_DIRS and HD5_LIBRARIES will
  #     not be set if the CMake configuration search was successful.

  # --- Search for the include files
  if ( NOT HDF5_INCLUDE_DIRS )
    find_path(HDF5_INCLUDE_DIR
              NAMES hdf5.h
              HINTS ${_hdf5_INCLUDE_SEARCH_DIRS}
              ${_hdf5_FIND_OPTIONS})

    if ( NOT HDF5_INCLUDE_DIR )
      message(FATAL_ERROR "Failed to locate HDF5 include file")
    endif()  

    # Check the settings file for other include directories
    if ( HDF5_SETTINGS_FILE )
      _HDF5_EXTRA_INCLUDE_DIRS(${HDF5_SETTINGS_FILE} extra_inc_dirs)
    endif()

    # Build HDF5_INCLUDE_DIRS
    set(HDF5_INCLUDE_DIRS ${HDF5_INCLUDE_DIR} ${extra_inc_dirs})
    list(REMOVE_DUPLICATES HDF5_INCLUDE_DIRS)

  endif(NOT HDF5_INCLUDE_DIRS)

  # Search for the libraries

  if ( NOT HDF5_LIBRARIES )

    # --- Search for the C library 
    find_library(_HDF5_C_LIBRARY
                 NAMES hdf5
                 HINTS ${_hdf5_LIBRARY_SEARCH_DIRS}
                 ${_hdf5_FIND_OPTIONS})

    # Since all other libraries need this core library, throw a
    # fatal error her if it is not found.
    if ( NOT _HDF5_C_LIBRARY )
      message(FATAL_ERROR "Could not locate the C HDF5 library")
    endif()

    # Define the target for the C library
    if (HDF5_SETTINGS_FILE)
      _HDF5_EXTRA_LIBRARIES(${HDF5_SETTINGS_FILE} HDF5_LINK_LIBRARIES)
    endif()  
    add_imported_library(${HDF5_C_TARGET}
                         LOCATION ${_HDF5_C_LIBRARY}
                         LINK_LANGUAGES "C"
                         LINK_INTERFACE_LIBRARIES "${HDF5_LINK_LIBRARIES}")
    set(HDF5_C_LIBRARY ${HDF5_C_TARGET})		       

    # --- Search for the other possible compnent libraries

    # Search for the C++ (CXX) library
    find_library(_HDF5_CXX_LIBRARY
                 NAMES hdf5_cpp
                 HINTS ${_hdf5_LIBRARY_SEARCH_DIRS}
                 ${_hdf5_FIND_OPTIONS})

    # Search for the Fortran library
    find_library(_HDF5_Fortran_LIBRARY
                 NAMES hdf5_fortran
                 HINTS ${_hdf5_LIBRARY_SEARCH_DIRS}
                 ${_hdf5_FIND_OPTIONS})
    
    # Search for the high-level (HL) library
    find_library(_HDF5_HL_LIBRARY
                 NAMES hdf5_hl
                 HINTS ${_hdf5_LIBRARY_SEARCH_DIRS}
                 ${_hdf5_FIND_OPTIONS})

    # Search for the Fortran high-level (HL) library
    find_library(_HDF5_Fortran_HL_LIBRARY
                 NAMES hdf5_hl_fortran hdf5hl_fortran
                 HINTS ${_hdf5_LIBRARY_SEARCH_DIRS}
                 ${_hdf5_FIND_OPTIONS})

    # --- Create the imported targets for each of the components found
    #     and update HDF5_LIBRARIES.

    # HL Library
    if ( _HDF5_HL_LIBRARY )
      add_imported_library(${HDF5_HL_TARGET}
                   LOCATION ${_HDF5_HL_LIBRARY}
                   LINK_LANGUAGES "C"
                   LINK_INTERFACE_LIBRARIES "${HDF5_C_TARGET}")
    endif() 
      
    # CXX Library
    if ( _HDF5_CXX_LIBRARY )
      add_imported_library(${HDF5_CXX_TARGET}
                   LOCATION ${_HDF5_CXX_LIBRARY}
                   LINK_LANGUAGES "CXX"
                   LINK_INTERFACE_LIBRARIES "${HDF5_C_TARGET}")
      set(HDF5_CXX_LIBRARY ${HDF5_CXX_TARGET})
    endif() 
      
    # Fortran Library
    if ( _HDF5_Fortran_LIBRARY )
      add_imported_library(${HDF5_Fortran_TARGET}
                   LOCATION ${_HDF5_Fortran_LIBRARY}
                   LINK_LANGUAGES "Fortran"
                   LINK_INTERFACE_LIBRARIES "${HDF5_C_TARGET}")
      set(HDF5_Fortran_LIBRARY ${HDF5_Fortran_TARGET})
    endif() 
      
    # Fortran HL Library
    if ( _HDF5_Fortran_HL_LIBRARY )
      add_imported_library(${HDF5_Fortran_HL_TARGET}
                   LOCATION ${_HDF5_Fortran_HL_LIBRARY}
                   LINK_LANGUAGES "Fortran"
                   LINK_INTERFACE_LIBRARIES "${HDF5_Fortran_TARGET}")
      set(HDF5_Fortran_LIBRARY ${HDF5_Fortran_HL_TARGET})
    endif()

    # Define the HDF5_<component>_LIBRARY to point to the target
    foreach ( _component ${HDF5_VALID_COMPONENTS} )
      if ( TARGET ${HDF5_${_component}_TARGET} )
	set(HDF5_${_component}_LIBRARY ${HDF5_${_component}_TARGET})
      endif()
    endforeach()

    # Define the HDF5_LIBRARIES variable
    set(HDF5_LIBRARIES
        ${HDF5_C_LIBRARY}
        ${HDF5_HL_LIBRARY}
	${HDF5_CXX_LIBRARY}
	${HDF5_Fortran_LIBRARY}
	${HDF5_Fortran_HL_LIBRARY})

    # Define the HDF5_C_LIBRARIES variable
    set(HDF5_C_LIBRARIES ${HDF5_C_LIBRARY} ${HDF5_HL_LIBRARY})


  endif(NOT HDF5_LIBRARIES)

endif()

# --- Define the version string from the settings file if not already set
if ( NOT HDF5_VERSION AND HDF5_SETTINGS_FILE )
  _HDF5_DEFINE_VERSION(${HDF5_SETTINGS_FILE} HDF5_VERSION)
endif()

# --- Define HDF5_IS_PARALLEL from the settings file if not already set
if ( NOT HDF5_IS_PARALLEL AND HDF5_SETTINGS_FILE )
  _HDF5_DEFINE_PARALLEL_BUILD(${HDF5_SETTINGS_FILE} HDF5_IS_PARALLEL)
endif()

# --- Search for HDF5 tools
set(_hdf5_TOOLS h52gif h5copy h5debug h5diff h5dump h5import h5jam h5ls h5mkgrp h5stat)
set(HDF5_TOOLS_FOUND)
foreach( tool ${_hdf5_TOOLS})
  string(TOUPPER "${tool}" tool_uc)
  set(_hdf5_VAR_NAME HDF5_${tool_uc}_BINARY)
  find_program(${_hdf5_VAR_NAME}
               ${tool}
               HINTS ${_hdf5_BINARY_SEARCH_DIRS}
               ${_hdf5_FIND_OPTIONS})
  if ("${_hdf5_VAR_NAME}")
    list(APPEND HDF5_TOOLS_FOUND ${tool})
  endif()
endforeach()



# --- Set the variables HDF5_<COMPONENT>_FOUND FLAGS
foreach ( _component ${HDF5_VALID_COMPONENTS} )
  if( HDF5_${_component}_LIBRARY )
    set(HDF5_${_component}_FOUND TRUE)
  else()
    set(HDF5_${_component}_FOUND FALSE)
  endif()
endforeach()  

# --- Provide a summary of what the module found
if ( NOT HDF5_FIND_QUIETLY )

  # Create a not found list

  message(STATUS "HDF5 Version: ${HDF5_VERSION}")
  #message(STATUS "\tHDF5_INCLUDE_DIRS      =${HDF5_INCLUDE_DIRS}")
  #message(STATUS "\tHDF5_LIBRARIES         =${HDF5_LIBRARIES}")
  #message(STATUS "\tHDF5_LINK_LIBRARIES    =${HDF5_LINK_LIBRARIES}")
  #message(STATUS "\tHDF5_IS_PARALLEL       =${HDF5_IS_PARALLEL}")
  message(STATUS "Found the following HDF5 component libraries")
  set(HDF5_COMPONENTS_NOTFOUND)
  foreach (_component ${HDF5_VALID_COMPONENTS} )
    if ( HDF5_${_component}_FOUND )
	#message(STATUS "\t  HDF5_${_component}_LIBRARY\t\t=${HDF5_${_component}_LIBRARY}")
	message(STATUS "\t${HDF5_${_component}_LIBRARY}")
    else()   
      list(APPEND HDF5_COMPONENTS_NOTFOUND ${_component})
    endif()
  endforeach()  
  if ( HDF5_COMPONENTS_NOTFOUND )
    message(STATUS "\tHDF5 Components not found: ${HDF5_COMPONENTS_NOTFOUND}")
  endif()  
  message(STATUS "\tHDF5_TOOLS_FOUND: ${HDF5_TOOLS_FOUND}")

endif()

find_package_handle_standard_args( HDF5 DEFAULT_MESSAGE
                                   HDF5_INCLUDE_DIRS
                                   HDF5_LIBRARIES
                                   HDF5_VERSION)
