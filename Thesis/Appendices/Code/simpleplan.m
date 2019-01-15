function endurance = simpleplan(TSFCsl,LDmax, Range, fuelToCruise, distToCruise, maxRange, dryWeight, maxTOW, fuelReserve, Altitude)
%range:       user defined range to calculate endurance (miles)
%fuelToCruise:  weight after takeoff, warmup, and climb to cruise (lbs)
%distToCruise:  distance traveled after takeoff and climb to cruise
%maxRange:    total range for fuel left after climb to cruise (change to
%             calculate by itself after a while) (in miles)
%dryWeight:   empty weight of a/c
%maxTOW:      max take off weight of aircraft
%fuelReserve: user defined fuel reserve left in aircraft for return
%             (percent)
%altitude:    flight plan altitude (in meters)
%TSFCsl:      thrust specific fuel consumption for aircraft at sea level
%endurance:   length of time for loiter (in hours)
%-------------------------------------------------------------------------
%Example: T-37 Cessna at 20000ft traveling to 300 miles
%endure = simpleplan(.9,14.8,300,5698,1.5,1391.2,3869,6598,0.2,20000)
%Output: endure = 2.6378 hours
initFuelPerc = fuelToCruise/maxTOW; %Fuel reserve calculation
slopeEgress = (0-initFuelPerc)/(maxRange-distToCruise);
slopeIngress = -slopeEgress;
bEgress = slopeEgress*distToCruise + initFuelPerc; %Intercept for egress slope
fuelAvail = maxTOW - dryWeight;
Altitude = convlength(Altitude,'ft','m');

%Intersection point
inter = (bEgress-fuelReserve)/(2*slopeIngress);

if Range>inter
    endurance ='Wanted range exceeds maximum range';
    print(endurance)
    return
end

weightInitial = (slopeEgress*Range + bEgress)*fuelAvail + dryWeight;
weightFinal = (slopeIngress*Range + fuelReserve)*fuelAvail + dryWeight;

[T,~,~,~] = atmosisa(Altitude); %Matlab function for temperature (Kelvin) at altitude
tempK = convtemp(518.7,'R','K');
theta = T/tempK; %TSFC correction ratio 

TSFC = TSFCsl*sqrt(theta); %Corrected TSFC

endurance = 1/TSFC*(LDmax)*log(weightInitial/weightFinal);
x = 0:.1:(inter+300);
y = 1.5:.1:(inter+300);
eqEgress = slopeEgress*y+bEgress;
eqIngress = slopeIngress*x+fuelReserve;
placement = (weightFinal+weightInitial-2*dryWeight)/(2*fuelAvail);
plot(y,eqEgress, x, eqIngress, [Range Range],...
    [(weightFinal-dryWeight)/fuelAvail (weightInitial-dryWeight)/fuelAvail],...
    [0 distToCruise],[1 (maxTOW-fuelToCruise)/fuelAvail])
txt = {'Fuel Available', 'for Loiter \rightarrow'};
text(Range,placement,txt,'HorizontalAlignment','right')
title('Flight Plan Mapping')
ylabel('Fuel Reserve (Reserve/Total Fuel)')
xlabel('Range (mi)')
legend('Egress','Ingress','Endurance Fuel @ Range')

end