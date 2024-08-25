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
load('DAC.dat','-mat');
load('pop.dat','-mat'); pop = squeeze(pop(:,1,:));

%% calculate exposure
stateID = readtable('stateID.csv'); stateID = table2array(stateID);
state_geoID = floor(geoID ./1000000000);
exp_us_mean = zeros(1,2,2); % 1-state, 2-nonDAC & DAC,3-smoke & indoor
exp_us_std = zeros(1,2,2);
exp_state_mean = zeros(49,2,2);
exp_state_std = zeros(49,2,2);
for i = 1:2 % 1-smoke; 2-indoor 
    for j = 1:2 % nonDAC & DAC
        row = find(~isnan(pop(:,1)) & DAC(:,2)==j-1);
        temp = PM(row,:,i) .* pop(row,:);
        exp_us = sum(temp,1) ./ sum(pop(row,:),1);
        exp_us_mean(1,j,i) = mean(exp_us,2);
        exp_us_std(1,j,i) = std(exp_us,0,2);
        for k = 1:49 % states
            row = find(~isnan(pop(:,1)) & (DAC(:,2)==j-1) & (state_geoID(:,1)==stateID(k,1)));
            temp = PM(row,:,i) .* pop(row,:);
            exp_state = sum(temp,1) ./ sum(pop(row,:),1);
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
dacName = {'nonDAC', 'DAC'};
fileName = fullfile(filepath, 'exp_DAC');
smokeName = {'smoke';'indoor'};
stateName = cellstr(strcat('state', num2str(stateID)));
for i = 1:2
    xlswrite(fileName, {'Mean'}, smokeName{i,1}, 'A1');
    xlswrite(fileName, {'std'}, smokeName{i,1}, 'E1');

    xlswrite(fileName, dacName, smokeName{i,1}, 'B1');
    xlswrite(fileName, dacName, smokeName{i,1}, 'F1');

    xlswrite(fileName, {'US'}, smokeName{i,1}, 'A2');
    xlswrite(fileName, {'US'}, smokeName{i,1}, 'E2');

    xlswrite(fileName, stateName, smokeName{i,1}, 'A3');
    xlswrite(fileName, stateName, smokeName{i,1}, 'E3');

    xlswrite(fileName, exp_us_mean(:,:,i), smokeName{i,1}, 'B2');
    xlswrite(fileName, exp_us_std(:,:,i), smokeName{i,1}, 'F2');

    xlswrite(fileName, exp_state_mean(:,:,i), smokeName{i,1}, 'B3');
    xlswrite(fileName, exp_state_std(:,:,i), smokeName{i,1}, 'F3');
end
