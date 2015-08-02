#!/bin/bash

# This script
	# substracts baseline from the profile(s)		(if asked to do so) (-b 1).
	# normalizes the profile(s)				(if asked to do so) (-n 1).
	# rotates the profile(s) to bring them to central bin	(if asked to do so) (-c 1).
	# rotates the profile(s) leftwards by a certain +-bins	(if asked to do so) (-l +-n).
	# rotates the profile(s) to a certain bin no		(if asked to do so) (-p n).
	# Accepts input file(s) such that In case of -i, files may or may not have any header, while In case of -I, all files must have *bestprof type header.
	# In case of -I, It also gives an estimate of the single pulse snr of the profile.

	# Assumes Bin info to be in 1st column unless specified otherwise (-B n).
	# Assumes Profile info to be in 2nd column unless specified otherwise (-C n).
	# Expects onpulse windows (1 at least and 3 atmost) and offpulse windows (2 at least and 3 atmost) to calculate baseline and SNRs. All of these bin counts are assumed to be 0-based.
		# The windows are to be specified based on the centered profile for which you can run the first iteration as below : 
		# centprof -i < A good snr filename (In case of -i, files may or may not have any header) >
		# centprof -I < A good snr bestprof_filename (In case of -I, all files must have *bestprof type header) >

	# Produces output file(s) for each input file(s), by suffixing _cn or user specified extension_name to input file names, such that they have
		# either two columns (-R 0)
			# 1st column having the Bin info
				# same as original
				# Or converted to phase (if asked to do so). 
					# such that bins are mapped to left edge of phase bins (-P 1)
					# Or such that bins are mapped to center of phase bins (-P 2)
			# 2nd column having the original or rotated and/or baseline subtracted and/or normalized output.
		# or n+1 columns with first n being the original columns (-R 1)
			# n+1 column having the original or rotated and/or baseline subtracted and/or normalized output.
		# or n+2 columns with first n being the original columns (-R 1 -P 1/2)
			# n+1 column having the Bin info converted to phase.
			# n+2 column having the original or rotated and/or baseline subtracted and/or normalized output.

Usage ()
	{
	echo
	echo "Incorrect usage: Found Less arguments."
	echo "USAGE : centprof	-i   <\"filename(s)\">          : In case of -i, files may or may not have any header. At a time only -i or -I should be used. "
	echo "			-I   <\"bestprof_filename(s)\"> : In case of -I, all files must have *bestprof type header. At a time only -i or -I should be used."
	echo "			-b   <subs_baseline_flag>     :  1  (yes; def) / 0 (no)"
	echo "			-n   <normalize_flag>         :  1  (yes; def) / 0 (no)"
	echo "			-c   <center_flag>            :  1  (yes; def) / 0 (no)"
	echo "			-l   <left_rot>               :  0  (def)      / +-(no of bins)"
	echo "			-p   <move_peak_to>           : -1  (don't move; def) / (0-based +ve bin no; c & l ignored)"
	echo "			-h   <Add new_header>         :  1  (yes; def) / 0 (no)"
	echo "			-H   <Retain old_header>      :  1  (yes; def) / 0 (no)"
	echo "			-o   <overwrite_files>        :  1  (yes; def) / 0 (no)"
	echo "			-P   <bin2phs>                :  0  (no ; def) / 1 (yes; bin-left) / 2 (yes; bin-cntr)"
	echo "			-B   <bin_info_column>        :  1  (def)      / (1-based +ve column no)"
	echo "			-C   <prof_info_column>       :  2  (def)      / (1-based +ve column no)"
	echo "			-R   <retain_orig_columns>    :  0  (no ; def) / 1 (yes)"
	echo "			-e   <extension_name>         : _cn (def)"
	echo "			-OFF <off_start1> <off_stop1> ... at least 2 pairs and upto 3 allowed : All of these bin counts are assumed to be 0-based."
	echo "			-ON  <on_start1 > <on_stop1 > ... at least 1 pair  and upto 3 allowed : All of these bin counts are assumed to be 0-based."
	echo
	echo "Exmpl : centprof -i \"*325*dat\"      -b 1 -n 1 -c 1 -l 3 -P 2 -R 1 -e _bcn_phs -OFF 2 10 43 50 -ON 15 30 "
	echo "        centprof -I \"*325*bestprof\" -b 1 -n 1 -c 1 -l 3 -P 2 -R 1 -e _bcn_phs -OFF 2 10 43 50 -ON 15 30 "
	echo
	echo "V-IMP : The windows are to be specified based on the centered profile for which you can run the first iteration as below : "
	echo "        centprof -i < A good snr filename (In case of -i, files may or may not have any header)>"
	echo "        centprof -I < A good snr bestprof_filename (In case of -I, all files must have *bestprof type header)>"
	echo 
	#echo "Developement Area : ujjwal@kanya.ncra.tifr.res.in:/misc/nasdata1/astro/pulsar/users/ujjwal/My_Codes/Shell_scripts/Cent_Prof/"  
	echo
	echo
}

error_flag=0
# Arguments check (assumes minimum possible args)
if test $# -lt 1
	then
	Usage
	exit -1
fi

