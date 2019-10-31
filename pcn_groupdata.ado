/*==================================================
project:       Create group data files from raw information 
               and update master file with means
Author:        R.Andres Castaneda Aguilar 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    23 Oct 2019 - 09:04:24
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pcn_groupdata, rclass
syntax anything(name=subcmd id="subcommand"),  ///
[                                         ///
			COUNtries(string)                   ///
			Years(numlist)                      ///
			maindir(string)                     ///
			type(string)                        ///
			clear                               ///
			pause                               ///
			vermast(string)                     ///
			veralt(string)                      ///
			*                                   ///
] 
version 15

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


//------------set up
*##s
if ("`maindir'" == "") cd "p:\01.PovcalNet\03.QA\01.GroupData"
else                   cd "`maindir'"


*------------------ Time and system Parameters ------------
local date      = c(current_date)
local time      = c(current_time)
local datetime  = clock("`date'`time'", "DMYhms")   // number, not date
local user      = c(username)
local dirsep    = c(dirsep)
local vintage:  disp %tdD-m-CY date("`c(current_date)'", "DMY")



*------------------ Initial Parameters  ------------------
local mfiles: dir "../../00.Master/02.vintage/" files "Master_*.xlsx", respect
local vcnumbers: subinstr local mfiles "Master_" "", all
local vcnumbers: subinstr local vcnumbers ".xlsx" "", all
local vcnumbers: list sort vcnumbers

mata: VC = strtoreal(tokens(`"`vcnumbers'"')); /* 
	 */ st_local("maxvc", strofreal(max(VC), "%15.0f"))

* exDate = Format(Now(), "yyyymmddHhNnSs") // VBA name


//------------load data
import excel "raw_GroupData.xlsx", sheet("raw_GroupData") firstrow clear
tostring survey, replace  // in case survey is unknown

gen id = countrycode + " " + strofreal(year)  + " " + /* 
*/ strofreal(coverage)  + " " + datatype  + " 0" + /* 
*/ strofreal(formattype) + " " + survey


//------------saving data vintages
levelsof id, local(ids) 

