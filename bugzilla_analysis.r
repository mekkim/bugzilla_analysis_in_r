#################################################################################
#																				#
# 		ANALYZING MOZILLA'S BUGZILLA DATABASE USING R							#
#																				#
#		© 2015 by Mekki MacAulay, mekki@mekki.ca, http://mekki.ca				#
#		Twitter: @mekki - http://twitter.com/mekki
#		Some rights reserved.													#
#																				#
#		Current version created on November 4, 2015								#
#																				#
#		This program is free and open source software. The author licenses it	# 
#		to you under the terms of the GNU General Public License (GPL), as 		#
#		published by the Free Software Foundation, either version 3, or			#
#		(at your option) any later version (GPLv3+).							#
#																				#
#		There is NO WARRANTY for this software, express or implied, including 	#
#		the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR 	#
#		PURPOSE. See the GNU General Public License for more details.			#
#																				#
#		For the full text of the GNU General Public License, please visit		#
#		http://gnu.org/licenses/												#									
#                                            									#
#		Should you require an alternative licensing arrangement for this 		#
#		software, please contact the author.	                                #
#																				#
#################################################################################
#
# This file is a commented R script file that can be executed directly in R:
#
# setwd('<FULL PATH TO THIS SCRIPT FILE>');
# source('<NAME OF THIS FILE>.r', echo=TRUE, max.deparse.length=100000, keep.source=TRUE, verbose=TRUE);
# (These source() parameters ensure that the R shell outputs the script commands and responses. Otherwise, they're hidden by default.) 
##
# Or, from the command prompt directly as follows (assuming R binary is in the PATH environment variable):
# cd <FULL PATH TO THIS SCRIPT FILE>
# R CMD BATCH <NAME OF THIS FILE>.r
# CAT <NAME OF THIS FILE>.Rout
# (The CAT is necessary because by default R output writes to file, not command prompt)
#
#################################################################################
#
# This script depends on the presence of an updated R installation along with a
# MySQL installation containing the Mozilla Bugzilla database and a
# PHP utility script for domain name parsing
#
# The following sections describe the process for installing these necesities
#
# INSTALL MYSQL SERVER
#
# Visit: https://dev.mysql.com/downloads/windows/installer/5.5.html
# 
# Download the MySQL MSI installer for Windows 
# (Version 5.5.44 will do just fine - Later versions have the annoying Oracle installer that makes things more complicated)
#
# Run the installer as administrator and complete the MySQL install with default settings (or minor tweaks if you wish)
# During install, set the  default username to "root" and password to "password" in the configuration
# Default host will be "localhost" and default port will be "3306"
# 
# Test connection to ensure it is working with the MySQL Workbench client that is also installed with the package
# Once connected with the MySQL Workbench client, under the menu "Server", select "Options File"
# Click on the "Networking" tab
# Check the box for "max_allowed_packet" and set its value to "1G" or a suitable large number
# Click "Apply" and then restart the server 
# (In the Navigator pane, click on "Startup / Shutdown" then click "Stop Server" in the main window, followed by "Start Server)
# 
#
# RESTORE BUGZILLA DATABASE (Current version includes data until end of 2012)
#
# Decompress/untar the Bugzilla database.  The result is a MySQL-formatted dumpfile with a .sql extension
# I'll assume that the file name is "2013_01_sanitized_bugzilla.sql". If it's not, change the name in the commands below.
# This dumpfile only works with MySQl databases.  It cannot be restored to other databases such as SQLite, PostGRESQL, MSSQL, etc.
# It is also sufficiently complex that scripts cannot readily be used to convert it to a dumpfile of a different format
# 
# From the command prompt, issue the following 3 commands one by one:
#
# mysql -uroot -ppassword -e 'DROP DATABASE bugs;'
# mysql -uroot -ppassword -e 'CREATE DATABASE bugs;'
# mysql -uroot -ppassword bugs < 2013_01_sanitized_bugzilla.sql
# 
# The result will be a database named "bugs" on the MySQL server, filled with the Bugzilla data
# 
# The "bugs" database will be kept as our "pristine" copy of the data so that we don't have to restore it from 
# the dumpfile if something goes wrong. This step isn't strictly necessary, but it never hurts to be safe.
# We'll only work on a duplicate of the "bugs" database that we can always recreate from the pristine copy if something breaks
# 
# To create a duplicate of the "bugs" database, which we will call "working", 
# from the command prompt, issue the following command:
# 
# mysqldbcopy --source=root:password@localhost --destination=root:password@localhost bugs:working
# 
# 
# INSTALL AND CONFIGURE R (Statistical package) or RRO (Revolution R Open enhanced R distribution)
#
# Visit: http://cran.utstat.utoronto.ca/bin/windows/base/
# 
# Download the installer for the latest version for Windows (32/64 bit)
#
# Alternatively, visit: http://mran.revolutionanalytics.com/download/#download
#
# Download the installer for the latest version of Revolution R Open, RRO, an alternative R distribution 
# primarily developed by Revolution Analytics (http://revolutionanalytics.com/), which is also open source
# Revolution Analytics maintains a Managed R Archive Network (MRAN) that mirrors the base CRAN with optimizations
#
# This script might execute slightly faster with RRO vs base R, but no large changes have been noted yet.
#
# You are encouraged to use an R or RRO version of at least 3.2.x as versions 3.1.3 and earlier execute this script significantly
# slower (~45% speed decrease), likely due to different memory heap management discussed here: 
# http://cran.r-project.org/src/base/NEWS
#
# Run the installer (either one) as administrator and complete the R install with default settings (or minor tweaks if you wish)
#
# Create a shortcut to R x64 X.X.X on the desktop (or suitable place - the installers offer to create one for you)
# Right-click on the shortcut and choose "Properties"
# Change the "Start in:" field to the location of this script file 
# (Currently: "C:\Users\atriou\Dropbox\Classes and York Stuff\Dissertation and brainstorming\Scripts\R")
# That will ensure that R can find this script when executed from within the R shell
#
# Install additional packages from the package manager including at least the following:
# 
# chron
# curl
# data.table
# DBI
# dplyr
# DT
# FactoMineR
# FSA: https://www.rforge.net/FSA/Installation.html -> Not needed with dplyr::filter, which is much faster
# ggplot2
# googleVis https://cran.r-project.org/web/packages/googleVis/index.html
# graphics
# gWidgets
# gWidgetsRGtk2
# highr
# longitudinalData
# lubridate
# Paneldata
# panelaggregation
# panelAR
# plyr
# Rcmdr (and its many plugins)
# RCurl
# rggobi
# RGraphics
# RGtk2
# RGtk2Extras
# RJDBC
# RMySQL
# RODBC
# RODBCext
# RQDA
# sqldf
# sqlutils
# stargazer
# timeDate
# utils
# xkcd
# xlsx
# zipcode
# ...
# and all of the recursive dependencies of these listed packages (should do it automatically for you)
# This might take a while...
#
# 
# INSTALL AND CONFIGURE PHP
#
# Download the latest zip installer package from http://windows.php.net/download/
# This version uses PHP 5.6.14, which was current release version at the time
#
# Extract the contents of the zip file to whatever directory you want to keep PHP in
# I chose "C:\php"
#
# Create a new file called "php.ini" in the PHP directory
# Edit the php.ini file to include the following lines:
#
# extension=php_curl.dll
# extension=php_openssl.dll
# extension=php_intl.dll
# extension=php_mbstring.dll
# memory_limit = 2048M
#
# Open the ext director in the PHP directory
# Copy php_curl.dll, php_openssl.dll, php_intl.dll, and php_mbstring.dll to the root PHP directory
#
# Change the system PATH environment variable to include "C:\php" or whatever directory you chose for the PHP install
#
# Download the latest version of PHP Composer from: https://getcomposer.org/Composer-Setup.exe
# Run the installer with default settings
#
# Follow the instructions here to install "PHP Domain Parser" using Composer: https://github.com/jeremykendall/php-domain-parser/blob/develop/README.md
# 
# The small php program "domainparser.php" is provided and uses the installed domai parser library
#
# END OF DEPENDENCIES TO RUN SCRIPT
#
#################################################################################

