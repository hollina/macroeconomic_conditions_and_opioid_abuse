// Change directory to restricted access mortality raw data path.
cd "$raw_data_res_mort_path"

// Note: The following code was run on Ruhm's machine in 3/2017

///////////////////////////////////////////////////////////////////////////////
// Import data from raw mortality files, all renamed to be mcod1999.dat, etc. and save in stata format

*1999-2002
foreach x in 1999 2000 2001 2002 {
	
	// Import raw data
	infix res 20 educ 52-53 month 55-56 female 59 race 62 age1 64 age2 65-66 place 75 mar 77 hispanic 82 day 83 state 124-125 county 126-128 str icd10 142-145 recode113 151-153 numcond 338-339 str rec1 341-345 str rec2 346-350 str rec3 351-355 str rec4 356-360 str rec5 361-365 str rec6 366-370 str rec7 371-375 str rec8 376-380 str rec9 381-385 str rec10 386-390 str rec11 391-395 str rec12 396-400 str rec13 401-405 str rec14 406-410 str rec15 411-415 str rec16 416-420 str rec17 421-425 str rec18 426-430 str rec19 431-435 str rec20 436-440 using "$raw_data_res_mort_path/mcod`x'.dat"
	
	// Create dummy variables
	replace female=female-1
	gen married=mar==2
	
	// Create age
	gen age=age2 if age1==0
	replace age=age2+100 if age1==1
	replace age=0 if age1>=2 & age1<=6
	
	// Create education
	*note: missing education is reference group
	gen hsdrop=educ<=11
	gen hsgrad=educ==12
	gen somecol=(educ>=13 & educ<=15)
	gen colgrad=(educ==16 | educ==17)
	
	// Create race
	gen black=race==3
	gen othrace=race==2
	
	// Drop variables used in creation
	drop age1 age2 educ race mar
	
	// Generate year variable
	gen year=`x'
	
	// Compress and save
	qui compress
	save "$raw_data_res_mort_path/mcod`x'", replace
	clear
}

*2003-2015
foreach x in 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
	
	// Import raw data
	infix res 20 str statel 29-30 county 35-37 educ1 61-62 educ2 63 educflag 64 month 65-66 str fem 69 age1 70 age2 71-73 place 83 str mar 84 day 85 str autpsy 109 str icd10 146-149 recode113 154-156 numcond 341-342 str rec1 344-348 str rec2 349-353 str rec3 354-358 str rec4 359-363 str rec5 364-368 str rec6 369-373 str rec7 374-378 str rec8 379-383 str rec9 384-388 str rec10 389-393 str rec11 394-398 str rec12 399-403 str rec13 404-408 str rec14 409-413 str rec15 414-418 str rec16 419-423 str rec17 424-428 str rec18 429-433 str rec19 434-438 str rec20 439-443 race 449 hispanic 488 using "$raw_data_res_mort_path/mcod`x'.dat"

	// Create dummy variables
	*replace missing values
	gen female=fem=="F"
	gen married=mar=="M"
	
	// Create age
	gen age=age2 if age1==1
	replace age=0 if age1>=2 & age1<=6
	
	// Create education
	*note: missing education is reference group
	gen hsdrop=educ1<=11 if educflag==0
	gen hsgrad=educ1==12 if educflag==0
	gen somecol=(educ1>=13 & educ1<=15) if educflag==0
	gen colgrad=(educ1==16 | educ1==17) if educflag==0
	replace hsdrop=educ2<=2 if educflag==1
	replace hsgrad=educ2==3 if educflag==1
	replace somecol=(educ2==4 | educ2==5) if educflag==1
	replace colgrad=(educ2>=6 & educ2<=8) if educflag==1
	
	
	// Create race
	gen black=race==3
	gen othrace=race==2
	
	// Create autopsy indicator
	gen autopsy=autpsy=="Y"
	
	// Drop variables used in creation
	drop age1 age2 fem mar race educ1 educ2 educflag
	
	// Generate year variable
	gen year=`x'
	
	// Compress and save
	qui compress
	save "$raw_data_res_mort_path/mcod`x'", replace
	clear
}


