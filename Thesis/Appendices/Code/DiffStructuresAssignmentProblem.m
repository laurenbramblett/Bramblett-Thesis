% Initialize data
data1 = load('c4_AC000');
data2 = load('c3_AC000');
data3 = load('c2_AC000');
data4 = load('c1_F15');
locales  = xlsread('uscities(1000largest)');
locales = locales(1:100,:);
data1.ac.Combat = 0; data1.ac.climbFuel = 0;
data2.ac.Combat = 0; data2.ac.climbFuel = 0;
data3.ac.Combat = 0; data3.ac.climbFuel = 0;
data4.ac.Combat = 0; data4.ac.climbFuel = 0;
data(1) = data1; data(2) = data2; data(3) = data3; data(4) = data4;
n = 20;
m = length(locales);

%Parameters
startLat = 39.9025;
startLong = -84.2218;
x = binvar(n,m);
d = zeros(m,1);
E = zeros(n,m);
priority = randi([1 20],1,length(locales));


for j = 1:m
    d(j) = dist2pts(startLat,startLong,locales(j,1),locales(j,2));
    k = 1;
    for i = 1:n
        E(i,j) = findEnduranceGivenRange(data(k).ac,d(j));
        if mod(i,5)==0
            k = k + 1;
        end
    end
end

% Constraints
const = [];

const = [const sum(x,1)<=1];

const = [const sum(x,2)<=1];

obj = sum((E.*x)*priority');

%Options
options = sdpsettings('solver', 'scip');
% Solve the problem
sol = optimize(const,-obj,options);

% Analyze error flags
if sol.problem == 0
 % Extract and display value
else
 sol.info
 yalmiperror(sol.problem)
end

%% Plot map
%For each plane if row,col>0 then which = city and plot coordinates using
%plotm.
vectLatLong = plotAircraftPaths(value(x),locales);
figure()
ax = usamap('conus');
states = shaperead('usastatelo', 'UseGeoCoords', true,...
  'Selector',...
  {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});

colormap = cbrewer('seq','Purples',4);
faceColors = makesymbolspec('Polygon',...
    {'INDEX', [1 numel(states)], 'FaceColor', ... 
    colormap}); 
geoshow(ax, states, 'DisplayType', 'polygon', ...
   'SymbolSpec',faceColors)
set(gcf, 'Renderer', 'opengl') % remove grids for contourf and the dashed line in colorbar when saving pdf/eps. in matlab2016a.
hold on


scatterm(locales(:,1),locales(:,2),3,[1 0 0],'filled')
hold on
for i = 1:5
    plotm([startLat startLong; vectLatLong(i,1) vectLatLong(i,2)],...
        'Color',1/255*[228 26 28])
    hold on
end
for i = 6:10
    plotm([startLat startLong; vectLatLong(i,1) vectLatLong(i,2)],...
        'Color',1/255*[55 126 184])
    hold on
end
for i = 11:15
    plotm([startLat startLong; vectLatLong(i,1) vectLatLong(i,2)],...
        'Color',1/255*[77 175 74])
    hold on
end
for i = 16:20
    plotm([startLat startLong; vectLatLong(i,1) vectLatLong(i,2)],...
        'Color',1/255*[255 127 0])
    hold on
end

h = zeros(4, 1);
h(1) = plot(NaN,NaN,'Color',1/255*[228 26 28],'DisplayName','AC4-000');
h(2) = plot(NaN,NaN,'Color',1/255*[55 126 184],'DisplayName','AC3-000');
h(3) = plot(NaN,NaN,'Color',1/255*[77 175 74],'DisplayName','AC2-000');
h(4) = plot(NaN,NaN,'Color',1/255*[255 127 0],'DisplayName','F15-C');
legend(h,'AC4-000','AC3-000','AC2-000','F-15C')

