//Import 1999
	clear all
	infix StateFIPS 1-2 CountyFIPS 4-6 median_income 134-139 using  "$raw_data_path/small_area_income_poverty_estimates/est99ALL.dat.txt"
		label variable median_income "Median Household Income"
	gen year =1999
drop if missing(CountyFIPS)
	keep if CountyFIPS!=0
		save "$temp_path/1999.dta", replace

//Import 2000
	clear all
	infix StateFIPS 1-2 CountyFIPS 4-6 median_income 134-139 using  "$raw_data_path/small_area_income_poverty_estimates/est00ALL.dat.txt"
	label variable median_income "Median Household Income"
	gen year =2000
drop if missing(CountyFIPS)
	keep if CountyFIPS!=0
		save "$temp_path/2000.dta", replace

//Import 2001
	clear all
	infix StateFIPS 1-2 CountyFIPS 4-6 median_income 134-139 using  "$raw_data_path/small_area_income_poverty_estimates/est01ALL.dat.txt"
		label variable median_income "Median Household Income"
drop if missing(CountyFIPS)
	keep if CountyFIPS!=0
		gen year =2001
	save "$temp_path/2001.dta", replace

//Import 2002
	clear all
	infix StateFIPS 1-2 CountyFIPS 4-6 median_income 134-139 using  "$raw_data_path/small_area_income_poverty_estimates/est02ALL.dat.txt"
		label variable median_income "Median Household Income"
	gen year =2002
drop if missing(CountyFIPS)
	keep if CountyFIPS!=0
		save "$temp_path/2002.dta", replace

//Import 2003
	clear all
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est03ALL.xls", sheet("est03ALL") cellrange(A2:AE3195) firstrow
drop if missing(CountyFIPS)
	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename PostalCode state
	rename Name county
	gen year =2003
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	
	save "$temp_path/2003.dta", replace
//Import 2004
	clear all
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est04ALL.xls", sheet("est04ALL") cellrange(A2:AE3195) firstrow
drop if missing(CountyFIPS)

	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace
	
	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2004
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2004.dta", replace

//Import 2005
	clear all
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est05ALL.xls", sheet("Sheet1") cellrange(A3:AE3199) firstrow clear
	drop if missing(CountyFIPS)

	destring StateFIPS, replace
	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2005
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2005.dta", replace

//Import 2006
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est06ALL.xls", sheet("est06ALL") cellrange(A3:AE3199) firstrow clear
	drop if missing(CountyFIPS)

	destring StateFIPS, replace

	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2006
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2006.dta", replace

//Import 2007	
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est07ALL.xls", sheet("est07ALL") cellrange(A3:AE3199) firstrow clear
	drop if missing(CountyFIPS)

	destring StateFIPS, replace

	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2007
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2007.dta", replace

	
//Import 2008
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est08ALL.xls", sheet("est08ALL") cellrange(A3:AE3200) firstrow clear
	drop if missing(CountyFIPS)

	destring StateFIPS, replace

	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2008
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2008.dta", replace

//Import 2009
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est09ALL.xls", sheet("est09ALL") cellrange(A3:AE3201) firstrow clear
	drop if missing(CountyFIPS)

	destring StateFIPS, replace
	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2009
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2009.dta", replace

//Import 2010
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est10ALL.xls", sheet("est10ALL") cellrange(A3:AE3201) firstrow clear
	drop if missing(CountyFIPS)

	destring StateFIPS, replace
	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2010
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2010.dta", replace

//Import 2011
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est11ALL.xls", sheet("est11ALL") cellrange(A3:AE3201) firstrow clear
	drop if missing(CountyFIPS)

	destring StateFIPS, replace
	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2011
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2011.dta", replace

//Import 2012
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est12ALL.xls", sheet("est12all") cellrange(A3:AE3198) firstrow clear
		drop if missing(CountyFIPS)

	destring CountyFIPSCode , replace
	destring StateFIPSCode , replace
	rename CountyFIPSCode CountyFIPS
	rename StateFIPSCode StateFIPS
	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename PostalCode state
	rename Name county
	gen year =2012
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2012.dta", replace

//Import 2013
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est13ALL.xls", sheet("est13ALL") cellrange(A4:AE3199) firstrow clear
	destring CountyFIPSCode , replace
	destring StateFIPSCode , replace
	rename CountyFIPSCode CountyFIPS
	rename StateFIPSCode StateFIPS
	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace

	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename Postal state
	rename Name county
	gen year =2013
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty
	save "$temp_path/2013.dta", replace

//Import 2014
	clear all
	import excel  "$raw_data_path/small_area_income_poverty_estimates/est14ALL.xls", sheet("est14ALL") cellrange(A4:AE3198) firstrow
	destring CountyFIPSCode , replace
	destring StateFIPSCode , replace
	rename CountyFIPSCode CountyFIPS
	rename StateFIPSCode StateFIPS
	keep if CountyFIPS!=0
	destring MedianHouseholdIncome , replace
	rename MedianHouseholdIncome median_income
	label variable median_income "Median Household Income"
	destring PovertyPercentAllAges, replace
	rename PovertyPercentAllAges percent_in_poverty
	label variable percent_in_poverty "\% in Poverty"
	rename PostalCode state
	rename Name county
	gen year =2014
	keep StateFIPS CountyFIPS year state median_income percent_in_poverty

	save "$temp_path/2014.dta", replace
	
//Append Together
	use "$temp_path/1999.dta", clear
	
	forvalues year=2000(1)2014{
		append using "$temp_path/`year'.dta"
	}
//Clean Up 
	forvalues year=1999(1)2014{
		erase "$temp_path/`year'.dta"
	}

//Save 
	save "$data_path/saipe_median_inc_poverty.dta", replace