////////////////////////////////////////////////////////////////////////////////
// Append the datasets together
use "$raw_data_res_mort_path/mcod1999"
foreach x in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 {
	qui append using "$raw_data_res_mort_path/mcod20`x'"
}

////////////////////////////////////////////////////////////////////////////////
// drop deaths to foreign residents
drop if res==4
drop res

////////////////////////////////////////////////////////////////////////////////
// replace missing values
replace day=. if day==9
replace age=. if age>150

////////////////////////////////////////////////////////////////////////////////
// state abbreviations to fips codes
replace state=02 if statel=="AK"	
replace state=01 if statel=="AL"	
replace state=05 if statel=="AR"	
replace state=04 if statel=="AZ"	
replace state=06 if statel=="CA"	
replace state=08 if statel=="CO"	
replace state=09 if statel=="CT"	
replace state=11 if statel=="DC"	
replace state=10 if statel=="DE"	
replace state=12 if statel=="FL"	
replace state=13 if statel=="GA"	
replace state=15 if statel=="HI"	
replace state=19 if statel=="IA"	
replace state=16 if statel=="ID"	
replace state=17 if statel=="IL"	
replace state=18 if statel=="IN"	
replace state=20 if statel=="KS"	
replace state=21 if statel=="KY"	
replace state=22 if statel=="LA"	
replace state=25 if statel=="MA"	
replace state=24 if statel=="MD"	
replace state=23 if statel=="ME"	
replace state=26 if statel=="MI"	
replace state=27 if statel=="MN"	
replace state=29 if statel=="MO"	
replace state=28 if statel=="MS"	
replace state=30 if statel=="MT"	
replace state=37 if statel=="NC"	
replace state=38 if statel=="ND"	
replace state=31 if statel=="NE"	
replace state=33 if statel=="NH"	
replace state=34 if statel=="NJ"	
replace state=35 if statel=="NM"	
replace state=32 if statel=="NV"	
replace state=36 if statel=="NY"	
replace state=39 if statel=="OH"	
replace state=40 if statel=="OK"	
replace state=41 if statel=="OR"	
replace state=42 if statel=="PA"	
replace state=44 if statel=="RI"	
replace state=45 if statel=="SC"	
replace state=46 if statel=="SD"	
replace state=47 if statel=="TN"	
replace state=48 if statel=="TX"	
replace state=49 if statel=="UT"	
replace state=51 if statel=="VA"	
replace state=50 if statel=="VT"	
replace state=53 if statel=="WA"	
replace state=55 if statel=="WI"	
replace state=54 if statel=="WV"	
replace state=56 if statel=="WY"	

////////////////////////////////////////////////////////////////////////////////
// generate unique county fips codes
gen cty=state*1000+county
drop statel county autpsy
rename cty county

////////////////////////////////////////////////////////////////////////////////
// Generate hispanic binary that is consistent
qui replace hispanic=1 if hispanic>=1 & hispanic<=5
qui replace hispanic=0 if hispanic>=6 & hispanic<=9

////////////////////////////////////////////////////////////////////////////////
// place of death variable (other/unknown is reference group)
gen hospin=place==1
gen hospout=place==2
gen hospdoa=place==3
gen home=(place==4 & year>=2003) | (place==6 & year<2003)

////////////////////////////////////////////////////////////////////////////////
// Indicate various types of drug deaths

