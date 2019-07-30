/*==================================================
project:       Down GPWG databases
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    29 Jul 2019 - 16:01:01
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pcn_download, rclass
syntax anything(name=subcmd id="subcommand"),  ///
[                                   ///
			COUNtries(string)                   ///
			Years(numlist)                      ///
			REGions(string)                     ///
			maindir(string)                     ///
			replace                             ///
] 

version 15.1

	local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY  
	local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS  
	local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS  
	local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time' 
	local datetimeHRF = trim("`datetimeHRF'")	
	local user=c(username) 




/*==================================================
            1: 
==================================================*/

primus query, overalls(approved)

* replace those that finish in GPWG and SARMD or something else. 
replace survey_id = regexs(1)+"GMD" if regexm(survey_id , "(.*)(GPWG.*)$")

generate datetime = string(date_modified, "%tc")

tostring _all, replace force 


*----------1.1: Send to MATA


split survey_id, p("_")

local i = 1
local n = 0
local names survey veralt vermast type

cap confirm var survey_id`i'
while _rc == 0 {

	if inlist(`i', 1, 2, 5, 7) {
		drop survey_id`i'
	}
	else {
		local ++n
		rename survey_id`i' `: word `n' of `names''
	}
	local ++i
	cap confirm var survey_id`i'
}

order country year survey veralt vermast type survey_id datetime


qui ds
local varlist = "`r(varlist)'"

mata: R = st_sdata(.,tokens(st_local("varlist")))
local n = _N


* : list posof "country" in varlist 


*----------1.2:

/*==================================================
              2: 
==================================================*/


mata: P  = J(0,0, .z)   // matrix with information about each survey

local n = 1
local maindir "P:/01.PovcalNet/01.Vintage_control"


local i = 0
while (`i' < `n') {
	local ++i
	
	mata: pcn_ind(R)
	
	*--------------------2.2: Load data
	cap datalibweb, country(`country') year(`year') surveyid(`survey_id')  /*
	*/   type(GMD) mod(GPWG)

	if (_rc) {
		local note "dlw error"
		mata: P = pcn_info(P)
		continue
	}

	*------Parameter of the file

	local filename "`r(filename)'"

	local dirname "`maindir'/`country'/`country'_`year'_`survey'"
	local dirname "`dirname'/`survey_id'/Data"
	
	char _dta[pcn_datetimeHRF]    "`datetimeHRF'" 
	char _dta[pcn_datetime]       "`date_time'" 
	char _dta[pcn_user]           "`user'" 

	* Confirm file exists
	cap confirm file "`dirname'/`filename'"

  if (_rc) {  // if file does not exist

		mata: st_local("direxists", strofreal(direxists("`dirname'")))

		if (`direxists' != 1) { // if folder does not exist
			cap mkdir "`maindir'/`country'"
			cap mkdir "`maindir'/`country'/`country'_`year'_`survey'"
			cap mkdir "`maindir'/`country'/`country'_`year'_`survey'/`survey_id'"
			cap mkdir "`maindir'/`country'/`country'_`year'_`survey'/`survey_id'/Data"
		}

		datasignature set, reset saving("`dirname'/`filename'", replace)
	
		saveold "`dirname'/`filename'"
		local note "saved"
	}

	else {  // If file exists, check data signature
		cap noi datasignature confirm using "`dirname'/`filename'"

		if (_rc) { // if data do not match
			if ("`replace'" != "") {
				
				cap mkdir "`dirname'/_vintage"
				preserve   // I cannot use  copy because I nees the pcn_datetime char
					use "`dirname'/`filename'", clear
					saveold "`dirname'/_vintage/`filename'_`:char _dta[pcn_datetime]'", clear
				restore
				saveold "`dirname'/`filename'", replace
				local note "replaced"
			}

			else { // if replace option not selected
				local note "not replaced"
			}
		}

		else {  // if data is the same
			local note "equal"
		}

	}  //  end of file exists condition


	mata: P = pcn_info(P)

} // end of while 




*----------2.1:


*----------2.2:


/*==================================================
              3: 
==================================================*/


*----------3.1:


*----------3.2:





end


/*====================================================================
Mata functions
====================================================================*/
mata
mata drop pcn*()
mata set mataoptimize on
mata set matafavor speed

void pcn_ind(string matrix R) {
	i = strtoreal(st_local("i"))
	vars = tokens(st_local("varlist"))
	for (j =1; j<=cols(vars); j++) {
		//printf("j=%s\n", R[i,j])
		st_local(vars[j], R[i,j] )
	} 
} // end of IDs variables

string matrix pcn_info(matrix P) {

	survey = st_local("survey_id")

	note = st_local("note")


	if (rows(P) == 0) {
		P = survey, note
	}
	else {
		P = P \ (survey, note)
	}
	
	return(P)
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


