clear all
import excel "$raw_data_path/EDU02.xls", sheet("EDU02C") firstrow

keep STCOU  EDU635200D
destring STCOU , replace
	gen str5 z=string(STCOU,"%05.0f")
	gen StateFIPS = substr(z,1,2)
	gen CountyFIPS = substr(z,3,3)
	destring StateFIPS, replace
	destring CountyFIPS, replace
	drop z
	drop STCOU
	rename EDU635200D highschool_graduates
	label variable highschool_graduates "Educational attainment - persons 25 years and over - percent high school graduate or higher 2000"
	
	drop if CountyFIPS ==0
	
	save "$data_path/high_school_2000.dta", replace
