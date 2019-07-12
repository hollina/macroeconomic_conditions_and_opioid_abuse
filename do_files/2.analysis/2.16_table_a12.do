/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified Date: 18 October 2016

  Description: Create a table with multiple specifications for each race (All, white, black, hisp)
	***DO NOT SHARE CHRIS' DATA***

*/ /////////////////////////////////////////////////////////////////////////////

clear all

capture program drop specification_table_by_race
*----------
program define specification_table_by_race
*----------
syntax, race(string) 

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
	
	local new_list	pharm_ovr_any 	benz_dep_any 	aro_dep_any 	adep_dep_any 	ins_dep_any 	coke_dep_any	 psyc_dep_any	 
	
	foreach x in `new_list' {
	gen  r_`x' = (`x'/pop_total)*100000
				
	gen  r_`x'_r_w = (`x'_r_w/pop_white)*100000
	gen  r_`x'_r_b = (`x'_r_b/pop_black)*100000
	gen  r_`x'_r_h = (`x'_r_h/pop_hisp)*100000
	}

// Simplify Variable Names
	rename *any *total //Can't do this earlier because of population
	rename *any* ** 
	
//Create Year Dummies
	tab year, gen(yd)
	
// Create FIPS dummies 
	tab fips, gen(cd)
	
// Gen County Specific Time Trends
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
	
		label var r_pharm_ovr_total "Pharmaceutical Overdose ED Visit Rate per 100k"
		label var r_pharm_ovr__r_w "White Pharmaceutical Overdose ED Visit Rate per 100k"
		label var r_pharm_ovr__r_b "Black Pharmaceutical Overdose ED Visit Rate per 100k"
		label var r_pharm_ovr__r_h "Hispanic Pharmaceutical Overdose ED Visit Rate per 100k"	 
			
		label var r_benz_dep_total "Benzo Overdose ED Visit Rate per 100k"
		label var r_benz_dep__r_w "White Benzo Overdose ED Visit Rate per 100k"
		label var r_benz_dep__r_b "Black Benzo Overdose ED Visit Rate per 100k"
		label var r_benz_dep__r_h "Hispanic Benzo Overdose ED Visit Rate per 100k"	 
	
	
		label var r_aro_dep_total "Aro. Analgesic Overdose ED Visit Rate per 100k"
		label var r_aro_dep__r_w "White Aro. Analgesic Overdose ED Visit Rate per 100k"
		label var r_aro_dep__r_b "Black Aro. Analgesic Overdose ED Visit Rate per 100k"
		label var r_aro_dep__r_h "Hispanic Aro. Analgesic Overdose ED Visit Rate per 100k"	 
	
		
		label var r_adep_dep_total "Anti-depressant Overdose ED Visit Rate per 100k"
		label var r_adep_dep__r_w "White Anti-depressant Overdose ED Visit Rate per 100k"
		label var r_adep_dep__r_b "Black Anti-depressant Overdose ED Visit Rate per 100k"
		label var r_adep_dep__r_h "Hispanic Anti-depressant Overdose ED Visit Rate per 100k"	 
	
			
		label var r_psyc_dep_total "Anti-Psychotic Overdose ED Visit Rate per 100k"
		label var r_psyc_dep__r_w "White Anti-Psychotic Overdose ED Visit Rate per 100k"
		label var r_psyc_dep__r_b "Black Anti-Psychotic Overdose ED Visit Rate per 100k"
		label var r_psyc_dep__r_h "Hispanic Anti-Psychotic Overdose ED Visit Rate per 100k"	 
	
					
			
		label var r_ins_dep_total "Insulin Overdose ED Visit Rate per 100k"
		label var r_ins_dep__r_w "White Insulin Overdose ED Visit Rate per 100k"
		label var r_ins_dep__r_b "Black Insulin Overdose ED Visit Rate per 100k"
		label var r_ins_dep__r_h "Hispanic Insulin Overdose ED Visit Rate per 100k"	 
	
		label var r_coke_dep_total "Cocaine Overdose ED Visit Rate per 100k"
		label var r_coke_dep__r_w "White Cocaine Overdose ED Visit Rate per 100k"
		label var r_coke_dep__r_b "Black Cocaine Overdose ED Visit Rate per 100k"
		label var r_coke_dep__r_h "Hispanic Cocaine Overdose ED Visit Rate per 100k"	 
		
		
	if all==1 {
		
		local y_list r_pharm_ovr_total //r_drug_ovr_total   //r_op_ovr_total

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
					qui reghdfe `y' unemp_rate   [aweight=pop_total], absorb(i.fips#c.year fips year) vce(cluster fips)  
						sum `y' [aweight=pop_total], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace
					
					estimates store `y'_3			

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
										*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_2			

		
					
			local lbl: variable  label `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_3 `y'_2    using  "$results_path/appendix/tables/table_a12_`race'_full_ed.tex" , ///
		keep(unemp_rate )  label star(* 0.10 ** 0.05 *** 0.01) ///
		replace se order(unemp_rate ) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(Mean N, fmt(%3.2f 0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" )) ///
		f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline  
		
		capture est clear	
		}
		
		
		
		
		
		
		local y_list   r_benz_dep_total r_aro_dep_total r_adep_dep_total r_ins_dep_total r_coke_dep_total //r_drug_ovr_total //r_op_ovr_total //r_her_ovr_total 
		
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
					qui reghdfe `y' unemp_rate   [aweight=pop_total], absorb(i.fips#c.year  fips year) vce(cluster fips)  
						sum `y' [aweight=pop_total], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace
					
					estimates store `y'_3			

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
										*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_2			

					
					
					
			local lbl: variable  label `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_3 `y'_2  using  "$results_path/appendix/tables/table_a12_`race'_full_ed.tex" , ///
		keep(unemp_rate )  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate ) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(Mean N, fmt(%3.2f 0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" )) ///
		f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'" ) noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		local y_list r_psyc_dep_total
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
					qui reghdfe `y' unemp_rate   [aweight=pop_total], absorb(i.fips#c.year  fips year) vce(cluster fips)  
						sum `y' [aweight=pop_total], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace
					
					estimates store `y'_3			

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
										*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_2			

					
			local lbl: variable  label `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_3 `y'_2   using  "$results_path/appendix/tables/table_a12_`race'_full_ed.tex" , ///
		keep(unemp_rate )  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate ) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(Mean N state_fe year_dum  county_trend state_year_fe, fmt(%3.2f 0 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
		f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		

			
	}		

	if white==1 {
		
		
			local y_list r_op_ovr__r_w //r_drug_ovr__r_w   //r_op_ovr__r_w
			
			foreach y in `y_list' {			
			
							// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_white], absorb(fips year) vce(cluster fips)   
						sum `y' [aweight=pop_white], meanonly
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
					qui reghdfe `y' unemp_rate county_time_pop_* [aweight=pop_white], absorb(fips year) vce(cluster fips)  
						sum `y' [aweight=pop_white], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace
					
					estimates store `y'_3			

					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)  
										    sum `y' [aweight=pop_white], meanonly
					scalar Mean = r(mean)
					estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
										*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_2			

					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate county_time_pop_*  [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)   
										    sum `y' [aweight=pop_white], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "Yes"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate median_income county_time_pop_* [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)   
										    sum `y' [aweight=pop_white], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "Yes"
					estadd local state_year_fe "Yes"		
					estimates store `y'_9		
					
			local lbl: variable  label `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7 `y'_9  using  "$results_path/appendix/tables/table_a12_`race'_county_combined_robust_se.tex" , ///
		keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(Mean N, fmt(%3.2f 0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" )) ///
		f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		
		
		
			
			
			local y_list r_drug_ovr__r_w // r_op_ovr__r_w //r_her_ovr__r_w
			
			foreach y in `y_list' {		
			
								// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_white], absorb(fips year) vce(cluster fips)   
						sum `y' [aweight=pop_white], meanonly
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
					qui reghdfe `y' unemp_rate county_time_pop_* [aweight=pop_white], absorb(fips year) vce(cluster fips)  
						sum `y' [aweight=pop_white], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace
					
					estimates store `y'_3			

					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)  
										    sum `y' [aweight=pop_white], meanonly
					scalar Mean = r(mean)
					estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
										*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_2			

					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate county_time_pop_*  [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)   
										    sum `y' [aweight=pop_white], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "Yes"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate median_income county_time_pop_* [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)   
										    sum `y' [aweight=pop_white], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "Yes"
					estadd local state_year_fe "Yes"		
					estimates store `y'_9			
					
			local lbl: variable  label  `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7  `y'_9 using  "$results_path/appendix/tables/table_a12_`race'_county_combined_robust_se.tex" , ///
		keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N state_fe year_dum  county_trend state_year_fe, fmt(%3.2f 0 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Time Trends"   "State-by-Year Fixed-Effects")) ///
	f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		

			
	}	
	

	if black==1 {
		

			local y_list r_op_ovr__r_b //r_drug_ovr__r_b   //r_op_ovr__r_b
			
			foreach y in `y_list' {				
			
								// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_black], absorb(fips year) vce(cluster fips)   
						sum `y' [aweight=pop_black], meanonly
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
					qui reghdfe `y' unemp_rate county_time_pop_* [aweight=pop_black], absorb(fips year) vce(cluster fips)  
						sum `y' [aweight=pop_black], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace
					
					estimates store `y'_3			

					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)  
										    sum `y' [aweight=pop_black], meanonly
					scalar Mean = r(mean)
					estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
										*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_2			

					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate county_time_pop_*  [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)   
										    sum `y' [aweight=pop_black], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "Yes"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate median_income county_time_pop_* [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)   
										    sum `y' [aweight=pop_black], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "Yes"
					estadd local state_year_fe "Yes"		
					estimates store `y'_9	
					
			local lbl: variable  label  `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7 `y'_9  using  "$results_path/appendix/tables/table_a12_`race'_county_combined_robust_se.tex" , ///
		keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(Mean N, fmt(%3.2f 0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" )) ///
		f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		
		
		
			
			
			local y_list  r_drug_ovr__r_b // r_op_ovr__r_b //r_her_ovr__r_b
			
			foreach y in `y_list' {				
			
								// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_black], absorb(fips year) vce(cluster fips)   
						sum `y' [aweight=pop_black], meanonly
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
					qui reghdfe `y' unemp_rate county_time_pop_* [aweight=pop_black], absorb(fips year) vce(cluster fips)  
						sum `y' [aweight=pop_black], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace
					
					estimates store `y'_3			

					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)  
										    sum `y' [aweight=pop_black], meanonly
					scalar Mean = r(mean)
					estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
										*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_2			

					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate county_time_pop_*  [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)   
										    sum `y' [aweight=pop_black], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "Yes"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate median_income county_time_pop_* [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)   
										    sum `y' [aweight=pop_black], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "Yes"
					estadd local state_year_fe "Yes"		
					estimates store `y'_9			
						
			local lbl: variable  label  `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7  `y'_9 using  "$results_path/appendix/tables/table_a12_`race'_county_combined_robust_se.tex" , ///
		keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N state_fe year_dum  county_trend state_year_fe, fmt(%3.2f 0 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Time Trends"   "State-by-Year Fixed-Effects")) ///
	f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		

			
	}	
	

	if hisp==1 {
		/*
			local y_list r_op_ovr__r_h // r_drug_ovr__r_h   //r_op_ovr__r_h
			
			foreach y in `y_list' {					
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_hisp], absorb(fips year) vce(cluster fips)   
											sum `y'  [aweight=pop_hisp], meanonly
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
					qui reghdfe `y' unemp_rate county_time_* [aweight=pop_hisp], absorb(fips year) vce(cluster fips)  
											sum `y'  [aweight=pop_hisp], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
														*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace

					estimates store `y'_2			
	
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)  
										sum `y'  [aweight=pop_hisp], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
				*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
																				*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_3			

					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate median_income [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)   
											sum `y'  [aweight=pop_hisp], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label  `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using  "$results_path/appendix/tables/table_a12_`race'_county_combined_robust_se.tex" , ///
		keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(Mean N, fmt(%3.2f 0) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" )) ///
		f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		
		
		
			
			
			local y_list r_drug_ovr__r_h //r_op_ovr__r_h //r_her_ovr__r_h
			
			foreach y in `y_list' {				
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_hisp], absorb(fips year) vce(cluster fips)   
											sum `y'  [aweight=pop_hisp], meanonly
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
					qui reghdfe `y' unemp_rate county_time_* [aweight=pop_hisp], absorb(fips year) vce(cluster fips)  
											sum `y'  [aweight=pop_hisp], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
														*estimates save  "$box/opioid_project/results/estimates/`y'_cty_trend", replace

					estimates store `y'_2			
	
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate   [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)  
										sum `y'  [aweight=pop_hisp], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
				*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
																				*estimates save  "$box/opioid_project/results/estimates/`y'_st_year_fe", replace

					estimates store `y'_3			

					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' unemp_rate median_income [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)   
											sum `y'  [aweight=pop_hisp], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean	
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label  `y'
			local lbl2: variable  label unemp_rate
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using  "$results_path/appendix/tables/table_a12_`race'_county_combined_robust_se.tex" , ///
		keep(unemp_rate median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(unemp_rate median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N state_fe year_dum  county_trend state_year_fe, fmt(%3.2f 0 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Mean of Dependent Variable" "\hspace{0.5cm}Observations" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Time Trends"   "State-by-Year Fixed-Effects")) ///
		f nomtitles substitute(\_ _) ///
		refcat(unemp_rate "\midrule \emph{`lbl'}", nolabel)	///
		coef(unemp_rate "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
*/
}
			
	*}	
	
*----------
end
*----------

specification_table_by_race, race(all)
/*
specification_table_by_race, race(white)
specification_table_by_race, race(black)
specification_table_by_race, race(hisp)



