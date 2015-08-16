#!/usr/bin/python

#########################################################
#                                                       #
#                  gaussian fitting                     #
#                Written by : Devansh Agarwal           #
#                devansh@iisertvm.ac.in                 #
#                                                       #
#########################################################

#import libaries
from scipy.optimize import curve_fit
import numpy as np
import matplotlib.pyplot as plt
import sys
def redchisqg(ydata,ymod,deg,sd):
     # Chi-square statistic
     if sd==None:
          chisq=np.sum((ydata-ymod)**2)
     else:
          chisq=np.sum( ((ydata-ymod)/sd)**2 )
     nu=len(ydata)-1-deg
     return chisq/nu

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


plt.plot(x,y,'m-')
plt.show()

def func(x, *params):
    y = np.zeros_like(x)
    for i in range(0, len(params), 3):
        ctr = params[i]
        amp = params[i+1]
        wid = params[i+2]
        y = y + amp * np.exp( -((x - ctr)/wid)**2)
    return y

comp = int(input("Number of components to be fit: ")) - 1

#intial guess
guess = [0.3352, 0.4982, 0.05026]#, 0.4003, 0.6865, 0.096460, 0.5948, 0.8761, 0.0801]

for i in range(comp):
    guess += [0.35 + 0.1*(i+1), 0.049, 0.05]

popt, pcov = curve_fit(func, x, y, p0=guess)
#print popt
err = np.sqrt(np.diag(pcov))
fit = func(x, *popt)
print redchisqg(y,fit,3*(comp+1),float(sys.argv[2]))
#print popt

j=0

from matplotlib.backends.backend_pdf import PdfPages
pp = PdfPages('multipage.pdf')
plt.figure(1)
plt.subplot(211)
for i in range(comp+1):
    ctr = popt[j]
    amp = popt[j+1]
    wid = popt[j+2]
    #print ctr, err[j], amp, err[j+1],wid*360*1.66510922232, err[j+2]*360*1.66510922232
    j=j+3
    plt.plot(x,amp * np.exp( -((x - ctr)/wid)**2))
print 360*(poddpt[0]-popt[3]), 360*(popt[3]-popt[6]), 360*(popt[0]-popt[6])
plt.plot(x,y, 'm.-',label='profile')
plt.ylabel("Intensity")
plt.plot(x, fit , 'k-',label='fit')
plt.legend(prop={'size':8})
plt.grid(True)
plt.subplot(212)
plt.grid(True)
plt.plot(x,(y-fit),'r-o',label='residuals')
plt.legend(loc=4,prop={'size':8})
plt.xlabel("Phase")
plt.ylabel("Residuals")
plt.savefig(pp, format='pdf')
pp.close()
plt.show()
