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
./error_s.py "<filename>" <no_of_windows> <on_bin> <off_bin>
'''
#import libaries
import sys
import numpy
import matplotlib.mlab
import itertools
import math
import pylab

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

#let the user provide the windows

no_input = int(sys.argv[2])+1
on_i=[]

for i in xrange(2*no_input):
	on_i.append(float(sys.argv[3+i]))

noise=[]

#chopper
j=0
for i in xrange(no_input):
	noise_temp=y_dat[x_dat.index(on_i[j]):x_dat.index(on_i[j+1])+1]
	j=j+2
	noise=noise+noise_temp


off_mean_old = numpy.mean(noise)
off_std_old = numpy.std(noise, dtype=numpy.float64)
x = [x1 - off_mean_old for x1 in y_dat]
x[:] = [x1/max(x) for x1 in x]

lol=0
print "# off_stdev",off_std_old
for i,j in map(None,x_dat,x):  
	print ('%.12f' %i),"\t",int(lol),"\t",('%.12f' %j)
	lol=lol+1

#C = numpy.random.normal(numpy.mean(x),numpy.std(x),7)
#
#f= open(sys.argv[2],'r')
#A=[]
#X=[]
#for line in f:
#        line = line.strip()
#        columns = line.split()
#        A.append(float(columns[2]))
#	X.append(float(columns[0]))
#f.close()
#
#B=[1,2]
#
#def unique(iterable):
#    seen = set()
#    for x in iterable:
#        if x in seen:
#            continue
#        seen.add(x)
#        yield x
#
#
#def max_compute(A,C,B):
#	D=list(unique(itertools.permutations(list(B) *len(A), r=len(A))))
#	maxed=[]
#	for b in D:
#	        for cperm in itertools.permutations(C):
#	                d= [math.pow(-1,x[0])*x[1] for x in zip(b, cperm)]
#			new_A = [sum(x)for x in zip(d, A)]
#			maxed.append(X[new_A.index(max(new_A))])
#	return(maxed)
#maxed=max_compute(A,C,B)
#print numpy.std(maxed),numpy.mean(maxed),math.pow(numpy.mean(numpy.array(maxed)**2),0.5)
#
#f= open(sys.argv[3],'r')
#tpx=[]
#tpy=[]
#for line in f:
#        line = line.strip()
#        columns = line.split()
#        tpy.append(float(columns[2]))
#        tpx.append(float(columns[0]))
#f.close()
#tpy1 = [x1 - num_mean for x1 in tpy]
#tpy1 = [x1/max(tpy1) for x1 in tpy1]
#p1,=pylab.plot(tpx,tpy, label = 'norm')
#p2,=pylab.plot(tpx,tpy1, label = 'un-norm')
#pylab.legend([p1,p2], ['A','B'],loc=1)
#pylab.grid()
#pylab.show()
