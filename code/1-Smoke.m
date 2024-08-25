clear;clc;
%% prepare smoke PM2.5 data
% input smoke PM2.5 dataset from  Childs et al., (2022)
smokePM2pt5 = readtable('Smoke PM25_Childs/smokePM2pt5_predictions_daily_tract_20060101-20201231.csv');
smokePM2pt5 = table2array(smokePM2pt5);

row=find(smokePM2pt5(:,2)>20200000);
smoke_2020 = smokePM2pt5(row,:);
clear("smokePM2pt5");

geoID = unique(smoke_2020(:,1));
geoID = sortrows(geoID,1);
N = length(geoID);
smoke_season = zeros(N,4);

dt = smoke_2020(:,2);
smoke_spring = smoke_2020(find(dt > 20200300 & dt < 20200600),[1,3]); 
smoke_summer = smoke_2020(find(dt > 20200600 & dt < 20200900),[1,3]);
smoke_fall = smoke_2020(find(dt > 20200900 & dt < 20201200),[1,3]);
smoke_winter = smoke_2020(find((dt > 20200100 & dt < 20200300) | (dt > 20201200 & dt < 20210000)),[1,3]);
for i=1:N
    row = find(smoke_spring==geoID(i)); % spring
    smoke_season(i,1) = sum(smoke_spring(row,2),"all")./92;
    row = find(smoke_summer==geoID(i)); % summer
    smoke_season(i,2) = sum(smoke_summer(row,2),"all")./92;
    row = find(smoke_fall==geoID(i)); % fall
    smoke_season(i,3) = sum(smoke_fall(row,2),"all")./91;
    row = find(smoke_winter==geoID(i)); % winter
    smoke_season(i,4) = sum(smoke_winter(row,2),"all")./91;
end

% assume 20% fluctuation
average = smoke_season;
std = average .* 0.20 ./2.58;

mu = log(average.^2 ./ sqrt(std.^2 + average.^2));
sigma = sqrt(log(std.^2 ./ average.^2 + 1));

smoke_rand = zeros(N,4,1000);
for i=1:N
    for j=1:4
        if ~isnan(mu(i,j))
            smoke_rand(i,j,:) = lognrnd(mu(i,j), sigma(i,j), 1000, 1);
        else
            smoke_rand(i,j,:) =0;
        end
    end
end
smoke_season = smoke_rand;

% calculate indoor concentration
load('Finf.dat','-mat');
indoor_season = smoke_season .* Finf;

save('smoke.dat','smoke_season','indoor_season','geoID','-v7.3');



clear;clc;
load('smoke.dat','-mat');
%% export smoke data
% annual average
smoke = squeeze(mean(smoke_season,2));
indoor = squeeze(mean(indoor_season,2));
clear indoor_season smoke_season;

PM = cat(3,smoke,indoor);
PM_mean = squeeze(mean(PM,2));
PM_std = squeeze(std(PM,0,2));

% export smoke data
filepath='Result/smoke/';
if ~exist(filepath, 'dir')
    mkdir(filepath);
end
smokeName = {'smoke';'indoor'};
for i=1:2
    filename = strcat(filepath,smokeName{i,1},'.csv');
    writematrix([geoID, PM_mean(:,i),PM_std(:,i)], filename);
end


