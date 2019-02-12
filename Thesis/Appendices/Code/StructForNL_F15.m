% Sample F-15C 
ac.TSFCsl = 1.1590; %Thrust specific fuel consumption per hour at sea level
ac.LDmax = 8.52; %lift over drag max (Maybe LDmaxLog)
%ac.LsqrDmax = 17.4013; %C_L^(1/2)/C_D max
ac.speedMax = .7318; %mach point where C_L^(1/2)/C_D is max
ac.LDmaxLog = 8.52; %L/D where C_L^(1/2)/C_D is max
ac.fuelToCruise = 42738; %a/c weight after climb to cruise
ac.distToCruise = 27.2*1.15; %Miles from base when climbing to cruise
ac.Combat = 688;     
ac.dryWeight = 31262; %No fuel weight of a/c w/ payload
ac.maxTOW = 44710; %Max takeoff weight of a/c
ac.eDryWeight = 30645;
ac.eMaxTOW = 44093;
ac.S = 608; %Wing planform area
%% User-Defined Inputs
ac.Range = 10; %Miles
ac.fuelReserve = 0.05; % %left of fuel
ac.TimeReserve = 20; % minutes of endurance available for aircraft
ac.Altitude = 30000; %Feet from sea level
ac.loiterAlt = 30000;
ac.climbFuel = 523; % (Uses fuel burn estimate)


%% Pareto Front
xValue = 20:5:intercept-20;
figure('Name', ' Nonlinear Pareto Frontier')
for j = 1:8
    ac.loiterAlt = 5000*j;
    pFront = [];
    for i = 20:5:intercept-20
        ac.Range = i;
        [~,~,~,~,~,endure] = FixForWeight(ac);
        pFront = [pFront endure];
    end

    plot(xValue,pFront)
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
    [~,~,~,~,~,endure] = FixForWeight(ac);
    pFront = [pFront endure];
end
figure('Name',' Pareto Front Comparison (Altitude = 30000ft)')
plot(xValue, pFront,'MarkerSize',7)
hold on
plot([399*1.15 368*1.15 335*1.15 303.5*1.15 239.3*1.15 175.8*1.15 111.9*1.15 47.6*1.15], [10 20 30 40 60 80 100 120],'*')
ylabel('Loiter Time (min)')
xlabel('Range (mi)')
legend('Tradeoff Frontier','Original Model')
hold off

% Difference between observations
distVect = [399*1.15 368*1.15 335*1.15 303.5*1.15 239.3*1.15 175.8*1.15 111.9*1.15 47.6*1.15];
endureVect = [10 20 30 40 60 80 100 120];
avgDiff = 0;
maxVal = 0;
for i = 1:length(distVect)
    ac.Range = distVect(i);
    [~,~,~,~,~,endureVal] = FixForWeight(ac);
    avgDiff = avgDiff + abs(endureVal-endureVect(i));
    if abs(endureVal-endureVect(i))>maxVal
        maxVal = abs(endureVal-endureVect(i));
    end
end
avgDiff = avgDiff/length(distVect);

%% Plot Points (20000ft)
ac.loiterAlt = 20000;
pFront = [];
for i = 20:5:intercept-20
    ac.Range = i;
    [~,~,~,~,~,endure] = FixForWeight(ac);
    pFront = [pFront endure];
end
figure('Name',' Pareto Front Comparison (Altitude = 20000ft)')
plot(xValue, pFront,'MarkerSize',7)
hold on
plot([397*1.15 363*1.15 328*1.15 294.1*1.15 225*1.15 157*1.15 88.4*1.15], [10 20 30 40 60 80 100],'*')
ylabel('Loiter Time (min)')
xlabel('Range (mi)')
legend('Tradeoff Frontier','Original Model')
hold off

% Difference between observations
distVect = [397*1.15 363*1.15 328*1.15 294.1*1.15 225*1.15 157*1.15 88.4*1.15];
endureVect = [10 20 30 40 60 80 100];
avgDiff = 0;
maxVal = 0;
for i = 1:length(distVect)
    ac.Range = distVect(i);
    [~,~,~,~,~,endureVal] = FixForWeight(ac);
    avgDiff = avgDiff + abs(endureVal-endureVect(i));
    if abs(endureVal-endureVect(i))>maxVal
        maxVal = abs(endureVal-endureVect(i));
    end
end
avgDiff = avgDiff/length(distVect);

%% Plot Points (10000ft)
ac.loiterAlt = 10000;
pFront = [];
for i = 20:5:intercept-20
    ac.Range = i;
    [~,~,~,~,~,endure] = FixForWeight(ac);
    pFront = [pFront endure];
end
figure('Name',' Pareto Front Comparison (Altitude = 10000ft)')
plot(xValue, pFront,'MarkerSize',7)
hold on
plot([394*1.15 357*1.15 319*1.15 281.8*1.15 206.4*1.15 132.3*1.15 57.5*1.15], [10 20 30 40 60 80 100],'*')
ylabel('Loiter Time (min)')
xlabel('Range (mi)')
legend('Tradeoff Frontier','Original Model')
hold off

% Difference between observations
distVect = [394*1.15 357*1.15 319*1.15 281.8*1.15 206.4*1.15 132.3*1.15 57.5*1.15];
endureVect = [10 20 30 40 60 80 100];
avgDiff = 0;
maxVal = 0;
for i = 1:length(distVect)
    ac.Range = distVect(i);
    [~,~,~,~,~,endureVal] = FixForWeight(ac);
    avgDiff = avgDiff + abs(endureVal-endureVect(i));
    if abs(endureVal-endureVect(i))>maxVal
        maxVal = abs(endureVal-endureVect(i));
    end
end
avgDiff = avgDiff/length(distVect);