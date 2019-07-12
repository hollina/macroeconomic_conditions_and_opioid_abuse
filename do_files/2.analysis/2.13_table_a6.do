	local race all
	// Open up death rate file created by Chris Ruhm
	use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear	
	
	// Make a variable for race
		gen all=0
		gen white =0
		gen black = 0
		gen hisp = 0

	// Indicate Chosen Option
		replace `race' = 1
		
	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode
	// Merge in Controls
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
		label variable aopioidhr "Hispanic Opioid Death Rate per 100k"
		label variable aheroinhr "Hispanic Heroin Death Rate per 100k"
/*		
	// Fix Population - We need to check this
		local pop_list pop popw popb poph pop_total pop_white pop_black pop_hisp
		foreach var in `pop_list' {
			replace `var' = 0 if missing(`var')
		}
	// Fix Rate- We need to check this
		local rate_list drugr aopioidr aheroinr popioidr pheroinr  opioidr heroinr
		foreach var in `rate_list' {
			replace `var' = . if pop==0
			replace `var' = 0 if pop!=0 & missing(`var')

		}
		
		replace percent_hispanic = 0 if pop_hisp==0 | poph==0
		
		local rate_list drugwr aopioidwr aheroinwr  popioidwr pheroinwr  opioidwr heroinwr
		foreach var in `rate_list' {
			replace `var' = . if popw==0
			replace `var' = 0 if popw!=0 & missing(`var')

		}
		
		local rate_list drugbr aopioidbr aheroinbr  popioidbr pheroinbr   opioidbr heroinbr
		foreach var in `rate_list' {
			replace `var' = . if popb==0
			replace `var' = 0 if popb!=0 & missing(`var')

		}	
		
		local rate_list drughr aopioidhr aheroinhr  popioidhr pheroinhr   opioidhr heroinhr
		foreach var in `rate_list' {
			replace `var' = . if poph==0
			replace `var' = 0 if poph!=0 & missing(`var')

		}	
*/		
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
	
	//State x Year FE
		egen state_year = group( StateFIPS year)
		qui tab state_year, gen(st_year_fe_)	
		
	// Clean Up
		replace unemp_rate = unemp_rate*100
		label variable unemp_rate "Unemployment Rate, [0-100]"
		replace median_income = median_income/1000
		label variable median_income "Median Income, \\\$1000s"
		gen percent_non_white = (pop-popw)/pop
		label variable percent_non_white "\% Non-White, [0-1]"
	

					
	// Run Specifications
		set matsize 11000
		if all==1 {
			local drug_list  aheroinr
		
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' unemp_rate [aweight=pop], absorb(countycode year) vce(cluster countycode)  
					    sum `var'  [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
				 reghdfe `var' unemp_rate  [aweight=pop], absorb(i.countycode#c.year countycode year) vce(cluster countycode)  
					    sum `var' [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean					//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"
					
					estimates save  "$temp_path/`var'_cty_trend", replace
					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons
					    sum `var' [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean					
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"
					
					estimates save  "$temp_path/`var'_st_year_fe", replace
					estimates store `var'_spec_3, nocopy

					
				qui reghdfe `var' unemp_rate   median_income  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)   keepsingletons
					    sum `var' [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean					
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
			
				
					local lbl: variable  label `var'
					local lbl2: variable  label unemp_rate
					local lbl3: variable  label median_income

	
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  using "$results_path/appendix/tables/table_a6_`race'_county_combined_robust_se_heroin_only.tex" , ///
				keep(unemp_rate )  label star(* 0.10 ** 0.05 *** 0.01) ///
				replace se order(unemp_rate) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(Mean N, fmt(%3.2f 0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" )) ///
				f nomtitles substitute(\_ _) ///
				refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
				coef(unemp_rate "\hspace{0.5cm}`lbl2'" ) noline
				
				capture est clear
			}
		}
		
	local race all
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear
	
	// Make a variable for race
		gen all=0
		gen white =0
		gen black = 0
		gen hisp = 0

	// Indicate Chosen Option
		replace `race' = 1

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
	 
     label var r_op_ovr__r_w "White Opioid Dependence ED Visit Rate per 100k"
     
     label var r_op_ovr__r_b "Black Opioid Dependence ED Visit Rate per 100k"
	 
     label var r_op_ovr__r_h "Hispanic Opioid Dependence ED Visit Rate per 100k"

		 label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
		 label var r_drug_ovr__r_w "White Drug Overdose ED Visit Rate per 100k"
		 label var r_drug_ovr__r_b "Black Drug Overdose ED Visit Rate per 100k"
		 label var r_drug_ovr__r_h "Hispanic Drug Overdose ED Visit Rate per 100k"

		label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
		label var r_her_ovr__r_w "White Heroin Overdose ED Visit Rate per 100k"
		label var r_her_ovr__r_b "Black Heroin Overdose ED Visit Rate per 100k"
		label var r_her_ovr__r_h "Hispanic Heroin Overdose ED Visit Rate per 100k"	 
	
	if all==1 {
		
		
		
		
		
		
		
		
		local y_list r_her_ovr_total 

		foreach y in `y_list' {
	
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_total], absorb(fips year) vce(cluster fips)   
															    sum `y' [aweight=pop_total], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1

				*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate  [aweight=pop_total], absorb(i.fips#c.year fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
						sum `y' [aweight=pop_total], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
						estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
										estimates save  "$temp_path/`y'_cty_trend", replace

					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)  
															    sum `y' [aweight=pop_total], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
										estimates save  "$temp_path/`y'_st_year_fe", replace

					estimates store `y'_3			
	
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate median_income [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
															    sum `y' [aweight=pop_total], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3   using "$results_path/appendix/tables/table_a6_`race'_county_combined_robust_se_heroin_only.tex" , ///
		keep(unemp_rate )  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate ) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(Mean N state_fe year_dum  county_trend state_year_fe, fmt(%3.2f 0 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
		f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'" ) noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		}
		
		
		
