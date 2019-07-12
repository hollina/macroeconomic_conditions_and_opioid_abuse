/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 30 August 2016
  
  Last Modified Date: 25 November 2016

  Description: Check to see if results are robust to: 
				1. Run at the State Level; for deaths and ed visits
				2. Limit Years (Dropping Every 3 years)
				3. By Excluded Quintile of County Characteristic (Population Density, Population, % Graduating High School, % Non-White)
				4. Placebos ED Visits (Vomiting During Pregnancy,  "Open Head Wounds, Broken Legs, Broken Arms, and Broken Noses
			
	***DO NOT SHARE CHRIS' DATA***

*/ /////////////////////////////////////////////////////////////////////////////
// Robustness Checks
	// Collapse to State See if results stick
	graph set window fontface "Times New Roman"
	
	
	// Drop Three Previous Years and Three Prior Years
		//Death Data
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
				
				label variable drugr "Drug Death Rate"
				label variable opioidr "Opioid Death Rate per 100k, Rerported"
				label variable popioidr "Opioid Death Rate per 100k, Adjusted"
				label variable aopioidr "Opioid Death Rate"
				label variable aopioidr "Opioid Death Rate"

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
				label variable unemp_rate "Unemployment Rate, [1-100]"
				replace median_income = median_income/1000
				label variable median_income "Median Income, \\\$1000s"
				gen percent_non_white = (pop-popw)/pop
				label variable percent_non_white "\% Non-White, [0-1]"

					
			set matsize 11000
			local drug_list drugr //aopioidr aheroinr	
			
			
			foreach var in `drug_list'{
				//Drop Estimates, use capture in case there are none
					capture drop xb hi lo x
				
				// Generate 0's for one
					g xb = 0 in 1
					g hi = 0 in 1
					g lo = 0 in 1
					
				
				// Run Each Year Loop	
					forvalues yr = 2001(1)2014{

						//Run Estimation
							qui reghdfe `var' unemp_rate  [aweight=pop]  if year!=`yr' & year!=`yr'-1 & year !=`yr'-2, absorb(countycode state_year year) vce(cluster countycode)  	
						
						// Store Values
							loc n = `yr'-2001 + 1
							replace xb =  _b[unemp_rate] in `n'
							replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate] in `n'
							replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate] in `n'					
					}
				// Make Graph
				g x = _n in 1/14
				local lab: variable label `var'
				
				tw (connected xb x in 1/14, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
					(line hi x in 1/14, lpattern(dash) lcolor(erose)) ///
					(line lo x in 1/14, lpattern(dash) lcolor(erose)), ///
					graphr(color(white)) ///
					legend(off) ///
					ylabel(0(.1).6, labsize(3.5)  noticks nogrid) ///
					xtick(1(1)14) ///
					xlabel(1 "99-01" 2 "00-02"  3 "01-03"  4 "02-04"  5 "03-05"  6 "04-06"  7 "05-07"  8 "06-08"  9 "07-09"  10 "08-10"  11 "09-11"   12 "10-12"  13 "11-13"  14 "12-14", labsize(3.25)  nogrid ) ///
					xtit("Excluded Years", size(4.5)) ///
					subtitle("`lab'", size(6) pos(11)) ///
					yline(0, lcolor(cranberry) )
		
				graph save "$results_path/appendix/figures/`var'_drop_years", replace
				graph export "$results_path/appendix/figures/`var'_drop_years.pdf", replace

			}
			
			local drug_list aopioidr //aheroinr

			foreach var in `drug_list'{
				//Drop Estimates, use capture in case there are none
					capture drop xb hi lo x
				
				// Generate 0's for one
					g xb = 0 in 1
					g hi = 0 in 1
					g lo = 0 in 1
					
				
				// Run Each Year Loop	
					forvalues yr = 2001(1)2014{

						//Run Estimation
							qui reghdfe `var' unemp_rate  [aweight=pop]  if year!=`yr' & year!=`yr'-1 & year !=`yr'-2, absorb(countycode state_year year) vce(cluster countycode)  	
						
						// Store Values
							loc n = `yr'-2001 + 1
							replace xb =  _b[unemp_rate] in `n'
							replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate] in `n'
							replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate] in `n'					
					}
				// Make Graph
				g x = _n in 1/14
				local lab: variable label `var'
				
				tw (connected xb x in 1/14, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
					(line hi x in 1/14, lpattern(dash) lcolor(erose)) ///
					(line lo x in 1/14, lpattern(dash) lcolor(erose)), ///
					graphr(color(white)) ///
					legend(off) ///
					ylabel(0(.1).4, labsize(3.5)  noticks nogrid) ///
					xtick(1(1)14) ///
					xlabel(1 "99-01" 2 "00-02"  3 "01-03"  4 "02-04"  5 "03-05"  6 "04-06"  7 "05-07"  8 "06-08"  9 "07-09"  10 "08-10"  11 "09-11"   12 "10-12"  13 "11-13"  14 "12-14", labsize(3.25)  nogrid ) ///
					xtit("Excluded Years", size(4.5)) ///
					subtitle("`lab'", size(6) pos(11)) ///
					yline(0, lcolor(cranberry) )
		
				graph save "$results_path/appendix/figures/`var'_drop_years", replace
				graph export "$results_path/appendix/figures/`var'_drop_years.pdf", replace


			}	
	
			
		//By County Characteristic
		*Change in Import Exposure Per Worker From 1990 to 2007
				merge m:1 StateFIPS CountyFIPS using "$data_path/dorn_data.dta"

						local drug_list drugr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if imp_exp_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Import Exposure per Worker Change (1990-2007) Quintile", size(4.5)) ///
									subtit("Drug Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(0(.2).6, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_by_imp_exp_quintile", replace
									graph export  "$results_path/appendix/figures/drug_by_imp_exp_quintile.pdf", replace
							
							

							}			  
				
					local drug_list aopioidr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if imp_exp_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Import Exposure per Worker Change (1990-2007) Quintile", size(4.5)) ///
									subtit("Opioid Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(0(.2).4, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/opioid_by_imp_exp_den_quintile", replace
									graph export  "$results_path/appendix/figures/opioid_by_imp_exp_quintile.pdf", replace
							}
				

		*Change in % Manufacturing Employement in Working Age Population From 1990 to 2007
						local drug_list drugr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if man_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Manufacturing Employment Change (1990-2007) Quintile", size(4.5)) ///
									subtit("Drug Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(0(.2).6, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_by_man_quintile", replace
									graph export  "$results_path/appendix/figures/drug_by_man_quintile.pdf", replace
							}			  
				
				
					local drug_list aopioidr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if man_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Manufacturing Employment Change (1990-2007) Quintile", size(4.5)) ///
									subtit("Opioid Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(0(.2).4, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/opioid_by_man_den_quintile", replace
									graph export  "$results_path/appendix/figures/opioid_by_man_quintile.pdf", replace
							}
						
				
		
			*Population Density
				capture drop _merge
				merge m:1 StateFIPS CountyFIPS using "$data_path/land_area_2000.dta"
				gen population_density = pop/land_area
				label variable population_density "Population per sq. Mile"

				xtile pop_den_5 = population_density, n(5)
				tab pop_den_5, gen(pop_den_q_)
				drop pop_den_5 
						local drug_list drugr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if pop_den_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Population Density Quintile", size(4.5)) ///
									subtit("Drug Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(0(.2).6, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_by_pop_den_quintile", replace
									graph export  "$results_path/appendix/figures/drug_by_pop_den_quintile.pdf", replace
							}			  
				
				
					local drug_list aopioidr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if pop_den_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Population Density Quintile", size(4.5)) ///
									subtit("Opioid Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/opioid_by_pop_den_quintile", replace
									graph export  "$results_path/appendix/figures/opioid_by_pop_den_quintile.pdf", replace
							}
						
				
			
			*Population		
				xtile pop_5 = pop, n(5)
				tab pop_5, gen(pop_q_)
				drop pop_5 
						local drug_list drugr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if pop_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Population Quintile", size(4.5)) ///
									subtit("Drug Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_by_pop_quintile", replace
									graph export  "$results_path/appendix/figures/drug_by_pop_quintile.pdf", replace
							}			  
				
				
					local drug_list aopioidr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if pop_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Population Quintile", size(4.5)) ///
									subtit("Opioid Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/opioid_by_pop_quintile", replace
									graph export  "$results_path/appendix/figures/opioid_by_pop_quintile.pdf", replace
							}
						
			
		
		*HS Graduation
				capture drop _merge
				merge m:1 StateFIPS CountyFIPS  using "$data_path/high_school_2000.dta"
				label variable highschool_graduates "\% High School Graduates"

				xtile hs_5 = highschool_graduates, n(5)
				tab hs_5, gen(hs_q_)
				drop hs_5 
							local drug_list drugr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if hs_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Graduated High School Quintile", size(4.5)) ///
									subtit("Drug Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(0(.2).6, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_by_hs_quintile", replace
									graph export  "$results_path/appendix/figures/drug_by_hs_quintile.pdf", replace
							}			  
				
				
					local drug_list aopioidr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if hs_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Graduated High School Quintile", size(4.5)) ///
									ytick(0(.05).3) ///
									ylabel(0(.05).3) ///	
									subtit("Opioid Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/opioid_by_hs_quintile", replace
									graph export  "$results_path/appendix/figures/opioid_by_hs_quintile.pdf", replace
							}
						
			
			
			*% Non-White
				xtile p_nw_5 = percent_non_white, n(5)
				tab p_nw_5, gen(p_nw_q_)
				drop p_nw_5 
						local drug_list drugr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if p_nw_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									ylabel(0(.1).6) ///
									legend(off) ///
									xtit("Excluded % Non-White Quintile", size(4.5)) ///
									subtit("Drug Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_by_pnw_quintile", replace
									graph export  "$results_path/appendix/figures/drug_by_pnw_quintile.pdf", replace
							}			  
				
				
					local drug_list aopioidr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate [aweight=pop] if p_nw_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Non-White Quintile", size(4.5)) ///
									subtit("Opioid Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/opioid_by_pnw_quintile", replace
									graph export  "$results_path/appendix/figures/opioid_by_pnw_quintile.pdf", replace
							}
						
				
				
			*% Non-White
						local drug_list drugwr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=popw]     if p_nw_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Non-White Quintile", size(4.5)) ///
									subtit("White Drug Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/w_drug_by_pnw_quintile", replace
									graph export  "$results_path/appendix/figures/w_drug_by_pnw_quintile.pdf", replace
							}			  
				
				
					local drug_list aopioidwr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate [aweight=popw] if p_nw_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Non-White Quintile", size(4.5)) ///
									subtit("White Opioid Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/w_opioid_by_pnw_quintile", replace
									graph export  "$results_path/appendix/figures/w_opioid_by_pnw_quintile.pdf", replace
							}
						
				
		
		*Opioid Death Magnitude
				xtile p_op_5 = aopioidr, n(5)
				tab p_op_5, gen(p_op_q_)
				drop p_op_5 
						local drug_list drugr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate   [aweight=pop]     if p_op_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Opioid Death Rate Quintile", size(4.5)) ///
									subtit("Drug Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_by_op_quintile", replace
									graph export  "$results_path/appendix/figures/drug_by_op_quintile.pdf", replace
							}			  
				
				
					local drug_list aopioidr 

						foreach var in `drug_list' {
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `var' unemp_rate [aweight=pop] if p_op_q_`y'!=1, absorb(countycode state_year year) vce(cluster countycode)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Opioid Death Rate Quintile", size(4.5)) ///
									subtit("Opioid Death Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/opioid_by_op_quintile", replace
									graph export  "$results_path/appendix/figures/opioid_by_op_quintile.pdf", replace
							}
						
				
				
