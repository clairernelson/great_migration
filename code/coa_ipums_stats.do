*Figures and maps for IPUMS and Census of Agriculture data

clear all
set more off
global great_migration "/users/clairenelson/dropbox/great-outmigration/claire/great_migration"

*Set scheme
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots

*******************************Weighted Scatterplot****************************

*Collapse IPUMs dataset to county-year
use "$great_migration/output/ipums_county_year_race.dta"
tempfile ipums_county_year

*Calculate share of Black/white farmers that are tenants
gegen farmers_bl = total(farmers*black), by(stateicp countyicp year)
gegen farmers_wh = total(farmers*(black == 0)), by(stateicp countyicp year)
gegen farm_renters_bl = total(farm_renters*black), by(stateicp countyicp year)
gegen farm_renters_wh = total(farm_renters*(black == 0)), by(stateicp countyicp year)
gen share_renters_bl = farm_renters_bl / farmers_bl
gen share_renters_wh = farm_renters_wh / farmers_wh

gcollapse (last) share_renters_wh  share_renters_bl pct_black ///
	(sum) farmers farm_renters population, by(stateicp countyicp year)
ren (countyicp stateicp) (county state)
gen share_renters = farm_renters / farmers //Share of farms who rent
save "`ipums_county_year'"

*Create CoA dataset of county averages, weighted by number of farms
*fix data/output
use "$great_migration/output/census_of_agriculture.dta", clear
keep if level == 1 //Keep only county level data from Census of Agriculture
keep if inlist(year,1900,1910,1920,1930,1940) //Keep only years from IPUMs
gen share_farmer_coa = farms / totpop

*Error in 1925 data puts two different counties under the same icpsr code
drop if state == 43 & county == 490

*Merge Census of Agriculture and IPUMs data
merge 1:1 year state county using "`ipums_county_year'", keep(3) nogen

*Weighted scatterplot: 1900
*Plot is similar for all years. The two measures are highly correlated
twoway scatter share_tenant share_renters if year == 1900 [w=totpop], ///
		title("CoA vs. IPUMS 1900 Tenancy Share Measure, Weighted by County Population") ///
		xtitle("IPUMS: Share of Farmers that Rent") ///
		ytitle("CoA Share of Farmers that are Tenants")
graph export "$great_migration/output/tenancy_coa_ipums.png", replace
		
*Weighted scatterplot by race: 1900
*The two measures by race are highly correlated
twoway scatter share_tenant_bl share_renters_bl [w=totpop] if year == 1900, ///
	title("CoA vs. IPUMS 1900 Black Tenancy Share Measure, Weighted by County Population") ///
	xtitle("IPUMS: Share of Black Farmers that Rent") ///
	ytitle("CoA Share of Black Farmers that are Tenants")
graph export "$great_migration/output/tenancy_bl_coa_ipums.png", replace
twoway scatter share_tenant_wh share_renters_wh [w=totpop] if year == 1900, ///
	title("CoA vs. IPUMS 1900 White Tenancy Share Measure, Weighted by County Population") ///
	xtitle("IPUMS: Share of White Farmers that Rent") ///
	ytitle("CoA Share of White Farmers that are Tenants")
graph export "$great_migration/output/tenancy_wh_coa_ipums.png", replace

*Population is correlated between two datasets
twoway scatter totpop population, ///
	title("CoA vs. IPUMS County Population ") ///
	xtitle("IPUMS County Population") ytitle("CoA County Population")
graph export "$great_migration/output/pop_coa_ipums.png", replace
	
*************Replicate Hornbeck and Naidu Figure 2 and Table 1******************
use "$great_migration/output/census_of_agriculture.dta", clear

*Check that data matches Hornbeck and Naidu graphs/statistics
*Restrict to Arkansas(42), Louisiana(45), Tennesse(54), and Missippi(46) 
*to roughly match their sample of counties (our numbers will be slightly higher)
keep if inlist(state, 42, 45, 54, 46)
keep if level == 1