#################################################################################
# 								START OF SCRIPT									#
#################################################################################

# LOAD LIBRARIES
load_libraries <- function () {

# Load MySQl connection library
library(RMySQL);

# Load the Data.table library for data.table objects and fread() function
library(data.table);

# Load plyr and dplyr libraries for operation functions
library(plyr);
library(dplyr);

# Load chron for easy date-time manipulation and calculation
library(chron);

} # End load_libraries function


# DATA INPUT

# In this step, we create and populate all of the data frames/tables that will be manipulated in the research
# from their data sources including the MySQL database and CSV files.

# Bugzilla data frames/tables
load_bugzilla_data <- function () {

# Create variable with MySQL database connection details:
# These details need to match the username, password, database name, and host as 
# configured during the installation of dependencies
bugzilla <- dbConnect(MySQL(), user='root', password='password', dbname='working', host='localhost');

# Create data frame variables for the useful tables in the Bugzilla database
bugs 			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM bugs;');
profiles 		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM profiles;');
activity 		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM bugs_activity;');
cc 				<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM cc;');
attachments 	<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM attachments;');
votes 			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM votes;');
longdescs 		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM longdescs;');
watch 			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM watch;');
duplicates		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM duplicates;');
group_list		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM groups;');
group_members	<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM user_group_map;');

} # End load_bugzilla_data function

# END DATA INPUT


# CLEAN BASE DATA

# In this step, we isolate the useful constructs for analysis
# Often, we'll create multiple operationalizations for similar things
 
