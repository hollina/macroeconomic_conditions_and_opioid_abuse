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
	
	
// Gen Employed to Population Ratio
	gen emp_ratio_all = (numb_emp/pop)*100
	gen emp_ratio_25_54 = (numb_emp/pop_25_54)*100
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	gen emp_ratio_15_up = (numb_emp/pop_15_up)*100

	
	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	
	label variable drugwr "White Drug Death Rate per 100k"
	label variable aopioidwr "White Opioid Death Rate per 100k"
	
	label variable drugbr "Black Drug Death Rate per 100k"
	label variable aopioidbr "Black Opioid Death Rate per 100k"

	label variable drughr "Hispanic Drug Death Rate per 100k"
	label variable aopioidbr "Hispanic Opioid Death Rate per 100k"
	
	label variable emp_ratio_15_64 "Employment to Population Ratio"


	label variable year "Year"
	
// Set Matsize
	set matsize 10000

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
// Gen County  Time Trend for 19 5% population bins and county specific in the top 5%
 
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
		
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year , gen(st_year_fe_)	
	
// Clean Up
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "\hspace{0.5cm}Median Income, \\$1000s"
	gen percent_non_white = (pop-popw)/pop
	label variable percent_non_white "\% Non-White, [0-1]"


	reghdfe drugr unemp_rate median_income [aweight=pop] , absorb(countycode state_year year) vce(cluster countycode)  		keepsingletons
		sum drugr, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
		
		lincom (unemp_rate/Mean)*100
			scalar Percent_Inc = r(estimate)
			estadd scalar Percent_Inc
			
		estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "Yes"
		estadd local state_by_year "Yes"
				eststo drug_all

	reghdfe drugwr unemp_rate  median_income [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  	keepsingletons
		    sum drugwr, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean			
					
		lincom (unemp_rate/Mean)*100
			scalar Percent_Inc = r(estimate)
			estadd scalar Percent_Inc
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "Yes"
		estadd local state_by_year "Yes"
		
		eststo drug_white
		
	reghdfe drugbr unemp_rate  median_income  [aweight=popb] if popb!=0 , absorb(countycode state_year year) vce(cluster countycode)  	keepsingletons
		    sum drugbr, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean		
					
		lincom (unemp_rate/Mean)*100
			scalar Percent_Inc = r(estimate)
			estadd scalar Percent_Inc
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "Yes"
		estadd local state_by_year "Yes"
		
		eststo drug_black
		
		
	reghdfe drughr unemp_rate median_income  [aweight=poph] if poph!=0 , absorb(countycode state_year year) vce(cluster countycode)  	keepsingletons
		    sum drughr, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
				
		lincom (unemp_rate/Mean)*100
			scalar Percent_Inc = r(estimate)
			estadd scalar Percent_Inc
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "Yes"
		estadd local state_by_year "Yes"
		
		eststo drug_hisp	
		

	
	reghdfe aopioidr unemp_rate  median_income  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)  	keepsingletons
			    sum aopioidr, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean				
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "Yes"
		estadd local state_by_year "Yes"
		
		eststo op_all
		
		
	reghdfe aopioidwr unemp_rate  median_income  [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  	keepsingletons
		    sum aopioidwr, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean					
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "Yes"
		estadd local state_by_year "Yes"
		
		eststo op_white

	reghdfe aopioidbr unemp_rate  median_income [aweight=popb] if popb!=0, absorb(countycode state_year year) vce(cluster countycode)  	keepsingletons
			    sum aopioidbr, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean				
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "Yes"
		estadd local state_by_year "Yes"
		
		eststo op_black

	reghdfe aopioidhr unemp_rate median_income  [aweight=poph] if poph!=0, absorb(countycode state_year year) vce(cluster countycode)  	keepsingletons
			    sum aopioidhr, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean				
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "Yes"
		estadd local state_by_year "Yes"
		
		eststo op_hisp
		
		
	local lbl: variable  label aopioidr 
	local lbl2: variable  label unemp_rate

	esttab op_all op_white  op_black op_hisp using  "$results_path/appendix/tables/table_a3_county_by_race_median_income.tex" , ///
	keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
	replace se order(unemp_rate median_income) ///
	booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
	stats( Mean N, fmt(%3.2f  0  ) layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label(   "\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations")) ///
	f mtitles("All" "White" "Black" "Hispanic") substitute(\_ _) ///
	refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
	coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline	
	
	
		
		
	local lbl: variable  label drugr
	local lbl2: variable  label unemp_rate
	
 	esttab drug_all drug_white  drug_black drug_hisp  using  "$results_path/appendix/tables/table_a3_county_by_race_median_income.tex" , ///
	keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
	append se order(unemp_rate median_income) ///
	booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
	stats(Mean N , fmt(%3.2f 0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ) label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations")) ///
	f nomtitles substitute(\_ _) ///
	refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
	coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline collabels(none) nonumbers 	

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
				
	gen  r_op_dep_any = (op_dep_any/pop_total)*100000
	
	gen  r_op_dep_any_r_w = (op_dep_any_r_w/pop_white)*100000
	gen  r_op_dep_any_r_b = (op_dep_any_r_b/pop_black)*100000
	gen  r_op_dep_any_r_h = (op_dep_any_r_h/pop_hisp)*100000	
	
	gen  r_drug_ovr_any = (drug_ovr_any/pop_total)*100000
				
	gen  r_drug_ovr_any_r_w = (drug_ovr_any_r_w/pop_white)*100000
	gen  r_drug_ovr_any_r_b = (drug_ovr_any_r_b/pop_black)*100000
	gen  r_drug_ovr_any_r_h = (drug_ovr_any_r_h/pop_hisp)*100000
	
	

	
	
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
// Gen County Time Trends
	xtile pop_20 = pop_total if year==2008, n(20)
	sort fips year
	bysort fips: carryforward pop_20, replace
	replace year = -year
	sort fips year
	bysort fips: carryforward pop_20, replace
	replace year = -year
	sort fips year

	capture drop county_time_pop_*
	
	qui	levelsof pop_20
	
	foreach x in `r(levels)' {
		gen county_time_pop_`x'=0
		replace  county_time_pop_`x' = time if pop_20==`x'
	}
	//Now make a specific time trend for top 5%
		qui	levelsof fips if pop_20==20
	
		foreach x in `r(levels)' {
			gen county_time_pop_20_`x'=0
			replace  county_time_pop_20_`x' = time if fips==`x'
		}
		replace pop_20=0 if pop_20==20
		drop county_time_pop_20
	
	
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
	label variable median_income "\hspace{0.5cm}Median Income, \\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
     label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
     label var r_op_dep_total "Opioid Dependence ED Visit Rate per 100k"
     label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
	 
