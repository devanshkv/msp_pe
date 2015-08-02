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
	arguments=$(echo "${line}" | awk '{$1=""; print}')
	cat ${prof} | grep "#" > head.sep
        cat ${prof} | grep -v "#" > data.sep
	echo "Calculating error for ${prof}"
	cp /home/devansh/Desktop/backup/Dropbox/27_046/scripts/0_mean.py .
	./0_mean.py data.sep ${arguments}> data
	name=$(echo "${prof}" |  cut -d. -f1)
	echo "${name}"
	cat head.sep data > ${name}_off_mean_0.bestprof_phs
	rm -rf *.sep data *.py
	echo "Done!"
done
