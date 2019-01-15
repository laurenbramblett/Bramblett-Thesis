# -*- coding: utf-8 -*-
"""
Created on Sun Nov  4 18:53:46 2018

@author: laure
"""
import math as m
import numpy as np
from skaero.atmosphere import coesa

class Aircraft(object):
    
    def __init__(self, alist):
        self.name = alist[0]
        self.TSFCsl = alist[1] # Thrust specific fuel consumption (lbs/sec)
        self.LDmax = alist[2] # Max lift over drag (L/D)
        self.speedMax = alist[3] # Mach speed max when C_L^(1/2)/C_D is maximized
        self.fuelToCruise = alist[4] # Fuel used during climb to cruise
        self.distToCruise = alist[5] # Miles traveled during climb to cruise
        self.Combat = alist[6] #Fuel burned during combat
        self.climbFuel = alist[7] #Fuel burned on climb from combat
        self.fuelReserve = alist[8] # Percent of fuel in reserve
        self.timeReserve = alist[9] # Minutes of endurance in reserve
        self.dryWeight = alist[10] # Weight including payload (excluding fuel) (lbs)
        self.maxTOW = alist[11] # Weight including payload and fuel (lbs)
        self.inDryWeight = alist[12] # Dry weight without payload/tanks (lbs)
        self.inMaxTOW = alist[13] #Weight with fuel without tanks and payload (lbs)
        self.cruiseAltitude = alist[14] # Altitude of cruise in ft
        self.loiterAltitude = alist[15] #Altitude of loiter in ft
        self.userRange = alist[16] # Miles desired
        
    def EnduranceTradeoffs(self,*args):
        R = 286.9; "Gas constant"
        Altitude = self.cruiseAltitude/3.2808;
        loiterAlt = self.loiterAltitude/3.2808;
        _, T1, _, _ = coesa.table(Altitude); "Use International Standard Atmosphere data"
        _, T2, _, _ = coesa.table(loiterAlt)
        tempK = 518.7*5/9;
        TSFC = self.TSFCsl*m.sqrt(T1/tempK)/3600; "TSFC at altitude (per hour)"
        TSFCloiter = self.TSFCsl*m.sqrt(T2/tempK)/3600
        speedMax = self.speedMax*m.sqrt(T1*R*1.4)*3.2808; "Conversion to account for altitude (ft/s)"
    
        "Fuel Reserve Conversion"
        percentFuel = (self.inMaxTOW - self.inDryWeight)*self.fuelReserve/100;
        solInitialWeight = m.exp(self.timeReserve*(TSFC*60)/self.LDmax)*self.inDryWeight;
        percentFuel = (percentFuel + (solInitialWeight-self.inDryWeight))/(self.inMaxTOW-self.inDryWeight);
    
        initialReserve = 1-(self.maxTOW - self.fuelToCruise)/self.maxTOW;
        translateE = -(m.log((initialReserve*(self.maxTOW-self.dryWeight)+self.dryWeight)/self.maxTOW)*\
                       speedMax/5280*self.LDmax/TSFC+self.distToCruise);
        translateI = (-(self.LDmax*speedMax/5280*\
                        m.log((self.inDryWeight + self.inMaxTOW*percentFuel-\
                               self.inDryWeight*percentFuel)/(self.inMaxTOW)))/TSFC);
        intersect = (self.LDmax*speedMax*m.log(-(m.exp(-(TSFC*5280*\
            translateE)/(2*self.LDmax*speedMax))*(m.exp((TSFC*5280*\
            translateI)/(2*self.LDmax*speedMax))*(4*self.inMaxTOW**2*self.maxTOW**2 +\
            self.dryWeight**2*self.inMaxTOW**2*m.exp((TSFC*5280*(translateE + \
            translateI))/(self.LDmax*speedMax)) + self.inDryWeight**2*self.maxTOW**2*\
            m.exp((TSFC*5280*(translateE + translateI))/(self.LDmax*\
            speedMax)) - 4*self.dryWeight*self.inMaxTOW**2*self.maxTOW - 4*self.inDryWeight*\
            self.inMaxTOW*self.maxTOW**2 + 4*self.dryWeight*self.inDryWeight*self.inMaxTOW*self.maxTOW - \
            2*self.dryWeight*self.inDryWeight*self.inMaxTOW*self.maxTOW*m.exp((TSFC*5280*\
            (translateE + translateI))/(self.LDmax*speedMax)))**(1/2) - \
            self.dryWeight*self.inMaxTOW*m.exp((TSFC*5280*(translateE + 2*\
            translateI))/(2*self.LDmax*speedMax)) + self.inDryWeight*self.maxTOW*\
            m.exp((TSFC*5280*(translateE + 2*translateI))/(2*\
            self.LDmax*speedMax))))/(2*self.inMaxTOW*(self.dryWeight - self.maxTOW))))/(TSFC*5280);
    
#        if self.userRange>intersect:
#            endurance = 'Wanted range exceeds max range';
#            return endurance;
        
        weightInitialFrac = (m.exp(-(self.userRange + translateE)*TSFC/(speedMax/5280*self.LDmax))*\
                             self.maxTOW - self.dryWeight)/(self.maxTOW-self.dryWeight);
        weightFinalFrac = (m.exp((self.userRange - translateI)*TSFC/(speedMax/5280*self.LDmax))*\
                           self.inMaxTOW - self.inDryWeight)/(self.inMaxTOW-self.inDryWeight);
                
        "Change from fraction of reserve to aircraft weight"
        weightInitial = weightInitialFrac*(self.maxTOW - self.dryWeight) + \
        self.dryWeight-(self.dryWeight-self.inDryWeight)
        weightFinal = weightFinalFrac*(self.inMaxTOW - self.inDryWeight) + self.inDryWeight;
        
        minLostCombat = 1/(TSFCloiter*60)*self.LDmax*m.log((self.inDryWeight+self.Combat)/self.inDryWeight)
        minLostClimb = 1/(TSFCloiter*60)*self.LDmax*m.log((self.inDryWeight+self.climbFuel)/self.inDryWeight)
        endurance = 1/(TSFCloiter*60)*self.LDmax*m.log((weightInitial)/weightFinal)\
        -minLostCombat - minLostClimb
        
        "Potentially make vectors outputted that make pareto front."
        
        xRange = np.arange(0,intersect+300,.1)  
        yRange = np.arange(1.5,intersect+300,.1)
        
        EgressEQ = [(m.exp(-(i+translateE)*TSFC/(speedMax/5280*self.LDmax))*self.maxTOW-\
                     self.dryWeight)/(self.maxTOW-self.dryWeight) for i in xRange]
        IngressEQ = [(m.exp((j-translateI)*TSFC/(speedMax/5280*self.LDmax))*self.maxTOW-\
                      self.dryWeight)/(self.maxTOW-self.dryWeight) for j in yRange]
        
        return intersect,weightInitialFrac,weightFinalFrac,EgressEQ,IngressEQ,endurance;
    



