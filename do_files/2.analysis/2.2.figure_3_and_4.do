// Clear memory
clear all

// Import NEDS data from HCUP 
import excel "$raw_data_path/neds_2006_2013.xlsx", sheet("Sheet2") firstrow clear

// Create an other
gen ed_other_any = ed_drug_any - ed_benzo_any - ed_opioid_any - ed_aro_analgesics_any - ed_anti_dep_any - ed_insulin_any - ed_coke_any - ed_psyc_any - ed_her_any

// Combine
gen ed_combined_any = -( - ed_benzo_any - ed_opioid_any - ed_aro_analgesics_any - ed_anti_dep_any - ed_insulin_any - ed_coke_any - ed_psyc_any - ed_her_any)

// Turn into rates per 100k
ds year pop, not
foreach x in `r(varlist)' {
	replace `x' = (`x'/pop)*100000
}

///////////////////////////////////////////////////////////////////////////////
// Create Figure 4


// Add labels in the last year
gen label_drug = ""
replace label_drug ="All Drugs" if year==2014

gen label_combined = ""
replace label_combined ="Top Drugs Combined" if year==2014


gen label_benzo = ""
replace label_benzo ="Benzos" if year==2014

gen label_opioids = ""
replace label_opioids ="Opioids" if year==2014

gen label_aro = ""
replace label_aro ="Aromatic Analgesics" if year==2014

gen label_her = ""
replace label_her ="Heroin" if year==2014

gen label_anti_dep = ""
replace label_anti_dep ="Anti-depressants" if year==2014

gen label_psyc = ""
replace label_psyc ="Anti-psychotics" if year==2014

gen label_insulin = ""
replace label_insulin ="Insulin" if year==2014

gen label_coke = ""
replace label_coke ="Cocaine" if year==2014

gen label_other = ""
replace label_other ="Other Drugs" if year==2014


// Plot top ten ED drug rates
twoway  ///
		(connected ed_benzo_any year, mlabel(label_benzo) ) ///
		(connected ed_opioid_any year, mlabel(label_opioids)) ///
		(connected ed_aro_analgesics_any year, mlabel(label_aro)) ///
		(connected ed_anti_dep_any year, mlabel(label_anti_dep)) ///
		(connected ed_insulin_any year, mlabel(label_insulin) mlabpos(3)) ///
		(connected ed_coke_any year, mlabel(label_coke) ) ///
		(connected ed_psyc_any year, mlabel(label_psyc)mlabpos(2)) ///
		(connected ed_her_any year, mlabel(label_her)) ///
		, legend(off) graphregion(margin(r+7)) ///
		xlabel(2006(1)2014, nogrid noticks) ///
				xtitle("Year", size(4))  ///
				ytitle("") ///
				graphregion(margin(r+15)) ///
				ylabel(0(10)30, noticks ) ///
				subtitle("ED Visit Rates are Visits per 100k", position(11) size(3)) ///
				
			   	graph export "$results_path/figures/figure_4_top_drug_ed_rate_06_14.pdf", replace 

///////////////////////////////////////////////////////////////////////////////
// Create Figure 3

// Update labels
gen label_opioids_2 = ""
gen label_drug_2 = ""
				
replace label_opioids ="Opioids" if year==2014
replace label_drug ="All Drugs" if year==2014
	
replace label_opioids_2 ="(Right Axis)" if year==2014
replace label_drug_2 ="(Left Axis)" if year==2014

// Plot ED All Drugs and opioids by year
twoway  (connected ed_drug_any year, msymbol(none) color(turquoise) mlabcolor(turquoise) mlabel(label_drug) yaxis(1) mlabpos(2) ) ///
		(connected ed_opioid_any year, msymbol(none) color(sea) mlabcolor(sea) lpattern("--") mlabel(label_opioids) yaxis(2) mlabpos(2)) ///
		(connected ed_drug_any year, msymbol(none) color(turquoise) mlabcolor(turquoise) mlabel(label_drug_2) yaxis(1) mlabpos(4) mlabsize(3)) ///
		(connected ed_opioid_any year, msymbol(none) color(sea) mlabcolor(sea) lpattern("--") mlabel(label_opioids_2) yaxis(2) mlabpos(4) mlabsize(3)) ///		
		, legend(off)  ///
		xlabel(2006(1)2014, nogrid noticks) ///
			xscale(r(2006 2015)) ///
				xtitle("Year", size(4))  ///
				ytitle("", axis(1)) ///
				ytitle("", axis(2)) ///
				graphregion(margin(r+1)) ///
				ylabel(, noticks axis(1)) ///
				ylabel(, noticks axis(2)) ///
				subtitle("ED Visit Rates are Visits per 100k", position(11) size(3))
			   	graph export "$results_path/figures/figure_3_drug_op_ed_rate_06_14.pdf", replace 
		
		
