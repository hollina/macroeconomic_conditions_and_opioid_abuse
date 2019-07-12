
/* /////////////////////////////////////////////////////////////////////////////  
  Author: Alex Hollingsworth

  Creation Date: 6 August 2016
  
  Last Modified Date: 28 October 2016

  Description: Creates county-year counts of ED visits by cause from the SEDD.
				It also adds demographic, population, income, and unemployment data
				This takes a while to run.
				
*/ /////////////////////////////////////////////////////////////////////////////

clear all

capture program drop sedd_all_icd_opioid
*----------
program define sedd_all_icd_opioid
*----------
syntax, state(string) year(string) 
	set more off, perm
	//Open Dataset
		use "$raw_data_res_ed_path/`state'_SEDD_`year'_CORE.dta", clear

	
	// Diagnosis List 
		local dx_list dx1 dx2 dx3 dx4 dx5 dx6 dx7 dx8 dx9 dx10 dx11 dx12 dx13 dx14 dx15 dx16 dx17 dx18 dx19 dx20 
	// Make Uniform Diagnosis Code Number
		isvar `dx_list'
						
		foreach z in `r(badlist)' {
			gen `z' = "XXXXX"
		}
		
	// Accident Code List
		local ecode_list ecode1  ecode2  ecode3  ecode4  ecode5  ecode6  ecode7  ecode8

	// Make Uniform ECODE Number
		isvar `ecode_list'
						
		foreach z in `r(badlist)' {
			gen `z' = ""

		}	
		
		foreach z in `ecode_list' {
			replace `z' = subinstr(`z', "E", "", .)
			replace `z' = subinstr(`z', "invl", "", .)
			replace `z' = trim(`z')
			destring `z', replace force
		}	
					
		
	// *************************************************************************
	//		Diagnoses
	// *************************************************************************

		// ICD-9 Into Broader Categories
		
	
			// UTI
				//ICD-9 List for URI
					local icd9_list 5990
					
				// Create Binary for first ICD-9
					gen uti_first=0
					label variable uti_first "UTI"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace uti_first =1 if `dx'=="`icd9'"
						}
					}		
				
			// Broken Nose Creation
				//ICD-9 List for Broken Noses, Open and Cold
					local icd9_list 8020 8021

				// Create Binary for first ICD-9
					gen bkn_nose_first=0
					label variable bkn_nose_first "Broken Nose"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace bkn_nose_first =1 if `dx'=="`icd9'"
						}
					}			
	
			// Vomiting During Pregnancy
				//ICD-9 List for Vomiting During Pregnancy 
					local icd9_list 64300 64301 64303 64310 64311 64313 64320 64321 64323 64380 64381 64383 64390 64391 64393 

				// Create Binary for first ICD-9
					gen vom_preg_first=0
					label variable vom_preg_first "Vomiting During Pregnancy"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace vom_preg_first =1 if `dx'=="`icd9'"
						}
					}
			// Opioid Overdose
				*https://www.cdc.gov/drugoverdose/pdf/pdo_guide_to_icd-9-cm_and_icd-10_codes-a.pdf 
				*All from the CDC
				
				//ICD-9 List for Opioid Overdose
					local icd9_list 96500 96502 96509  // Opium and Opioid Poisoning
				// Create Binary for first ICD-9
					gen op_ovr_first=0
					label variable op_ovr_first "Opioid Poisoning"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace op_ovr_first =1 if `dx'=="`icd9'"
						}
					}			
					
				// Ecode List
					local e_list 8501 8502
			
					foreach e_numb in `ecode_list' { 
						foreach e_code in `e_list' {
							replace op_ovr_first =1 if `e_numb'==`e_code'
						}
					}		
					
			// Heroin Overdose
				//ICD-9 List for Opioid Overdose
					local icd9_list 96501  // 
				// Create Binary for first ICD-9
					gen her_ovr_first=0
					label variable her_ovr_first "Heroin Poisoning"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace her_ovr_first =1 if `dx'=="`icd9'"
						}
					}	
				// Ecode List
					local e_list 8500
			
					foreach e_numb in `ecode_list' { 
						foreach e_code in `e_list' {
							replace her_ovr_first =1 if `e_numb'==`e_code'
						}
					}		
			// Other Pharmaceutical Overdose
				//ICD-9 List for Opioid Overdose
					local icd9_list 96000 96100 96200 96300 96400 96510 96540 96550 96560 96570 96580 96590 ///
									96600 96700 96800 96810 96820 96830 96840 96860 96870 96890 96900 96910 96920 96930 ///
									96940 96950 96980 96990 97000 97001 97090 97100 97200 97300 97400 97500 97600 97700 97710 ///
									97720 97730 97740 97800 97900
				// Create Binary for first ICD-9
					gen pharm_ovr_first=0
					label variable pharm_ovr_first "Other Pharmaceutical Poisoning"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace pharm_ovr_first =1 if `dx'=="`icd9'"
						}
					}	
			// Ecode List
					local e_list  8503 8504 8505 8506 8507 8508 8509 ///
								  8510 8520 8530 8540 8543 8548 8550 8551 8553 8554 8555 ///
								  8556 8558 8559 8560 8570 8580 8581 8582 8583 8584 8585 ///
								  8586 9500 9501 9502 9503 9800 9801 9802 9803
			
					foreach e_numb in `ecode_list' { 
						foreach e_code in `e_list' {
							replace pharm_ovr_first =1 if `e_numb'==`e_code'
						}
					}		
								
			// Drug Overdose
				//ICD-9 List for Drug Overdose
					local icd9_list 9600-9799  // 
					
				// Create Binary for first ICD-9
					gen drug_ovr_first=0
					label variable drug_ovr_first "Drug Poisoning"
	
					forvalues icd9=9600(1)9799  { 
						foreach dx in `dx_list' {
							replace drug_ovr_first =1 if `dx'=="`icd9'"
						}
					}		
					
			// Ecode List 8500-8589
					local e_list //8500	8501	8502	8503	8504	8505	8506	8507	8508	8509	8510	8511	8512	8513	8514	8515	8516	8517	8518	8519	8520	8521	8522	8523	8524	8525	8526	8527	8528	8529	8530	8531	8532	8533	8534	8535	8536	8537	8538	8539	8540	8541	8542	8543	8544	8545	8546	8547	8548	8549	8550	8551	8552	8553	8554	8555	8556	8557	8558	8559	8560	8561	8562	8563	8564	8565	8566	8567	8568	8569	8570	8571	8572	8573	8574	8575	8576	8577	8578	8579	8580	8581	8582	8583	8584	8585	8586	8587	8588	8589 9500 9501 9502 9503 9504 9505 9506 9507 9508 9509
			
					foreach e_numb in `ecode_list' { 
						foreach e_code in `e_list' {
							replace drug_ovr_first =1 if `e_numb'==`e_code'
						}
					}		
			// Opioid Dependence
				//ICD-9 List for Opioid Dependence
					local icd9_list 30400 30401 30402 30403 30550 30551 30552 30553

				// Create Binary for first ICD-9
					gen op_dep_first=0
					label variable op_dep_first ""
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace op_dep_first =1 if `dx'=="`icd9'"
						}
					}
					
			// Benzos
				//ICD-9 List for Benzos
					local icd9_list 9694

				// Create Binary for first ICD-9

								// Create Binary for first ICD-9
					gen benz_dep_first=0
					label variable benz_dep_first "Pois-Benzodiazepine Tran"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace benz_dep_first =1 if `dx'=="`icd9'"
						}
						}
			/*			
			// Medicinal Agnent
				//ICD-9 List for Benzos
					local icd9_list 9779 9778

				// Create Binary for first ICD-9

								// Create Binary for first ICD-9
					gen med_dep_first=0
					label variable med_dep_first "Pois Medicinal Agt"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace med_dep_first =1 if `dx'=="`icd9'"
						}
			*/							
			// Aromatic Analgesics 
				//ICD-9 List for Benzos
					local icd9_list 9654

				// Create Binary for first ICD-9

								// Create Binary for first ICD-9
					gen aro_dep_first=0
					label variable aro_dep_first "Pois-Arom Analgesics Nec"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace aro_dep_first =1 if `dx'=="`icd9'"
						}
						}
		// Antidepressants  
				//ICD-9 List for Benzos
					local icd9_list 9690

				// Create Binary for first ICD-9

								// Create Binary for first ICD-9
					gen adep_dep_first=0
					label variable adep_dep_first "Pois Antidepressants Nec"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace adep_dep_first =1 if `dx'=="`icd9'"
						}
						}
		// Insulin  
				//ICD-9 List for Benzos
					local icd9_list 9623

				// Create Binary for first ICD-9

								// Create Binary for first ICD-9
					gen ins_dep_first=0
					label variable ins_dep_first "Insulin"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace ins_dep_first =1 if `dx'=="`icd9'"
						}
						}
		// Cocaine  
				//ICD-9 List for Benzos
					local icd9_list 9708

				// Create Binary for first ICD-9

								// Create Binary for first ICD-9
					gen coke_dep_first=0
					label variable coke_dep_first "Cocaine"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
							replace coke_dep_first =1 if `dx'=="`icd9'"
						}	
						}					
		// Antipsychotic  
				//ICD-9 List for Benzos
					local icd9_list 9693

				// Create Binary for first ICD-9

								// Create Binary for first ICD-9
					gen psyc_dep_first=0
					label variable psyc_dep_first "Antipsychotic"
						
					foreach icd9 in `icd9_list' { 
						foreach dx in `dx_list' {
						
							replace psyc_dep_first =1 if `dx'=="`icd9'"
						}
}						
												
			//Both Heroin and Opioid
				gen oah_ovr_first=0
				label variable oah_ovr_first "Opioid and Herioid Overdose"
				replace oah_ovr_first = 1 if her_ovr_first ==1 & op_ovr_first ==1
				
			//For these placebos we will use CCS code 
				//First CCS Code Local Macro
					local dx_ccs_list dxccs1  dxccs2  dxccs3  dxccs4  dxccs5  dxccs6  dxccs7  dxccs8  dxccs9  dxccs10  dxccs11  dxccs12  dxccs13  dxccs14  dxccs15  dxccs16  dxccs17  dxccs18  dxccs19  dxccs20         
					
				// Make Uniform Diagnosis Code Number
					isvar `dx_ccs_list'
									
					foreach z in `r(badlist)' {
						gen `z' = -9999
					}
				//Broken Arm
					//CCS List for Broken Arm
						local ccs_list 229

					//First CCS Code
						gen brk_arm_first=0
						label variable brk_arm_first "Broken Arm"
													
						foreach ccs in `ccs_list' { 
							foreach dx in `dx_ccs_list' {
								replace brk_arm_first=1 if `dx'==`ccs'
							}
						}
				//Broken Leg
					//CCS List for Broken Leg
						local ccs_list 230
						
					//First CCS Code
						gen brk_leg_first=0
						label variable brk_leg_first "Broken Leg"
							
						foreach ccs in `ccs_list' { 
							foreach dx in `dx_ccs_list' {
								replace brk_leg_first=1 if `dx'==`ccs'
							}
						}
						
				//Open Wound Head 
					//CCS List Open Head Wound
						local ccs_list 235

					//First CCS Code
						gen head_first=0
						label variable head_first "Open Head Wound"
							
						foreach ccs in `ccs_list' { 
							foreach dx in `dx_ccs_list' {
								replace head_first=1 if `dx'==`ccs'
							}
						}
						
	// *************************************************************************
	//		Payer Type
	// *************************************************************************
	
		// Reformat Expected primary payer into Binary Variables
			/*Note: This could be more specific for any given state, but pay1 is comparable
					across states. Also children on CHIP could be listed in Medicaid in 
					some state-years, but other in other state-years. */
					
			// Medicare
				gen payer_mcare=0
				replace payer_mcare=1 if pay1==1
				label variable payer_mcare "Medicare, Expected Payer"
					
			// Medicaid
				gen payer_mcaid=0
				replace payer_mcaid=1 if pay1==2
				label variable payer_mcaid "Medicaid, Expected Payer"
					
			// Private Insurance
				gen payer_ins=0
				replace payer_ins=1 if pay1==3
				label variable payer_ins "Private Insurance, Expected Payer"
					
			// Self-Pay
				gen payer_self=0
				replace payer_self=1 if pay1==4
				label variable payer_self "Self-Pay, Expected Payer"
					
			// No Charge
				gen payer_free=0
				replace payer_free=1 if pay1==5
				label variable payer_free  "No Charge, Expected Payer"
					
			// Other
				gen payer_other=0
				replace payer_other=1 if pay1==6
				label variable payer_other "Other, Expected Payer"
				
			// Missing
				gen payer_miss=0
				replace payer_miss=1 if pay1==. |pay1==.a |pay1==.b
				label variable payer_miss "Missing, Expected Payer"

	// *************************************************************************
	//		Demographics
	// *************************************************************************
		
		// Turn Race into Binaries
			//Account for the fact that some years don't have race
			
			isvar race
						
			foreach z in `r(badlist)' {
				gen `z' =.
			}
		        
			gen r_w=1 if race==1 
			replace r_w=0 if race!=1 & !missing(race)
			label variable r_w "White"
			
		        gen r_b=1 if race==2 
			replace r_b=0 if race!=2 & !missing(race)
			label variable r_b "Black"
			
		        gen r_h=1 if race==3
			replace r_h=0 if race!=3 & !missing(race)
			label variable r_h "Hispanic"
					
		// Turn Age into Age Group Binaries

			//Drop if under 18 months old. Retail Clinics do not treat 17 months and younger
				capture drop if agemonth <18 //Not all state years have agemonth
				capture drop if age < 2

			//Fine Age Bands
				//1.5-5
					gen age_1_5 = 0
					replace age_1_5 = 1 if age < 6
					label variable age_1_5 "Age 1.5 to 5"
				//6-12
					gen age_6_12 = 0
					replace age_6_12 = 1 if age > 5 & age <13
					label variable age_6_12 "Age 6 to 12"		
				//13-17
					gen age_13_17 = 0
					replace age_13_17 = 1 if age > 12 & age <18
					label variable age_13_17 "Age 13 to 17"	
				//18-25
					gen age_18_25 = 0
					replace age_18_25 = 1 if age > 17 & age <26
					label variable age_18_25 "Age 18 to 25"		
				//26-45
					gen age_26_45 = 0
					replace age_26_45 = 1 if age > 25 & age <46
					label variable age_26_45 "Age 26 to 45"		
				//46-64
					gen age_46_64 = 0
					replace age_46_64 = 1 if age > 45 & age <65
					label variable age_46_64 "Age 46 to 64"		
				//65-84
					gen age_65_84 = 0
					replace age_65_84 = 1 if age > 64 & age <85
					label variable age_65_84 "Age 65 to 84"		
				//85+
					gen age_85_up = 0
					replace age_85_up = 1 if age > 84
					label variable age_85_up "Age 85+"	
					
			// Broad Age Bands 
				//1.5-17
					gen age_1_17 = 0
					replace age_1_17 = 1 if age < 18
					label variable age_1_17 "Age 1.5 to 17"		
				//18-64
					gen age_18_64 = 0
					replace age_18_64 = 1 if age > 17 & age <65
					label variable age_18_64 "Age 18 to 64"			
				//65+
					gen age_65_up = 0
					replace age_65_up = 1 if age > 64
					label variable age_65_up "Age 65+"	
					
		// Turn Gender into Binary
			label variable female "Female (=1)"
					
		//Generate A One for Each Observation
			gen ones = 1
			
		// Keep if One of the dx codes listed
			ds *first*
			gen keeper = 0 

			foreach v in `r(varlist)' {
				replace keeper =1 if `v' ==1 
			}
			
			keep if keeper==1
			

			drop keeper
			
		// Save a temp version of this file. 
			save "$raw_data_res_ed_path/temp_store_`state'_`year'.dta", replace

		// Create List of Diseases
			qui ds  *first*
			local collapse_icd_list `r(varlist)'
			
		// Save a temp version of the file for each icd9 and ccs subset
			foreach x in `collapse_icd_list' {
				use "$raw_data_res_ed_path/temp_store_`state'_`year'.dta", clear
				
				local label_macro: var label `x'  
				collapse (sum) ones, by(`x'  pstco2 )
				
				rename `x' b_`x'
				rename ones `x'
			
				sort  b_`x'
				
				egen id=group(pstco2 )
				reshape wide `x', j(b_`x') i(id)
				
				
					isvar `x'1  `x'0
						
				foreach z in `r(badlist)' {
					gen `z' = 0
				}
				
				
				replace `x'0 = 0 if missing(`x'0)
				replace `x'1 = 0 if missing(`x'1)

				drop id
				gen share_`x' = `x'1/(`x'0+`x'1)
				drop `x'0
				rename *1 *				
				
				label variable `x' "# of Annual Visits for `label_macro'"
				label variable share_`x' "% of Annual Visits for `label_macro'"
				
				gen year = `year'
				
				sum `x' share_
			
				save  "$raw_data_res_ed_path/`state'_`year'_`x'_total.dta", replace
				
			}
		use "$raw_data_res_ed_path/temp_store_`state'_`year'.dta", clear	
		//Sub-group macro 
			//Demographics
				qui ds age_* female payer_* r_*
				local dem_groups `r(varlist)'
			//Diagnosis
				qui ds  *first*
				local diag_groups `r(varlist)'		
				
		// Make A file for each subgroup
			foreach y in `dem_groups' {
				foreach x in `diag_groups' {
						use "$raw_data_res_ed_path/temp_store_`state'_`year'.dta", clear
						
						
						local label_macro1: var label `x'  
						local label_macro2: var label `y'  
				
						keep if  `y'  ==1
					if _N>0 {
						collapse (sum) ones, by(`x'  pstco2 )
									
						rename `x' b_`x'
						rename ones `x'
					
						sort  b_`x'
						
						egen id=group( pstco2 )
						reshape wide `x', j(b_`x') i(id)
												
						isvar `x'1  `x'0
						
						foreach z in `r(badlist)' {
							gen `z' = 0
						}
				
						replace `x'0 = 0 if missing(`x'0)
						capture replace `x'1 = 0 if missing(`x'1)
				
				
						gen year = `year'
						drop `x'0
						capture rename *1 *
						
						capture noisily rename `x' `x'_`y'  
						
						isvar `x'_`y'  
						
						foreach z in `r(badlist)' {
							gen `z' = 0
						}
						
					capture	label variable `x'_`y' "# of Annual Visits for `label_macro2' `label_macro1'"
						drop id
						save  "$raw_data_res_ed_path/`state'_`year'_`x'_`y'.dta", replace
					}
				}
			}
			
		// Merge the Files Together
			use "$raw_data_res_ed_path/temp_store_`state'_`year'.dta", clear 
			
			// Create List of Diseases
				qui ds  *first*
				local collapse_icd_list `r(varlist)'		
			//Sub-group macro 
				//Demographics
					qui ds age_* female payer_* r_*
					local dem_groups `r(varlist)'
				//Diagnosis
					qui ds  *first*
					local diag_groups `r(varlist)'
				
				
			keep pstco2 year 
			duplicates drop
			
				foreach x in `collapse_icd_list' {
					merge 1:1 pstco2  year  using "$raw_data_res_ed_path/`state'_`year'_`x'_total.dta", nogen
				}
				
				foreach y in `dem_groups' {
					foreach x in `diag_groups' {
					capture	merge 1:1 pstco2  year  using  "$raw_data_res_ed_path/`state'_`year'_`x'_`y'.dta", nogen
					}
				}
				
		// Replace Missing With 0	
			qui ds year  pstco2 , not
			foreach v in `r(varlist)' {
				replace `v' = 0 if missing(`v')
			}
		// Gen State Variable. Later we will only keep counties that match with state
			gen state_lower = "`state'"
		//Share is created incorrectly 
			capture drop *share*

		// Rename From First
			rename *first* *any*
		//Save
			save "$raw_data_res_ed_path/`state'_`year'_pstco_any_diagnosis.dta", replace
				
		// Erase Temp File
		
			// Erase temp version of main file. 
				erase "$raw_data_res_ed_path/temp_store_`state'_`year'.dta"
		
			// Erase each collapsed file by icd
				foreach x in `collapse_icd_list' {
					erase "$raw_data_res_ed_path/`state'_`year'_`x'_total.dta"
				}

				foreach y in `dem_groups' {
					foreach x in `diag_groups' {
						capture	erase "$raw_data_res_ed_path/`state'_`year'_`x'_`y'.dta"
						}
					}

	
