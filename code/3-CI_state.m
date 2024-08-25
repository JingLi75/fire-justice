clear;clc;
tic;

load('smoke.dat','-mat'); 
smoke_all=squeeze(mean(smoke_season,2));
smoke_mean_all = mean(smoke_all,2);
indoor_all = squeeze(mean(indoor_season,2));
indoor_mean_all = mean(indoor_all,2);
clear smoke_season indoor_season;

load('CDC_SVI.dat','-mat'); % CDC.dat: c1-geoID, c2-pop, c3-std_pop, c4-c23-SVI (index)
CDC_all = CDC; clear CDC;
%% calculate CI, state Rank 
stateID = floor(geoID./1000000000);
stateName = unique(stateID);
CI_state = zeros(49,20,2,1000);% d1-state, d2-SVI,d3-smoke & indoor, d4-distribution
for s=1:49
    row = find(stateID==stateName(s));
    CDC = CDC_all(row,:,:);
    smoke = smoke_all(row,:);
    indoor = indoor_all(row,:);
    for i=1:20
        for j=1:1000
            row = find(~isnan(CDC(:,i+3)) & ~isnan(CDC(:,3)));
            data_valid = [CDC(row,[i+3,2]), smoke(row,j), indoor(row,j)];
            data_sorted = sortrows(data_valid,1);
            temp = data_sorted(:,[2:4]);
            data_cum = cumsum(temp,1) ./ sum(temp,1);
            for k=1:2
                CI_state(s,i,k,j) = 1-2.*trapz(data_cum(:,1),data_cum(:,k+1));
            end
        end
    end
end
median_CI = median(CI_state,4);
p5_CI = prctile(CI_state,5,4);
p95_CI = prctile(CI_state,95,4);
CI_state = cat(4,median_CI,p5_CI,p95_CI);

% export CI data
filepath='Result/CI/';
if ~exist(filepath, 'dir')
    mkdir(filepath);
end
filename = fullfile(filepath,'CI_state');
smokeName = {'smoke','indoor'};
sheetName = {'median_CI';'p5_CI';'p95_CI'};
for i=1:3       
    xlswrite(filename,{'smoke'},sheetName{i},'A1');
    xlswrite(filename,{'state'},sheetName{i},'A2');
    xlswrite(filename,stateName,sheetName{i},'A3');
    xlswrite(filename,index{4:23,1}',sheetName{i},'B2');
    xlswrite(filename,CI_state(:,:,1,i),sheetName{i},'B3');

    xlswrite(filename,{'indoor'},sheetName{i},'W1');
    xlswrite(filename,{'state'},sheetName{i},'W2');
    xlswrite(filename,stateName,sheetName{i},'W3');
    xlswrite(filename,index{4:23,1}',sheetName{i},'X2');
    xlswrite(filename,CI_state(:,:,2,i),sheetName{i},'X3');
end
clear CDC data_cum data_sorted data_valid median_CI p5_CI p95_CI temp row i j k CI_state;
%% export data for drawing concentration curve
for s=1:49
    row = find(stateID==stateName(s));
    CDC = CDC_all(row,:,:);
    smoke_mean = smoke_mean_all(row,:);
    indoor_mean = indoor_mean_all(row,:);
    filepath=strcat('Result/CCurve_state/', num2str(stateName(s)),'/');
    if ~exist(filepath, 'dir')
        mkdir(filepath);
    end
    for i=1:20
        row = find(~isnan(CDC(:,i+3)) & ~isnan(CDC(:,3)));
        data_valid = [CDC(row,[i+3,2]), smoke_mean(row,1), indoor_mean(row,1)];
        data_sorted = sortrows(data_valid,1);
        temp = data_sorted(:,[2:4]);
        data_cum = cumsum(temp,1) ./ sum(temp,1); 
        filename = strcat(char(index{i+3,1}),'.csv');
        csvwrite(fullfile(filepath,filename),data_cum);
    end
end

toc;