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

	xtile pop_20 = pop if year==1999, n(20)
	sort countycode year
	bysort countycode: carryforward pop_20, replace
	
	


mat avg_aopioid = J(100,2,.)

forvalues i = 1/100 {
	qui reghdfe r_aopioid_version_`i' unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)  
	mat avg_aopioid[`i',1] = _b[unemp_rate]
	mat avg_aopioid[`i',2] = _se[unemp_rate]
}

mat avg_aopioidw = J(100,2,.)

forvalues i = 1/100 {
	qui reghdfe r_aopioidw_version_`i' unemp_rate  [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  
	mat avg_aopioidw[`i',1] = _b[unemp_rate]
	mat avg_aopioidw[`i',2] = _se[unemp_rate]
}

mat avg_aopioidb = J(100,2,.)

forvalues i = 1/100 {
	qui reghdfe r_aopioidb_version_`i' unemp_rate  [aweight=popb], absorb(countycode state_year year) vce(cluster countycode)  
	mat avg_aopioidb[`i',1] = _b[unemp_rate]
	mat avg_aopioidb[`i',2] = _se[unemp_rate]
}

mat avg_aopioidh = J(100,2,.)

forvalues i = 1/100 {
	qui reghdfe r_aopioidh_version_`i' unemp_rate  [aweight=poph], absorb(countycode state_year year) vce(cluster countycode)  
	mat avg_aopioidh[`i',1] = _b[unemp_rate]
	mat avg_aopioidh[`i',2] = _se[unemp_rate]
}



svmat avg_aopioid
svmat avg_aopioidw
svmat avg_aopioidb
svmat avg_aopioidh

//Calculate the coefficient
rename  avg_aopioid1 avg_aopioid_b
sum avg_aopioid_b
scalar avg_aopioid_coef = `r(mean)'

//Calculate the within variance
rename  avg_aopioid2 avg_aopioid_se
gen avg_aopioid_se_2 = avg_aopioid_se^2

sum avg_aopioid_se_2
scalar avg_aopioid_within_variance = `r(mean)'


//Calculate the between variance
gen avg_aopioid_b_msd = (avg_aopioid_b-avg_aopioid_coef)^2
sum avg_aopioid_b_msd
scalar avg_aopioid_between_variance = (1/(100-1))*`r(sum)'


//Calculate total variance of the prediction
scalar avg_aopioid_total_variance = avg_aopioid_within_variance + (1+ 1/100)*avg_aopioid_between_variance

// Calculate standard error of prediction 
scalar avg_aopioid_se = sqrt(avg_aopioid_total_variance)

// Calculate standard error of within  
scalar avg_aopioid_se_within = sqrt(avg_aopioid_within_variance)

// Calculate standard error of between  
scalar avg_aopioid_se_between = sqrt(avg_aopioid_between_variance)



local loop_list aopioidw aopioidb aopioidh
foreach x in `loop_list' {

	//Calculate the coefficient
	rename  avg_`x'1 avg_`x'_b
	sum avg_`x'_b
	scalar avg_`x'_coef = `r(mean)'

	//Calculate the within variance
	rename  avg_`x'2 avg_`x'_se
	gen avg_`x'_se_2 = avg_`x'_se^2

	sum avg_`x'_se_2
	scalar avg_`x'_within_variance = `r(mean)'


	//Calculate the between variance
	gen avg_`x'_b_msd = (avg_`x'_b-avg_`x'_coef)^2
	sum avg_`x'_b_msd
	scalar avg_`x'_between_variance = (1/(100-1))*`r(sum)'


	//Calculate total variance of the prediction
	scalar avg_`x'_total_variance = avg_`x'_within_variance + (1+ 1/100)*avg_`x'_between_variance

	// Calculate standard error of prediction 
	scalar avg_`x'_se = sqrt(avg_`x'_total_variance)

	// Calculate standard error of within  
	scalar avg_`x'_se_within = sqrt(avg_`x'_within_variance)

	// Calculate standard error of between  
	scalar avg_`x'_se_between = sqrt(avg_`x'_between_variance)


}



qui reghdfe aopioidr unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)  
scalar avg_aopioid_df = e(df_r)
gen avg_aopioid_z_score = abs((avg_aopioid_coef/avg_aopioid_se))
gen avg_aopioid_p_val = ttail(avg_aopioid_df,avg_aopioid_z_score)*2

qui reghdfe aopioidwr unemp_rate  [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  
scalar avg_aopioidw_df = e(df_r)
gen avg_aopioidw_z_score = abs((avg_aopioidw_coef/avg_aopioidw_se))
gen avg_aopioidw_p_val = ttail(avg_aopioidw_df,avg_aopioidw_z_score)*2

qui reghdfe aopioidbr unemp_rate  [aweight=popb], absorb(countycode state_year year) vce(cluster countycode)  
scalar avg_aopioidb_df = e(df_r)
gen avg_aopioidb_z_score = abs((avg_aopioidb_coef/avg_aopioidb_se))
gen avg_aopioidb_p_val = ttail(avg_aopioidb_df,avg_aopioidb_z_score)*2

qui reghdfe aopioidhr unemp_rate  [aweight=poph], absorb(countycode state_year year) vce(cluster countycode)  
scalar avg_aopioidh_df = e(df_r)
gen avg_aopioidh_z_score = abs((avg_aopioidh_coef/avg_aopioidh_se))
gen avg_aopioidh_p_val = ttail(avg_aopioidh_df,avg_aopioidh_z_score)*2

di avg_aopioid_se
di avg_aopioidw_se
di avg_aopioidb_se
di avg_aopioidh_se

sum *_p_val
scalar mi_95_hi =  avg_aopioid_coef + 1.96*avg_aopioid_se
scalar mi_95_low = avg_aopioid_coef - 1.96*avg_aopioid_se

scalar boot_95_hi =  avg_aopioid_coef + 1.96*avg_aopioid_se_between
scalar boot_95_low = avg_aopioid_coef - 1.96*avg_aopioid_se_between

scalar within_95_hi =  avg_aopioid_coef + 1.96*avg_aopioid_se_within
scalar within_95_low = avg_aopioid_coef - 1.96*avg_aopioid_se_within


local avg_aopioid_coef =avg_aopioid_coef

local mi_95_hi = mi_95_hi
local mi_95_low = mi_95_low
local boot_95_hi = boot_95_hi
local boot_95_low = boot_95_low

local within_95_hi = within_95_hi
local within_95_low = within_95_low

local within_95_hi_l = within_95_hi - .005
local within_95_low_l = within_95_low +.005

twoway (hist avg_aopioid_b , fcolor(none)), ///
xlabel(`mi_95_low' "Low Bound (MI)" `within_95_low_l' "Low Bound (within)" `boot_95_low' "Low Bound (boot)" `avg_aopioid_coef' "Mean" `boot_95_hi' "Up Bound (boot)" `within_95_hi_l' "Up Bound (within)" `mi_95_hi'  "Up Bound (MI)",  angle(45)) ///
xline(`avg_aopioid_coef', lcolor(green)) ///
xline(`mi_95_hi', lcolor(red)) ///
xline(`mi_95_low', lcolor(red)) ///
xline(`boot_95_hi', lcolor(blue)) ///
xline(`boot_95_low', lcolor(blue)) ///
xline(`within_95_hi', lcolor(gs10)) ///
xline(`within_95_low', lcolor(gs10)) ///
xtitle("Distribution of Coefficents from Mutliple Imputation Procedure")
graph export "$results_path/appendix/figures/multiple_imputation_results.pdf", replace

*Don't run from here and below unless you want to redo the tables since part of this is done by hand.
// Opioid Deaths by Race
qui reghdfe aopioidr unemp_rate  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)  
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo op_all
		
qui reghdfe aopioidwr unemp_rate  [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  
					
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo op_white
		
qui reghdfe aopioidbr unemp_rate  [aweight=popb], absorb(countycode state_year year) vce(cluster countycode)  
					
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo op_black

qui reghdfe aopioidhr unemp_rate  [aweight=poph], absorb(countycode state_year year) vce(cluster countycode)  

					
	 	estadd local year_dum "Yes"
		estadd local state_fe "Yes"
		estadd local county_trend "No"
		estadd local state_by_year "Yes"
		
		eststo op_hisp		
	local lbl: variable  label aopioidr
	local lbl2: variable  label unemp_rate
		
	esttab op_all op_white  op_black  op_hisp using  "$results_path/appendix/tables/table_a11_county_multiple_inf.tex" , ///
	keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
	replace se order(unemp_rate) ///
	booktabs b(%20.4f) se(%20.4f) eqlabels(none) alignment(S S)  ///
	f mtitles("All" "White" "Black" "Hispanic") substitute(\_ _) ///
	refcat(unemp_rate "\midrule \emph{Baseline: `lbl'}", nolabel)	///
	coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline	noobs
	******GO IN BY HAND AND UPDATE COEF"S AND SE AND STARS BELOW********
	**THIS CODE IS ONLY TO GET THE SET UP**********
	
 	esttab op_all op_white  op_black op_hisp using  "$results_path/appendix/tables/table_a11_county_multiple_inf.tex" , ///
	keep(unemp_rate)  label star(* 0.10 ** 0.05 *** 0.01) ///
	append se order(unemp_rate) ///
	booktabs b(%20.4f) se(%20.4f) eqlabels(none) alignment(S S)  ///
	stats(N  state_fe year_dum  county_trend state_by_year, fmt(0 0 0 0 0 ) ///
	layout( "\multicolumn{1}{c}{@}"     "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	label("\hline \hspace{0.5cm}Observations" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
	f nomtitles substitute(\_ _) ///
	refcat(unemp_rate "\midrule \emph{Multiple Imputation: `lbl'}", nolabel)	///
	coef(unemp_rate "\hspace{0.5cm}`lbl2'") noline collabels(none) nonumbers 


