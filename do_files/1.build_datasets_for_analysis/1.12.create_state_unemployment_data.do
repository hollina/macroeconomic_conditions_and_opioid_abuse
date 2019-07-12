// Clear memory
clear all

// Import state unemployment rate data
import delimited "$raw_data_path/la.data.2.AllStatesU.txt", encoding(ISO-8859-1) clear

// Keep only annual average
keep if period=="M13"

// Create state fips code
gen StateFIPS = substr(series_id,6,2)  
destring StateFIPS, replace

// Keep only the unemployment data
gen data_type = substr(series_id,20,1) 
keep if data_type=="3"
rename value unemployment_rate

// Keep only what we need (0-100)
keep year unemployment_rate StateFIPS

// Save dataset
compress
save "$data_path/state_unemployment_rate.dta", replace
