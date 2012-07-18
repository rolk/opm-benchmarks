# $Date$
# $Revision$

check_PROGRAMS = 
noinst_PROGRAMS = upscale_relperm_benchmark

upscale_relperm_benchmark_SOURCES = upscale_relperm_benchmark.cpp

AM_CPPFLAGS += $(DUNEMPICPPFLAGS) $(BOOST_CPPFLAGS) $(SUPERLU_CPPFLAGS)
AM_LDFLAGS  += $(DUNEMPILDFLAGS) $(BOOST_LDFLAGS) $(SUPERLU_LDFLAGS)
LDADD = $(DUNEMPILIBS) $(BOOST_UNIT_TEST_FRAMEWORK_LIB) \
        $(BOOST_FILESYSTEM_LIB) $(BOOST_SYSTEM_LIB)   \
        $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS) $(SUPERLU_LIBS)


TESTS = $(check_PROGRAMS)

include $(top_srcdir)/am/global-rules