# Domains: Bugzilla
clean_bugzilla_data <- function () {
# Domains are trimmed from the email address in the "login_name" field of the "profiles" table

# Import the profiles table from the previous subroutine to work on
profiles_stripped_email <- profiles;

# Createa a new column called "stripped_email" based on the "login_name" column that removes the portion before the @ symbol
profiles_stripped_email$stripped_email <- sub("^[a-z0-9_%+-.]+@((?:[a-z0-9-]+\\.)+[a-z]{2,4})$", "\\1", profiles$login_name, ignore.case = TRUE, perl = TRUE);

# Write the stripped email portion to file to later input into the PHP script
write(profiles_stripped_email$stripped_email, "stripped_emails.txt");

# Call the PHP script described at the start of this file to trim the stripped emails to registerable domain portion only
registerable_domain_portion_list_unclean <- system("php -f domainparser.php", intern=TRUE);

# The PHP script returns an unclean version of the registerable domains, so parse out only the registerable domain part
registerable_domain_portion_list <- sub('^.+\\\"(.+)\\\"$', "\\1", registerable_domain_portion_list_unclean, ignore.case = TRUE, perl = TRUE);

# Create a new data frame from profiles and add the domain column from the cleaned registerable domain list
profiles_with_domain <- profiles;
profiles_with_domain$domain <- registerable_domain_portion_list;

# Trim out profiles that have webmail domains from the full profiles list to identify organizations.
# Thankfully, we already created a text file with over 5,000 webmail domains

webmail_domains 	<- fread("webmaildomains.txt", header=FALSE);
webmail_domains		<- webmail_domains$V1;

profiles_no_webmail <- filter(profiles_with_domain, !(tolower(profiles_with_domain$domain) %in% tolower(webmail_domains)));
profiles_no_webmail <- filter(profiles_no_webmail, ((profiles_no_webmail$domain != "NULL") & (profiles_no_webmail$domain != "")));

# Clean up some entries with manual imputation

# The userid "1" means "nobody", but has a "mozilla.org" domain, so would otherwise be retained.  Delete it.
profiles_no_webmail			<- filter(profiles_no_webmail, userid != 1);

# Mozilla uses some fake email addresses that end in ".bugs" for tracking purposes.
profiles_no_webmail$domain	<- sub("^.+\\.bugs$", "mozilla\\.org", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);

# Mozilla internally uses "mozilla.org", "mozilla.com" and "mozillafoundation.org" addresses.  Let's merge them to "mozilla.org" as a single organization
profiles_no_webmail$domain	<- sub("^mozilla\\.com", "mozilla\\.org", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^mozillafoundation\\.org", "mozilla\\.org", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);

# Old Netscape profiles are deprecated to this format. Might as well merge them with the other Netscape accounts.
profiles_no_webmail$domain	<- sub("^formerly-netscape\\.com$", "netscape\\.com", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);

# Bugzilla used to use .com, but now it's just .org
profiles_no_webmail$domain	<- sub("^bugzilla\\.com", "bugzilla\\.org", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);

# Some organizations use multiple domains. Hard to catch them all, but these are the ones noticed:
profiles_no_webmail$domain	<- sub("^mot\\.com", "motorola\\.com", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^nortel\\.com", "nortelnetworks\\.com", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^nortel\\.ca", "nortelnetworks\\.com", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^nrc\\.ca", "nrc\\.gc\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^nrc-cnrc\\.gc\\.ca", "nrc\\.gc\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^mohawkcollege\\.ca", "mohawkc\\.on\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^senecacollege\\.ca", "senecac\\.on\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^crc\\.ca", "ic\\.gc\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^hamilton\\.ca", "hamilton\\.on\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^humber\\.ca", "humberc\\.on\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^nfy\\.ca", "nfy\\.bc\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^ocad\\.ca", "ocadu\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^stclaircollege\\.ca", "stclairc\\.on\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^toronto\\.ca", "toronto\\.on\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^unitz\\.ca", "unitz\\.on\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^usherb\\.ca", "usherbrooke\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^yknet\\.ca", "yknet\\.yk\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);
profiles_no_webmail$domain	<- sub("^iee\\.org", "yknet\\.yk\\.ca", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);

# Count the number of times each domain shows up in the profiles to estimate organization size & level of participation
# And set the 1st column name to "domain", and the second column name to "org_user_count"
profiles_domain_count_working <- as.data.table(dplyr::rename(arrange(as.data.frame(table(profiles_no_webmail$domain)), -Freq), domain = Var1, org_user_count = Freq));

# The "userid" field in the profiles table got incorrectly autodetected as "integer"
# So set it to factor
profiles_no_webmail <- mutate(profiles_no_webmail, userid = as.factor(userid));


# BUGS

# Import the bugs table from the previous subroutine to work on
bugs_working <- bugs;

# Set fields that were incorrectly set as integer to factors
bugs_working <- mutate(bugs_working, bug_id 		= as.factor(bug_id),
									 assigned_to 	= as.factor(assigned_to),
									 reporter 		= as.factor(reporter),
									 qa_contact		= as.factor(qa_contact));

# Bugs 8358, 14616, 16198, 16199, 16473, & 16532 are incomplete "test" bugs that aren't real, so delete via manual imputation.
bugs_working <- filter(bugs_working, !(bug_id %in% c("8358", "14616", "16198", "16199", "16473", "16532")));


# LONGDESCS

# Import the longdescs table from the previous subroutine to work on
longdescs_working <- longdescs;

# Set fields that were incorrectly set as integer to factors
longdescs_working <- mutate(longdescs_working, bug_id 	= as.factor(bug_id),
											   who 		= as.factor(who));


# ACTIVITY

# Import the activity table from the previous subroutine to work on
activity_working <- activity;

# Set fields that were incorrectly set as integer to factors
activity_working <- mutate(activity_working, bug_id = as.factor(bug_id),
											 who	= as.factor(who));


# CC

# Import the CC table from the previous subroutine to work on
cc_working <- cc;

# Set the fields that were incorrectly set as integer to factors
cc_working <- mutate(cc_working, bug_id = as.factor(bug_id),
								 who = as.factor(who));


# ATTACHMENTS

# Import the attachments table from the previous subroutine to work on
attachments_working <- attachments;

# Set fields that were incorrectly set as integer to factors
attachments_working <- mutate(attachments_working, bug_id 		= as.factor(bug_id),
												   submitter_id = as.factor(submitter_id));


# VOTES

# Import the votes table from the previous subroutine to work on
votes_working <- votes;

# Set the fields that were incorrectly set as integer to factors
votes_working <- mutate(votes_working, bug_id 	= as.factor(bug_id),
									   who 		= as.factor(who));												   
												   

# WATCH

# Import the watch table from the previous subroutine to work on
watch_working <- watch;

# Set the fields that were incorrectly set as integer to factors
watch_working <- mutate(watch_working, watcher 	= as.factor(watcher),
									   watched	= as.factor(watched));													   


# DUPLICATES

# Import the duplicates table from the previous subroutine to work on
duplicates_working <- duplicates;

# Set the fields that were incorrectly set as integer to factors
duplicates_working <- mutate(duplicates_working, dupe_of 	= as.factor(dupe_of),
												 dupe		= as.factor(dupe));	
												 

# GROUP MEMBERS

# Import the group_members table from the previous subroutine to work on
group_members_working <- group_members;

# Set the fields that were incorrectly set as integer to factors
group_members_working <- mutate(group_members_working, user_id 	= as.factor(user_id),
													   group_id	= as.factor(group_id));													 
									   
												   
# Create global variable to use in other functions
# Make them all data.tables along the way since we'll use functions from the data.tables library throughout

profiles_domain_count_clean <<- as.data.table(profiles_domain_count_working);
profiles_clean 				<<- as.data.table(profiles_no_webmail);
bugs_clean					<<- as.data.table(bugs_working);
longdescs_clean				<<- as.data.table(longdescs_working);
activity_clean				<<- as.data.table(activity_working);
cc_clean					<<- as.data.table(cc_working);
attachments_clean			<<- as.data.table(attachments_working);
votes_clean					<<- as.data.table(votes_working);
watch_clean					<<- as.data.table(watch_working);
duplicates_clean			<<- as.data.table(duplicates_working);
group_members_clean			<<- as.data.table(group_members_working);
group_list_clean			<<- as.data.table(group_list);

} # End clean_bugzilla_data function

# END CLEAN BASE DATA


# CREATE BASE OPERATIONALIZED VARIABLES

operationalize_base <- function () {

# PROFILES

# We want to add an entry for each profile that has the number of organizational users
# Get the org user count based on the profiles_domain_count variable which acts as a form of lookup table

profiles_domain_count 	<- profiles_domain_count_clean;
profiles_working 		<- profiles_clean;

# Set the sort keys of both variables according to domain.  Same domain is fine, since it will be same number of org users
setkey(profiles_domain_count, domain);
setkey(profiles_working, domain);

# Merge the tables onto the profiles_working table according to domain and org_user_count, preserving all profiles_working rows
profiles_working <- merge(profiles_working, profiles_domain_count, by="domain", all.x=TRUE);


# BUGS

# We want to add the domain of the reporter, qa_contact, and assigned_to person for each bug
# Create a subset of the bugs table that consists only of organizational entries
bugs_working <- filter(bugs_clean, (reporter 	%in% profiles_working$userid) | 
								   (assigned_to %in% profiles_working$userid) | 
								   (qa_contact 	%in% profiles_working$userid));


# Merge the "domain" column for the bug's reporter
setkey(profiles_working, userid);
setkey(bugs_working, reporter);
bugs_working <- merge(bugs_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="reporter", by.y="userid", all.x=TRUE);

# Rename it to "reporter_domain" so that we won't clober it when we repeat for assigned_to and qa_contact
bugs_working <- dplyr::rename(bugs_working, reporter_domain = domain);

# Repeat merge/rename with assigned_to
setkey(profiles_working, userid);
setkey(bugs_working, assigned_to);
bugs_working <- merge(bugs_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="assigned_to", by.y="userid", all.x=TRUE);
bugs_working <- dplyr::rename(bugs_working, assigned_domain = domain);

# Repeat merge/rename  with qa_contact
setkey(profiles_working, userid);
setkey(bugs_working, qa_contact);
bugs_working <- merge(bugs_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="qa_contact", by.y="userid", all.x=TRUE);
bugs_working <- dplyr::rename(bugs_working, qa_domain = domain);


# Add a numerical version of "bug_severity" field since it's ordered factors
# Read in the bug_severity lookup table from file
severity_lookup <- read.table("severity_lookup.txt", sep=",", header=TRUE);
severity_lookup <- as.data.table(severity_lookup);

# Merge the new "severity" numerical column according to "bug_severity"
setkey(severity_lookup, bug_severity);
setkey(bugs_working, bug_severity);
bugs_working <- merge(bugs_working, severity_lookup, by='bug_severity', all.x=TRUE);


# Add a outcome variable that reduces "bug_status" and "resolution" to one of "fixed", "not_fixed", or "pending"
# Read in the outcome lookup table from file
outcome_lookup <- read.table("outcome_lookup.txt", sep=",", header=TRUE);
outcome_lookup <- as.data.table(outcome_lookup);

# Merge the new "outcome" column according to "bug_status" and "resolution" combinations
setkey(outcome_lookup, bug_status, resolution);
setkey(bugs_working, bug_status, resolution);
bugs_working <- merge(bugs_working, outcome_lookup, by=c('bug_status', 'resolution'), all.x=TRUE);


# ACTIVITY

# Create a subset of the activities table that consists only of organizational entries
# Removing non-organizational domains reduces activity count from 9,507,565 to 6,158,479
# But, beware!  Many of those are mozilla.org.  It's far smaller (4,031,878) without mozilla.org.  Still impressive!
activity_working <- filter(activity_clean, who %in% profiles_working$userid);


# Merge the "domain" column based on the "who" field for each activity
setkey(profiles_working, userid);
setkey(activity_working, who);
activity_working <- merge(activity_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="who", by.y="userid", all.x=TRUE);


# CC

# Create a subset of the CC table that consists only of organizational entries
# Removing non-organizational domains reduces CC count from 2,502,470 to 1,478,453
# But, beware!  Many of those are mozilla.org.  It's far smaller (987,318) without mozilla.org.  Still impressive!
cc_working <- filter(cc_clean, who %in% profiles_working$userid);

# Merge the "domain" column based on the "who" field for each cc
setkey(profiles_working, userid);
setkey(cc_working, who);
cc_working <- merge(cc_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="who", by.y="userid", all.x=TRUE);

 
# ATTACHMENTS

# Create a subset of the attachments table that consists only of organizational entries
# Removing non-organizational domains reduces attachments count from 677,680 to 412,726
# But, beware!  Many of those are mozilla.org.  It's far smaller (285,307) without mozilla.org.  Still impressive!
attachments_working <- filter(attachments_clean, submitter_id %in% profiles_working$userid);

# Merge the "domain" column based on the "submitter_id" field for each attachment
setkey(profiles_working, userid);
setkey(attachments_working, submitter_id);
attachments_working <- merge(attachments_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="submitter_id", by.y="userid", all.x=TRUE);

 
# VOTES

# Create a subset of the votes table that consists only of organizational entries
# Removing non-organizational domains reduces votes count from 242,592 to 89,292, a much bigger % change than other variables. Lots of individual users voting!
# Interestingly, most (88,068) are not from mozilla.org.  Surprising!
votes_working <- filter(votes_clean, who %in% profiles_working$userid);

# Merge the "domain" column based on the "who" field for each attachment
setkey(profiles_working, userid);
setkey(votes_working, who);
votes_working <- merge(votes_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="who", by.y="userid", all.x=TRUE);

 
# LONGDESCS

# Create a subset of the longdescs table that consists only of organizational entries
# Removing non-organizational domains reduces longdescs count from 6,652,299 to 4,098,387.
# But, beware!  Many of those are mozilla.org.  It's far smaller (2,923,853) without mozilla.org.  About half.
longdescs_working <- filter(longdescs_clean, who %in% profiles_working$userid);

# Merge the "domain" column based on the "who" field for each longdesc
setkey(profiles_working, userid);
setkey(longdescs_working, who);
longdescs_working <- merge(longdescs_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="who", by.y="userid", all.x=TRUE);

 
# WATCH

# Create a subset of the watch table that consists only of organizational entries
# Removing non-organizational domains reduces watch count from 5,716 to 4,886.
# But, beware!  Many of those are mozilla.org.  Only 338 entries have neither watched nor watcher as "mozilla.org"
# "mozilla.org" people are watchers 806 times and watched 3488 times. Lots of people follow what Mozilla org people are doing.
watch_working <- filter(watch_clean, (watcher %in% profiles_working$userid) | (watched %in% profiles_working$userid));

# Merge the "domain" column for the "watcher"
setkey(profiles_working, userid);
setkey(watch_working, watcher);
watch_working <- merge(watch_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="watcher", by.y="userid", all.x=TRUE);

# Rename it to "watcher_domain" so that we won't clober it when we repeat for watched_domain
watch_working <- dplyr::rename(watch_working, watcher_domain = domain);

# Repeat merge/rename with "watched"
setkey(profiles_working, userid);
setkey(watch_working, watched);
watch_working <- merge(watch_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="watched", by.y="userid", all.x=TRUE);
watch_working <- dplyr::rename(watch_working, watched_domain = domain);


# GROUP MEMBERS

# Create a subset of the group_members table taht consists only of organizational entries
# Removing non-organizational domains reduces the group members count from X to Y
# But, beware!  Many of those are mozilla.org.  Only Z entries are not "mozilla.org"

group_members_working <- filter(group_members_clean, user_id %in% profiles_working$userid);


# Merge the "domain" column based on the "user_id" field for each group membership entry
setkey(profiles_working, userid);
setkey(group_members_working, user_id);
group_members_working <- merge(group_members_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="user_id", by.y="userid", all.x=TRUE);

 
# Set global variables for other functions
profiles_base 		<<- profiles_working;
bugs_base 			<<- bugs_working;
activity_base	 	<<- activity_working;
cc_base				<<- cc_working;
attachments_base 	<<- attachments_working;
votes_base 			<<- votes_working;
longdescs_base	 	<<- longdescs_working;
watch_base	 		<<- watch_working;
group_members_base	<<- group_members_working;

} # End operationalize_base function


# OPERATIONALIZE INTERACTIONS BETWEEN TABLES

operationalize_interactions <- function () {

# PROFILES-USER-ACTIVITY

# Import profiles from previous subroutine
profiles_working <- profiles_base;

# Count the activities for each user in the activity table
activity_user_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(activity_base$who)), -Freq), who = Var1));

