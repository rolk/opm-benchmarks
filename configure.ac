# -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
AC_PREREQ(2.50)
DUNE_AC_INIT # gets module version from dune.module file
AM_INIT_AUTOMAKE

# Use "silent" rules by default if available in the Automake being used to
# process this setup. See, e.g.,
#
# http://www.flameeyes.eu/autotools-mythbuster/automake/silent.html
#
# for details, particularly concerning the backwards compatibility.
#
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_CONFIG_SRCDIR([benchmarks/upscale_relperm_benchmark.cpp])
AM_CONFIG_HEADER([config.h])


# we need no more than the standard DE-stuff
# this module depends on dune-common dune-grid dune-istl dune-cornerpoint opm-porsol opm-upscaling
# this implies checking for [dune-common], [dune-geometry], [dune-grid], [dune-istl], [opm-core], [dune-cornerpoint], [opm-porsol], [opm-upscaling]
DUNE_CHECK_ALL

# implicitly set the Dune-flags everywhere
AC_SUBST(AM_CPPFLAGS, $DUNE_CPPFLAGS)
AC_SUBST(AM_LDFLAGS, $DUNE_LDFLAGS)
LIBS="$DUNE_LIBS"

AC_CONFIG_FILES([
  Makefile
  benchmarks/Makefile
  doc/Makefile
  doc/doxygen/Makefile
  doc/doxygen/Doxyfile
  opm/Makefile
  opm/benchmarks/Makefile
  m4/Makefile
  opm-benchmarks.pc
])
AC_OUTPUT
# finally print the summary information
DUNE_SUMMARY_ALL