// Make it so we drop hispanic 
	gen hisp_unemp_rate = unemp_rate

// Set Matsize
	set matsize 10000

				
//Drug Overdoses 
			 reghdfe r_drug_ovr_total unemp_rate median_income [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
		    sum r_drug_ovr_total, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto dep_all 
				
			reghdfe r_drug_ovr__r_w unemp_rate  median_income  [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)   
		    sum r_drug_ovr__r_w, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto dep_white		
			
			reghdfe r_drug_ovr__r_b unemp_rate median_income   [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)   
			    sum r_drug_ovr__r_b, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean								
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto dep_black
				
				
			reghdfe r_drug_ovr__r_h hisp_unemp_rate median_income   [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)   
 
			scalar Mean = .		
			estadd scalar Mean		

				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto dep_hisp
				
	

//Opioid Overdoes
			 reghdfe r_op_ovr_total unemp_rate median_income [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
		    sum r_op_ovr_total, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ovr_all 
				
			reghdfe r_op_ovr__r_w unemp_rate  median_income  [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)   
			    sum r_op_ovr__r_w, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean						
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ovr_white		
			
			reghdfe r_op_ovr__r_b unemp_rate median_income   [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)   
		    sum r_op_ovr__r_b, meanonly
			scalar Mean = r(mean)
			estadd scalar Mean									
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ovr_black
				
			reghdfe r_op_ovr__r_h hisp_unemp_rate  median_income  [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)   

			scalar Mean = .
			estadd scalar Mean							
				estadd local year_dum "Yes"
				estadd local state_fe "Yes"
				estadd local county_trend "No"
				estadd local state_by_year "Yes"
				

				est sto ovr_hisp
				
	local lbl: variable  label r_op_ovr_total
	local lbl2: variable  label unemp_rate		
				
			esttab ovr_all ovr_white  ovr_black ovr_hisp  using  "$results_path/appendix/tables/table_a3_county_by_race_median_income.tex" , ///
			keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
			append se order(unemp_rate median_income) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N , fmt(%3.2f 0  ) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations")) ///
			f nomtitles substitute(\_ _) ///
			refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
			coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline collabels(none) nonumbers 	

				
				
	local lbl: variable  label r_drug_ovr_total 
	local lbl2: variable  label unemp_rate		

	esttab dep_all dep_white  dep_black dep_hisp using  "$results_path/appendix/tables/table_a3_county_by_race_median_income.tex" , ///
	keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
	append se order(unemp_rate median_income) ///
	booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
	stats(Mean N  state_fe year_dum  county_trend state_by_year, fmt( %3.2f 0  0 0 0 0 ) ///
	layout( "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations"  "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
	f nomtitles substitute(\_ _) ///
	refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
	coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline collabels(none) nonumbers 
