clear all
import excel "$raw_data_path/median_income_state.xls", sheet("h08") cellrange(A4:BM115) firstrow clear
keep  CURRENTDOLLARS B  D  F  H  J  L  N  P  R  T  V  X  Z  AB  AD  AF  AH  AJ  AL  AN  AP  AR  AT  AV  AX  AZ  BB  BD  BF  BH  BJ  BL 

ds CURRENTDOLLARS, not


foreach var in `r(varlist)'{
		replace `var' = trim(`var')
		replace  `var' = subinstr(`var',"(","_",.)
		replace  `var' = subinstr(`var',")","_",.)
		replace  `var' = subinstr(`var'," ","_",.)
		rename `var' median_`=`var'[1]'

}

drop median_2013__38_
ds CURRENTDOLLARS, not

foreach var in `r(varlist)'{

		local new = substr("`var'", 1, 11)
		rename `var' `new'
		
		}
		
		drop in  1/3
		drop in  107/108
		keep in 1/51
rename CURRENTDOLLARS state

reshape long median_@, i(state) j(year) string
rename median_ median_income
destring median_income, replace
destring year, replace
replace state=trim(state)

gen state_name=strupper(state)
gen state_code=""

replace state_code ="AK" if state_name=="ALASKA"
replace state_code ="AL" if state_name=="ALABAMA"
replace state_code ="AR" if state_name=="ARKANSAS"
replace state_code ="AS" if state_name=="AMERICAN SAMOA"
replace state_code ="AZ" if state_name=="ARIZONA"
replace state_code ="CA" if state_name=="CALIFORNIA"
replace state_code ="CO" if state_name=="COLORADO"
replace state_code ="CT" if state_name=="CONNECTICUT"
replace state_code ="DC" if state_name=="DISTRICT OF COLUMBIA"
replace state_code ="DC" if state_name=="D.C."
replace state_code ="DE" if state_name=="DELAWARE"
replace state_code ="FL" if state_name=="FLORIDA"
replace state_code ="GA" if state_name=="GEORGIA"
replace state_code ="GU" if state_name=="GUAM"
replace state_code ="HI" if state_name=="HAWAII"
replace state_code ="IA" if state_name=="IOWA"
replace state_code ="ID" if state_name=="IDAHO"
replace state_code ="IL" if state_name=="ILLINOIS"
replace state_code ="IN" if state_name=="INDIANA"
replace state_code ="KS" if state_name=="KANSAS"
replace state_code ="KY" if state_name=="KENTUCKY"
replace state_code ="LA" if state_name=="LOUISIANA"
replace state_code ="MA" if state_name=="MASSACHUSETTS"
replace state_code ="MD" if state_name=="MARYLAND"
replace state_code ="ME" if state_name=="MAINE"
replace state_code ="MI" if state_name=="MICHIGAN"
replace state_code ="MN" if state_name=="MINNESOTA"
replace state_code ="MO" if state_name=="MISSOURI"
replace state_code ="MS" if state_name=="MISSISSIPPI"
replace state_code ="MT" if state_name=="MONTANA"
replace state_code ="NC" if state_name=="NORTH CAROLINA"
replace state_code ="ND" if state_name=="NORTH DAKOTA"
replace state_code ="NE" if state_name=="NEBRASKA"
replace state_code ="NH" if state_name=="NEW HAMPSHIRE"
replace state_code ="NJ" if state_name=="NEW JERSEY"
replace state_code ="NM" if state_name=="NEW MEXICO"
replace state_code ="NV" if state_name=="NEVADA"
replace state_code ="NY" if state_name=="NEW YORK"
replace state_code ="OH" if state_name=="OHIO"
replace state_code ="OK" if state_name=="OKLAHOMA"
replace state_code ="OR" if state_name=="OREGON"
replace state_code ="PA" if state_name=="PENNSYLVANIA"
replace state_code ="PR" if state_name=="PUERTO RICO"
replace state_code ="RI" if state_name=="RHODE ISLAND"
replace state_code ="SC" if state_name=="SOUTH CAROLINA"
replace state_code ="SD" if state_name=="SOUTH DAKOTA"
replace state_code ="TN" if state_name=="TENNESSEE"
replace state_code ="TX" if state_name=="TEXAS"
replace state_code ="UT" if state_name=="UTAH"
replace state_code ="VA" if state_name=="VIRGINIA"
replace state_code ="VI" if state_name=="VIRGIN ISLANDS"
replace state_code ="VT" if state_name=="VERMONT"
replace state_code ="WA" if state_name=="WASHINGTON"
replace state_code ="WI" if state_name=="WISCONSIN"
replace state_code ="WV" if state_name=="WEST VIRGINIA"
replace state_code ="WY" if state_name=="WYOMING"

drop state
rename state_code state

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

drop state_name state

save "$data_path/state_median_income.dta", replace
