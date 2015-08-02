#!/bin/bash
#########################################################
#                                                       #
#                  Collaspe profile by a number	        #
#                Written by : Devansh Agarwal           #
#                devansh@iisertvm.ac.in                 #
#                                                       #
#########################################################

Usage ()
        {
        echo
        echo "                          Incorrect usage"
        echo "                          Useage : collapse.sh <no of bins>"
        echo "                          Uses a python script collapse.py"
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
for line in $(<$1)
do
	IFS="$old"	
	prof=$(echo "${line}" | awk '{print $1}')
	arguments=$(echo "${line}" | awk '{$1=""; print}')
	cat ${prof} | grep "#" > head.sep
  cat ${prof} | grep -v "#" > data.sep
	echo "Calculating error for ${prof}"
	cp /home/devansh/Copy/Pulsars/data/db_mean_0/Database/scripts/collapse.py .
	./collapse.py data.sep $arguments > data
	name=$(echo "${prof}" |  cut -d. -f1)
	echo "${name}"
	cat head.sep data > ${name}_smooth.bestprof_phs
	rm -rf *.sep data *.py
	echo "Done!"
done
