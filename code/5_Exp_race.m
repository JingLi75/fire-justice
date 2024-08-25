clear;clc;

%% load smoke data
load('smoke.dat','-mat');
% annual average
smoke = squeeze(mean(smoke_season,2));
indoor = squeeze(mean(indoor_season,2));
clear indoor_season smoke_season;
PM = cat(3, smoke, indoor);
clear smoke indoor;

%% load pop data: total & race
load('pop.dat','-mat');
% c1-Total, c2-Hispanic, c3-White, c4-Black, c5-Native (Native Alaska & Native Hawaiian), c6-Asian, c7-Other (Other & Two or more).

%% calculate exposure
stateID = readtable('stateID.csv'); stateID = table2array(stateID);
state_geoID = floor(geoID ./1000000000);
exp_us_mean = zeros(1,7,2); % 1-state, 2-races,3-smoke & indoor
exp_us_std = zeros(1,7,2);
exp_state_mean = zeros(49,7,2);
exp_state_std = zeros(49,7,2);
for i = 1:2 % 1-smoke; 2-indoor 
    for j = 1:7 % pop of total and 6 races
        row = find(~isnan(pop(:,j,1)));
        temp = PM(row,:,i) .* squeeze(pop(row,j,:));
        exp_us = sum(temp(:,:),1) ./ sum(squeeze(pop(row,j,:)),1);
        exp_us_mean(1,j,i) = mean(exp_us,2);
        exp_us_std(1,j,i) = std(exp_us,0,2);
        for k = 1:49 % states
            row = find(~isnan(pop(:,j,1)) & state_geoID(:,1)==stateID(k,1));
            temp = PM(row,:,i) .* squeeze(pop(row,j,:));
            exp_state = sum(temp,1) ./ sum(squeeze(pop(row,j,:)),1);
            exp_state_mean(k,j,i) = mean(exp_state,2);
            exp_state_std(k,j,i) = std(exp_state,0,2);
        end
    end
end
clear exp_state exp_us PM pop row state_geoID temp i j k ans;

%% export exposure data 
filepath='Result/exposure/';
if ~exist(filepath, 'dir')
    mkdir(filepath);
end
raceName = {'Total'; 'Hispanic'; 'White'; 'Black'; 'Native'; 'Asian'; 'Other'};
fileName = fullfile(filepath, 'exp_race');
smokeName = {'smoke';'indoor'};
stateName = cellstr(strcat('state', num2str(stateID)));
for i = 1:2
    xlswrite(fileName, {'Mean'}, smokeName{i,1}, 'A1');
    xlswrite(fileName, {'std'}, smokeName{i,1}, 'J1');

    xlswrite(fileName, raceName', smokeName{i,1}, 'B1');
    xlswrite(fileName, raceName', smokeName{i,1}, 'K1');

    xlswrite(fileName, {'US'}, smokeName{i,1}, 'A2');
    xlswrite(fileName, {'US'}, smokeName{i,1}, 'J2');

    xlswrite(fileName, stateName, smokeName{i,1}, 'A3');
    xlswrite(fileName, stateName, smokeName{i,1}, 'J3');

    xlswrite(fileName, exp_us_mean(:,:,i), smokeName{i,1}, 'B2');
    xlswrite(fileName, exp_us_std(:,:,i), smokeName{i,1}, 'K2');

    xlswrite(fileName, exp_state_mean(:,:,i), smokeName{i,1}, 'B3');
    xlswrite(fileName, exp_state_std(:,:,i), smokeName{i,1}, 'K3');
end
