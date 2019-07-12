// Inner Bootstrap Program
	capture program drop boot
	program define boot, rclass
	 preserve 
	  bsample
		qui reghdfe y_with_simulated_effect_size unemp_rate   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)  
	  return scalar se_unemp = _se[unemp_rate]
	  return scalar b_unemp = _b[unemp_rate]
	  return scalar df = e(df_r)
	 restore
	end
	

// Outer Program
capture program drop power_for_simulated_effect_size
*----------
program define power_for_simulated_effect_size
syntax  [if] [in],  [alpha(real .05) simulated_effect_size(real 1.0 ) bootstrap_numb(integer 100) row(integer 2)]
*----------
use  "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear


	gen  r_op_ovr_any = (op_ovr_any/pop_total)*100000
				
	gen  r_op_ovr_any_r_w = (op_ovr_any_r_w/pop_white)*100000
	gen  r_op_ovr_any_r_b = (op_ovr_any_r_b/pop_black)*100000
	gen  r_op_ovr_any_r_h = (op_ovr_any_r_h/pop_hisp)*100000
	
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


		 reghdfe r_drug_ovr_total unemp_rate   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)  residuals(actual_residuals)
		 
		 gen null_y = r_drug_ovr_total  - _b[unemp_rate]*unemp_rate 
		 
		 reghdfe null_y unemp_rate   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips) 
		
		
		gen y_with_simulated_effect_size = null_y + `simulated_effect_size'*unemp_rate



	// Draw with replacement (same N as whole dataset) from this new distribution 1000 times (or any large number)
	simulate se=r(se_unemp) b=r(b_unemp) df =r(df), reps(`bootstrap_numb') seed(12345): boot
			gen z_score = abs((b/se))
			gen p_val = ttail(df,z_score)*2
			
	// The percentage of times we accept that 5 is different from zero at level alpha is our power
		scalar alpha = `alpha'
		scalar obs = _N
				
		gen significant_at_alpha = 0
		replace significant_at_alpha=1 if p_val <=  alpha
		gen ones = 1
				
		egen power_at_alpha = sum(significant_at_alpha)
		replace power_at_alpha = power_at_alpha/obs
				
		gen row = `row'
			if row == 1 {
				putexcel set "$temp_path/power_analysis_results.xlsx", replace
				
				putexcel A1 = "Power"
				putexcel B1 = "Alpha"
				putexcel C1 = "Simulated Effect Size"
				putexcel D1 = "Bootstrap Number"

				sum power_at_alpha
				putexcel A2 = `r(mean)'
				putexcel B2 = `alpha'
				putexcel C2 = `simulated_effect_size'
				putexcel D2 = `bootstrap_numb'

			}
			replace row = row+1
			local row = `row' +1
			if row > 2 {
				putexcel set "$temp_path/power_analysis_results.xlsx", modify
				
				sum power_at_alpha
				putexcel A`row' = `r(mean)'
				putexcel B`row' = `alpha'
				putexcel C`row' = `simulated_effect_size'
				putexcel D`row' = `bootstrap_numb'
	
				
				}

*----------
end
*----------

// Run the program
set seed 1234

// Set up Choices
	local alpha_list .1 .05 .01 .001

// Implement the choices in a loop. It should mostly add to the same dataset. 
	//This is important to start the putexcel on the right row
	local r = 1

					//Each Alpha Level
					foreach a in `alpha_list' {
						//Various percent reductions from the mean
						forvalues p = 0(.5)20 {
								// Determine the Power 
								power_for_simulated_effect_size, alpha(`a') simulated_effect_size(`p') bootstrap_numb(100)  row(`r') 
								//Add One to the Row
								local ++r
							
						}
					}
				
clear all 
	import excel "$temp_path/power_analysis_results.xlsx", sheet("Sheet1") firstrow

			
	gen label_a_001 =""
	replace label_a_001 =  "{&alpha} =.001" if SimulatedEffectSize ==5
	
	gen label_a_01 =""
	replace label_a_01 =  "{&alpha} =.01" if SimulatedEffectSize ==4
	
	gen label_a_05 =""
	replace label_a_05 =  "{&alpha} =.05" if SimulatedEffectSize ==3
	
	gen label_a_1 =""
	replace label_a_1 =  "{&alpha} =.1" if SimulatedEffectSize ==2.5
		
	twoway ///
		(connected Power SimulatedEffectSize ///
			if Alpha==.001 & SimulatedEffectSize<8.01, lpattern("l") color(sea) msymbol(none) mlabcolor(sea) mlabel(label_a_001) mlabsize(3)) ///
		(connected Power SimulatedEffectSize ///
			if Alpha==.01 & SimulatedEffectSize<8.01, lpattern(".._")  color(turquoise) msymbol(none) mlabcolor(turquoise) mlabel(label_a_01) mlabsize(3) ) ///
		(connected Power SimulatedEffectSize ///
			if Alpha==.05 & SimulatedEffectSize<8.01, lpattern("-") color(vermillion) msymbol(none) mlabcolor(vermillion)  mlabel(label_a_05) mlabsize(3) mlabpos(3)) ///
		(connected Power SimulatedEffectSize ///
			if Alpha==.1 & SimulatedEffectSize<8.01, lpattern("l")  color(black) msymbol(none) mlabcolor(black) mlabel(label_a_1) mlabsize(3) mlabpos(9)) ///
		, xlabel(0(1)8, nogrid ) ///
		ylabel(,gmax noticks) ///
		ytitle("") ///
		xtitle("Imposed True Treatment Effect Size") ///
		legend(off) ///
		xscale(r(0 8)) ///
		subtitle("Power (% of cases where imposed true treatment effect is correctly identified)", position(11) size(3)) ///
		xline(.95, lpattern(dash) lcolor(grey) noextend) 
		
		*note("Note: The dashed vertical line is the estimated effect size of 1 percentage point increase in the unemployment rate" "          on the opioid overdose ED visit rate. {&alpha} is the probability of a type I error.", pos(7))
			
			*		title("Simulated Power Analysis For All Drug Overdose ED Visit Rate") ///

		graph export "$results_path/appendix/figures/power_analysis_results.pdf", replace