# Set default/initial values
file_passed=0
subs_baseline_flag=1
normalize_flag=1
center_flag=1
left_rot=0
move_peak_to=-1
new_header=1
old_header=1
overwrite_files=1
overwrite_flag=0
bin2phs=0
bin_info_column=1
prof_info_column=2
retain_orig_columns=0
extension_name="_cn"
window_info_passed=0

# Get commandline inputs
narg=${#}
readarg=0

while [[ "$readarg" -lt "$narg" ]]
	do
	case "$1" in
	-i) filenames=${2};file_passed=1;readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-I) filenames=${2};file_passed=2;readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-b) subs_baseline_flag=$( echo ${2} | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l );shift;shift;;
	-n) normalize_flag=$( echo ${2} | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l );shift;shift;;
	-c) center_flag=$( echo ${2} | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-l) left_rot=$( echo ${2} | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-p) move_peak_to=$(echo " (${2}) " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-h) new_header=$(echo " (${2}) " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-H) old_header=$(echo " (${2}) " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-o) overwrite_files=$(echo " (${2}) " | bc | awk '{printf"%d",$1}' );overwrite_flag=1;readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-P) bin2phs=$(echo " (${2}) " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-B) bin_info_column=$(echo " (${2}) " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-C) prof_info_column=$(echo " (${2}) " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-R) retain_orig_columns=$(echo " (${2}) " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-e) extension_name=${2};readarg=$(echo "$readarg + 2"| bc -l);shift;shift;;
	-OFF) window_info_passed=$(echo " (${window_info_passed}) + 1 " | bc | awk '{printf"%d",$1}' )
		off_start1=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift
		 off_stop1=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift
		off_start2=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift
		 off_stop2=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift
		if [[ ! -z  ${2} ]] && [[ ${2} != "-i" && ${2} != "-I" && ${2} != "-b" && ${2} != "-n" && ${2} != "-c" && ${2} != "-l" && ${2} != "-p" && ${2} != "-h" && ${2} != "-H" && ${2} != "-o" && ${2} != "-P" && ${2} != "-B" && ${2} != "-C" && ${2} != "-R" && ${2} != "-e" && ${2} != "-OFF" && ${2} != "-ON" ]]
			then
			off_start3=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift
			 off_stop3=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift;shift
		else
			shift
		fi
		;;
	-ON) window_info_passed=$(echo " (${window_info_passed}) + 1 " | bc | awk '{printf"%d",$1}' )
		on_start1=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 2"| bc -l);shift
		 on_stop1=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift
		if [[ ! -z  ${2} ]] && [[ ${2} != "-i" && ${2} != "-I" && ${2} != "-b" && ${2} != "-n" && ${2} != "-c" && ${2} != "-l" && ${2} != "-p" && ${2} != "-h" && ${2} != "-H" && ${2} != "-o" && ${2} != "-P" && ${2} != "-B" && ${2} != "-C" && ${2} != "-R" && ${2} != "-e" && ${2} != "-OFF" && ${2} != "-ON" ]]
			then
			on_start2=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift
			 on_stop2=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift
			if [[ ! -z  ${2} ]] && [[ ${2} != "-i" && ${2} != "-I" && ${2} != "-b" && ${2} != "-n" && ${2} != "-c" && ${2} != "-l" && ${2} != "-p" && ${2} != "-h" && ${2} != "-H" && ${2} != "-o" && ${2} != "-P" && ${2} != "-B" && ${2} != "-C" && ${2} != "-R" && ${2} != "-e" && ${2} != "-OFF" && ${2} != "-ON" ]]
				then
				on_start3=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift
				 on_stop3=$(echo " (${2}) + 1 " | bc | awk '{printf"%d",$1}' );readarg=$(echo "$readarg + 1"| bc -l);shift;shift
			else
				shift
			fi
		else
			shift
		fi
		;;
	*) echo
	   echo "ERROR !! Incorrect argument string"
	   error_flag=1;readarg=$(echo "$readarg + 1"| bc -l);shift
	   ;;

	esac
done

if [[ "$move_peak_to" -ne -1 ]]
	then
	move_peak_to=$(echo " (${move_peak_to}) + 1 " | bc | awk '{printf"%d",$1}' )
fi

