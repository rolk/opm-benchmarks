#!/bin/bash
# This script file is used to generate input files used by upscale_relperm_benchmark. 
# Three files must be specified below:
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
# These files are combined into a C++ syntax file for declaring the data as strings. 
# The resulting file must be included in upscale_relperm_benchmark.

# Define files as variables
gridfile=benchmark75.grdecl
resultfile=benchmark75_upscaled_relperm_20points.txt
stonefile=stonefile_benchmark.txt
cfile=benchmark75_input_data.cpp

tmp1=temp_file1.txt
tmp2=temp_file2.txt
tmp3=temp_file3.txt

################################
# Eclipse file 
################################

# Insert quotes and newline character on every line, and insert ; on the last line. Store in $tmp1
sed -e 's/.*/"&\\n"/g' -e '$s/\\n"/";/' <$gridfile >$tmp1

# Insert declaration of string on first line
sed -i '1istring eclipseInput =' $tmp1

# Add extra line
echo "" >> $tmp1

################################
# Result file
################################

# Delete comments, insert quotes and newline character on every line, and insert ; on last line. Store in $tmp2
sed -e '/#.*/ d' -e 's/.*/"&\\n"/g' -e '$s/\\n"/";/' <$resultfile >$tmp2

# Insert declaration of string on first line
sed -i '1istring result_string =' $tmp2

# Add extra line
echo "" >> $tmp2

################################
# Stone file
################################

# Delete comments, insert quotes and newline character on every line, and insert ; on last line. Store in $tmp3
sed -e '/#.*/ d' -e 's/.*/"&\\n"/g' -e '$s/\\n"/";/' <$stonefile >$tmp3

# Insert declaration of string on first line
sed -i '1istring stone_string =' $tmp3

# Add extra line
echo "" >> $tmp3

################################
# Merge files
################################

echo "// Date: "$(date) > $cfile 
echo "// This file is created from createInputDataFiles.sh." >> $cfile
echo "// It contains input data and reference solution stored as strings." >> $cfile
echo "// To be included in upscale_relperm_benchmark." >> $cfile
echo "" >> $cfile
echo "using namespace std;" >> $cfile
echo "" >> $cfile

# Add file name variables as strings
echo "static char* ECLIPSEFILENAME = \""$gridfile"\";" >> $cfile
echo "static char* ROCKFILENAME = \""$stonefile"\";" >> $cfile
echo "static char* REFERENCEFILENAME = \""$resultfile"\";" >> $cfile
echo "" >> $cfile

cat $tmp1 $tmp2 $tmp3 >> $cfile

# Finally, remove temp files
rm $tmp1
rm $tmp2
rm $tmp3
