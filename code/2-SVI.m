clear;clc;
% prepare CDC justice index
% load SVI data from CDC
CDC=readtable('CDC justice index/SVI_2018_US.csv');
index = readtable('CDC justice index/column of SVI.xlsx');
N = height(CDC);
M = height(index);
CDC_temp=zeros(N,M);
for i = 1:23
    name = string(index{i,1});
    CDC_temp(:,i) = CDC.(name);
end

geoID = csvread('geoID.csv');
N = length(geoID);
CDC = zeros(N,23);
for i=1:N
    row=find(CDC_temp(:,1)==geoID(i));
    if row
        CDC(i,2:end) = CDC_temp(row,2:end);
    else
        CDC(i,2:end) = nan;
    end
end
CDC(:,1) = geoID;
CDC(CDC==-999) = nan; % replace missing data with nan

save('CDC_SVI.dat','CDC','index','-mat'); % CDC.dat: c1-geoID, c2-pop, c3-std_pop, c4-c23-SVI (index)