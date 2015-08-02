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
	echo $std
  echo "fitting for ${prof}"
	#cp /home/devansh/Dropbox/db_mean_0/Database/scripts/error_s.py .
	./gauss_fit.py data.sep $std
	#name=$(echo "${prof}" |  cut -d. -f1)
	#echo "${name}"
	#cat head.sep data > ${name}_off_mean_0.bestprof_phs
	rm -rf *.sep data #*.py
	echo "Done!"
done
