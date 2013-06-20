# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t; compile-command: "cmake -Wdev" -*-
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

# key information about the program
set (project "opm-benchmarks")
set (${project}_NAME "${project}")
set (${project}_DESCRIPTION "Open Porous Media Initiative Benchmarks")
set (${project}_DIR "benchmarks")
set (${project}_VERSION_MAJOR 1)
set (${project}_VERSION_MINOR 0)

# defines that must be present in config.h for our headers
set (${project}_CONFIG_VAR
	HAVE_MPI
	OPM_BENCHMARKS_VERSION_STRING
	)

# dependencies
set (${project}_DEPS
	# compile with C99 support if available
	"C99"
	# compile with C++0x/11 support if available
	"CXX11Features"
	# OPM dependency
	"opm-core"
	"opm-upscaling"
	)

# C++ project
cmake_minimum_required (VERSION 2.8)
project (${${project}_NAME})
enable_language (CXX)

# additional search modules
set (${project}_MODULE_DIR "${PROJECT_SOURCE_DIR}/cmake/Modules")
list (APPEND CMAKE_MODULE_PATH ${${project}_MODULE_DIR})

# include special
if (CMAKE_VERSION VERSION_LESS "2.8.3")
	message (STATUS "Enabling compatibility modules for CMake 2.8.3")
	list (APPEND CMAKE_MODULE_PATH "${${project}_MODULE_DIR}/compat-2.8.3")
endif (CMAKE_VERSION VERSION_LESS "2.8.3")

if (CMAKE_VERSION VERSION_LESS "2.8.5")
	message (STATUS "Enabling compatibility modules for CMake 2.8.5")
	list (APPEND CMAKE_MODULE_PATH "${${project}_MODULE_DIR}/compat-2.8.5")	
endif (CMAKE_VERSION VERSION_LESS "2.8.5")	

if (CMAKE_VERSION VERSION_LESS "2.8.7")
	message (STATUS "Enabling compatibility modules for CMake 2.8.7")
	list (APPEND CMAKE_MODULE_PATH "${${project}_MODULE_DIR}/compat-2.8.7")
endif (CMAKE_VERSION VERSION_LESS "2.8.7")

# print system information to better pinpoint issues from log alone
include (UseSystemInfo)
system_info ()

# very early try to print repo id (to pinpoint version if something goes wrong)
include (UseVCSInfo)
vcs_info ()
vcs_verstr (${project})

# print toolchain information to identify compilers with potential bugs
include (UseCompVer)
compiler_info ()

# default settings: build static debug library
include (OpmDefaults)
opm_defaults (${project})
message (STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# use tricks to do faster builds
include (UseFastBuilds)

# precompiled headers
include (UsePrecompHeaders)

# optimize full if we're not doing a debug build
include (UseOptimization)

# turn on all warnings; this must be done before adding any
# dependencies, in case they alter the list of warnings
include (UseWarnings)

# parallel computing must be explicitly enabled
option (USE_MPI "Use Message Passing Interface for parallel computing" OFF)
if (NOT USE_MPI)
	set (CMAKE_DISABLE_FIND_PACKAGE_MPI TRUE)
endif (NOT USE_MPI)

# macro to set standard variables (INCLUDE_DIRS, LIBRARIES etc.)
include (OpmFind)
find_and_append_package_list_to (${project} ${${project}_DEPS})

# remove the dependency on the testing framework from the main library;
# it is not possible to query for Boost twice with different components.
list (REMOVE_ITEM ${project}_LIBRARIES "${Boost_UNIT_TEST_FRAMEWORK_LIBRARY}")

# don't import more libraries than we need to
include (UseOnlyNeeded)

# put debug information into every executable
include (UseDebugSymbols)

# detect if Boost is in a shared library
include (UseDynamicBoost)

# needed for Debian installation scheme
include (UseMultiArch)

# this module contains code to figure out which files is where
include (OpmFiles)
opm_auto_dirs ()

# put libraries in lib/
opm_out_dirs ()

# identify the compilation units in the library; sources in opm/,
# tests files in tests/, examples in tutorials/ and examples/
opm_sources (${project})

# create configuration header which describes available features
# necessary to compile this library. singular version is the names that
# is required by this project alone, plural version transitively
# includes the necessary defines by the dependencies
include (ConfigVars)
list (APPEND ${project}_CONFIG_VARS ${${project}_CONFIG_VAR})

# write configuration variables to this file. note that it is a temporary.
message (STATUS "Writing config file \"${PROJECT_BINARY_DIR}/config.h\"...")
set (CONFIG_H "${PROJECT_BINARY_DIR}/config.h.tmp")
configure_vars (
	FILE  CXX  ${CONFIG_H}
	WRITE ${${project}_CONFIG_VARS}
	)

# overwrite the config.h that is used by the code only if we have some
# real changes. thus, we don't have to recompile if a reconfigure is run
# due to some files being added, for instance
execute_process (COMMAND
	${CMAKE_COMMAND} -E copy_if_different ${CONFIG_H} ${PROJECT_BINARY_DIR}/config.h
	)

### --- begin opm-benchmarks specific --- ###
# some CMake properties do not do list expansion
string (REPLACE ";" " " ${project}_LINKER_FLAGS_STR "${${project}_LINKER_FLAGS}")

# all public header files are together with the source. prepend our own
# source path to the one of the dependencies so that our version of any
# ambigious paths are used.
set (${project}_INCLUDE_DIR "${PROJECT_SOURCE_DIR}")
set (${project}_INCLUDE_DIRS ${${project}_INCLUDE_DIR} ${${project}_INCLUDE_DIRS})

# setup compile command-line
include_directories (${${project}_INCLUDE_DIRS})
link_directories (${${project}_LIBRARY_DIRS})
add_definitions (${${project}_DEFINITIONS})

# targets
set (${project}_TARGET upscale_relperm_benchmark)
add_executable (${${project}_TARGET} ${${project}_SOURCES})

# add libraries
target_link_libraries (${${project}_TARGET} ${${project}_LIBRARIES})

# queue this executable to be stripped
strip_debug_symbols (${${project}_TARGET} ${project}_DEBUG)

# pre-compile common headers; this is setup *after* the library to pick
# up extra options set there
if (PRECOMPILE_HEADERS)
	get_target_property (_type ${${project}_TARGET} TYPE)
	precompile_header (CXX ${_type}
	  HEADER "${${project}_PRECOMP_CXX_HEADER}"
	  TARGET ${project}_CXX_pch
	  FLAGS  ${project}_PRECOMP_CXX_FLAGS
	  )
	# must set property on source files instead of entire target, because
	# it only applies to C++ modules (and cannot be used for C)
	set_source_files_properties (${${project}_CXX_SOURCES} PROPERTIES
	  OBJECT_DEPENDS "${${project}_CXX_pch}"
	  COMPILE_FLAGS  "${${project}_PRECOMP_CXX_FLAGS}"
	  )
	message (STATUS "Precompiled headers: ${${project}_CXX_pch}")
endif (PRECOMPILE_HEADERS)
### --- end opm-benchmarks specific --- ###

# TODO: Unit testing

# TODO: Installation of binary

### clean in-source builds ###
include (OpmDistClean)
opm_dist_clean (${project})

### emulate the with-xxx feature of autotools;
include (OpmKnown)
