clear all

// Import Commuting Zone Trade Exposure From David Dorn's Data
	use "$raw_data_path/david_dorn_data/workfile_china_long.dta"
	*CZONES do not appear to cross state lines
 	
 
		xtile man_den_5 = d_pct_manuf, n(5)
		tab man_den_5, gen(man_q_)
		drop man_den_5 
		
		xtile imp_exp_den_5 = d_tradeusch_pw, n(5)
		tab imp_exp_den_5, gen(imp_exp_q_)
		drop imp_exp_den_5 
		
// Attach David Dorn's 1990 County to Commuting Zone 
	merge 1:m czone using  "$raw_data_path/david_dorn_data/cw_cty_czone.dta"
	
	*Missing Alaska and Hawaii
	keep if _merge==3
	drop _merge

// Create State and County FIPS in mergeable form
	gen str5 z=string(cty_fips,"%05.0f")
	gen StateFIPS = substr(z,1,2)
	gen CountyFIPS = substr(z,3,3)
	destring StateFIPS, replace
	destring CountyFIPS, replace
	
	drop z
	

								
save "$data_path/dorn_data.dta", replace
