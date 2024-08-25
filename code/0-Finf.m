clear;clc;
raw = readtable('Finf_refH/Finf.xlsx');
%% Obtain Finf data of climate zone for each census tract
% input Finf for climate zone
Finf_mean = table2array(raw(2:5,2:5));% d1-cliamte zone, d2-season
Finf_std = table2array(raw(9:12,2:5));% d1-cliamte zone, d2-season
mu = log((Finf_mean.^2)./sqrt(Finf_std.^2 + Finf_mean.^2));
sigma = sqrt(log((Finf_std.^2 ./ Finf_mean.^2)+1));
Finf_zone =zeros(4,4,1000); % d1-climate zone, d2-season, d3-distribution
rng(1234);
for i=1:4 % climate zone
    for j=1:4 % season
        Finf_zone(i,j,:) = lognrnd(mu(i,j), sigma(i,j), 1000,1);
    end
end

ZoneName = {'Marine'; 'Hot-dry'; 'Cold'; 'Other'};

load("ClimateZone.dat","-mat");
N = length(geoID);
Finf_geosID = zeros(N,4,1000);
zone_geosID = cell(N,1);
for i=1:N
    row = find(strcmpi(ZoneName, ClimateZone{i}));
    Finf_geosID(i,:,:) = Finf_zone(row,:,:);
    zone_geosID{i,1} = ZoneName{row};
end

%% obtain Finf data of built year for each census tract
% input Finf data of built year
Finf_year = table2array(raw(1:8,9));
year = table2array(raw(1:8,8));

% load built year data for geoID
load("BuiltYear.dat","-mat");
Finf_yy = zeros(N,1);
for i = 1:N    
    row = find(year==BuiltYear(i));
    Finf_yy(i,1) = Finf_year(row);
end


%% adjust Finf_climate zone (base), with built year variation (% increase compared to median for each climate zone)
increase = zeros(N,1);
Finf_climate = zeros(N,4,1000);
Finf_adBuilt = zeros(N,4,1000);
for i=1:length(ZoneName)
    row = find(strcmpi(zone_geosID,ZoneName(i)));   
    median_yy = median(Finf_yy(row,1),1);
    increase(row,1) = (Finf_yy(row,1) - median_yy)./median_yy;
    
    Finf_adBuilt(row,:,:) = Finf_geosID(row,:,:) .* (1 + increase(row,1));
end

Finf = Finf_adBuilt;
save('Finf.dat','Finf','geoID','-v7.3');


