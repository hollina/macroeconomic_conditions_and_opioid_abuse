/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified Date: 18 October 2016

  Description: Show sensitivity to different time trends 
*/ /////////////////////////////////////////////////////////////////////////////

clear all
set maxvar 32000

clear all
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			


	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode
		
// Merge in Controls
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
				
				keep if _merge==3 //Lost 61 observations. Should Figure out Why.
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
				
				keep if _merge==3 // We lose MD 2002 since we don't have that data on poverty for some reason
				//Lost 2001 and 2002
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

				keep if _merge==3
				drop _merge
				

				label variable year "Year"

			// XTSET the data
				xtset countycode year
				
			// Clean Up
				replace unemp_rate = unemp_rate*100
				label variable unemp_rate "Unemployment Rate, [1-100]"
				replace median_income = median_income/1000
				label variable median_income "Median Income, \\\$1000s"
				gen percent_non_white = (pop-popw)/pop
				label variable percent_non_white "\% Non-White, [0-1]"
	
// Gen Employed to Population Ratio
	gen emp_ratio_all = (numb_emp/pop)*100
	gen emp_ratio_25_54 = (numb_emp/pop_25_54)*100
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	gen emp_ratio_15_up = (numb_emp/pop_15_up)*100

	
	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	label variable aheroinr "Heroin Death Rate per 100k"
	
	label variable drugwr "White Drug Death Rate per 100k"
	label variable aopioidwr "White Opioid Death Rate per 100k"
	label variable aheroinwr "White Heroin Death Rate per 100k"
	
	label variable drugbr "Black Drug Death Rate per 100k"
	label variable aopioidbr "Black Opioid Death Rate per 100k"
	label variable aheroinbr "Black Heroin Death Rate per 100k"

	label variable drughr "Hispanic Drug Death Rate per 100k"
	label variable aopioidbr "Hispanic Opioid Death Rate per 100k"
	label variable aheroinbr "Hispanic Heroin Death Rate per 100k"
	

	label variable year "Year"

// XTSET the data
	xtset countycode year

	
// Gen Year Dummies
	tab year, gen(yd)
	/*
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	
	qui levelsof countycode
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if countycode==`x'
	}
	*/
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year , gen(st_year_fe_)	
	

			
			set matsize 5000
