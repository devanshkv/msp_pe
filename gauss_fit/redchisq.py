import numpy
def redchisqg(ydata,ymod,deg,sd):
     # Chi-square statistic
     if sd==None:
          chisq=numpy.sum((ydata-ymod)**2)
     else:
          chisq=numpy.sum( ((ydata-ymod)/sd)**2 )
     nu=len(ydata)-1-deg
     return chisq/nu
