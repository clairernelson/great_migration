*Create county level IPUMS dataset with occupation shares

clear all
set more off
global great_migration "/Users/clairenelson/Dropbox/great-outmigration/claire/great_migration"

use "$great_migration/output/ipums_county_year_race"

gen black_population = pct_black * population
gen white_population = population - black_population

*Calculate average wage by race
gegen incwage_bl = total(incwage*(black == 1)), by(stateicp countyicp year)
gegen incwage_wh = total(incwage*(black == 0)), by(stateicp countyicp year)
gen avg_wage_bl = incwage_bl / black_population
gen avg_wage_wh = incwage_wh / white_population

*Calculate share of people that are agricultural/manufacutring workers
gegen ag_workers_bl = total(ag_workers*(black==1)), by(stateicp countyicp year)
gegen ag_workers_wh = total(ag_workers*(black==0)), by(stateicp countyicp year)
gegen mfg_workers_bl = total(mfg_workers*(black==1)), by(stateicp countyicp year)
gegen mfg_workers_wh = total(mfg_workers*(black==0)), by(stateicp countyicp year)	
gen share_ag_bl = ag_workers_bl / black_population
gen share_ag_wh = ag_workers_wh / white_population
gen share_mfg_bl = mfg_workers_bl / black_population
gen share_mfg_wh = mfg_workers_wh / white_population

*Calculate share of Black/white farmers that are tenants/owners/laborers
gegen farmers_bl = total(farmers*(black==1)), by(stateicp countyicp year)
gegen farmers_wh = total(farmers*(black==0)), by(stateicp countyicp year)
gegen farm_renters_bl = total(farm_renters*(black==1)), by(stateicp countyicp year)
gegen farm_renters_wh = total(farm_renters*(black==0)), by(stateicp countyicp year)
gegen farm_owners_bl = total(farm_owners*(black==1)), by(stateicp countyicp year)
gegen farm_owners_wh = total(farm_owners*(black==0)), by(stateicp countyicp year)
gegen farm_laborers_bl = total(farm_laborers*(black==1)), by(stateicp countyicp year)
gegen farm_laborers_wh = total(farm_laborers*(black==0)), by(stateicp countyicp year)
gen share_renters_bl = farm_renters_bl / farmers_bl //Share of farmers that rent by race
gen share_renters_wh = farm_renters_wh / farmers_wh
gen share_ag_renters_bl = farm_renters_bl / ag_workers_bl //Share ag workers that are farmer-renters by race
gen share_ag_renters_wh = farm_renters_wh / ag_workers_wh
gen share_owners_bl = farm_owners_bl / ag_workers_bl //Share ag workers that are farmer-owners by race
gen share_owners_wh = farm_owners_wh / ag_workers_wh
gen share_laborers_bl = farm_laborers_bl / ag_workers_bl //Share ag workers that are farm laborers by race
gen share_laborers_wh = farm_laborers_wh / ag_workers_wh

*Collapse to county level
gcollapse (last) population black_population white_population pct_black ///
	pct_married farmers_wh farmers_bl ag_workers_bl ag_workers_wh ///
	mfg_workers_bl mfg_workers_wh farm_renters_bl farm_renters_wh farm_owners_bl ///
	farm_owners_wh farm_laborers_bl farm_laborers_wh share* avg_wage* (sum) households ///
	farmers farm_renters farm_owners farm_laborers mfg_workers ag_workers ///
	nonfarm_workers under_15 between_15_44 over_44 under_15_f between_15_44_f ///
	over_44_f under_15_m between_15_44_m over_44_m incwage, by(stateicp countyicp year)
//pct_employed

*Calculate average wage overall
gen avg_wage = incwage / population
	
*Calculate overall shares of occupations
gen share_renters = farm_renters / farmers //Share of farms who rent
gen share_ag_renters = farm_renters / ag_workers //Share of agricultural workers that are farm-renters
gen share_ag = ag_workers / population //Share of people that are in agricultural occupation
gen share_mfg = mfg_workers / population //Share of people that work in manufacturing
gen share_owners = farm_owners / ag_workers //Share of agricultural workers that are farm owners
gen share_laborers = farm_laborers / ag_workers //Share of agricultural workers that are farm laborers

*Label variables and dataset
la var population "County-Year Population"
la var households "Number of Households"
la var pct_black "Black Percentage of Population"
la var black_population "County Black Population"
la var white_population "County White Population"
//la var pct_employed "Percentage of Population Employed"
//la var pct_employed_bl "Percentage of Black Population Employed"
//la var pct_employed_wh "Percentage of White Population Employed"
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
la var ag_workers "Number of Agricultural Workers, 15-44"
la var farm_owners "Number of Farm Owners, 15-44"
la var farm_renters "Number of Farmers who Rent, 15-44"
la var farm_laborers "Number of Farm Laborers, 15-44"
la var mfg_workers "Number of Manufacturing Workers, 15-44"
la var nonfarm_workers "Number of Nonfarm Workers, 15-44"

la var avg_wage "Average Wage"
la var avg_wage_bl "Black Average Wage"
la var avg_wage_wh "White Average Wage"

la var farmers_wh "Number of White Farmers. 15-44"
la var farmers_bl "Number of Black Farmers. 15-44"
la var ag_workers_wh "Number of White Agricultural Workers, 15-44"
la var ag_workers_bl "Number of Black Agricultural Workers, 15-44"
la var mfg_workers_wh "Number of White Manufacturing Workers, 15-44"
la var mfg_workers_bl "Number of Black Manufacturing Workers, 15-44"
la var farm_owners_wh "Number of White Farm Owners, 15-44"
la var farm_owners_bl "Number of Black Farm Owners, 15-44"
la var farm_renters_wh "Number of White Farmers who Rent, 15-44"
la var farm_renters_bl "Number of Black Farmers who Rent, 15-44"
la var farm_laborers_wh "Number of White Farm Laborers, 15-44"
la var farm_laborers_bl "Number of Black Farm Laborers, 15-44"

la var share_ag "Share of Population that Works in Agriculture"
la var share_ag_wh "Share of White Population that Works in Agriculture"
la var share_ag_bl "Share of Black Population that Works in Agriculture"

la var share_mfg "Share of Population that Works in Manufacturing"
la var share_mfg_wh "Share of White Population that Works in Manufacturing"
la var share_mfg_bl "Share of Black Population that Works in Manufacturing"

la var share_renters "Share of Farmers that Rent"
la var share_renters_wh "Share of White Farmers that Rent"
la var share_renters_bl "Share of Black Farmers that Rent"

la var share_owners "Share of Agricultural Workers that are Farmer-Owners"
la var share_owners_wh "Share of White Agricultural Workers that are Farmer-Owners"
la var share_owners_bl "Share of Black Agricultural Workers that are Farmer-Owners"
la var share_laborers "Share of Agricultural Workers that are Farm Laborers"
la var share_laborers_wh "Share of White Agricultural Workers that are Farm Laborers"
la var share_laborers_bl "Share of Black Agricultural Workers that are Farm Laborers"
la var share_ag_renters "Share of Agricultural Workers that are Farmer-Renters"
la var share_ag_renters_wh "Share of White Agricultural Workers that are Farmer-Renters"
la var share_ag_renters_bl "Share of Black Agricultural Workers that are Farmer-Renters"

la data "County-Year 1900-1940 IPUMs Dataset"

*Save dataset
save "$great_migration/output/ipums_county_year.dta", replace
