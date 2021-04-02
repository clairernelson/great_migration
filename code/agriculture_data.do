*Keep Hornbeck and Naidu (2014) variables from Census of Agriculture
*Harmonize variable names across years 

clear all
set more off
global great_migration "/users/clairenelson/dropbox/great-outmigration/claire/great_migration"

*Set scheme
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots

*Hornbeck and Naidu variables: population, black population, black farm share (#farms)
*value of land and buildings, equipment value, land value, farmland, average farmsize,
*mules, horses, tractors, county area, plus sharecropping variables

*1900: missing tractors
*Other/unspecified tenants are included in cash tenants
tempfile coa_1900
use "$great_migration/data/census_of_agriculture_1900.dta", clear
keep STATE COUNTY LEVEL NAME FIPS TOTPOP FARMS FARMSIZE FARMTEN AREA ///
	 FARMCOL FARMVAL FARMSBUI FARMEQUI ACFARM MULES* HORSES* FARMWHCT FARMCOCT ///
	 FARMWHST FARMCOST
//FARMSTEN
ren (FARMCOL ACFARM HORSES20 FARMVAL FARMSBUI FARMCOCT) ///
	(FARMSBL FARMLAND HORSES LANDVAL FARMBUI FARMBLCT)
ren FARMCOST FARMBLST
gen MULES = MULES0 + MULES1_2 + MULES20 //Add mules by age group to get total mules
gen year = 1900
gen VALUELB = LANDVAL + FARMBUI //Calculate value of land and buildings
gen FARMCTEN = FARMWHCT + FARMBLCT //Calculate total number of cash tenants
gen FARMBLT = FARMBLST + FARMBLCT //Total Black tenants
gen FARMWHT = FARMWHST + FARMWHCT
//gen FARMSTEN = FARMBLST + FARMWHST //Total share tenants
drop FARMBUI MULES0 MULES1_2 MULES20 FARMWHST FARMBLST
save "`coa_1900'"
	
*1910: missing tractors
*Standing renters included with cash tenants
tempfile coa_1910
use "$great_migration/data/census_of_agriculture_1910.dta", clear
keep STATE COUNTY FIPS LEVEL NAME AREA TOTPOP FARMS FARMNEG FARMLAND FARMVAL FARMBUI ///
	FARMEQUI HORSES MULES FARMTEN FARMNWTE FARMFBWT FARMCTEN FARMNEGT
//FARMSCT FARMOTEN FARMSTEN
ren (FARMNEG FARMVAL FARMNEGT) (FARMSBL LANDVAL FARMBLT)
gen year = 1910
gen FARMWHT = FARMNWTE + FARMFBWT //Total white tenants
gen FARMSIZE = FARMLAND / FARMS //Calculate avg farm size from farmland and number farms
gen VALUELB = LANDVAL + FARMBUI //Calculate value of land and buildings
drop FARMBUI FARMNWTE FARMFBWT
save "`coa_1910'"
	
*1920: missing tractors
*Standing renters for North and West included in cash tennats
*Standing renters for South listed separately
tempfile coa_1920
use "$great_migration/data/census_of_agriculture_1920.dta", clear
keep STATE COUNTY FIPS LEVEL NAME TOTPOP VAR1 VAR6 VAR18 VAR23 VAR24 VAR25 ///
	VAR56 VAR63 VAR47 VAR50 VAR51 VAR52 VAR53
//VAR44 VAR45 VAR46 VAR48 VAR49
ren (VAR1 VAR6 VAR18 VAR63 VAR56 VAR23 VAR24 VAR25 VAR53) ///
	(FARMS FARMSBL FARMLAND MULES HORSES LANDVAL FARMBUI FARMEQUI AREA)
ren (VAR47 VAR50 VAR51 VAR52) ///
	(FARMCTEN FARMNWTE FARMFBWT FARMBLT)
//ren (VAR44 VAR45 VAR46) (FARMSTEN FARMCR FARMSCT)
gen year = 1920
gen FARMSIZE = FARMLAND / FARMS //Calculate avg farm size from farmland and number farms
gen VALUELB = LANDVAL + FARMBUI //Calculate value of land and buildings
gen FARMWHT = FARMNWTE + FARMFBWT //Total white tenants
gen FARMTEN = FARMWHT + FARMBLT //Calculate total tenants
drop FARMBUI FARMNWTE FARMFBWT
save "`coa_1920'"
	
*1925
*Other tenants includes all tenants other than cash tenants and croppers
tempfile coa_1925
use "$great_migration/data/census_of_agriculture_1925.dta", clear
keep STATE COUNTY FIPS LEVEL NAME VAR1 VAR2 VAR16 VAR26 VAR27 VAR28 VAR29 ///
	VAR71 VAR72 VAR74 VAR125 VAR127 VAR129 VAR188 VAR199 VAR203
//VAR32 VAR33 VAR34 VAR35
ren (VAR1 VAR2 VAR16 VAR74 VAR72 VAR203 VAR199 VAR188 VAR125 VAR127 VAR129 VAR71) ///
	(TOTPOP FARMS FARMSBL FARMSIZE FARMLAND MULES HORSES TRACTORS VALUELB LANDVAL FARMEQUI AREAAC)
ren (VAR26 VAR27 VAR28 VAR29) ///
	(FARMTEN FARMWHT FARMBLT FARMCTEN)
//ren (VAR32 VAR33 VAR34 VAR35) (FARMCR FARMCRWH FARMCRBL FARMOTEN)
gen year = 1925
gen AREA = AREAAC * 0.0015625 //Convert county area to square miles
drop AREAAC
save "`coa_1925'"
	
*1930
*Other tenants includes all tenants other than cash tenants and croppers
tempfile coa_1930
use "$great_migration/data/census_of_agriculture_1930.dta", clear
keep STATE COUNTY FIPS LEVEL NAME VAR1 VAR2 VAR5 VAR8 VAR11 ///
	VAR120 VAR121 VAR125 VAR140 VAR172 VAR182 VAR1018 VAR47 VAR48 VAR49 VAR50
//VAR51 VAR52 VAR53 VAR54
ren (VAR1 VAR2 VAR5 VAR11 VAR8 VAR182 VAR172 VAR1018 VAR120 VAR121 VAR125 VAR140) ///
	(TOTPOP FARMS FARMSBL FARMSIZE FARMLAND MULES HORSES TRACTORS VALUELB LANDVAL FARMEQUI AREA) 
ren (VAR47 VAR48 VAR49 VAR50) ///
	(FARMWHT FARMBLT FARMWHCT FARMBLCT)
//ren (VAR51 VAR52 VAR53 VAR54) (FARMCRWH FARMCRBL FARMWHOT FARMBLOT)
gen FARMCTEN = FARMWHCT + FARMBLCT
//gen FARMCR = FARMCRWH + FARMCRBL //Calculate total croppers
//gen FARMOTEN = FARMWHOT + FARMBLOT //Total other tenants
gen FARMTEN = FARMWHT + FARMBLT //Calculate total tenants
gen year = 1930
save "`coa_1930'"

*1935: missing tractors, land value, and equipment value
*Other tenants includes all tenants other than croppers
tempfile coa_1935
use "$great_migration/data/census_of_agriculture_1935.dta", clear
keep STATE COUNTY FIPS LEVEL NAME VAR1 VAR2 VAR4 VAR9 VAR11 VAR12 VAR19 ///
	VAR56 VAR61 VAR95 VAR100 VAR57 VAR62
ren (VAR1 VAR2 VAR4 VAR11 VAR12 VAR100 VAR95 VAR19 VAR9) ///
	(TOTPOP FARMS FARMSBL FARMSIZE FARMLAND MULES HORSES VALUELB AREAAC)
ren (VAR56 VAR57 VAR61 VAR62) (FARMCRWH FARMWHOT FARMCRBL FARMBLOT)
gen FARMCR = FARMCRWH + FARMCRBL //Calculate total croppers
gen year = 1935
gen AREA = AREAAC * 0.0015625 //Convert county area to square miles
//gen FARMOTEN = FARMWHOT + FARMBLOT //Total other tenants
gen FARMTEN = FARMCRWH + FARMWHOT + FARMCRBL + FARMBLOT //Calculate total tenants
gen FARMBLT = FARMCRBL + FARMBLOT //Total Black tenants
gen FARMWHT = FARMCRWH + FARMWHOT //Total white tenants
drop AREAAC
foreach x in FARMCR FARMCRBL FARMCRWH {
	ren `x' `x'_1935
}
drop FARMWHOT FARMBLOT
save "`coa_1935'"

*1940:
tempfile coa_1940
use "$great_migration/data/census_of_agriculture_1940.dta", clear
keep STATE COUNTY FIPS LEVEL NAME VAR1 VAR4 VAR7 VAR8 VAR29 VAR31 VAR33 VAR35 ///
	VAR130 VAR190 VAR194 VAR594 VAR43 VAR45
//VAR46 VAR47 VAR48
ren (VAR1 VAR4 VAR35 VAR8 VAR7 VAR194 VAR190 VAR594 VAR29 VAR31 VAR33 VAR130) ///
	(TOTPOP FARMS FARMSBL FARMSIZE FARMLAND MULES HORSES TRACTORS VALUELB FARMBUI FARMEQUI AREA)
ren (VAR43 VAR45) (FARMTEN FARMCTEN)
//ren (VAR46 VAR47 VAR48) (FARMSCT FARMSCR FARMOTEN)
gen year = 1940
gen LANDVAL = VALUELB - FARMBUI // Calculate land value from land and buildings
drop FARMBUI
drop if mi(COUNTY) //Drop missing values
save "`coa_1940'"

*1945: missing land value
tempfile coa_1945
use "$great_migration/data/census_of_agriculture_1945.dta", clear
keep STATE COUNTY FIPS TOTPOP40 NAME LEVEL VAR2 VAR3 VAR4 VAR7 VAR39 VAR43 ///
	VAR68 VAR105 VAR458 VAR461 VAR559 VAR561
//VAR565 VAR562 VAR563 VAR564 VAR604 VAR605 VAR606 VAR614 VAR615 VAR616
ren (TOTPOP40 VAR2 VAR68 VAR7 VAR4 VAR458 VAR461 VAR105 VAR39 VAR43 VAR3) ///	
	(TOTPOP FARMS FARMSBL FARMSIZE FARMLAND MULES HORSES TRACTORS VALUELB FARMEQUI AREAAC)
ren (VAR559 VAR561)  (FARMTEN FARMCTEN)
//ren (VAR565 VAR562 VAR563 VAR564 VAR604 VAR605 VAR606 VAR614 VAR615 VAR616) ///
	//(FARMOTEN FARMSCT FARMSCR FARMCR FARMSCTWH FARMWHST FARMCRWH FARMSCTBL FARMBLST FARMCRBL) 
gen year = 1945
gen AREA = AREAAC * 0.0015625 //Convert county area to square miles
drop AREAAC
save "`coa_1945'"

*1950: missing land value and value of equipment
tempfile coa_1950
use "$great_migration/data/census_of_agriculture_1950.dta", clear
keep STATE COUNTY FIPS TOTPOP NAME LEVEL VAR1 VAR2 VAR8 VAR9 VAR10 VAR128 ///
	VAR245 VAR301 VAR304 VAR132 VAR134
//VAR135 VAR136 VAR137 VAR138 VAR139 VAR140 VAR141 VAR178 VAR184 VAR142
ren (VAR1 VAR128 VAR9 VAR8 VAR304 VAR301 VAR245 VAR10 VAR2) ///
	(FARMS FARMSBL FARMSIZE FARMLAND MULES HORSES TRACTORS AVG_LB AREAAC)
ren (VAR132 VAR134) (FARMTEN FARMCTEN)
//ren (VAR135 VAR136 VAR137 VAR138 VAR139 VAR140 VAR141 VAR178 VAR184 VAR142) ///
	//(FARMSCT FARMSCR FARMCSCR FARMSTEN FARMCS FARMLS FARMCR FARMCRWH FARMCRBL FARMOTEN)
gen year = 1950
gen AREA = AREAAC * 0.0015625 //Convert county area to square miles
gen VALUELB = AVG_LB * FARMS // Calculate total value of land and buildings from average
drop AREAAC AVG_LB
save "`coa_1950'"

*Append into a single dataset
clear
foreach x in 1900 1910 1920 1925 1930 1935 1940 1945 1950 {
	append using "`coa_`x''"
}

*Match units used in Hornbeck and Naidu
rename *, lower
gen farmshare_bl = farmsbl / farms //Calculate Black farm share
gen county_area = area * 640 //Convert county area to acres
gen landval_fac = landval / farmland //Land value per acre
gen mules_horses = mules + horses //Total number of mules and horses
gen mules_horses_100ac = mules_horses * 100 / county_area //Mules and horses per 100 county acres
gen farmequi_100ac = farmequi * 100 / county_area //Value equipment per 100 county acres
gen farmland_100ac = farmland * 100 / county_area //Farmland per 100 county acres
gen valuelb_100ac = valuelb * 100 / county_area //Value land and buildings per 100 county acres
gen valuelb_100fac = valuelb * 100 / farmland //Value land and buildings per 100 farm acres
gen totpop_100ac = totpop * 100 / county_area //Population per 100 county acres
gen tractors_100ac = tractors * 100 / county_area //Tracgtors per 100 county acres
drop area

*Calculate share of farmers that are tenants; total and by race
gen share_tenant = farmten / farms
gen share_tenant_bl = farmblt / farmsbl
gen share_tenant_wh = farmwht / (farms - farmsbl)

*Create total noncash tenants: total minus cash tenants
*Missing number of cash tenants for 1935, imputed total tenants for 1920, 1930, 1935
*Total and by race
gen noncash_tenants = farmten - farmcten
replace noncash_tenants = farmcr_1935 if year == 1935 //Estimate using number of croppers
gen noncash_tenants_bl = farmblt - farmblct
replace noncash_tenants_bl = farmcrbl_1935 if year == 1935 //Estimate using number of croppers
gen noncash_tenants_wh = farmwht - farmwhct
replace noncash_tenants_wh = farmcrwh_1935 if year == 1935 //Estimate using number of croppers

*Calculate share of farmers that are non-cash tenants
gen share_noncash = noncash_tenants / farms
gen share_noncash_bl = noncash_tenants_bl / farmsbl
gen share_noncash_wh = noncash_tenants_wh / (farms-farmsbl)
drop *1935

*Label variables and dataset
la var farmsbl "Number of Black-operated farms"
la var mules "Number of Mules"
la var horses "Number of Horses"
la var mules_horses "Number of Mules and Horses"
la var mules_horses_100ac "Number of Mules and Horses per 100 County Acres"
la var valuelb "Value of Land and Buildings"
la var valuelb_100ac "Value of Land and Buildings per 100 County Acres"
la var valuelb_100fac "Value of Land and Buildings per 100 Farm Acres"
la var farmequi_100ac "Value of farm implements/machinery per 100 County Acres"
la var farmland_100ac "Farmland per 100 County Acres"
la var tractors "Number of Tractors on Farms"
la var tractors_100ac "Number of Tractors per 100 County Acres"
la var totpop "Total Population"
la var totpop_100ac "Population per 100 County Acres"
la var farmshare_bl "Share of Farms with Black Operators"
la var county_area "Area of County (Acres)"
la var landval_fac "Land Value per Farm Acre"

la var farmten "Number of Tenants"
la var farmcten "Number of Cash Tenants"
la var farmwht "Number of White Tenants"
la var farmblt "Number of Black Tenants"
la var share_tenant "Share of Farmers that are Tenants"
la var share_tenant_bl "Share of Black Farmers that are Tenants"
la var share_tenant_wh "Share of White Farmers that are Tenants"
la var noncash_tenants "Number of Non-Cash Tenants"
la var noncash_tenants_bl "Number of Black Non-Cash Tenants"
la var noncash_tenants_wh "Number of White Non-Cash Tenants"
la var share_noncash "Share of Farmers that are Non-Cash Tenants"
la var share_noncash_bl "Share of Black Farmers that are Non-Cash Tenants"
la var share_noncash_wh "Share of White Farmers that are Non-Cash Tenants"

la data "United States Agriculture Data (1900-1950)"

*Order variables
order year state county fips name level county_area totpop farmland farmsize ///
	farms farmsbl farmshare_bl landval valuelb farmequi horses mules tractors
	
*Save dataset
save "$great_migration/data/census_of_agriculture.dta", replace

preserve
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
restore

exit
