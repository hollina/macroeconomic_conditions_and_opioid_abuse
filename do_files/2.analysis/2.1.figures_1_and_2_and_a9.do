// Clear memory
clear all

// Open restricted access mortality data
use "$raw_data_res_mort_path/drug_mortality_county_year.dta", clear

// Split his county fips code to match our way of reporting it
	gen str5 z=string(county,"%05.0f")
	gen StateFIPS = substr(z,1,2)
	gen CountyFIPS = substr(z,3,3)
	destring StateFIPS, replace
	destring CountyFIPS, replace
	drop z

// Merge in Controls

	// Unemployment
	merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
	keep if _merge==3 
	drop _merge
	
	// Median income
	merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
	keep if _merge==3  
	drop _merge
	
	// Population
	merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"
	keep if _merge==3
	drop _merge
	
// Add labels to variables
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
	
	label variable year "Year"

// Inflate up by population before collapse
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
	
// Convert unemploymnet rate to be between 0 and 100
	replace unemp_rate = unemp_rate*100
	label variable unemp_rate "Unemployment Rate, [1-100]"
	
// Collpase data to year level
	collapse (sum) drug* aopioid* aheroin* pop* (mean) unemp_rate, by(year)
	
// Turn back into a rate by deflating by population	
	replace drugr  = drugr/pop
	replace aopioidr=aopioidr/pop
	replace aheroinr=aheroinr/pop
	
	replace drugwr  = drugwr/popw
	replace aopioidwr=aopioidwr/popw
	replace aheroinwr=aheroinwr/popw
	
	replace drugbr  = drugbr/popb
	replace aopioidbr=aopioidbr/popb
	replace aheroinbr=aheroinbr/popb
		
	replace drughr  = drughr/poph
	replace aopioidhr=aopioidhr/poph
	replace aheroinhr=aheroinhr/poph
	
// Add back in labels
	label variable drugr "Drug Death Rate per 100k"
	label variable aopioidr "Opioid Death Rate per 100k"
	label variable aheroinr "Heroin Death Rate per 100k"
	
	label variable unemp_rate "Unemployment Rate, [1-100]"
	
///////////////////////////////////////////////////////////////////////////////
// Create Figure 1	

// Create labels for the graphs
	gen label_total = ""
	replace label_total = "Total" if year ==2014

	gen label_white =""
	replace label_white =  "White" if year ==2014
	
	gen label_black =""
	replace label_black =  "Black" if year ==2014
	
	gen label_hisp =""
	replace label_hisp =  "Hispanic" if year ==2014
		
	gen label_drug =""
	replace label_drug =  "All Drugs" if year ==2014
			
	gen label_opioid =""
	replace label_opioid =  "Opioids" if year ==2014
			
	gen label_heroin =""
	replace label_heroin =  "Heroin" if year ==2014
	
	gen label_unemp =""
	replace label_unemp =  "Unemployment Rate" if year ==2014

// Plot
	twoway (connected drugr year, lpattern("_") color(sea) msymbol(none) mlabel(label_drug) mlabcolor(sea)) ///
		   (connected aopioidr year, color(turquoise) mlabcolor(turquoise) msymbol(none) mlabel(label_opioid)) ///
		   (connected unemp_rate year, color(black) msymbol(none) mlabel(label_unemp)), ///
		   xlabel(1999(1)2014, nogrid) ///
		   xscale(range(1999 2014)) ///
		   ylabel(,gmax) ///
		   legend(off) ///
			graphregion(margin(r+22)) ///
			ylabel(, noticks) ///
			subtitle("Unemployment Rate, [0-100]; Death Rates are Deaths per 100k", position(11) size(3)) 
// Save			
	graph export "$results_path/figures/figure_1_death_rates_over_time.pdf", replace

///////////////////////////////////////////////////////////////////////////////
// Create Figure 2

// Update labels	
	label variable drugr "Total"
	label variable aopioidr "Total"
	label variable aheroinr "Total"
	
	label variable drugwr "White"
	label variable aopioidwr "White"
	label variable aheroinwr "White"
		
	label variable drugbr "Black"
	label variable aopioidbr "Black"
	label variable aheroinbr "Black"
		
	label variable drughr "Hispanic"
	label variable aopioidhr "Hispanic"
	label variable aheroinhr "Hispanic"
	
	// Plot
	twoway (connected aopioidr year, lpattern("_") color(black) msymbol(none) mlabel(label_total) mlabcolor(black)) ///
		   (connected aopioidwr year, color(turquoise) mlabcolor(turquoise) msymbol(none) mlabel(label_white)) ///
		   (connected aopioidbr year, color(vermillion) mlabcolor(vermillion)   msymbol(none) mlabel(label_black)) ///
		   (connected aopioidhr year, color(sea) msymbol(none) mlabcolor(sea) mlabel(label_hisp)), ///
		   xlabel(1999(1)2014, nogrid) ///
		   xscale(range(1999 2014)) ///
		   ylabel(,gmax) ///
		   legend(off) ///
			graphregion(margin(r+7)) ///
			ylabel(, noticks) ///
			subtitle("Death Rates are Deaths per 100k in Group", position(11) size(3)) 		
// Save		 
	graph export "$results_path/figures/figure_2_opioid_deaths_by_race_over_time.pdf", replace
	
///////////////////////////////////////////////////////////////////////////////
// Create Figure A9

// Plot
	twoway (connected drugr year, lpattern("_") color(black) msymbol(none) mlabel(label_total) mlabcolor(black)) ///
		   (connected drugwr year, color(turquoise) mlabcolor(turquoise) msymbol(none) mlabel(label_white)) ///
		   (connected drugbr year, color(vermillion) mlabcolor(vermillion)   msymbol(none) mlabel(label_black)) ///
		   (connected drughr year, color(sea)  mlabcolor(sea) msymbol(none) mlabel(label_hisp)), ///
		   xlabel(1999(1)2014, nogrid) ///
		   xscale(range(1999 2014)) ///
		   ylabel(,gmax) ///
		   legend(off) ///
			graphregion(margin(r+7)) ///
			ylabel(, noticks) ///
			subtitle("Death Rates are Deaths per 100k in Group", position(11) size(3)) 
			*title("Total Drug Death Rate by Race, 1999-2014", position(11))

// Save		 
	graph export "$results_path/appendix/figures/figure_A9_drug_deaths_by_race_over_time.pdf", replace
