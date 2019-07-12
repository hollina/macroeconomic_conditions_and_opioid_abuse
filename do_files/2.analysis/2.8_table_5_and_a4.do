/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 November 2016
  
  Last Modified Date: 25 November 2016

  Description: State-Level Robustness Checks. Both with Unemployment Rate 
			  and Emp:Pop Ratio
*/ /////////////////////////////////////////////////////////////////////////////

// Collapse to State Level
	use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			
	
	
// Inflate before collapse 
	replace drugr  = drugr*pop
	replace aopioidr=aopioidr*pop
	replace aheroinr=aheroinr*pop
	
	replace drugwr  = drugwr*popw
	replace aopioidwr=aopioidwr*popw
	replace aheroinwr=aheroinwr*popw
	
	replace drugbr  = drugbr*popb
	replace aopioidbr=aopioidbr*popb
	replace aheroinbr=aheroinbr*popb
	
	replace drughr  = drughr*poph
	replace aopioidhr=aopioidhr*poph
	replace aheroinhr=aheroinhr*poph
	
	
// Split his county fips code to match our way of reporting it
	gen str5 z=string(county,"%05.0f")
	gen StateFIPS = substr(z,1,2)
	gen CountyFIPS = substr(z,3,3)
	destring StateFIPS, replace
	destring CountyFIPS, replace
	capture drop _merge
	
	merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
	capture drop _merge
	
	merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"
	capture drop _merge

	collapse (sum) drug* aopioid* aheroin* pop*  numb_* , by( StateFIPS year)
				merge 1:1 StateFIPS year using "$data_path/state_median_income.dta"
				keep if _merge==3
				drop _merge
				
// Add State Level ED			
	merge 1:1 StateFIPS year using  "$data_path/state_level_ed_all.dta"
	capture drop _merge

// Create State Specific Time Trends
			// Gen County Specific Time Trends
			gen time = 1 + year - 1999
			
			qui levelsof StateFIPS
			foreach x in `r(levels)' {
				gen state_time_`x'=0
				replace  state_time_`x' = time if StateFIPS==`x'
			}
// Return Deaths to Rates			
	replace drugr  = drugr/pop
	replace aopioidr=aopioidr/pop
	
	replace drugwr  = drugwr/popw
	replace aopioidwr=aopioidwr/popw
	
	replace drugbr  = drugbr/popb
	replace aopioidbr=aopioidbr/popb
	
	replace drughr  = drughr/poph
	replace aopioidhr=aopioidhr/poph

// Create Rate For ED Visits
	gen r_drug_all_both  = (drug_all_both/pop)*100000
	gen r_op_all_both  = (op_all_both/pop)*100000

	gen r_drug_race_white_both  = (drug_race_white_both/popw)*100000
	gen r_op_race_white_both  = (op_race_white_both/popw)*100000
	
	gen r_drug_race_black_both  = (drug_race_black_both/popb)*100000
	gen r_op_race_black_both  = (op_race_black_both/popb)*100000
	
	gen r_drug_race_hispanic_both  = (drug_race_hispanic_both/poph)*100000
	gen r_op_race_hispanic_both  = (op_race_hispanic_both/poph)*100000
	
sum r_drug_all_both  
	sum r_op_all_both  

	sum r_drug_race_white_both  
	sum r_op_race_white_both  
	
	sum r_drug_race_black_both
	sum r_op_race_black_both  
	
	sum r_drug_race_hispanic_both 
	sum r_op_race_hispanic_both  
//Label Employment to Population Ratio	
	gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	label variable emp_ratio_15_64 "\hspace{0.5cm} Employment to Population Ratio"
			
	gen emp_ratio_15_54 = (numb_emp/pop_15_54)*100
	label variable emp_ratio_15_54 "\hspace{0.5cm} Employment to Population Ratio"
//Add State Unemployment Data
	merge 1:1 StateFIPS year using "$data_path/state_unemployment_rate.dta"
	keep if _merge==3
	label variable unemployment_rate "\hspace{0.5cm} Unemployment Rate, [0-100]"
	
			
//Add Year Dummies
	tab year, gen(yd)