# ARGUMENT SANITY CHECKS :

	# Filename passed check
	if [[ "$file_passed" -eq 0 ]]
		then
		echo
		echo "ERROR !! filename argument missing."
		error_flag=1
	fi
	
	# subs_baseline_flag value check
	if [[ "${subs_baseline_flag}" -ne 0 && "${subs_baseline_flag}" -ne 1 ]]
		then
		echo
		echo "ERROR !! subs_baseline_flag should have a value of 0 or 1. Will quit."
		error_flag=1
	fi
	
	# normalize_flag value check
	if [[ "${normalize_flag}" -ne 0 && "${normalize_flag}" -ne 1 ]]
		then
		echo
		echo "ERROR !! normalize_flag should have a value of 0 or 1. Will quit."
		error_flag=1
	fi
	
	# center_flag value check
	if [[ "${center_flag}" -ne 0 && "${center_flag}" -ne 1 ]]
		then
		echo
		echo "ERROR !! center_flag should have a value of 0 or 1. Will quit."
		error_flag=1
	fi
	
	# new_header value check
	if [[ "${new_header}" -ne 0 && "${new_header}" -ne 1 ]]
		then
		echo
		echo "ERROR !! new_header should have a value of 0 or 1. Will quit."
		error_flag=1
	fi
	
	# old_header value check
	if [[ "${old_header}" -ne 0 && "${old_header}" -ne 1 ]]
		then
		echo
		echo "ERROR !! old_header should have a value of 0 or 1. Will quit."
		error_flag=1
	fi
	
	# overwrite_files value check
	if [[ "${overwrite_files}" -ne 0 && "${overwrite_files}" -ne 1 ]]
		then
		echo
		echo "ERROR !! overwrite_files should have a value of 0 or 1. Will quit."
		error_flag=1
	fi
	
	# bin2phs value check
	if [[ "${bin2phs}" -ne 0 && "${bin2phs}" -ne 1 && "${bin2phs}" -ne 2  ]]
		then
		echo
		echo "ERROR !! bin2phs should have a value of 0,1 or 2. Will quit."
		error_flag=1
	fi
	
	# retain_orig_columns value check
	if [[ "${retain_orig_columns}" -ne 0 && "${retain_orig_columns}" -ne 1 ]]
		then
		echo
		echo "ERROR !! retain_orig_columns should have a value of 0 or 1. Will quit."
		error_flag=1
	fi
	
	# Window info passed check
	if [[ "$window_info_passed" -eq 1 ]]
		then
		echo
		echo "ERROR !! Only OFF or ON windows were passed."
		error_flag=1
	fi
	
	# Quit if any basic error encountered
	if [[ "$error_flag" -eq 1 ]]
		then
		echo
		Usage
		exit -1;
	fi

# Overwrite alert
if [[ "$overwrite_files" -eq 1 && "$overwrite_flag" -eq 0 ]]
	then
	echo
	if [[ ! -z $( ls -1 ${filenames}${extension_name} 2> /dev/null ) ]]
	then
		echo "Overwrite permission : One or more of file(s) ${filenames}${extension_name} exists and will get overwritten !! Enter 'yes' to proceed:"
		read VAR
		if [[ "$VAR" != "yes" ]]
			then
			exit -1;
		fi
	fi
fi

# Work loop begins

rm -rf junk_filelist
ls -1 ${filenames} > junk_filelist 2> /dev/null

processed_file=0

