clear;clc;

file=dir('Finf_refH/Built Year Tract/*.csv');
BuiltYear=[];
for i=1:length(file)
    filename=strcat('Finf_refH/Built Year Tract/', file(i).name);
    data_tempt=csvread(filename,1,0);
    BuiltYear=[BuiltYear; data_tempt];
end

%% supplement missing data (318) with county mean (315) or state mean (3)
% calculate county average
CountyID = floor(BuiltYear(:,1)./1000000);
U_CountyID = unique(CountyID);
N = length(U_CountyID);
BuiltYear_county = [];
for i=1:N
    year_temp = BuiltYear(CountyID(:,1)==U_CountyID(i),2);
    BuiltYear_county = [BuiltYear_county; mean(year_temp,1)];
end

% calculate state average
StateID = floor(BuiltYear(:,1)./1000000000);
U_StateID = unique(StateID);
N = length(U_StateID);
BuiltYear_state = [];
for i=1:N
    year_temp = BuiltYear(StateID(:,1)==U_StateID(i),2);
    BuiltYear_state = [BuiltYear_state; mean(year_temp,1)];
end

% supplement missing data
geoID = csvread('geoID.csv');
geo_countyID = floor(geoID(:,1)./1000000);
geo_stateID = floor(geoID(:,1)./1000000000);

N = length(geoID);
BuiltYear_full = [];
for i=1:N
    row = find(BuiltYear(:,1)==geoID(i));
    row_county = find(U_CountyID(:,1)==geo_countyID(i));
    row_state = find(U_StateID(:,1)==geo_stateID(i));
    if row        
        BuiltYear_full(i,1) = BuiltYear(row,2);
    elseif row_county
        BuiltYear_full(i,1)=BuiltYear_county(row_county,1);
    else
        BuiltYear_full(i,1)=BuiltYear_state(row_state,1);
    end
end


% substitue continue built year with 8 catagory built years (1940, 1950...2010)
year = [1940:10:2010]';
N = length(BuiltYear_full);
BuiltYear_cat = zeros(N,1);
for i=1:length(year)
    yy=year(i);
    for j=1:N
        if BuiltYear_full(j) <= yy+5 & BuiltYear_full(j) > yy-5;
            BuiltYear_cat(j) =  yy;
        elseif BuiltYear_full(j) <= 1945
            BuiltYear_cat(j) =  1940;
        elseif BuiltYear_full(j) > 2010
            BuiltYear_cat(j) =  2010;
        end
    end
end

BuiltYear = BuiltYear_cat;
save('BuiltYear.dat','BuiltYear','geoID','-mat') % d1-Geos_ID, d2-builtyear middle year


