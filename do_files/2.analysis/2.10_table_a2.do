
// Robustness Check Summary Statistics Table
	// State-Level Results
		clear all

		// Open up death rate file created by Chris Ruhm
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear			
			
	// Split his county fips code to match our way of reporting it
		gen str5 z=string(county,"%05.0f")
		gen StateFIPS = substr(z,1,2)
		gen CountyFIPS = substr(z,3,3)
		destring StateFIPS, replace
		destring CountyFIPS, replace
		drop z
		rename county countycode	

		// State-Level Creation
			replace anoopr = anoopr*pop
			replace anoopher = anoopher*pop
			
			replace drugr = drugr*pop
			replace aopioidr = aopioidr*pop
			replace aheroinr = aheroinr*pop
		
			replace drugwr = drugwr*popw
			replace aopioidwr = aopioidwr*popw
			replace aheroinwr = aheroinwr*popw

			replace drugbr = drugbr*popb
			replace aopioidbr = aopioidbr*popb
			replace aheroinbr = aheroinbr*popb

			replace drughr = drughr*poph
			replace aopioidhr = aopioidhr*poph
			replace aheroinhr = aheroinhr*poph
// Merge in Controls
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
				
				keep if _merge==3  
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
				
				keep if _merge==3 
				drop _merge
				
				merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

				keep if _merge==3
				drop _merge
				

				label variable year "Year"

			collapse (sum) pop drugr aopioidr aheroinr popw drugwr aopioidwr aheroinwr  popb drugbr aopioidbr aheroinbr   poph drughr aopioidhr aheroinhr numb_emp pop_15_64 anoopr anoopher , by(StateFIPS year)
		
		//Turn Variables back into rates
		
		replace anoopr = anoopr/pop
		replace anoopher  = anoopher/pop
		
			replace drugr = drugr/pop
			replace aopioidr = aopioidr/pop
			replace aheroinr = aheroinr/pop
			
			replace drugwr = drugwr/popw
			replace aopioidwr = aopioidwr/popw
			replace aheroinwr = aheroinwr/popw

			replace drugbr = drugbr/popb
			replace aopioidbr = aopioidbr/popb
			replace aheroinbr = aheroinbr/popb

			replace drughr = drughr/poph
			replace aopioidhr = aopioidhr/poph
			replace aheroinhr = aheroinhr/poph		
			
// Add State Level ED			
	merge 1:1 StateFIPS year using  "$data_path/state_level_ed_all.dta"
	capture drop _merge
	
