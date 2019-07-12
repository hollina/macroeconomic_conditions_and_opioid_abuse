# Replication code for "Macroeconomic conditions and opioid abuse"

<img align="right" width="330" src="https://www.nber.org/aginghealth/2017no3/w23192.jpg">

This repository contains code and data to replicate the results of:

Hollingsworth, A., Ruhm, C. J., & Simon, K. (2017). Macroeconomic Conditions and Opioid Abuse. Journal of Health Economics, 56, 222–233. <https://doi.org/10.1016/j.jhealeco.2017.07.009>

An earlier version of the paper was released as NBER Working Paper No. 23192, <https://www.nber.org/papers/w23192>.

A non-technical summary of this paper is available via the 2017 NBER Bulletin on Aging and Health 2017, Number 3 at <https://www.nber.org/aginghealth/2017no3/w23192.shtml>. Source of image-->



**Abstract**: We examine how deaths and emergency department (ED) visits related to use of opioid analgesics (opioids) and other drugs vary with macroeconomic conditions. As the county unemployment rate increases by one percentage point, the opioid death rate per 100,000 rises by 0.19 (3.6%) and the opioid overdose ED visit rate per 100,000 increases by 0.95 (7.0%). Macroeconomic shocks also increase the overall drug death rate, but this increase is driven by rising opioid deaths. Our findings hold when performing a state- level analysis, rather than county-level; are primarily driven by adverse events among whites; and are stable across time periods.

## Replication Code:
The entire project can be recreated by running:

	~/do_files/0.master_script.do

The do files within  the directory `~/do_files/1.build_datasets_for_analysis` build the datasets used in the analysis. 
The do files within`~/do_files/2.analysis/` reconstruct all figures and tables used in the paper and appendix.

On lines 48 and 49 of 0.master_script.do, you will need to change your folder locations on your own machine, identifying the project folder path and the location of the restricted access data (not provided here). 

Note that `$box` is a global macro I store in my profile.do. The profile.do is loaded each time stata is started and allows for one do file to be run across multiple machines with no additional editing. For example: 

Global macros for unified coding. 
	Throughout the do files you'll notice that my files often start with `"$box/`

On my mac, my profile.do has two commands:

	global google "/Users/hollinal/Google Drive/"
	global box "/Users/hollinal/Box Sync/"

On my PC, my profile.do has two commands:
	
	global google "C:/hollinal/Google Drive/"
	global box "C:/Users/hollinal/Box Sync/"

Thus I can use the exact same code on every machine as it can fix the differences. 

More info about profile.do : http://www.stata.com/support/faqs/programming/profile-do-file/ 


## Raw Data:
All publicly available raw data are kept in a series of zipped folders within the zipped raw_data directory. 

The restricted access mortality data can be obtained by submitting a request here <https://www.cdc.gov/nchs/nvss/nvss-restricted-data.htm>. 

The restricted access emergency department data can be obtained by submitting a request here <https://www.hcup-us.ahrq.gov/tech_assist/centdist.jsp>. See Table 1 for the states and years used in this project.


## Software Used:
All analysis were done on unix machines using Stata SE 14.2. We use a number of user-written packages that should be outlined in the `0.master_script.do` file. 

Document compliation was done using Latex. 

## License:
Replication Package (this github repo): [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
