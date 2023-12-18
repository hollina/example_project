// Clear memory
clear all
	
// Open Auto Dataset
sysuse auto

/////////////////////////////////////////////////////////////////////////////
// Summary Statistics
eststo clear
		
estpost summarize  mpg foreign headroom trunk weight length turn
	esttab using "output/summary_statistics.tex" , replace ///
	cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
	nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
	noobs substitute(\_ _) ///
	refcat(foreign "\emph{Mortality Sample}" pop "\hspace{0.5cm} \emph{All}" popw "\hspace{0.5cm} \emph{White}" popb "\hspace{0.5cm} \emph{Black}" poph "\hspace{0.5cm} \emph{Hispanic}" , nolabel) 

/////////////////////////////////////////////////////////////////////////////
// Regressions

// Regression 1
reg price mpg foreign

sum  price , meanonly
scalar Mean = r(mean)	
estadd scalar Mean							

estadd local year_dum "No"
estadd local state_fe "No"
estadd local county_trend "No"
estadd local robut_se "No"

est sto r1

// Regression 2
reg price mpg foreign, robust

sum  price , meanonly
scalar Mean = r(mean)	
estadd scalar Mean							

estadd local year_dum "No"
estadd local state_fe "No"
estadd local county_trend "No"
estadd local robut_se "Yes"

est sto r2
		
// Regression 3
reg price mpg foreign headroom trunk weight length turn

sum  price , meanonly
scalar Mean = r(mean)	
estadd scalar Mean							

estadd local year_dum "No"
estadd local state_fe "No"
estadd local county_trend "No"
estadd local robut_se "No"

est sto r3

// Regression 4
reg price mpg foreign headroom trunk weight length turn, robust

sum  price , meanonly
scalar Mean = r(mean)	
estadd scalar Mean							

estadd local year_dum "No"
estadd local state_fe "No"
estadd local county_trend "No"
estadd local robut_se "Yes"

est sto r4

* Export the Results (so you can see them on the screen)
	esttab  r1 r2 r3 r4 , label se drop(_cons) star(* 0.10 ** 0.05 *** 0.01) ///
		stats( Mean N r2_a year_dum state_fe county_trend robut_se)
		
* Export the Results
	esttab  r1 r2 r3 r4   using "output/important_table.tex" , ///
		keep(mpg foreign headroom trunk weight length turn)  label star(* 0.10 ** 0.05 *** 0.01) ///
		replace se order(mpg foreign headroom trunk weight length turn) ///
		booktabs b(%20.2f) se(%20.2f) eqlabels(none) alignment(S S)  ///
		stats( Mean N r2_a year_dum state_fe county_trend robut_se, fmt(%3.2f  0  %3.2f 0 0 0 0) ///
		layout( "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
		label(   "\hspace{0.0cm}Mean of Dependent Variable" "\hspace{0.0cm}Observations" "\hspace{0.0cm}Adjusted R sq."  "\hline\hspace{0.0cm}Year FE"  "\hspace{0.0cm}County FE"  "\hspace{0.0cm}Some Type of Linear Time Trend(s)"  "\hspace{0.0cm}Robust Standard Errors")) ///
		f nomtitles substitute(\_ _) 	
		
/////////////////////////////////////////////////////////////////////////////
// Regression with non-linear output
gen ln_weight = ln(weight)
reg ln_weight i.foreign

// Store the dispensary effect
//Evaluate Effect using nlcom. Since we will do a tranform of the log results  
nlcom 100*(exp(_b[1.foreign])-1)
mat b = r(b)
mat V = r(V)

scalar b = b[1,1]
scalar se_v2 = sqrt(V[1,1])
scalar p_val = 2*ttail(`e(df_r)',abs(b/se_v2))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(b,.01)
local rounded_estimate : di %3.2f rounded_estimate
scalar string_estimate = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(se_v2,.01)
local rounded_se : di %3.2f rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_estimate = string_estimate + "\nlsym{3}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_estimate = string_estimate + "\nlsym{2}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_estimate = string_estimate + "\nlsym{1}"

}
else {
	scalar string_estimate = string_estimate 
}			
	
// Add the results
estadd local b_str =string_estimate
estadd local se_str =string_se


// Add indicators for state and year fixed-effects.
estadd local state_fe "No"
estadd local year_fe "No"

// Store the model
est sto nl_model


esttab nl_model  ///
	using "output/non_linear.tex" ///
	,star(* 0.10 ** 0.05 *** .01) ///
	stats(b_str se_str state_fe year_fe  N, fmt( 0 0 0 0 0) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
		"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	label("Foreign (=1)" "~"  ///
	"\hline State fixed-effects" "Year fixed-effects" "Observations")) ///
	drop(*) se b(%9.2f) booktabs ///
	f replace nomtitles ///
	 se(%20.2f) eqlabels(none) alignment(S S) 
	
/////////////////////////////////////////////////////////////////////////////
// Figures

// Scatter plot
scatter price weight
graph export "output/simple_scatter.pdf", replace 

// Coef. Plot of Regressions
coefplot r1 r2 r3 r4, ///
	drop(_cons) ///
	yline(0) ciopts(recast(rcap)) ///			
	vertical  ///
	legend(pos(6) col(4) ///
		lab(2  "Base")  lab(4  "+ Robust SE") ///
		lab(6  "+ Additional Controls")     lab(8  "+ Additional Controls and Robust SE") ///
		stack symplacement(center) size(2.75) ) ///
	xlabel(,labsize(3))

graph export "output/coef_plot.pdf", replace 

//  Graph of another regression
quietly regress mpg weight
predict hat
predict stdf, stdf
generate lo = hat - 1.96*stdf
generate hi = hat + 1.96*stdf
scatter mpg weight || line hat lo hi weight, pstyle(p2 p3 p3) sort

graph export "output/regression_plot.pdf", replace 
		

