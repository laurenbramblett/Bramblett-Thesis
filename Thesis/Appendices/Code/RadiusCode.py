# -*- coding: utf-8 -*-
"""
Created on Sat Nov  3 11:14:09 2018

@author: laure
"""

import math as m
import pandas as pd
import numpy as np

def createCircleAroundWithRadius(lat, lon, radiusMiles):
    latArray = []
    lonArray = []
 
    for brng in range(0,360):
            lat2, lon2 = getLocation(lat,lon,brng,radiusMiles)
            latArray.append(lat2)
            lonArray.append(lon2)

    return lonArray,latArray


def getLocation(lat1, lon1, brng, distanceMiles):
    lat1 = lat1 * m.pi/ 180.0
    lon1 = lon1 * m.pi / 180.0
     #earth radius
     #R = 6378.1Km
     #R = ~ 3959 Miles
    R = 3959
    distanceMiles = distanceMiles/R

    brng = (brng / 90)* m.pi / 2

    lat2 = m.asin(m.sin(lat1) * m.cos(distanceMiles) \
                  + m.cos(lat1) * m.sin(distanceMiles) * m.cos(brng))

    lon2 = lon1 + m.atan2(m.sin(brng)*m.sin(distanceMiles)\
                          * m.cos(lat1),m.cos(distanceMiles)-m.sin(lat1)*m.sin(lat2))

    lon2 = 180.0 * lon2/ m.pi
    lat2 = 180.0 * lat2/ m.pi
    

    return lat2, lon2

def mapInterestPts(file,startLat,startLong,distanceMiles):
    R = 3959
    locates = pd.read_excel(file)
    allDist = np.zeros([1,2])
    radii = []
    startLatRad = m.radians(startLat)
    count = 0
    for i in locates.index:
        long = locates["Longitude"][i]
        lat = locates["Latitude"][i]
        latRad = m.radians(lat)
        delLat = m.radians(startLat-lat)
        delLong = m.radians(startLong-long)
        
        a = (m.sin(delLat/2))**2+m.cos(latRad)*m.cos(startLatRad)*(m.sin(delLong/2))**2
        c = 2*m.atan2(m.sqrt(a),m.sqrt(1-a))
        D = R*c
        if D<=distanceMiles:
            coords = np.array([lat,long])
            allDist=np.vstack((allDist,coords))
            radii.append(D)
        if count == 0:
                count = 1
                allDist = np.delete(allDist,(0),axis = 0)
                
    return allDist,radii;
    
    
    
    
    