// Initalize the variables
foreach i in narcotic anyop opioid heroin natop meth synop otopioid cocaine othnarc nonopan sedative benzo othsed psyctrop antidep antipsyc stim unspecif otherd alcohol ethanol {
	gen `i'=0
}

// Replace status based upon diagnoses codes
forval i = 1/20 {
	qui replace narcotic=1 if inrange(substr(rec`i',1,4),"T400","T409")
	qui replace anyop=1 if inrange(substr(rec`i',1,4),"T400","T404") | inrange(substr(rec`i',1,4),"T406","T406")
	qui replace opioid=1 if inrange(substr(rec`i',1,4),"T402","T404")
	qui replace heroin=1 if inrange(substr(rec`i',1,4),"T401","T401")
	qui replace natop=1 if inrange(substr(rec`i',1,4),"T402","T402")	
	qui replace meth=1 if inrange(substr(rec`i',1,4),"T403","T403")
	qui replace synop=1 if inrange(substr(rec`i',1,4),"T404","T404")	
	qui replace otopioid=1 if inrange(substr(rec`i',1,4),"T402","T402") | inrange(substr(rec`i',1,4),"T404","T404")
	qui replace cocaine=1 if inrange(substr(rec`i',1,4),"T405","T405")
	qui replace othnarc=1 if inrange(substr(rec`i',1,4),"T406","T409") | inrange(substr(rec`i',1,4),"T400","T400")
	qui replace nonopan=1 if inrange(substr(rec`i',1,4),"T400","T401") | inrange(substr(rec`i',1,4),"T405","T409")
	qui replace sedative=1 if inrange(substr(rec`i',1,4),"T420","T428")
	qui replace benzo=1 if inrange(substr(rec`i',1,4),"T424","T424")
	qui replace othsed=1 if inrange(substr(rec`i',1,4),"T420","T423") | inrange(substr(rec`i',1,4),"T425","T428")
	qui replace psyctrop=1 if inrange(substr(rec`i',1,4),"T430","T439")
	qui replace antidep=1 if inrange(substr(rec`i',1,4),"T430","T432")
	qui replace antipsyc=1 if inrange(substr(rec`i',1,4),"T433","T435")
	qui replace stim=1 if inrange(substr(rec`i',1,4),"T436","T436")
	qui replace unspecif=1 if inrange(substr(rec`i',1,4),"T509","T509")
	qui replace otherd=1 if inrange(substr(rec`i',1,4),"T4360","T389") | inrange(substr(rec`i',1,4),"T410","T419") | inrange(substr(rec`i',1,4),"T440","T487") | inrange(substr(rec`i',1,4),"T490","T508") 
	qui replace alcohol=1 if inrange(substr(rec`i',1,4),"T510","T514") 
	qui replace ethanol=1 if inrange(substr(rec`i',1,4),"T510","T510") 
}


// Exclusive Use
gen oponly=(opioid==1 & nonopan==0 & sedative==0 & psyctrop==0 & unspecif==0 & otherd==0)
gen nonoonly=(opioid==0 & nonopan==1 & sedative==0 & psyctrop==0 & unspecif==0 & otherd==0)
gen sedonly=(opioid==0 & nonopan==0 & sedative==1 & psyctrop==0 & unspecif==0 & otherd==0)
gen psyconly=(opioid==0 & nonopan==0 & sedative==0 & psyctrop==1 & unspecif==0 & otherd==0)
gen otonly=(opioid==0 & nonopan==0 & sedative==0 & psyctrop==0 & unspecif==0 & otherd==1)
gen unonly=(opioid==0 & nonopan==0 & sedative==0 & psyctrop==0 & unspecif==1 & otherd==0)
gen heronly=(heroin==1 & opioid==0 & cocaine==0 & othnarc==0 & sedative==0 & psyctrop==0 & unspecif==0 & otherd==0)
gen coconly=(cocaine==1 & opioid==0 & heroin==0 & othnarc==0 & sedative==0 & psyctrop==0 & unspecif==0 & otherd==0)
gen methonly=(meth==1 & otopioid==0 & nonopan==0 & sedative==0 & psyctrop==0 & unspecif==0 & otherd==0)
gen otoponly=(otopioid==1 & meth==0 & nonopan==0 & sedative==0 & psyctrop==0 & unspecif==0 & otherd==0)
gen antidonly=(opioid==0 & nonopan==0 & sedative==0 & antidep==1 & antipsyc==0 & stim==0 & unspecif==0 & otherd==0)
gen antiponly=(opioid==0 & nonopan==0 & sedative==0 & antidep==0 & antipsyc==1 & stim==0 & unspecif==0 & otherd==0)
gen stimonly=(opioid==0 & nonopan==0 & sedative==0 & antidep==0 & antipsyc==0 & stim==1 & unspecif==0 & otherd==0)

// Underlying Causes of Death
gen tot=1
gen veh=recode113==114

* Poisoning includes Y35.2 (legal intervention/war, approx n=2) & theoretically *U01.6, *U01.7 (homicide), which is never observed
gen pois=inrange(substr(icd10,1,3),"X40","X49") | inrange(substr(icd10,1,3),"X60","X69") | inrange(substr(icd10,1,3),"X85","X90")  | inrange(substr(icd10,1,3),"Y10","Y19") | icd10=="Y352"
gen poisacc=inrange(substr(icd10,1,3),"X40","X49")
gen poisint=inrange(substr(icd10,1,3),"X60","X69")
gen poishom=inrange(substr(icd10,1,3),"X85","X90")
gen poisund=inrange(substr(icd10,1,3),"Y10","Y19")
gen drug=inrange(substr(icd10,1,3),"X40","X44") | inrange(substr(icd10,1,3),"X60","X64") | icd10=="X85" | inrange(substr(icd10,1,3),"Y10","Y14") | icd10=="Y352"
gen drugun=icd10=="Y352"
gen drugacc=inrange(substr(icd10,1,3),"X40","X44")
gen drugint=inrange(substr(icd10,1,3),"X60","X64")
gen drughom=icd10=="X85"
gen drugund=inrange(substr(icd10,1,3),"Y10","Y14")

* sedative/stimulant/nervous system/pain: antiepileptic, sedative-hypnotic, antiparkinsonism, psychotropic (nec) [includes: antidepressants, barbiturates, hydantoin (anticonvulsants), iminostilbenes, methaqualone, neuroleptics, stimulants, succinimides/oxazolidinediones (anticolvulsants), tranquillizers], drugs acting on autonomic nervous system; nonopioid analgesics, antipyretics, antirheumatics (all analgesics)
gen sed=(icd10=="X40" | icd10=="X41" | icd10=="X43"  | icd10=="X60" | icd10=="X61" | icd10=="X63"| icd10=="Y10" | icd10=="Y11" | icd10=="Y13")
* narcotic poisoning: narcotics & psychodysleptics (hallucinogens). includes: cannabis, cocaine, codeine, heroin, LSD, mescaline, methadone, morphine, opium 
gen narc=(icd10=="X42" | icd10=="X62" | icd10=="Y12")
* other drugs: includes drugs acting on: smooth/skeletal muscles, anaesthetics (general & local), respiratory/cardiovascular/GI systems, hormones, haematoligical agents, systematic antibiotics/anti-infectives, therapeutic gases, topical preparations, vaccines, mineral/uric acide metabolism
gen odrug=(icd10=="X44" | icd10=="X64" | icd10=="Y14")
gen alc=(icd10=="X45" | icd10=="X65" | icd10=="Y15")
gen gas=(icd10=="X47" | icd10=="X67" | icd10=="X88" | icd10=="Y17")
gen opois=(icd10=="X46" | icd10=="X48" | icd10=="X49" | icd10=="X66" | icd10=="X68" | icd10=="X69" | icd10=="X86" | icd10=="X88" | icd10=="X89"| icd10=="X90"| icd10=="Y16" | icd10=="Y18" | icd10=="Y19")
gen psactive=inrange(substr(icd10,1,3),"F11","F16")

////////////////////////////////////////////////////////////////////////////////
// Label variables
label var year "year"
label variable month "month of death"
label var day "day of death (1=sunday, 7=saturday)"
label var age "age (years)"
label var female "female (dv)"
label var black "black (dv)"
label var othrace "other nonwhite (dv)"
label var hispanic "Hispanic (dv)"
label var married "currently married (dv)"
label var autopsy "autopsy performed (dv), >=2003"

label var hsdrop "<high school graduate (dv)"
label var hsgrad "high school graduate (dv)"
label var somecol "some college (dv)"
label var colgrad "college graduate (dv)"
label var state "state of residence (fips code)"
label var county "county of residence (fips code)"
label var icd10 "underlying cause of death: icd10 code"
label var recode113 "underlying cause of death: 113 cause recode"
label var numcond "# of record-axis conditions"

label var hospin "died hospital, inpatient (dv)"
label var hospout"died hospital, outpatent/ER (dv)"
label var hospdoa"died hospital, DOA (dv)"
label var home "died at home (dv)"

label var tot "total deaths"
label var veh "vehicle deaths (UCL)"
label var pois "poisoning deaths (UCL)"
label var poisacc "accidental poisoning deaths (UCL)"
label var poisint "intentional poisoning deaths (UCL)"
label var poishom "homicide poisoning deaths (UCL)"
label var poisund "undetermined poisoning deaths (UCL)"
label var drug "unusual drug poisoning (T35.2), probably delete"
label var drugun "drug poisoning deaths (UCL)"
label var drugacc "accidental drug poisoning deaths (UCL)"
label var drugint "intentional drug poisoning deaths (UCL)"
label var drughom "homicide drug poisoning deaths (UCL)"
label var drugund "undetermined drug poisoning deaths (UCL)"
label var narc "narcotic poisoning deaths (UCL)"
label var sed "pain/psych/nerv poisoning deaths (UCL)"
label var odrug "other drug poisoning deaths (UCL)"
label var alc "alcohol poisoning deaths (UCL)"
label var gas "gas/vapours poisoning (UCL)"
label var opois "other poisoning: not drug, alcohol or gas (UCL))"
label var psactive "# mental/behavior disorders due to drugs (UCL)"

label var narcotic "narcotics/hallucinogens (T40.0-40.9)"
label var anyop "all types of opioids (T40.0-T40.6)"
label var heroin "heroin (T40.1)"
label var opioid "opioid analgesics (T40.2-40.4)"
label var natop "natural/semisynthetic opioids (oxycodone/hydrocodone) (T40.2)"
label var meth "methadone (T40.3)"
label var synop "synthetic opioids (fentanyl/tramadol) (T40.4)"
label var otopioid "opioid analgesics, non-methadone (T40.2, T40.4)"
label var cocaine "cocaine (T40.5-40.5)"
label var othnarc "other narcotic, cannabis, LSD, etc. (T40.0, T40.6-40.9)"
label var nonopan "non-opioid analg. narcotics (T40.0-40.1, T40.5-40.9)"
label var sedative "antiepileptic, sedative, antiparkinsonism (T42.0-42.8)"
label var benzo "benzodiazepines (T42.4)"
label var othsed "other sedatives (T42.0-42.3, T42.5-42.8)"
label var psyctrop "psychotropic drugs (T43.0-43.9)"
label var antidep "antidepressants (T43.0-43.2)"
label var antipsyc "antipsychotics (T43.3-43.5)"
label var stim "psychostimulants (T43.6)"
label var unspecif "unspecified drugs (T50.9)"
label var otherd "other drugs (T36.0-38.9, T41.0-41.9, T44.0-48.7, T49.0-50.8)"
label var alcohol "alcohol (T51.0-51.4)"
label var ethanol "ethanol (T51.1)"

label var oponly "prescription opioids analgesics only"
label var nonoonly "non-opioid analg. narcotics only"
label var sedonly "sedatives only"
label var psyconly "psychotropics only"
label var otonly "other drugs only"
label var unonly "unspecified drugs only"
label var heronly "heroin only"
label var coconly "cocaine only"
label var methonly "methadone only"
label var otoponly "prescr opioid analgesics (nonmethadone) only"
label var antidonly "antidepressants only"
label var antiponly "antipsychotics only"
label var stimonly "psychostimulants only"

drop rec* place

////////////////////////////////////////////////////////////////////////////////
// Add indicators for state/county specified & unspecified DM rates
egen nodiag=mean(unonly) if drug==1, by(state year)
gen diag=1-nodiag
drop nodiag
label var diag "specified drug diagnosis: state average"

egen nodiagc=mean(unonly) if drug==1, by(county year)
gen diagcty=1-nodiagc
drop nodiagc
label var diagcty "specified drug diagnosis: county average"

egen undiag=mean(unspecif) if drug==1, by(state year)
label var undiag "any unspecified drug diagnosis: state average"

egen undiagcty=mean(unspecif) if drug==1, by(county year)
label var undiagcty "any unspecified drug diagnosis: county average"

////////////////////////////////////////////////////////////////////////////////
// Compress and save 
quietly compress
save "$raw_data_res_mort_path/mcod1", replace

////////////////////////////////////////////////////////////////////////////////
// Remove intermediate files used for creation
erase "$raw_data_res_mort_path/mcod1999"
foreach x in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 {
	erase "$raw_data_res_mort_path/mcod20`x'"
}

////////////////////////////////////////////////////////////////////////////////
// Open main death file
use "$raw_data_res_mort_path/mcod1.dta", clear

////////////////////////////////////////////////////////////////////////////////
* keep drug poisoning deaths only
keep if drug==1 & year<=2014

////////////////////////////////////////////////////////////////////////////////
* add census division indicator
qui gen census=1 if state==9 | state==23 | state==25 | state==33 | state==44 | state==50
qui replace census=2 if state==34 | state==36 | state==42
qui replace census=3 if state==17 | state==18 | state==26 | state==39 | state==55
qui replace census=4 if state==19 | state==20 | state==27 | state==29 | state==31 | state==38 | state==46
qui replace census=5 if state==10 | state==11 | state==12 | state==13 | state==24 | state==37 | state==45 | state==51 | state==54
qui replace census=6 if state==1 | state==21 | state==28 | state==47
qui replace census=7 if state==5 | state==22 | state==40 | state==48
qui replace census=8 if state==4 | state==8 | state==16 | state==30 | state==32 | state==35 | state==49 | state==56
qui replace census=9 if state==2 | state==6 | state==15 | state==41 | state==53

label define census 1 "New England" 2 "Mid-Atlantic" 3 "EN Central" 4 "WN Central" 5 "South Atlantic" 6 "ES Central" 7 "WS Central" 8 "Mountain" 9 "Pacific"

label values census census
label var census "census division"

////////////////////////////////////////////////////////////////////////////////
// create a macro of variables that will be used later
macro define demogi "i.female i.black i.othrace i.hispanic i.married i.hsdrop i.hsgrad i.somecol i.colgrad"

////////////////////////////////////////////////////////////////////////////////
// create an age category group indicator and dummy variables for each 
qui gen agecat=recode(age,20,30,40,50,60,70,80,81)
qui replace agecat=99 if agecat==.

qui tab agecat, gen(ages)   
macro define demog "female black othrace hispanic married hsdrop hsgrad somecol colgrad ages1 ages2 ages3 ages4 ages5 ages6 ages7 ages8 ages9"

////////////////////////////////////////////////////////////////////////////////
// Initialize opioid indicator variables for later

gen popioid=.
gen pheroin=.
gen aopioid=opioid
gen aheroin=heroin	

// opioid & heroin combination use
gen comb=(opioid==1 & heroin==1)

gen acomb=comb	

gen diagcty2=diagcty
	
////////////////////////////////////////////////////////////////////////////////
// Run probit analysis 

// Run probit model for opioid analgesics
forvalues i = 1999/2014 {
	qui probit opioid diagcty $demogi i.agecat i.day i.census if year==`i'
	qui replace diagcty=1
	qui predict popioidx`i' if year==`i'
	qui replace diagcty=diagcty2
	qui replace popioid=popioidx`i' if year==`i'

	qui probit opioid $demogi i.agecat i.day i.state if unonly==0 & year==`i'
	qui predict aopioidx`i' if year==`i'
	qui replace aopioid=aopioidx`i' if unonly==1 & aopioidx`i'~=.	
}

// Take 100 draws from the a binomial with p equal to the probit coef. to capture uncertainty around probit prediction
forval j = 1/100 {
	gen aopioid_version_`j' = rbinomial(1,aopioid)
	replace aopioid_version_`j' = opioid if missing(aopioid_version_`j')
}

// Run probit model for heroin
forvalues i = 1999/2014 {
	qui probit heroin diagcty $demogi i.agecat i.day i.census if year==`i'
	qui replace diagcty=1
	qui predict pheroinx`i' if year==`i'
	qui replace diagcty=diagcty2
	qui replace pheroin=pheroinx`i' if year==`i'

	qui probit heroin $demogi i.agecat i.day i.state if unonly==0 & year==`i'
	qui predict aheroinx`i' if year==`i'
	qui replace aheroin=aheroinx`i' if unonly==1 & aheroinx`i'~=.
}

// Take 100 draws from the a binomial with p equal to the probit coef. to capture uncertainty around probit prediction
forval j = 1/100 {
	gen aheroin_version_`j' = rbinomial(1,aheroin)
	replace aheroin_version_`j' = heroin if missing(aheroin_version_`j')
}

// Run probit model for combination
forvalues i = 1999/2014 {
	qui probit acomb $demogi i.agecat i.day i.state if unonly==0 & year==`i'
	qui predict acombx`i' if year==`i'
	qui replace acomb=acombx`i' if unonly==1 & acombx`i'~=.
}

// Take 100 draws from the a binomial with p equal to the probit coef. to capture uncertainty around probit prediction
forval j = 1/100 {
	gen acomb_version_`j' = rbinomial(1,acomb)
	replace acomb_version_`j' = acomb if missing(acomb_version_`j')
}

// Drop the variables used in the construction of the above
drop popioidx* pheroinx* aopioidx* aheroinx* acombx*

// Create a white, black, and hispanic version of each 
ds *_version_*

foreach i in drug opioid heroin popioid pheroin aopioid aheroin acomb {
	qui gen `i'w=`i' if black==0 & othrace==0 & hispanic==0
	qui gen `i'b=`i' if black==1 & hispanic==0
	qui gen `i'h=`i' if hispanic==1
}

forval j = 1/100 {
	foreach i in aopioid aheroin acomb {
		qui gen `i'w_version_`j'=`i'_version_`j' if black==0 & othrace==0 & hispanic==0
		qui gen `i'b_version_`j'=`i'_version_`j' if black==1 & hispanic==0
		qui gen `i'h_version_`j'=`i'_version_`j' if hispanic==1
	}
}
////////////////////////////////////////////////////////////////////////////////
// Sort the data
sort county year

////////////////////////////////////////////////////////////////////////////////
// Collapse at the county-year level
collapse (sum) drug* opioid* heroin* popioid* pheroin* aopioid aopioidw aopioidb aopioidh aheroin aheroinw aheroinb aheroinh acomb acombw acombb acombh unonly *_version_*, by(county year) fast

////////////////////////////////////////////////////////////////////////////////
// replace with zero rates if no drug deaths in county
replace drug=0 if drug==.

foreach i in w b h {
	replace drug`i'=0 if drug`i'==. & pop`i'~=.
}

foreach i in opioid heroin popioid pheroin opioidw heroinw popioidw pheroinw opioidb heroinb popioidb pheroinb opioidh heroinh popioidh pheroinh aopioid aheroin acomb aopioidw aheroinw acombw aopioidb aheroinb acombb aopioidh aheroinh acombh {
	qui replace `i'=0 if drug==0
}

foreach j in aopioid aheroin acomb {
	forval i=1/100 {
		qui replace `j'_version_`i'=0 if drug==0
	}
}

forval i=1/100 {
	qui replace aopioidw_version_`i'=0 if drug==0
	qui replace aopioidb_version_`i'=0 if drug==0
	qui replace aopioidh_version_`i'=0 if drug==0
}

forval i=1/100 {
	qui replace aheroinw_version_`i'=0 if drug==0
	qui replace aheroinb_version_`i'=0 if drug==0
	qui replace aheroinh_version_`i'=0 if drug==0
}

forval i=1/100 {
	qui replace acombw_version_`i'=0 if drug==0
	qui replace acombb_version_`i'=0 if drug==0
	qui replace acombh_version_`i'=0 if drug==0
}

////////////////////////////////////////////////////////////////////////////////
// Merge with the population data
merge 1:1 county year using "$data_path/county_pop_age_race_1990_2014.dta"
drop _merge

// Drop if missing population
drop if pop==.

////////////////////////////////////////////////////////////////////////////////
// Generate death rate per 100k for each group and drug type
ds aopioid_* aheroin_* acomb_*

foreach i in `r(varlist)' {
qui gen r_`i'=`i'*100000/pop
}

foreach i in drug opioid heroin popioid pheroin  unonly aopioid aheroin acomb {
qui gen `i'r=`i'*100000/pop
}

ds aopioidw_* aheroinw_* acombw_*

foreach i in  `r(varlist)'  {
	qui gen r_`i'=`i'*100000/popw
}

foreach i in drugw opioidw heroinw popioidw pheroinw  aopioidw aheroinw acombw  {
	qui gen `i'r=`i'*100000/popw
}


ds aopioidb_* aheroinb_* acombb_*

foreach i in  `r(varlist)'  {
	qui gen r_`i'=`i'*100000/popb
}

foreach i in drugb opioidb heroinb popioidb pheroinb  aopioidb aheroinb acombb  {
	qui gen `i'r=`i'*100000/popb
}
ds aopioidh_* aheroinh_* acombh_*

foreach i in  `r(varlist)'  {
	qui gen r_`i'=`i'*100000/poph
}

foreach i in drugh opioidh heroinh popioidh pheroinh   aopioidh aheroinh acombh  {
	qui gen `i'r=`i'*100000/poph
}

////////////////////////////////////////////////////////////////////////////////
// label variables again (labels were lost after the collapse)

label var drugr "drug poisoning death rate per 100,000"
label var opioidr "reported opioid death rate 100,000"
label var heroinr "reported heroin death rate 100,000"
label var popioidr "adjusted opioid death rate 100,000"
label var pheroinr "adjusted heroin death rate 100,000"
label var aopioidr "opioid death rate 100,000 w/imputations"
label var aheroinr "heroin death rate 100,000 w/imputations"
label var acombr "opioid & heroin combination death rate 100,000 w/imputations"
label var unonlyr "unspecified (only) death rate 100,000"

label var drugwr "drug poisoning death rate per 100,000: non-Hispanic whites"
label var opioidwr "reported opioid death rate 100,000: non-Hispanic whites"
label var heroinwr "reported heroin death rate 100,000: non-Hispanic whites"
label var popioidwr "adjusted opioid death rate 100,000: non-Hispanic whites"
label var pheroinwr "adjusted heroin death rate 100,000: non-Hispanic whites"
label var aopioidwr "opioid death rate 100,000 w/imputations: non-Hispanic whites"
label var aheroinwr "heroin death rate 100,000 w/imputations: non-Hispanic whites"

label var drugbr "drug poisoning death rate per 100,000: non-Hispanic blacks"
label var opioidbr "reported opioid death rate 100,000: non-Hispanic blacks"
label var heroinbr "reported heroin death rate 100,000: non-Hispanic blacks"
label var popioidbr "adjusted opioid death rate 100,000: non-Hispanic blacks"
label var pheroinbr "adjusted heroin death rate 100,000: non-Hispanic blacks"
label var aopioidbr "opioid death rate 100,000 w/imputations: non-Hispanic blacks"
label var aheroinbr "heroin death rate 100,000 w/imputations: non-Hispanic blacks"

label var drughr "drug poisoning death rate per 100,000: Hispanics"
label var opioidhr "reported opioid death rate 100,000: Hispanics"
label var heroinhr "reported heroin death rate 100,000: Hispanics"
label var popioidhr "adjusted opioid death rate 100,000: Hispanics"
label var pheroinhr "adjusted heroin death rate 100,000: Hispanics"
label var aopioidhr "opioid death rate 100,000 w/imputations: Hispanics"
label var aheroinhr "heroin death rate 100,000 w/imputations: Hispanics"

label var pop "county population"
label var popw "county population: non-Hispanic Whites"
label var popb "county population: non-Hispanic Blacks"
label var poph "county population: Hispanics"


////////////////////////////////////////////////////////////////////////////////
// Generate one last variable. The non-opioid and non-opioid/non-heroin drug death rate
gen anoopr=drugr-aopioidr
gen anoopher=drugr-aopioidr-aheroinr+acombr

label var anoopr "non-opioid drug death rate 100,000 w/imputations"
label var anoopher "non-opioid or heroin drug death rate 100,000 w/imputations"

////////////////////////////////////////////////////////////////////////////////
// Compress and save
compress
save "$raw_data_res_mort_path/drug_mortality_county_year.dta", replace
