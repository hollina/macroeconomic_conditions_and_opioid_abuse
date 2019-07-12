/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 28 November 2016
  
  Last Modified Date: 28 November 2016

  Description: 

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

// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Clean Up
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	gen percent_non_white = (pop-popw)/pop
	label variable percent_non_white "\% Non-White, [0-1]"

// Gen Non-Opioid Non-Heroin Drug Deaths
	replace anoopr = 0 if anoopr<0
	replace anoopher = 0 if anoopher<0

	
	label variable anoopr "Drug Death Rate per 100k, Exluding Opioids"
	label variable anoopher "Drug Death Rate per 100k, Exluding Opioids and Heroin"


// Drug Deaths by Race

	reghdfe drugr unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons
	
	sum drugr [aweight=pop], meanonly
	scalar Mean = r(mean)
	estadd scalar Mean
	
	lincom unemp_rate/Mean
	scalar Percent = r(estimate)*100
	estadd scalar Percent 
	
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo drug_all
		
	reghdfe aopioidr unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons
	sum aopioidr [aweight=pop], meanonly
	scalar Mean = r(mean)
	estadd scalar Mean
	
	lincom unemp_rate/Mean
	scalar Percent = r(estimate)*100
	estadd scalar Percent 
		 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo drug_op
		
	reghdfe aheroinr unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons
	sum aheroinr [aweight=pop], meanonly
	scalar Mean = r(mean)
	estadd scalar Mean
		
	lincom unemp_rate/Mean
	scalar Percent = r(estimate)*100
	estadd scalar Percent 
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo drug_her
		
	reghdfe anoopr unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons
	sum anoopr [aweight=pop], meanonly
	scalar Mean = r(mean)
	estadd scalar Mean
	 	
	lincom unemp_rate/Mean
	scalar Percent = r(estimate)*100
	estadd scalar Percent 
		estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo drug_nop
		
	reghdfe anoopher unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons
		sum anoopher [aweight=pop], meanonly
	scalar Mean = r(mean)
	estadd scalar Mean
	 	
	lincom unemp_rate/Mean
	scalar Percent = r(estimate)*100
	estadd scalar Percent 
		estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo drug_nopher
		
		local lbl2: variable  label unemp_rate

		esttab drug_all drug_op drug_her drug_nop drug_nopher using "$results_path/appendix/tables/table_a5_no_op_county_by_race.tex" , ///
	keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
	replace se order(unemp_rate) ///
	booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
	stats(Mean N , fmt(%3.2f 0  ) layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations")) ///
	f mtitles("All Drugs" "Only Opioids" "Only Heroin" "All Excluding Opioids" "All Excluding Both") substitute(\_ _) ///
	refcat(unemp_rate "\midrule \emph{Deaths per 100k}", nolabel)	///
	coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline	
		

*******************************************************************************
//ED Visits
*******************************************************************************
clear all
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta"
drop if StateFIPS==21 & year==2009
	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
				
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	
	gen  r_her_ovr_any = (her_ovr_any/pop_total)*100000
				
	gen  r_her_ovr_any_r_w = (her_ovr_any_r_w/pop_white)*100000
	gen  r_her_ovr_any_r_b = (her_ovr_any_r_b/pop_black)*100000
	gen  r_her_ovr_any_r_h = (her_ovr_any_r_h/pop_hisp)*100000
	

// Gen Non-Opioid Non-Heroin Drug Deaths
	gen no_op_her_drugr = drug_ovr_any - op_ovr_any - her_ovr_any + oah_ovr_any
	gen r_no_op_her_drugr = (no_op_her_drugr/pop_total)*100000
	label variable r_no_op_her_drugr "Drug ED Visit Rate per 100k, Exluding Opioids and Heroin"

	gen no_op_drugr = drug_ovr_any - op_ovr_any 
	gen r_no_op_drugr = (no_op_drugr/pop_total)*100000
	label variable r_no_op_drugr "Drug ED Visit Rate per 100k, Exluding Opioids"

	
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


//Drug Overdoses 
			 reghdfe r_drug_ovr_total unemp_rate  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
				sum r_drug_ovr_total [aweight=pop_total], meanonly
				scalar Mean = r(mean)
				estadd scalar Mean
	 	
							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ed_all 
				
			reghdfe r_op_ovr_total unemp_rate  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
				sum r_op_ovr_total [aweight=pop_total], meanonly
				scalar Mean = r(mean)
				estadd scalar Mean
	 	
							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ed_op 	
				
			reghdfe r_her_ovr_total unemp_rate  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
				sum r_her_ovr_total [aweight=pop_total], meanonly
				scalar Mean = r(mean)
				estadd scalar Mean
	 	
							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ed_her 		
				
			reghdfe r_no_op_drugr unemp_rate  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
				sum r_no_op_drugr [aweight=pop_total], meanonly
				scalar Mean = r(mean)
				estadd scalar Mean
	 	
							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ed_nop
				
 			reghdfe r_no_op_her_drugr unemp_rate  [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
				sum r_no_op_her_drugr [aweight=pop_total], meanonly
				scalar Mean = r(mean)
				estadd scalar Mean
	 	
							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ed_nopher	
				
			local lbl: variable  label no_op_drugr
			local lbl2: variable  label unemp_rate		
				
			esttab ed_all ed_op ed_her ed_nop ed_nopher using "$results_path/appendix/tables/table_a5_no_op_county_by_race.tex" , ///
			keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
			append se order(unemp_rate) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N state_fe year_dum  county_trend state_by_year, fmt(%3.2f 0  0 0 0 0 ) ///
			layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
			label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
			f nomtitles substitute(\_ _) ///
			refcat(unemp_rate "\midrule \emph{ED Visits per 100k}", nolabel)	///
			coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline collabels(none) nonumbers 

	
		
