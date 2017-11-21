#!usr/bin/python

"""Chapter 6.3 Practical"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

""" The typical Lotka-Volterra Model simulated using scipy """
""" LV2.py practical is a modification of LV1.py by taking the arguments for the parameters from the command line """

import scipy as sc
import scipy.integrate as integrate
import pylab as p #Contains matplotlib for plotting
# import matplotlip.pylab as p #Some people might need to do this
import sys #Taking arguments for parameters from command line

def dR_dt(pops, t=0):
    """ Returns the growth rate of predator and prey populations at any
    given time step """

    R = pops[0]
    C = pops[1]
    dRdt = r*R*(1-(R/K)) - a*R*C
    dydt = -z*C + e*a*R*C

    return sc.array([dRdt, dydt])

if len(sys.argv)>1: #if length of the argument from command line is >1 then define parameters
     r = float(sys.argv[1])
     a = float(sys.argv[2])
     z = float(sys.argv[3])
     e = float(sys.argv[4])
     K = float(sys.argv[5])
else: #otherwise define the parameters as such...
    # Define parameters:
    r = 1. # Resource growth rate
    a = 0.1 # Consumer search rate (determines consumption rate)
    z = 1.5 # Consumer mortality rate
    e = 0.75 # Consumer production efficiency
    K = 30.0 #carrying capacity of the system - the max pop that is stable
# Now define time -- integrate from 0 to 15, using 1000 points:
t = sc.linspace(0, 15,  1000)

x0 = 10
y0 = 5
z0 = sc.array([x0, y0]) # initials conditions: 10 prey and 5 predators per unit area

pops, infodict = integrate.odeint(dR_dt, z0, t, full_output=True)

infodict['message']     # >>> 'Integration successful.'

prey, predators = pops.T # What's this for?
f1 = p.figure() #Open empty figure object
p.plot(t, prey, 'g-', label='Resource density') # Plot
p.plot(t, predators  , 'b-', label='Consumer density')
p.grid()
p.legend(loc='best')
p.xlabel('Time')
p.ylabel('Population')
p.title('Consumer-Resource population dynamics')
p.annotate('r=%r, a=%r, z=%r, e=%r, K=%r' %(r,a,z,e,K), xy=(0,0), xytext=(10,8))
p.show()
f1.savefig('../Results/LV2_plot.pdf') #Save figure

print "Resource population density is %f" % pop[-1,0] #-1 is the last element entry (nth entry)
print "Resource population density is %f" % pop[-1,1]
