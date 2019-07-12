clear all
// First. Bhargava ran a script that downloaded HCUP Net files for ICD-9's of interest. 
// These files can also be downloaded by clicking through HCUPNet's archival system and downloading the files
// 
//Second. Run the code below to clean it up. This only needs to be done once. 
	*It will not work two times in a row since we are adding filename extensions
	*The computer doesn't know how to handle multiple filename extensions

local drug_list her op drug 
local state_list Arizona Florida Hawaii Illinois Iowa Kentucky Maryland Minnesota "North Carolina" Nebraska "New Hampshire" "South Carolina" Tennessee Utah Vermont
local year_list 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013

foreach drug in `drug_list'{
 foreach st in `state_list' {
	foreach yr in `year_list' {
		clear
		// Import File 
			capture import delimited "$raw_data_path/hcupnet/`drug'/State statistics - `yr' `st' - all-listed.txt", delimiter(tab) encoding(ISO-8859-1)
			
		// Generate Labels
			*Note. I do it this way for two reasons.
				*1. Not all variables are reported for each state-year. So the row position doesn't hold consistent meaning
				*2. Row variable labels have differential spacing. So I can't think of a clear deliminator to use that will chop the variables up how I want them
		if _N >0 {		
			*clear
			*capture import delimited "/Users/hollinal/Box Sync/opioid_project/raw_data/hcupnet/her/State statistics - 2011 Nebraska - all-listed.txt", delimiter(tab) encoding(ISO-8859-1)

			drop in 1
				
				gen var_type=""

				//All
					replace var_type="all" if substr(v1,1,10) =="All visits"
					replace v1 = subinstr(v1,"All visits","",.)	 if substr(v1,1,10) =="All visits"
				
				//Age
					replace var_type="age_under_1" 					 if substr(v1,1,12) =="Age group <1"
					replace v1 = subinstr(v1,"Age group <1","",.)	 if substr(v1,1,12) =="Age group <1"
					
					replace var_type="age_1_17"			  if substr(v1,1,4) =="1-17"
					replace v1 = subinstr(v1,"1-17","",.) if substr(v1,1,4) =="1-17"
					
					replace var_type="age_1_17"			  if substr(v1,1,14) =="Age group 1-17"
					replace v1 = subinstr(v1,"Age group 1-17","",.) if substr(v1,1,14) =="Age group 1-17"
					
					replace var_type="age_18_44" 		   if substr(v1,1,15) =="Age group 18-44"
					replace v1 = subinstr(v1,"Age group 18-44","",.)  if substr(v1,1,15) =="Age group 18-44"
					
					replace var_type="age_45_64" 		  if substr(v1,1,15) =="Age group 45-64"
					replace v1 = subinstr(v1,"Age group 45-64","",.) if substr(v1,1,15) =="Age group 45-64"

					replace var_type="age_18_44" 		   if substr(v1,1,5) =="18-44"
					replace v1 = subinstr(v1,"18-44","",.)  if substr(v1,1,5) =="18-44"

					replace var_type="age_45_64" 		  if substr(v1,1,5) =="45-64"
					replace v1 = subinstr(v1,"45-64","",.) if substr(v1,1,5) =="45-64"

					replace var_type="age_65_84"		  if substr(v1,1,5) =="65-84"
					replace v1 = subinstr(v1,"65-84","",.) if substr(v1,1,5) =="65-84"
					
					replace var_type="age_missing" 		  if substr(v1,1,7)=="Missing" & var_type[_n-1] == "age_65_84"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing" & var_type[_n-1] == "age_65_84"

					replace var_type="age_85_up" 		  if substr(v1,1,3)=="85+"
					replace v1 = subinstr(v1,"85+","",.) if substr(v1,1,3)=="85+"

					replace var_type="age_missing" 		  if substr(v1,1,7)=="Missing" & var_type[_n-1] == "age_85_up"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing" & var_type[_n-1] == "age_85_up"

				//Gender
					replace var_type="sex_male" 		  if substr(v1,1,8)=="Sex Male" 
					replace v1 = subinstr(v1,"Sex Male","",.)  if substr(v1,1,8)=="Sex Male" 
					
					replace var_type="sex_female" 		  if substr(v1,1,10)=="Sex Female" 
					replace v1 = subinstr(v1,"Sex Female","",.)  if substr(v1,1,10)=="Sex Female" 

					replace var_type="sex_female" 		  if substr(v1,1,6)=="Female" 
					replace v1 = subinstr(v1,"Female","",.)  if substr(v1,1,6)=="Female" 
					
					replace var_type="sex_missing" 		  if substr(v1,1,7)=="Missing" & var_type[_n-1] == "sex_female"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing" & var_type[_n-1] == "sex_female"
					
				//Expected Payer
					replace var_type="payer_medicare" 		  if substr(v1,1,14)=="Payer Medicare" 
					replace v1 = subinstr(v1,"Payer Medicare","",.)  if substr(v1,1,14)=="Payer Medicare" 

					replace var_type="payer_medicaid" 		  if substr(v1,1,8)=="Medicaid" 
					replace v1 = subinstr(v1,"Medicaid","",.)  if substr(v1,1,8)=="Medicaid" 		
					
					replace var_type="payer_medicaid" 		  if substr(v1,1,14)=="Payer Medicaid" 
					replace v1 = subinstr(v1,"Payer Medicaid","",.)  if substr(v1,1,14)=="Payer Medicaid" 					
					
					replace var_type="payer_private" 		  if substr(v1,1,23)=="Payer Private insurance" 
					replace v1 = subinstr(v1,"Payer Private insurance","",.)  if substr(v1,1,23)=="Payer Private insurance" 
					
					replace var_type="payer_private" 		  if substr(v1,1,17)=="Private insurance" 
					replace v1 = subinstr(v1,"Private insurance","",.)  if substr(v1,1,17)=="Private insurance" 
					
					replace var_type="payer_uninsured" 		  if substr(v1,1,9)=="Uninsured"
					replace v1 = subinstr(v1,"Uninsured","",.)  if substr(v1,1,9)=="Uninsured" 

					replace var_type="payer_other" 		  if substr(v1,1,5)=="Other"  & var_type[_n-1] == "payer_uninsured"
					replace v1 = subinstr(v1,"Other","",.)  if substr(v1,1,5)=="Other"   & var_type[_n-1] == "payer_uninsured"

					replace var_type="payer_missing" 		  if substr(v1,1,7)=="Missing"  & var_type[_n-1] == "payer_other"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"  & var_type[_n-1] == "payer_other"
					
					replace var_type="payer_missing" 		  if substr(v1,1,7)=="Missing"  & var_type[_n-1] == "payer_uninsured"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"  & var_type[_n-1] == "payer_uninsured"
				//Income
				
					replace var_type="zip_inc_low" 		  if substr(v1,1,29)=="Median income for zipcode Low" 
					replace v1 = subinstr(v1,"Median income for zipcode Low" ,"",.)   if substr(v1,1,29)=="Median income for zipcode Low" 

					replace var_type="zip_inc_not_low" 		  if substr(v1,1,7)=="Not low"
					replace v1 = subinstr(v1,"Not low","",.)  if substr(v1,1,7)=="Not low" 
			
					replace var_type="zip_inc_not_low" 		  if substr(v1,1,33)=="Median income for zipcode Not low"
					replace v1 = subinstr(v1,"Median income for zipcode Not low","",.)  if substr(v1,1,33)=="Median income for zipcode Not low" 

					replace var_type="zip_inc_missing" 		  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "zip_inc_not_low"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"    & var_type[_n-1] == "zip_inc_not_low"

				//Population Size
					replace var_type="res_metro" 		  if substr(v1,1,37)=="Patient residence Large central metro"
					replace v1 = subinstr(v1,"Patient residence Large central metro","",.)  if substr(v1,1,37)=="Patient residence Large central metro" 
					
					replace var_type="res_suburb" 		  if substr(v1,1,46)=="Patient residence Large fringe metro (suburbs)"
					replace v1 = subinstr(v1,"Patient residence Large fringe metro (suburbs)","",.)  if substr(v1,1,46)=="Patient residence Large fringe metro (suburbs)" 
					 
					replace var_type="res_suburb" 		  if substr(v1,1,28)=="Large fringe metro (suburbs)"
					replace v1 = subinstr(v1,"Large fringe metro (suburbs)","",.)  if substr(v1,1,28)=="Large fringe metro (suburbs)" 
					 
					replace var_type="res_medium" 		  if substr(v1,1,40)=="Patient residence Medium and small metro"
					replace v1 = subinstr(v1,"Patient residence Medium and small metro","",.)  if substr(v1,1,40)=="Patient residence Medium and small metro" 
					
					replace var_type="res_medium" 		  if substr(v1,1,22)=="Medium and small metro"
					replace v1 = subinstr(v1,"Medium and small metro","",.)  if substr(v1,1,22)=="Medium and small metro" 

					replace var_type="res_rural" 		  if substr(v1,1,32)=="Micropolitan and noncore (rural)"
					replace v1 = subinstr(v1,"Micropolitan and noncore (rural)","",.)  if substr(v1,1,32)=="Micropolitan and noncore (rural)" 

					replace var_type="res_missing" 		  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "res_rural"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "res_rural"
				
				//Race and/or Ethnicity
					replace var_type="race_white" 		  if substr(v1,1,20)=="Race/ethnicity White"
					replace v1 = subinstr(v1,"Race/ethnicity White","",.)  if substr(v1,1,20)=="Race/ethnicity White" 

					replace var_type="race_black" 		  if substr(v1,1,20)=="Race/ethnicity Black"
					replace v1 = subinstr(v1,"Race/ethnicity Black","",.)  if substr(v1,1,20)=="Race/ethnicity Black" 	
					
					replace var_type="race_nat_amer" 		  if substr(v1,1,30)=="Race/ethnicity Native American"
					replace v1 = subinstr(v1,"Race/ethnicity Native American","",.)  if substr(v1,1,30)=="Race/ethnicity Native American" 
					
					replace var_type="race_hispanic" 		  if substr(v1,1,23)=="Race/ethnicity Hispanic"
					replace v1 = subinstr(v1,"Race/ethnicity Hispanic","",.)  if substr(v1,1,23)=="Race/ethnicity Hispanic" 
					
					replace var_type="race_black" 		  if substr(v1,1,5)=="Black"
					replace v1 = subinstr(v1,"Black","",.)  if substr(v1,1,5)=="Black" 

					replace var_type="race_hispanic" 		  if substr(v1,1,8)=="Hispanic"
					replace v1 = subinstr(v1,"Hispanic","",.)  if substr(v1,1,8)=="Hispanic" 

					replace var_type="race_asian" 		  if substr(v1,1,22)=="Asian/Pacific Islander"
					replace v1 = subinstr(v1,"Asian/Pacific Islander","",.)  if substr(v1,1,22)=="Asian/Pacific Islander" 

					replace var_type="race_nat_amer" 		  if substr(v1,1,15)=="Native American"
					replace v1 = subinstr(v1,"Native American","",.)  if substr(v1,1,15)=="Native American" 

					replace var_type="race_other" 		  if substr(v1,1,5)=="Other"
					replace v1 = subinstr(v1,"Other","",.)  if substr(v1,1,5)=="Other" 

					replace var_type="race_missing" 		  if substr(v1,1,22)=="Race/ethnicity Missing"	
					replace v1 = subinstr(v1,"Race/ethnicity Missing","",.)  if substr(v1,1,22)=="Race/ethnicity Missing" 
					
					replace var_type="race_missing" 		  if substr(v1,1,7)=="Missing"	  & var_type[_n-1] == "race_other"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "race_other"
					
					replace var_type="race_missing" 		  if substr(v1,1,7)=="Missing"	  & var_type[_n-1] == "race_asian"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "race_asian"
							
					replace var_type="race_missing" 		  if substr(v1,1,7)=="Missing"	  & var_type[_n-1] == "race_black"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "race_black"
					
					replace var_type="race_missing" 		  if substr(v1,1,7)=="Missing"	  & var_type[_n-1] == "race_hispanic"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "race_hispanic"				
					
					replace var_type="race_missing" 		  if substr(v1,1,7)=="Missing"	  & var_type[_n-1] == "race_nat_amer"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "race_nat_amer"
					
					replace var_type="race_missing" 		  if substr(v1,1,7)=="Missing"	  & var_type[_n-1] == "race_white"
					replace v1 = subinstr(v1,"Missing","",.)  if substr(v1,1,7)=="Missing"   & var_type[_n-1] == "race_white"					
				//Owner
					replace var_type="own_gov" 		  if substr(v1,1,16)=="Owner Government"
					replace v1 = subinstr(v1,"Owner Government","",.)  if substr(v1,1,16)=="Owner Government" 

					
					replace var_type="owner_non_profit" 		  if substr(v1,1,29)=="Owner Private, not-for-profit"
					replace v1 = subinstr(v1,"Owner Private, not-for-profit","",.)  if substr(v1,1,29)=="Owner Private, not-for-profit" 
					
					
					replace var_type="owner_non_profit" 		  if substr(v1,1,23)=="Private, not-for-profit"
					replace v1 = subinstr(v1,"Private, not-for-profit","",.)  if substr(v1,1,23)=="Private, not-for-profit" 

					replace var_type="owner_for_profit" 		  if substr(v1,1,19)=="Private, for-profit"
					replace v1 = subinstr(v1,"Private, for-profit","",.)  if substr(v1,1,19)=="Private, for-profit" 
				
				//Teaching Status
					replace var_type="teaching_no" 		  if substr(v1,1,27)=="Teaching status Nonteaching"
					replace v1 = subinstr(v1,"Teaching status Nonteaching","",.)  if substr(v1,1,27)=="Teaching status Nonteaching" 
 
 
 					replace var_type="teaching_yes" 		  if substr(v1,1,24)=="Teaching status Teaching"
					replace v1 = subinstr(v1,"Teaching status Teaching","",.)  if substr(v1,1,24)=="Teaching status Teaching" 
					
					replace var_type="teaching_yes" 		  if substr(v1,1,8)=="Teaching"
					replace v1 = subinstr(v1,"Teaching","",.)  if substr(v1,1,8)=="Teaching" 
				

								
				//Metro Status
					replace var_type="loc_non_metro" 		  if substr(v1,1,25)=="Location Non-metropolitan"
					replace v1 = subinstr(v1,"Location Non-metropolitan","",.)  if substr(v1,1,25)=="Location Non-metropolitan" 

					replace var_type="loc_metro" 		  if substr(v1,1,12)=="Metropolitan"
					replace v1 = subinstr(v1,"Metropolitan","",.)  if substr(v1,1,12)=="Metropolitan" 
					
					replace var_type="loc_metro" 		  if substr(v1,1,21)=="Location Metropolitan"
					replace v1 = subinstr(v1,"Location Metropolitan","",.)  if substr(v1,1,21)=="Location Metropolitan" 

			// Remove Unwanted Characters
				replace v1 = subinstr(v1,"(","",.)	 
				replace v1 = subinstr(v1,")","",.)	
				replace v1 = subinstr(v1,",","",.)	
				replace v1 = subinstr(v1,"%","",.)
				
			// Fix Missing Variables
				replace v1 = subinstr(v1,"*","* *",.) //Code for Missing (for Now)	There is not star for percent so we need to make sure spacing is correct
				replace v1 = subinstr(v1,"*","-999999999",.) //Code for Missing (for Now)	
				
			// Trim spaces
				replace v1 = trim(v1)  
				
				
			// Again Fix Missing Variables
				split v1, p(" ")
				rename v11 _both
				replace _both = "-999999999" if missing(_both) //Sometime there are only two stars when missing everything. This is to fix that
				rename v13 _admit
				replace _admit = "-999999999" if missing(_admit)
				rename v15 _ed
				replace _ed = "-999999999" if missing(_ed)

			// Reshape into one row
				keep var_type _*
				gen numb = 1
				reshape wide @_both @_admit @_ed, i(numb) j(var_type) string
				drop numb
				
			// Destring 
				qui ds
				foreach var in `r(varlist)' {
					destring `var', replace
				}
				
			// Change to Missing if actually missing 
				qui ds
				foreach var in `r(varlist)' {
					replace `var'=. if `var'==-999999999
				}
				
			gen state = "`st'"
			gen year = `yr'
			save "$temp_path/`st'_`yr'.dta", replace
		}
	}
}


