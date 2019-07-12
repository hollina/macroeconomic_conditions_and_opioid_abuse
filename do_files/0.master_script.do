/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// HOLLINGSWORTH, RUHM, and SIMON (hollinal@indiana.edu, cjr6e@virginia.edu,  
//								   and simonkos@indiana.edu)

// MACROECONOMIC CONDITIONS AND OPIOID ABUSE
// DOI: http://dx.doi.org/10.1016/j.jhealeco.2017.07.009 

// VERSION: 
// SEPTEMBER 2017

// FILE:
// master_script.do

// DESCRIPTION:
// THIS FILE RUNS ALL DO FILES NECESSARY TO REPLICATE RESULTS REPORTED IN PAPER/APPENDIX

// NOTE:
// RESTRICTED ACCESS MORTALITY AND ED DATA ARE NOT INCLUDED IN THESE FILES
// SEE READ ME FOR INSTRUCTIONS ON HOW TO OBTAIN THESE DATA

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// Version of stata
version 14.2

// Close any open log files
capture log close

// Clear Memory
clear all

// Allow the screen to move without having to click more
set more off

// Drop everything in mata
matrix drop _all

// Set your file paths.
global box "/Users/hollinal/Box"

global root_path "$box/opioid_project/cleaned_version" // Root folder directory that contains the subfolders for constructing the dataset and estimation
global restricted_data_path "/Volumes/secure_key/" // Root folder directory that contains the restricted access data

global data_path "$root_path/data_for_analysis" // Path for data used in analysis
global raw_data_path "$root_path/raw_data" // Path for raw data
global raw_data_res_mort_path "$restricted_data_path/mortality" // Path for restricted access mortality data
global raw_data_res_ed_path "$restricted_data_path/sedd" // Path for restricted access ED data
global temp_path "$root_path/temp" // Path for temp folder

global script_path "$root_path/do_files" // Path for running the scripts to create tables and figures
global results_path "$root_path/results" // Path for tables/figures output
global log_path "$root_path/logs" // Path for logs


// Custom Install Location for Stata Packages. Useful if working on a server where you have limited write permissions.
local custom_stata_package_location 0

