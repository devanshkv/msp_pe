#!/bin/bash
#########################################################
#                                                       #
#                  Running Average    	                #
#                Written by : Devansh Agarwal           #
#                devansh@iisertvm.ac.in                 #
#                                                       #
#########################################################

Usage ()
        {
        echo
        echo "                          Incorrect usage"
        echo "                          Useage : run_avg.sh <run.avg>"
        echo "                          Adds details to header corrects for mean baseline=0"
        echo "                          Uses a python script run_avg.py"
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
  cp -rp /home/devansh/Copy/Pulsars/data/db_smooth/Database/scripts/run_avg.py .
	./run_avg.py data.sep ${arguments}> data
	name=$(echo "${prof}" |  cut -d. -f1)
	echo "${name}"
	cat head.sep data > ${name}_run_smooth.bestprof_phs
	rm -rf *.sep data run_avg.py
	echo "Done!"
done
