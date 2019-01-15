# -*- coding: utf-8 -*-
"""
Created on Thu Nov  8 12:49:03 2018

@author: laure
"""

import pandas as pd
import math as m
from skaero.atmosphere import coesa


def inputs(file):
    inputslist = []
    data = pd.read_table(file, header = None, index_col = False, \
                         delim_whitespace =True , skiprows = [0,1],\
                         usecols = range(0,12))
    name = data.iloc[14,0]
    ## Find Aircraft Avgs and Inputs
    lines = tuple(open(file, 'r'))
    for i in range(len(lines)):
        current = lines[i]
        if current.find("0English Weight")==0:
            weightRef = i+1
            break
    weights = lines[weightRef]
    weights = weights.split()
    fullWeight = float(weights[2])    
    dryWeight = fullWeight - float(weights[5])
    payload = float(weights[8])
    tank = float(weights[15])
    intFuel = float(weights[20])
    fullWeightWOPayload = dryWeight - payload- tank + intFuel
    dryWeightWOPayload = fullWeightWOPayload - intFuel
    
    for i in range(len(data)):
        if data.iloc[i,0]=='TOTAL':
            avgRef1 = i + 2
            break
    for i in range(avgRef1,len(data)):
        if data.iloc[i,0]=='TOTAL':
            avgRef2 = i-3
            break
            
    avgTable = data.iloc[range(avgRef1,avgRef2),:]       
    
    
    hold = []
    for i in range(len(avgTable)):
        if fullWeight>=float(avgTable.iloc[i,0]):
            hold.append(i)
    
    
    cruiseAlt = float(avgTable.iloc[hold[0],2])
    avgMach = 0
    avgTSFC = 0
    avgLD = 0
    
    for i in hold:
        avgMach = avgMach + float(avgTable.iloc[i,4])
        avgTSFC = avgTSFC + float(avgTable.iloc[i,7])
        avgLD = avgLD + float(avgTable.iloc[i,6])           
    
    avgMach = avgMach/len(hold)
    avgTSFC = avgTSFC/len(hold)
    avgLD = avgLD/len(hold)
    
#    R = 286.9 #"Gas constant"
    Altitude = cruiseAlt/3.2808;
    h, T, p, rho = coesa.table(Altitude)
    tempK = 518.7*5/9
    theta = T/tempK #"TSFC correction"
    
#    avgMach = avgMach/(m.sqrt(T*R*1.4)) #Sea level computation
    avgTSFC = avgTSFC/(m.sqrt(theta)) #Sea level computation
    ## Find Fuel Burn Values
        
    for i in range(len(data)): ## PROBABLY WILL HAVE TO DO THIS DIFFERENT
        if data.iloc[i,0]=='WARMUP':
            fuelRef1 = i
            break
    for i in range(len(data)):
        if data.iloc[i,0]=='NRRANG':
            fuelRef2 = i 
            break
    
    fuelMini = data.iloc[range(fuelRef1,fuelRef2),:]
    
    if fuelMini.iloc[3,0]=='DROP':
        reserveTime = data.iloc[fuelRef2-3,1]
        reserveTime = float(reserveTime.split('min')[0])
        reserveFuel = data.iloc[fuelRef2-3,3]
        reserveFuel = float(reserveFuel.split('%Fuel')[0])
        distToCruise = float(data.iloc[fuelRef1+1,7])*1.15
        fuelToCruise = float(data.iloc[fuelRef1+1,8])
        combatFuel = float(fuelMini.iloc[5,5])-float(fuelMini.iloc[6,6])
        climbFuel = float(fuelMini.iloc[7,5])-float(fuelMini.iloc[8,6])
        loiterAlt = float(fuelMini.iloc[2,7])
    else:
        reserveTime = data.iloc[fuelRef2-3,1]
        reserveTime = float(reserveTime.split('min')[0])
        reserveFuel = data.iloc[fuelRef2-3,3]
        reserveFuel = float(reserveFuel.split('%Fuel')[0])
        distToCruise = float(data.iloc[fuelRef1+1,7])*1.15
        fuelToCruise = float(data.iloc[fuelRef1+1,8])
        combatFuel = float(fuelMini.iloc[4,7])-float(fuelMini.iloc[3,6])
        climbFuel = float(fuelMini.iloc[6,7])-float(fuelMini.iloc[4,7])
        loiterAlt = float(fuelMini.iloc[3,7])
    
    userRange = 10 #This is a placeholder
    
    inputslist = [name, avgTSFC, avgLD, avgMach, fuelToCruise, distToCruise,\
                  combatFuel, climbFuel, reserveFuel, reserveTime, dryWeight, \
                  fullWeight, dryWeightWOPayload, fullWeightWOPayload, \
                  cruiseAlt, loiterAlt, userRange]

    return inputslist;