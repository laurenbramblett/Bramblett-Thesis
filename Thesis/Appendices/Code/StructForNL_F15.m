% Sample F-15C 
ac.TSFCsl = 1.1590; %Thrust specific fuel consumption per hour at sea level
ac.LDmax = 8.72; %lift over drag max (Maybe LDmaxLog)
%ac.LsqrDmax = 17.4013; %C_L^(1/2)/C_D max
ac.speedMax = .7318; %mach point where C_L^(1/2)/C_D is max
ac.LDmaxLog = 8.32; %L/D where C_L^(1/2)/C_D is max
ac.fuelToCruise = 42738; %a/c weight after climb to cruise
ac.distToCruise = 27.2*1.15; %Miles from base when climbing to cruise
ac.Combat = 688;     
ac.dryWeight = 31262; %No fuel weight of a/c w/ payload
ac.maxTOW = 44710; %Max takeoff weight of a/c
ac.S = 608; %Wing planform area
%% User-Defined Inputs
ac.Range = 459; %Miles
ac.fuelReserve = 0.05; % %left of fuel
ac.TimeReserve = 20; % minutes of endurance available for aircraft
ac.Altitude = 30000; %Feet from sea level
ac.loiterAlt = 10000;
ac.climbFuel = 523; % (Uses fuel burn estimate)

%% Run
[WI,WF,EqI,EqE,intercept,endure] = NLParetoFuncTranslateE(ac); % USED Correction factor of 15 minutes
if endure ~='Wanted range exceeds maximum range\n'
    x = 0:.1:(intercept+300);
    y = 1.5:.1:(intercept+300);
    placement = (WF+WI-2*ac.dryWeight)/(2*(ac.maxTOW-ac.dryWeight));
    plot(y,EqI, x, EqE, [ac.Range ac.Range],...
        [(WF-ac.dryWeight)/(ac.maxTOW-ac.dryWeight) (WI-ac.dryWeight)/(ac.maxTOW-ac.dryWeight)])
    txt = {'Fuel Available', 'for Loiter $\rightarrow$'};
    text(ac.Range,placement,txt,'HorizontalAlignment','right')
    title('Flight Plan Mapping')
    ylabel('Fuel Reserve (Reserve/Total Fuel)')
    xlabel('Range (mi)')
    legend('Egress','Ingress','Endurance Fuel @ Range')
end

%% Pareto Front
xValue = 20:5:intercept-20;
figure('Name', ' Nonlinear Pareto Frontier')
for j = 1:8
    ac.loiterAlt = 5000*j;
    pFront = [];
    for i = 20:5:intercept-20
        ac.Range = i;
        [~,~,~,~,~,endure] = FixForAltChange(ac);
        pFront = [pFront endure];
    end

    plot(xValue,pFront, '-o')
    hold on
end

title('Pareto Frontier for Nonlinear Range vs. Time')
ylabel('Loiter Time (min)')
xlabel('Range (mi)')
legend('5000ft','10000ft','15000ft','20000ft','25000ft','30000ft','35000ft','40000ft')

%% Plot Points (30000ft)
ac.loiterAlt = 30000;
pFront = [];
for i = 20:5:intercept-20
    ac.Range = i;
    [~,~,~,~,~,endure] = FixForAltChange(ac);
    pFront = [pFront endure];
end
figure('Name',' Pareto Front Comparison (Altitude = 30000ft)')
plot(xValue, pFront,'-k.','MarkerSize',7)
hold on
plot([399*1.15 368*1.15 335*1.15 303.5*1.15 239.3*1.15 175.8*1.15 111.9*1.15 47.6*1.15], [10 20 30 40 60 80 100 120],'r*')
title('Pareto Front: Endurance vs. Range at 30000 ft')
ylabel('Loiter Time (min)')
xlabel('Range (mi)')

%% Plot Points (20000ft)
ac.loiterAlt = 20000;
pFront = [];
for i = 20:5:intercept-20
    ac.Range = i;
    [~,~,~,~,~,endure] = FixForAltChange(ac);
    pFront = [pFront endure];
end
figure('Name',' Pareto Front Comparison (Altitude = 20000ft)')
plot(xValue, pFront,'-k.','MarkerSize',7)
hold on
plot([397*1.15 363*1.15 328*1.15 294.1*1.15 225*1.15 157*1.15 88.4*1.15], [10 20 30 40 60 80 100],'r*')
title('Pareto Front: Endurance vs. Range at 20000 ft')
ylabel('Loiter Time (min)')
xlabel('Range (mi)')

%% Plot Points (10000ft)
ac.loiterAlt = 10000;
pFront = [];
for i = 20:5:intercept-20
    ac.Range = i;
    [~,~,~,~,~,endure] = FixForAltChange(ac);
    pFront = [pFront endure];
end
figure('Name',' Pareto Front Comparison (Altitude = 10000ft)')
plot(xValue, pFront,'-k.','MarkerSize',7)
hold on
plot([394*1.15 357*1.15 319*1.15 281.8*1.15 206.4*1.15 132.3*1.15 57.5*1.15], [10 20 30 40 60 80 100],'r*')
title('Pareto Front: Endurance vs. Range at 10000 ft')
ylabel('Loiter Time (min)')
xlabel('Range (mi)')
hold off