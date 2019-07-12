*Source of data: http://seer.cancer.gov/popdata/download.html

// Clear memory
clear all

// Import SEER population data
infix year 1-4 str state 5-6 StateFIPS 7-8 CountyFIPS 9-11 registry 12-13 race 14 origin 15 sex 16 age 17-18 population 19-27 using "$raw_data_path/seer_pop_data/us.1990_2014.19ages.adjusted.txt"

// Add labels
label define sex 1 "Male" 2 "Female" 
label values sex sex
label variable sex "Gender"

label define race 1 "White" 2 "Black" 3 "American Indian/Alaska Native" 4 "Asian or Pacific Islander" 
label values race race
label variable race "Race"

label define origin 0 "Non-Hispanic" 1 "Hispanic" 9 "NA" 
label values origin origin
label variable origin "Origin"

drop registry

// Generate total population by race
bysort StateFIPS CountyFIPS year: egen pop =  total(population)
bysort StateFIPS CountyFIPS year: egen popw = total(population) if race==1 & origin==0
bysort StateFIPS CountyFIPS year: egen popb = total(population) if race==2  & origin==0
bysort StateFIPS CountyFIPS year: egen poph = total(population) if origin==1 



bysort StateFIPS CountyFIPS year: egen pop_15_54 = total(population) if age>3 & age <12
bysort StateFIPS CountyFIPS year: egen pop_25_54 = total(population) if age>5 & age <12
bysort StateFIPS CountyFIPS year: egen pop_25_64 = total(population) if age>5 & age <14
bysort StateFIPS CountyFIPS year: egen pop_15_64 = total(population) if age>3 & age <14
bysort StateFIPS CountyFIPS year: egen pop_15_up = total(population) if age>3

bysort StateFIPS CountyFIPS year: egen popw_15_54 = total(popw) if age>3 & age <12
bysort StateFIPS CountyFIPS year: egen popw_25_54 = total(popw) if age>5 & age <12
bysort StateFIPS CountyFIPS year: egen popw_25_64 = total(popw) if age>5 & age <14
bysort StateFIPS CountyFIPS year: egen popw_15_64 = total(popw) if age>3 & age <14
bysort StateFIPS CountyFIPS year: egen popw_15_up = total(popw) if age>3

bysort StateFIPS CountyFIPS year: egen popb_15_54 = total(popb) if age>3 & age <12
bysort StateFIPS CountyFIPS year: egen popb_25_54 = total(popb) if age>5 & age <12
bysort StateFIPS CountyFIPS year: egen popb_25_64 = total(popb) if age>5 & age <14
bysort StateFIPS CountyFIPS year: egen popb_15_64 = total(popb) if age>3 & age <14
bysort StateFIPS CountyFIPS year: egen popb_15_up = total(popb) if age>3


bysort StateFIPS CountyFIPS year: egen poph_15_54 = total(poph) if age>3 & age <12
bysort StateFIPS CountyFIPS year: egen poph_25_54 = total(poph) if age>5 & age <12
bysort StateFIPS CountyFIPS year: egen poph_25_64 = total(poph) if age>5 & age <14
bysort StateFIPS CountyFIPS year: egen poph_15_64 = total(poph) if age>3 & age <14
bysort StateFIPS CountyFIPS year: egen poph_15_up = total(poph) if age>3


// Make sure that every variable is filled in 
ds pop*
local var_list `r(varlist)'
foreach x in `var_list'{
	bysort StateFIPS CountyFIPS year: 	carryforward `x', replace
}

replace year = -year

sort  StateFIPS CountyFIPS year
foreach x in `var_list'{
	bysort StateFIPS CountyFIPS year: 	carryforward `x', replace
}

replace year=-year

// Keep only the first observation
bysort StateFIPS CountyFIPS year: gen order =_n
keep if order==1
drop order 

// Create a combined fips code to match up with Chris' mortality data 
gen county=StateFIPS*1000+CountyFIPS  
keep if year>1998
keep StateFIPS CountyFIPS county year pop popb poph popw *_15_54 *_25_54 *_25_64 *_15_64 *_15_up

// Compress and save
compress
save "$data_path/county_pop_age_race_1990_2014.dta", replace