# Merge the "user_activity_count" with the profiles table based on "who" and "userid"
setkey(activity_user_count, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_user_count, by.x="userid", by.y="who", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_activity_count = Freq);

# For any NA entries in the "user_activity_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_activity_count = ifelse(is.na(user_activity_count), 0, user_activity_count));


# PROFILES-ORG-ACTIVITY

# Count the activities for each org in the activity table
activity_org_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(activity_base$domain)), -Freq), domain = Var1));

# Profile_working is already a data.table and the userid is already as.factor, so no need to set again
# We want to operate on the updated profile_working anyways, not the base anymore

# Merge the "org_activity_count" with the profiles table based on "domain" column of both
setkey(activity_org_count, domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, activity_org_count, by="domain", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, org_activity_count = Freq);


# PROFILES-USER-BUGS_REPORTED

# Count the bugs reported by each user in the bugs table
bug_user_reported_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$reporter)), -Freq), reporter = Var1));

# Merge the "user_bugs_reported_count" with the profiles table based on "reporter" and "userid"
setkey(bug_user_reported_count, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_reported_count, by.x="userid", by.y="reporter", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_bugs_reported_count = Freq);

# For any NA entries in the "user_bugs_reported_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_reported_count = ifelse(is.na(user_bugs_reported_count), 0, user_bugs_reported_count));


# PROFILES-ORG-BUGS_REPORTED

# Count the bugs reported by each org in the bugs table
bug_org_reported_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$reporter_domain)), -Freq), reporter_domain = Var1));

# Merge the "org_bugs_reported_count" with the profiles table based on "reporter_domain" and "domain" columns
setkey(bug_org_reported_count, reporter_domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, bug_org_reported_count, by.x="domain", by.y="reporter_domain", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, org_bugs_reported_count = Freq);


# PROFILES-USER-BUGS_ASSIGNED

# Count the bugs assigned to each user in the bugs table
bug_user_assigned_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$assigned_to)), -Freq), assigned = Var1));

# Merge the "user_bugs_assigned_count" with the profiles table based on "assigned_to" and "userid"
setkey(bug_user_assigned_count, assigned);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_assigned_count, by.x="userid", by.y="assigned", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_bugs_assigned_count = Freq);

# For any NA entries in the "user_bugs_assigned_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_assigned_count = ifelse(is.na(user_bugs_assigned_count), 0, user_bugs_assigned_count));


# PROFILES-ORG-BUGS_ASSIGNED

# Count the bugs assigned to each org in the bugs table
bug_org_assigned_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$assigned_domain)), -Freq), assigned_domain = Var1));

# Merge the "org_bugs_assigned_count" with the profiles table based on "assigned_domain" and "domain" columns
setkey(bug_org_assigned_count, assigned_domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, bug_org_assigned_count, by.x="domain", by.y="assigned_domain", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, org_bugs_assigned_count = Freq);