//No Time Trends
	// Clear Estimates
		capture est sto clear	
	// All
		reghdfe aopioidr unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo op_all_none
		reghdfe drugr    unemp_rate   [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo drug_all_none			
*******************************************************************************
//ED Visits
*******************************************************************************

// Open data
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear

drop if StateFIPS==21 & year==2009
	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
				
	gen  r_op_dep_any = (op_dep_any/pop_total)*100000
	
	gen  r_op_dep_any_r_w = (op_dep_any_r_w/pop_white)*100000
	gen  r_op_dep_any_r_b = (op_dep_any_r_b/pop_black)*100000
	gen  r_op_dep_any_r_h = (op_dep_any_r_h/pop_hisp)*100000	
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	
	gen  r_her_ovr_any = (her_ovr_any/pop_total)*100000
				
	gen  r_her_ovr_any_r_w = (her_ovr_any_r_w/pop_white)*100000
	gen  r_her_ovr_any_r_b = (her_ovr_any_r_b/pop_black)*100000
	gen  r_her_ovr_any_r_h = (her_ovr_any_r_h/pop_hisp)*100000
	

	
	
// Simplify Variable Names
	rename *any *total //Can't do this earlier because of population
	rename *any* ** 
	
//Create Year Dummies
	tab year, gen(yd)
	
// Create FIPS dummies 
	tab fips, gen(cd)

// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Generate Recession Binary and Recession or After Binary
	*https://fred.stlouisfed.org/series/USREC
	gen recession_year = 0
	replace recession_year=1 if year==2008 | year ==2009
	
	gen post_recession = 0
	replace post_recession = 1 if year>2009
	
	
// Label Certain Variables
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
     label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
     label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
	 label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
	 
// Make it so we drop hispanic 
	gen hisp_unemp_rate = unemp_rate

// Set Matsize
	set matsize 10000
//No Time Trends
		reghdfe r_op_ovr_total unemp_rate   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_op_all_none

		reghdfe r_drug_ovr_total unemp_rate   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_drug_all_none
			
			
		esttab op_all_none drug_all_none e_op_all_none e_drug_all_none  using  "$results_path/appendix/tables/table_a1_different_time_trends.tex" , ///
		keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
		replace se order(unemp_rate) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		f nomtitles substitute(\_ _)  noobs ///
		refcat(unemp_rate "\hline \emph{All Races/Ethnicities}", nolabel)	///
		noline	///
		mgroups("Opioid Death Rate" "All Drug Death Rate" "Opioid ED Visit Rate" "Drug ED Visit Rate", pattern(1 1  1 1  ) prefix(\multicolumn{1}{c}{\underline{\smash{) suffix(}}})  span) ///
		coef(unemp_rate "\hspace{0.5cm} No Time Trends") 	
/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified Date: 18 October 2016

  Description: Create single table with the perferred spec by Race (All, White, Black, Hisp)
	***DO NOT SHARE CHRIS' DATA***

*/ /////////////////////////////////////////////////////////////////////////////


clear all
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			


	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode
		
// Merge in Controls
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
				
				keep if _merge==3 //Lost 61 observations. Should Figure out Why.
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
				
				keep if _merge==3 // We lose MD 2002 since we don't have that data on poverty for some reason
				//Lost 2001 and 2002
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

				keep if _merge==3
				drop _merge
				

				label variable year "Year"

			// XTSET the data
				xtset countycode year

				
			// Gen Year Dummies
				
				
			// Clean Up
				replace unemp_rate = unemp_rate*100
				label variable unemp_rate "Unemployment Rate, [1-100]"
				replace median_income = median_income/1000
				label variable median_income "Median Income, \\\$1000s"
				gen percent_non_white = (pop-popw)/pop
				label variable percent_non_white "\% Non-White, [0-1]"
	
// Gen Employed to Population Ratio
	gen emp_ratio_all = (numb_emp/pop)*100
	gen emp_ratio_25_54 = (numb_emp/pop_25_54)*100
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	gen emp_ratio_15_up = (numb_emp/pop_15_up)*100


	
	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	label variable aheroinr "Heroin Death Rate per 100k"
	
	label variable drugwr "White Drug Death Rate per 100k"
	label variable aopioidwr "White Opioid Death Rate per 100k"
	label variable aheroinwr "White Heroin Death Rate per 100k"
	
	label variable drugbr "Black Drug Death Rate per 100k"
	label variable aopioidbr "Black Opioid Death Rate per 100k"
	label variable aheroinbr "Black Heroin Death Rate per 100k"

	label variable drughr "Hispanic Drug Death Rate per 100k"
	label variable aopioidbr "Hispanic Opioid Death Rate per 100k"
	label variable aheroinbr "Hispanic Heroin Death Rate per 100k"
	

	label variable year "Year"

// XTSET the data
	xtset countycode year

	
// Gen Year Dummies
	tab year, gen(yd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof countycode
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if countycode==`x'
	}
	*/
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year , gen(st_year_fe_)	
	
	
			
			set matsize 5000
//5 Time Trends
	// Clear Estimates
		capture est sto clear	
		
	xtile pop_5 = pop if year==1999, n(5)
	sort countycode year
	bysort countycode: carryforward pop_5, replace
	
	qui levelsof pop_5

	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_5==`x'
	}

	// All
		reghdfe aopioidr unemp_rate county_time_pop_*  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo op_all_none
		reghdfe drugr    unemp_rate  county_time_pop_*  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo drug_all_none			
*******************************************************************************
//ED Visits
*******************************************************************************
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear
drop if StateFIPS==21 & year==2009
	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
				
	gen  r_op_dep_any = (op_dep_any/pop_total)*100000
	
	gen  r_op_dep_any_r_w = (op_dep_any_r_w/pop_white)*100000
	gen  r_op_dep_any_r_b = (op_dep_any_r_b/pop_black)*100000
	gen  r_op_dep_any_r_h = (op_dep_any_r_h/pop_hisp)*100000	
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	
	gen  r_her_ovr_any = (her_ovr_any/pop_total)*100000
				
	gen  r_her_ovr_any_r_w = (her_ovr_any_r_w/pop_white)*100000
	gen  r_her_ovr_any_r_b = (her_ovr_any_r_b/pop_black)*100000
	gen  r_her_ovr_any_r_h = (her_ovr_any_r_h/pop_hisp)*100000
	

	
	
// Simplify Variable Names
	rename *any *total //Can't do this earlier because of population
	rename *any* ** 
	
//Create Year Dummies
	tab year, gen(yd)
	
// Create FIPS dummies 
	tab fips, gen(cd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof fips
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if fips==`x'
	}
// Gen Commuter Zone Specific Time Trends
	capture drop _merge
	merge  m:1  StateFIPS CountyFIPS using "$data_path/dorn_data.dta"
	
	qui	levelsof czone
	
	foreach x in `r(levels)' {
		gen czone_time_`x'=0
		replace  czone_time_`x' = time if czone==`x'
	}
*/	
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Generate Recession Binary and Recession or After Binary
	*https://fred.stlouisfed.org/series/USREC
	gen recession_year = 0
	replace recession_year=1 if year==2008 | year ==2009
	
	gen post_recession = 0
	replace post_recession = 1 if year>2009
	
	
// Label Certain Variables
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
     label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
     label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
	 label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
	 
// Make it so we drop hispanic 
	gen hisp_unemp_rate = unemp_rate

// Set Matsize
	set matsize 10000
//5 Time Trends

xtile pop_5 = pop_total if year==2008, n(5)
	sort fips year
	bysort fips: carryforward pop_5, replace
	replace year = -year
	sort fips year
	bysort fips: carryforward pop_5, replace
	replace year = -year
	sort fips year

	qui levelsof pop_5

	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_5==`x'
	}

		reghdfe r_op_ovr_total unemp_rate   county_time_pop_*  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_op_all_none

		reghdfe r_drug_ovr_total unemp_rate  county_time_pop_*   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_drug_all_none
			
			
		esttab op_all_none drug_all_none e_op_all_none e_drug_all_none  using  "$results_path/appendix/tables/table_a1_different_time_trends.tex" , ///
		keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		f nomtitles substitute(\_ _) nonumbers noobs  noline	collabels(none)   ///
		coef(unemp_rate "\hspace{0.5cm} 5 County Time Trends by Pop. Quintile") 	
/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified Date: 18 October 2016

  Description: Create single table with the perferred spec by Race (All, White, Black, Hisp)

*/ /////////////////////////////////////////////////////////////////////////////


clear all
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			


	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode
		
// Merge in Controls
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
				
				keep if _merge==3 //Lost 61 observations. Should Figure out Why.
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
				
				keep if _merge==3 // We lose MD 2002 since we don't have that data on poverty for some reason
				//Lost 2001 and 2002
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

				keep if _merge==3
				drop _merge
				

				label variable year "Year"

			// XTSET the data
				xtset countycode year

				
			// Gen Year Dummies
				
				
			// Clean Up
				replace unemp_rate = unemp_rate*100
				label variable unemp_rate "Unemployment Rate, [1-100]"
				replace median_income = median_income/1000
				label variable median_income "Median Income, \\\$1000s"
				gen percent_non_white = (pop-popw)/pop
				label variable percent_non_white "\% Non-White, [0-1]"
	
// Gen Employed to Population Ratio
	gen emp_ratio_all = (numb_emp/pop)*100
	gen emp_ratio_25_54 = (numb_emp/pop_25_54)*100
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	gen emp_ratio_15_up = (numb_emp/pop_15_up)*100

	
	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	label variable aheroinr "Heroin Death Rate per 100k"
	
	label variable drugwr "White Drug Death Rate per 100k"
	label variable aopioidwr "White Opioid Death Rate per 100k"
	label variable aheroinwr "White Heroin Death Rate per 100k"
	
	label variable drugbr "Black Drug Death Rate per 100k"
	label variable aopioidbr "Black Opioid Death Rate per 100k"
	label variable aheroinbr "Black Heroin Death Rate per 100k"

	label variable drughr "Hispanic Drug Death Rate per 100k"
	label variable aopioidbr "Hispanic Opioid Death Rate per 100k"
	label variable aheroinbr "Hispanic Heroin Death Rate per 100k"
	

	label variable year "Year"

// XTSET the data
	xtset countycode year

	
// Gen Year Dummies
	tab year, gen(yd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof countycode
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if countycode==`x'
	}
	*/
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year , gen(st_year_fe_)	
	
