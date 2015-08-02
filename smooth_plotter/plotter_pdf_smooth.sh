#!/bin/bash

#remove unwanted files
rm -rf plotter_pdf temp_dm* *.sm

#initial gnuplot stuff
echo "reset"													                      >> plotter_pdf
echo "set terminal pdfcairo solid butt enhanced size 11in,9in font \"Helvectica,15\" "  >> plotter_pdf
echo "set output 'ouput.pdf'"                               >> plotter_pdf
echo "set multiplot"                                        >> plotter_pdf
echo "set macros"                                           >> plotter_pdf

#macros etc for spacing stuff
echo "NOXTICS = \"set xtics (''0,''0.25,''0.5,''0.75,''1); \ unset xlabel\""    >> plotter_pdf
echo "XTICS = \"set xtics (0,0.25,0.5,0.75,1); \ "                              >> plotter_pdf
echo "set xlabel \"phase\""                                                     >> plotter_pdf
echo "NOYTICS = \"set format y ''; unset ylabel"                                >> plotter_pdf

#few varibales

size_decor=$(ls ${1} | wc -l)
phase_decor=0.05
counter=0.0
firstdone=0
dm_counter=0
smoothing_counter=0
pt_size=$(echo "4.0/${size_decor}" | bc -l)
#lets get plotting
for prof in `ls -1 ${1}`
       do
			   #grof = J0218+4232_0243_
         grof=$(echo "${prof}" | cut -c1-16)
			   psr_name=$(echo "${prof}" | cut -d_ -f 1)
         prof_bin=$(tail -n 1 $prof | awk '{print $2}' )
         freq=$(echo "$prof" | cut -d_ -f 2)
			   period=$(grep ${psr_name} /home/devansh/Copy/Pulsars/data/Database/period.dat | awk '{print $2}')
			   dm=$(echo "${prof}" | cut -d_ -f 3)
         run_avg_file=$(locate run.avg | grep $psr_name | head -n 1)
         smooth_widow=$(grep "_$freq" $run_avg_file | awk '{print $2}')
         echo "Plotting PSR : $psr_name at requency : $freq, DM : $dm, Period : $period"
         dm_counter=$(echo "${dm_counter} + 1" | bc )
         smoothing_counter=$(echo "$smoothing_counter + 1" | bc )
         if [[ ! -z $smooth_widow ]]
         then
           smooth_widow_width=$(echo "$smooth_widow / $prof_bin" | bc -l)
           echo "and smoothing window length: $smooth_widow_width"
           echo "0.2 0.8 $smooth_widow_width" > ${freq}_${smoothing_counter}.sm
         fi
		     if [[ "${firstdone}" -eq 0 ]]
          then
			      firstdone=1
			      echo ""                                                                   >> plotter_pdf
            echo "set origin 0.,${phase_decor}"                                       >> plotter_pdf
			      echo "set bmarg 0.075"									                                 	>> plotter_pdf
            echo "set size 0.5,$(echo ".9 / ${size_decor}" | bc -l)"                  >> plotter_pdf
            echo "set xrange [\"0\":\"1\"]"                                           >> plotter_pdf
            echo "set key lmargin"                                                    >> plotter_pdf
			      echo "@XTICS;"				                                          					>> plotter_pdf
			      echo "set ytics (0.0,0.25,0.5,0.75,1.0)"				                          >> plotter_pdf
			      echo "set ytics (0.0,0.5,1.0)"                                 						>> plotter_pdf
			      echo "set grid"                                                           >> plotter_pdf
            # if external then plot blue else black
            if [[ ! -z `echo "${prof}" | grep "epn"` ]]
              then
                echo "pl \"${prof}\" u 1:3 w lp lc rgb \"blue\"  ps ${pt_size} t \"`echo \"${prof}\" | cut -d_ -f 2` epndb" >> plotter_pdf
                if [ -f ${freq}_${smoothing_counter}.sm ];
                then
                  echo "repl \"${freq}_${smoothing_counter}.sm\" u 1:2:3 w xerrorbars lc rgb \"red\" pt 0  notitle" >> plotter_pdf
                fi
            else
                echo "pl \"${prof}\" u 1:3 w lp lc rgb \"black\"  ps ${pt_size} t \"`echo \"${prof}\" | cut -d_ -f 2,6 | sed 's#_# #g' | cut -d. -f 1`" >> plotter_pdf               
                if [[ -z $(echo $prof | grep "codis") ]]
                then
                  grep "${grof}" /home/devansh/Copy/Pulsars/data/Database/dm_smear_2nd_order.dat > temp_dm_${dm_counter}
                  echo "repl \"temp_dm_${dm_counter}\" u 2:3:4 w xerrorbars  lc rgb \"black\" pt 0 notitle" >> plotter_pdf
                  if [ -f ${freq}_${smoothing_counter}.sm ];
                  then
                      echo "repl \"${freq}_${smoothing_counter}.sm\" u 1:2:3 w xerrorbars lc rgb \"red\" pt 0  notitle" >> plotter_pdf
                  fi
                fi
	          fi

       		else

			      echo ""												                                        >> plotter_pdf
			      echo "set origin 0.0,${phase_decor}"								                  >> plotter_pdf
			      echo "set size 0.5,$(echo ".9 / ${size_decor}" | bc -l)"						>> plotter_pdf
			      echo "set grid"                                                       >> plotter_pdf
			      echo "set xrange [\"0\":\"1\"]"							                       		>> plotter_pdf
			      echo "@NOXTICS;"							                                      	>> plotter_pdf
			      echo "set key lmargin"				                              					>> plotter_pdf
			      echo "set ytics (0.0,0.5,1.0)"                                        >> plotter_pdf
	
            if [[ ! -z `echo "${prof}" | grep -E '(epn|nancay)'` ]]
              then
              if [[ ! -z `echo "${prof}" | grep 'epn'` ]]
              then
			      	  echo "pl \"${prof}\" u 1:3 w lp lc rgb \"blue\"  ps ${pt_size} t \"`echo \"${prof}\" | cut -d_ -f 2` epndb" >> plotter_pdf
              else
                echo "pl \"${prof}\" u 1:3 w lp lc rgb \"blue\"  ps ${pt_size} t \"`echo \"${prof}\" | cut -d_ -f 2` nancy" >> plotter_pdf
              fi
            		if [ -f ${freq}_${smoothing_counter}.sm ];
                then
                  echo "repl \"${freq}_${smoothing_counter}.sm\" u 1:2:3 w xerrorbars  lc rgb \"red\" pt 0  notitle" >> plotter_pdf
                fi
           	else
		            echo "pl \"${prof}\" u 1:3 w lp lc rgb \"black\"  ps ${pt_size} t \"`echo \"${prof}\" | cut -d_ -f 2,6 | sed 's#_# #g' | cut -d. -f 1`" >> plotter_pdf
                if [[ -z $(echo $prof | grep "codis") ]]
                then
                  grep "${grof}" /home/devansh/Copy/Pulsars/data/Database/dm_smear_2nd_order.dat > temp_dm_${dm_counter}
                  echo "repl \"temp_dm_${dm_counter}\" u 2:3:4 w xerrorbars lc rgb \"black\" pt 0 notitle" >> plotter_pdf
                fi
	            	if [ -f ${freq}_${smoothing_counter}.sm ];
                then
                  echo "repl \"${freq}_${smoothing_counter}.sm\" u 1:2:3 w xerrorbars  lc rgb \"red\" pt 0  notitle" >> plotter_pdf
                fi
            fi

		      fi

		echo ""                         >> plotter_pdf
		phase_decor=$(echo "${phase_decor} + $(echo ".9 / ${size_decor}" | bc -l)" | bc -l)
		counter=$(echo "${counter}+1" | bc -l)
	done

		echo ""                                                                                           >> plotter_pdf
    echo "reset"                                                                                      >> plotter_pdf
    echo "set origin 0.5,0.5"                                                                         >> plotter_pdf
    echo "set size 0.4,0.4"                                                                           >> plotter_pdf
    echo "set grid"                                                                                   >> plotter_pdf
		echo "set title \"PSR : ${psr_name}\nP : ${period} (s)\nDM : ${dm} (pc/cm^{-3})\" "               >> plotter_pdf
		echo "set xlabel 'frequency (MHz)'"                                                               >> plotter_pdf
    echo "set ylabel 'width (degrees)'"                                                               >> plotter_pdf
		echo "pl \"${2}\" u 1:2 w lp ps 0.5 pt 7 lc rgb \"black\", \"${2}\" u 1:3 w lp ps 0.5 pt 7 lc rgb \"black\""	        		>> plotter_pdf

    echo "reset"                                                                                      >> plotter_pdf
		echo "set origin 0.5,0.1"                                                                         >> plotter_pdf
    echo "set size 0.4,0.4"                                                                           >> plotter_pdf
    echo "set grid"                                                                                   >> plotter_pdf
    echo "set key"                                                                                    >> plotter_pdf
    echo "set xlabel 'frequency (MHz)'"                                                               >> plotter_pdf
    echo "set ylabel 'separation (degrees)'"                                                          >> plotter_pdf
		echo "pl \"${2}\" u 1:3 w lp ps 0.5 pt 7 lc rgb \"black\" t \"separation\""                       >> plotter_pdf

	  echo "unset multiplot"									                                                          >> plotter_pdf
    echo "unset output"                                                                               >> plotter_pdf
gnuplot plotter_pdf