# PROFILES-USER-BUGS_QA

# Count the bugs where each user is set as QA in the bugs table
bug_user_qa_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$qa_contact)), -Freq), qa = Var1));

# Merge the "user_bugs_qa_count" with the profiles table based on "qa" and "userid"
setkey(bug_user_qa_count, qa);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_qa_count, by.x="userid", by.y="qa", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_bugs_qa_count = Freq);

# For any NA entries in the "user_bugs_qa_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_qa_count = ifelse(is.na(user_bugs_qa_count), 0, user_bugs_qa_count));


# PROFILES-ORG-BUGS_QA

# Count the bugs where each org is set as QA in the bugs table
bug_org_qa_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$qa_domain)), -Freq), qa_domain = Var1));

# Merge the "org_bugs_qa_count" with the profiles table based on "qa_domain" and "domain" columns
setkey(bug_org_qa_count, qa_domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, bug_org_qa_count, by.x="domain", by.y="qa_domain", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, org_bugs_qa_count = Freq);


# BUGS-ACTIVITY

# Import bugs table from previous base subroutine
bugs_working <- bugs_base;

# Group the activities table by bug_id to prepare for DPLYR's summarize() function
activity_working_grouped <- group_by(activity_clean, bug_id);

# Summarize the number of entries for each bug_id in the activity table:
activity_working_summary <- summarize(activity_working_grouped, activity_count = n());

# Merge the activity_working_summary and bugs_working tables based on bug_id to add column activity_count
setkey(activity_working_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_working_summary, by="bug_id", all.x=TRUE);


# BUGS-ACTIVITY-DAYS_OPEN

# Filter the activities table for cases where some sort of resolution has occured
# We want the whole activity_clean table, not just activities_base (by "orgs") because non-org users may have changed a bug status
# The possible resolutions are in "added" and are "CLOSED", "RESOLVED" or "VERIFIED"
# These SHOULD only appear in fieldid 29 which is "bug_status", but sometimes they end up elsewhere, so check for fieldid
activity_resolved <- filter(activity_clean, (added=="CLOSED" & fieldid==29 ) | (added=="RESOLVED" & fieldid==29) | (added=="VERIFIED" & fieldid==29));

# Rearrange the resolved activities by descending date, meaning present, backwards, or most recent dates first
activity_resolved <- arrange(activity_resolved, desc(bug_when));

# Filter the resolved activities to the most recent one per unique bug
# This way, if there are multiple "CLOSED", etc. because of reopening, we only catch the most recent one
activity_resolved_distinct <- distinct(activity_resolved, bug_id);

# Drop all the columns except bug_id and bug_when and rename bug_when to censor_ts to match with new column in bugs_working
activity_resolved_distinct <- select(activity_resolved_distinct, bug_id, censor_ts = bug_when);

# Merge the "activity_resolved" and "bugs_working" tables based on bug_id
setkey(activity_resolved_distinct, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_resolved_distinct, by="bug_id", all.x=TRUE);

# For all the rows that have "pending" outcome, we want to set the end time of the dataset as the censor_ts value
bugs_working <- mutate(bugs_working, censor_ts = ifelse(outcome=="pending", as.character("2013-01-01 10:01:00"), censor_ts));

# In very rare cases, with very old bugs, there is sometimes no entry in the activity table even when there is a resolution
# For those cases, set the censor_ts to delta_ts, the last time it or related tables were modified
bugs_working <- mutate(bugs_working, censor_ts = ifelse(is.na(censor_ts), delta_ts, censor_ts));

# Create a new column that subtracts creation_ts from censor_ts to get number of "days_open"
bugs_working <- mutate(bugs_working, days_open = difftime(as.chron(censor_ts), as.chron(creation_ts), units = "days"));


# BUGS-ACTIVITY-REOPENED

# Filter the activities table for cases where bugs are reopened
# We want the whole activity table, not just activities by "orgs" because non-org users may have reopened the bug
# It SHOULD only appear in fieldid 29 which is "bug_status", but sometimes it ends up elsewhere, so check for fieldid
# "Reopening" can happen from quite a few transitions, not all of which use the actual "REOPENED" status
# Many of these are not legal according to the workflow table, but may exist for historical resons before the current workflow flags
# The possible transitions are listed below as alternatives in the filters
activity_reopened <- filter(activity_clean, (				  added=="REOPENED" 	& fieldid==29) |	# All transitions 			to reopened
									  (removed=="CLOSED" 	& added=="UNCONFIRMED" 	& fieldid==29) |	# Transition from closed 	to unconfirmed
									  (removed=="CLOSED" 	& added=="NEW" 			& fieldid==29) |	# Transition from closed 	to new
									  (removed=="CLOSED" 	& added=="ASSIGNED"		& fieldid==29) |	# Transition from closed 	to assigned
									  (removed=="RESOLVED" 	& added=="ASSIGNED"		& fieldid==29) |	# Transition from resolved 	to assigned
									  (removed=="RESOLVED" 	& added=="NEW"			& fieldid==29) |	# Transition from resolved	to new
									  (removed=="RESOLVED" 	& added=="UNCONFIRMED"	& fieldid==29) |	# Transition from resolved 	to unconfirmed
									  (removed=="VERIFIED" 	& added=="NEW"			& fieldid==29) |	# Transition from verified 	to new
									  (removed=="VERIFIED" 	& added=="UNCONFIRMED"	& fieldid==29) |	# Transition from verified 	to unconfirmed
									  (removed=="VERIFIED" 	& added=="ASSIGNED"		& fieldid==29));	# Transition from verified 	to assigned


# Drop bugs that aren't in the bugs_working table since they have no org involvement
activity_reopened <- filter(activity_reopened, bug_id %in% bugs_working$bug_id);

# Retain only the bug_id column, which acts as our count
activity_reopened <- select(activity_reopened, bug_id);

# Count the number of times each bug_id appears in the list, which is the number of times it was reopened
activity_reopened_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(activity_reopened$bug_id)), -Freq), bug_id = Var1, reopened_count = Freq));

# Merge the activity_reopened_count table with the bugs_working table based on "user_id"
setkey(activity_reopened_count, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_reopened_count, by="bug_id", all.x=TRUE);

# For any NA entries in the "reopened_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, reopened_count = ifelse(is.na(reopened_count), 0, reopened_count));


# BUGS-ACTIVITY-ASSIGNED

# Filter the activity table for entries that represent bug assignment count
# Bug assignment is defined by transition, although sometimes the transition is ignored and the
# change of "assigned_to" person in field 34 is the only evidence of assignment
# We'll operationalize it as transition only because change of "assigned_to" person is most often a bounce rejection
# It's not ideal, but the transitions should be a conservative subset that are actually assignments, whereas
# the inclusion of change of "assigned_to" person is likely to hit a lot of false positives, espeically with tracking userids
# Further, jump transitions from new or unconfirmed directly to resolved may indicate a assignment and fix 
# or it may indicate a rejection as wontfix or invalid, so can't include in this conservative measure
# Manual inspection of the rare cases of new or unconfirmed going straight to verified suggest no assignment took place
# so we don't include those cases.
# The possible transitions are listed as alternatives int he filters as follows:

activity_assigned <- filter(activity_clean, (removed=="NEW"			& added=="ASSIGNED"		& fieldid==29) |
											(removed=="REOPENED"	& added=="ASSIGNED"		& fieldid==29) |
											(removed=="UNCONFIRMED"	& added=="ASSIGNED"		& fieldid==29) |
											(removed=="VERIFIED" 	& added=="ASSIGNED" 	& fieldid==29) |
											(removed=="RESOLVED" 	& added=="ASSIGNED"		& fieldid==29));

# Drop bugs that aren't in the bugs_working table since they aren't relevant
activity_assigned <- filter(activity_assigned, bug_id %in% bugs_working$bug_id);

# Use DPLYR group_by() function to organize the activity_assigned table by bug_id to prepare for summarize() function
activity_assigned_grouped <- group_by(activity_assigned, bug_id);

# Use DPLYR summarize() to get the count of assignment activities per bug_id
activity_assigned_summary <- summarize(activity_assigned_grouped, assigned_count=n());

# Merge the activity_assigned_summary table with the bugs_working table based on "user_id"
setkey(activity_assigned_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_assigned_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "assigned_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, assigned_count = ifelse(is.na(assigned_count), 0, assigned_count));


# BUGS-ACTIVITY-REASSIGNED

# Filter the activities table for cases where bugs were once assigned, but assignment ownership is rejected and reset, which we call "reassignment"
# Technically it's one-sided since a different owner also has to accept, which we measured separately above in the assigned_count
# We want the whole activity table, not just activities by "orgs" because non-org users may have rejected the bug assignment
# Reassignment is measured by transitions in fieldid==29
# "Reassigning" can happen from several transitions
# Further, it's possible that reassignment happens as part of reopening, so this status change isn't only measure
# Same reasoning for using transitions instead of changes in "assigned_to" as above
# The possible transitions are listed below as alternatives in the filters as follows:
activity_reassigned <- filter(activity_clean, (removed=="REOPENED"	& added=="NEW"			& fieldid==29) |
											  (removed=="REOPENED"	& added=="UNCONFIRMED"	& fieldid==29) |
											  (removed=="VERIFIED"	& added=="RESOLVED"		& fieldid==29) |
											  (removed=="ASSIGNED"  & added=="NEW" 			& fieldid==29) |
											  (removed=="ASSIGNED" 	& added=="UNCONFIRMED" 	& fieldid==29) |
											  (removed=="ASSIGNED" 	& added=="REOPENED"		& fieldid==29));


# Drop bugs that aren't in the bugs_working table since they aren't relevant
activity_reassigned <- filter(activity_reassigned, bug_id %in% bugs_working$bug_id);

# Use DPLYR group_by() function to organize the activity_reassigned table by bug_id to prepare for summarize() function
activity_reassigned_grouped <- group_by(activity_reassigned, bug_id);

# Use DPLYR summarize() to get the count of reassignment activities per bug_id
activity_reassigned_summary <- summarize(activity_reassigned_grouped, reassigned_count=n());

# Merge the activity_reassigned_summary table with the bugs_working table based on "user_id"
setkey(activity_reassigned_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_reassigned_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "reassigned_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, reassigned_count = ifelse(is.na(reassigned_count), 0, reassigned_count));


# BUGS-LONGDESCS-DESCRIPTION-LENGTH

# Count the number of chracters in the title ("short_desc") and make that its own column, "title_length"
# Since nchar() returns 2 when title is blank, our ifelse catches that case and sets it to 0
bugs_working <- mutate(bugs_working, title_length = ifelse(short_desc=="", 0, nchar(short_desc)));

# We want to count the number of characters in the initial comment when the bug was filed. This is effectively the
# "bug description" even though it's handled the same way as other comments.

# Import longdescs table from the original database inport and make it a data.table
# We want the whole longdescs_clean (not org-only long_descs_base) table because the reporter might not be an org user but one of the other
# actors may be; otherwise, many results will end up NA
longdescs_working <- longdescs_clean;

# Create a new column in the longdescs_working table that has the character length of each comment
# Since nchar() returns 2 when comment is blank, our ifelse catches that case and sets it to 0
longdescs_working <- mutate(longdescs_working, comment_length = ifelse(thetext=="", 0, nchar(thetext)));

# Rearrange the longdescs in the table by date, leaving most distant dates first, and most recent dates last
longdescs_working_arranged <- arrange(longdescs_working, bug_when);

# Filter to the first comment for each bug_id, which should be the submission full bug description
longdescs_working_distinct <- distinct(longdescs_working_arranged, bug_id);

# Drop all the columns except bug_id and comment_length
longdescs_working_distinct <- select(longdescs_working_distinct, bug_id, comment_length);

# Merge the "longdescs_working_distinct" and "bugs_working" tables based on bug_id to add column "description_length"
setkey(longdescs_working_distinct, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_working_distinct, by="bug_id", all.x=TRUE);
bugs_working <- dplyr::rename(bugs_working, description_length = comment_length);


# BUGS-LONGDESCS-COMMENTS-LENGTH

# We can reuse the longdescs_working variable from above, so no need to import it again
# It already has the comment length column added.  We just need to sum those for each bug_id
# First, we'll use Dplyr's group_by() command to set a flag in the data.frame that bug_ids should be grouped
longdescs_working_grouped <- group_by(longdescs_working, bug_id);

# Now we'll use Dplyr's summarize() command to extract the sums of the comments column for each bug_id
longdescs_working_summary <- summarize(longdescs_working_grouped, comments_length = sum(comment_length));

# Merge the longdescs_working_summary and bugs_working tables based on bug_id to add column comments_length
setkey(longdescs_working_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_working_summary, by="bug_id", all.x=TRUE);

# The comments_length variable includes the description_length, so subtract it:
bugs_working <- mutate(bugs_working, comments_length = comments_length - description_length);


# PROFILES-USER-BUGS_REPORTED-REOPENED_OR_ASSIGNED_OR_REASSIGNED
# (Track how many times each user that reported a bug, had it reopened, assigned or reassigned)

# Use DPLYR's group_by() function to organize bugs_working table according to reporter userid
bugs_working_grouped_reporter <- group_by(bugs_working, reporter);

# Use DPLYR's summarize() function to sum reopened, assigned, and reassigned count across all bugs for each reporter
bugs_working_grouped_user_reporter_summary <- summarize(bugs_working_grouped_reporter,	user_bugs_reported_reopened_count	= sum(reopened_count),
																						user_bugs_reported_assigned_count	= sum(assigned_count),
																						user_bugs_reported_reassigned_count = sum(reassigned_count));

# Merge the "bugs_working_grouped_user_reporter_summary" table with the profiles table based on "reporter" and "userid"
setkey(bugs_working_grouped_user_reporter_summary, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_grouped_user_reporter_summary, by.x="userid", by.y="reporter", all.x=TRUE);

# For any NA entries in the count columns, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_reported_reopened_count 		= ifelse(is.na(user_bugs_reported_reopened_count), 	 0, user_bugs_reported_reopened_count),
											 user_bugs_reported_assigned_count 		= ifelse(is.na(user_bugs_reported_assigned_count), 	 0, user_bugs_reported_assigned_count),
											 user_bugs_reported_reassigned_count 	= ifelse(is.na(user_bugs_reported_reassigned_count), 0, user_bugs_reported_reassigned_count));


# PROFILES-ORG-BUGS_REPORTED-REOPENED_OR_ASSIGNED_OR_REASSIGNED
# (Track how many times each org that was a bug's reporter, had it reopened, assigned or reassigned)

# Use DPLYR's group_by() function to organize bugs_working table according to reporter_domain
bugs_working_grouped_reporter_domain <- group_by(bugs_working, reporter_domain);

# Use DPLYR's summarize() function to sum reopened, assigned, and reassigned count across all bugs for each reporter_domain
bugs_working_grouped_org_reporter_summary <- summarize(bugs_working_grouped_reporter_domain, org_bugs_reported_reopened_count 	= sum(reopened_count),
																							 org_bugs_reported_assigned_count 	= sum(assigned_count),
																							 org_bugs_reported_reassigned_count = sum(reassigned_count));

# Merge the "bugs_working_grouped_org_reporter_summary" table with the profiles table based on "reporter_domain" and "domain"
setkey(bugs_working_grouped_org_reporter_summary, reporter_domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, bugs_working_grouped_org_reporter_summary, by.x="domain", by.y="reporter_domain", all.x=TRUE);

# For any NA entries in the count column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, org_bugs_reported_reopened_count = ifelse(is.na(org_bugs_reported_reopened_count), 	0, org_bugs_reported_reopened_count),
											 org_bugs_reported_assigned_count = ifelse(is.na(org_bugs_reported_assigned_count), 	0, org_bugs_reported_assigned_count),
											 org_bugs_reported_reassigned_count = ifelse(is.na(org_bugs_reported_reassigned_count), 0, org_bugs_reported_reassigned_count));