*----------
end
*----------

////////////////////////////////////////////////////////////////////////////////
// Create County Level Data for Each State Year

forvalues yr = 2005/2014 {
	sedd_all_icd_opioid, state(AZ) year(`yr') 
}

forvalues yr = 2005/2014 {
	sedd_all_icd_opioid, state(FL) year(`yr') 
}

forvalues yr = 2008/2013 {
	sedd_all_icd_opioid, state(KY) year(`yr') 
}
	forvalues yr = 2002/2012 {
	sedd_all_icd_opioid, state(MD) year(`yr') 
}
forvalues yr = 2004/2013 {
	sedd_all_icd_opioid, state(NJ) year(`yr') 
}

////////////////////////////////////////////////////////////////////////////////
// Combine data	

// Clear memory
clear all
	
// Change directory
cd "$raw_data_res_ed_path/"
	
// Append the files together
use MD_2002_pstco_any_diagnosis.dta, clear

forvalues yr = 2003/2012 {
	append using "MD_`yr'_pstco_any_diagnosis.dta"
}
forvalues yr = 2005/2014 {
	append using "FL_`yr'_pstco_any_diagnosis.dta"
}

forvalues yr = 2005/2014 {
	append using "AZ_`yr'_pstco_any_diagnosis.dta"
}

forvalues yr = 2008/2013 {
	append using "KY_`yr'_pstco_any_diagnosis.dta"
}

forvalues yr = 2004/2013 {
	append using "NJ_`yr'_pstco_any_diagnosis.dta"
}

// Sort the Data
order state_lower pstco2 year  
sort state_lower pstco2 year  

// Add State Abb, Name, and FIPS
rename state_lower state

gen StateFIPS=.					
		
replace StateFIPS=	15	if 	state=="HI"
replace StateFIPS=	1	if 	state=="AL"
replace StateFIPS=	2	if 	state=="AK"
replace StateFIPS=	4	if 	state=="AZ"
replace StateFIPS=	5	if 	state=="AR"
replace StateFIPS=	6	if 	state=="CA"
replace StateFIPS=	8	if 	state=="CO"
replace StateFIPS=	9	if 	state=="CT"
replace StateFIPS=	10	if 	state=="DE"
replace StateFIPS=	11	if 	state=="DC"
replace StateFIPS=	12	if 	state=="FL"
replace StateFIPS=	13	if 	state=="GA"
replace StateFIPS=	16	if 	state=="ID"
replace StateFIPS=	17	if 	state=="IL"
replace StateFIPS=	18	if 	state=="IN"
replace StateFIPS=	19	if 	state=="IA"
replace StateFIPS=	20	if 	state=="KS"
replace StateFIPS=	21	if 	state=="KY"
replace StateFIPS=	22	if 	state=="LA"
replace StateFIPS=	23	if 	state=="ME"
replace StateFIPS=	24	if 	state=="MD"
replace StateFIPS=	25	if 	state=="MA"
replace StateFIPS=	26	if 	state=="MI"
replace StateFIPS=	27	if 	state=="MN"
replace StateFIPS=	28	if 	state=="MS"
replace StateFIPS=	29	if 	state=="MO"
replace StateFIPS=	30	if 	state=="MT"
replace StateFIPS=	31	if 	state=="NE"
replace StateFIPS=	32	if 	state=="NV"
replace StateFIPS=	33	if 	state=="NH"
replace StateFIPS=	34	if 	state=="NJ"
replace StateFIPS=	35	if 	state=="NM"
replace StateFIPS=	36	if 	state=="NY"
replace StateFIPS=	37	if 	state=="NC"
replace StateFIPS=	38	if 	state=="ND"
replace StateFIPS=	39	if 	state=="OH"
replace StateFIPS=	40	if 	state=="OK"
replace StateFIPS=	41	if 	state=="OR"
replace StateFIPS=	42	if 	state=="PA"
replace StateFIPS=	44	if 	state=="RI"
replace StateFIPS=	45	if 	state=="SC"
replace StateFIPS=	46	if 	state=="SD"
replace StateFIPS=	47	if 	state=="TN"
replace StateFIPS=	48	if 	state=="TX"
replace StateFIPS=	49	if 	state=="UT"
replace StateFIPS=	50	if 	state=="VT"
replace StateFIPS=	51	if 	state=="VA"
replace StateFIPS=	53	if 	state=="WA"
replace StateFIPS=	54	if 	state=="WV"
replace StateFIPS=	55	if 	state=="WI"
replace StateFIPS=	56	if 	state=="WY"

gen state_name=""

replace state_name=	"ALASKA"	if StateFIPS==	2
replace state_name=	"ALABAMA"	if StateFIPS==	1
replace state_name=	"ARKANSAS"	if StateFIPS==	5
replace state_name=	"AMERICAN SAMOA"	if StateFIPS==	60
replace state_name=	"ARIZONA"	if StateFIPS==	4
replace state_name=	"CALIFORNIA"	if StateFIPS==	6
replace state_name=	"COLORADO"	if StateFIPS==	8
replace state_name=	"CONNECTICUT"	if StateFIPS==	9	
replace state_name=	"DISTRICT OF COLUMBIA"	if StateFIPS==	11
replace state_name=	"DELAWARE"	if StateFIPS==	10
replace state_name=	"FLORIDA"	if StateFIPS==	12
replace state_name=	"GEORGIA"	if StateFIPS==	13
replace state_name=	"GUAM"	if StateFIPS==	66
replace state_name=	"HAWAII"	if StateFIPS==	15
replace state_name=	"IOWA"	if StateFIPS==	19
replace state_name=	"IDAHO"	if StateFIPS==	16
replace state_name=	"ILLINOIS"	if StateFIPS==	17
replace state_name=	"INDIANA"	if StateFIPS==	18
replace state_name=	"KANSAS"	if StateFIPS==	20
replace state_name=	"KENTUCKY"	if StateFIPS==	21
replace state_name=	"LOUISIANA"	if StateFIPS==	22
replace state_name=	"MASSACHUSETTS"	if StateFIPS==	25
replace state_name=	"MARYLAND"	if StateFIPS==	24
replace state_name=	"MAINE"	if StateFIPS==	23
replace state_name=	"MICHIGAN"	if StateFIPS==	26
replace state_name=	"MINNESOTA"	if StateFIPS==	27
replace state_name=	"MISSOURI"	if StateFIPS==	29
replace state_name=	"MISSISSIPPI"	if StateFIPS==	28
replace state_name=	"MONTANA"	if StateFIPS==	30
replace state_name=	"NORTH CAROLINA"	if StateFIPS==	37
replace state_name=	"NORTH DAKOTA"	if StateFIPS==	38
replace state_name=	"NEBRASKA"	if StateFIPS==	31
replace state_name=	"NEW HAMPSHIRE"	if StateFIPS==	33
replace state_name=	"NEW JERSEY"	if StateFIPS==	34
replace state_name=	"NEW MEXICO"	if StateFIPS==	35
replace state_name=	"NEVADA"	if StateFIPS==	32
replace state_name=	"NEW YORK"	if StateFIPS==	36
replace state_name=	"OHIO"	if StateFIPS==	39
replace state_name=	"OKLAHOMA"	if StateFIPS==	40
replace state_name=	"OREGON"	if StateFIPS==	41
replace state_name=	"PENNSYLVANIA"	if StateFIPS==	42
replace state_name=	"PUERTO RICO"	if StateFIPS==	72
replace state_name=	"RHODE ISLAND"	if StateFIPS==	44
replace state_name=	"SOUTH CAROLINA"	if StateFIPS==	45
replace state_name=	"SOUTH DAKOTA"	if StateFIPS==	46
replace state_name=	"TENNESSEE"	if StateFIPS==	47
replace state_name=	"TEXAS"	if StateFIPS==	48
replace state_name=	"UTAH"	if StateFIPS==	49
replace state_name=	"VIRGINIA"	if StateFIPS==	51
replace state_name=	"VIRGIN ISLANDS"	if StateFIPS==	78
replace state_name=	"VERMONT"	if StateFIPS==	50
replace state_name=	"WASHINGTON"	if StateFIPS==	53
replace state_name=	"WISCONSIN"	if StateFIPS==	55
replace state_name=	"WEST VIRGINIA"	if StateFIPS==	54
replace state_name=	"WYOMING"	if StateFIPS==	56

replace state_name = proper(state_name)

// Keep only if a resident of the state the hospital is located in
gen str5 z = string(pstco2,"%05.0f")	

gen st_of_residence =substr(z,1,2)
destring st_of_residence, replace
keep if st_of_residence == StateFIPS

// Generate Separate State and County FIPS
gen CountyFIPS =substr(z,3,3) 
destring CountyFIPS, replace

drop z st_of_residence

order state_name state StateFIPS  CountyFIPS year  
sort StateFIPS CountyFIPS year  

rename pstco2 fips

// Replace Missing with 0s	
qui ds state_name state StateFIPS  CountyFIPS year  , not
foreach x in `r(varlist)'{
	replace `x' =0 if missing(`x')
}

// Add Demographic, Population, Income, and Unemployment Data
merge m:1 StateFIPS CountyFIPS year using "$data_path/county_unemployment_99_14.dta"
keep if _merge==3
drop _merge

merge m:1 StateFIPS CountyFIPS year using "$data_path/saipe_median_inc_poverty.dta"
keep if _merge==3 // We lose MD 2002 since we don't have that data on poverty for some reason
drop _merge

merge m:1 StateFIPS CountyFIPS year using "$data_path/county_pop_age_race_1990_2014.dta"
keep if _merge==3
drop _merge

// Sort and Order
sort StateFIPS CountyFIPS year

// XTSET
xtset fips year

// Drop share, it's not created correctly
capture drop *share*

// Drop NJ 2005. There's an issue
drop if state=="NJ" & year==2005

// Drop KY 2009. There's an issue
drop if state=="KY" & year==2009

// Make Sure Race is Missing for Arizona 2005-2007. There's an issue
qui ds *_r_w *_r_b *_r_h
foreach var in `r(varlist)' {
	replace `var' = . if StateFIPS==4 & year <2008
}

// Save Dataset for analysis
compress
save "$raw_data_res_ed_path/drug_ed_visits_with_county.dta", replace
