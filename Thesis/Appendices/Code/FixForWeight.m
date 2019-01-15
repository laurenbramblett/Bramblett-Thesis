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
percFuel = (ac.inMaxTOW-ac.inDryWeight)*ac.fuelReserve;
solInitialWeight = exp(ac.TimeReserve*(TSFC_cruise*60)/ac.LDmax)*ac.inDryWeight;
percFuel = (percFuel +(solInitialWeight-ac.inDryWeight))/(ac.inMaxTOW-ac.inDryWeight);
%
divider = 5280;
initialReserve = 1-(ac.maxTOW-ac.fuelToCruise)/ac.maxTOW;
translateE = -(log((initialReserve*(ac.maxTOW-ac.dryWeight)+ac.dryWeight)/ac.maxTOW)*...
    speedMax_cruise/5280*ac.LDmaxLog/TSFC_cruise+ac.distToCruise);
translateI = (-(ac.LDmaxLog*speedMax_cruise/5280*log((ac.inDryWeight...
    + ac.inMaxTOW*percFuel-ac.inDryWeight*percFuel)/(ac.inMaxTOW)))/TSFC_cruise);
intersect = (ac.LDmaxLog*speedMax_cruise*log(-(exp(-(TSFC_cruise*divider*...
    translateE)/(2*ac.LDmaxLog*speedMax_cruise))*(exp((TSFC_cruise*divider*...
    translateI)/(2*ac.LDmaxLog*speedMax_cruise))*(4*ac.inMaxTOW^2*ac.maxTOW^2 + ...
    ac.dryWeight^2*ac.inMaxTOW^2*exp((TSFC_cruise*divider*(translateE + ...
    translateI))/(ac.LDmaxLog*speedMax_cruise)) + ac.inDryWeight^2*ac.maxTOW^2*...
    exp((TSFC_cruise*divider*(translateE + translateI))/(ac.LDmaxLog*...
    speedMax_cruise)) - 4*ac.dryWeight*ac.inMaxTOW^2*ac.maxTOW - 4*ac.inDryWeight*...
    ac.inMaxTOW*ac.maxTOW^2 + 4*ac.dryWeight*ac.inDryWeight*ac.inMaxTOW*ac.maxTOW - ...
    2*ac.dryWeight*ac.inDryWeight*ac.inMaxTOW*ac.maxTOW*exp((TSFC_cruise*divider*...
    (translateE + translateI))/(ac.LDmaxLog*speedMax_cruise)))^(1/2) - ...
    ac.dryWeight*ac.inMaxTOW*exp((TSFC_cruise*divider*(translateE + 2*...
    translateI))/(2*ac.LDmaxLog*speedMax_cruise)) + ac.inDryWeight*ac.maxTOW*...
    exp((TSFC_cruise*divider*(translateE + 2*translateI))/(2*...
    ac.LDmaxLog*speedMax_cruise))))/(2*ac.inMaxTOW*(ac.dryWeight - ac.maxTOW))))/(TSFC_cruise*divider);
 

% if ac.Range>intersect
%     endurance ='Wanted range exceeds maximum range\n';
%     fprintf(endurance)
%     eqEgress = 0;
%     eqIngress = 0;
%     weightInitial = 0;
%     weightFinal = 0;
%     return
% end

weightInitial = (exp(-(ac.Range+translateE)*TSFC_cruise/(speedMax_cruise/5280*ac.LDmaxLog))*ac.maxTOW-...
    ac.dryWeight)/(ac.maxTOW-ac.dryWeight);
weightFinal = (exp((ac.Range-translateI)*TSFC_cruise/(speedMax_cruise/5280*ac.LDmaxLog))*...
    ac.inMaxTOW-ac.inDryWeight)/(ac.inMaxTOW-ac.inDryWeight);
%Change from fraction of reserve to aircraft weight
weightInitial = weightInitial*(ac.maxTOW-ac.dryWeight)+ac.dryWeight-(ac.dryWeight-ac.inDryWeight);
weightFinal = weightFinal*(ac.inMaxTOW-ac.inDryWeight)+ac.inDryWeight;

minlostCombat = 1/(TSFC_loiter*60)*(ac.LDmax)*log((ac.inDryWeight+ac.Combat)/ac.inDryWeight);
minlostClimb = 1/(TSFC_loiter*60)*(ac.LDmax)*log((ac.inDryWeight+ac.climbFuel)/ac.inDryWeight);
endurance = 1/(TSFC_loiter*60)*(ac.LDmax)*log((weightInitial)/weightFinal)-...
    minlostCombat-minlostClimb;
x = 0:.1:(intersect+300);
y = 1.5:.1:(intersect+300);
eqEgress = (exp(-(x+translateE)*TSFC_cruise/(speedMax_cruise/5280*ac.LDmaxLog))*ac.maxTOW-...
    ac.dryWeight)/(ac.maxTOW-ac.dryWeight);
eqIngress = (exp((y-translateI)*TSFC_cruise/(speedMax_cruise/5280*ac.LDmaxLog))*...
    ac.maxTOW-ac.dryWeight)/(ac.maxTOW-ac.dryWeight);

end