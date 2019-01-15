# -*- coding: utf-8 -*-
"""
Created on Thu Nov  8 13:11:36 2018

@author: laure
"""
#EXAMPLE USAGE
import model_inputs as mod
import AircraftClass as ac
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import RadiusCode as rc

samplefile = 'C:/Users/laure/Documents/Thesis/NASIC Thesis/Notes/scrubbeddata/loiterc1_000_output.txt'
interestPts = 'C:/Users/laure/Documents/Thesis/NASIC Thesis/Code/Python/Locations.xlsx'
inputslist = mod.inputs(samplefile)
F15C = ac.Aircraft(inputslist)
intersect,_,_,inEQ, outEQ, endurance = ac.Aircraft.EnduranceTradeoffs(F15C)

#%% Radius

Lat = 38.820485
Lon = -97.705588
distanceInMiles = intersect

#orthographic basemap, center on specified lat and lon
mp = Basemap(projection='ortho', lat_0 = Lat, lon_0 = Lon, resolution = 'l')

mp.bluemarble()
mp.drawstates()
mp.drawcountries()
mp.drawcoastlines()

X,Y = rc.createCircleAroundWithRadius(Lat,Lon,distanceInMiles)

X,Y = mp(X,Y)
mp.plot(X,Y,marker=None,color='g',linewidth=1)

x,y = mp(Lon,Lat)
mp.plot(x,y ,marker='D',color='g',markersize=2)

## Added points
dist,ranges = rc.mapInterestPts(interestPts, Lat, Lon, intersect)
A = dist[:,0]; 
B = dist[:,1]; 
A,B = mp(B,A)
mp.scatter(A,B ,1,marker = 'D',color = 'r')

for i in range(len(ranges)):
    F15C.userRange = ranges[i]
    _,_,_,_, _, endurance = ac.Aircraft.EnduranceTradeoffs(F15C)
    endurance = str(round(endurance,2))
    plt.text(A[i]+100000,B[i],'%s min' %endurance,fontsize = 8,color = 'y')
    
    
    
##%% PARETO FRONT ALTITUDES
#xValue = np.arange(20,intersect-20,20)
#pFront = np.zeros((8,len(xValue)))
#
#
#for j in range(0,8):
#    F15C.loiterAltitude = 5000+5000*j;
#    for i in xValue:
#        F15C.userRange = i
#        _,_,_,_,_,endure = ac.Aircraft.EnduranceTradeoffs(F15C)
#        idx = int((i-20)/20)
#        pFront[j,idx] = endure
#        
#plt.figure()
#for i in range(0,8):
#    alts = 5000+5000*i
#    plt.plot(xValue,pFront[i,], label = 'Loiter Altitude = %d' % alts)
#    plt.pause(1)
#       
#plt.xlabel(r'\textbf{Range} (mi)')
#plt.ylabel(r'\textbf{Loiter Time} (min)')
#plt.title(r"Pareto Front for Nonlinear Range vs. Time ", fontsize=16)
#plt.legend()
#plt.show() 