#!/bin/bash
#########################################################
#                                                       #
#                  Separation error	                #
#                Written by : Devansh Agarwal           #
#                devansh@iisertvm.ac.in                 #
#                                                       #
#########################################################

Usage ()
        {
        echo
        echo "                          Incorrect usage"
        echo "                          Useage : error_s.sh <mean.off>"
        echo "                          Adds details to header corrects for mean baseline=0"
        echo "                          Uses a python script error_s.py"
        echo "                          devansh@iisertvm.ac.in"
        }
if test $# -lt 1
        then
        Usage
        exit -1
fi
rm -rf *.sep

old="$IFS"
IFS='
'
for line in $(<${1})
do
	IFS="$old"
	prof=$(echo "${line}" | awk '{print $1}')
	cat ${prof} | grep "#" > head.sep
  std=$(cat head.sep | grep "std" | awk '{print $3}' | tail -n 1)
  cat ${prof} | grep -v "#" > data.sep
  echo "fitting for ${prof}"
  cp -np /home/devansh/Copy/git/msp_pe/gauss_fit/gauss_fit.py .
  ./gauss_fit.py data.sep $std
	name=$(echo "${prof}" |  cut -d_ -f1)
  freq=$(echo ${prof} | cut -d_  -f2)
  mv multipage.pdf ${name}_$freq.pdf
	rm -rf *.sep data #*.py
done
	echo "Done!"
