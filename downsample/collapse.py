#!/usr/bin/python

#########################################################
#                                                       #
#                  collapse by given no. of bins        #
#                Written by : Devansh Agarwal           #
#                devansh@iisertvm.ac.in                 #
#                                                       #
#########################################################
'''
Useage:
./collapse.py <filename> <no. of bins>
'''
#import libaries
import sys
import numpy as np
import math
import scipy

#lets read the files!
f= open(sys.argv[1],'r')
x_dat = []
y_dat = []

for line in f:
	line = line.strip()
        columns = line.split()
        x_dat.append(float(columns[0]))
        y_dat.append(float(columns[2]))
f.close()
y_dat=np.array(y_dat)
x_dat=np.array(x_dat)
#let the user provide the windows
R=int(sys.argv[2])
pad_size = math.ceil(float(y_dat.size)/R)*R - y_dat.size
b_padded = np.append(y_dat, np.zeros(pad_size)*np.NaN)
x=scipy.nanmean(b_padded.reshape(-1,R), axis=1)

a_padded = np.append(x_dat, np.zeros(pad_size)*np.NaN)
y=scipy.nanmean(a_padded.reshape(-1,R), axis=1)


#
#no_input = int(sys.argv[2])+1
#on_i=[]
#
#for i in xrange(2*no_input):
#	on_i.append(float(sys.argv[3+i]))
#
#noise=[]
#
##chopper
#j=0
#for i in xrange(no_input):
#	noise_temp=y_dat[x_dat.index(on_i[j]):x_dat.index(on_i[j+1])+1]
#	j=j+2
#	noise=noise+noise_temp
#
#
#off_mean_old = numpy.mean(noise)
#off_std_old = numpy.std(noise, dtype=numpy.float64)
#x = [x1 - off_mean_old for x1 in y_dat]
x[:] = [x1/max(x) for x1 in x]
#
lol=0
#print "# off_stdev",off_std_old
for i,j in map(None,y,x):  
	print ('%.12f' %i),"\t",int(lol),"\t",('%.12f' %j)
	lol=lol+1
#
