*Create county-year-race level dataset from IPUMs data
*Requires gtools

clear all
set more off
global great_migration "/Users/clairenelson/Dropbox/great-outmigration/claire/great_migration"

use "$great_migration/data/usa_00003.dta"
append using "$great_migration/data/usa_00004.dta"

*Population and households
gen black = (race == 2)
gen id = _n
gegen population = count(id), by(stateicp countyicp year)
gegen black_population = total(black), by(stateicp countyicp year)
gen pct_black = black_population/population
gen married = (marst == 1 | marst == 2)
gegen n_married = total(married), by(stateicp countyicp year black) //Include married with spouse present or absent
gen pct_married = n_married/population

*Age demographics
gen under_15 = (age < 15)
gen between_15_44 = (age >= 15 & age <= 44)
gen over_44 = (age > 44)
gen under_15_f = (age < 15 & sex == 2)
gen between_15_44_f = (age >= 15 & age <= 44 & sex == 2)
gen over_44_f = (age > 44 & sex == 2)
gen under_15_m = (age < 15 & sex == 1)
gen between_15_44_m = (age >= 15 & age <= 44 & sex == 1)
gen over_44_m = (age > 44 & sex == 1)

*Occupation variables
gen farmers = (occ1950 == 100 & age >= 15 & age <= 44)
gen farm_owners = (occ1950 == 100 & ownershp == 1 & age >= 15 & age <= 44)
gen farm_renters = (occ1950 == 100 & ownershp == 2 & age >= 15 & age <= 44)
gen farm_laborers = (inlist(occ1950, 820,829) & age >= 15 & age <= 44)
gen mfg_workers = (ind1950>=300 & ind1950<=399 & age >= 15 & age <= 44) //industry code in the 300s
gen nonfarm_workers = (!inlist(occ1950, 100, 123, 810, 820, 830) & age >= 15 & age <= 44)

*Collapse by county-year-race
gcollapse (nunique) households=serial (last) population pct_black pct_married ///
	(sum) under_15 between_15_44 over_44 under_15_f between_15_44_f over_44_f under_15_m ///
	between_15_44_m over_44_m farmers farm_owners farm_renters farm_laborers ///
	mfg_workers nonfarm_workers, by(stateicp countyicp year black)

*Label variables and dataset
la var population "County-Year-Race Population"
la var households "Number of Households"
la var pct_black "Black Percentage of Population"
la var pct_married "Married Percentage of Population"
la var under_15 "Number of People Under 15"
la var between_15_44 "Number of People Between 15 and 44"
la var over_44 "Number of People Over 44"
la var under_15_f "Number of Females Under 15"
la var between_15_44_f "Number of Females Between 15 and 44"
la var over_44_f "Number of Females Over 44"
la var under_15_m "Number of Males Under 15"
la var between_15_44_m "Number of Males Between 15 and 44"
la var over_44_m "Number of Males Over 44"
la var farmers "Number of Farmers, 15-44"
la var farm_owners "Number of Farm Owners, 15-44"
la var farm_renters "Number of Farmers who Rent, 15-44"
la var farm_laborers "Number of Farm Laborers, 15-44"
la var mfg_workers "Number of Manufacturing Workers, 15-44"
la var nonfarm_workers "Number of Nonfarm Workers, 15-44"
la data "County-Year-Race 1900-1940 IPUMs Dataset"

*Save dataset
save "$great_migration/output/ipums_county_year_race.dta", replace

exit

