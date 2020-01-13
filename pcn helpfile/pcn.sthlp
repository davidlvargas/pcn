{smcl}
{* *! version 1.0.0 8jan2020}{...}
{cmd:help pcn}{right: ({browse "some link":SJ: ???})}
{hline}

{vieweralsosee "" "--"}{...}
{vieweralsosee "Install wbopendata" "ssc install wbopendata"}{...}
{vieweralsosee "Help wbopendata (if installed)" "help wbopendata"}{...}
{viewerjumpto   "Command description"   "pcn##desc"}{...}
{viewerjumpto "Parameters description"   "pcn##param"}{...}
{viewerjumpto "Options description"   "pcn##options"}{...}
{viewerjumpto "Subcommands"   "pcn##subcommands"}{...}
{viewerjumpto "Stored results"   "pcn##return"}{...}
{viewerjumpto "Examples"   "pcn##Examples"}{...}
{viewerjumpto "Disclaimer"   "pcn##disclaimer"}{...}
{viewerjumpto "How to cite"   "pcn##howtocite"}{...}
{viewerjumpto "References"   "pcn##references"}{...}
{viewerjumpto "Acknowledgements"   "pcn##acknowled"}{...}
{viewerjumpto "Authors"   "pcn##authors"}{...}
{viewerjumpto "Regions" "pcn_countries##regions"}{...}
{viewerjumpto "Countries" "pcn_countries##countries"}{...}
{title:Title}

{* Title}
{p2colset 10 17 16 2}{...}
{p2col:{cmd:pcn} {hline 2}}Stata package to manage {ul:{it:PovcalNet}} files and folders.{p_end}
{* short description}
{p 4 4 2}{bf:{ul:Description (short)}}{p_end}
{pstd}
The {cmd:pcn} command(s) throughout a series of subcommands allows Stata users to manage the PovcalNet files and folders in a comprensive way.{p_end}
{pstd}
A more comprensive {it:{help pcn##description:description}} is avialable {help pcn##description:below}.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:pcn:} [{it:{help pcn##subcommands:subcommand}}] [{cmd:,} {it:{help pcn##subcommands:Parameters}} {it:{help pcn##subcommands:Options}}]

{p 4 4 2} Where parameters .... .{p_end}

{p 4 4 2} {ul:{title:Subcommands}}
The available subcommnds are the following:

{col 5}Subcommand{col 30}Description
{space 4}{hline}
{p2colset 5 30 16 2}{...}
{p2col:{opt download}}Downloads{p_end}
{p2col:{opt load}}Loads{p_end}
{p2col:{opt create}}Create{p_end}
{p2col:{ul:{opt group}}{opt data}}Tricky thing{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##subcommands:subcommands} is found {help pcn##subcommands:below}.{p_end}


{p 4 4 2} {ul:{title:Parameters}}
The {bf:pcn} command requires the following parameters:

{col 5}Parameters{col 30}Description
{space 4}{hline}
{p2colset 5 30 16 2}{...}
{p2col:{opt country:}(3-letter code)}List of country code (accepts multiples) or {it:all}{p_end}
{p2col:{opt years:}(numlist|string)}List of years (accepts multiples) or {it:all}{p_end}
{p2col:{opt type:}(string)}Type ?{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##Param:parameters} is found {help pcn##Param:below}.{p_end}

{p 4 4 2} {ul:{title:Options}}
The {bf:pcn} command has the following options available:

{col 5}Parameters{col 30}Description
{space 4}{hline}
{p2colset 5 30 16 2}{...}
{p2col:{opt clear:}}replace data in memory{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##options:Options} is found {help pcn##options:below}. {p_end}

{bf: Note: pcn} requires dataliweb access.

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

                {it:{help pcn##description:Command description}}
                {it:{help pcn##subcommands:Parameters description}}
                {it:{help pcn##Param:Parameters description}}
                {it:{help pcn##options:Options description}}
                {it:{help pcn##:Examples}}
                {it:{help pcn##disclaimer:Disclaimer}}
                {it:{help pcn##termsofuse:Terms of use}}
                {it:{help pcn##howtocite:How to cite}}

{marker description}{...}
{title:Description}
{pstd}
the {cmd:pcn} command(s) allows Stata users with access to the World Bank's dataliweb platform to {p_end}

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt detail} displays detailed output of the calculation.

{phang}
{opt meanonly} restricts the calculation to be based on only the means.  The
default is to use a trimmed mean.

{phang}
{opt format} requests that the summary statistics be displayed using
the display formats associated with the variables, rather than the default
{cmd:g} display format; see
{findalias frformats}.

{phang}
{opt separator(#)} specifies how often to insert separation lines
into the output.  The default is {cmd:separator(5)}, meaning that a
line is drawn after every 5 variables.  {cmd:separator(10)} would draw a line
after every 10 variables.  {cmd:separator(0)} suppresses the separation line.

{phang}
{opth generate(newvar)} creates {it:newvar} containing the whatever
values.

{marker examples}{...}
{title:Examples}


{marker disclaimer}{...}
{title:Disclaimer}


{marker termsofuse}{...}
{title:Terms of use}

{marker howtocite}{...}
{title:How to cite}