// Clean Up
	
			
			set matsize 5000
//100 Time Trends
	// Clear Estimates
		capture est sto clear	
		
xtile pop_100 = pop if year==1999, n(100)
	sort countycode year
	bysort countycode: carryforward pop_100, replace
	
	capture drop county_time_pop_*
	
	qui	levelsof pop_100
	
	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_100==`x'
	}


	// All
		reghdfe aopioidr unemp_rate county_time_pop_*  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo op_all_none
		reghdfe drugr    unemp_rate  county_time_pop_*  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo drug_all_none			
*******************************************************************************
//ED Visits
*******************************************************************************

// Open data
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear

drop if StateFIPS==21 & year==2009
	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
				
	gen  r_op_dep_any = (op_dep_any/pop_total)*100000
	
	gen  r_op_dep_any_r_w = (op_dep_any_r_w/pop_white)*100000
	gen  r_op_dep_any_r_b = (op_dep_any_r_b/pop_black)*100000
	gen  r_op_dep_any_r_h = (op_dep_any_r_h/pop_hisp)*100000	
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	
	gen  r_her_ovr_any = (her_ovr_any/pop_total)*100000
				
	gen  r_her_ovr_any_r_w = (her_ovr_any_r_w/pop_white)*100000
	gen  r_her_ovr_any_r_b = (her_ovr_any_r_b/pop_black)*100000
	gen  r_her_ovr_any_r_h = (her_ovr_any_r_h/pop_hisp)*100000
	

	
	
// Simplify Variable Names
	rename *any *total //Can't do this earlier because of population
	rename *any* ** 
	
//Create Year Dummies
	tab year, gen(yd)
	
// Create FIPS dummies 
	tab fips, gen(cd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof fips
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if fips==`x'
	}
// Gen Commuter Zone Specific Time Trends
	capture drop _merge
	merge  m:1  StateFIPS CountyFIPS using "$data_path/dorn_data.dta"
	
	qui	levelsof czone
	
	foreach x in `r(levels)' {
		gen czone_time_`x'=0
		replace  czone_time_`x' = time if czone==`x'
	}
*/	
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Generate Recession Binary and Recession or After Binary
	*https://fred.stlouisfed.org/series/USREC
	gen recession_year = 0
	replace recession_year=1 if year==2008 | year ==2009
	
	gen post_recession = 0
	replace post_recession = 1 if year>2009
	
	
// Label Certain Variables
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
     label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
     label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
	 label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
	 
// Make it so we drop hispanic 
	gen hisp_unemp_rate = unemp_rate

// Set Matsize
	set matsize 10000
