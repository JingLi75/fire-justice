clear;clc;

geoID = csvread('geoID.csv');
DAC = readtable('White house_dac/1.0-communities - Dac and non Dac.xlsx');
DAC = table2array(DAC);
N=length(geoID);
DAC_geoID = zeros(N,2);
for i=1:N
    row=find(DAC(:,1)==geoID(i,1));
    if row
        DAC_geoID(i,2) = DAC(row,2);
    else
        DAC_geoID(i,2) = nan;
    end
end
DAC_geoID(:,1) = geoID;
DAC = DAC_geoID; clear DAC_geoID;
save('DAC.dat','DAC','-mat');

