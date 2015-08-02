#!/bin/bash
Usage ()
        {
        echo "			rot_prof"
	echo "	rotates profile with given number towards left"
        echo "Incorrect usage : Found Less arguments."
        echo "Useage :	rot_prof  <file> <number>"
        echo "Note :	It is assumed that the data is the 3rd column"
        echo "		Centprof_latest is needed"
        }
if test $# -lt 1
        then
        Usage
        exit -1
fi
/home/devansh/Desktop/backup/Dropbox/27_046/scripts/centprof_latest.sh -i $1 -b 0 -n 0 -c 1 -B 1 -C 3 -R 1
rm -rf head
cat $1_cn | grep  "#" >> head
cat $1_cn | grep -v "#" |  awk '{printf"%.8f\t%.8f\t%.8f\n",$1,$2,$4}' >> head
mv head $1_cn
rm -rf head
#./home/devansh/Pulsars/data/spread_plot "J*phs" 0.0 1.0
