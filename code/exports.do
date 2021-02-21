*Analyze 2-digit SIC-year export totals

clear all
set more off

*Set scheme
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots

global great_migration "/Users/clairenelson/Documents/Research/great_migration"

import excel "$great_migration/data/statistical_abstract_exports.xlsx", ///
	sheet("Data") first
	
drop R
destring(SIC_4), replace
	
*Flag observations to be included in 2-digit-year totals using level one category
*totals from Statistical Abstract
gen total_flag = !mi(article_1) & mi(article_2) & unit == "dolls" & ///
	 !mi(SIC_2) & !inlist(article_1, "Iron and Steel", "Oils", ///
	"Gold and silver, manufactures of, including jewelry", "Wool")

*Use level 2 totals for Gold and Silver, Iron and Steel, Oils, and Wool because
*level 1 totals have ambigous SIC code
replace total_flag = 1 if !mi(article_1) & !mi(article_2) & mi(article_3) & ///
	!mi(SIC_2) & unit == "dolls" & inlist(article_1, "Iron and Steel", "Oils", ///
	"Gold and silver, manufactures of, including jewelry", "Wool")

*Collapse by 2-digit SIC code
keep if total_flag == 1
collapse (sum) year_*, by(SIC_2)

*Reshape
reshape long year_, i(SIC_2) j(year)
rename year_ total_exports
format total_exports %20.0gc
sort SIC_2 year

*Label values of SIC_2 with industry name
label define industry_title 19 "Ordnance and accessories" ///
	20 "Food and kindred products" 21 "Tobacco manufactures" 22 "Textile mill products" ///
	23 "Apparel and other finished products made from fabrics and similar materials" ///
	24 "Lumber and wood products (except furniture)" 25 "Furniture and fixtures" ///
	26 "Paper and allied products" 27 "Printing, publishing, and allied industries" ///
	28 "Chemicals and allied products" 29 "Products of petroleum and coal" ///
	30 "Rubber products" 31 "Leather and leather products" ///
	32 "Stone, clay, and glass products" 33 "Primary metal industries" ///
	34 "Fabricated metal product (except ordnance, machinery, and transportation equipment)" ///
	35 "Machinery (excpet electircal)" 36 "Electrical machinery, equipment, and supplies" ///
	37 "Transportation equipment" ///
	38 "Professional, scientific, and controlling instruments; photographic and optical goods; watches and clocks" ///
	39 "Miscellaneous manufacturing industries"
label values SIC_2 industry_title

*Graph 2-digit-year totals over time
levelsof SIC_2
foreach x in `r(levels)' {
	local title: label (SIC_2) `x'
	graph twoway line total_exports year if SIC_2 == `x', ///
		xtitle("Year") ytitle("Total Exports ($)") title("`title'")
	graph export "$great_migration/output/industry_`x'_exports.png", replace
}
	
*Graph total exports over time
preserve
collapse (sum) total_exports, by(year)
twoway line total_exports year, name(g_total) xtitle("Year") ///
	ytitle("Total Exports($)") title("Total Annual Exports")
graph export "$great_migration/output/total_exports.png", replace
restore

*Save dataset of yearly industry totals
save "$great_migration/output/total_industry_exports.dta", replace

exit
