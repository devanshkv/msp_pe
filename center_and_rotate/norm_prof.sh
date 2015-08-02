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
#/home/devansh/Desktop/backup/Dropbox/27_046/scripts/centprof_latest.sh -i $1 -b 0 -n 1 -c 0 -B 1 -C 3 -R 1
rm -rf head
cat $1 | grep  "#" >> head
cat $1 | grep -v "#" >> file
awk 'FNR==NR{max=($3+0>max)?$3:max;next} {print $1,$2,$3/max}' file file > gile
cat head gile > $1_cn
rm -rf head file gile
#./home/devansh/Pulsars/data/spread_plot "J*phs" 0.0 1.0