////////////////////////////////////////////////////////////////////////////////
//ED Data
clear all

// Open data
use  "$raw_data_res_ed_path/drug_ed_visits_with_county.dta"

// Create Log Visits per 100k, Vists per 100k, and Log Visits (plus 1)
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
				label variable unemp_rate "Unemployment Rate, [1-100]"
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



				
				local y_list r_drug_ovr_total 

				foreach y in `y_list' {

			
					//Drop Estimates, use capture in case there are none
					capture drop xb hi lo x
				
				// Generate 0's for one
					g xb = 0 in 1
					g hi = 0 in 1
					g lo = 0 in 1
					
				
				// Run Each Year Loop	
					forvalues yr = 2004(1)2014{

						//Run Estimation
							reghdfe `y' unemp_rate   [aweight=pop_total]  if year!=`yr' & year!=`yr'-1 & year !=`yr'-2, absorb(fips state_year year) vce(cluster fips)  
						
						// Store Values
							loc n = `yr'-2004 + 1
							replace xb =  _b[unemp_rate] in `n'
							replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate] in `n'
							replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate] in `n'					
					}
				// Make Graph
				g x = _n in 1/11
				local lab: variable label `y'
				
				tw (connected xb x in 1/11, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
					(line hi x in 1/11, lpattern(dash) lcolor(erose)) ///
					(line lo x in 1/11, lpattern(dash) lcolor(erose)), ///
					graphr(color(white)) ///
					legend(off) ///
					ylabel(, labsize(4.5) noticks nogrid) ///
					xtick(1(1)11) ///
					xlabel(1 "02-04"  2 "03-05"  3 "04-06"  4 "05-07"  5 "06-08"  6 "07-09"  7 "08-10"  8 "09-11"   9 "10-12"  10 "11-13"  11 "12-14", labsize(3.25) nogrid) ///
					xtit("Excluded Years", size(4.5)) ///
					subtit("`lab'", size(6) pos(11)) ///
					yline(0, lcolor(cranberry)) 
					graph save "$results_path/appendix/figures/`y'_drop_years", replace
				graph export "$results_path/appendix/figures/`y'_drop_years.pdf", replace

				
				
					}
					
				local y_list  r_op_ovr_total 

				foreach y in `y_list' {

			
					//Drop Estimates, use capture in case there are none
					capture drop xb hi lo x
				
				// Generate 0's for one
					g xb = 0 in 1
					g hi = 0 in 1
					g lo = 0 in 1
					
				
				// Run Each Year Loop	
					forvalues yr = 2004(1)2014{

						//Run Estimation
							reghdfe `y' unemp_rate   [aweight=pop_total]  if year!=`yr' & year!=`yr'-1 & year !=`yr'-2, absorb(fips state_year year) vce(cluster fips)  
						
						// Store Values
							loc n = `yr'-2004 + 1
							replace xb =  _b[unemp_rate] in `n'
							replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate] in `n'
							replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate] in `n'					
					}
				// Make Graph
				g x = _n in 1/11
				local lab: variable label `y'
				
				tw (connected xb x in 1/11, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
					(line hi x in 1/11, lpattern(dash) lcolor(erose)) ///
					(line lo x in 1/11, lpattern(dash) lcolor(erose)), ///
					graphr(color(white)) ///
					legend(off) ///
					ylabel(, labsize(4.5) nogrid notick) ///
					xtick(1(1)11) ///
					xlabel(1 "02-04"  2 "03-05"  3 "04-06"  4 "05-07"  5 "06-08"  6 "07-09"  7 "08-10"  8 "09-11"   9 "10-12"  10 "11-13"  11 "12-14", labsize(3.25) nogrid) ///
					xtit("Excluded Years", size(4.5)) ///
					subtit("`lab'", size(6) pos(11)) ///
					yline(0, lcolor(cranberry)) 
		
					graph save "$results_path/appendix/figures/`y'_drop_years", replace
				graph export "$results_path/appendix/figures/`y'_drop_years.pdf", replace

				
				
					}
			
		//By County Characteristic
					*Change in Import Exposure Per Worker From 1990 to 2007
				//Fix FL Problem 
				replace CountyFIPS=25 if StateFIPS==12 & CountyFIPS==86
 				
				merge m:1 StateFIPS CountyFIPS using "$data_path/dorn_data.dta"
				replace CountyFIPS=86 if StateFIPS==12 & CountyFIPS==25

			
				drop man_q_*
				drop imp_exp_*
				drop _merge
				 
				xtile man_den_5 = d_pct_manuf if !missing(r_drug_ovr_total), n(5)
				tab man_den_5, gen(man_q_)
				drop man_den_5 
		
				xtile imp_exp_den_5 = d_tradeusch_pw if !missing(r_drug_ovr_total), n(5)
				tab imp_exp_den_5, gen(imp_exp_q_)
				drop imp_exp_den_5 

						
				local y_list r_drug_ovr_total 

					foreach z in `y_list' {

							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if imp_exp_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Import Exposure per Worker Change (1990-2007) Quintile", size(4.5)) ///
									subtit("Drug Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_ovr_by_imp_exp_quintile", replace
									graph export  "$results_path/appendix/figures/drug_ovr_by_imp_exp_quintile.pdf", replace
							}
					local y_list r_op_ovr_total 

					foreach z in `y_list' {

							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if imp_exp_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Import Exposure per Worker Change (1990-2007) Quintile", size(4.5)) ///
									subtit("Opioid Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/op_ovr_by_imp_exp_quintile", replace
									graph export  "$results_path/appendix/figures/op_ovr_by_imp_exp_quintile.pdf", replace
							}
							
				
		*Change in % Manufacturing Employement in Working Age Population From 1990 to 2007


				local y_list r_drug_ovr_total 

					foreach z in `y_list' {

							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if man_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Manufacturing Employment Change (1990-2007) Quintile", size(4.5)) ///
									subtit("Drug Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_ovr_by_man_quintile", replace
									graph export  "$results_path/appendix/figures/drug_ovr_by_man_quintile.pdf", replace
							}
					local y_list r_op_ovr_total 

					foreach z in `y_list' {

							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if man_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Manufacturing Employment Change (1990-2007) Quintile", size(4.5)) ///
									subtit("Opioid Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/op_ovr_by_man_quintile", replace
									graph export  "$results_path/appendix/figures/op_ovr_by_man_quintile.pdf", replace
							}
							
				
			*Population Density
				merge m:1 StateFIPS CountyFIPS using "$data_path/land_area_2000.dta"
				gen population_density = pop_total/land_area
				label variable population_density "Population per sq. Mile"

				xtile pop_den_5 = population_density, n(5)
				tab pop_den_5, gen(pop_den_q_)
				drop pop_den_5 
				  
						
							local y_list r_drug_ovr_total 

					foreach z in `y_list' {

							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if pop_den_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Population Density Quintile", size(4.5)) ///
									subtit("Drug Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_ovr_by_pop_den_quintile", replace
									graph export  "$results_path/appendix/figures/drug_ovr_by_pop_den_quintile.pdf", replace
							}
					local y_list r_op_ovr_total 

					foreach z in `y_list' {

							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if pop_den_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Population Density Quintile", size(4.5)) ///
									subtit("Opioid Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/op_ovr_by_pop_den_quintile", replace
									graph export  "$results_path/appendix/figures/op_ovr_by_pop_den_quintile.pdf", replace
							}
							
		
		*Population 
				xtile pop_5 = pop_total, n(5)
				tab pop_5, gen(pop_q_)
				drop pop_5 
				 
					local y_list r_drug_ovr_total 

					foreach z in `y_list' {

							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if pop_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Population Quintile", size(4.5)) ///
									subtit("Drug Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_ovr_by_pop_quintile", replace
									graph export  "$results_path/appendix/figures/drug_ovr_by_pop_quintile.pdf", replace
							}
											
					
					local y_list r_op_ovr_total 

					foreach z in `y_list' {

							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if pop_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded Population Quintile", size(4.5)) ///
									subtit("Opioid Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/op_ovr_by_pop_quintile", replace
									graph export  "$results_path/appendix/figures/op_ovr_by_pop_quintile.pdf", replace
							}
					
			*HS Graduation
				capture drop _merge
				merge m:1 StateFIPS CountyFIPS  using "$data_path/high_school_2000.dta"
				label variable highschool_graduates "\% High School Graduates"

				xtile hs_5 = highschool_graduates, n(5)
				tab hs_5, gen(hs_q_)
				drop hs_5 
					local y_list r_drug_ovr_total

					foreach z in `y_list' {


							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {
									reghdfe `z' unemp_rate   [aweight=pop_total]     if hs_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
							
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Graduated High School Quintile", size(4.5)) ///
									subtit("Drug Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_ovr_by_hs_quintile", replace
									graph export  "$results_path/appendix/figures/drug_ovr_by_hs_quintile.pdf", replace
							
						}
				  
					local y_list r_op_ovr_total

					foreach z in `y_list' {


							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {
									reghdfe `z' unemp_rate   [aweight=pop_total]     if hs_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
							
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Graduated High School Quintile", size(4.5)) ///
									subtit("Opioid Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/op_ovr_by_hs_quintile", replace
									graph export  "$results_path/appendix/figures/op_ovr_by_hs_quintile.pdf", replace
							
						}
						
						
					
			*% Non-White
				xtile p_nw_5 = percent_non_white, n(5)
				tab p_nw_5, gen(p_nw_q_)
				drop p_nw_5 
				
						
				local y_list r_drug_ovr_total 

				foreach z in `y_list' {

					
					//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if p_nw_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Non-White Quintile", size(4.5)) ///
									subtit("Drug Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_ovr_by_pnw_quintile", replace
									graph export  "$results_path/appendix/figures/drug_ovr_by_pnw_quintile.pdf", replace
							
						}
					local y_list r_op_ovr_total 

					foreach z in `y_list' {

					
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if p_nw_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Non-White Quintile", size(4.5) ) ///
									subtit("Opioid Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/op_ovr_by_pnw_quintile", replace
									graph export  "$results_path/appendix/figures/op_ovr_by_pnw_quintile.pdf", replace
							
						}

			*% Non-White for Whites						
				local y_list r_drug_ovr__r_w 

				foreach z in `y_list' {

					
					//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_white]     if p_nw_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Non-White Quintile", size(4.5)) ///
									subtit("White Drug Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/w_drug_ovr_by_pnw_quintile", replace
									graph export  "$results_path/appendix/figures/w_drug_ovr_by_pnw_quintile.pdf", replace
							
						}
					local y_list r_op_ovr__r_w 

					foreach z in `y_list' {

					
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_white]     if p_nw_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Non-White Quintile", size(4.5) ) ///
									subtit("White Opioid Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/w_op_ovr_by_pnw_quintile", replace
									graph export  "$results_path/appendix/figures/w_op_ovr_by_pnw_quintile.pdf", replace
							
						}
		
		*Opioid Death Magnitude
				xtile p_op_5 = r_op_ovr_total, n(5)
				tab p_op_5, gen(p_op_q_)
				drop p_op_5 
				
				local y_list r_drug_ovr_total 

				foreach z in `y_list' {

					
					//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if p_op_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Opioid Death Rate Quintile", size(4.5)) ///
									subtit("Drug Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/drug_ovr_by_op_quintile", replace
									graph export  "$results_path/appendix/figures/drug_ovr_by_op_quintile.pdf", replace
							
						}
					local y_list r_op_ovr_total 

					foreach z in `y_list' {

					
							//All Drug Deaths, Reported	
								capture drop xb* hi* lo* x*
									g xb  = 0 in 1
									g hi  = 0 in 1
									g lo  = 0 in 1
								forvalues y = 1/5 {

								//Run Estimation
									reghdfe `z' unemp_rate   [aweight=pop_total]     if p_op_q_`y'!=1, absorb(fips state_year year) vce(cluster fips)  
														
									replace xb    = _b[unemp_rate] in `y'
									replace hi = _b[unemp_rate] + 1.96 * _se[unemp_rate]  in `y'
									replace lo = _b[unemp_rate] - 1.96 * _se[unemp_rate]  in `y'

								}

								g x = _n in 1/5

								tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
									(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
									(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
									graphr(color(white)) ///
									legend(off) ///
									xtit("Excluded % Opioid Death Rate Quintile", size(4.5) ) ///
									subtit("Opioid Overdose ED Visit Rate", size(6) pos(11)) ///
									yline(0, lcolor(cranberry)) ///
									ylabel(, noticks nogrid) ///
									xlabel(,nogrid)
									graph save "$results_path/appendix/figures/op_ovr_by_op_quintile", replace
									graph export  "$results_path/appendix/figures/op_ovr_by_op_quintile.pdf", replace
							
						}
			//Placebos for the ED Visits	
	
		gen  r_uti_total = (uti_total/pop_total)*100000
		gen  r_vom_preg_total = (vom_preg_total/pop_total)*100000
		gen  r_brk_leg_total = (brk_leg_total/pop_total)*100000
		gen  r_brk_arm_total = (brk_arm_total/pop_total)*100000
		gen  r_bkn_nose_total = (bkn_nose_total/pop_total)*100000
		gen  r_head_total = (head_total/pop_total)*100000
  
		label var r_uti_total "UTIs"
		label var r_vom_preg_total "Vomiting During Pregnancy"
		label var r_brk_leg_total "Broken Legs"
		label var r_brk_arm_total "Broken Arms"
		label var r_bkn_nose_total "Broken Noses"
		label var r_head_total "Open Head Wounds"

		local y_list   op_ovr drug_ovr  uti vom_preg head brk_leg brk_arm bkn_nose 

		foreach y in `y_list' {

		 
			reghdfe r_`y'_total unemp_rate   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)  

			
			eststo m_`y'	
		}
		
	
	
		 coefplot  m_op_ovr   m_vom_preg m_head m_brk_leg m_brk_arm m_bkn_nose /// 
		 , keep(unemp_rate) yline(0) ciopts(recast(rcap)) ///			
				vertical title("Effect of 1% Increase in Unemployment Rate on ED Visit Rate for:" ,size(small)) ///
				legend(pos(6) col(6) lab(2 "Opioid Overdoses")  lab(4 "Vomiting During Pregnancy") lab(6 "Open Head Wounds")  ///
				lab(8 "Broken Legs") lab(10 "Broken Arms") lab(12 "Broken Noses") stack symplacement(center) size(2.75) ) ///
				coeflabel(unemp_rate=" ") 

		
		graph export "$results_path/appendix/figures/placebos.pdf", replace
		
		label var r_op_dep_total "Opioid Dependence ED Visit Rate"
		label var r_op_ovr_total "Opioid Overdose ED Visit Rate"

	// Break Down of Each Overdose Type
		// Create Log Visits per 100k, Vists per 100k, and Log Visits (plus 1)
	ds  *__age*  *__female*  *__payer* 
	foreach var in `r(varlist)' {
		local templabel : var label `var'

		gen r_`var' = (`var'/pop_total)*100000
		label variable  r_`var'  "Rate (100k) `templabel'"
		
	}
	
	
	
	
	local y_list drug_ovr op_ovr   

	foreach y in `y_list' {

		qui ds r_`y'_total r_`y'__age* r_`y'__female r_`y'__payer*
		
		foreach var in `r(varlist)' {			
		
			reghdfe `var' unemp_rate   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)  
			estimates store m_`var'

		}
		
		local templabel : var label r_`y'_total
		

	
	
		qui coefplot ///
		m_r_`y'_total ///
		m_r_`y'__age_1_17 m_r_`y'__age_18_25 m_r_`y'__age_26_45 m_r_`y'__age_46_64 m_r_`y'__age_65_up ///
		 m_r_`y'__payer_ins m_r_`y'__payer_self m_r_`y'__payer_mcaid m_r_`y'__payer_mcare  /// 
		 , keep(unemp_rate) yline(0) ///
				ciopts(recast(rcap)) ///
				vertical title("Effect of 1% Increase in Unemployment Rate on `templabel'" ,size(small)) ///
				coeflabel(unemp_rate="Unemployment Rate") ///
				legend(pos(6) col(12) lab(2 "Total") lab(4 "Age:1-17") lab(6 "Age:18-25")  lab(8 "Age:26-45") lab(10 "Age:46-64") lab(12 "Age:65+") lab(14 "Private Ins.") lab(16 "Uninsured") lab(18 "Medicaid") lab(20 "Medicare") stack symplacement(center)) 
		
		graph export "$results_path/appendix/figures/`y'_all_spec.pdf", replace
	
	}