#HERE
# PROFILES-USER-BUGS_ASSIGNED-REASSIGNED
# (Track how many times each user that was set as assigned_to a bug, had it reassigned on them)

# Use DPLYR's group_by() function to organize bugs_working table according to assigned userid
bugs_working_grouped_assigned_to <- group_by(bugs_working, assigned_to);

# Use DPLYR's summarize() function to sum reassigned count across all bugs for each assigned_to user
bugs_working_grouped_user_assigned_to_summary <- summarize(bugs_working_grouped_assigned_to, user_bugs_assigned_to_reassigned_count = sum(reassigned_count));

# Merge the "bugs_working_grouped_user_assigned_to_summary" table with the profiles table based on "assigned_to" and "userid"
setkey(bugs_working_grouped_user_assigned_to_summary, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_grouped_user_assigned_to_summary, by.x="userid", by.y="assigned_to", all.x=TRUE);

# For any NA entries in the "user_bugs_assigned_to_reassigned_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_reassigned_count = ifelse(is.na(user_bugs_assigned_to_reassigned_count), 0, user_bugs_assigned_to_reassigned_count));


# PROFILES-ORG-BUGS_ASSIGNED-REASSIGNED
# (Track how many times each org that was set as assigned_to for a bug, had it reassigned on them)

# Use DPLYR's group_by() function to organize bugs_working table according to assigned_domain
bugs_working_grouped_assigned_domain <- group_by(bugs_working, assigned_domain);

# Use DPLYR's summarize() function to sum reassigned count across all bugs for each assigned_domain
bugs_working_grouped_org_assigned_summary <- summarize(bugs_working_grouped_assigned_domain, org_bugs_assigned_reassigned_count = sum(reassigned_count));

# Merge the "bugs_working_grouped_org_assigned_summary" table with the profiles table based on "assigned_domain" and "domain"
setkey(bugs_working_grouped_org_assigned_summary, assigned_domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, bugs_working_grouped_org_assigned_summary, by.x="domain", by.y="assigned_domain", all.x=TRUE);

# For any NA entries in the "org_bugs_assigned_reassigned_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, org_bugs_assigned_reassigned_count = ifelse(is.na(org_bugs_assigned_reassigned_count), 0, org_bugs_assigned_reassigned_count));


# PROFILES-USER-BUGS_QA-REASSIGNED
# (Track how many times each user that was set as qa_contact a bug, had it reassigned on them)

# Use DPLYR's group_by() function to organize bugs_working table according to qa_contact userid
bugs_working_grouped_qa_contact <- group_by(bugs_working, qa_contact);

# Use DPLYR's summarize() function to sum reassigned count across all bugs for each qa_contact user
bugs_working_grouped_user_qa_contact_summary <- summarize(bugs_working_grouped_qa_contact, user_bugs_qa_contact_reassigned_count = sum(reassigned_count));

# Merge the "bugs_working_grouped_user_qa_contact_summary" table with the profiles table based on "qa_contact" and "userid"
setkey(bugs_working_grouped_user_qa_contact_summary, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_grouped_user_qa_contact_summary, by.x="userid", by.y="qa_contact", all.x=TRUE);

# For any NA entries in the "user_bugs_qa_contact_reassigned_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_reassigned_count = ifelse(is.na(user_bugs_qa_contact_reassigned_count), 0, user_bugs_qa_contact_reassigned_count));


# PROFILES-ORG-BUGS_QA-REASSIGNED
# (Track how many times each org that was set as qa_contact for a bug, had it reassigned on them)

# Use DPLYR's group_by() function to organize bugs_working table according to qa_domain
bugs_working_grouped_qa_domain <- group_by(bugs_working, qa_domain);

# Use DPLYR's summarize() function to sum reassigned count across all bugs for each qa_domain
bugs_working_grouped_org_qa_summary <- summarize(bugs_working_grouped_qa_domain, org_bugs_qa_reassigned_count = sum(reassigned_count));

# Merge the "bugs_working_grouped_org_qa_summary" table with the profiles table based on "qa_domain" and "domain"
setkey(bugs_working_grouped_org_qa_summary , qa_domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, bugs_working_grouped_org_qa_summary , by.x="domain", by.y="qa_domain", all.x=TRUE);

# For any NA entries in the "org_bugs_qa_reassigned_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, org_bugs_qa_reassigned_count = ifelse(is.na(org_bugs_qa_reassigned_count), 0, org_bugs_qa_reassigned_count));


# PROFILES-USER-ACTIVITY-ASSIGNING
# (Track how many times each user has done the activity of assigning a bug)

# This time, we need activity_base so that we can match up with domains, which aren't in activity_clean

activity_base_assigned <- filter(activity_base, (removed=="NEW"			& added=="ASSIGNED"		& fieldid==29) |
												(removed=="REOPENED"	& added=="ASSIGNED"		& fieldid==29) |
												(removed=="UNCONFIRMED"	& added=="ASSIGNED"		& fieldid==29) |
												(removed=="VERIFIED" 	& added=="ASSIGNED" 	& fieldid==29) |
												(removed=="RESOLVED" 	& added=="ASSIGNED"		& fieldid==29));

# Use DPLYR's group_by() function to organize the activity_base_assigned table according to the "who" did the assigning actiivty
activity_base_assigned_grouped_who <- group_by(activity_base_assigned, who);

# Use DPLYR's summarize() function to sum assigning activity according for each user
activity_base_assigned_grouped_who_summary <- summarize(activity_base_assigned_grouped_who, user_activity_assigning_count = n());