// Add Region by Year FE
	qui gen census=1 if StateFIPS==9 | StateFIPS==23 | StateFIPS==25 | StateFIPS==33 | StateFIPS==44 | StateFIPS==50
	qui replace census=2 if StateFIPS==34 | StateFIPS==36 | StateFIPS==42
	qui replace census=3 if StateFIPS==17 | StateFIPS==18 | StateFIPS==26 | StateFIPS==39 | StateFIPS==55
	qui replace census=4 if StateFIPS==19 | StateFIPS==20 | StateFIPS==27 | StateFIPS==29 | StateFIPS==31 | StateFIPS==38 | StateFIPS==46
	qui replace census=5 if StateFIPS==10 | StateFIPS==11 | StateFIPS==12 | StateFIPS==13 | StateFIPS==24 | StateFIPS==37 | StateFIPS==45 | StateFIPS==51 | StateFIPS==54
	qui replace census=6 if StateFIPS==1 | StateFIPS==21 | StateFIPS==28 | StateFIPS==47
	qui replace census=7 if StateFIPS==5 | StateFIPS==22 | StateFIPS==40 | StateFIPS==48
	qui replace census=8 if StateFIPS==4 | StateFIPS==8 | StateFIPS==16 | StateFIPS==30 | StateFIPS==32 | StateFIPS==35 | StateFIPS==49 | StateFIPS==56
	qui replace census=9 if StateFIPS==2 | StateFIPS==6 | StateFIPS==15 | StateFIPS==41 | StateFIPS==53

	egen region_year = group(census year)
	qui tab region_year, gen(region_year_fe_)	

// Clear Previous Estimates
	eststo clear

	