// Create Rate For ED Visits
	gen r_drug_all_both  = (drug_all_both/pop)*100000
	gen r_op_all_both  = (op_all_both/pop)*100000
	gen r_her_all_both  = (her_all_both/pop)*100000

	gen r_drug_race_white_both  = (drug_race_white_both/popw)*100000
	gen r_op_race_white_both  = (op_race_white_both/popw)*100000
	gen r_her_race_white_both  = (her_race_white_both/popw)*100000
	
	gen r_drug_race_black_both  = (drug_race_black_both/popb)*100000
	gen r_op_race_black_both  = (op_race_black_both/popb)*100000
	gen r_her_race_black_both  = (her_race_black_both/popb)*100000
	
	gen r_drug_race_hispanic_both  = (drug_race_hispanic_both/poph)*100000
	gen r_op_race_hispanic_both  = (op_race_hispanic_both/poph)*100000
	gen r_her_race_hispanic_both  = (her_race_hispanic_both/poph)*100000
	
	       
		//Relabel Variables
			label variable drugr "Drug Death Death Rate per 100k"
			label variable aopioidr "Opioid Death Rate per 100k"
			label variable aheroinr "Heroin Death Rate per 100k"

			label variable drugwr "Drug Death Rate per 100k"
			label variable aopioidwr "Opioid Death Rate per 100k"
			label variable aheroinwr "Heroin Death Rate per 100k"
			
			label variable drugbr "Drug Death Rate per 100k"
			label variable aopioidbr "Opioid Death Rate per 100k"
			label variable aheroinbr "Heroin Death Rate per 100k"

			label variable drughr "Drug Death Rate per 100k"
			label variable aopioidhr "Opioid Death Rate per 100k"
			label variable aheroinhr "Heroin Death Rate per 100k"
			
			label variable r_drug_all_both "Drug ED Visit Rate per 100k"
			label variable r_op_all_both "Opioid ED Visit Rate per 100k"
			label variable r_her_all_both "Heroin ED Visit Rate per 100k"

			label variable r_drug_race_white_both "Drug ED Visit Rate per 100k"
			label variable r_op_race_white_both "Opioid ED Visit Rate per 100k"
			label variable r_her_race_white_both "Heroin ED Visit Rate per 100k"
		

			label variable r_drug_race_black_both "Drug ED Visit Rate per 100k"
			label variable r_op_race_black_both "Opioid ED Visit Rate per 100k"
			label variable r_her_race_black_both "Heroin ED Visit Rate per 100k"
			

			label variable r_drug_race_hispanic_both "Drug ED Visit Rate per 100k"
			label variable r_op_race_hispanic_both "Opioid ED Visit Rate per 100k"
			label variable r_her_race_hispanic_both "Heroin ED Visit Rate per 100k"
			
			
			label variable year "Year"
			
			replace pop = pop/100000
			label variable pop "Population, in 100k"
			
			replace popw = popw/100000
			label variable popw "Population, in 100k"
			
			replace popb = popb/100000
			label variable popb "Population, in 100k"
			
			replace poph = poph/100000
			label variable poph "Population, in 100k"
			
		gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
		label variable emp_ratio_15_64 "Employment to Population Ratio"
		
			
		// Merge in State-Level Unemployment and Median Income
			merge 1:1 StateFIPS year using "$data_path/state_unemployment_rate.dta"
			keep if _merge==3	
			drop _merge
			merge 1:1 StateFIPS year using "$data_path/state_median_income.dta"
			keep if _merge==3
				
	label variable unemployment_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	
	// Gen Non-Opioid Non-Heroin Drug Deaths

	replace anoopr = 0 if anoopr<0
	replace anoopher = 0 if anoopher<0
	label variable anoopr "Drug Death Rate per 100k, Exluding Opioids"
	label variable anoopher "Drug Death Rate per 100k, Exluding Opioids and Heroin"
	
	
	local indent_list unemployment_rate median_income emp_ratio_15_64  anoopr anoopher ///
		  year pop drugr aopioidr aheroinr  r_drug_all_both           r_op_all_both 	      r_her_all_both ///
		  popw drugwr aopioidwr aheroinwr   r_drug_race_white_both    r_op_race_white_both    r_her_race_white_both ///
		  popb drugbr aopioidbr aheroinbr 	r_drug_race_black_both    r_op_race_black_both 	  r_her_race_black_both ///
		  poph drughr aopioidhr aheroinhr   r_drug_race_hispanic_both r_op_race_hispanic_both r_her_race_hispanic_both
		
		foreach x in `indent_list' {
			local lab: variable label `x'
			label variable `x' "\hspace{0.5cm} `lab'"

		}

	local indent2_list pop  drugr  aopioidr  aheroinr   r_drug_all_both           r_op_all_both 	       r_her_all_both ///
					   popw drugwr aopioidwr aheroinwr  r_drug_race_white_both    r_op_race_white_both     r_her_race_white_both ///
		               popb drugbr aopioidbr aheroinbr 	r_drug_race_black_both    r_op_race_black_both 	   r_her_race_black_both ///
		               poph drughr aopioidhr aheroinhr  r_drug_race_hispanic_both r_op_race_hispanic_both r_her_race_hispanic_both ///
					   anoopr anoopher
		
		foreach x in `indent2_list' {
			local lab: variable label `x'
			label variable `x' "\hspace{0.5cm} `lab'"

		}
		
	//Mortality											
		
			// Export Summary Table
				eststo clear
				estpost summarize  unemployment_rate median_income emp_ratio_15_64 [aweight=pop] if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", replace ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat(unemployment_rate "\emph{State-Level Mortality Data \vspace{.25cm}}"  , nolabel) 

			// Add to Summary Table
				eststo clear
				estpost summarize  year pop  if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat(pop "\hspace{0.5cm} \emph{All}" , nolabel) ///
				noline collabels(none)

			// Add to Summary Table
				eststo clear
				estpost summarize   aopioidr  aheroinr  drugr  anoopr anoopher [aweight=pop]  if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none)

			// Add to Summary Table
				eststo clear
				estpost summarize  popw    if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat( popw "\hspace{0.5cm} \emph{White}", nolabel) ///
				noline collabels(none)
				
			// Add to Summary Table
				eststo clear
				estpost summarize   aopioidwr aheroinwr  drugwr   [aweight=popw]  if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none)
												
			// Add to Summary Table
				eststo clear
				estpost summarize  popb   if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat( popb "\hspace{0.5cm} \emph{Black}", nolabel) ///
				noline collabels(none)				
				
			// Add to Summary Table
				eststo clear
				estpost summarize   aopioidbr aheroinbr drugbr	 [aweight=popb]  if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none)
												
			// Add to Summary Table
				eststo clear
				estpost summarize  poph    if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat( poph "\hspace{0.5cm} \emph{Hispanic}", nolabel) ///
				noline collabels(none)				
				
			// Add to Summary Table
				eststo clear
				estpost summarize   aopioidhr aheroinhr  drughr  [aweight=poph]  if !missing(drugr)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none)
													
	//ED Visits											
		
			// Export Summary Table
				eststo clear
				estpost summarize  unemployment_rate median_income emp_ratio_15_64 [aweight=pop]  if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none) ///
				refcat(unemployment_rate "\emph{State-Level Emergency Department Data \vspace{.25cm}}"  , nolabel) 
				
			// Add to Summary Table
				eststo clear
				estpost summarize  year pop   if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat(pop "\hspace{0.5cm} \emph{All}" , nolabel) ///
				noline collabels(none)

			// Add to Summary Table
				eststo clear
				estpost summarize               r_op_all_both 	       r_her_all_both  r_drug_all_both [aweight=pop]   if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none)

			// Add to Summary Table
				eststo clear
				estpost summarize  popw     if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat( popw "\hspace{0.5cm} \emph{White}", nolabel) ///
				noline collabels(none)
				
			// Add to Summary Table
				eststo clear
				estpost summarize       r_op_race_white_both     r_her_race_white_both  r_drug_race_white_both [aweight=popw]   if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none)
												
			// Add to Summary Table
				eststo clear
				estpost summarize  popb    if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat( popb "\hspace{0.5cm} \emph{Black}", nolabel) ///
				noline collabels(none)				
				
			// Add to Summary Table
				eststo clear
				estpost summarize  	    r_op_race_black_both 	   r_her_race_black_both  r_drug_race_black_both [aweight=popb]   if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none)
			// Add to Summary Table
				eststo clear
				estpost summarize  poph     if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				refcat( poph "\hspace{0.5cm} \emph{Hispanic}", nolabel) ///
				noline collabels(none)				
				
			// Add to Summary Table
				eststo clear
				estpost summarize     r_op_race_hispanic_both r_her_race_hispanic_both r_drug_race_hispanic_both  [aweight=poph]  if !missing(r_drug_all_both)
				esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
				cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
				nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
				noobs substitute(\_ _) ///
				noline collabels(none)	
				
