# wildfire-inequality
72537 census tracts across 49 states in the contiguous US (CONUS)

Datasets (data size & missing value):
wildfire PM2.5 (smoke): 72537
building age: 72243, supplement missing data (318) with county mean (315) or state mean (3).
climate zone: 4, 4 seasons, for 3108 county
CDC/ATSDR SVI 2018: total 72837, but 199 not found in smoke ID; total 700~900 missing value for SVI data


BuiltYear.dat
ClimateZone.dat
Finf.dat: d1-census tract, d2-seasons, d3-distribution
CDC_SVI.dat: c1-geoID, c2-pop, c3-std_pop, c4-c23-SVI (index)
smoke.dat：c1-geoID, c2-season, c3-distribution
pop.dat: % c1-Total, c2-Hispanic, c3-White, c4-Black, c5-Native (Native Alaska & Native Hawaiian), c6-Asian, c7-Other (Other & Two or more).
