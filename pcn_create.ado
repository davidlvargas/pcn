/*==================================================
project:       Create text file and other povcalnet files
Author:        R.Andres Castaneda Aguilar 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     9 Aug 2019 - 08:51:26
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_create, rclass   
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
countries(string)               ///
Years(numlist)                 ///
maindir(string)               ///
type(string)                  ///
survey(string)                ///
replace                       ///
vermast(string)               ///
veralt(string)                ///
MODule(string)                ///
clear                         ///
pause                         ///
*                             ///
] 

version 15

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


* ---- Initial parameters

local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY  
local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS  
local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS  
local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time' 
local datetimeHRF = trim("`datetimeHRF'")	
local user=c(username) 



/*==================================================
1: primus query
==================================================*/
qui pcn_primus_query, countries(`countries') years(`years') ///
`pause' vermast("`vermast'") veralt("`veralt'") 

local varlist = "`r(varlist)'"
local n = _N

/*==================================================
2:  Loop over surveys
==================================================*/
mata: P  = J(0,0, .z)   // matrix with information about each survey
local i = 0
local previous ""
while (`i' < `n') {
	local ++i
	
	mata: pcn_ind(R)
	
	if ("`previous'" == "`country'-`year'") continue
	else local previous "`country'-`year'"
	
	
	*--------------------2.2: Load data
	cap noi pcn_load, country(`country') year(`year') type(`type') /*
	*/ maindir("`maindir'") vermast(`vermast') veralt(`veralt')  /*
	*/ survey("`survey'") `pause' `clear' `options'
	
	if (_rc) continue
	
	local filename = "`r(filename)'"
	local survin   = "`r(survin)'"
	local survid   = "`r(survid)'"
	local surdir   = "`r(surdir)'"
	return add
	
	*--------Create folders
	cap mkdir "`surdir'/`survin'PCN"
	cap mkdir "`surdir'/`survin'PCN/Data"
	
	/*==================================================
	3:  Clear and save data
	==================================================*/
	*----------1.1: clean weight variable
	
	cap confirm var weight, exact 
	if (_rc) {
		cap confirm var weight_p, exact 
		if (_rc == 0) rename weight_p weight
		else {
			cap confirm var weight_h, exact 
			if (_rc == 0) rename weight_h weight
			else {
				noi disp in red "no weight variable found for country(`country') year(`year') veralt(`veralt') "
				continue
			}
		}
	}
	
	
	* make sure no information is lost
	svyset, clear
	recast double welfare
	recast double weight    
	
	* monthly data
	quietly replace welfare=welfare/12
	
	* keep weight and welfare
	keep weight welfare
	sort welfare
	
	* drop missing values
	quietly drop if welfare < 0 | welfare == .
	quietly drop if weight <= 0 | weight == .
	
	order weight welfare
	
	//------------Uncollapsed data
	saveold "`surdir'/`survin'PCN/Data/`survin'.dta", `replace'
	
	export delimited using "`surdir'/`survin'PCN/Data/`country'`year'.txt", ///
	novarnames nolabel delimiter(tab) `replace'
	
	
	//------------ collapse data
	collapse (sum) weight, by(welfare)
	
	saveold "`surdir'/`survin'PCN/Data/`survin'collapsed.dta", `replace'
	
	export delimited using "`surdir'/`survin'PCN/Data/`country'`year'_collapsed.txt", ///
	novarnames nolabel delimiter(tab) `replace'
	
	* mata: P = pcn_info(P)
	
} // end of while 

end


/*====================================================================
Mata functions
====================================================================*/

findfile "pcn_functions.mata"
include "`r(fn)'"


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