//100 Time Trends


	xtile pop_100 = pop_total if year==2008, n(100)
	sort fips year
	bysort fips: carryforward pop_100, replace
	replace year = -year
	sort fips year
	bysort fips: carryforward pop_100, replace
	replace year = -year
	sort fips year

	qui levelsof pop_100

	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_100==`x'
	}

		reghdfe r_op_ovr_total unemp_rate   county_time_pop_*  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_op_all_none

		reghdfe r_drug_ovr_total unemp_rate  county_time_pop_*   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_drug_all_none
			
			
		esttab op_all_none drug_all_none e_op_all_none e_drug_all_none  using  "$results_path/appendix/tables/table_a1_different_time_trends.tex" , ///
		keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		f nomtitles substitute(\_ _) nonumbers noobs  noline	collabels(none)   ///
		coef(unemp_rate "\hspace{0.5cm} 100 County Time Trends by Pop. Percentile") 	
/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified Date: 18 October 2016

  Description: Create single table with the perferred spec by Race (All, White, Black, Hisp)
	***DO NOT SHARE CHRIS' DATA***

*/ /////////////////////////////////////////////////////////////////////////////

clear all
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			


	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode
		
// Merge in Controls
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
				
				keep if _merge==3 //Lost 61 observations. Should Figure out Why.
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
				
				keep if _merge==3 // We lose MD 2002 since we don't have that data on poverty for some reason
				//Lost 2001 and 2002
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

				keep if _merge==3
				drop _merge
				

				label variable year "Year"

			// XTSET the data
				xtset countycode year

				
			// Gen Year Dummies
				
				
			// Clean Up
				replace unemp_rate = unemp_rate*100
				label variable unemp_rate "Unemployment Rate, [1-100]"
				replace median_income = median_income/1000
				label variable median_income "Median Income, \\\$1000s"
				gen percent_non_white = (pop-popw)/pop
				label variable percent_non_white "\% Non-White, [0-1]"
	
// Gen Employed to Population Ratio
	gen emp_ratio_all = (numb_emp/pop)*100
	gen emp_ratio_25_54 = (numb_emp/pop_25_54)*100
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	gen emp_ratio_15_up = (numb_emp/pop_15_up)*100


	
	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	label variable aheroinr "Heroin Death Rate per 100k"
	
	label variable drugwr "White Drug Death Rate per 100k"
	label variable aopioidwr "White Opioid Death Rate per 100k"
	label variable aheroinwr "White Heroin Death Rate per 100k"
	
	label variable drugbr "Black Drug Death Rate per 100k"
	label variable aopioidbr "Black Opioid Death Rate per 100k"
	label variable aheroinbr "Black Heroin Death Rate per 100k"

	label variable drughr "Hispanic Drug Death Rate per 100k"
	label variable aopioidbr "Hispanic Opioid Death Rate per 100k"
	label variable aheroinbr "Hispanic Heroin Death Rate per 100k"
	

	label variable year "Year"

// XTSET the data
	xtset countycode year

	
// Gen Year Dummies
	tab year, gen(yd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof countycode
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if countycode==`x'
	}
	*/
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year , gen(st_year_fe_)	
	
	
			
			set matsize 5000
//99 Time Trends and top 1% get own
	// Clear Estimates
		capture est sto clear	
		
	capture drop pop_100
	xtile pop_100 = pop if year==1999, n(100)
	sort countycode year
	bysort countycode: carryforward pop_100, replace
	
	capture drop county_time_pop_*
	
	qui	levelsof pop_100
	
	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_100==`x'
	}
	//Now make a specific time trend for top 1%
		qui	levelsof countycode if pop_100==100
	
		foreach x in `r(levels)' {
			gen county_time_pop_100_`x'=0
			replace  county_time_pop_100_`x' = time if countycode==`x'
		}
		replace pop_100=0 if pop_100==100
		drop county_time_pop_100



	// All
		reghdfe aopioidr unemp_rate county_time_pop_*  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo op_all_none
		reghdfe drugr    unemp_rate  county_time_pop_*  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo drug_all_none			
*******************************************************************************
//ED Visits
*******************************************************************************
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear
drop if StateFIPS==21 & year==2009
	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
				
	gen  r_op_dep_any = (op_dep_any/pop_total)*100000
	
	gen  r_op_dep_any_r_w = (op_dep_any_r_w/pop_white)*100000
	gen  r_op_dep_any_r_b = (op_dep_any_r_b/pop_black)*100000
	gen  r_op_dep_any_r_h = (op_dep_any_r_h/pop_hisp)*100000	
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	
	gen  r_her_ovr_any = (her_ovr_any/pop_total)*100000
				
	gen  r_her_ovr_any_r_w = (her_ovr_any_r_w/pop_white)*100000
	gen  r_her_ovr_any_r_b = (her_ovr_any_r_b/pop_black)*100000
	gen  r_her_ovr_any_r_h = (her_ovr_any_r_h/pop_hisp)*100000
	

	
	
// Simplify Variable Names
	rename *any *total //Can't do this earlier because of population
	rename *any* ** 
	
//Create Year Dummies
	tab year, gen(yd)
	
