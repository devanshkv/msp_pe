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
from scipy.optimize import curve_fit
import numpy as np
import matplotlib.pyplot as plt
import sys
import redchisq
#lets read the files!
f= open(sys.argv[1],'r')
x = []
y = []

for line in f:
    line = line.strip()
    columns = line.split()
    x.append(float(columns[0]))
    y.append(float(columns[2]))
f.close()


#plt.plot(x,y,'m-')
#plt.show()

def func(x, *params):
    y = np.zeros_like(x)
    for i in range(0, len(params), 3):
        ctr = params[i]
        amp = params[i+1]
        wid = params[i+2]
        y = y + amp * np.exp( -((x - ctr)/wid)**2)
    return y

comp = 1#int(input("Number of components to be fit: ")) - 1

guess = [0.5 , 1 , 0.08]

for i in range(comp):
    guess += [0.55 + 0.05*i, 0.04, 0.05]

popt, pcov = curve_fit(func, x, y, p0=guess)
#print popt
err = np.sqrt(np.diag(pcov))
fit = func(x, *popt)
print redchisq.redchisqg(y,fit,3*(comp+1),float(sys.argv[2]))

j=0
for i in range(comp+1):
    ctr = popt[j]
    amp = popt[j+1]
    wid = popt[j+2]
    print ctr, err[j], amp, err[j+1],wid*360*1.66510922232, err[j+2]*360*1.66510922232
    j=j+3
    plt.plot(x,amp * np.exp( -((x - ctr)/wid)**2))

plt.plot(x,y, 'mo')
plt.plot(x, fit , 'k-')
plt.show()