echo
echo "The no of columns in each of the input files (as will get listed below) should ideally be same. The no of columns in each of the output files should be same. "
echo
for file in $(cat junk_filelist)
	do
	echo "	DOING $file"

	# STEP 0 : Basic checks.
	
	# Checking the existance of file
	if [[ ! -s ${file} ]]
		then
		echo "		ERROR !! ${file} does not exists or is empty. Will skip this one."
		echo
		continue
	fi

	# Generating the output file name
	out_file=$(echo ${file}${extension_name})

	# File suitability check (In case of -I, all files must have *bestprof type header).
	if [[ "${file_passed}" -eq 2 ]]
		then
		if [[ -z `grep "T_sample" ${file} | awk '{print $1}' ` ]] || [[ -z `grep "Data Folded" ${file} | awk '{print $1}' ` ]] || [[ -z `grep "P_topo (ms)" ${file} | awk '{print $1}' ` ]]
			then
			echo "		ERROR !! ${file} not of suitable format (In case of -I, all files must have *bestprof type header). Will skip this one."
			echo
			continue
		fi
	fi

	# STEP 1 : Get basic info from input file and a few further checks.

	        MAX=$(cat ${file}  | grep -v "#" | awk "{Line=Line+1; printf\"%15.8f\t%d\n\",$`echo ${prof_info_column}`,Line}" | sort -n | tail -n 1 | awk '{print $1}')
	        MIN=$(cat ${file}  | grep -v "#" | awk "{Line=Line+1; printf\"%15.8f\t%d\n\",$`echo ${prof_info_column}`,Line}" | sort -n | head -n 1 | awk '{print $1}')
	     MAXBIN=$(cat ${file}  | grep -v "#" | awk "{Line=Line+1; printf\"%15.8f\t%d\n\",$`echo ${prof_info_column}`,Line}" | sort -n | tail -n 1 | awk '{print $2-1}')
	     TOTBIN=$(cat ${file}  | grep -v "#" | wc -l)
	 neg_TOTBIN=$(echo "-1*($TOTBIN)" | bc -l | awk '{printf"%d",$1}' )
	       NCOL=$(cat ${file}  | grep -v "#" | awk "{print NF}" | head -n 1 )
	     MIDBIN=$(echo " ($TOTBIN+1)/2 -1" | bc)
	  LFTSFTBIN=$(echo " ($MAXBIN) - ($MIDBIN)" | bc)
	LFTSFTBIN_1=$(echo " ($LFTSFTBIN) + 1" | bc)
	  RGTSFTBIN=$(echo " -1*($LFTSFTBIN)" | bc)
	    MAX_INT=$(echo " 1000000*($MAX)/1.0 " | bc)
	    MIN_INT=$(echo " 1000000*($MIN)/1.0 " | bc)
	if [[ "${file_passed}" -eq 2 ]]
		then
	   T_sample=$(cat ${file} | grep "T_sample" | awk '{printf"%.8f\n",$4*1000000}')
	   Data_pts=$(cat ${file} | grep "Data Folded"   | awk '{printf"%d\n",$5}')
	   Period_t=$(cat ${file} | grep "P_topo (ms)"   | awk '{printf"%.14f\n",$5*1000}')
	    N_pulse=$(echo " ($Data_pts) * ($T_sample) / ($Period_t) " | bc -l | awk '{printf"%d\n",$1}')
	fi

	# left_rot value check 
	if [[ "$left_rot" -ge "$TOTBIN" || "$left_rot" -le "$neg_TOTBIN" ]]
		then
		echo "		ERROR !! Leftwards rotation can not be out of range -$TOTBIN to $TOTBIN. Will skip this one."
		echo
		continue
	fi

	# move_peak_to value check 
	if [[ "$move_peak_to" -ne -1 ]]
		then
		if [[ "$move_peak_to" -gt "$TOTBIN" || "$move_peak_to" -lt 1 ]]
			then
			echo "		ERROR !! Peak can not be moved to a bin out of range 1 to TOTBIN $TOTBIN. Will skip this one."
			echo
			continue
		fi
	fi

	# bin_info_column value check 
	if [[ "$bin_info_column" -gt "$NCOL" || "$bin_info_column" -lt 1 || "$bin_info_column" -eq "$prof_info_column" ]]
		then
		echo "		ERROR !! bin_info_column either same as prof_info_column or out of range of 1 to ${NCOL} (No of columns in input file ${file}). Will skip this one."
		echo
		continue
	fi

	# prof_info_column value check 
	if [[ "$prof_info_column" -gt "$NCOL" || "$prof_info_column" -lt 1 || "$prof_info_column" -eq "$bin_info_column" ]]
		then
		echo "		ERROR !! prof_info_column either same as prof_info_column or out of range of 1 to ${NCOL} (No of columns in input file ${file}). Will skip this one."
		echo
		continue
	fi

	# Clears old files from prev run
	if [[ "$overwrite_files" -eq 0 && -s ${out_file} ]]
		then
		echo "		ERROR !! ${out_file} exists & overwriting has been prohibited. Will skip this one."
		echo
		continue
	else
		rm -rf ${out_file}
	fi


	# STEP 2 : Create a intermediate centered profile by bring the peak to the centre to facilitate computing window based quantities.

	rm -rf junk_top junk_bot junk_first_iter junk_off junk_on
	
	if [[ "$LFTSFTBIN" -gt 0 ]]
		then
		cat ${file} | grep -v "#"  | tail -n +"$LFTSFTBIN_1" | awk "{printf \"%.8f\n\",$`echo ${prof_info_column}`}" > junk_top
		cat ${file} | grep -v "#"  | head -n  "$LFTSFTBIN"   | awk "{printf \"%.8f\n\",$`echo ${prof_info_column}`}" > junk_bot
		cat junk_top junk_bot > junk_first_iter
	fi
	if [[ "$LFTSFTBIN" -lt 0 ]]
		then
		cat ${file} | grep -v "#"  | tail -n  "$RGTSFTBIN" | awk "{printf \"%.8f\n\",$`echo ${prof_info_column}`}" > junk_top
		cat ${file} | grep -v "#"  | head -n -"$RGTSFTBIN" | awk "{printf \"%.8f\n\",$`echo ${prof_info_column}`}" > junk_bot
		cat junk_top junk_bot > junk_first_iter
	fi
	if [[ "$LFTSFTBIN" -eq 0 ]]
		then
		cat ${file} | grep -v "#"  | awk "{printf \"%.8f\n\",$`echo ${prof_info_column}`}" > junk_top
		cat junk_top > junk_first_iter
	fi

	rm -rf junk_top junk_bot
	
	# STEP 3 : Computing window based quantities.
 
	if [[ "$window_info_passed" -eq 2 ]]
		then

		# OFF

		off_bin1=$(echo " ($off_stop1) - ($off_start1) + 1" | bc)
		off_bin2=$(echo " ($off_stop2) - ($off_start2) + 1" | bc)
		 off_bin=$(echo " ($off_bin1) + ($off_bin2)" | bc)
		
		cat junk_first_iter | head -n "$off_stop1" | tail -n "$off_bin1" | awk '{print $1}' >  junk_off
		cat junk_first_iter | head -n "$off_stop2" | tail -n "$off_bin2" | awk '{print $1}' >> junk_off
		
		if [ ! -z  $off_start3 ]
			then
			off_bin3=$(echo " ($off_stop3) - ($off_start3) + 1" | bc)
			off_bin=$(echo " ($off_bin) + ($off_bin3)" | bc)
		
			cat junk_first_iter | head -n "$off_stop3" | tail -n "$off_bin3" | awk '{print $1}' >> junk_off
		fi
		
		off_aggr=$(cat junk_off | awk '{off_sum = off_sum + $1 ; printf"%.8f\n",off_sum}' | tail -n 1 )
		off_mean=$(echo "($off_aggr)/($off_bin)" | bc -l | awk '{printf"%.8f\n",$1}')
		
		off_min=$(cat junk_off | sort -n | head -n 1 )
		off_max=$(cat junk_off | sort -n | tail -n 1 )

		# off_rms
		sum=0
		for off_val in `cat junk_off`
			do
			sum=$( echo "($sum) + (($off_val)-($off_mean))*(($off_val)-($off_mean))/($off_bin)" | bc -l )
		done
		off_rms=$( echo "sqrt($sum)" | bc -l | awk '{printf"%.6f",$1}' )


		# ON

		on_bin1=$(echo " ($on_stop1) - ($on_start1) + 1" | bc)
		on_bin=$on_bin1
		
		cat junk_first_iter | head -n "$on_stop1" | tail -n "$on_bin1" | awk '{print $1}' >  junk_on
		
		if [ ! -z  $on_start2 ]
			then
			on_bin2=$(echo " ($on_stop2) - ($on_start2) + 1" | bc)
			on_bin=$(echo " ($on_bin) + ($on_bin2)" | bc)
			
			cat junk_first_iter | head -n "$on_stop2" | tail -n "$on_bin2" | awk '{print $1}' >> junk_on
		fi
		
		if [ ! -z  $on_start3 ]
			then
			on_bin3=$(echo " ($on_stop3) - ($on_start3) + 1" | bc)
			on_bin=$(echo " ($on_bin) + ($on_bin3)" | bc)
			
			cat junk_first_iter | head -n "$on_stop3" | tail -n "$on_bin3" | awk '{print $1}' >> junk_on
		fi
		
		on_aggr=$(cat junk_on | awk '{on_sum = on_sum + $1 ; printf"%.8f\n",on_sum}' | tail -n 1 )
		on_aupl=$(echo "($on_aggr) - (($on_bin)*($off_mean))" | bc -l | awk '{printf"%.8f\n",$1}')
		on_mean=$(echo "($on_aggr)/($on_bin)" | bc -l )
		
		on_min=$(cat junk_on | sort -n | head -n 1 )
		on_max=$(cat junk_on | sort -n | tail -n 1 )
		

		# SNR 
		peak_snr=$(echo " (($on_max)-($off_mean))/($off_rms)" | bc -l | awk '{printf"%.8f\n",$1}')
		int_snr=$(echo " ($on_aupl)/(sqrt($on_bin)*($off_rms))"  | bc -l | awk '{printf"%.8f\n",$1}')
			#Int_SNR = AUP/(sqrt(W)*sigma_offpulse)

		if [[ "${file_passed}" -eq 2 ]]
			then
			single_pulse_snr=$(echo "($int_snr)/(sqrt($N_pulse))" | bc -l | awk '{printf"%.8f\n",$1}')
		fi

		baseline=${off_mean}
		norm_fac=$( echo "((${on_max})-(${off_mean}))" | bc -l | awk '{printf"%15.8f\n",$1}' )
	else
		baseline=${MIN}
		norm_fac=$( echo "((${MAX})-(${MIN}))" | bc -l | awk '{printf"%15.8f\n",$1}' )
	
	fi

	# STEP 4: Computing post rotation and baseline and norm_fac based on b,n,c,l,p arguments: 
		  # set values of vars such as rot required to centered prof, norm_fac, baseline based on the value of flags and then apply those to get the final prof.

	LFTSFTBIN_post=0
	LFTSFTBIN_post_1=0
	RGTSFTBIN_post=0
	if [[ "$move_peak_to" -ne -1 ]]
		then
		LFTSFTBIN_post=$(echo " ($MIDBIN) - ($move_peak_to)" | bc)
		LFTSFTBIN_post_1=$(echo " ($LFTSFTBIN_post) +1" | bc)
		RGTSFTBIN_post=$(echo " -1*($LFTSFTBIN_post)" | bc)
	else
		if [[ "$center_flag" -eq 0 ]]
			then
			LFTSFTBIN_post=$(echo " ($MIDBIN) - ($MAXBIN)" | bc)
			LFTSFTBIN_post_1=$(echo " ($LFTSFTBIN_post) +1" | bc)
			RGTSFTBIN_post=$(echo " -1*($LFTSFTBIN_post)" | bc)
		fi
		if [[ "$left_rot" -ne 0 ]]
			then
			LFTSFTBIN_post=$(echo " ($LFTSFTBIN_post) + ($left_rot)" | bc)
			LFTSFTBIN_post_1=$(echo " ($LFTSFTBIN_post) +1" | bc)
			RGTSFTBIN_post=$(echo " -1*($LFTSFTBIN_post)" | bc)
		fi
	fi

	while [[ "$LFTSFTBIN_post" -gt "$TOTBIN" ]]
		do
		LFTSFTBIN_post=$(echo " ($LFTSFTBIN_post) - ($TOTBIN)" | bc)
		LFTSFTBIN_post_1=$(echo " ($LFTSFTBIN_post) +1" | bc)
		RGTSFTBIN_post=$(echo " -1*($LFTSFTBIN_post)" | bc)
	done
		
	while [[ "$RGTSFTBIN_post" -gt "$TOTBIN" ]]
		do
		RGTSFTBIN_post=$(echo " ($RGTSFTBIN_post) - ($TOTBIN)" | bc)
		LFTSFTBIN_post=$(echo " -1*($RGTSFTBIN_post)" | bc)
		LFTSFTBIN_post_1=$(echo " ($LFTSFTBIN_post) +1" | bc)
	done
		

	if [[ "$subs_baseline_flag" -eq 0 ]]
		then
		baseline=0
	fi

	if [[ "$normalize_flag" -eq 0 ]]
		then
		norm_fac=1
	fi

	# STEP 5: Compute the effective rotation given. 

	LFTSFTBIN_eff=$(echo " ($LFTSFTBIN) + ($LFTSFTBIN_post) " | bc)
	LFTSFTBIN_eff_1=$(echo " ($LFTSFTBIN_eff) +1" | bc)
	RGTSFTBIN_eff=$(echo " ($RGTSFTBIN) + ($RGTSFTBIN_post) " | bc)
	
	while [[ "$LFTSFTBIN_eff" -gt "$TOTBIN" ]]
		do
		LFTSFTBIN_eff=$(echo " ($LFTSFTBIN_eff) - ($TOTBIN)" | bc)
		LFTSFTBIN_eff_1=$(echo " ($LFTSFTBIN_eff) +1" | bc)
		RGTSFTBIN_eff=$(echo " -1*($LFTSFTBIN_eff)" | bc)
	done
		
	while [[ "$RGTSFTBIN_eff" -gt "$TOTBIN" ]]
		do
		RGTSFTBIN_eff=$(echo " ($RGTSFTBIN_eff) - ($TOTBIN)" | bc)
		LFTSFTBIN_eff=$(echo " -1*($RGTSFTBIN_eff)" | bc)
		LFTSFTBIN_eff_1=$(echo " ($LFTSFTBIN_eff) +1" | bc)
	done
	
	# STEP 6: Getting the no of columns in the output.

	if [[ "${retain_orig_columns}" -eq 1 && "${bin2phs}" -ne 0 ]]
		then
		NCOL_out=$(echo "$NCOL + 2" | bc | awk '{printf"%d",$1}' )
		echo "				No of columns in the output file = ${NCOL_out}, i.e. No of columns in the input file ${NCOL} + 2 new columns at the end."
	else
	if [[ "${retain_orig_columns}" -eq 1 && "${bin2phs}" -eq 0 ]]
		then
		NCOL_out=$(echo "$NCOL + 1" | bc | awk '{printf"%d",$1}' )
		echo "				No of columns in the output file = ${NCOL_out}, i.e. No of columns in the input file ${NCOL} + 1 new columns at the end."
	else
		NCOL_out=2
		echo "				No of columns in the output file = ${NCOL_out}, and  No of columns in the input file ${NCOL}."
	fi
	fi

	# STEP 7 : Now depending on the flags passed by user, generate the new header of the output profile.

	if [[ "$window_info_passed" -eq 0 ]] && [[ "$new_header" -eq 1 ]]
		then
		echo "# All bin related quantities refer to 1 based counting even though at input they were expected as 0 based."	>> ${out_file}
		echo "# Input file name ............= ${file}"										>> ${out_file}
		echo "# Profile column .............= ${prof_info_column}"								>> ${out_file}
		echo "# No of col in input file ....= ${NCOL}"										>> ${out_file}
		echo "# No of col in output file ...= ${NCOL_out}"									>> ${out_file}
		echo "# subs_baseline_flag .........= ${subs_baseline_flag}"								>> ${out_file}
		echo "# normalize_flag .............= ${normalize_flag}"								>> ${out_file}
		echo "# center_flag ................= ${center_flag}"									>> ${out_file}
		echo "# left_rot ...................= ${left_rot}"									>> ${out_file}
		echo "# move_peak_to ...............= ${move_peak_to}"									>> ${out_file}
		echo "# Bin to phase ...............= ${bin2phs}"									>> ${out_file}
		echo "# Retain orig columns ........= ${retain_orig_columns}"								>> ${out_file}
		echo "# window_info_passed .........= ${window_info_passed}"								>> ${out_file}
		#echo "# Window ranges for OFF ......= $off_start1-$off_stop1, $off_start2-$off_stop2, $off_start3-$off_stop3"		>> ${out_file}
		#echo "# Window ranges for ON .......= $on_start1-$on_stop1, $on_start2-$on_stop2, $on_start3-$on_stop3"		>> ${out_file}
		echo "# Max ........................= $MAX"										>> ${out_file}	
		echo "# Min ........................= $MIN"										>> ${out_file}	
		echo "# Maxbin .....................= $MAXBIN"										>> ${out_file}	
		echo "# Totbin .....................= $TOTBIN"										>> ${out_file}	
		echo "# Midbin .....................= $MIDBIN"										>> ${out_file}	
		echo "# Lft_shift ..................= $LFTSFTBIN_eff"									>> ${out_file}	
		echo "# Rgt_shift ..................= $RGTSFTBIN_eff"									>> ${out_file}	
		#echo "# No of off bins .............= $off_bin"									>> ${out_file}
		#echo "# Aggregate of off-pulse bins = $off_aggr"									>> ${out_file}
		#echo "# Mean off-pulse level .......= $off_mean"									>> ${out_file}
		#echo "# off_min ....................= $off_min"									>> ${out_file}
		#echo "# off_max ....................= $off_max"									>> ${out_file}
		#echo "# Offpulse rms ...............= $off_rms"									>> ${out_file}
		#echo "# No of on bins ..............= $on_bin"										>> ${out_file}
		#echo "# Aggregate of on-pulse bins .= $on_aggr"									>> ${out_file}
		#echo "# Area under pulse ...........= $on_aupl"									>> ${out_file}
		#echo "# on_min .....................= $on_min"										>> ${out_file}
		#echo "# on_max .....................= $on_max"										>> ${out_file}
		#echo "# Peak based snr .............= $peak_snr"									>> ${out_file}
		#echo "# Integrated snr .............= $int_snr"									>> ${out_file}
		if [[ "${file_passed}" -eq 2 ]]
			then
			echo "# No of pulses ...............= $N_pulse"									>> ${out_file}
			#echo "# Single Pulse snr ...........= $single_pulse_snr"							>> ${out_file}
		fi
	else
	if [[ "$window_info_passed" -eq 2 ]] && [[ "$new_header" -eq 1 ]]
		then
		# Window sanity checks
		if [ "$MAX" != "$on_max" ]
			then
			echo "# Warning ! On-Pulse peak (= $on_max) is not same as profile max (= $MAX)."				>> ${out_file}
			echo "# Warning ! ${file} :On-Pulse peak (= $on_max) is not same as profile max (= $MAX)." >&2 
		fi
		if [ "$MIN" != "$off_min" ]
			then
			dev_var=$(echo "(($off_min)-($MIN))/(($off_max)-($off_min))" | bc -l)
				# Alloing the deviation within 10% of off peak-to-peak.
			Dev_var=$(echo "($dev_var)*($dev_var)*1000000000/1.0" | bc )
			if [[ "$Dev_var" -gt 10000000 ]]
				then
				echo "# Warning ! Off-Pulse min (= $off_min) is not same as profile min (= $MIN).. The deviation is more than 10% off-peak-to-peak."	>> ${out_file}
				echo "# Warning ! ${file} :Off-Pulse min (= $off_min) is not same as profile min (= $MIN).. The deviation is more than 10% off-peak-to-peak." >&2
			fi	
		fi

		echo "# All bin related quantities refer to 1 based counting even though at input they were expected as 0 based."	>> ${out_file}
		echo "# Input file name ............= ${file}"										>> ${out_file}
		echo "# Profile column .............= ${prof_info_column}"								>> ${out_file}
		echo "# No of col in input file ....= ${NCOL}"										>> ${out_file}
		echo "# No of col in output file ...= ${NCOL_out}"									>> ${out_file}
		echo "# subs_baseline_flag .........= ${subs_baseline_flag}"								>> ${out_file}
		echo "# normalize_flag .............= ${normalize_flag}"								>> ${out_file}
		echo "# center_flag ................= ${center_flag}"									>> ${out_file}
		echo "# left_rot ...................= ${left_rot}"									>> ${out_file}
		echo "# move_peak_to ...............= ${move_peak_to}"									>> ${out_file}
		echo "# Bin to phase ...............= ${bin2phs}"									>> ${out_file}
		echo "# Retain orig columns ........= ${retain_orig_columns}"								>> ${out_file}
		echo "# window_info_passed .........= ${window_info_passed}"								>> ${out_file}
		echo "# Window ranges for OFF ......= $off_start1-$off_stop1, $off_start2-$off_stop2, $off_start3-$off_stop3"		>> ${out_file}
		echo "# Window ranges for ON .......= $on_start1-$on_stop1, $on_start2-$on_stop2, $on_start3-$on_stop3"			>> ${out_file}
		echo "# Max ........................= $MAX"										>> ${out_file}	
		echo "# Min ........................= $MIN"										>> ${out_file}	
		echo "# Maxbin .....................= $MAXBIN"										>> ${out_file}	
		echo "# Totbin .....................= $TOTBIN"										>> ${out_file}	
		echo "# Midbin .....................= $MIDBIN"										>> ${out_file}	
		echo "# Lft_shift ..................= $LFTSFTBIN_eff"									>> ${out_file}	
		echo "# Rgt_shift ..................= $RGTSFTBIN_eff"									>> ${out_file}	
		echo "# No of off bins .............= $off_bin"										>> ${out_file}
		echo "# Aggregate of off-pulse bins = $off_aggr"									>> ${out_file}
		echo "# Mean off-pulse level .......= $off_mean"									>> ${out_file}
		echo "# off_min ....................= $off_min"										>> ${out_file}
		echo "# off_max ....................= $off_max"										>> ${out_file}
		echo "# Offpulse rms ...............= $off_rms"										>> ${out_file}
		echo "# No of on bins ..............= $on_bin"										>> ${out_file}
		echo "# Aggregate of on-pulse bins .= $on_aggr"										>> ${out_file}
		echo "# Area under pulse ...........= $on_aupl"										>> ${out_file}
		echo "# on_min .....................= $on_min"										>> ${out_file}
		echo "# on_max .....................= $on_max"										>> ${out_file}
		echo "# Peak based snr .............= $peak_snr"									>> ${out_file}
		echo "# Integrated snr .............= $int_snr"										>> ${out_file}
		if [[ "${file_passed}" -eq 2 ]]
			then
			echo "# No of pulses ...............= $N_pulse"									>> ${out_file}
			echo "# Single Pulse snr ...........= $single_pulse_snr"							>> ${out_file}
		fi
	fi
	fi

	rm -rf junk_top junk_bot junk_col1 junk_col2

	# STEP 8 : Converting bin 2 phase if asked to do so.

	if [[ "${bin2phs}" -eq 1 ]]
		then
		for ((k=0; k<${TOTBIN} ; k++))
			do
			Phase=$(echo "1.0*($k)/($TOTBIN) " | bc -l | awk '{printf"%.6f",$1}')
			echo "$Phase"  >> junk_col1
		done
	else
	if [[ "${bin2phs}" -eq 2 ]]
		then
		for ((k=0; k<${TOTBIN} ; k++))
			do
			Phase=$(echo "1.0*($k)/($TOTBIN) + 1.0/(2.0*($TOTBIN)) " | bc -l | awk '{printf"%.6f",$1}')
			echo "$Phase"  >> junk_col1
		done
	else
		cat ${file} | grep -v "#"  | awk "{print $`echo ${bin_info_column}`}" > junk_col1
	fi
	fi

	# STEP 9 : Apply post rotation, baseline and norm_fac on junk_first_iter.

	if [[ "$LFTSFTBIN_post" -gt 0 ]]
		then
		cat junk_first_iter | grep -v "#"  | tail -n +"$LFTSFTBIN_post_1" | awk -v var1="$baseline" -v var2="$norm_fac" '{printf "%.8f\n",($1-var1)/var2}' > junk_top
		cat junk_first_iter | grep -v "#"  | head -n  "$LFTSFTBIN_post"   | awk -v var1="$baseline" -v var2="$norm_fac" '{printf "%.8f\n",($1-var1)/var2}' > junk_bot
		cat junk_top junk_bot > junk_col2
	fi
	if [[ "$LFTSFTBIN_post" -lt 0 ]]
		then
		cat junk_first_iter | grep -v "#"  | tail -n  "$RGTSFTBIN_post" | awk -v var1="$baseline" -v var2="$norm_fac" '{printf "%.8f\n",($1-var1)/var2}' > junk_top
		cat junk_first_iter | grep -v "#"  | head -n -"$RGTSFTBIN_post" | awk -v var1="$baseline" -v var2="$norm_fac" '{printf "%.8f\n",($1-var1)/var2}' > junk_bot
		cat junk_top junk_bot > junk_col2
	fi
	if [[ "$LFTSFTBIN_post" -eq 0 ]]
		then
		cat junk_first_iter | grep -v "#"  | awk -v var1="$baseline" -v var2="$norm_fac" '{printf "%.8f\n",($1-var1)/var2}' > junk_top
		cat junk_top > junk_col2
	fi

	# STEP 10 : Now depending on the flags passed by user, generate the old header of the output profile.

	if [[ "$old_header" -eq 1 ]]
		then
		if [[ "$new_header" -eq 1 ]]
			then
			echo "############### ORIGINAL HEADER BELOW #################################"					>> ${out_file}
		fi
		cat ${file} | grep "#"													>> ${out_file}
	else
		if [[ "$new_header" -eq 1 ]]
			then
			echo "#######################################################################"					>> ${out_file}
		fi
	fi

	# STEP 11 : Generating the final profile as well as Retaining the info in the original file if asked.

	if [[ "${retain_orig_columns}" -eq 1 ]]
		then
		rm -rf junk_orig
		cat ${file} | grep -v "#" >> junk_orig
		if [[ "${bin2phs}" -ne 0 ]]
			then
			paste junk_orig junk_col1 junk_col2										>> ${out_file}
		else
			paste junk_orig junk_col2											>> ${out_file}
		fi
		rm -rf junk_orig
	else
		paste junk_col1 junk_col2												>> ${out_file}
	fi

	rm -rf junk_top junk_bot junk_col1 junk_col2 junk_first_iter junk_off junk_on

	processed_file=$(echo "${processed_file} + 1" | bc )
	echo