// Create FIPS dummies 
	tab fips, gen(cd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof fips
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if fips==`x'
	}
// Gen Commuter Zone Specific Time Trends
	capture drop _merge
	merge  m:1  StateFIPS CountyFIPS using "$data_path/dorn_data.dta"
	
	qui	levelsof czone
	
	foreach x in `r(levels)' {
		gen czone_time_`x'=0
		replace  czone_time_`x' = time if czone==`x'
	}
*/	
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Generate Recession Binary and Recession or After Binary
	*https://fred.stlouisfed.org/series/USREC
	gen recession_year = 0
	replace recession_year=1 if year==2008 | year ==2009
	
	gen post_recession = 0
	replace post_recession = 1 if year>2009
	
	
// Label Certain Variables
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
     label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
     label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
	 label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
	 
// Make it so we drop hispanic 
	gen hisp_unemp_rate = unemp_rate

// Set Matsize
	set matsize 10000
//99 Time Trends and top 1% get own


	capture drop pop_100
	capture drop county_time_pop_*

	
	xtile pop_100 = pop_total if year==2008, n(100)
	sort fips year
	bysort fips: carryforward pop_100, replace
	replace year = -year
	sort fips year
	bysort fips: carryforward pop_100, replace
	replace year = -year
	sort fips year

	qui levelsof pop_100

	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_100==`x'
	}

	//Now make a specific time trend for top 1%
		qui	levelsof fips if pop_100==100
	
		foreach x in `r(levels)' {
			gen county_time_pop_100_`x'=0
			replace  county_time_pop_100_`x' = time if fips==`x'
		}
		replace pop_100=0 if pop_100==100
		drop county_time_pop_100

		reghdfe r_op_ovr_total unemp_rate   county_time_pop_*  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_op_all_none

		reghdfe r_drug_ovr_total unemp_rate  county_time_pop_*   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_drug_all_none
			
			
		esttab op_all_none drug_all_none e_op_all_none e_drug_all_none  using  "$results_path/appendix/tables/table_a1_different_time_trends.tex" , ///
		keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		f nomtitles substitute(\_ _) nonumbers noobs  noline	collabels(none)   ///
		coef(unemp_rate "\specialcell{\hspace{0.5cm} Top 1\% of Counties Have a Specific Trend,\\ 99 Other Trends by Pop. Percentile}") 	
/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified Date: 18 October 2016

  Description: Create single table with the perferred spec by Race (All, White, Black, Hisp)
	***DO NOT SHARE CHRIS' DATA***

*/ /////////////////////////////////////////////////////////////////////////////

clear all
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			


	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode
		
// Merge in Controls
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
				
				keep if _merge==3 //Lost 61 observations. Should Figure out Why.
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
				
				keep if _merge==3 // We lose MD 2002 since we don't have that data on poverty for some reason
				//Lost 2001 and 2002
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

				keep if _merge==3
				drop _merge
				

				label variable year "Year"

			// XTSET the data
				xtset countycode year

				
			// Gen Year Dummies
				
				
			// Clean Up
				replace unemp_rate = unemp_rate*100
				label variable unemp_rate "Unemployment Rate, [1-100]"
				replace median_income = median_income/1000
				label variable median_income "Median Income, \\\$1000s"
				gen percent_non_white = (pop-popw)/pop
				label variable percent_non_white "\% Non-White, [0-1]"
	
// Gen Employed to Population Ratio
	gen emp_ratio_all = (numb_emp/pop)*100
	gen emp_ratio_25_54 = (numb_emp/pop_25_54)*100
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	gen emp_ratio_15_up = (numb_emp/pop_15_up)*100


	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	label variable aheroinr "Heroin Death Rate per 100k"
	
	label variable drugwr "White Drug Death Rate per 100k"
	label variable aopioidwr "White Opioid Death Rate per 100k"
	label variable aheroinwr "White Heroin Death Rate per 100k"
	
	label variable drugbr "Black Drug Death Rate per 100k"
	label variable aopioidbr "Black Opioid Death Rate per 100k"
	label variable aheroinbr "Black Heroin Death Rate per 100k"

	label variable drughr "Hispanic Drug Death Rate per 100k"
	label variable aopioidbr "Hispanic Opioid Death Rate per 100k"
	label variable aheroinbr "Hispanic Heroin Death Rate per 100k"
	

	label variable year "Year"

// XTSET the data
	xtset countycode year

	
// Gen Year Dummies
	tab year, gen(yd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof countycode
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if countycode==`x'
	}
	*/
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year , gen(st_year_fe_)	
	

	
			
			set matsize 5000
//19 Time Trends and top 5% get own
	// Clear Estimates
		capture est sto clear	
		
	xtile pop_20 = pop if year==1999, n(20)
	sort countycode year
	bysort countycode: carryforward pop_20, replace
	
	capture drop county_time_pop_*
	
	qui	levelsof pop_20
	
	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_20==`x'
	}
	//Now make a specific time trend for top 5%
		qui	levelsof countycode if pop_20==20
	
		foreach x in `r(levels)' {
			gen county_time_pop_20_`x'=0
			replace  county_time_pop_20_`x' = time if countycode==`x'
		}
		replace pop_20=0 if pop_20==20
		drop county_time_pop_20
		


	// All
		reghdfe aopioidr unemp_rate county_time_pop_*  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo op_all_none
		reghdfe drugr    unemp_rate  county_time_pop_*  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo drug_all_none			
