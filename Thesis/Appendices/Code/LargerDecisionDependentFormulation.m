%Data
data = load('c4_AC000');
locales  = xlsread('uscities(1000largest)');
locales = locales([798 119 239 173 10],:);
data.ac.Combat = 0;
data.ac.climbFuel = 0;
m = length(locales)+1;
startLat = 39.9025;
startLong = -84.2218;
totFuel = data.ac.maxTOW - data.ac.dryWeight;

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

constr = [constr data.ac.maxTOW-sum(sum(C.*x(:,:,1)))*data.ac.maxTOW<=F(1)];

for k = 2:m
    constr = [constr (data.ac.maxTOW-sum(F(1:k-1)))*sum(sum(x(:,:,k)))-(sum(sum(C.*x(:,:,k)))*(data.ac.maxTOW-sum(F(1:k-1))))<=F(k)];
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

obj = 500*sum(sum(sum(x)))+sum(F(m-2:m));

%Options
options = sdpsettings('solver','scip','debug','on');
% Solve the problem
sol = optimize(constr,-obj,options);

%% Plot Result
%For each plane if row,col>0 then which = city and plot coordinates using
%plotm.
vectLatLong = plotAircraftPaths3D(value(x),locales,startLat,startLong);

figure()
ax = usamap('ohio');
states = shaperead('usastatelo', 'UseGeoCoords', true,...
  'Selector',...
  {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});

colormap = cbrewer('seq','Purples',8);
faceColors = makesymbolspec('Polygon',...
    {'INDEX', [1 numel(states)], 'FaceColor', ... 
    colormap}); %NOTE - colors are random
geoshow(ax, states, 'DisplayType', 'polygon','SymbolSpec', faceColors)
set(gcf, 'Renderer', 'opengl') % remove grids for contourf and the dashed line in colorbar when saving pdf/eps. in matlab2016a.
hold on

scatterm(startLat,startLong,12,1/255*[228 26 28],'filled')
hold on
scatterm(locales(:,1),locales(:,2),12,1/255*[228 26 28],'filled')
hold on
vectLatLong = [startLat startLong; vectLatLong];

for i = 1:length(vectLatLong)-1
    deltLat = -vectLatLong(i,1)+vectLatLong(i+1,1);
    deltLong = -vectLatLong(i,2)+vectLatLong(i+1,2);
    r = quiverm(vectLatLong(i,1),vectLatLong(i,2),deltLat,deltLong);
    %[1 0.498 0];
    hold on
end
