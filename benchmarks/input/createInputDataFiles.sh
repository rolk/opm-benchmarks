#!/bin/bash
# This script file is used to generate input files used by upscale_relperm_benchmark. 
# Three files must be specified on the command line::
#   - An eclipse grid file
#   - A stone file 
#   - An output/result file from running upscale_relperm on a equal problem
#       This file will be used to verify the results computed in upscale_relperm_benchmark.
#       Assumptions in upscale_relperm_benchmark that must be taken into account when creating this file:
#         - only one stone file
#         - isotropic input data
#         - upscales only one phase
#       Remember that other options also must match (e.g., points, relPermCurve, jFunctionCurve, ...)
#
# If a fourth argument is given, this is used as the relative path to this
# directory from the compilation unit where these files are included.
#
# The output from this program is C++ syntax for a program declaring the data as
# string. This output can be piped into a file which must be included in
# upscale_relperm_benchmark.
#
# Example:
#   ./createInputDataFiles.sh bench20.grdecl stone.txt benchmark.txt input/ > bench20.cpp

# check for correct number of arguments
if [ $# -lt 3 -o $# -gt 4 ]; then
    echo Usage: $0 gridfile stonefile resultfile [reldir] 1>&2
    exit 1
fi

# names for each of the inputs that are specified
gridfile="$1"
stonefile="$2"
resultfile="$3"
reldir="$4"

# header which contains timestamp and description
cat <<EOF
// Date: $(date +"%F %T %Z")
// This file is created from createInputDataFiles.sh.
// It contains input data and reference solution stored as strings.
// To be included in upscale_relperm_benchmark.

EOF

# filenames embedded to recreate original files
cat <<EOF
static const char* ECLIPSEFILENAME = "$gridfile";
static const char* ROCKFILENAME = "$stonefile";
static const char* REFERENCEFILENAME = "$resultfile";

EOF

# macro to embed files; first include a file as a local
# label (plus a zero terminator, so it can be read as string),
# then a symbol which is a pointer to this label; align
# to 64 bits to satisfy various architectures
cat <<EOF
#define EXTERN_FILE(type,name,file) \\
  __asm__ (               \\
    ".global " #name "\n" \\
    ".data\n"             \\
    ".p2align 3\n"        \\
    "1:\n"                \\
    ".incbin " #file "\n" \\
    ".byte 0, 0\n"        \\
    ".p2align 3\n"        \\
    #name ":\n"           \\
    ".int 1b\n"           \\
    );                    \\
  extern type *name

EOF

# embed the files we need (this is not done when running the
# script but rather when compiling the resulting output!)
cat <<EOF
EXTERN_FILE(const char,eclipseInput,"$reldir$gridfile");
EXTERN_FILE(const char,stone_string,"$reldir$stonefile");
EXTERN_FILE(const char,result_string,"$reldir$resultfile");
EOF