*******************************************************************************
//ED Visits
*******************************************************************************
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear
drop if StateFIPS==21 & year==2009
	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
				
	gen  r_op_dep_any = (op_dep_any/pop_total)*100000
	
	gen  r_op_dep_any_r_w = (op_dep_any_r_w/pop_white)*100000
	gen  r_op_dep_any_r_b = (op_dep_any_r_b/pop_black)*100000
	gen  r_op_dep_any_r_h = (op_dep_any_r_h/pop_hisp)*100000	
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	
	gen  r_her_ovr_any = (her_ovr_any/pop_total)*100000
				
	gen  r_her_ovr_any_r_w = (her_ovr_any_r_w/pop_white)*100000
	gen  r_her_ovr_any_r_b = (her_ovr_any_r_b/pop_black)*100000
	gen  r_her_ovr_any_r_h = (her_ovr_any_r_h/pop_hisp)*100000
	

	
	
// Simplify Variable Names
	rename *any *total //Can't do this earlier because of population
	rename *any* ** 
	
//Create Year Dummies
	tab year, gen(yd)
	
// Create FIPS dummies 
	tab fips, gen(cd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof fips
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if fips==`x'
	}
// Gen Commuter Zone Specific Time Trends
	capture drop _merge
	merge  m:1  StateFIPS CountyFIPS using "$data_path/dorn_data.dta"
	
	qui	levelsof czone
	
	foreach x in `r(levels)' {
		gen czone_time_`x'=0
		replace  czone_time_`x' = time if czone==`x'
	}
*/	
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Generate Recession Binary and Recession or After Binary
	*https://fred.stlouisfed.org/series/USREC
	gen recession_year = 0
	replace recession_year=1 if year==2008 | year ==2009
	
	gen post_recession = 0
	replace post_recession = 1 if year>2009
	
	
// Label Certain Variables
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
     label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
     label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
	 label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
	 
// Make it so we drop hispanic 
	gen hisp_unemp_rate = unemp_rate

// Set Matsize
	set matsize 10000
//19 Time Trends and top 5% get own


	capture drop pop_100
	capture drop county_time_pop_*

	
	xtile pop_100 = pop_total if year==2008, n(20)
	sort fips year
	bysort fips: carryforward pop_100, replace
	replace year = -year
	sort fips year
	bysort fips: carryforward pop_100, replace
	replace year = -year
	sort fips year

	qui levelsof pop_100

	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_100==`x'
	}

	//Now make a specific time trend for top 1%
		qui	levelsof fips if pop_100==20
	
		foreach x in `r(levels)' {
			gen county_time_pop_100_`x'=0
			replace  county_time_pop_100_`x' = time if fips==`x'
		}
		replace pop_100=0 if pop_100==20
		capture drop county_time_pop_100

		reghdfe r_op_ovr_total unemp_rate   county_time_pop_*  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_op_all_none

		reghdfe r_drug_ovr_total unemp_rate  county_time_pop_*   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
			eststo e_drug_all_none
			
			
		esttab op_all_none drug_all_none e_op_all_none e_drug_all_none  using  "$results_path/appendix/tables/table_a1_different_time_trends.tex" , ///
		keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		f nomtitles substitute(\_ _) nonumbers noobs  noline	collabels(none)   ///	
		coef(unemp_rate "\specialcell{\hspace{0.5cm} Top 5\% of Counties Have a Specific Trend,\\ 19 Other Trends by Pop. Vigintile}") 	
/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified Date: 18 October 2016

  Description: Create single table with the perferred spec by Race (All, White, Black, Hisp)
	***DO NOT SHARE CHRIS' DATA***

*/ /////////////////////////////////////////////////////////////////////////////

clear all
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			


	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode
		
// Merge in Controls
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
				
				keep if _merge==3 //Lost 61 observations. Should Figure out Why.
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
				
				keep if _merge==3 // We lose MD 2002 since we don't have that data on poverty for some reason
				//Lost 2001 and 2002
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

				keep if _merge==3
				drop _merge
				

				label variable year "Year"

			// XTSET the data
				xtset countycode year

				
			// Gen Year Dummies				
				
			// Clean Up
				replace unemp_rate = unemp_rate*100
				label variable unemp_rate "Unemployment Rate, [1-100]"
				replace median_income = median_income/1000
				label variable median_income "Median Income, \\\$1000s"
				gen percent_non_white = (pop-popw)/pop
				label variable percent_non_white "\% Non-White, [0-1]"
	