# Merge the "activity_base_assigned_grouped_who_summary" table with the profiles table according to "who" and "userid"
setkey(activity_base_assigned_grouped_who_summary, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_base_assigned_grouped_who_summary, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries in the "user_activity_assigning_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_activity_assigning_count = ifelse(is.na(user_activity_assigning_count), 0, user_activity_assigning_count));


# PROFILES-ORG-ACTIVITY-ASSIGNING
# (Track how many times each org has done the activity of assigning a bug)

# Use DPLYR's group_by() function to organize the activity_base_assigned table according to the "domain" that did the assigning actiivty
activity_base_assigned_grouped_domain <- group_by(activity_base_assigned, domain);

# Use DPLYR's summarize() function to sum assigning activity according for each org
activity_base_assigned_grouped_domain_summary <- summarize(activity_base_assigned_grouped_domain, org_activity_assigning_count = n());

# Merge the "activity_base_assigned_grouped_domain_summary" table with the profiles table according to "domain"
setkey(activity_base_assigned_grouped_domain_summary, domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, activity_base_assigned_grouped_domain_summary, by="domain", all.x=TRUE);

# For any NA entries in the "org_activity_assigning_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, org_activity_assigning_count = ifelse(is.na(org_activity_assigning_count), 0, org_activity_assigning_count));


# PROFILES-USER-ACTIVITY-REASSIGNING
# (Track how many times each user has done the activity of reassigning a bug)

# This time, we need activity_base so that we can match up with domains, which aren't in activity_clean

activity_base_reassigned <- filter(activity_base,  (removed=="REOPENED"		& added=="NEW"			& fieldid==29) |
												   (removed=="REOPENED"		& added=="UNCONFIRMED"	& fieldid==29) |
												   (removed=="VERIFIED"		& added=="RESOLVED"		& fieldid==29) |
												   (removed=="ASSIGNED"  	& added=="NEW" 			& fieldid==29) |
												   (removed=="ASSIGNED" 	& added=="UNCONFIRMED" 	& fieldid==29) |
												   (removed=="ASSIGNED" 	& added=="REOPENED"		& fieldid==29));

# Use DPLYR's group_by() function to organize the activity_base_reassigned table according to the "who" did the reassigning actiivty
activity_base_reassigned_grouped_who <- group_by(activity_base_reassigned, who);

# Use DPLYR's summarize() function to sum reassigning activity according for each user
activity_base_reassigned_grouped_who_summary <- summarize(activity_base_reassigned_grouped_who, user_activity_reassigning_count = n());

# Merge the "activity_base_reassigned_grouped_who_summary" table with the profiles table according to "who" and "userid"
setkey(activity_base_reassigned_grouped_who_summary, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_base_reassigned_grouped_who_summary, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries in the "user_activity_reassigning_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_activity_reassigning_count = ifelse(is.na(user_activity_reassigning_count), 0, user_activity_reassigning_count));


# PROFILES-ORG-ACTIVITY-REASSIGNING
# (Track how many times each org has done the activity of reassigning a bug)

# Use DPLYR's group_by() function to organize the activity_base_reassigned table according to the "domain" that did the reassigning actiivty
activity_base_reassigned_grouped_domain <- group_by(activity_base_reassigned, domain);

# Use DPLYR's summarize() function to sum reassigning activity according for each org
activity_base_reassigned_grouped_domain_summary <- summarize(activity_base_reassigned_grouped_domain, org_activity_reassigning_count = n());

# Merge the "activity_base_reassigned_grouped_domain_summary" table with the profiles table according to "domain"
setkey(activity_base_reassigned_grouped_domain_summary, domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, activity_base_reassigned_grouped_domain_summary, by="domain", all.x=TRUE);

# For any NA entries in the "org_activity_reassigning_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, org_activity_reassigning_count = ifelse(is.na(org_activity_reassigning_count), 0, org_activity_reassigning_count));


# PROFILES-USER-ACTIVITY-REOPENING
# (Track how many times each user has done the activity of reopening a bug)

# This time, we need activity_base so that we can match up with domains, which aren't in activity_clean

activity_base_reopened <- filter(activity_base, (			  added=="REOPENED" 	& fieldid==29) |	# All transitions 			to reopened
									  (removed=="CLOSED" 	& added=="UNCONFIRMED" 	& fieldid==29) |	# Transition from closed 	to unconfirmed
									  (removed=="CLOSED" 	& added=="NEW" 			& fieldid==29) |	# Transition from closed 	to new
									  (removed=="CLOSED" 	& added=="ASSIGNED"		& fieldid==29) |	# Transition from closed 	to assigned
									  (removed=="RESOLVED" 	& added=="ASSIGNED"		& fieldid==29) |	# Transition from resolved 	to assigned
									  (removed=="RESOLVED" 	& added=="NEW"			& fieldid==29) |	# Transition from resolved	to new
									  (removed=="RESOLVED" 	& added=="UNCONFIRMED"	& fieldid==29) |	# Transition from resolved 	to unconfirmed
									  (removed=="VERIFIED" 	& added=="NEW"			& fieldid==29) |	# Transition from verified 	to new
									  (removed=="VERIFIED" 	& added=="UNCONFIRMED"	& fieldid==29) |	# Transition from verified 	to unconfirmed
									  (removed=="VERIFIED" 	& added=="ASSIGNED"		& fieldid==29));	# Transition from verified 	to assigned


# Use DPLYR's group_by() function to organize the activity_base_reopened table according to the "who" did the reopening actiivty
activity_base_reopened_grouped_who <- group_by(activity_base_reopened, who);

# Use DPLYR's summarize() function to sum reopening activity according for each user
activity_base_reopened_grouped_who_summary <- summarize(activity_base_reopened_grouped_who, user_activity_reopening_count = n());

# Merge the "activity_base_reopened_grouped_who_summary" table with the profiles table according to "who" and "userid"
setkey(activity_base_reopened_grouped_who_summary, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_base_reopened_grouped_who_summary, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries in the "user_activity_reopening_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_activity_reopening_count = ifelse(is.na(user_activity_reopening_count), 0, user_activity_reopening_count));


# PROFILES-ORG-ACTIVITY-REOPENING
# (Track how many times each org has done the activity of reopening a bug)


# Use DPLYR's group_by() function to organize the activity_base_reopened table according to the "domain" that did the reopening actiivty
activity_base_reopened_grouped_domain <- group_by(activity_base_reopened, domain);

# Use DPLYR's summarize() function to sum reopening activity according for each org
activity_base_reopened_grouped_domain_summary <- summarize(activity_base_reopened_grouped_domain, org_activity_reopening_count = n());

# Merge the "activity_base_reopened_grouped_domain_summary" table with the profiles table according to "domain"
setkey(activity_base_reopened_grouped_domain_summary, domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, activity_base_reopened_grouped_domain_summary, by="domain", all.x=TRUE);

# For any NA entries in the "org_activity_reopening_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, org_activity_reopening_count = ifelse(is.na(org_activity_reopening_count), 0, org_activity_reopening_count));










# Set global variables for other functions
profiles_interactions 	<<- profiles_working;
bugs_interactions 		<<- bugs_working;
longdescs_interactions	<<- longdescs_working;


} # End operationalize_interactions function



run_main <- function () {
	load_libraries();
	load_bugzilla_data();
	clean_bugzilla_data();
	operationalize_base();
	operationalize_interactions();
} # End run_main function




	

run_main();

# Perform garbage collection to free memory

gc();

#
# EOF

