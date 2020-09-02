////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// AUTHOR NAME (email)

// TITLE

// JOURNAL

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Set R and Wget path
global r_path "/usr/local/bin/R" 
global wget_path "/usr/local/bin/wget" 

///////////////////////////////////////////////////////////////////////////////
// Set options 

// Download raw data (0 for no; 1 for yes)
global downloads 0

// Build dataset used in analysis (0 for no; 1 for yes)
global build_data 0

// Use restricted access mortality data  (0 for no; 1 for yes)
global restricted_access 0

// Run very slow parts of the analysis code
global slow_code 0

// Deprecated code, keep this set to 0
global deprecated 0

///////////////////////////////////////////////////////////////////////////////
// Use included packages

cap adopath - PERSONAL
cap adopath - PLUS
cap adopath - SITE
cap adopath - OLDPLACE
adopath + "stata_packages"
net set ado "stata_packages"

// Download packages 
if $downloads == 1 {
	// Install  Packages
	ssc install estout, replace	
	ssc install blindschemes, replace	
	ssc install coefplot, replace
}


///////////////////////////////////////////////////////////////////////////////
// Set your file paths, These are relative to where the project file is saved. 

global data_path "data/data_for_analysis"
global raw_data_path "data/raw_data" 
global temp_path "temp" 

global script_path "scripts" 
global results_path "output" 
global log_path "logs" 

global restricted_data_raw "restricted_raw_data" 
global restricted_data_analysis "restricted_data_for_analysis"

// Version of stata
version 15

// Close any open log files
capture log close

// Clear Memory
clear all

// Set Date
global date = subinstr("$S_DATE", " ", "-", .)

// Specify Screen Width for log files
set linesize 255

// Set font type
graph set window fontface "Roboto"

// Set Graph Scheme
set scheme plotplainblind

// Allow the screen to move without having to click more
set more off

// Drop everything in mata
matrix drop _all

// Set Project Details using local mactos
local project nascar_and_lead
global pgm master_build_datasets_for_analysis
local task "This file runs the do files needed to create the datasets used in our NASCAR and lead analysis"
local tag "$pgm.do $date"

///////////////////////////////////////////////////////////////////////////////
// Run do files
do $script_path/1.test_script.do


////////////////////////////////////////////////////////////////////////////////
// Call R using the shell command
* I believe this will only work on Unix machines. However it's possible that it works on Windows as well
* the first part, /usr/local/bin/R, points to the location of R on your machine
* the second part, --vanilla, are the options you want to run with R
* the third part, <1_scrape_nascar_data_from_racing_reference.R, points to the file we want to run
* oddly the < "carrot" is necessary and throws an error when it's not there
shell $r_path --vanilla <scripts/2.test_script.R
