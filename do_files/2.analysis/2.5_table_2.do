/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 25 August 2016
  
  Last Modified: 18 October 2016

  Description: Create a combined summary statistics table
			
*/ /////////////////////////////////////////////////////////////////////////////

// Create County Level Summary Statistics Table Weighted by Population
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

keep if _merge==3
drop _merge

merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"

keep if _merge==3
drop _merge

merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"

keep if _merge==3
drop _merge

// Label data
label variable drugr "Drug Death Rate per 100k"
label variable opioidr "Opioid Death Rate per 100k, Rerported"
label variable popioidr "Opioid Death Rate per 100k, Adjusted"
label variable aopioidr "Opioid Death Rate per 100k"

label variable year "Year (Mortality Data)"

label variable drugwr "Drug Death Rate per 100k"
label variable aopioidwr "Opioid Death Rate per 100k"

label variable drugbr "Drug Death Rate per 100k"
label variable aopioidbr "Opioid Death Rate per 100k"

label variable drughr "Drug Death Rate per 100k"
label variable aopioidhr "Opioid Death Rate per 100k"

// Fix up control variables and add labels
replace unemp_rate = unemp_rate*100
label variable unemp_rate "Unemployment Rate, [0-100]"
replace median_income = median_income/1000
label variable median_income "Median Income, \\\$1000s"
gen percent_non_white = (pop-popw)/pop
label variable percent_non_white "\% Non-White, [0-1]"

replace pop = pop/100000
label variable pop "Population, in 100k"

replace popw = popw/100000
label variable popw "Population, in 100k"

replace popb = popb/100000
label variable popb "Population, in 100k"
		
replace poph = poph/100000
label variable poph "Population, in 100k"

label variable year "Year"
	
// Add an indent (for table formatting)
local indent_list unemp_rate  year pop drugr aopioidr  popw drugwr aopioidwr  popb drugbr aopioidbr   poph drughr aopioidhr

foreach x in `indent_list' {
	local lab: variable label `x'
	label variable `x' "\hspace{0.5cm} `lab'"

}

// Add another indent to some (for table formatting)
local indent2_list  pop drugr aopioidr  popw drugwr aopioidwr   popb drugbr aopioidbr    poph drughr aopioidhr     

foreach x in `indent2_list' {
	local lab: variable label `x'
	label variable `x' "\hspace{0.5cm} `lab'"

}

// Make local macros for each summary stat "set" by population that we will weight by
local sum_list_all_1 unemp_rate  
local sum_list_all_2 year pop
local sum_list_all_3 drugr aopioidr  

local sum_list_white_0 popw
local sum_list_white  drugwr aopioidwr  

local sum_list_black_0 popb
local sum_list_black  drugbr aopioidbr 

local sum_list_hisp_0 poph
local sum_list_hisp  drughr aopioidhr     

// Export Summary Table
	eststo clear
	estpost summarize  unemp_rate  [aweight=pop]
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", replace ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	refcat(unemp_rate "\emph{Mortality Data \vspace{.25cm}}"  , nolabel) 

// Add to Summary Table
	eststo clear
	estpost summarize  year pop 
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	refcat(pop "\hspace{0.5cm} \emph{All}" , nolabel) ///
	noline collabels(none)

// Add to Summary Table
	eststo clear
	estpost summarize aopioidr drugr    [aweight=pop]  
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	noline collabels(none)

// Add to Summary Table
	eststo clear
	estpost summarize  popw   
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	refcat( popw "\hspace{0.5cm} \emph{White}", nolabel) ///
	noline collabels(none)
	
// Add to Summary Table
	eststo clear
	estpost summarize  aopioidwr drugwr      [aweight=popw]  
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	noline collabels(none)
									
// Add to Summary Table
	eststo clear
	estpost summarize  popb  
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	refcat( popb "\hspace{0.5cm} \emph{Black}", nolabel) ///
	noline collabels(none)				
	
// Add to Summary Table
	eststo clear
	estpost summarize aopioidbr drugbr     [aweight=popb]  
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	noline collabels(none)
								
// Add to Summary Table
	eststo clear
	estpost summarize  poph   
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	refcat( poph "\hspace{0.5cm} \emph{Hispanic}", nolabel) ///
	noline collabels(none)				
	
// Add to Summary Table
	eststo clear
	estpost summarize  aopioidhr drughr     [aweight=poph] 
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	noline collabels(none)
															
//////////////////////////////////////////////////////////////////////////////		
//ED Data
clear all

// Open data
use "$raw_data_res_ed_path/drug_ed_visits_with_county.dta"

// Create rates
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
rename *any *total 
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
label var r_op_dep_total "Opioid Dependence ED Visit Rate per 100k"
	 