// Make Table
	//Drug Deaths
		 reghdfe drugr unemployment_rate   [aweight=pop], absorb(StateFIPS year ) vce(robust)
		 
		 	sum drugr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store state_1		
						
		reghdfe drugr unemployment_rate   state_time_* [aweight=pop], absorb(StateFIPS year )  vce(robust)
			 
		 	sum drugr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
					
					estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store state_1b			
						
		reghdfe drugr unemployment_rate    [aweight=pop], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum drugr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store state_1c
						
						
		 reghdfe drugwr unemployment_rate    [aweight=popw], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drugwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store state_2
							
		reghdfe drugwr unemployment_rate   state_time_* [aweight=popw], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drugwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store state_2b			
						
			 reghdfe drugwr unemployment_rate    [aweight=popw], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum drugwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store state_2c
						
		 reghdfe drugbr unemployment_rate   [aweight=popb], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drugbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store state_3
							
			 reghdfe drugbr unemployment_rate   state_time_* [aweight=popb], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drugbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store state_3b			
						
			 reghdfe drugbr unemployment_rate    [aweight=popb], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum drugbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store state_3c	
						
		 reghdfe drughr unemployment_rate    [aweight=poph], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drughr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store state_4
							
			 reghdfe drughr unemployment_rate   state_time_* [aweight=poph], absorb(StateFIPS year ) vce(robust)
		 
		 	sum drughr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store state_4b			
						
			 reghdfe drughr unemployment_rate    [aweight=poph], absorb(StateFIPS year region_year) vce(robust)
		 
		 	sum drughr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store state_4c		

	//Opioids
		 reghdfe aopioidr unemployment_rate   [aweight=pop], absorb(StateFIPS year)  vce(robust)
		 
		 	sum aopioidr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store w_state_1		
								
			 reghdfe aopioidr unemployment_rate   state_time_* [aweight=pop], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store w_state_1b			
						
			 reghdfe aopioidr unemployment_rate    [aweight=pop], absorb(StateFIPS year region_year) vce(robust)
		 
		 	sum aopioidr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store w_state_1c	
						
						
		 reghdfe aopioidwr unemployment_rate    [aweight=popw], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store w_state_2
									
			 reghdfe aopioidwr unemployment_rate   state_time_* [aweight=popw], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store w_state_2b			
						
			 reghdfe aopioidwr unemployment_rate    [aweight=popw], absorb(StateFIPS year region_year)  vce(robust)
			 
		 	sum aopioidwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
								estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store w_state_2c						
		 reghdfe aopioidbr unemployment_rate   [aweight=popb], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store w_state_3
											
			 reghdfe aopioidbr unemployment_rate   state_time_* [aweight=popb], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store w_state_3b			
						
			 reghdfe aopioidbr unemployment_rate    [aweight=popb], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum aopioidbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
						
						estimates store w_state_3c			
			
						
		 reghdfe aopioidhr unemployment_rate   [aweight=poph], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidhr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store w_state_4			
								
			 reghdfe aopioidh unemployment_rate   state_time_* [aweight=poph], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidhr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store w_state_4b			
						
			 reghdfe aopioidhr unemployment_rate    [aweight=poph], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum aopioidhr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom unemployment_rate/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store w_state_4c	
						
		esttab w_state_1 w_state_1b  w_state_2 w_state_2b   w_state_3 w_state_3b  w_state_4 w_state_4b   using "$results_path/tables/table_5_state_deaths_by_type.tex" , ///
			keep(unemployment_rate) label star(* 0.10 ** 0.05 *** 0.01) ///
			replace se order(unemployment_rate) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N, fmt(%3.2f 0  )layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label( "\hspace{0.5cm} Mean of Dependent Variable" "\hspace{0.5cm} Observations" )) ///
			f nomtitles substitute(\_ _) ///
			refcat(unemployment_rate "\hline \emph{Opioid Death Rate per 100k}", nolabel) noline ///
			mgroups("All" "White" "Black" "Hispanic", pattern(1 0  1 0  1 0  1 0  ) prefix(\multicolumn{2}{c}{\underline{\smash{~~~~~~~~~~~~~~~) suffix(~~~~~~~~~~~~~~~}}})  span)
	
		esttab state_1 state_1b  state_2 state_2b   state_3 state_3b  state_4 state_4b  using "$results_path/tables/table_5_state_deaths_by_type.tex" , ///		
			keep(unemployment_rate) label star(* 0.10 ** 0.05 *** 0.01) ///
			append se order(unemployment_rate)  collabels(none) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N, fmt(%3.2f 0  )layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm} Mean of Dependent Variable" "\hspace{0.5cm} Observations")) ///
			f nomtitles substitute(\_ _) ///
			refcat(unemployment_rate "\hline \emph{Drug Death Rate per 100k}", nolabel) noline nonumbers ///

	gen hisp_unemp = unemployment_rate
	//Drug ED Visits
		//All
		 reghdfe r_drug_all_both unemployment_rate   [aweight=pop], absorb(StateFIPS year )  vce(robust)
						sum r_drug_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed1_state_1		
								
			 reghdfe r_drug_all_both unemployment_rate   state_time_* [aweight=pop], absorb(StateFIPS year )  vce(robust)
					
						sum r_drug_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed1_state_1b			
						
			 reghdfe r_drug_all_both unemployment_rate    [aweight=pop], absorb(StateFIPS year region_year)  vce(robust)
						sum r_drug_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed1_state_1c	
						
			//White
		 reghdfe r_drug_race_white_both unemployment_rate  [aweight=popw], absorb(StateFIPS year ) vce(robust)
						sum r_drug_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed1_state_2
											
			 reghdfe r_drug_race_white_both unemployment_rate   state_time_* [aweight=popw], absorb(StateFIPS year ) vce(robust)
						sum r_drug_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed1_state_2b			
						
			 reghdfe r_drug_race_white_both unemployment_rate    [aweight=popw], absorb(StateFIPS year region_year) vce(robust)
						sum r_drug_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed1_state_2c
				//Black
					
		 reghdfe r_drug_race_black_both unemployment_rate  [aweight=popb], absorb(StateFIPS year )  vce(robust)
						sum r_drug_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean						
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed1_state_3
										
			 reghdfe r_drug_race_black_both unemployment_rate   state_time_* [aweight=popb], absorb(StateFIPS year )  vce(robust)
						sum r_drug_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean						
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed1_state_3b			
						
			 reghdfe r_drug_race_black_both unemployment_rate    [aweight=popb], absorb(StateFIPS year region_year)  vce(robust)
						sum r_drug_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean						
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed1_state_3c			
		//Hispanic				
		 reghdfe r_drug_race_hispanic_both hisp_unemp    [aweight=poph], absorb(StateFIPS year )  vce(robust)
						sum r_drug_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean						
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed1_state_4			
										
			 reghdfe r_drug_race_hispanic_both hisp_unemp   state_time_* [aweight=poph], absorb(StateFIPS year )  vce(robust)
						sum r_drug_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed1_state_4b			
						
			 reghdfe r_drug_race_hispanic_both hisp_unemp    [aweight=poph], absorb(StateFIPS year region_year)  vce(robust)
						sum r_drug_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed1_state_4c	

	//Opioid ED Visits
		//All
		 reghdfe r_op_all_both unemployment_rate   [aweight=pop], absorb(StateFIPS year )  vce(robust)
						sum r_op_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed2_state_1		
								
			 reghdfe r_op_all_both unemployment_rate   state_time_* [aweight=pop], absorb(StateFIPS year )  vce(robust)
						sum r_op_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
											estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed2_state_1b			
						
			 reghdfe r_op_all_both unemployment_rate    [aweight=pop], absorb(StateFIPS year region_year) vce(robust)
						sum r_op_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
											estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed2_state_1c	
						
			//White
		 reghdfe r_op_race_white_both unemployment_rate  [aweight=popw], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed2_state_2
											
			 reghdfe r_op_race_white_both unemployment_rate   state_time_* [aweight=popw], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
											estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed2_state_2b			
						
			 reghdfe r_op_race_white_both unemployment_rate    [aweight=popw], absorb(StateFIPS year region_year)  vce(robust)
						sum r_op_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
											estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed2_state_2c
				//Black
					
		 reghdfe r_op_race_black_both unemployment_rate  [aweight=popb], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed2_state_3
										
			 reghdfe r_op_race_black_both unemployment_rate   state_time_* [aweight=popb], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed2_state_3b			
						
			 reghdfe r_op_race_black_both unemployment_rate    [aweight=popb], absorb(StateFIPS year region_year)  vce(robust)
						sum r_op_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed2_state_3c			
		//Hispanic				
		 reghdfe r_op_race_hispanic_both hisp_unemp    [aweight=poph], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed2_state_4			
										
			 reghdfe r_op_race_hispanic_both hisp_unemp   state_time_* [aweight=poph], absorb(StateFIPS year ) vce(robust)
						sum r_op_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed2_state_4b			
						
			 reghdfe r_op_race_hispanic_both hisp_unemp    [aweight=poph], absorb(StateFIPS year region_year)  vce(robust)
						sum r_op_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed2_state_4c	

		esttab ed2_state_1 ed2_state_1b  ed2_state_2 ed2_state_2b   ed2_state_3 ed2_state_3b  ed2_state_4 ed2_state_4b  using "$results_path/tables/table_5_state_deaths_by_type.tex" , ///
			keep(unemployment_rate) label star(* 0.10 ** 0.05 *** 0.01) ///
			append se order(unemployment_rate)  collabels(none) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N , fmt( %3.2f 0  )layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label( "\hspace{0.5cm} Mean of Dependent Variable" "\hspace{0.5cm} Observations" )) ///
			f nomtitles substitute(\_ _) ///
			refcat(unemployment_rate "\hline \emph{Opioid ED Visit Rate per 100k}", nolabel) noline nonumbers ///
			
		esttab ed1_state_1 ed1_state_1b  ed1_state_2 ed1_state_2b   ed1_state_3 ed1_state_3b  ed1_state_4 ed1_state_4b  using "$results_path/tables/table_5_state_deaths_by_type.tex" , ///			
			keep(unemployment_rate) label star(* 0.10 ** 0.05 *** 0.01) ///
			append se order(unemployment_rate)  collabels(none) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N  state_fe year_dum  state_trend, fmt( %3.2f 0  0 0 0  )layout("\multicolumn{1}{c}{@}"   "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm} Mean of Dependent Variable" "\hspace{0.5cm} Observations" "\hline State Fixed-Effects" "Year Fixed-Effects"  "State Specific Time Trends")) ///
			f nomtitles substitute(\_ _) ///
			refcat(unemployment_rate "\hline \emph{Drug ED Visit Rate per 100k}", nolabel) noline nonumbers 


	//Drug Deaths
		 reghdfe drugr emp_ratio_15_54   [aweight=pop], absorb(StateFIPS year ) vce(robust)
		 
		 	sum drugr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store state_1		
						
		reghdfe drugr emp_ratio_15_54   state_time_* [aweight=pop], absorb(StateFIPS year )  vce(robust)
			 
		 	sum drugr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
					
					estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store state_1b			
						
		reghdfe drugr emp_ratio_15_54    [aweight=pop], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum drugr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store state_1c
						
						
		 reghdfe drugwr emp_ratio_15_54    [aweight=popw], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drugwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store state_2
							
		reghdfe drugwr emp_ratio_15_54   state_time_* [aweight=popw], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drugwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store state_2b			
						
			 reghdfe drugwr emp_ratio_15_54    [aweight=popw], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum drugwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store state_2c
						
		 reghdfe drugbr emp_ratio_15_54   [aweight=popb], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drugbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store state_3
							
			 reghdfe drugbr emp_ratio_15_54   state_time_* [aweight=popb], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drugbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store state_3b			
						
			 reghdfe drugbr emp_ratio_15_54    [aweight=popb], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum drugbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store state_3c	
						
		 reghdfe drughr emp_ratio_15_54    [aweight=poph], absorb(StateFIPS year )  vce(robust)
		 
		 	sum drughr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store state_4
							
			 reghdfe drughr emp_ratio_15_54   state_time_* [aweight=poph], absorb(StateFIPS year ) vce(robust)
		 
		 	sum drughr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store state_4b			
						
			 reghdfe drughr emp_ratio_15_54    [aweight=poph], absorb(StateFIPS year region_year) vce(robust)
		 
		 	sum drughr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store state_4c		

	//Opioids
		 reghdfe aopioidr emp_ratio_15_54   [aweight=pop], absorb(StateFIPS year)  vce(robust)
		 
		 	sum aopioidr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
			
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store w_state_1		
								
			 reghdfe aopioidr emp_ratio_15_54   state_time_* [aweight=pop], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store w_state_1b			
						
			 reghdfe aopioidr emp_ratio_15_54    [aweight=pop], absorb(StateFIPS year region_year) vce(robust)
		 
		 	sum aopioidr [aweight=pop], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store w_state_1c	
						
						
		 reghdfe aopioidwr emp_ratio_15_54    [aweight=popw], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store w_state_2
									
			 reghdfe aopioidwr emp_ratio_15_54   state_time_* [aweight=popw], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store w_state_2b			
						
			 reghdfe aopioidwr emp_ratio_15_54    [aweight=popw], absorb(StateFIPS year region_year)  vce(robust)
			 
		 	sum aopioidwr [aweight=popw], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
								estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store w_state_2c						
		 reghdfe aopioidbr emp_ratio_15_54   [aweight=popb], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store w_state_3
											
			 reghdfe aopioidbr emp_ratio_15_54   state_time_* [aweight=popb], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store w_state_3b			
						
			 reghdfe aopioidbr emp_ratio_15_54    [aweight=popb], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum aopioidbr [aweight=popb], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
						
						estimates store w_state_3c			
			
						
		 reghdfe aopioidhr emp_ratio_15_54   [aweight=poph], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidhr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store w_state_4			
								
			 reghdfe aopioidhr emp_ratio_15_54   state_time_* [aweight=poph], absorb(StateFIPS year )  vce(robust)
		 
		 	sum aopioidhr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store w_state_4b			
						
			 reghdfe aopioidhr emp_ratio_15_54    [aweight=poph], absorb(StateFIPS year region_year)  vce(robust)
		 
		 	sum aopioidhr [aweight=poph], meanonly
			scalar Mean = r(mean)
			estadd scalar Mean
	 	
			lincom emp_ratio_15_54/Mean
			scalar Percent = r(estimate)*100
			estadd scalar Percent 
									estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store w_state_4c	
						

	
		esttab w_state_1 w_state_1b  w_state_2 w_state_2b   w_state_3 w_state_3b  w_state_4 w_state_4b   using "$results_path/appendix/tables/table_a4_ratio_state_deaths_by_type.tex" , ///
			keep(emp_ratio_15_54) label star(* 0.10 ** 0.05 *** 0.01) ///
			replace se order(emp_ratio_15_54) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N, fmt(%3.2f 0  )layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label( "\hspace{0.5cm} Mean of Dependent Variable" "\hspace{0.5cm} Observations" )) ///
			f nomtitles substitute(\_ _) ///
			refcat(emp_ratio_15_54 "\hline \emph{Opioid Death Rate per 100k}", nolabel) noline ///
			mgroups("All" "White" "Black" "Hispanic", pattern(1 0  1 0  1 0  1 0  ) prefix(\multicolumn{2}{c}{\underline{\smash{~~~~~~~~~~~~~~~) suffix(~~~~~~~~~~~~~~~}}})  span)
	
		esttab state_1 state_1b  state_2 state_2b   state_3 state_3b  state_4 state_4b  using "$results_path/appendix/tables/table_a4_ratio_state_deaths_by_type.tex" , ///		
			keep(emp_ratio_15_54) label star(* 0.10 ** 0.05 *** 0.01) ///
			append se order(emp_ratio_15_54)  collabels(none) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N, fmt(%3.2f 0  )layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm} Mean of Dependent Variable" "\hspace{0.5cm} Observations")) ///
			f nomtitles substitute(\_ _) ///
			refcat(emp_ratio_15_54 "\hline \emph{Drug Death Rate per 100k}", nolabel) noline nonumbers ///
