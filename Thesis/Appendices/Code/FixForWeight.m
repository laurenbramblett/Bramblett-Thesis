function [weightInitial, weightFinal, eqIngress, eqEgress, intersect, endurance] = FixForWeight(ac)

Altitude = convlength(ac.Altitude,'ft','m');
loiterAlt = convlength(ac.loiterAlt,'ft','m');
[T1,a1,~,~] = atmosisa(Altitude); %Matlab function for temperature (Kelvin) at altitude
[T2,~,~,~] = atmosisa(loiterAlt);
[T3,a3,~,~] = atmosisa(3048);
tempK = convtemp(518.7,'R','K');
theta1 = T1/tempK; %TSFC correction ratio 
theta2 = T2/tempK;
TSFC_cruise = ac.TSFCsl*sqrt(theta1)/3600; %Corrected TSFC
TSFC_loiter = ac.TSFCsl*sqrt(theta2)/3600; 
TSFC_drop = ac.TSFCsl*sqrt(T3/tempK)/3600;
speedMax_cruise = ac.speedMax* convvel(a1,'m/s','ft/s'); %mach to ft/s at altitude

% maxRange = (speedMax_cruise/5280)/(TSFC_cruise)*ac.LDmaxLog*log(ac.maxTOW/ac.dryWeight);
%Fuel Reserve Conversion
percFuel = (ac.eMaxTOW-ac.eDryWeight)*ac.fuelReserve;
solInitialWeight = exp(ac.TimeReserve*(TSFC_cruise*60)/ac.LDmax)*ac.eDryWeight;
percFuel = (percFuel +(solInitialWeight-ac.eDryWeight))/(ac.eMaxTOW-ac.eDryWeight);
%
divider = 5280;
initialReserve = 1-(ac.maxTOW-ac.fuelToCruise)/ac.maxTOW;
translateI = -(log((initialReserve*(ac.maxTOW-ac.dryWeight)+ac.dryWeight)/ac.maxTOW)*...
    speedMax_cruise/5280*ac.LDmaxLog/TSFC_cruise+ac.distToCruise);
translateE = (-(ac.LDmaxLog*speedMax_cruise/5280*log((ac.eDryWeight...
    + ac.eMaxTOW*percFuel-ac.eDryWeight*percFuel)/(ac.eMaxTOW)))/TSFC_cruise);
intersect = (ac.LDmaxLog*speedMax_cruise*log(-(exp(-(TSFC_cruise*divider*...
    translateI)/(2*ac.LDmaxLog*speedMax_cruise))*(exp((TSFC_cruise*divider*...
    translateE)/(2*ac.LDmaxLog*speedMax_cruise))*(4*ac.eMaxTOW^2*ac.maxTOW^2 + ...
    ac.dryWeight^2*ac.eMaxTOW^2*exp((TSFC_cruise*divider*(translateI + ...
    translateE))/(ac.LDmaxLog*speedMax_cruise)) + ac.eDryWeight^2*ac.maxTOW^2*...
    exp((TSFC_cruise*divider*(translateI + translateE))/(ac.LDmaxLog*...
    speedMax_cruise)) - 4*ac.dryWeight*ac.eMaxTOW^2*ac.maxTOW - 4*ac.eDryWeight*...
    ac.eMaxTOW*ac.maxTOW^2 + 4*ac.dryWeight*ac.eDryWeight*ac.eMaxTOW*ac.maxTOW - ...
    2*ac.dryWeight*ac.eDryWeight*ac.eMaxTOW*ac.maxTOW*exp((TSFC_cruise*divider*...
    (translateI + translateE))/(ac.LDmaxLog*speedMax_cruise)))^(1/2) - ...
    ac.dryWeight*ac.eMaxTOW*exp((TSFC_cruise*divider*(translateI + 2*...
    translateE))/(2*ac.LDmaxLog*speedMax_cruise)) + ac.eDryWeight*ac.maxTOW*...
    exp((TSFC_cruise*divider*(translateI + 2*translateE))/(2*...
    ac.LDmaxLog*speedMax_cruise))))/(2*ac.eMaxTOW*(ac.dryWeight - ac.maxTOW))))/(TSFC_cruise*divider);
 

% if ac.Range>intersect
%     endurance ='Wanted range exceeds maximum range\n';
%     fprintf(endurance)
%     eqEgress = 0;
%     eqIngress = 0;
%     weightInitial = 0;
%     weightFinal = 0;
%     return
% end

weightInitial = (exp(-(ac.Range+translateI)*TSFC_cruise/(speedMax_cruise/5280*ac.LDmaxLog))*ac.maxTOW-...
    ac.dryWeight)/(ac.maxTOW-ac.dryWeight);
weightFinal = (exp((ac.Range-translateE)*TSFC_cruise/(speedMax_cruise/5280*ac.LDmaxLog))*...
    ac.eMaxTOW-ac.eDryWeight)/(ac.eMaxTOW-ac.eDryWeight);
%Change from fraction of reserve to aircraft weight
weightInitial = weightInitial*(ac.maxTOW-ac.dryWeight)+ac.dryWeight-(ac.dryWeight-ac.eDryWeight);
weightFinal = weightFinal*(ac.eMaxTOW-ac.eDryWeight)+ac.eDryWeight;

minlostCombat = 1/(TSFC_loiter*60)*(ac.LDmax)*log((ac.eDryWeight+ac.Combat)/ac.eDryWeight);
minlostClimb = 1/(TSFC_loiter*60)*(ac.LDmax)*log((ac.eDryWeight+ac.climbFuel)/ac.eDryWeight);
endurance = 1/(TSFC_loiter*60)*(ac.LDmax)*log((weightInitial)/weightFinal)-...
    minlostCombat-minlostClimb;
% x = 0:.1:(intersect+300);
% y = 1.5:.1:(intersect+300);
% eqEgress = (exp(-(x+translateE)*TSFC_cruise/(speedMax_cruise/5280*ac.LDmaxLog))*ac.maxTOW-...
%     ac.dryWeight)/(ac.maxTOW-ac.dryWeight);
% eqIngress = (exp((y-translateI)*TSFC_cruise/(speedMax_cruise/5280*ac.LDmaxLog))*...
%     ac.maxTOW-ac.dryWeight)/(ac.maxTOW-ac.dryWeight);

eqEgress = 0;
eqIngress = 0;

end