use "$temp_path/Arizona_2005.dta", clear
drop in 1

local state_list Arizona Florida Hawaii Illinois Iowa Kentucky Maryland Minnesota "North Carolina" Nebraska "New Hampshire" "South Carolina" Tennessee Utah Vermont
local year_list 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013

 foreach st in `state_list' {
	foreach yr in `year_list' {
		capture append using "$temp_path/`st'_`yr'.dta"
	}
}


*We are missing Vermont. I should try to edit his code to see why

// Replace Missing if Year 2010 or earlier for separate files
	ds *_ed
	foreach var in `r(varlist)' {
		replace `var' = . if year <2011 
	}
	ds *_admit
	foreach var in `r(varlist)' {
		replace `var' = . if year <2011 
	}
// Erase Temp Files
	local state_list Arizona Florida Hawaii Illinois Iowa Kentucky Maryland Minnesota "North Carolina" Nebraska "New Hampshire" "South Carolina" Tennessee Utah Vermont
	local year_list 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013

	 foreach st in `state_list' {
		foreach yr in `year_list' {
			capture erase "$temp_path/`st'_`yr'.dta"
		}
	}
			

// Attach FIPS Codes
	gen StateFIPS=.
	
	replace  StateFIPS=1 if state=="Alabama"
	replace  StateFIPS=2 if state=="Alaska"
	replace  StateFIPS=4 if state=="Arizona"
	replace  StateFIPS=5 if state=="Arkansas"
	replace  StateFIPS=6 if state=="California"
	replace  StateFIPS=8 if state=="Colorado"
	replace  StateFIPS=9 if state=="Connecticut"
	replace  StateFIPS=10 if state=="Delaware"
	replace  StateFIPS=11 if state=="District of Columbia"
	replace  StateFIPS=12 if state=="Florida"
	replace  StateFIPS=13 if state=="Geogia"
	replace  StateFIPS=15 if state=="Hawaii"
	replace  StateFIPS=16 if state=="Idaho"
	replace  StateFIPS=17 if state=="Illinois"
	replace  StateFIPS=18 if state=="Indiana"
	replace  StateFIPS=19 if state=="Iowa"
	replace  StateFIPS=20 if state=="Kansas"
	replace  StateFIPS=21 if state=="Kentucky"
	replace  StateFIPS=22 if state=="Louisiana"
	replace  StateFIPS=23 if state=="Maine"
	replace  StateFIPS=24 if state=="Maryland"
	replace  StateFIPS=25 if state=="Massachusetts"
	replace  StateFIPS=26 if state=="Michigan"
	replace  StateFIPS=27 if state=="Minnesota"
	replace  StateFIPS=28 if state=="Mississippi"
	replace  StateFIPS=29 if state=="Missouri"
	replace  StateFIPS=30 if state=="Montana"
	replace  StateFIPS=31 if state=="Nebraska"
	replace  StateFIPS=32 if state=="Nevada"
	replace  StateFIPS=33 if state=="New Hampshire"
	replace  StateFIPS=34 if state=="New Jersey"
	replace  StateFIPS=35 if state=="New Mexico"
	replace  StateFIPS=36 if state=="New York"
	replace  StateFIPS=37 if state=="North Carolina"
	replace  StateFIPS=38 if state=="North Dakota"
	replace  StateFIPS=39 if state=="Ohio"
	replace  StateFIPS=40 if state=="Oklahoma"
	replace  StateFIPS=41 if state=="Oregon"
	replace  StateFIPS=42 if state=="Pennsylvania"
	replace  StateFIPS=44 if state=="Rhode Island"
	replace  StateFIPS=45 if state=="South Carolina"
	replace  StateFIPS=46 if state=="South Dakota"
	replace  StateFIPS=47 if state=="Tennessee"
	replace  StateFIPS=48 if state=="Texas"
	replace  StateFIPS=49 if state=="Utah"
	replace  StateFIPS=50 if state=="Vermont"
	replace  StateFIPS=51 if state=="Virginia"
	replace  StateFIPS=53 if state=="Washington"
	replace  StateFIPS=54 if state=="West Virginia"
	replace  StateFIPS=55 if state=="Wisconsin"
	replace  StateFIPS=56 if state=="Wyoming"

sort StateFIPS year 
order StateFIPS state year all*

//Rename For Type of ED Visit
	ds StateFIPS state year, not
	foreach var in `r(varlist)' {
		rename `var' `drug'_`var'
	}
//Save
	save "$data_path/hcupnet_`drug'_all.dta", replace
}

// Merge the datasets
use "$data_path/hcupnet_drug_all.dta", clear
merge 1:1 StateFIPS year using "$data_path/hcupnet_op_all.dta"
drop _merge
merge 1:1 StateFIPS year using "$data_path/hcupnet_her_all.dta"
drop _merge

order StateFIPS state year drug_all_both op_all_both her_all_both

// compress and save
compress
save "$data_path/state_level_ed_all.dta", replace


// Erase the datasets used in construction
erase "$data_path/hcupnet_drug_all.dta"
erase "$data_path/hcupnet_op_all.dta"
erase "$data_path/hcupnet_her_all.dta"

