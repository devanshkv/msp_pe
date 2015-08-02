#!/usr/bin/python

#########################################################
#                                                       #
#                  Separation error                     #
#                Written by : Devansh Agarwal           #
#                devansh@iisertvm.ac.in                 #
#                                                       #
#########################################################
'''
Useage : 
./run_avg.py "<filename>" <no. of points to average>
'''
#import libaries
import sys
import numpy as np

def runningMean(x, N):
    y = np.zeros((len(x),))
    for ctr in range(len(x)):
        y[ctr] = np.sum(x[ctr:(ctr+N)])
    return y/N

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

x=runningMean(y_dat,int(sys.argv[2]))

#Normalize
x[:] = [x1/max(x) for x1 in x]

lol=0
for i,j in map(None,x_dat,x):
	print ('%.12f' %i),"\t",int(lol),"\t",('%.12f' %j)
	lol=lol+1
