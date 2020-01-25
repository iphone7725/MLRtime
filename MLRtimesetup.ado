cap prog drop MLRtimesetup
prog def MLRtimesetup

	syntax [anything], [go]

	if "`go'" == "" {
	
		display "This function will set up the proper packages"
		display "(github and rcall in Stata)"
		display "necessary to use R in Stata."
		display "These are both installed from GitHub"
		local url1 = `""https://journals.sagepub.com/doi/10.1177/1536867X19830891""'
		display "and are not maintained by StataCorp or the MLRtime authors."
		display "For more information on github and rcall, see {browse " `"`url1'"' ":the Stata Journal publication by Haghish}."
		display ""
		display "This will also install all of the R packages that MLRtime can use."
		display ""
		display "Finally, this setup requires that R is ALREADY installed on your machine."
		local urlR = `""https://www.r-project.org/""'
		display "R can be installed at {browse " `"`urlR'"' ":R-Project.org}. Do that first if it's not already installed."
		display "Do you want to continue? Type Y or Yes to continue, and anything else to quit."
		display _request(start)
		
		local st = lower("$start")
		
		if !inlist("`st'","y","yes") {
			di "Exiting..."
			exit
		}
		
		display "Should setup check for updated versions of packages?"
		display "Type Y or yes to check for updates, and anything else to only install packages"
		display "if they are completely missing."
		display _request(upd)
		
		local st = lower("$upd")
	}
	else {
		local st = "y"
	}

	if "`anything'" == "" {
		local repo = "https://cran.cnr.berkeley.edu/"
	}
	else {
		local repo = "`anything'"
	}
	
	if inlist("`st'","y","yes") {
		net install github, from("https://haghish.github.io/github/") replace
		github install haghish/rcall, stable
		
		display as error "rcall has been installed. rcall will now be used to install R packages."
		local url3 = `""http://www.haghish.com/packages/Rcall.php""'
		display as text "If errors occur, please see {browse " `"`url3'"' ":the rcall website} for"
		display "troubleshooting - rcall may not be able to find your R installation."
		
		foreach pkg in "DiceKriging" "lmtest" "Matrix" "methods" "Rcpp" "sandwich" "grf" "survival" "ranger" {
			rcall: if(!("`pkg'" %in% rownames(installed.packages()))) {install.packages('`pkg'', repos = '`repo'', dependencies = TRUE)} else { update.packages('`pkg'', repos = 'https://cran.cnr.berkeley.edu/', dependencies = TRUE)}
		}
	}
	else {
		* Check if github is installed and if not, install it
		capture which github
		if _rc > 0 {
			net install github, from("https://haghish.github.io/github/")
		}
		
		* Check if rcall is installed and if not, install it
		capture which rcall
		if _rc > 0 {
			github install haghish/rcall, stable
			display as error "rcall has been installed. rcall will now be used to install R packages."
			local url3 = `""http://www.haghish.com/packages/Rcall.php""'
			display as text "If errors occur, please see {browse " `"`url3'"' ":the rcall website} for"
			display "troubleshooting - rcall may not be able to find your R installation."
		}
	
		* Use install.packages because install_github can get strange with dependencies
		foreach pkg in "DiceKriging" "lmtest" "Matrix" "methods" "Rcpp" "sandwich" "grf" {
			rcall: if(!("`pkg'" %in% rownames(installed.packages()))) {install.packages('`pkg'', repos = '`repo'', dependencies = TRUE)}
		}
	}
	
	display "You're good to go! Everything is installed."
	display "You may want to rerun MLRtimesetup regularly to get updated versions of packages."
	
end