done

echo "No of input  files ${filenames}	available = $(ls -1 ${filenames} 2> /dev/null | wc -l)"
echo "No of output files ${filenames}${extension_name}	successfully generated = ${processed_file}"

rm -rf plotall${extension_name}.gnu
echo "set grid" > plotall${extension_name}.gnu
if [[ "${retain_orig_columns}" -eq 1 && "${bin2phs}" -ne 0 ]]
	then
	ls -1 ${filenames}${extension_name} 2> /dev/null | awk -v var="${NCOL_out}" '{printf("pl \"%s\" u %d:%d w l ; pause -1\n",$1,(var-1),var)}' >> plotall${extension_name}.gnu
else
if [[ "${retain_orig_columns}" -eq 1 && "${bin2phs}" -eq 0 ]]
	then
	ls -1 ${filenames}${extension_name} 2> /dev/null | awk -v var="${NCOL_out}" -v var1="${bin_info_column}" '{printf("pl \"%s\" u %d:%d w l ; pause -1\n",$1,var1,var)}' >> plotall${extension_name}.gnu
else
	ls -1 ${filenames}${extension_name} 2> /dev/null | awk '{printf("pl \"%s\" u 1:2 w l ; pause -1\n",$1)}' >> plotall${extension_name}.gnu
fi
fi

rm -rf junk_filelist

echo
echo "filename(s)${extension_name} have been generated corresponding to all specified files. Also plotall${extension_name}.gnu generated, now from within gnuplot:"
echo "	load 'plotall${extension_name}.gnu'"
echo

exit 0