label var r_op_ovr__r_w "Opioid Overdose ED Visit Rate per 100k"
label var r_op_dep__r_w "Opioid Dependence ED Visit Rate per 100k"
 
label var r_op_ovr__r_b "Opioid Overdose ED Visit Rate per 100k"
label var r_op_dep__r_b "Opioid Dependence ED Visit Rate per 100k"
 
label var r_op_ovr__r_h "Opioid Overdose ED Visit Rate per 100k"
label var r_op_dep__r_h "Opioid Dependence ED Visit Rate per 100k"
	 
		
label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
label var r_drug_ovr__r_w "Drug Overdose ED Visit Rate per 100k"
label var r_drug_ovr__r_b "Drug Overdose ED Visit Rate per 100k"
label var r_drug_ovr__r_h "Drug Overdose ED Visit Rate per 100k"

label variable year "Year"

replace pop_total = pop_total/100000
label variable pop_total "Population, in 100k"

replace pop_white = pop_white/100000
label variable pop_white "Population, in 100k"

replace pop_black = pop_black/100000
label variable pop_black "Population, in 100k"

replace pop_hisp = pop_hisp/100000
label variable pop_hisp "Population, in 100k"

	
// List of variables to indent
local indent_list unemp_rate  year pop_total r_op_ovr_total r_op_dep_total  r_drug_ovr_total  ///
											pop_white r_op_ovr__r_w  r_op_dep__r_w r_drug_ovr__r_w  ///
											pop_black r_op_ovr__r_b  r_op_dep__r_b r_drug_ovr__r_b   ///
											pop_hisp  r_op_ovr__r_h  r_op_dep__r_h r_drug_ovr__r_h   ///
											

foreach x in `indent_list' {
local lab: variable label `x'
label variable `x' "\hspace{0.5cm} `lab'"

}

// List of variables to indent twice
local indent2_list  pop_total r_op_ovr_total r_op_dep_total  r_drug_ovr_total   ///
											pop_white r_op_ovr__r_w  r_op_dep__r_w  r_drug_ovr__r_w   ///
											pop_black r_op_ovr__r_b  r_op_dep__r_b  r_drug_ovr__r_b   ///
											pop_hisp  r_op_ovr__r_h  r_op_dep__r_h  r_drug_ovr__r_h   

foreach x in `indent2_list' {
local lab: variable label `x'
label variable `x' "\hspace{0.5cm} `lab'"

}

// Full list of variables
local sum_list  unemp_rate  year pop_total r_drug_ovr_total r_op_ovr_total   ///
											pop_white r_drug_ovr__r_w r_op_ovr__r_w    ///
											pop_black r_drug_ovr__r_b r_op_ovr__r_b   ///
											pop_hisp r_drug_ovr__r_h r_op_ovr__r_h   

											
// Export Summary Table
	eststo clear
	estpost summarize  unemp_rate 
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)   collabels(none) eform  ///
	noobs substitute(\_ _) noline ///
	refcat(unemp_rate "\emph{Emergency Department Data \vspace{.25cm}}" , nolabel) 

	
// Export Summary Table
	eststo clear
	estpost summarize  year
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)   collabels(none) eform  ///
	noobs substitute(\_ _) noline

// Export Summary Table
	eststo clear
	estpost summarize  pop_total
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)   collabels(none) eform  ///
	noobs substitute(\_ _) noline ///
	refcat(pop_total "\hspace{0.5cm} \emph{All}" , nolabel) 

// Export Summary Table
	eststo clear
	estpost summarize  r_op_ovr_total r_drug_ovr_total   [aweight=pop_total]  
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)   collabels(none) eform  ///
	noobs substitute(\_ _) noline

// Export Summary Table
	eststo clear
	estpost summarize  pop_white
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)   collabels(none) eform  ///
	noobs substitute(\_ _) noline ///
	refcat(pop_white "\hspace{0.5cm} \emph{White}" , nolabel) 


// Export Summary Table
	eststo clear
	estpost summarize r_op_ovr__r_w r_drug_ovr__r_w   [aweight=pop_white] 
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)   collabels(none) eform  ///
	noobs substitute(\_ _) noline	

// Export Summary Table
	eststo clear
	estpost summarize pop_black
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)   collabels(none) eform  ///
	noobs substitute(\_ _) noline ///
	refcat(pop_black "\hspace{0.5cm} \emph{Black}"  , nolabel) 

// Export Summary Table
	eststo clear
	estpost summarize r_op_ovr__r_b r_drug_ovr__r_b  [aweight=pop_black] 
	esttab using "$results_path/tables/table_2_summary_statistics_weighted.tex", append ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)   collabels(none) eform  ///
	noobs substitute(\_ _) noline 		
