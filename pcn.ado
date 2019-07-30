/*==================================================
project:       Stata package to manage PovcalNet files and folders
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           https://github.com/randrescastaneda/pcn
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    29 Jul 2019 - 09:18:01
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn, rclass
syntax anything(name=subcmd id="subcommand"),  ///
[                                   ///
			COUNtries(string)                   ///
			Years(numlist)                      ///
			REGions(string)                     ///
			FILENames(string)                   ///
			REPOsitory(string)                  ///
			reporoot(string)                    ///
			repofromfile                        ///
			MODule(string)                      ///
			plines(string)                      ///
			cpivintage(string)                  ///
			veralt(string)                      ///
			vermast(string)                     ///
			TYPEs(string)                       ///
			trace(string)                       ///
			WBOdata(string)                     ///
			vcdate(string)                      ///
			createrepo                          ///
			WELFAREvars(string)                 ///
			newonly force                       ///
			noi  gpwg2  pause                   ///
			load  shape(string)                 ///
			purge restore keep(string)          ///
] 
version 15.1



/*==================================================
	    Dependencies         
==================================================*/
if ("${pcn_ssccmd}" == "") {
*--------------- SSC commands
	local cmds missings
	
	noi disp in y "Note: " in w "{cmd:pcn} requires the packages below: " /* 
	 */ _n in g "`cmds'"
	 
	foreach cmd of local cmds {
		capture which `cmd'
		if (_rc != 0) {
			ssc install `cmd'
			noi disp in g "{cmd:`cmd'} " in w _col(15) "installed"
		}
	}
	adoupdate `cmds', ssconly
	if ("`r(pkglist)'" != "") adoupdate `r(pkglist)', update ssconly
	global pcn_ssccmd = 1  // make sure it does not execute again per session
}



// ---------------------------------------------------------------------------------
//  initial parameters
// ---------------------------------------------------------------------------------

* Directory path
if ("`drive'" == "") local drive "P"

if ("`root'" == "") local root "01.PovcalNet/01.Vintage_control"

if ("`maindir'" == "") local maindir "`drive':/`root'"


// ----------------------------------------------------------------------------------
// Download GPWG
// ----------------------------------------------------------------------------------

if ("`subcmd'" == "gpwg") {

	pcn_download, countries(`countries') years(`years') /*
	*/ maindir("`maindir'") 
	exit
}





// ----------------------------------------------------------------------------------
//  build 
// ----------------------------------------------------------------------------------



/*====================================================================
Create repository
====================================================================*/
*--------------------1.1: Load repository data
if ("`createrepo'" != "" & "`calcset'" == "repo") {
	cap confirm file "`reporoot'\repo_gpwg2.dta"
	if ("`gpwg2'" == "gpwg2" | _rc) {
		indicators_gpwg2, out("`out'") datetime(`datetime')
	}
	local dt: disp %tdDDmonCCYY date("`c(current_date)'", "DMY")
	local dt = trim("`dt'")
	if ("`repofromfile'" == "") {
		cap datalibweb, repo(erase `repository', force) reporoot("`reporoot'") type(GMD)
		datalibweb, repo(create `repository') reporoot("`reporoot'") /* 
		*/         type(GMD) country(`countries') year(`years')       /* 
		*/         region(`regions') module(`module')
		noi disp "repo `repository' has been created successfully."
		use "`reporoot'\repo_`repository'.dta", clear
		append using "`reporoot'\repo_gpwg2.dta"			
		}
		else {
			use "`reporoot'\repo_`repository'.dta", clear
		}
		* Fix names of surveyid and files
		local repovars filename surveyid
		foreach var of local repovars {
			replace `var' = upper(`var')
			replace `var' = subinstr(`var', ".DTA", ".dta", .)
			foreach x in 0 1 2 {
				while regexm(`var', "_V`x'") {
					replace `var' = regexr(`var', "_V`x'", "_v`x'")
				}	
			}
		}
		
		duplicates drop filename, force
		save "`reporoot'\repo_`repository'.dta", replace
		* confirm file exists
		cap confirm file "`reporoot'\repo_vc_`repository'.dta"
		if (_rc) {
			gen vc_`dt' = 1
			save "`reporoot'\repo_vc_`repository'.dta", replace
			noi disp "repo_vc_`repository' successfully updated"
			exit 
		}
		use "`reporoot'\repo_vc_`repository'.dta", clear
		* Fix names of surveyid and files
		local repovars filename surveyid
		foreach var of local repovars {
			replace `var' = upper(`var')
			replace `var' = subinstr(`var', ".DTA", ".dta", .)
			foreach x in 0 1 2 {
				while regexm(`var', "_V`x'") {
					replace `var' = regexr(`var', "_V`x'", "_v`x'")
				}	
			}
		}
		
		duplicates drop filename, force
		merge 1:1 filename using "`reporoot'\repo_`repository'.dta"
		cap confirm new var vc_`dt'
		if (_rc) drop vc_`dt'
		recode _merge (1 = 0 "old") (3 = 1 "same") (2 = 2 "new"), gen(vc_`dt')
		sum vc_`dt', meanonly
		if r(mean) == 1 {
			noi disp in r "variable {cmd:vc_`dt'} is the same as previous version. No update"
			drop vc_`dt' _merge
			error
		}
		else {
			noi disp in y "New vintages:"
			noi list filename if vc_`dt' == 2
		}
		drop _merge
		save "`reporoot'\repo_vc_`repository'.dta", replace
		exit
}

/*==================================================
    Download GPWG
    ==================================================*/


    *----------1.1:


    *----------1.2:


/*==================================================
              2: 
              ==================================================*/


              *----------2.1:


              *----------2.2:


/*==================================================
              3: 
              ==================================================*/


              *----------3.1:


              *----------3.2:





              end
              exit
              /* End of do-file */

              ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

              Notes:
              1.
              2.
              3.


              Version Control:


