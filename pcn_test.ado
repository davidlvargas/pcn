/*==================================================
project:       test pcn adofile
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:     9 Aug 2019 - 10:49:50
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pcn_test, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
			country(string)               ///
			Year(numlist)                 ///
			REGions(string)               ///
			maindir(string)               ///
			type(string)                  ///
			survey(string)                ///
			replace                       ///
			vermast(string)               ///
			veralt(string)                ///
			MODule(string)                ///
			clear                         ///
			pause                         ///
] 

version 15

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


// ------------------------------------------------------------------------
// test
// ------------------------------------------------------------------------


noi mata: hello()

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
