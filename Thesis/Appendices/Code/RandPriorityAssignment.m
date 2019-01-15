data = load('c4_AC000');
locales  = xlsread('uscities(1000largest)');
locales = locales(1:100,:);
data.ac.Combat = 0;
data.ac.climbFuel = 0;
n = 20;
m = length(locales);
startLat = 39.9025;
startLong = -84.2218;
x = binvar(n,m);
d = zeros(m,1);
E = zeros(n,m);
priority = randi([1 20],1,length(locales));

for j = 1:m
    d(j) = dist2pts(startLat,startLong,locales(j,1),locales(j,2));
    for i = 1:n
        E(i,j) = findEnduranceGivenRange(data.ac,d(j));
        if E(i,j) <0
            E(i,j) = 0;
        end
    end
end

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
    colormap}); %NOTE - colors are random
geoshow(ax, states, 'DisplayType', 'polygon', ...
   'SymbolSpec', faceColors)
set(gcf, 'Renderer', 'opengl') % remove grids for contourf and the dashed line in colorbar when saving pdf/eps. in matlab2016a.
hold on

scatterm(locales(:,1),locales(:,2),3,[1 0 0],'filled')
hold on
for i = 1:length(vectLatLong)
plotm([startLat startLong; vectLatLong(i,1) vectLatLong(i,2)],'Color',1/255*[255 127 0])
hold on
end