if `custom_stata_package_location' {
	// Set a specific folder for storing custom stata programs, useful for server
	*Note: Be sure to create a folder named stata at destination to keep it organized
	global file_path_for_stata "$temp_path" 
	
	// Set Personal Path
	net set ado "$file_path_for_stata"

	// Add Path to a directory that stata looks at for packages
	adopath + "$file_path_for_stata"
}
else  {
	di "Using Default Locations to Install Any Packages"
}


// Install Stata Packages
local install_stata_packages 0

// Install Packages if needed, if not, make a note of this. 
*This should be a comprehensive list of all additional packages needed to run the code.
if `install_stata_packages' {
	ssc install carryforward
	ssc install isvar
	
	ssc install reghdfe
	ssc install estout
	ssc install graphlog
	ssc install blindschemes
	ssc install geonear
	ssc install ftools
	
	local github "https://raw.githubusercontent.com"
	net install gtools, from(`github'/mcaceresb/stata-gtools/master/build/)
}
else  {
	di "All packages up-to-date"
}


// Set Date
global date = subinstr("$S_DATE", " ", "-", .)

// Specify Screen Width for log files
set linesize 255

// Set font type
graph set window fontface "Times New Roman" 

// Set Graph Scheme
set scheme plotplainblind

// Set Project Details using local mactos
local project opioids_and_unemployment
global pgm master_script

local task "This file replicates Hollingsworth, Ruhm, and Simon (2017) JHE Paper"
local tag "$pgm.do $date"

// Start Log
log using "$log_path/$pgm", replace text
di "The file is: `tag'"
di "Task: `task'"
di "Project: `project'"

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Build datasets for analysis

///////////////////////////////////////////////////////////////////////////////
// Create a county-by-year population-by-race
do "$script_path/1.build_datasets_for_analysis/1.1.create_county_by_year_population.do"

///////////////////////////////////////////////////////////////////////////////
// Create a county-by-year unemployment rate
do "$script_path/1.build_datasets_for_analysis/1.2.create_county_unemployment.do"

///////////////////////////////////////////////////////////////////////////////
// Create a county-by-year median income and poverty rate
do "$script_path/1.build_datasets_for_analysis/1.3.create_saipe_median_inc_poverty.do"

///////////////////////////////////////////////////////////////////////////////
// Create a state-by-year median income 
do "$script_path/1.build_datasets_for_analysis/1.4.create_state_median_income.do"

///////////////////////////////////////////////////////////////////////////////
// Create measure of county % high school graduates in 2000 
do "$script_path/1.build_datasets_for_analysis/1.6.create_high_school_graduates_2000.do"

///////////////////////////////////////////////////////////////////////////////
// Create import exposure measure by county
do "$script_path/1.build_datasets_for_analysis/1.7.create_import_exposure.do"

///////////////////////////////////////////////////////////////////////////////
// Create variable reporting county land area in 2000
do "$script_path/1.build_datasets_for_analysis/1.8.create_land_area_in_2000.do"

///////////////////////////////////////////////////////////////////////////////
// Build county-year-level drug death estimates from raw mortality data
do "$script_path/1.build_datasets_for_analysis/1.9.create_county_year_mortality_from_raw_mortality_files.do"

///////////////////////////////////////////////////////////////////////////////
// Create drug overdose ED visits with county level information from HCUP SEDD microdata
do "$script_path/1.build_datasets_for_analysis/1.10.create_ed_visits_with_county_id_by_year.do"

///////////////////////////////////////////////////////////////////////////////
// Create drug overdose ED visits at state-year level from HCUPNet data
do "$script_path/1.build_datasets_for_analysis/1.11.create_state_drug_ed_visit.do"

///////////////////////////////////////////////////////////////////////////////
// Create state level unemployment data
do "$script_path/1.build_datasets_for_analysis/1.12.create_state_unemployment_data.do"

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Make all figures

///////////////////////////////////////////////////////////////////////////////
// Make Figures 1 and 2 (And A9)
	do  "$script_path/2.analysis/2.1.figures_1_and_2_and_a9.do"

///////////////////////////////////////////////////////////////////////////////
// Make Figure 3 and 4
	do  "$script_path/2.analysis/2.2.figure_3_and_4.do"
	
///////////////////////////////////////////////////////////////////////////////
// Make Figures A1 - A8
	do  "$script_path/2.analysis/2.3_figures_a1_to_18.do"

///////////////////////////////////////////////////////////////////////////////
// Make Figure A10
	do  "$script_path/2.analysis/2.4_figure_a10.do" 
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Make all tables

///////////////////////////////////////////////////////////////////////////////
// Table 1
* SEE TEX DOCUMENT

///////////////////////////////////////////////////////////////////////////////
// Table 2: County level summary statistics
	do  "$script_path/2.analysis/2.5_table_2.do" 

///////////////////////////////////////////////////////////////////////////////
// Table 3: County level estimates (and A7-A9)
	do  "$script_path/2.analysis/2.6_table_3_and_a7_to_a9.do" 

///////////////////////////////////////////////////////////////////////////////
// Table 4: County level estimates by race for preferred model
	do  "$script_path/2.analysis/2.7_table_4.do" 
	
///////////////////////////////////////////////////////////////////////////////
// Table 5: State level estimates (and A4)
	do  "$script_path/2.analysis/2.8_table_5_and_a4.do"

///////////////////////////////////////////////////////////////////////////////
// Table A1: Other time trends
	do "$script_path/2.analysis/2.9_table_a1.do"
	
///////////////////////////////////////////////////////////////////////////////
// Table A2: Other summary statitics
	do "$script_path/2.analysis/2.10_table_a2.do"

///////////////////////////////////////////////////////////////////////////////
// Table A3: Add median income to perferred model
	do "$script_path/2.analysis/2.11_table_a3.do"  
	*NOTE: Need to manually remove Meidan Income etc still)

///////////////////////////////////////////////////////////////////////////////
// Table A5: Non-Heroin ED Visits
	do "$script_path/2.analysis/2.12_table_a5.do"  

///////////////////////////////////////////////////////////////////////////////
// Table A6: Heroin Death Rates
	do "$script_path/2.analysis/2.13_table_a6.do"  
	
///////////////////////////////////////////////////////////////////////////////
// Table A10: Boom v Bust
	do "$script_path/2.analysis/2.14_table_a10.do"  

///////////////////////////////////////////////////////////////////////////////
// Table A11: Accounting for uncertainty in imputation procedure
	do "$script_path/2.analysis/2.15_table_a11.do"  

///////////////////////////////////////////////////////////////////////////////
// Table A12: ED Estimates for other drugs
	do "$script_path/2.analysis/2.16_table_a12.do"  
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Close log
log close
