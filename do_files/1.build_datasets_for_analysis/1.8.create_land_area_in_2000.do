clear all
import excel "$raw_data_path/LND01.xls", sheet("Sheet1") firstrow
keep STCOU  LND010200D
destring STCOU , replace
	gen str5 z=string(STCOU,"%05.0f")
	gen StateFIPS = substr(z,1,2)
	gen CountyFIPS = substr(z,3,3)
	destring StateFIPS, replace
	destring CountyFIPS, replace
	drop z
	drop STCOU
	rename LND010200D land_area
	label variable land_area "Total area in square miles 2000"
	
	drop if CountyFIPS ==0
	
	save "$data_path/land_area_2000.dta", replace