*Figure 2: Graphs of log outcomes
*Trends look very similar, our levels are slightly higher
gegen sample_totpop = total(totpop), by(year)
gegen sample_farmequi = total(farmequi), by(year)
gegen sample_mules_horses = total(mules_horses), by(year)
gegen sample_farmsize = total(farmsize), by(year)
gegen sample_landval_fac = total(landval_fac), by(year)
gen ltotpop = log(sample_totpop)
gen lfarmequi = log(sample_farmequi)
gen lmules_horses = log(sample_mules_horses)
gen lfarmsize = log(sample_farmsize)
gen llandval_fac = log(sample_landval_fac)

twoway connected ltotpop year, nodraw name(g1) title("Log Population") ytitle("")
twoway connected lfarmequi year, nodraw name(g2) title("Log Farm Equipment") ytitle("")
twoway connected lmules_horses year, nodraw name(g3) title("Log Value of Agricultural Capital") ytitle("")
twoway connected lfarmsize year, nodraw name(g4) title("Log Number of Mules and Horses") ytitle("")
twoway connected llandval_fac year, nodraw name(g5) title("Log Land Value per Farm Acre") ytitle("")
graph combine g1 g2 g3 g4 g5, title("Figure 2: Aggregate Changes in the Sample Region")
graph export "$great_migration/output/hn_figure2.png", replace

*Table 1, Column 1 Panel A: 1920 Population Means
*Population mean is close but Black farmshare is understated here
su totpop_100ac if year == 1920
su farmshare_bl if year == 1920 //Slightly different

*Table 1, Column 1 Panel B: 1925 Agriculture Variable Means
*Close to Hornbeck and Naidu Values
su farmequi_100ac if year == 1925
su mules_horses_100ac if year == 1925
su tractors_100ac if year == 1925
su farmsize if year == 1925
su farmland_100ac if year == 1925
su valuelb_100fac if year == 1925
su valuelb_100ac if year == 1925

*****************************Trends for Key Outcomes****************************

*CoA: yearly average of Hornbeck and Naidu outcomes weighted by county farms
use "$great_migration/output/census_of_agriculture.dta", clear
keep if level == 1 //Keep county level data
gcollapse (mean) totpop farmequi mules_horses farmsize landval_fac ///
	farmshare_bl farmequi_100ac mules_horses_100ac tractors tractors_100ac ///
	farmland_100ac valuelb_100fac valuelb_100ac share_noncash share_noncash_bl ///
	share_noncash_wh share_tenant share_tenant_bl share_tenant_wh [aw=farms] , by(year)
	
*Population
twoway connected totpop year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("County Population") xtitle("Year") ///
	title("CoA: Average County Population, Weighted by Number of Farms in County")
graph export "$great_migration/output/coa_trend_pop.png", replace

*Value of farm equipment
twoway connected farmequi_100ac year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Value per 100 County Acres") xtitle("Year") title("Value of Farm Capital") /// 
	name(c1, replace) nodraw
		
*Mules and horses
twoway connected mules_horses_100ac year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Number per 100 County Acres") xtitle("Year") title("Mules and Horses") ///
	name(c2, replace) nodraw
	
*Average farmsize
format farmsize %9.0g
twoway connected farmsize year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Average Acreage") xtitle("Year") title("Farm Size") ///
	name(c3, replace) nodraw
		
*Landval per Acre Farmland
twoway connected landval_fac year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Value per Acre Farmland") xtitle("Year") title("Farm Land Value") ///
	name(c4, replace) nodraw
		
*Black farm share
twoway connected farmshare_bl year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Black Farm Share") xtitle("Year") ///
	name(c5, replace) nodraw title("Share of Farms with Black Operators")
		
*Tractors
twoway connected tractors_100ac year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Number per 100 County Acres") xtitle("Year") title("Tractors") ///
	name(c6, replace) nodraw
	
*Farmland per 100 county acres
twoway connected farmland_100ac year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Farm Acres per 100 County Acres") xtitle("Year") ///
	name(c7, replace) nodraw title("Farmland")
		
*Value of land and buildings per 100 county acres
twoway connected valuelb_100ac year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Value per 100 County Acres") xtitle("Year") ///
	name(c8, replace) nodraw title("Value of Farm Land and Buildings")
	
*Combine graphs
graph combine c1 c2 c3 c4, rows(2) title("CoA: Trends in Key Outcomes") ///
	subtitle("Yearly Average Weighted by Number of Farms in County")
