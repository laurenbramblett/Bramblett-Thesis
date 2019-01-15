%Data
data = load('c4_AC000');
locales  = xlsread('uscities(1000largest)');
locales = locales([169 798 173 10 119],:);
data.ac.Combat = 0;
data.ac.climbFuel = 0;
m = length(locales)+1;
startLat = 39.7589;
startLong = -84.1916;
totFuel = data.ac.maxTOW - data.ac.dryWeight;
fmin = 3000;


%Decision Variables
x = binvar(m,m,m,'full');
F = sdpvar(m,1,'full');

%Initialize
allLatLong = zeros(m,2);
allLatLong(2:m,:) = locales;
allLatLong(1,:) = [startLat startLong];
Altitude = convlength(data.ac.Altitude,'ft','m');
[T1,a1,~,~] = atmosisa(Altitude); %Matlab function for temperature (Kelvin) at altitude
tempK = convtemp(518.7,'R','K');
theta1 = T1/tempK; %TSFC correction ratio 
TSFC_cruise = data.ac.TSFCsl*sqrt(theta1)/3600; %Corrected TSFC
speedMax_cruise = data.ac.speedMax* convvel(a1,'m/s','ft/s')/5280; %mach to mi/s at altitude

D = zeros(m,m); %Distance matrix
C = zeros(m,m); %Fuel efficiency factor
for i = 1:m
    for j = 1:m
        D(i,j) = dist2pts(allLatLong(i,1),allLatLong(i,2),allLatLong(j,1),allLatLong(j,2));
        C(i,j) = exp(-D(i,j)/speedMax_cruise*TSFC_cruise/data.ac.LDmax);
    end
end

%Constraints

constr = [];

constr = [constr sum(x(1,2:m,1)) == 1];

for k = 2:m
    constr = [constr sum(x(1,:,k)) == 0];
end

for k = 1:m-1
    for i = 2:m
        constr = [constr sum(x(i,:,k+1))-sum(x(:,i,k)) == 0];
    end
end

constr = [constr sum(sum(x(:,1,:))) == 1];

constr = [constr data.ac.maxTOW-sum(sum(C.*x(:,:,1)))*data.ac.maxTOW-F(1)<=-fmin];

for k = 2:m
    constr = [constr (data.ac.maxTOW-sum(F(1:k-1)))*sum(sum(x(:,:,k)))-...
        (sum(sum(C.*x(:,:,k)))*(data.ac.maxTOW-sum(F(1:k-1))))-F(k)<=-fmin*sum(sum(x(:,:,k)))];
end

for k = 1:m
    constr = [constr sum(sum(x(:,:,k)))<=1];
end

for k = 1:m
    for i = 1:m
        constr = [constr x(i,i,k) == 0];
    end
end

for j = 1:m
    constr = [constr sum(sum(x(:,j,:)))<=1]; %Okay
end

constr = [constr sum(F)<=totFuel];

obj = 5000*sum(sum(sum(x)))-sum(F);

%Options
options = sdpsettings('solver','scip','debug','on');
% Solve the problem
sol = optimize(constr,-obj,options);

%% Plot Result
%For each plane if row,col>0 then which = city and plot coordinates using
%plotm.
vectLatLong = plotAircraftPaths3D(value(x),locales,startLat,startLong);

figure()
ax = usamap('Ohio');
states = shaperead('usastatelo', 'UseGeoCoords', true,...
  'Selector',...
  {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
names = {states.Name};
ohioindex = strcmp('Ohio',names);
pennindex = strcmp('Pennsylvania',names);

colormap = cbrewer('seq','Purples',8);
faceColors = makesymbolspec('Polygon',...
    {'INDEX', [1 50], 'FaceColor', ... 
    colormap});
stateColor = 1/255*[239 247 241];
pennColor = 1/255*[218 218 235];
geoshow(ax, states, 'DisplayType', 'polygon','SymbolSpec', faceColors)
geoshow(ax, states(ohioindex),  'FaceColor', stateColor)
geoshow(ax, states(pennindex),  'FaceColor', pennColor)
set(gcf, 'Renderer', 'opengl') % remove grids for contourf and the dashed line in colorbar when saving pdf/eps. in matlab2016a.
hold on

vectLatLong = [startLat startLong; vectLatLong];

plotm(vectLatLong,'Color',[0 0 0])

scatterm(startLat,startLong,20,1/255*[49 163 84],'filled')
hold on
scatterm(locales(:,1),locales(:,2),20,1/255*[178 24 43],'filled')
hold on