//Employment to Population Ratio
	//Drug ED Visits
	gen hisp_emp_ratio = emp_ratio_15_54
		//All
		 reghdfe r_drug_all_both emp_ratio_15_54   [aweight=pop], absorb(StateFIPS year )  vce(robust)
						sum r_drug_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed1_state_1		
								
			 reghdfe r_drug_all_both emp_ratio_15_54   state_time_* [aweight=pop], absorb(StateFIPS year )  vce(robust)
						sum r_drug_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed1_state_1b			
						
			 reghdfe r_drug_all_both emp_ratio_15_54    [aweight=pop], absorb(StateFIPS year region_year)  vce(robust)
						sum r_drug_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed1_state_1c	
						
			//White
		 reghdfe r_drug_race_white_both emp_ratio_15_54  [aweight=popw], absorb(StateFIPS year ) vce(robust)
						sum r_drug_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed1_state_2
											
			 reghdfe r_drug_race_white_both emp_ratio_15_54   state_time_* [aweight=popw], absorb(StateFIPS year ) vce(robust)
						sum r_drug_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed1_state_2b			
						
			 reghdfe r_drug_race_white_both emp_ratio_15_54    [aweight=popw], absorb(StateFIPS year region_year) vce(robust)
						sum r_drug_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
				
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed1_state_2c
				//Black
					
		 reghdfe r_drug_race_black_both emp_ratio_15_54  [aweight=popb], absorb(StateFIPS year )  vce(robust)
						sum r_drug_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean						
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed1_state_3
										
			 reghdfe r_drug_race_black_both emp_ratio_15_54   state_time_* [aweight=popb], absorb(StateFIPS year )  vce(robust)
						sum r_drug_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean						
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed1_state_3b			
						
			 reghdfe r_drug_race_black_both emp_ratio_15_54    [aweight=popb], absorb(StateFIPS year region_year)  vce(robust)
						sum r_drug_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean						
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed1_state_3c			
		//Hispanic				
		 reghdfe r_drug_race_hispanic_both hisp_emp_ratio    [aweight=poph], absorb(StateFIPS year )  vce(robust)
						sum r_drug_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean						
							estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed1_state_4			
										
			 reghdfe r_drug_race_hispanic_both hisp_emp_ratio   state_time_* [aweight=poph], absorb(StateFIPS year )  vce(robust)
						sum r_drug_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed1_state_4b			
						
			 reghdfe r_drug_race_hispanic_both hisp_emp_ratio    [aweight=poph], absorb(StateFIPS year region_year)  vce(robust)
						sum r_drug_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed1_state_4c	


	//Opioid ED Visits
		//All
		 reghdfe r_op_all_both emp_ratio_15_54   [aweight=pop], absorb(StateFIPS year )  vce(robust)
						sum r_op_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed2_state_1		
								
			 reghdfe r_op_all_both emp_ratio_15_54   state_time_* [aweight=pop], absorb(StateFIPS year )  vce(robust)
						sum r_op_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
											estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed2_state_1b			
						
			 reghdfe r_op_all_both emp_ratio_15_54    [aweight=pop], absorb(StateFIPS year region_year) vce(robust)
						sum r_op_all_both [aweight=pop], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
											estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed2_state_1c	
						
			//White
		 reghdfe r_op_race_white_both emp_ratio_15_54  [aweight=popw], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed2_state_2
											
			 reghdfe r_op_race_white_both emp_ratio_15_54   state_time_* [aweight=popw], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
											estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed2_state_2b			
						
			 reghdfe r_op_race_white_both emp_ratio_15_54    [aweight=popw], absorb(StateFIPS year region_year)  vce(robust)
						sum r_op_race_white_both [aweight=popw], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
											estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed2_state_2c
				//Black
					
		 reghdfe r_op_race_black_both emp_ratio_15_54  [aweight=popb], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed2_state_3
										
			 reghdfe r_op_race_black_both emp_ratio_15_54   state_time_* [aweight=popb], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed2_state_3b			
						
			 reghdfe r_op_race_black_both emp_ratio_15_54    [aweight=popb], absorb(StateFIPS year region_year)  vce(robust)
						sum r_op_race_black_both [aweight=popb], meanonly
						scalar Mean = r(mean)
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed2_state_3c			
		//Hispanic				
		 reghdfe r_op_race_hispanic_both hisp_emp_ratio    [aweight=poph], absorb(StateFIPS year )  vce(robust)
						sum r_op_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "No"

						estimates store ed2_state_4			
										
			 reghdfe r_op_race_hispanic_both hisp_emp_ratio   state_time_* [aweight=poph], absorb(StateFIPS year ) vce(robust)
						sum r_op_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "Yes"
						estadd local region_year "No"

						estimates store ed2_state_4b			
						
			 reghdfe r_op_race_hispanic_both hisp_emp_ratio    [aweight=poph], absorb(StateFIPS year region_year)  vce(robust)
						sum r_op_race_hispanic_both [aweight=poph], meanonly
						scalar Mean = .
						estadd scalar Mean
						
						estadd local year_dum "Yes"
						estadd local state_fe "Yes"	
						estadd local state_trend "No"
						estadd local region_year "Yes"
			
						estimates store ed2_state_4c	

		esttab ed2_state_1 ed2_state_1b  ed2_state_2 ed2_state_2b   ed2_state_3 ed2_state_3b  ed2_state_4 ed2_state_4b  using "$results_path/appendix/tables/table_a4_ratio_state_deaths_by_type.tex" , ///
			keep(emp_ratio_15_54) label star(* 0.10 ** 0.05 *** 0.01) ///
			append se order(emp_ratio_15_54)  collabels(none) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N , fmt( %3.2f 0  )layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label( "\hspace{0.5cm} Mean of Dependent Variable" "\hspace{0.5cm} Observations" )) ///
			f nomtitles substitute(\_ _) ///
			refcat(emp_ratio_15_54 "\hline \emph{Opioid ED Visit Rate per 100k}", nolabel) noline nonumbers ///
			
		esttab ed1_state_1 ed1_state_1b  ed1_state_2 ed1_state_2b   ed1_state_3 ed1_state_3b  ed1_state_4 ed1_state_4b  using "$results_path/appendix/tables/table_a4_ratio_state_deaths_by_type.tex" , ///			
			keep(emp_ratio_15_54) label star(* 0.10 ** 0.05 *** 0.01) ///
			append se order(emp_ratio_15_54)  collabels(none) ///
			booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
			stats(Mean N  state_fe year_dum  state_trend, fmt( %3.2f 0  0 0 0  )layout("\multicolumn{1}{c}{@}"   "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm} Mean of Dependent Variable" "\hspace{0.5cm} Observations" "\hline State Fixed-Effects" "Year Fixed-Effects"  "State Specific Time Trends")) ///
			f nomtitles substitute(\_ _) ///
			refcat(emp_ratio_15_54 "\hline \emph{Drug ED Visit Rate per 100k}", nolabel) noline nonumbers 
		
