clear;clc;

geoID = csvread('geoID.csv');
pop = readtable('Census Bureau/ACSDP5Y2019.DP05-Data.csv');
N = length(geoID);

raceName = readtable('Census Bureau/raceID.xls');
raceName = raceName(:,1:3);


pop_E = zeros(height(pop),9);
pop_M = zeros(height(pop),9); % 90% margin of error
for i=1:9
    pop_E(:,i) = pop{:,raceName{i,2}};
    pop_M(:,i) = pop{:,raceName{i,3}};
end
raceName = raceName.raceName;

GEO_ID = cellfun(@(s) str2double(s(end-10:end)), pop.GEO_ID, 'UniformOutput', true);

mu = zeros(N,9);% column 1-Total, 2-Hispanic, 3-White, 4-Black, 5-Native Alaska, 6-Asian, 7-Native Hawaiian, 8-Other, 9-Two or more
moe = zeros(N,9);
for i=1:N
    row = find(GEO_ID == geoID(i));
    mu(i,:) = pop_E(row,:);
    moe(i,:) = pop_M(row,:);
end
sigma = moe./1.645;
pop = zeros(N,9,1000); % 1-geoID, 2-races, 3-distribution
for i=1:N
    for j=1:9
        pop(i,j,:) = normrnd(mu(i,j), sigma(i,j),[1000,1]);
    end
end


pop_native = pop(:,5,:) + pop(:,7,:);
pop_other = pop(:,8,:) + pop(:,9,:);
pop = [pop(:,1:4,:), pop_native, pop(:,6,:), pop_other]; 
save('pop.dat','pop','geoID','-v7.3'); %pop: c1-Total, c2-Hispanic, c3-White, c4-Black, c5-Native = 5-Native Alaska + 7-Native Hawaiian
% c6-Asian, c7-Other = 8-Other + 9-Two or more