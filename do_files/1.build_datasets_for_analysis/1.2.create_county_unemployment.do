// Clear memory
clear all

// Loop over all years
local year 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 

foreach yr in `year' {
	clear
	import excel "$raw_data_path/bls_local_unemployment_area_data/laucnty`yr'.xlsx", sheet("laucnty`yr'") 
	rename B StateFIPS
	rename C CountyFIPS
	rename E year 

	rename J unemp_rate
	rename I numb_unemp
	rename H numb_emp
	rename G numb_labor_force
	
	drop in 1/6
	destring StateFIPS, replace 
	destring CountyFIPS, replace
	destring year, replace
	
	local loop_list unemp_rate numb_unemp  numb_emp numb_labor_force
	foreach var in `loop_list' {
		replace `var'="" if `var'=="N.A."
		destring `var', replace
	}

	replace unemp_rate=unemp_rate/100

	keep StateFIPS CountyFIPS unemp_rate numb_unemp  numb_emp numb_labor_force year

	save "$temp_path/temp_county_unemployment_`yr'.dta", replace
	
	

}

use "$temp_path/temp_county_unemployment_01.dta", clear

local year 99 00 02 03 04 05 06 07 08 09 10 11 12 13 14
foreach yr in `year' {
	append using "$temp_path/temp_county_unemployment_`yr'.dta"
	erase  "$temp_path/temp_county_unemployment_`yr'.dta"
}
drop if missing(StateFIPS)


erase "$temp_path/temp_county_unemployment_01.dta"
save "$data_path/county_unemployment_99_14.dta",replace
