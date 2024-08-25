clear;
clc;

ClimateZone = readtable('Finf_refH/climate_zones - us.csv');
columnNames = ClimateZone.Properties.VariableNames;

STCNTY = [ClimateZone.STCNTY];
BAClimateZone = [ClimateZone.BAClimateZone];

Name_Finf = {'Marine'; 'Hot-dry'; 'Cold'; 'Other'};
N = length(STCNTY);
ZoneName = cell(N,1);
for i=1:N
    row=find(strcmpi(Name_Finf(:,1), BAClimateZone{i,1}));
    if ~isempty(row)
        ZoneName{i,1}=Name_Finf{row,1};
    else
        ZoneName{i,1}=Name_Finf{4,1};
    end
end


geoID = csvread('geoID.csv');
geoID_STCNTY = floor(geoID./1000000);
N = length(geoID);
geoID_ZoneName=cell(N,1);
for i=1:N
    row = find(STCNTY==geoID_STCNTY(i));
    geoID_ZoneName{i}=ZoneName{row};
end

ClimateZone=geoID_ZoneName;

save('ClimateZone.dat','geoID', 'ClimateZone','-mat');
