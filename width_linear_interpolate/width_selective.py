#########################################################
#                                                       #
#                Width Calculator 	                #
#               Written by : Devansh Agarwal            #
#               devansh@iisertvm.ac.in                  #
#                                                       #
#########################################################
'''
The program calculates the FWHM of a given profile by 
linear interpolation, given the location of the peak.
It assumes bins in 1st column and data in 3rd column
of the given profile, to change that go yo #write
data section.
Put the file in data.mba or change in #read the data
file section.


Useage : python width_selective.py <peak_location>

'''
import sys

#read the data file

f = open('data.mba', 'r')

#location of peak

loc = float(sys.argv[1])

#pre-initialize

phs_nos=[]
dat_nos=[]
pre01=[]
post01=[]

#write data

for line in f:
                                #Read and Split

                                rows = line.strip()
                                columns = line.split()
			
                                #Read Raw Stokes from ascii

                                phs_nos.append(float(columns[0]))
                                dat_nos.append(float(columns[2]))
f.close()

#normalize

dat_nos = [x/max(dat_nos) for x in dat_nos]
I = int(phs_nos.index(loc))

#list for leading and lagging part

pre = dat_nos [:I]
post = dat_nos [I:]

#pre calculation, half of intensity at user given location

pnt = float(0.5*dat_nos[I])
print pnt

#index for points near by

for x in pre:
	if x <= pnt:
		pre01.append(float(x))

ind_pre=len(pre01)-1

for x in post:
	if x <= pnt:
		post01.append(float(x))

ind_post=len(pre)+post.index(post01[0])

# Data Points

x_lead_1=float(phs_nos[ind_pre])
y_lead_1=float(dat_nos[ind_pre])
x_lead_2=float(phs_nos[ind_pre+1])
y_lead_2=float(dat_nos[ind_pre+1])
x_lag_1=float(phs_nos[ind_post])
y_lag_1=float(dat_nos[ind_post])
x_lag_2=float(phs_nos[ind_post-1])
y_lag_2=float(dat_nos[ind_post-1])

px_lead_1=float(phs_nos[ind_pre])
py_lead_1=float(dat_nos[ind_pre])
px_lead_2=float(phs_nos[ind_pre-1])
py_lead_2=float(dat_nos[ind_pre-1])
px_lag_1=float(phs_nos[ind_post])
py_lag_1=float(dat_nos[ind_post])
px_lag_2=float(phs_nos[ind_post-1])
py_lag_2=float(dat_nos[ind_post-1])


#calcualte the lines for interpolation and width

left_bin = float(x_lead_2+((pnt-y_lead_2)*(x_lead_1-x_lead_2)/(y_lead_1-y_lead_2)))
right_bin = float(x_lag_2+((pnt-y_lag_2)*(x_lag_1-x_lag_2)/(y_lag_1-y_lag_2)))
width_1 =abs(360* ((right_bin-left_bin)))

pleft_bin = float(px_lead_2+((pnt-py_lead_2)*(px_lead_1-px_lead_2)/(py_lead_1-py_lead_2)))
pright_bin = float(x_lag_2+((pnt-py_lag_2)*(px_lag_1-px_lag_2)/(py_lag_1-py_lag_2)))
width_2 =abs(360* ((pright_bin-pleft_bin)))

differ=abs(width_1-width_2)
aver=(width_1+width_2)/2

if differ < (0.5*aver):
	width = aver
else:
	width = "check points",aver,width_1,width_2

#finally the width
print width, width_1, width_2
#print x_lead_1,"\t",y_lead_1,"\t",x_lead_2,"\t",y_lead_2,"\t",x_lag_1,"\t",y_lag_1,"\t",x_lag_2,"\t",y_lag_2