//County Level Data for Robustness Checks
	clear all

		// Open up death rate file created by Chris Ruhm
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
		// Merge in Census Data			
		merge m:1 StateFIPS CountyFIPS using   "$data_path/high_school_2000.dta"
		
		drop _merge
		merge m:1 StateFIPS CountyFIPS using "$data_path/land_area_2000.dta"

		label variable highschool_graduates "\% High School Graduates, 2010"
		label variable land_area "Land Area sq. Miles, 2010"

		
		
		label variable drugr "Drug Death Death Rate per 100k"
		label variable opioidr "Opioid Death Rate per 100k, Rerported"
		label variable popioidr "Opioid Death Rate per 100k, Adjusted"
		label variable aopioidr "Opioid Death Rate per 100k"
		
		label variable heroinr "Heroin Death Rate per 100k, Rerported"
		label variable pheroinr "Heroin Death Rate per 100k, Adjusted"	
		label variable aheroinr "Heroin Death Rate per 100k"
		label variable year "Year (Mortality Data)"

		label variable drugwr "Drug Death Rate per 100k"
		label variable aopioidwr "Opioid Death Rate per 100k"
		label variable aheroinwr "Heroin Death Rate per 100k"
		
		label variable drugbr "Drug Death Rate per 100k"
		label variable aopioidbr "Opioid Death Rate per 100k"
		label variable aheroinbr "Heroin Death Rate per 100k"

		label variable drughr "Drug Death Rate per 100k"
		label variable aopioidhr "Opioid Death Rate per 100k"
		label variable aheroinhr "Heroin Death Rate per 100k"
				
		gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
		label variable emp_ratio_15_64 "Employment to Population Ratio"
		
		label variable unemp_rate "Unemployment Rate, [0-100]"
		replace median_income = median_income/1000
		label variable median_income "Median Income, \\\$1000s"
		
		gen population_density = pop/land_area
		label variable population_density "Population per sq. Mile, 2010"
		gen percent_non_white = (pop-popw)/pop
		label var percent_non_white "\% Non-White, 2010"

		local sum_list emp_ratio_15_64 
		local sum_list2   highschool_graduates population_density percent_non_white     median_income


				foreach x in `sum_list' {
					local lab: variable label `x'
					label variable `x' "\hspace{0.5cm} `lab'"
				}
				foreach x in `sum_list2' {
					local lab: variable label `x'
					label variable `x' "\hspace{0.5cm} `lab'"
				}
				/*
						// Export Summary Table
							eststo clear
							estpost summarize  `sum_list' if !missing(drugr)
							esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
							cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
							nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) collabels(none) eform  ///
							noobs substitute(\_ _) noline ///
							refcat( emp_ratio_15_64 "\emph{County-Level Variables Data \vspace{.25cm}}", nolabel) ///
				*/			
							
						// Export Summary Table
							eststo clear
							estpost summarize  `sum_list2' if year==2010 & !missing(drugr)
							esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
							cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
							nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) collabels(none) eform  ///
							noobs substitute(\_ _) noline 		///
							refcat( highschool_graduates "\emph{County-Level Variables for Mortality Data \vspace{.25cm}}", nolabel) ///

	// County Level Data
	clear all

	use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta"

	// Create Log Visits per 100k, Vists per 100k, and Log Visits (plus 1)
		ds *any*
		foreach var in `r(varlist)' {
			local templabel : var label `var'
			label variable `var' "Total `templabel'"
			gen lr_`var' = log(((`var'+1)/pop_total)*100000)
			label variable  lr_`var'  "Log Rate (100k) of `templabel'"

			gen r_`var' = (`var'/pop_total)*100000
			label variable  r_`var'  "Rate (100k) `templabel'"
			
			gen l_`var' = log(`var'+1)
			label variable  l_`var'  "Log `templabel'"
		}
		
		ds *any*
		foreach var in `r(varlist)' {
	   local varlabel : var label `var'
	  local newname : subinstr local varlabel "# of Annual Visits for" "\# Visits,", all
	  label variable `var' "`newname'"
	}
		// Merge in Census Data	
		capture drop _merge
		merge m:1 StateFIPS CountyFIPS using   "$data_path/high_school_2000.dta"
		
		drop _merge
		merge m:1 StateFIPS CountyFIPS using "$data_path/land_area_2000.dta"


	// Simplify Variable Names
		rename *any *total //Can't do this earlier because of population
		rename *any_* **
		
		// Label Certain Variables
		replace unemp_rate = unemp_rate*100
		label variable unemp_rate "Unemployment Rate, [1-100]"
		replace median_income = median_income/1000
		label variable median_income "Median Income, \\\$1000s"
		label variable percent_non_white "\% Non-White, [0-1]"
		label var r_op_dep_total "Opioid Dependence ED Visits per 100k"
		label var r_op_ovr_total " Opioid Overdose ED Visits per 100k"
		label var r_her_ovr_total "Heroin Overdose ED Visits per 100k"
  
		label var r_her_ovr_r_w "White Heroin Overdose ED Visits per 100k"
		label var r_her_ovr_r_b "Black Heroin Overdose ED Visits per 100k"
		label var r_her_ovr_r_h "Hispanic Heroin Overdose ED Visits per 100k"

		label var year "Year (ED Data)"
			gen emp_ratio_15_64 = (numb_emp/pop_15_64)*100
	label variable emp_ratio_15_64 "Employment to Population Ratio"
		label variable highschool_graduates "\% High School Graduates, 2010"

			label var r_uti_total "UTI ED Visits per 100k"
			label var r_vom_preg_total "Vomiting During Pregnancy ED Visits per 100k"
			label var r_brk_leg_total "Broken Leg ED Visits per 100k"
			label var r_brk_arm_total "Broken Arm ED Visits per 100k"
			label var r_bkn_nose_total "Broken Nose ED Visits per 100k"
			label var r_head_total "Open Head Wound ED Visits per 100k"		
				    
		label var percent_non_white "\% Non-White, 2010"
		gen population_density = pop_total/land_area
		label variable population_density "Population per sq. Mile, 2010"
		
		
	// Gen Non-Opioid Non-Heroin Drug Deaths
	*gen oah_ovr_first = 0	//As a place holder until the code is done
	
	gen no_op_her_drugr = drug_ovr_total - op_ovr_total - her_ovr_total + oah_ovr_total 
	gen r_no_op_her_drugr = (no_op_her_drugr/pop_total)*100000
	label variable r_no_op_her_drugr "Drug ED Visit Rate per 100k, Exluding Opioids and Heroin"

	gen no_op_drugr = drug_ovr_total - op_ovr_total 
	gen r_no_op_drugr = (no_op_drugr/pop_total)*100000
	label variable r_no_op_drugr "Drug ED Visit Rate per 100k, Exluding Opioids"
					 

		
		local sum_list1  median_income r_her_ovr_total r_her_ovr_r_w r_her_ovr_r_b r_her_ovr_r_h r_no_op_drugr r_no_op_her_drugr
		local sum_list1a highschool_graduates population_density percent_non_white 
		local sum_list2 r_vom_preg_total r_head_total r_brk_leg_total r_brk_arm_total r_bkn_nose_total   //year //unemp_rate median_income year 


		foreach x in `sum_list1' {
			local lab: variable label `x'
			label variable `x' "\hspace{0.5cm} `lab'"
		}
		foreach x in `sum_list1a' {
			local lab: variable label `x'
			label variable `x' "\hspace{0.5cm} `lab'"
		}
		foreach x in `sum_list2' {
			local lab: variable label `x'
			label variable `x' "\hspace{0.5cm} `lab'"
		}

			// Export Summary Table
					eststo clear
					estpost summarize  `sum_list1a'  if !missing(r_uti_total) & year==2010
					esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
					cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
					nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) collabels(none) eform  ///
					noobs substitute(\_ _) noline ///
					refcat(highschool_graduates "\emph{County-Level Variables for Emergency Department Data \vspace{.25cm}}" , nolabel)
			// Export Summary Table
					eststo clear
					estpost summarize  `sum_list1'  if !missing(r_uti_total)
					esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
					cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
					nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) collabels(none) eform  ///
					noobs substitute(\_ _) noline
				
			// Export Summary Table
					eststo clear
					estpost summarize  `sum_list2' [aweight=pop_total]  if !missing(r_uti_total)
					esttab using "$results_path/appendix/tables/table_a2_st_summary_statistics_weighted.tex", append ///
					cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
					nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) collabels(none) eform  ///
					 noobs substitute(\_ _) noline