qui foreach id of local ids {
	local cc:  word 1 of `id'
	local yr:  word 2 of `id'
	local cg:  word 3 of `id'
	local dt:  word 4 of `id'
	local ft:  word 5 of `id'
	local sy:  word 6 of `id'
	
	if      (`cg' == 1) local cov = "R"
	else if (`cg' == 2) local cov = "U"
	else if (`cg' == 3) local cov = "N"
	else                local cov = "A"
	
	local l2y = substr("`yr'", 3,.)
	
	if (inlist("`sy'", "", ".")) local sy = "USN" // Unknown Survey Name
	
	//------------Create directories
	local cc = upper("`cc'")
	
	cap mkdir "../../01.Vintage_control/`cc'"
	
	local sydir "../../01.Vintage_control/`cc'/`cc'_`yr'_`sy'"
	cap mkdir "`sydir'"
	
	
	preserve 
	keep if id == "`id'"
	keep weight  welfare 
	
	local signature "`cc'_`yr'_`sy'_PCNGD-`cg'"
	cap datasignature confirm using /* 
	*/ "02.datasignature/`signature'", strict
	local dsrc = _rc
	if (`dsrc' == 601) {
		local fileid "`cc'_`yr'_`sy'_v01_M_v01_A_PCNGD"
	}
	if (`dsrc' == 9) {
		
		local dirs: dir "`sydir'" dirs "*PCNGD", respect
		
		local fe = ""  // file exists
		local va = ""
		foreach dir of local dirs {
			
			if regexm("`dir'", "v([0-9]+)_A") local va = "`va' " + regexs(1)
			
			local exfile: dir "`sydir'/`dir'/Data" files "*PCNGD-`cg'.dta", respect
			if (`"`exfile'"' != "") continue
			else local fe = "`dir'"  // file does not exists
		}
		
		local va: subinstr local va " " ",", all
		local va = "0" + "`va'"
		
		if ("`fe'"  == "") local va = max(`va') + 1
		else               local va = max(`va') 
		
		if length("`va'") == 1 local va = "0"+"`va'"
		local fileid "`cc'_`yr'_`sy'_v01_M_v`va'_A_PCNGD"
	}
	if (`dsrc' != 0) {
		local verid "`sydir'/`fileid'"
		cap mkdir "`verid'"
		cap mkdir "`verid'/Data"
		
		noi datasignature set, reset /* 
		*/ saving("02.datasignature/`signature'", replace)
		
		
		//------------Include Characteristics
		
		local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `datetime'
		local datetimeHRF = trim("`datetimeHRF'")
		
		char _dta[filename]     `fileid'-`cg'.dta
		char _dta[id]           `fileid'
		char _dta[datatype]     `dt'
		char _dta[countrycode]  `cc'
		char _dta[year]         `yr'
		char _dta[coverage]     `cov'
		char _dta[groupdata]     1
		char _dta[formattype]   `ft'
		char _dta[datetime]     `datetime'
		char _dta[datetimeHRF]  `datetimeHRF'
		
		
		save "03.vintage/`signature'_`datetime'.dta", replace
		save "`verid'/Data/`fileid'-`cg'.dta", replace
		
		export delimited using "`verid'/Data/`fileid'-`cg'.txt", ///
		novarnames nolabel delimiter(tab) `replace'
		
		export delimited using "`verid'/Data/`cc'`cov'`l2y'.T`ft'", ///
		novarnames nolabel delimiter(tab) `replace'
		
	}
	else {
		noi disp in y "File " in w "`fileid'-`cg'.dta" in /* 
		*/ y " is up to date."
	}
	
	*get the mean
	sum welfare [w = welfare], meanonly
	local `cc'`yr'`cg'm = r(mean)
	
	restore 
}

//------------ Check both files are in the most recent folder
qui foreach id of local ids {
	local cc:  word 1 of `id'
	local yr:  word 2 of `id'
	local cg:  word 3 of `id'
	local dt:  word 4 of `id'
	local ft:  word 5 of `id'
	local sy:  word 6 of `id'
	
	if      (`cg' == 1) local cov = "R"
	else if (`cg' == 2) local cov = "U"
	else if (`cg' == 3) local cov = "N"
	else                local cov = "A"
	
	local l2y = substr("`yr'", 3,.)
	
	if (inlist("`sy'", "", ".")) local sy = "USN" // Unknown Survey Name
	
	local cc = upper("`cc'")
	local sydir "../../01.Vintage_control/`cc'/`cc'_`yr'_`sy'"
	
	local dirs: dir "`sydir'" dirs "*PCNGD", respect
	
	local fe = ""  // file exists
	local va = ""
	foreach dir of local dirs {
		
		if regexm("`dir'", "v([0-9]+)_A") local va = "`va' " + regexs(1)
		
		local exfile: dir "`sydir'/`dir'/Data" files "*PCNGD-`cg'.dta", respect
		if (`"`exfile'"' != "") continue
		else local fe = "`dir'"  // file does not exists
	}
	
	if ("`fe'" != "") {
	
		local mfiles: dir "03.vintage" files "`signature'*.dta", respect
		disp `"`mfiles'"'
		local vcs: subinstr local mfiles "`signature'_" "", all
		local vcs: subinstr local vcs ".dta" "", all
		local vcs: list sort vcs
		disp `"`vcs'"'
		
		mata: VC = strtoreal(tokens(`"`vcs'"'));  /* 
		*/	  st_local("mvc", strofreal(max(VC), "%15.0f"))
		
		copy "03.vintage/`signature'_`mvc'.dta" "`sydir'/`fe'/Data/`fe'-`cg'.dta"
		
		use "`sydir'/`fe'/Data/`fe'-`cg'.dta", clear
		
		local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `datetime'
		local datetimeHRF = trim("`datetimeHRF'")
		
		char _dta[filename]     `fe'-`cg'.dta
		char _dta[id]           `fe'
		char _dta[datetime]     `datetime'
		char _dta[datetimeHRF]  `datetimeHRF'

		save, replace
		
		export delimited using "`sydir'/`fe'/Data/`fileid'-`cg'.txt", ///
		novarnames nolabel delimiter(tab) `replace'
		
		export delimited using "`sydir'/`fe'/Data/`cc'`cov'`l2y'.T`ft'", ///
		novarnames nolabel delimiter(tab) `replace'
	
	}
	
}

//========================================================
//  Update mean in the Master file
//========================================================



drop _all
local nid: word count `ids' 
set obs `nid'

gen Region                = ""
gen countryName           = ""
gen Coverage              = ""
gen CountryCode           = ""
gen SurveyTime            = .
gen CPI_Time              = .
gen DataType              = ""
gen SurveyMean_LCU        = .
gen currency              = .
gen source                = ""
gen SurveyID              = ""
gen SurveyMean_PPP        = .
gen DistributionFileName  = ""


local i = 0
foreach id of local ids {
	local ++i 
	
	local cc:  word 1 of `id'
	local yr:  word 2 of `id'
	local cg:  word 3 of `id'
	local dt:  word 4 of `id'
	local ft:  word 5 of `id'
	
	
	loca incond "in `i'"
	
	replace CountryCode = "`cc'"  `incond'
	replace CPI_Time = `yr'       `incond'
	replace SurveyTime = `yr'     `incond'
	
	if      (`cg' == 1) {
		replace Coverage = "Rural"  `incond'
		local cov = "R"
	}
	else if (`cg' == 2) {
		replace Coverage = "Urban"  `incond'
		local cov = "U"
	}
	else if (`cg' == 3) {
		replace Coverage = "National"  `incond'
		local cov = "N"
	}
	else               {
		replace Coverage = "Aggregated"  `incond'
		local cov = "A"
	}
	
	
	* replace currency = `currency'
	* replace source   = "`source'"
	
	if (upper("`dt'") == "C") local idt = "X"
	if (upper("`dt'") == "Y") local idt = "Y"
	replace DataType = "`idt'"  `incond'
	
	replace SurveyID = "`cc'`cov'`yr'`idt'" `incond'
	
	replace SurveyMean_LCU = ``cc'`yr'`cg'm' `incond'
	
	local l2y = substr("`yr'", 3,.)
	replace DistributionFileName = "`cc'`cov'`l2y'.T`ft'"  `incond'
	
}


tempfile tf
save `tf', replace

//------------Load Master file
import excel using "../../00.Master/02.vintage/Master_`maxvc'.xlsx", /* 
*/ sheet("SurveyMean") clear firstrow
missings dropvars, force

cap confirm var Comment
if (_rc) gen Comment = ""


merge 1:1 CountryCode SurveyTime Coverage DataType /* 
*/ using `tf', update replace

levelsof _merge, local(mrg) clean 

if !regexm("`mrg'", "2|4|5") {
	noi disp "Variables remain the same after update in Master.xlsx"
	exit
}



//------------missings data
sort CountryCode Coverage DataType SurveyTime
missings report if inlist(_merge, 2, 4, 5),  string 

local varlist = "`r(varlist)'"

foreach var of local varlist {
	replace `var' = `var'[_n-1] if inlist(_merge, 2, 4, 5)
}

drop _merge

//========================================================
//   Export results
//========================================================


//------------Verify if there were changes. 
cap datasignature confirm using /* 
*/ "02.datasignature/Master_SurveyMean_GD", strict
if (_rc) {
	
	//------------ Modify Vintage Control
	local masttime: disp %tcCCYYNNDDHHMMSS `datetime'
	
	local vint "p:\01.PovcalNet\00.Master\_vintage_control.xlsx"
	import excel "`vint'", describe
	if regexm("`r(range_1)'", "([0-9]+)$") local lr = real(regexs(1)) + 1
	
	putexcel set "`vint'", sheet(_vintage) modify
	
	
	putexcel A`lr' = "Master_`masttime'"
	putexcel B`lr' = "`user'"
	putexcel C`lr' = "SurveyMean"
	putexcel D`lr' = `"Modify/add mean for `ids' (automatic)"'
	
	//------------ Reset Signature
	noi datasignature set, reset /* 
	*/ saving("02.datasignature/Master_SurveyMean_GD", replace)
	
	//------------Change new version of SurveyMean sheet
	save "03.vintage/Master_SurveyMean_GD-`datetime'.dta", replace
	save "03.vintage/Master_SurveyMean_GD.dta", replace
	
	//------------Modify Master file with new sheet
	
	export excel "p:\01.PovcalNet\00.Master\01.current\Master.xlsx", /* 
	*/ sheet(SurveyMean, modify) firstrow(variables)
	
	copy "p:\01.PovcalNet\00.Master\01.current\Master.xlsx"   /* 
	 */ "p:\01.PovcalNet\00.Master\02.vintage\Master_`masttime'.xlsx"
	
}
else {
	noi disp in y "File " in w "Master_SurveyMean_GD.dta" in y " is up to date."
}





end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


local date      = c(current_date)
local time      = c(current_time)
local datetime  = clock("`date'`time'", "DMYhms")
disp "`datetime'"

disp %tcDDmonCCYY_HH:MM:SS `datetime'

disp %tcCCYYmonDDHHMMSS `datetime'

disp %tcCCYYNNDDHHMMSS `datetime'

local a: disp %tcCCYYNNDDHHMMSS `datetime'

local b  = clock("`a'", "YMDhms")

disp %tcDDmonCCYY_HH:MM:SS `datetime'
disp %tcDDmonCCYY_HH:MM:SS `b'

local vcnumbers: dir "." files "zzz*"
local vcnumbers: subinstr	 local vcnumbers "zzz" "", all








local exfile: dir "../../01.Vintage_control/CHN/CHN_2016_USN/chn_2016_usn_v01_m_v01_a_pcngd/Data" files "*PCNGD-2.dta"
disp `"`exfile'"'