graph export "$great_migration/output/coa_trends.png", replace
graph combine c5 c6 c7 c8, rows(2) title("CoA: Trends in Key Outcomes") ///
	subtitle("Yearly Average Weighted by Number of Farms in County")
graph export "$great_migration/output/coa_trends_2.png", replace
	
*Share of farmers that are tenants
twoway connected share_tenant year, ysc(r(0 1)) ylabel(#6) ///
	title("Farmers that are Tenants") xtitle("Year") ///
	name(s1, replace) nodraw ytitle("Share")
twoway connected share_tenant_bl year, ysc(r(0 1)) ylabel(#6) ///
	title("Black Farmers that are Tenants") xtitle("Year") ///
	name(s2, replace) nodraw ytitle("Share")
twoway connected share_tenant_wh year, ysc(r(0 1)) ylabel(#6) ///
	title("White Farmers that are Tenants") xtitle("Year") ///
	name(s3, replace) nodraw ytitle("Share")

*Share of farmers that are noncash tenants
twoway connected share_noncash year, ysc(r(0 1)) ylabel(#6) ///
	title("Farmers that are Noncash Tenants") xtitle("Year") ///
	name(s4, replace) nodraw ytitle("Share")
twoway connected share_noncash_bl year, ysc(r(0 1)) ylabel(#6) ///
	title("Black Farmers that are Noncash Tenants") xtitle("Year") ///
	name(s5, replace) nodraw ytitle("Share")
twoway connected share_noncash_wh year, ysc(r(0 1)) ylabel(#6) ///
	title("White Farmers that are Noncash Tenants") xtitle("Year") ///
	name(s6, replace) nodraw ytitle("Share")
	
*Combine graphs
graph combine s1 s2 s3 s4 s5 s6, rows(2) title("CoA: Trends in Sharecropping Variables") ///
	subtitle("Yearly Average Weighted by Number of Farms in County")
graph export "$great_migration/output/coa_trends_scrp.png", replace

*IPUMS: yearly average of Hornbeck and Naidu outcomes weighted by county population
use "`ipums_county_year'", clear
gcollapse (mean) population pct_black share_renters share_renters_bl ///
	share_renters_wh [aw=population], by(year)

*Yearly average of Hornbeck and Naidu outcomes weighted by county population

*Population
twoway connected population year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("County Population") xtitle("Year") name(p1,replace) ///
	title("Average County Population") nodraw

*Black population
twoway connected pct_black year, ysc(r(0) extend) ylabel(#6) ///
	ytitle("Percentage") xtitle("Year") name(p2,replace) ///
	title("Black Percentage of Population") nodraw

graph combine p1 p2, title("IPUMS: Trend in Population Variables") ///
	subtitle("Yearly Average Weighted by County Population")
graph export "$great_migration/output/ipums_trend_pop.png", replace

*Share of farmers that rent
twoway connected share_renters year, ysc(r(0 1)) ylabel(#6) ///
	title("Farmers that are Renters") xtitle("Year") ///
	name(r1, replace) nodraw ytitle("Share")
twoway connected share_renters_bl year, ysc(r(0 1)) ylabel(#6) ///
	title("Black Farmers that are Renters") xtitle("Year") ///
	name(r2, replace) nodraw ytitle("Share")
twoway connected share_renters_wh year, ysc(r(0 1)) ylabel(#6) ///
	title("White Farmers that are Renters") xtitle("Year") ///
	name(r3, replace) nodraw ytitle("Share")
graph combine r1 r2 r3, rows(1) title("IPUMS: Trends in Sharecropping Variables") ///
	subtitle("Yearly Average Weighted by County Population")
graph export "$great_migration/output/ipums_trend_scrp.png", replace


**********************Map key outcomes for Southern States*********************
clear all

*Install packages
//ssc install spmap
//ssc install shp2dta

*Create county shapefiles
shp2dta using "$great_migration/data/cb_2018_us_county_500k", ///
	database("$great_migration/data/usdb_county") ///
	coordinates("$great_migration/data/uscoord_county") ///
	genid(id) replace
use "$great_migration/data/usdb_county.dta"

*Create five digit fips code
gen fips = STATEFP + COUNTYFP
destring fips, replace
destring STATEFP, replace
save "$great_migration/data/usdb_county.dta", replace


*Census of Agriculture maps
foreach year in 1900 1910 1920 1925 1930 {
*Keep county level data
use "$great_migration/data/census_of_agriculture.dta", clear

*Error in 1925 data puts two different counties under the same icpsr code
drop if state == 43 & county == 490
keep if level == 1 & year == `year' & !mi(fips)
keep share_noncash* share_tenant* fips name

*Merge data with shapefile
merge 1:1 fips using "$great_migration/data/usdb_county.dta", nogen keep(3)

*Map outcomes for Deep South
spmap share_noncash using "$great_migration/data/uscoord_county" ///
	if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
	id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
	legend(symy(*2) symx(*2) size(*2) position (7)) ///
	title("Share of Farms Operated by Noncash Tenants, `year'")
graph export "$great_migration/output/noncash_map_`year'.png", replace

spmap share_tenant using "$great_migration/data/uscoord_county" ///
	if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
	id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
	legend(symy(*2) symx(*2) size(*2) position (7)) ///
	title("Share of Farms Operated by Tenants, `year'")
graph export "$great_migration/output/tenant_map_`year'.png", replace

*Share noncash is available by race only for 1900 and 1930
if `year' == 1900 | `year' == 1930 {
	spmap share_noncash_bl using "$great_migration/data/uscoord_county" ///
		if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
		id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
		legend(symy(*2) symx(*2) size(*2) position (7)) ///
		title("Share of Black Farms Operated by Noncash Tenants, `year'")
	graph export "$great_migration/output/noncash_bl_map_`year'.png", replace

	spmap share_noncash_wh using "$great_migration/data/uscoord_county" ///
		if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
		id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
		legend(symy(*2) symx(*2) size(*2) position (7)) ///
		title("Share of White Farms Operated by Noncash Tenants, `year'")
	graph export "$great_migration/output/noncash_wh_map_`year'.png", replace
	
	spmap share_tenant_bl using "$great_migration/data/uscoord_county" ///
		if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
		id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
		legend(symy(*2) symx(*2) size(*2) position (7)) ///
		title("Share of Black Farms Operated by Tenants, `year'")
	graph export "$great_migration/output/tenant_bl_map_`year'.png", replace

	spmap share_tenant_wh using "$great_migration/data/uscoord_county" ///
		if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
		id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
		legend(symy(*2) symx(*2) size(*2) position (7)) ///
		title("Share of White Farms Operated by Tenants, `year'")
	graph export "$great_migration/output/tenant_wh_map_`year'.png", replace
}
}

/*Need to map with ICPSR codes
*IPUMs Maps
foreach year in 1900 1910 1920 1925 1930 {
	use "`ipums_county_year'", clear
	
	*Merge data with shapefile
	merge 1:1 fips using "$great_migration/data/usdb_county.dta", nogen keep(3)
	
	*Map outcomes for Deep South
	spmap share_renters using "$great_migration/data/uscoord_county" ///
		if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
		id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
		legend(symy(*2) symx(*2) size(*2) position (7)) ///
		title("Share of Farmers that Are Renters, `year'")
	graph export "$great_migration/output/renter_map_`year'.png", replace

	spmap share_renters_bl using "$great_migration/data/uscoord_county" ///
		if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
		id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
		legend(symy(*2) symx(*2) size(*2) position (7)) ///
		title("Share of Black Farmers that are Renters, `year'")
	graph export "$great_migration/output/renter_bl_map_`year'.png", replace
	
	spmap share_renters_wh using "$great_migration/data/uscoord_county" ///
		if inlist(STATEFP, 1, 5, 12, 13, 22, 28, 37, 45) | inlist(STATEFP, 40, 47, 48), ///
		id(id) fcolor(Blues) clmethod(custom) clbreaks(0 0.2 0.4 0.6 0.8 1) ///
		legend(symy(*2) symx(*2) size(*2) position (7)) ///
		title("Share of White Farmers that are Renters, `year'")
	graph export "$great_migration/output/renter_wh_map_`year'.png", replace
	
}
*/


exit
