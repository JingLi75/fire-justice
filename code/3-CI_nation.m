clear;clc;
tic;

load('smoke.dat','-mat'); 
smoke=squeeze(mean(smoke_season,2));
smoke_mean = mean(smoke,2);
indoor = squeeze(mean(indoor_season,2));
indoor_mean = mean(indoor,2);
clear smoke_season indoor_season;

load('CDC_SVI.dat','-mat'); % CDC.dat: c1-geoID, c2-pop, c3-std_pop, c4-c23-SVI (index)

%% calculate CI, nation Rank 
CI_nation = zeros(20,2,1000);%1-SVI,2-smoke & indoor
% calculate CI
for i=1:20
    for j=1:1000
        row = find(~isnan(CDC(:,i+3)) & ~isnan(CDC(:,3)));
        data_valid = [CDC(row,[i+3,2]), smoke(row,j), indoor(row,j)];
        data_sorted = sortrows(data_valid,1);
        temp = data_sorted(:,[2:4]);
        data_cum = cumsum(temp,1) ./ sum(temp,1);
        for k=1:2
            CI_nation(i,k,j) = 1-2.*trapz(data_cum(:,1),data_cum(:,k+1));
        end
    end
end
median_CI = median(CI_nation,3);
p5_CI = prctile(CI_nation,5,3);
p95_CI = prctile(CI_nation,95,3);
CI_nation = cat(3,median_CI,p5_CI,p95_CI);

% export CI data
filepath='Result/CI/';
if ~exist(filepath, 'dir')
    mkdir(filepath);
end
filename = fullfile(filepath,'CI_nation');
smokeName = {'smoke','indoor'};
sheetName = {'median_CI';'p5_CI';'p95_CI'};
for i=1:3       
    xlswrite(filename,index{4:23,1},sheetName{i},'A2');
    xlswrite(filename,smokeName,sheetName{i},'B1:C1');
    xlswrite(filename,CI_nation(:,:,i),sheetName{i},'B2');
end
clear data_cum data_sorted data_valid indoor median_CI p5_CI p95_CI smoke temp row i j k;
%% export data for drawing concentration curve
for i=1:20
    row = find(~isnan(CDC(:,i+3)) & ~isnan(CDC(:,3)));
    data_valid = [CDC(row,[i+3,2]), smoke_mean(row,1), indoor_mean(row,1)];
    data_sorted = sortrows(data_valid,1);
    temp = data_sorted(:,[2:4]);
    data_cum = cumsum(temp,1) ./ sum(temp,1);

    filepath='Result/CCurve_nation/';
    if ~exist(filepath, 'dir')
        mkdir(filepath);
    end
    filename = strcat(char(index{i+3,1}),'.csv');
    csvwrite(fullfile(filepath,filename),data_cum);
end

toc;