// Gen Employed to Population Ratio
	gen emp_ratio_all = (numb_emp/pop)*100
	gen emp_ratio_25_54 = (numb_emp/pop_25_54)*100
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	gen emp_ratio_15_up = (numb_emp/pop_15_up)*100


	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	label variable aheroinr "Heroin Death Rate per 100k"
	
	label variable drugwr "White Drug Death Rate per 100k"
	label variable aopioidwr "White Opioid Death Rate per 100k"
	label variable aheroinwr "White Heroin Death Rate per 100k"
	
	label variable drugbr "Black Drug Death Rate per 100k"
	label variable aopioidbr "Black Opioid Death Rate per 100k"
	label variable aheroinbr "Black Heroin Death Rate per 100k"

	label variable drughr "Hispanic Drug Death Rate per 100k"
	label variable aopioidbr "Hispanic Opioid Death Rate per 100k"
	label variable aheroinbr "Hispanic Heroin Death Rate per 100k"
	

	label variable year "Year"

// XTSET the data
	xtset countycode year

	
// Gen Year Dummies
	tab year, gen(yd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof countycode
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if countycode==`x'
	}
	*/
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year , gen(st_year_fe_)	
	

	
			
			set matsize 5000
// Commuter Zone Specific Time Trends
	// Clear Estimates
		capture est sto clear	
		
capture drop _merge
	merge  m:1  StateFIPS CountyFIPS using "$data_path/dorn_data.dta"
	
	qui	levelsof czone
	
	foreach x in `r(levels)' {
		gen czone_time_`x'=0
		replace  czone_time_`x' = time if czone==`x'
	}
	
		


	// All
		reghdfe aopioidr unemp_rate [aweight=pop], absorb(i.czone#c.year countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo op_all_none
		reghdfe drugr    unemp_rate  [aweight=pop], absorb(i.czone#c.year countycode state_year year) vce(cluster countycode)   keepsingletons			
			eststo drug_all_none			
*******************************************************************************
//ED Visits
*******************************************************************************
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear
drop if StateFIPS==21 & year==2009
	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
				
	gen  r_op_dep_any = (op_dep_any/pop_total)*100000
	
	gen  r_op_dep_any_r_w = (op_dep_any_r_w/pop_white)*100000
	gen  r_op_dep_any_r_b = (op_dep_any_r_b/pop_black)*100000
	gen  r_op_dep_any_r_h = (op_dep_any_r_h/pop_hisp)*100000	
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	
	gen  r_her_ovr_any = (her_ovr_any/pop_total)*100000
				
	gen  r_her_ovr_any_r_w = (her_ovr_any_r_w/pop_white)*100000
	gen  r_her_ovr_any_r_b = (her_ovr_any_r_b/pop_black)*100000
	gen  r_her_ovr_any_r_h = (her_ovr_any_r_h/pop_hisp)*100000
	

	
	
// Simplify Variable Names
	rename *any *total //Can't do this earlier because of population
	rename *any* ** 
	
//Create Year Dummies
	tab year, gen(yd)
	
// Create FIPS dummies 
	tab fips, gen(cd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	/*
	qui levelsof fips
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if fips==`x'
	}
// Gen Commuter Zone Specific Time Trends
	capture drop _merge
	merge  m:1  StateFIPS CountyFIPS using "$data_path/dorn_data.dta"
	
	qui	levelsof czone
	
	foreach x in `r(levels)' {
		gen czone_time_`x'=0
		replace  czone_time_`x' = time if czone==`x'
	}
*/	
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Generate Recession Binary and Recession or After Binary
	*https://fred.stlouisfed.org/series/USREC
	gen recession_year = 0
	replace recession_year=1 if year==2008 | year ==2009
	
	gen post_recession = 0
	replace post_recession = 1 if year>2009
	
	
// Label Certain Variables
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
     label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
     label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
	 label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
	 
// Make it so we drop hispanic 
	gen hisp_unemp_rate = unemp_rate

// Set Matsize
	set matsize 10000
// Commuter Zone Specific Time Trends


	capture drop _merge
	merge  m:1  StateFIPS CountyFIPS using "$data_path/dorn_data.dta"
	
	qui	levelsof czone
	
	foreach x in `r(levels)' {
		gen czone_time_`x'=0
		replace  czone_time_`x' = time if czone==`x'
	}

		reghdfe r_op_ovr_total unemp_rate    [aweight=pop_total], absorb(i.czone#c.year  fips state_year year) vce(cluster fips)   
			eststo e_op_all_none

		reghdfe r_drug_ovr_total unemp_rate   [aweight=pop_total], absorb(i.czone#c.year  fips state_year year) vce(cluster fips)   
			eststo e_drug_all_none
			
			
		esttab op_all_none drug_all_none e_op_all_none e_drug_all_none  using  "$results_path/appendix/tables/table_a1_different_time_trends.tex" , ///
		keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		f nomtitles substitute(\_ _) nonumbers noobs  noline	collabels(none)   ///
		coef(unemp_rate "\hspace{0.5cm} Commuter Zone Specific Time Trends")
/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified Date: 18 October 2016

  Description: Create single table with the perferred spec by Race (All, White, Black, Hisp)
	***DO NOT SHARE CHRIS' DATA***

*/ /////////////////////////////////////////////////////////////////////////////

clear all
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			


	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode
		
// Merge in Controls
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
				
				keep if _merge==3 //Lost 61 observations. Should Figure out Why.
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
				
				keep if _merge==3 // We lose MD 2002 since we don't have that data on poverty for some reason
				//Lost 2001 and 2002
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

				keep if _merge==3
				drop _merge
				

				label variable year "Year"

			// XTSET the data
				xtset countycode year

				
			// Gen Year Dummies				
				
			// Clean Up
				replace unemp_rate = unemp_rate*100
				label variable unemp_rate "Unemployment Rate, [1-100]"
				replace median_income = median_income/1000
				label variable median_income "Median Income, \\\$1000s"
				gen percent_non_white = (pop-popw)/pop
				label variable percent_non_white "\% Non-White, [0-1]"
	
// Gen Employed to Population Ratio
	gen emp_ratio_all = (numb_emp/pop)*100
	gen emp_ratio_25_54 = (numb_emp/pop_25_54)*100
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	gen emp_ratio_15_up = (numb_emp/pop_15_up)*100

	
	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	label variable aheroinr "Heroin Death Rate per 100k"
	
	label variable drugwr "White Drug Death Rate per 100k"
	label variable aopioidwr "White Opioid Death Rate per 100k"
	label variable aheroinwr "White Heroin Death Rate per 100k"
	
	label variable drugbr "Black Drug Death Rate per 100k"
	label variable aopioidbr "Black Opioid Death Rate per 100k"
	label variable aheroinbr "Black Heroin Death Rate per 100k"

	label variable drughr "Hispanic Drug Death Rate per 100k"
	label variable aopioidbr "Hispanic Opioid Death Rate per 100k"
	label variable aheroinbr "Hispanic Heroin Death Rate per 100k"
	

	label variable year "Year"

// XTSET the data
	xtset countycode year

	
// Gen Year Dummies
	tab year, gen(yd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	
	qui levelsof countycode
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if countycode==`x'
	}
	
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year , gen(st_year_fe_)	
	

	
			
			set matsize 5000
// County  Specific Time Trends



	// All
		reghdfe aopioidr unemp_rate    [aweight=pop], absorb(i.countycode#c.year countycode state_year year) vce(cluster countycode)   keepsingletons			
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local state_by_year "Yes"
			eststo op_all_none
		reghdfe drugr    unemp_rate    [aweight=pop], absorb(i.countycode#c.year countycode state_year year) vce(cluster countycode)   keepsingletons			
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local state_by_year "Yes"
		eststo drug_all_none			
*******************************************************************************
//ED Visits
*******************************************************************************
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear
drop if StateFIPS==21 & year==2009
	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
				
	gen  r_op_dep_any = (op_dep_any/pop_total)*100000
	
	gen  r_op_dep_any_r_w = (op_dep_any_r_w/pop_white)*100000
	gen  r_op_dep_any_r_b = (op_dep_any_r_b/pop_black)*100000
	gen  r_op_dep_any_r_h = (op_dep_any_r_h/pop_hisp)*100000	
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	
	gen  r_her_ovr_any = (her_ovr_any/pop_total)*100000
				
	gen  r_her_ovr_any_r_w = (her_ovr_any_r_w/pop_white)*100000
	gen  r_her_ovr_any_r_b = (her_ovr_any_r_b/pop_black)*100000
	gen  r_her_ovr_any_r_h = (her_ovr_any_r_h/pop_hisp)*100000
	

	
	
// Simplify Variable Names
	rename *any *total //Can't do this earlier because of population
	rename *any* ** 
	
//Create Year Dummies
	tab year, gen(yd)
	
// Create FIPS dummies 
	tab fips, gen(cd)
	
// Gen County Specific Time Trends
	gen time = 1 + year - 1999
	
	qui levelsof fips
	foreach x in `r(levels)' {
		gen county_time_`x'=0
		replace  county_time_`x' = time if fips==`x'
	}

*
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Generate Recession Binary and Recession or After Binary
	*https://fred.stlouisfed.org/series/USREC
	gen recession_year = 0
	replace recession_year=1 if year==2008 | year ==2009
	
	gen post_recession = 0
	replace post_recession = 1 if year>2009
	
	
// Label Certain Variables
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
     label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
     label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
	 label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
	 
// Make it so we drop hispanic 
	gen hisp_unemp_rate = unemp_rate

// Set Matsize
	set matsize 10000
// County  Specific Time Trends


		reghdfe r_op_ovr_total unemp_rate    [aweight=pop_total], absorb(i.fips#c.year fips state_year year) vce(cluster fips)   
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local state_by_year "Yes"
			eststo e_op_all_none

		reghdfe r_drug_ovr_total unemp_rate     [aweight=pop_total], absorb(i.fips#c.year fips state_year year) vce(cluster fips)   
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local state_by_year "Yes"
			eststo e_drug_all_none
			
			
		esttab op_all_none drug_all_none e_op_all_none e_drug_all_none  using  "$results_path/appendix/tables/table_a1_different_time_trends.tex" , ///
		keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		f nomtitles substitute(\_ _) nonumbers   noline	collabels(none)   ///
		coef(unemp_rate "\hspace{0.5cm} County Specific Time Trends") ///
		stats(N  state_fe year_dum  state_by_year, fmt(0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("Observations" "\hline County Fixed-Effects" "Year Fixed-Effects"    "State-by-Year Fixed-Effects")) ///
	