exit
// Use Employee : Population Ratio instead of % Unemployment
	
clear all

capture program drop r_specification_table_by_race
*----------
program define r_specification_table_by_race
*----------
syntax, race(string) 
	
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
		merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
		
		keep if _merge==3 
		drop _merge
		
		merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
		
		keep if _merge==3 
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

		gen emp_ratio = numb_emp/pop_15_64
		label variable emp_ratio "Employment-to-Population ratio"

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
			local drug_list drugr //aopioidr aheroinr
		
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' numb_emp [aweight=pop], absorb(countycode year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
					
				qui reghdfe `var' numb_emp county_time_* [aweight=pop], absorb(countycode year) vce(cluster countycode)  
				//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"

					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' numb_emp  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_3, nocopy
				
					
				qui reghdfe `var' numb_emp   median_income  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
					
					local lbl: variable  label `var'
					local lbl2: variable  label numb_emp
					local lbl3: variable  label median_income

				
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  `var'_spec_7  using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
				keep(numb_emp median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
				replace se order(numb_emp median_income) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
				f nomtitles substitute(\_ _) ///
				refcat(numb_emp "\midrule \emph{`lbl'}", nolabel)	///
				coef(numb_emp "\hspace{0.5cm}`lbl2'" ///
				median_income "\hspace{0.5cm}`lbl3'") noline
				
				capture est clear
			}
		

			local drug_list aopioidr aheroinr
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' numb_emp [aweight=pop], absorb(countycode year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
					
				qui reghdfe `var' numb_emp county_time_*  [aweight=pop], absorb(countycode year) vce(cluster countycode)  
				//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"

					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' numb_emp  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_3, nocopy
				
					
				qui reghdfe `var' numb_emp   median_income  [aweight=pop], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
					
					local lbl: variable  label `var'
					local lbl2: variable  label numb_emp
					local lbl3: variable  label median_income

				
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  `var'_spec_7  using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
				keep(numb_emp median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
				append se order(numb_emp median_income) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
				f nomtitles substitute(\_ _) ///
				refcat(numb_emp "\midrule \emph{`lbl'}", nolabel)	///
				coef(numb_emp "\hspace{0.5cm}`lbl2'" ///
				median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
				
				capture est clear

			}
		}

		
		if white==1 {
			local drug_list drugwr //aopioidr aheroinr
		
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' numb_emp [aweight=popw], absorb(countycode year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
					
				qui reghdfe `var' numb_emp county_time_*  [aweight=popw], absorb(countycode year) vce(cluster countycode)  
				//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"

					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' numb_emp  [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_3, nocopy
				
					
				qui reghdfe `var' numb_emp   median_income  [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
					
					local lbl: variable  label `var'
					local lbl2: variable  label numb_emp
					local lbl3: variable  label median_income

				
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  `var'_spec_7  using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
				keep(numb_emp median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
				replace se order(numb_emp median_income) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
				f nomtitles substitute(\_ _) ///
				refcat(numb_emp "\midrule \emph{`lbl'}", nolabel)	///
				coef(numb_emp "\hspace{0.5cm}`lbl2'" ///
				median_income "\hspace{0.5cm}`lbl3'") noline
				
				capture est clear
			}
		

			local drug_list aopioidwr aheroinwr
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' numb_emp [aweight=popw], absorb(countycode year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
					
				qui reghdfe `var' numb_emp county_time_* [aweight=popw], absorb(countycode year) vce(cluster countycode)  
				//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"

					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' numb_emp  [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_3, nocopy
				
					
				qui reghdfe `var' numb_emp   median_income  [aweight=popw], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
					
					local lbl: variable  label `var'
					local lbl2: variable  label numb_emp
					local lbl3: variable  label median_income

				
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  `var'_spec_7  using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
				keep(numb_emp median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
				append se order(numb_emp median_income) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
				f nomtitles substitute(\_ _) ///
				refcat(numb_emp "\midrule \emph{`lbl'}", nolabel)	///
				coef(numb_emp "\hspace{0.5cm}`lbl2'" ///
				median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
				
				capture est clear

			}
		}



		
		if black==1 {
			local drug_list drugbr //aopioidr aheroinr
		
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' numb_emp [aweight=popb], absorb(countycode year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
					
				qui reghdfe `var' numb_emp county_time_*  [aweight=popb], absorb(countycode year) vce(cluster countycode)  
				//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"

					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' numb_emp  [aweight=popb], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_3, nocopy
				
					
				qui reghdfe `var' numb_emp   median_income  [aweight=popb], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
					
					local lbl: variable  label `var'
					local lbl2: variable  label unemp_rate
					local lbl3: variable  label median_income

				
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  `var'_spec_7  using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
				keep(numb_emp median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
				replace se order(numb_emp median_income) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
				f nomtitles substitute(\_ _) ///
				refcat(numb_emp "\midrule \emph{`lbl'}", nolabel)	///
				coef(numb_emp "\hspace{0.5cm}`lbl2'" ///
				median_income "\hspace{0.5cm}`lbl3'") noline
				
				capture est clear
			}
		

			local drug_list aopioidbr aheroinbr
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' numb_emp [aweight=popb], absorb(countycode year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
					
				qui reghdfe `var' numb_emp county_time_*  [aweight=popb], absorb(countycode year) vce(cluster countycode)  
				//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"

					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' numb_emp  [aweight=popb], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_3, nocopy
				
					
				qui reghdfe `var' numb_emp   median_income  [aweight=popb], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
					
					local lbl: variable  label `var'
					local lbl2: variable  label numb_emp
					local lbl3: variable  label median_income

				
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  `var'_spec_7  using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
				keep(numb_emp median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
				append se order(numb_emp median_income) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
				f nomtitles substitute(\_ _) ///
				refcat(numb_emp "\midrule \emph{`lbl'}", nolabel)	///
				coef(numb_emp "\hspace{0.5cm}`lbl2'" ///
				median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
				
				capture est clear

			}
		}



		


	
		if hisp==1 {
			local drug_list drughr //aopioidr aheroinr
		
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' numb_emp [aweight=poph], absorb(countycode year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
					
				qui reghdfe `var' numb_emp county_time_*  [aweight=poph], absorb(countycode year) vce(cluster countycode)  
				//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"

					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' numb_emp  [aweight=poph], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_3, nocopy
				
					
				qui reghdfe `var' numb_emp   median_income  [aweight=poph], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
					
					local lbl: variable  label `var'
					local lbl2: variable  label numb_emp
					local lbl3: variable  label median_income

				
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  `var'_spec_7  using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
				keep(numb_emp median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
				replace se order(numb_emp median_income) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
				f nomtitles substitute(\_ _) ///
				refcat(numb_emp "\midrule \emph{`lbl'}", nolabel)	///
				coef(numb_emp "\hspace{0.5cm}`lbl2'" ///
				median_income "\hspace{0.5cm}`lbl3'") noline
				
				capture est clear
			}
		

			local drug_list aopioidhr aheroinhr
			foreach var in `drug_list' {
			// Specification Choice Table
				qui reghdfe `var' numb_emp [aweight=poph], absorb(countycode year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "No"

					estimates store `var'_spec_1, nocopy
					
				qui reghdfe `var' numb_emp county_time_*  [aweight=poph], absorb(countycode year) vce(cluster countycode)  
				//county_time_*
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "Yes"
					estadd local state_by_year "No"

					estimates store `var'_spec_2, nocopy
					
				qui reghdfe `var' numb_emp  [aweight=poph], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_3, nocopy
				
					
				qui reghdfe `var' numb_emp   median_income  [aweight=poph], absorb(countycode state_year year) vce(cluster countycode)  
				
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"
					estadd local county_trend "No"
					estadd local state_by_year "Yes"

					estimates store `var'_spec_7, nocopy	
					
					local lbl: variable  label `var'
					local lbl2: variable  label numb_emp
					local lbl3: variable  label median_income

				
				esttab `var'_spec_1 `var'_spec_2 `var'_spec_3  `var'_spec_7  using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
				keep(numb_emp median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
				append se order(numb_emp median_income) ///
				booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
				stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
				label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
				f nomtitles substitute(\_ _) ///
				refcat(numb_emp "\midrule \emph{`lbl'}", nolabel)	///
				coef(numb_emp "\hspace{0.5cm}`lbl2'" ///
				median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
				
				capture est clear

			}
		}


*/
		
/*
use  "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", clear
	
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
// State x Year FE
	egen state_year = group( StateFIPS year)
	qui tab state_year, gen(st_year_fe_)	
	
// Generate Recession Binary and Recession or After Binary
	*https://fred.stlouisfed.org/series/USREC
	gen recession_year = 0
	replace recession_year=1 if year==2008 | year ==2009
	
	gen post_recession = 0
	replace post_recession = 1 if year>2009
	
	gen emp_ratio = numb_emp/pop_15_64
	label variable emp_ratio "Employment-to-Population ratio"
	
// Label Certain Variables
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [0-100]"
	replace median_income = median_income/1000
	label variable median_income "Median Income, \\\$1000s"
	label variable percent_non_white "\% Non-White, [0-1]"
	
			 label var r_op_ovr_total "Opioid Overdose ED Visit Rate per 100k"
			 label var r_op_dep_total "Opioid Dependence ED Visit Rate per 100k"
				 
			 label var r_op_ovr__r_w "White Opioid Overdose ED Visit Rate per 100k"
			 label var r_op_dep__r_w "White Opioid Dependence ED Visit Rate per 100k"
			 
			 label var r_op_ovr__r_b "Black Opioid Overdose ED Visit Rate per 100k"
			 label var r_op_dep__r_b "Black Opioid Dependence ED Visit Rate per 100k"
			 
			 label var r_op_ovr__r_h "Hispanic Opioid Overdose ED Visit Rate per 100k"
			 label var r_op_dep__r_h "Hispanic Opioid Dependence ED Visit Rate per 100k"
				 
					
		 label var r_drug_ovr_total "Drug Overdose ED Visit Rate per 100k"
		 label var r_drug_ovr__r_w "White Drug Overdose ED Visit Rate per 100k"
		 label var r_drug_ovr__r_b "Black Drug Overdose ED Visit Rate per 100k"
		 label var r_drug_ovr__r_h "Hispanic Drug Overdose ED Visit Rate per 100k"

		label var r_her_ovr_total "Heroin Overdose ED Visit Rate per 100k"
		label var r_her_ovr__r_w "White Heroin Overdose ED Visit Rate per 100k"
		label var r_her_ovr__r_b "Black Heroin Overdose ED Visit Rate per 100k"
		label var r_her_ovr__r_h "Hispanic Heroin Overdose ED Visit Rate per 100k"

		
	if all==1 {
		
		local y_list r_drug_ovr_total   r_op_ovr_total

			foreach y in `y_list' {			
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_total], absorb(fips year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1
					*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio county_time_* [aweight=pop_total], absorb(fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_3			
					
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio median_income [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label `y'
			local lbl2: variable  label emp_ratio
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
		keep(emp_ratio median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(emp_ratio median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
		f nomtitles substitute(\_ _) ///
		refcat(emp_ratio "\midrule \emph{`lbl'}", nolabel)	///
		coef(emp_ratio "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		
		
		
		
		local y_list r_her_ovr_total 

		foreach y in `y_list' {
	
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_total], absorb(fips year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1
					*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio county_time_* [aweight=pop_total], absorb(fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_3			
					
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y'  emp_ratio [aweight=pop_total], absorb(fips state_year year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label `y'
			local lbl2: variable  label emp_ratio
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using "$results_path/appendix/tables/ratio_race'_county_combined_robust_se.tex" , ///
		keep(emp_ratio median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(emp_ratio median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(N r2_a state_fe year_dum  county_trend state_year_fe, fmt(0 %3.2f 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
		f nomtitles substitute(\_ _) ///
		refcat(emp_ratio "\midrule \emph{`lbl'}", nolabel)	///
		coef(emp_ratio "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		

			
	}		

	if white==1 {
		
		
			local y_list r_drug_ovr__r_w   r_op_ovr__r_w
			
			foreach y in `y_list' {			
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_white], absorb(fips year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1
					*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio county_time_* [aweight=pop_white], absorb(fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_3			
					
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio median_income [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label `y'
			local lbl2: variable  label emp_ratio
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
		keep(emp_ratio median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(emp_ratio median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
		f nomtitles substitute(\_ _) ///
		refcat(emp_ratio "\midrule \emph{`lbl'}", nolabel)	///
		coef(emp_ratio "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		
		
		
			
			
			local y_list r_her_ovr__r_w
			
			foreach y in `y_list' {		
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_white], absorb(fips year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1
					*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio county_time_* [aweight=pop_white], absorb(fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_3			
					
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio median_income [aweight=pop_white], absorb(fips state_year year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label  `y'
			local lbl2: variable  label emp_ratio
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
		keep(emp_ratio median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(emp_ratio median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(N r2_a state_fe year_dum  county_trend state_year_fe, fmt(0 %3.2f 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
		f nomtitles substitute(\_ _) ///
		refcat(emp_ratio "\midrule \emph{`lbl'}", nolabel)	///
		coef(emp_ratio "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		

			
	}	
	

	if black==1 {
		

			local y_list r_drug_ovr__r_b   r_op_ovr__r_b
			
			foreach y in `y_list' {				
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_black], absorb(fips year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1
					*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio county_time_* [aweight=pop_black], absorb(fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_3			
					
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio median_income [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label  `y'
			local lbl2: variable  label emp_ratio
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
		keep(emp_ratio median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(emp_ratio median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
		f nomtitles substitute(\_ _) ///
		refcat(emp_ratio "\midrule \emph{`lbl'}", nolabel)	///
		coef(emp_ratio "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		
		
		
			*/
	/*		
			local y_list   r_her_ovr__r_b
			
			foreach y in `y_list' {				
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_black], absorb(fips year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1
					*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio county_time_* [aweight=pop_black], absorb(fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_3			
					
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio median_income [aweight=pop_black], absorb(fips state_year year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label  `y'
			local lbl2: variable  label emp_ratio
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
		keep(emp_ratio median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(emp_ratio median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(N r2_a state_fe year_dum  county_trend state_year_fe, fmt(0 %3.2f 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
		f nomtitles substitute(\_ _) ///
		refcat(emp_ratio "\midrule \emph{`lbl'}", nolabel)	///
		coef(emp_ratio "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		

			
	}	
	

	if hisp==1 {
		
			
			local y_list r_drug_ovr__r_h   r_op_ovr__r_h
			
			foreach y in `y_list' {					
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_hisp], absorb(fips year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1
					*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio county_time_* [aweight=pop_hisp], absorb(fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_3			
					
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio median_income [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label  `y'
			local lbl2: variable  label emp_ratio
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
		keep(emp_ratio median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(emp_ratio median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(N r2_a, fmt(0  %3.2f) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$")) ///
		f nomtitles substitute(\_ _) ///
		refcat(emp_ratio "\midrule \emph{`lbl'}", nolabel)	///
		coef(emp_ratio "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		
		
		
			*/
			
/*			local y_list r_her_ovr__r_h
			
			foreach y in `y_list' {				
			
				// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_hisp], absorb(fips year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "No"					
					estimates store `y'_1
					*county_time_* 
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio county_time_* [aweight=pop_hisp], absorb(fips year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
						estadd local county_trend "Yes"
					estadd local state_year_fe "No"		
					estimates store `y'_2			
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio   [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)  
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"			
							estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_3			
					
					
					// FE- Unemployement - Population Weighted- Robust SE - Add Control Variable to Year FE 
					qui reghdfe `y' emp_ratio median_income [aweight=pop_hisp], absorb(fips state_year year) vce(cluster fips)   
					*estadd scalar  p_stat   = (2 * ttail(e(df_r), abs(_b[unemp_rate]/_se[unemp_rate])))
					estadd local year_dum "Yes"
					estadd local state_fe "Yes"	
					estadd local county_trend "No"
					estadd local state_year_fe "Yes"		
					estimates store `y'_7			
						
			local lbl: variable  label  `y'
			local lbl2: variable  label emp_ratio
			local lbl3: variable  label median_income

		
		esttab `y'_1 `y'_2 `y'_3 `y'_7   using "$results_path/appendix/tables/ratio_`race'_county_combined_robust_se.tex" , ///
		keep(emp_ratio median_income)  label star(* 0.10 ** 0.05 *** 0.01) ///
		append se order(emp_ratio median_income) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats(N r2_a state_fe year_dum  county_trend state_year_fe, fmt(0 %3.2f 0 0 0 0 ) ///
		layout( "\multicolumn{1}{c}{@}"    "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label("\hspace{0.5cm}Observations" "\hspace{0.5cm}Adj. \$R^2\$" "\hline County Fixed-Effects" "Year Fixed-Effects"  "County Specific Time Trends"   "State-by-Year Fixed-Effects")) ///
		f nomtitles substitute(\_ _) ///
		refcat(emp_ratio "\midrule \emph{`lbl'}", nolabel)	///
		coef(emp_ratio "\hspace{0.5cm}`lbl2'" ///
		median_income "\hspace{0.5cm}`lbl3'") noline  collabels(none) nonumbers 
		
		capture est clear	
		}
		
		
		

			
	}	
*----------
end
*----------

r_specification_table_by_race, race(all)
r_specification_table_by_race, race(white)
r_specification_table_by_race, race(black)
r_specification_table_by_race, race(hisp)
