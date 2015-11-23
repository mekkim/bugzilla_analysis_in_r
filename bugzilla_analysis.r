#################################################################################
#																				#
# 		ANALYZING MOZILLA'S BUGZILLA DATABASE USING R							#
#																				#
#		© 2015 by Mekki MacAulay, mekki@mekki.ca, http://mekki.ca				#
#		Twitter: @mekki - http://twitter.com/mekki								#
#		Some rights reserved.													#
#																				#
#		Current version created on November 23, 2015							#
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
#
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
# Add the mysql/bin folder to the PATH system environment
# Its default location is C:\Program Files\MySQL\MySQL Server 5.5\bin, but could
# vary depending on your install parameters
#
# RESTORE BUGZILLA DATABASE (Current version includes data until end of 2012)
#
# Decompress/untar the Bugzilla database.  The result is a MySQL-formatted dumpfile with a .sql extension
# I'll assume that the file name is "2013_01_sanitized_bugzilla.sql". If it's not, change the name in the commands below.
# This dumpfile only works with MySQl databases.  It cannot be restored to other databases such as SQLite, PostGRESQL, MSSQL, etc.
# It is also sufficiently complex that scripts cannot readily be used to convert it to a dumpfile of a different format
# 
# Open the standard command prompt as administrator and type the following 3 commands, hitting enter after each one:
#
# mysql -uroot -ppassword --execute="DROP DATABASE `bugs`;"
# mysql -uroot -ppassword --execute="CREATE DATABASE `bugs`;"
# mysql -uroot -ppassword bugs < 2013_01_sanitized_bugzilla.sql
# 
# The last command will execute for several minutes as it populates the database with the dumpfile data 
# The result will be a database named "bugs" on the MySQL server, filled with the Bugzilla data
# 
# 
# INSTALL AND CONFIGURE R (Statistical package) or RRO (Revolution R Open enhanced R distribution)
#
# Visit: http://cran.utstat.utoronto.ca/bin/windows/base/ or another mirror
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
# googleVis https://cran.r-project.org/web/packages/googleVis/index.html -> Not used presently.  Seems buggy.
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
# tidyr
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
# I chose x64 Thread Safe, but the other ones should work too
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
# The small php program "domainparser.php" is provided and uses the installed domain parser library
#
# END OF DEPENDENCIES TO RUN SCRIPT
#
#################################################################################

#################################################################################
# 								START OF SCRIPT									#
#################################################################################


# SET USER-DEFINED PARAMETERS
set_parameters <- function () {

# Set the date & time for the end fo the database snapshot
DATABASE_END_TIMESTAMP			<<- as.POSIXct("2013-01-01 10:01:00", format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01");
BAD_PROFILE_CREATION_TIMESTAMP 	<<- as.POSIXct("2011-04-23 07:05:38", format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01");

} # End set_parameters function


# SET R OPTIONS FOR CODE EXECUTION ENVIRONMENT
set_options <- function () {

# Increase the memory limit to force Windows to use the pagefile for all other processes and allocate 
# maximum amount of physical RAM to R
memory.limit(65000);

# Set warnings to display as they occur and give verbose output
options(warn=1, verbose=TRUE);

} # End set_options function


# LOAD LIBRARIES
load_libraries <- function () {

# Load MySQl connection library
library(RMySQL);

# Load the Data.table library for data.table objects and fread() function
library(data.table);

# Load plyr and dplyr and tidyr libraries for data table manipulation functions
library(plyr);
library(dplyr);
library(tidyr);

# Load chron for easy date-time manipulation and calculation
library(chron);

} # End load_libraries function


# UTILITY FUNCTIONS

# CALCULATE QUANTILES/QUARTILES in all 9 type models and display comparison
calculate_quantiles <- function(x, probs=seq(0,1, 0.25), decimals=6, dropNA=TRUE) {
	res <- matrix(as.numeric(NA), 9, length(probs));
	for(type in 1:9) res[type, ] <- y <- quantile(x, probs, na.rm=dropNA, type=type);
	dimnames(res) <- list(1:9, names(y));
	round(res, decimals);

} # End calculate_quantiles function


# SAFE IF-ELSE
# Fix the stripping of class and/or factor attributes when using base ifelse()
safe_ifelse <- function(cond, yes, no, preserved_attributes = "no") {
	
	preserved 			<- switch(EXPR = preserved_attributes, "cond" = cond, "yes" = yes, "no" = no);
	preserved_class 	<- class(preserved);
	preserved_levels 	<- levels(preserved);
	preserved_is_factor	<- "factor" %in% preserved_class;
	
	return_obj <- ifelse(cond, yes, no);
			
	if (preserved_is_factor) {
		return_obj 		   	<- as.factor(return_obj);
		levels(return_obj) 	<- preserved_levels;
	} else {
		class(return_obj) 	<- preserved_class;
	}
	return(return_obj);
  
} # End safe if-else function


# DATA INPUT

# In this step, we create and populate all of the data frames/tables that will be manipulated in the research
# from their data sources including the MySQL database and CSV files.

# Bugzilla data frames/tables
load_bugzilla_data <- function () {

# Create variable with MySQL database connection details:
# These details need to match the username, password, database name, and host as 
# configured during the installation of dependencies
bugzilla <- dbConnect(MySQL(), user='root', password='password', dbname='bugs', host='localhost');

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
keywords		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM keywords;');
flags			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM flags;');

# We're now done with the RMySQL library, so detach it to prevent any problems
detach("package:RMySQL", unload=TRUE);

# After we've loaded all the data, the MySQL server hogs RAM because of its cashing, so restart it
# with the following commands to free up memory:
system("net stop MySQL");
system("net start MySQL");

} # End load_bugzilla_data function

# Compustat functions are included for my dissertation work and depend on access to a specific set of
# compustat data that I cannot redistribute.  They're commented out in the main() function so you can safely ignore.
# Compustat data frames/tables
load_compustat_data <- function () {

# Create data frame variables from the COMPUSTAT CSV files
# We'll use the fread function in data.table

compustatna 	<<- fread("compustatna.csv");
compustatint 	<<- fread("compustatint.csv");

} # End load_compustat_data function


# Mimetypes / Internet Media Types from Internet Assigned Numbers Authority (IANA)
load_mimetypes <- function () {

# Read all 8 CSV files, one for each registry, from IANA update list at http://www.iana.org/assignments/media-types/media-types.xml
# We only really care about the "Template" column, which we'll use for matching later
application_mimetypes	<- read.csv('http://www.iana.org/assignments/media-types/application.csv');
audio_mimetypes			<- read.csv('http://www.iana.org/assignments/media-types/audio.csv');
image_mimetypes			<- read.csv('http://www.iana.org/assignments/media-types/image.csv');
message_mimetypes		<- read.csv('http://www.iana.org/assignments/media-types/message.csv');
model_mimetypes			<- read.csv('http://www.iana.org/assignments/media-types/model.csv');
multipart_mimetypes		<- read.csv('http://www.iana.org/assignments/media-types/multipart.csv');
text_mimetypes			<- read.csv('http://www.iana.org/assignments/media-types/text.csv');
video_mimetypes			<- read.csv('http://www.iana.org/assignments/media-types/video.csv');

# We want it all to lowercase to make matching easier
application_mimetypes	<<- mutate(application_mimetypes, 	Template = tolower(Template));
audio_mimetypes			<<- mutate(audio_mimetypes, 		Template = tolower(Template));
image_mimetypes			<<- mutate(image_mimetypes, 		Template = tolower(Template));
message_mimetypes		<<- mutate(message_mimetypes, 		Template = tolower(Template));
model_mimetypes			<<- mutate(model_mimetypes, 		Template = tolower(Template));
multipart_mimetypes		<<- mutate(multipart_mimetypes, 	Template = tolower(Template));
text_mimetypes			<<- mutate(text_mimetypes, 			Template = tolower(Template));
video_mimetypes			<<- mutate(video_mimetypes, 		Template = tolower(Template));

} # End load_mimetypes function

# END DATA INPUT


# CLEAN BASE DATA

# In this step, we isolate the useful constructs for analysis
# Often, we'll create multiple operationalizations for similar things
 
# Domains: COMPUSTAT
# Compustat functions are included for my dissertation work and depend on access to a specific set of
# compustat data that I cannot redistribute.  They're commented out in the execution so you can safely ignore.
clean_compustat_data <- function () { 
# Since we're going to cross-reference the Bugzilla and COMPUSTAT databases using website,
# we want to isolate the unique URLs in the COMPUSTAT data sets
weburlint 	<- compustatint$weburl;
weburlna 	<- compustatna$weburl;

# Trim off the leading "www."
weburlint 	<- sub("^www\\.((?:[a-z0-9-]+\\.)+[a-z]{2,4})$", "\\1", weburlint, ignore.case = TRUE, perl = TRUE);
weburlna 	<- sub("^www\\.((?:[a-z0-9-]+\\.)+[a-z]{2,4})$", "\\1", weburlna, ignore.case = TRUE, perl = TRUE);

# Trim off the trailing "/index.html" or other trailing parts
weburlint	<- sub("^((?:[a-z0-9-]+\\.)+[a-z]{2,4})\\/.*$", "\\1", weburlint, ignore.case = TRUE, perl = TRUE);
weburlna	<- sub("^((?:[a-z0-9-]+\\.)+[a-z]{2,4})\\/.*$", "\\1", weburlna, ignore.case = TRUE, perl = TRUE);

# Reduce to unique, non-"" values
compustat_domains_int	<<- unique(weburlint[weburlint !=""]);
compustat_domains_na	<<- unique(weburlna[weburlna !=""]);

# Create an "all" value for when necessary, without duplicates
compustat_domains <<- unique(c(weburlint, weburlna));

} # End clean_compustat_data function


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
# Commented out because preserving it could be useful to identify pre-mozilla foundation creation people
# profiles_no_webmail$domain	<- sub("^formerly-netscape\\.com$", "netscape\\.com", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);

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


# Some users are known to have organizational affiliations not related to their domain.  This list is necessarily incomplete.
# Currently commented out because we want deliberate selection if/when these users are merged into their supposed orgs
# Further, org association is only current as of the date of this file and could change latter, so leaving it commented out is best unless temporarily changed for testing.
#profiles_no_webmail$domain	<- sub("^joshmatthews\\.met", "mozilla\\.org", profiles_no_webmail$domain, ignore.case = TRUE, perl = TRUE);



# The "userid" field in the profiles table got incorrectly autodetected as "integer", so set it to factor
# Adjust other variable types as appropriate

profiles_no_webmail <- mutate(profiles_no_webmail,  userid 					= as.factor(userid),
													disable_mail			= as.logical(disable_mail),
													first_patch_bug_id 		= as.factor(first_patch_bug_id),
													is_enabled				= as.logical(is_enabled),
													first_patch_approved_id	= as.factor(first_patch_approved_id),
													mybugslink				= as.logical(mybugslink),
													creation_ts				= as.POSIXct(creation_ts, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"));


# BUGS

# Import the bugs table from the previous subroutine to work on
bugs_working <- bugs;

# Set fields that were incorrectly set as integer to factors
bugs_working <- mutate(bugs_working, bug_id 					= as.factor(bug_id),
									 assigned_to 				= as.factor(assigned_to),
									 reporter 					= as.factor(reporter),
									 qa_contact					= as.factor(qa_contact),
									 everconfirmed				= as.logical(everconfirmed),
									 reporter_accessible		= as.logical(reporter_accessible),
									 cclist_accessible			= as.logical(cclist_accessible),
									 product_id					= as.factor(product_id),
									 component_id				= as.factor(component_id),
									 creation_ts				= as.POSIXct(creation_ts, 		format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
									 delta_ts					= as.POSIXct(delta_ts, 			format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
									 lastdiffed					= as.POSIXct(lastdiffed, 		format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
									 cf_last_resolved			= as.POSIXct(cf_last_resolved, 	format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"));	

# Bugs 8358, 14616, 16198, 16199, 16473, & 16532 are incomplete "test" bugs that aren't real, so delete via manual imputation.
bugs_working <- filter(bugs_working, !(bug_id %in% c("8358", "14616", "16198", "16199", "16473", "16532")));

# Rename the default "votes" column to "votes_all_actors_count" to be consistent with other similar variable names
bugs_working <- dplyr::rename(bugs_working, votes_all_actors_count = votes);


# LONGDESCS

# Import the longdescs table from the previous subroutine to work on
longdescs_working <- longdescs;

# Set fields that were incorrectly set as integer to factors
longdescs_working <- mutate(longdescs_working, bug_id 			= as.factor(bug_id),
											   who 				= as.factor(who),
											   isprivate		= as.logical(isprivate),
											   already_wrapped 	= as.logical(already_wrapped),
											   comment_id		= as.factor(comment_id),
											   type				= as.factor(type),
											   bug_when			= as.POSIXct(bug_when, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"));


# ACTIVITY

# Import the activity table from the previous subroutine to work on
activity_working <- activity;

# Set fields that were incorrectly set as integer to factors
activity_working <- mutate(activity_working, bug_id 	= as.factor(bug_id),
											 who		= as.factor(who),
											 fieldid	= as.factor(fieldid),
											 attach_id	= as.factor(attach_id),
											 comment_id = as.factor(comment_id),
											 bug_when 	= as.POSIXct(bug_when, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"));


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
attachments_working <- mutate(attachments_working, bug_id 				= as.factor(bug_id),
												   submitter_id 		= as.factor(submitter_id),
												   mimetype 			= tolower(mimetype),
												   attach_id			= as.factor(attach_id),
												   ispatch				= as.logical(ispatch),
												   isobsolete 			= as.logical(isobsolete),
												   isprivate			= as.logical(isprivate),
												   isurl				= as.logical(isurl),
												   creation_ts			= as.POSIXct(creation_ts, 		format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
												   modification_time 	= as.POSIXct(modification_time, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"));


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

													   
# KEYWORDS

# Import the keywords table from the previous subroutine to work on
keywords_working <- keywords;

# Set the fields types for proper matching later
keywords_working <- mutate(keywords_working, bug_id 	= as.factor(bug_id),
											 keywordid	= as.factor(keywordid));
											 

# FLAGS

# Import the flags table from the previous subroutine to work on
flags_working <- flags;

# Set the fields types for proper matching later
flags_working <- mutate(flags_working, 	bug_id 				= as.factor(bug_id),
										setter_id			= as.factor(setter_id),
										creation_date		= as.POSIXct(creation_date, 	format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
										modification_date	= as.POSIXct(modification_date, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"));
										
											 
# Create global variable to use in other functions
# Make them all data.tables along the way since we'll use functions from the data.tables library throughout

profiles_clean 					<<- as.data.table(profiles_no_webmail);
bugs_clean						<<- as.data.table(bugs_working);
longdescs_clean					<<- as.data.table(longdescs_working);
activity_clean					<<- as.data.table(activity_working);
cc_clean						<<- as.data.table(cc_working);
attachments_clean				<<- as.data.table(attachments_working);
votes_clean						<<- as.data.table(votes_working);
watch_clean						<<- as.data.table(watch_working);
duplicates_clean				<<- as.data.table(duplicates_working);
group_members_clean				<<- as.data.table(group_members_working);
keywords_clean					<<- as.data.table(keywords_working);
flags_clean						<<- as.data.table(flags_working);
group_list_clean				<<- as.data.table(group_list);


} # End clean_bugzilla_data function

# END CLEAN BASE DATA


# CREATE BASE OPERATIONALIZED VARIABLES

operationalize_base <- function () {

# PROFILES

# Import the profiles_clean table from the previous subroutine to work on
profiles_working <- profiles_clean;

# Create a new column that subtracts the profile creation timestamp from the DATABASE_END_TIMESTAMP parameter to get age of profile in days
# There is no way to get a timestamp of when disabled accounts were disabled, so we can't calculate their age when disabled, unfortunately
# Another unfortunate problem is that about 30% of the creation_ts values are the same value, suggesting that some sort of merge/restore happened
# on April 23, 2011 (2011-04-23 07:05:38), which incorrectly reset the creation timestamps to that date/time.  As such, those values are bad and have to be set to NA instead
profiles_working <- mutate(profiles_working, profile_age = safe_ifelse(creation_ts==BAD_PROFILE_CREATION_TIMESTAMP, NA, as.double(difftime(DATABASE_END_TIMESTAMP, creation_ts, units = "secs")) / 86400));


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

# Bug_severity column gets types set wrong, so reset it here
severity_lookup$bug_severity <- as.character(severity_lookup$bug_severity);
severity_lookup$severity	 <- as.factor(severity_lookup$severity);

# Merge the new "severity" numerical column according to "bug_severity"
setkey(severity_lookup, bug_severity);
setkey(bugs_working, bug_severity);
bugs_working <- merge(bugs_working, severity_lookup, by='bug_severity', all.x=TRUE);


# Add a outcome variable that reduces "bug_status" and "resolution" to one of "fixed", "not_fixed", or "pending"
# Read in the outcome lookup table from file
outcome_lookup <- read.table("outcome_lookup.txt", sep=",", header=TRUE);
outcome_lookup <- as.data.table(outcome_lookup);

# Outcome lookup status gets type set wrong, so reset it here
outcome_lookup$bug_status <- as.character(outcome_lookup$bug_status);

# Merge the new "outcome" column according to "bug_status" and "resolution" combinations
setkey(outcome_lookup, bug_status, resolution);
setkey(bugs_working, bug_status, resolution);
bugs_working <- merge(bugs_working, outcome_lookup, by=c('bug_status', 'resolution'), all.x=TRUE);


# Create a variable called "days_to_last_resolved", which counts from creation_ts to cf_last_resolved or DATABASE_END_TIMESTAMP if NA
bugs_working <- mutate(bugs_working, days_to_last_resolved = safe_ifelse(is.na(cf_last_resolved), as.double(difftime(DATABASE_END_TIMESTAMP, creation_ts, units = "secs")) / 86400,
																								  as.double(difftime(cf_last_resolved, 		creation_ts, units = "secs"))  / 86400));


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


# FLAGS

# Create a subset of the flags table that consists only of organizational entries
# Removing non-organizational domains reduces flags count from 437,771 to 320,843
# But, beware!  Many of those are mozilla.org.  It's far smaller (188,656) without mozilla.org.  A bit more than half.
flags_working <- filter(flags_clean, setter_id %in% profiles_working$userid);

# Merge the "domain" column based on the "setter_id" field for each flags entry
setkey(profiles_working, userid);
setkey(flags_working, setter_id);
flags_working <- merge(flags_working, profiles_working[, c("userid", "domain"), with=FALSE], by.x="setter_id", by.y="userid", all.x=TRUE);

# Rename it to "setter_domain" so that it's clear what it is
flags_working <- dplyr::rename(flags_working, setter_domain = domain);
 
 
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
flags_base			<<- flags_working;


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
profiles_working <- mutate(profiles_working, user_activity_count = safe_ifelse(is.na(user_activity_count), 0, user_activity_count));


# PROFILE-GROUP_MEMBERS

# Add logical columns for each of group & group bless properties to each profile for easy lookup
# As of end 2012, only 12 of 14 in schema are used.  bz_sudo_protect (31) & bz_quip_moderators (87) are not used
# Select just the user_id, group_id, & isbless columns from group_members_base
group_members_working <- select(group_members_base, user_id, group_id, isbless);

# Use data.table's dcast() function to recast the table such that each row is a single user_id and
# there are 2 columsn for each group, one representing membership, and one representing isbless. 
group_members_working <- dcast(group_members_working, user_id ~ group_id + isbless, drop=FALSE, value.var="isbless");

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(group_members_working) <- gsub("^(\\d)", "arg\\1", names(group_members_working), perl=TRUE);
					
# Rename and change the variable types from integer to logical
# Transmute() is used instead of mutate() to drop all other unwanted columns
group_members_working <- transmute(group_members_working, user_id = user_id,
														can_edit_parameters 			= as.logical(arg1_0),
														can_edit_parameters_bless 		= as.logical(arg1_1),
														can_edit_groups					= as.logical(arg3_0),
														can_edit_groups_bless			= as.logical(arg3_1),
														can_edit_components				= as.logical(arg4_0),
														can_edit_components_bless		= as.logical(arg4_1),
														can_edit_keywords				= as.logical(arg7_0),
														can_edit_keywords_bless			= as.logical(arg7_1),
														can_edit_users					= as.logical(arg8_0),
														can_edit_users_bless			= as.logical(arg8_1),
														can_edit_bugs					= as.logical(arg9_0),
														can_edit_bugs_bless				= as.logical(arg9_1),
														can_confirm						= as.logical(arg10_0),
														can_confirm_bless				= as.logical(arg10_1),
														can_admin						= as.logical(arg13_0),
														can_admin_bless					= as.logical(arg13_1),
														can_edit_classifications 		= as.logical(arg18_0),
														can_edit_classifications_bless	= as.logical(arg18_1),
														can_edit_whine_self				= as.logical(arg19_0),
														can_edit_whine_self_bless		= as.logical(arg19_1),
														can_edit_whine_others			= as.logical(arg20_0),
														can_edit_whine_others_bless		= as.logical(arg20_1),
														can_sudo						= as.logical(arg30_0),
														can_sudo_bless					= as.logical(arg30_1));					

# Change the non_NA values to "TRUE" and then the NA values to "FALSE"
group_members_working[group_members_working==FALSE] <- TRUE;
group_members_working[is.na(group_members_working)] <- FALSE;


# Merge the group_members_working table with the profiles table based on "user_id" and "userid"
setkey(group_members_working, user_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, group_members_working, by.x="userid", by.y="user_id", all.x=TRUE);


# For any NA entries in any of the "can_" columns, that means FALSE, so mutate it accordingly.
profiles_working <- mutate(profiles_working, 			can_edit_parameters 			= safe_ifelse(is.na(can_edit_parameters), 				FALSE, can_edit_parameters),
														can_edit_parameters_bless 		= safe_ifelse(is.na(can_edit_parameters_bless), 		FALSE, can_edit_parameters_bless),
														can_edit_groups					= safe_ifelse(is.na(can_edit_groups), 					FALSE, can_edit_groups),
														can_edit_groups_bless			= safe_ifelse(is.na(can_edit_groups_bless), 			FALSE, can_edit_groups_bless),
														can_edit_components				= safe_ifelse(is.na(can_edit_components), 				FALSE, can_edit_components),
														can_edit_components_bless		= safe_ifelse(is.na(can_edit_components_bless), 		FALSE, can_edit_components_bless),
														can_edit_keywords				= safe_ifelse(is.na(can_edit_keywords), 				FALSE, can_edit_keywords),
														can_edit_keywords_bless			= safe_ifelse(is.na(can_edit_keywords_bless), 			FALSE, can_edit_keywords_bless),
														can_edit_users					= safe_ifelse(is.na(can_edit_users), 					FALSE, can_edit_users),
														can_edit_users_bless			= safe_ifelse(is.na(can_edit_users_bless), 				FALSE, can_edit_users_bless),
														can_edit_bugs					= safe_ifelse(is.na(can_edit_bugs), 					FALSE, can_edit_bugs),
														can_edit_bugs_bless				= safe_ifelse(is.na(can_edit_bugs_bless), 				FALSE, can_edit_bugs_bless),
														can_confirm						= safe_ifelse(is.na(can_confirm), 						FALSE, can_confirm),
														can_confirm_bless				= safe_ifelse(is.na(can_confirm_bless), 				FALSE, can_confirm_bless),
														can_admin						= safe_ifelse(is.na(can_admin), 						FALSE, can_admin),
														can_admin_bless					= safe_ifelse(is.na(can_admin_bless), 					FALSE, can_admin_bless),
														can_edit_classifications 		= safe_ifelse(is.na(can_edit_classifications), 			FALSE, can_edit_classifications),
														can_edit_classifications_bless	= safe_ifelse(is.na(can_edit_classifications_bless), 	FALSE, can_edit_classifications_bless),
														can_edit_whine_self				= safe_ifelse(is.na(can_edit_whine_self	), 				FALSE, can_edit_whine_self	),
														can_edit_whine_self_bless		= safe_ifelse(is.na(can_edit_whine_self_bless), 		FALSE, can_edit_whine_self_bless),
														can_edit_whine_others			= safe_ifelse(is.na(can_edit_whine_others), 			FALSE, can_edit_whine_others),
														can_edit_whine_others_bless		= safe_ifelse(is.na(can_edit_whine_others_bless), 		FALSE, can_edit_whine_others_bless),
														can_sudo						= safe_ifelse(is.na(can_sudo), 							FALSE, can_sudo),
														can_sudo_bless					= safe_ifelse(is.na(can_sudo_bless), 					FALSE, can_sudo_bless));			


# PROFILES-USER-BUGS_REPORTED

# Count the bugs reported by each user in the bugs table
bug_user_reported_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$reporter)), -Freq), reporter = Var1));

# Merge the "user_bugs_reported_count" with the profiles table based on "reporter" and "userid"
setkey(bug_user_reported_count, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_reported_count, by.x="userid", by.y="reporter", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_bugs_reported_count = Freq);

# For any NA entries in the "user_bugs_reported_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_reported_count = safe_ifelse(is.na(user_bugs_reported_count), 0, user_bugs_reported_count));


# PROFILES-USER-BUGS_ASSIGNED

# Count the bugs assigned to each user in the bugs table
bug_user_assigned_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$assigned_to)), -Freq), assigned = Var1));

# Merge the "user_bugs_assigned_count" with the profiles table based on "assigned_to" and "userid"
setkey(bug_user_assigned_count, assigned);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_assigned_count, by.x="userid", by.y="assigned", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_bugs_assigned_count = Freq);

# For any NA entries in the "user_bugs_assigned_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_assigned_count = safe_ifelse(is.na(user_bugs_assigned_count), 0, user_bugs_assigned_count));


# PROFILES-USER-BUGS_QA

# Count the bugs where each user is set as QA in the bugs table
bug_user_qa_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$qa_contact)), -Freq), qa = Var1));

# Merge the "user_bugs_qa_count" with the profiles table based on "qa" and "userid"
setkey(bug_user_qa_count, qa);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_qa_count, by.x="userid", by.y="qa", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_bugs_qa_count = Freq);

# For any NA entries in the "user_bugs_qa_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_qa_count = safe_ifelse(is.na(user_bugs_qa_count), 0, user_bugs_qa_count));


# BUGS-ACTIVITY_ALL_ACTORS
# (Number of activities by all_actors for each bug)

# Import bugs table from previous base subroutine
bugs_working <- bugs_base;

# Group the activities table by bug_id to prepare for DPLYR's summarize() function
activity_working_grouped <- group_by(activity_clean, bug_id);

# Summarize the number of entries for each bug_id in the activity table:
activity_working_summary <- summarize(activity_working_grouped, activity_all_actors_count = n());

# Merge the activity_working_summary and bugs_working tables based on bug_id to add column activity_all_actors_count
setkey(activity_working_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_working_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "activity_all_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, activity_all_actors_count = safe_ifelse(is.na(activity_all_actors_count), 0, activity_all_actors_count));


# BUGS-ACTIVITY_DAYS_OPEN

# Filter the activities table for cases where some sort of resolution has occured by setting of status
# This measure is sometimes distinct from time between creation_ts & cf_last_resolved (if not NA), so both are created
# We want the whole activity_clean table, not just activities_base (by "orgs") because non-org users may have changed a bug status
# The possible resolutions are in "added" and are "CLOSED", "RESOLVED" or "VERIFIED"
# These SHOULD only appear in fieldid 29 which is "bug_status", but sometimes they end up elsewhere, so check for fieldid
activity_resolved <- filter(activity_clean, (added=="CLOSED" 	& fieldid==29) | 
											(added=="RESOLVED" 	& fieldid==29) | 
											(added=="VERIFIED" 	& fieldid==29));

# Rearrange the resolved activities by descending date, meaning present, backwards, or most recent dates first
activity_resolved <- arrange(activity_resolved, desc(bug_when));

# Filter the resolved activities to the most recent one per unique bug
# This way, if there are multiple "CLOSED", etc. because of reopening, we only catch the most recent one
activity_resolved_distinct <- distinct(activity_resolved, bug_id);

# Drop all the columns except bug_id and bug_when and rename bug_when to censor_ts to match with new column in bugs_working
activity_resolved_distinct <- select(activity_resolved_distinct, bug_id, censor_ts = bug_when);

# Merge the "activity_resolved" and "bugs_working" tables based on bug_id to add censor_ts column
setkey(activity_resolved_distinct, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_resolved_distinct, by="bug_id", all.x=TRUE);

# For all the rows that have "pending" outcome, we want to set the end time of the dataset as the censor_ts value
bugs_working <- mutate(bugs_working, censor_ts = safe_ifelse(outcome=="pending", DATABASE_END_TIMESTAMP, censor_ts)); 

# In very rare cases, with very old bugs, there is sometimes no entry in the activity table even when there is a resolution
# For those cases, set the censor_ts to delta_ts, the last time it or related tables were modified
bugs_working <- mutate(bugs_working, censor_ts = safe_ifelse(is.na(censor_ts), delta_ts, censor_ts));

# Create a new column that subtracts creation_ts from censor_ts to get number of "days_open"
bugs_working <- mutate(bugs_working, days_open = as.double(difftime(censor_ts, creation_ts, units = "secs")) / 86400);


# BUGS-ACTIVITY_REOPENED

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
bugs_working <- mutate(bugs_working, reopened_count = safe_ifelse(is.na(reopened_count), 0, reopened_count));


# BUGS-ACTIVITY_ASSIGNED

# Filter the activity table for entries that represent bug assignment count
# Bug assignment is defined by transition, although sometimes the transition is ignored and the
# change of "assigned_to" person in field 34 is the only evidence of assignment
# We'll operationalize it as transition only because change of "assigned_to" person is most often a bounce rejection
# It's not ideal, but the transitions should be a conservative subset that are actually assignments, whereas
# the inclusion of change of "assigned_to" person is likely to hit a lot of false positives, espeically with tracking userids
# As such, this conservative subset can be thought of as "assigned_and_accepted_count", which is distinct from the case in
# profiles_user_bugs_assigned_count, where we treat it as "assigned_but_maybe_not_accepted_count"
#
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
bugs_working <- mutate(bugs_working, assigned_count = safe_ifelse(is.na(assigned_count), 0, assigned_count));


# BUGS-ACTIVITY_REASSIGNED

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
bugs_working <- mutate(bugs_working, reassigned_count = safe_ifelse(is.na(reassigned_count), 0, reassigned_count));


# BUGS-LONGDESCS_TITLE_AND_DESCRIPTION_LENGTH

# Count the number of chracters in the title ("short_desc") and make that its own column, "title_length"
# Since nchar() returns 2 when title is blank, our ifelse catches that case and sets it to 0
bugs_working <- mutate(bugs_working, title_length = safe_ifelse(short_desc=="", 0, nchar(short_desc)));

# We want to count the number of characters in the initial comment when the bug was filed. This is effectively the
# "bug description" even though it's handled the same way as other comments.

# Import longdescs table from the original database inport and make it a data.table
# We want the whole longdescs_clean (not org-only long_descs_base) table because the reporter might not be an org user but one of the other
# actors may be; otherwise, many results will end up NA
longdescs_working <- longdescs_clean;

# Create a new column in the longdescs_working table that has the character length of each comment
# Since nchar() returns 2 when comment is blank, our ifelse catches that case and sets it to 0
longdescs_working <- mutate(longdescs_working, comment_length = safe_ifelse(thetext=="", 0, nchar(thetext)));

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


# BUGS-LONGDESCS_COMMENTS_ALL_ACTORS_COUNT_AND_COMBINED_LENGTH_AND_MEAN_LENGTH

# We can reuse the longdescs_working variable from above, so no need to import it again
# It already has the comment length column added.  We just need to count/sum/mean those for each bug_id

longdescs_working_grouped <- group_by(longdescs_working, bug_id);

# Now we'll use Dplyr's summarize() command to extract the count/sums/means of the comments column for each bug_id
# We subtract 1 from n() because the first comment is the "description" of which there will always be one.
longdescs_working_summary <- summarize(longdescs_working_grouped, comments_all_actors_count	= n() - 1,
																  comments_combined_length 	= sum(comment_length),
																  comments_mean_length		= mean(comment_length));

# Merge the longdescs_working_summary and bugs_working tables based on bug_id to add the new columns
setkey(longdescs_working_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_working_summary, by="bug_id", all.x=TRUE);

# The comments_combined_length variable includes the description_length, so subtract it
# The comments_mean_length included the description_length in its calculation, so recalculate the mean without it
bugs_working <- mutate(bugs_working, comments_combined_length 	= comments_combined_length - description_length,
									 comments_mean_length		=  ((comments_mean_length * (comments_all_actors_count + 1)) - description_length) / comments_all_actors_count);




# BUGS-CC_ALL_ACTORS

# First, we'll use Dplyr's group_by() command to set a flag in the data.frame that bug_ids should be grouped
# We want cc_clean because non-org users may still be following bug
cc_working_bug_id_grouped <- group_by(cc_clean, bug_id);

# Apply Dplyr's summarize() command to extract the count of CCs for each bug_id
cc_working_bug_id_summary <- summarize(cc_working_bug_id_grouped, cc_all_actors_count = n());

# Merge the cc_working_bug_id summary and bugs_working tables based on bug_id to add CC count
setkey(cc_working_bug_id_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, cc_working_bug_id_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "cc_all_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, cc_all_actors_count = safe_ifelse(is.na(cc_all_actors_count), 0, cc_all_actors_count));


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
profiles_working <- mutate(profiles_working, user_bugs_reported_reopened_count 		= safe_ifelse(is.na(user_bugs_reported_reopened_count), 	 0, user_bugs_reported_reopened_count),
											 user_bugs_reported_assigned_count 		= safe_ifelse(is.na(user_bugs_reported_assigned_count), 	 0, user_bugs_reported_assigned_count),
											 user_bugs_reported_reassigned_count 	= safe_ifelse(is.na(user_bugs_reported_reassigned_count), 	 0, user_bugs_reported_reassigned_count));


# PROFILES-USER-BUGS_ASSIGNED_TO-REOPENED_OR_ASSIGNED_OR_REASSIGNED
# (Track how many times each user that was set as assigned_to a bug, had it reopened, assigned, or reassigned)

# Use DPLYR's group_by() function to organize bugs_working table according to assigned userid
bugs_working_grouped_assigned_to <- group_by(bugs_working, assigned_to);

# Use DPLYR's summarize() function to sum reopened, assigned, and reassigned count across all bugs for each assigned_to user
bugs_working_grouped_user_assigned_to_summary <- summarize(bugs_working_grouped_assigned_to, user_bugs_assigned_to_reopened_count 	= sum(reopened_count),
																							 user_bugs_assigned_to_assigned_count 	= sum(assigned_count),
																							 user_bugs_assigned_to_reassigned_count = sum(reassigned_count));

# Merge the "bugs_working_grouped_user_assigned_to_summary" table with the profiles table based on "assigned_to" and "userid"
setkey(bugs_working_grouped_user_assigned_to_summary, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_grouped_user_assigned_to_summary, by.x="userid", by.y="assigned_to", all.x=TRUE);

# For any 0 entries in the assigned_count column, that's silly because at least the assigned_to user was assigned, so set to 1
# Note that here we're referring to "assigned_to" as not necessarily accepted assignment by the user in the assigned_to field, unlike with bugs assigned_count
# NA entries in the count columns, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_reopened_count 	= safe_ifelse(is.na(user_bugs_assigned_to_reopened_count), 	 0, user_bugs_assigned_to_reopened_count),
											 user_bugs_assigned_to_assigned_count 	= safe_ifelse(user_bugs_assigned_to_assigned_count == 0, 	 1, user_bugs_assigned_to_assigned_count),						  
											 user_bugs_assigned_to_reassigned_count = safe_ifelse(is.na(user_bugs_assigned_to_reassigned_count), 0, user_bugs_assigned_to_reassigned_count));
											 
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_assigned_count	= safe_ifelse(is.na(user_bugs_assigned_to_assigned_count), 	 0, user_bugs_assigned_to_assigned_count));


# PROFILES-USER-BUGS_QA_CONTACT-REOPENED_OR_ASSIGNED_OR_REASSIGNED
# (Track how many times each user that was set as qa_contact a bug, had it reopened, assigned, or reassigned)

# Use DPLYR's group_by() function to organize bugs_working table according to qa_contact userid
bugs_working_grouped_qa_contact <- group_by(bugs_working, qa_contact);

# Use DPLYR's summarize() function to sum reopened, assigned, and reassigned count across all bugs for each qa_contact user
bugs_working_grouped_user_qa_contact_summary <- summarize(bugs_working_grouped_qa_contact,  user_bugs_qa_contact_reopened_count 	= sum(reopened_count),
																							user_bugs_qa_contact_assigned_count 	= sum(assigned_count),
																							user_bugs_qa_contact_reassigned_count 	= sum(reassigned_count));

# Merge the "bugs_working_grouped_user_qa_contact_summary" table with the profiles table based on "qa_contact" and "userid"
setkey(bugs_working_grouped_user_qa_contact_summary, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_grouped_user_qa_contact_summary, by.x="userid", by.y="qa_contact", all.x=TRUE);

# For any NA entries in the count columns, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_reopened_count 	= safe_ifelse(is.na(user_bugs_qa_contact_reopened_count), 	0, user_bugs_qa_contact_reopened_count),
											 user_bugs_qa_contact_assigned_count 	= safe_ifelse(is.na(user_bugs_qa_contact_assigned_count), 	0, user_bugs_qa_contact_assigned_count),
											 user_bugs_qa_contact_reassigned_count 	= safe_ifelse(is.na(user_bugs_qa_contact_reassigned_count), 0, user_bugs_qa_contact_reassigned_count));


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
profiles_working <- mutate(profiles_working, user_activity_assigning_count = safe_ifelse(is.na(user_activity_assigning_count), 0, user_activity_assigning_count));


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
profiles_working <- mutate(profiles_working, user_activity_reassigning_count = safe_ifelse(is.na(user_activity_reassigning_count), 0, user_activity_reassigning_count));


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

# Use DPLYR's summarize() function to count reopening activity according for each user
activity_base_reopened_grouped_who_summary <- summarize(activity_base_reopened_grouped_who, user_activity_reopening_count = n());

# Merge the "activity_base_reopened_grouped_who_summary" table with the profiles table according to "who" and "userid"
setkey(activity_base_reopened_grouped_who_summary, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_base_reopened_grouped_who_summary, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries in the "user_activity_reopening_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_activity_reopening_count = safe_ifelse(is.na(user_activity_reopening_count), 0, user_activity_reopening_count));


# PROFILES-ATTACHMENTS_USER_ALL_TYPES
# (Track how many attachments each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_all_grouped_submitter <- group_by(attachments_base, submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_all_grouped_submitter_summary <- summarize(attachments_base_all_grouped_submitter, user_attachments_all_types_count = n());

# Merge the "attachments_base_all_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_all_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_all_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_all_types_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_all_types_count = safe_ifelse(is.na(user_attachments_all_types_count), 0, user_attachments_all_types_count));


# PROFILES-ATTACHMENTS_USER_PATCH
# (Track how many attachments that were patches each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_patch_grouped_submitter <- group_by(filter(attachments_base, ispatch==TRUE), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_patch_grouped_submitter_summary <- summarize(attachments_base_patch_grouped_submitter, user_attachments_patch_count = n());

# Merge the "attachments_base_patch_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_patch_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_patch_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_patch_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_patch_count = safe_ifelse(is.na(user_attachments_patch_count), 0, user_attachments_patch_count));


# PROFILES-ATTACHMENTS_USER_APPLICATION
# (Track how many attachments that were applications each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_application_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% application_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_application_grouped_submitter_summary <- summarize(attachments_base_application_grouped_submitter, user_attachments_application_count = n());

# Merge the "attachments_base_application_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_application_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_application_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_application_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_application_count = safe_ifelse(is.na(user_attachments_application_count), 0, user_attachments_application_count));

# PROFILES-ATTACHMENTS_USER_AUDIO
# (Track how many attachments that were audio each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_audio_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% audio_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_audio_grouped_submitter_summary <- summarize(attachments_base_audio_grouped_submitter, user_attachments_audio_count = n());

# Merge the "attachments_base_audio_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_audio_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_audio_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_audio_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_audio_count = safe_ifelse(is.na(user_attachments_audio_count), 0, user_attachments_audio_count));

# PROFILES-ATTACHMENTS_USER_IMAGE
# (Track how many attachments that were images each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_image_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% image_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_image_grouped_submitter_summary <- summarize(attachments_base_image_grouped_submitter, user_attachments_image_count = n());

# Merge the "attachments_base_image_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_image_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_image_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_image_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_image_count = safe_ifelse(is.na(user_attachments_image_count), 0, user_attachments_image_count));


# PROFILES-ATTACHMENTS_USER_MESSAGE
# (Track how many attachments that were messages each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_message_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% message_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_message_grouped_submitter_summary <- summarize(attachments_base_message_grouped_submitter, user_attachments_message_count = n());

# Merge the "attachments_base_message_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_message_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_message_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_message_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_message_count = safe_ifelse(is.na(user_attachments_message_count), 0, user_attachments_message_count));


# PROFILES-ATTACHMENTS_USER_MODEL
# (Track how many attachments that were models each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_model_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% model_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_model_grouped_submitter_summary <- summarize(attachments_base_model_grouped_submitter, user_attachments_model_count = n());

# Merge the "attachments_base_model_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_model_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_model_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_model_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_model_count = safe_ifelse(is.na(user_attachments_model_count), 0, user_attachments_model_count));


# PROFILES-ATTACHMENTS_USER_MULTIPART
# (Track how many attachments that were multipart each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_multipart_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% multipart_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_multipart_grouped_submitter_summary <- summarize(attachments_base_multipart_grouped_submitter, user_attachments_multipart_count = n());

# Merge the "attachments_base_multipart_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_multipart_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_multipart_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_multipart_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_multipart_count = safe_ifelse(is.na(user_attachments_multipart_count), 0, user_attachments_multipart_count));


# PROFILES-ATTACHMENTS_USER_TEXT
# (Track how many attachments that were text each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_text_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% text_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_text_grouped_submitter_summary <- summarize(attachments_base_text_grouped_submitter, user_attachments_text_count = n());

# Merge the "attachments_base_text_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_text_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_text_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_text_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_text_count = safe_ifelse(is.na(user_attachments_text_count), 0, user_attachments_text_count));


# PROFILES-ATTACHMENTS_USER_VIDEO
# (Track how many attachments that were video each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_video_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% video_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_video_grouped_submitter_summary <- summarize(attachments_base_video_grouped_submitter, user_attachments_video_count = n());

# Merge the "attachments_base_video_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_video_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_video_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_video_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_video_count = safe_ifelse(is.na(user_attachments_video_count), 0, user_attachments_video_count));


# PROFILES-ATTACHMENTS_USER_UNKNOWN
# (Track how many attachments that were an unknown type each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_unknown_grouped_submitter <- group_by(filter(attachments_base, !(mimetype %in% c(application_mimetypes$Template,
																								  audio_mimetypes$Template,
																								  image_mimetypes$Template,
																								  message_mimetypes$Template,
																								  model_mimetypes$Template,
																								  multipart_mimetypes$Template,
																								  text_mimetypes$Template,
																								  video_mimetypes$Template))), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_unknown_grouped_submitter_summary <- summarize(attachments_base_unknown_grouped_submitter, user_attachments_unknown_count = n());

# Merge the "attachments_base_unknown_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_unknown_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_unknown_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "user_attachments_unknown_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_attachments_unknown_count = safe_ifelse(is.na(user_attachments_unknown_count), 0, user_attachments_unknown_count));


# PROFILES-BUGS-ATTACHMENTS_USER_KNOWLEDGE_ACTORS
# I operationalize user/org knowledge actors as users/orgs who have done at least one of: report a bug, be assigned_to a bug, be qa_contact for a bug, submit an attachment of any type for a bug
profiles_working <- mutate(profiles_working, user_knowledge_actor = safe_ifelse((user_bugs_reported_count  			> 	0 |
																				user_bugs_assigned_count  			>	0 |
																				user_bugs_qa_count		  			>	0 |
																				user_attachments_all_types_count	>	0 ), TRUE, FALSE)); 


# PROFILES-GROUPS_USER_CORE_ACTORS
# I operationalize user/org core actors as users/orgs who have one or more group membership
# As of the end of 2012, that includes 2478 core profiles out of 109765 total profiles, or roughly 2.25%, which seems a reasonable subset to define as "core"
# Since we set the group membership flags in the profiles earlier, all we have to do is look for a true entry to set the "user" core actor field
# At present, there are 24 group flags (12 for membership and 12 for bless ability for each group)
profiles_working <- mutate(profiles_working, user_core_actor = safe_ifelse((can_edit_parameters 			 == TRUE |
																			can_edit_parameters_bless 		 == TRUE |
																			can_edit_groups					 == TRUE |
																			can_edit_groups_bless			 == TRUE |
																			can_edit_components				 == TRUE |
																			can_edit_components_bless		 == TRUE |
																			can_edit_keywords				 == TRUE |
																			can_edit_keywords_bless			 == TRUE |
																			can_edit_users					 == TRUE |
																			can_edit_users_bless			 == TRUE |
																			can_edit_bugs					 == TRUE |
																			can_edit_bugs_bless				 == TRUE |
																			can_confirm						 == TRUE |
																			can_confirm_bless				 == TRUE |
																			can_admin						 == TRUE |
																			can_admin_bless					 == TRUE |
																			can_edit_classifications 		 == TRUE |
																			can_edit_classifications_bless	 == TRUE |
																			can_edit_whine_self				 == TRUE |
																			can_edit_whine_self_bless		 == TRUE |
																			can_edit_whine_others			 == TRUE |
																			can_edit_whine_others_bless		 == TRUE |
																			can_sudo						 == TRUE |
																			can_sudo_bless					 == TRUE), TRUE, FALSE));
	
																			
# PROFILES-BUGS-ATTACHMENTS_USER_PERIPHERAL_ACTORS
# I operationalize user/or peripheral actors as users/ who are not any other actor type (currently not core and not knowledge)
profiles_working <- mutate(profiles_working, user_peripheral_actor = safe_ifelse((user_knowledge_actor	== FALSE &
																				  user_core_actor		== FALSE), TRUE, FALSE));
																			 

# BUGS-CC_KNOWLEDGE_ACTORS
# (Count of knowledge actors who are following bug)

# Create a list of userids that are knowledge actors with defined organizations (not full profile list)
profiles_knowledge_actors <- filter(profiles_working, user_knowledge_actor==TRUE);
user_knowledge_actors <- select(profiles_knowledge_actors, userid);

# Make it a vector list instead of data.table
user_knowledge_actors <- user_knowledge_actors$userid;

# Filter the cc_base database to knowledge actors who have defined organizations
cc_knowledge_actors <- filter(cc_base, who %in% user_knowledge_actors);

# Use Dplyr's group_by() command to sort cc_knowledge_actors by bug_id
cc_knowledge_actors_grouped_bug_id <- group_by(cc_knowledge_actors, bug_id);

# Apply Dplyr's summarize() command to extract the count of CCs for each bug_id by knowledge actors
cc_knowledge_actors_bug_id_summary <- summarize(cc_knowledge_actors_grouped_bug_id, cc_knowledge_actors_count = n());

# Merge the cc_knowledge_actors_bug_id_summary and bugs_working tables based on bug_id to add CC count
setkey(cc_knowledge_actors_bug_id_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, cc_knowledge_actors_bug_id_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "cc_knowledge_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, cc_knowledge_actors_count = safe_ifelse(is.na(cc_knowledge_actors_count), 0, cc_knowledge_actors_count));


# BUGS-CC_CORE_ACTORS
# (Count of core actors who are following bug)

# Create a list of userids that are core actors with defined organizations (not full profile list)
profiles_core_actors <- filter(profiles_working, user_core_actor==TRUE);
user_core_actors <- select(profiles_core_actors, userid);

# Make it a vector list instead of data.table
user_core_actors <- user_core_actors$userid;

# Filter the cc_base database to core actors who have defined organizations
cc_core_actors <- filter(cc_base, who %in% user_core_actors);

# Use Dplyr's group_by() command to sort cc_core_actors by bug_id
cc_core_actors_grouped_bug_id <- group_by(cc_core_actors, bug_id);

# Apply Dplyr's summarize() command to extract the count of CCs for each bug_id by core actors
cc_core_actors_bug_id_summary <- summarize(cc_core_actors_grouped_bug_id, cc_core_actors_count = n());

# Merge the cc_core_actors_bug_id_summary and bugs_working tables based on bug_id to add CC count
setkey(cc_core_actors_bug_id_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, cc_core_actors_bug_id_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "cc_core_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, cc_core_actors_count = safe_ifelse(is.na(cc_core_actors_count), 0, cc_core_actors_count));


# BUGS-CC_PERIPHERAL_ACTORS
# (Count of peripheral actors who are following bug)

# Create a list of userids that are peripheral actors with defined organizations (not full profile list)
profiles_peripheral_actors <- filter(profiles_working, user_peripheral_actor==TRUE);
user_peripheral_actors <- select(profiles_peripheral_actors, userid);

# Make it a vector list instead of data.table
user_peripheral_actors <- user_peripheral_actors$userid;

# Filter the cc_base database to peripheral actors who have defined organizations
cc_peripheral_actors <- filter(cc_base, who %in% user_peripheral_actors);

# Use Dplyr's group_by() command to sort cc_peripheral_actors by bug_id
cc_peripheral_actors_grouped_bug_id <- group_by(cc_peripheral_actors, bug_id);

# Apply Dplyr's summarize() command to extract the count of CCs for each bug_id by peripheral actors
cc_peripheral_actors_bug_id_summary <- summarize(cc_peripheral_actors_grouped_bug_id, cc_peripheral_actors_count = n());

# Merge the cc_peripheral_actors_bug_id_summary and bugs_working tables based on bug_id to add CC count
setkey(cc_peripheral_actors_bug_id_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, cc_peripheral_actors_bug_id_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "cc_peripheral_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, cc_peripheral_actors_count = safe_ifelse(is.na(cc_peripheral_actors_count), 0, cc_peripheral_actors_count));


# BUGS-ACTIVITY_KNOWLEDGE_ACTORS
# (Number of activities by knowledge_actors for each bug)

# Filter according to activities done by knowledge actors
activity_knowledge_actors <- filter(activity_base, who %in% user_knowledge_actors);

# Group the activity table by bug_id to prepare for DPLYR's summarize() function
activity_knowledge_actors_grouped <- group_by(activity_knowledge_actors, bug_id);

# Summarize the number of entries for each bug_id in the activity table:
activity_knowledge_actors_grouped_summary <- summarize(activity_knowledge_actors_grouped, activity_knowledge_actors_count = n());

# Merge the activity_knowledge_actors_grouped_summary and bugs_working tables based on bug_id to add column activity_knowledge_actors_count
setkey(activity_knowledge_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_knowledge_actors_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "activity_knowledge_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, activity_knowledge_actors_count = safe_ifelse(is.na(activity_knowledge_actors_count), 0, activity_knowledge_actors_count));


# BUGS-ACTIVITY_CORE_ACTORS
# (Number of activities by core_actors for each bug)

# Filter according to activities done by core actors
activity_core_actors <- filter(activity_base, who %in% user_core_actors);

# Group the activity table by bug_id to prepare for DPLYR's summarize() function
activity_core_actors_grouped <- group_by(activity_core_actors, bug_id);

# Summarize the number of entries for each bug_id in the activity table:
activity_core_actors_grouped_summary <- summarize(activity_core_actors_grouped, activity_core_actors_count = n());

# Merge the activity_core_actors_grouped_summary and bugs_working tables based on bug_id to add column activity_core_actors_count
setkey(activity_core_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_core_actors_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "activity_core_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, activity_core_actors_count = safe_ifelse(is.na(activity_core_actors_count), 0, activity_core_actors_count));


# BUGS-ACTIVITY_PERIPHERAL_ACTORS
# (Number of activities by peripheral_actors for each bug)

# Filter according to activities done by peripheral actors
activity_peripheral_actors <- filter(activity_base, who %in% user_peripheral_actors);

# Group the activity table by bug_id to prepare for DPLYR's summarize() function
activity_peripheral_actors_grouped <- group_by(activity_peripheral_actors, bug_id);

# Summarize the number of entries for each bug_id in the activity table:
activity_peripheral_actors_grouped_summary <- summarize(activity_peripheral_actors_grouped, activity_peripheral_actors_count = n());

# Merge the activity_peripheral_actors_grouped_summary and bugs_working tables based on bug_id to add column activity_peripheral_actors_count
setkey(activity_peripheral_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_peripheral_actors_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "activity_peripheral_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, activity_peripheral_actors_count = safe_ifelse(is.na(activity_peripheral_actors_count), 0, activity_peripheral_actors_count));


# BUGS-ACTIVITY_TYPES
# (Count the types of activity for each bug)

# The types of interest to count are changes to the following bug fields: CC, keywords, product, component, status, resolution, 
# flags, whiteboard, target_milestone, description, priority, & severity
# Their respective fieldid's are: 37, 21, 25, 33, 29, 30, 69, 22, 40, 24, 32, 31 in the activity table
# Since we only care about count, all we need is "bug_id", and "fieldid". Other columns don't matter here.

activity_types_working <- select(filter(activity_clean, fieldid %in% c(37, 21, 25, 33, 29, 30, 69, 22, 40, 24, 32, 31)), bug_id, fieldid);

# Use data.table's dcast() function to recast the table such that each row is a single bug_id and there is
# a column for each field_id
activity_types_recast <- dcast(activity_types_working, bug_id ~ fieldid, drop=FALSE, value.var="fieldid", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_types_recast) <- gsub("^(\\d)", "arg\\1", names(activity_types_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns
activity_types_recast <- transmute(activity_types_recast, 	bug_id 							= bug_id,
															cc_change_count 				= arg37,
															keywords_change_count			= arg21,
															product_change_count			= arg25,
															component_change_count			= arg33,
															status_change_count				= arg29,
															resolution_change_count			= arg30,
															flags_change_count				= arg69,
															whiteboard_change_count			= arg22,
															target_milestone_change_count	= arg40,
															description_change_count		= arg24,
															priority_change_count			= arg32,
															severity_change_count		 	= arg31);

# Merge the activity_types_recast and bugs_working tables based on bug_id to add the activity type count columns
setkey(activity_types_recast, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_types_recast, by="bug_id", all.x=TRUE);

# For some reason, 6200 bugs have no activity associated with them, probably for legacy reasons, so they don't show up in the recast type table
# Their counts for each of the types need to be set from NA to 0
bugs_working <- mutate(bugs_working, cc_change_count 				= safe_ifelse(is.na(cc_change_count), 				0, cc_change_count), 	
									 keywords_change_count 			= safe_ifelse(is.na(keywords_change_count), 		0, keywords_change_count),
									 product_change_count 			= safe_ifelse(is.na(product_change_count), 			0, product_change_count),
									 component_change_count 		= safe_ifelse(is.na(component_change_count), 		0, component_change_count),
									 status_change_count 			= safe_ifelse(is.na(status_change_count), 			0, status_change_count),
									 resolution_change_count 		= safe_ifelse(is.na(resolution_change_count), 		0, resolution_change_count),
									 flags_change_count 			= safe_ifelse(is.na(flags_change_count), 			0, flags_change_count),
									 whiteboard_change_count 		= safe_ifelse(is.na(whiteboard_change_count), 		0, whiteboard_change_count),
									 target_milestone_change_count 	= safe_ifelse(is.na(target_milestone_change_count), 0, target_milestone_change_count),
									 description_change_count 		= safe_ifelse(is.na(description_change_count), 		0, description_change_count),
									 priority_change_count 			= safe_ifelse(is.na(priority_change_count), 		0, priority_change_count),
									 severity_change_count 			= safe_ifelse(is.na(severity_change_count), 		0, severity_change_count));


# BUGS-ACTIVITES_HOURS&DAYS_THRESHOLDS

# We want to count how activities take place in less than a certain amount of hours since bug creation_ts
# To do that, we have to first lookup the bug creation_ts for our reference time frame
bugs_creation_ts <- transmute(bugs_clean, bug_id = bug_id, bug_creation_ts = as.POSIXct(creation_ts, tz="UTC", origin="1970-01-01"));

# Merge the bugs_creation_ts table with the activity_clean (as activity_working) table to set our bug_creation_ts column for calculations
activity_working <- activity_clean;
setkey(bugs_creation_ts, bug_id);
setkey(activity_working, bug_id);
activity_working <- merge(activity_working, bugs_creation_ts, by="bug_id", all.x=TRUE);

# Make a hours_since_bug_creation column using date subtraction for each activity
activity_working <- mutate(activity_working, hours_since_bug_creation = safe_ifelse(bug_when==bug_creation_ts, 0, as.double(difftime(bug_when, bug_creation_ts, units = "secs")) / 3600));

# Any NA values that result from the above mutate relate only to test bugs that were manually deleted, so are irrelevant and 
# will not show up when added to the bugs_working table
# However, values less than 0 indicate an impossible situation where an activity on a bug occurred before it was created
# It most likely means a legacy problem with user timezones.  Manual inspection suggests that it occurs more than once with each user, so is related to user, like a timezone
# We'll set them to NA since they're spurious
activity_working <- mutate(activity_working, hours_since_bug_creation = safe_ifelse(hours_since_bug_creation < 0, NA, hours_since_bug_creation));

# Create a set of logical columns for the various thresholds hours_since_bug_creation for each activity.  
# This method is inefficient because each activity will only have TRUE in one column, and FALSE in all others
# but it will drastically simplify the sum() operation when we group_by bug_id and this activity_working construct will be removed
# from RAM after this subroutine ends, so it's only a temporary memory hog

activity_working <- mutate(activity_working, 	activity_lt_1hour		= as.logical(hours_since_bug_creation >= 0 		& hours_since_bug_creation 	< 1),
												activity_lt_3hours		= as.logical(hours_since_bug_creation >= 1		& hours_since_bug_creation 	< 3),
												activity_lt_6hours		= as.logical(hours_since_bug_creation >= 3 		& hours_since_bug_creation 	< 6),
												activity_lt_12hours		= as.logical(hours_since_bug_creation >= 6 		& hours_since_bug_creation 	< 12),
												activity_lt_1day		= as.logical(hours_since_bug_creation >= 12 	& hours_since_bug_creation 	< 24),
												activity_lt_3days		= as.logical(hours_since_bug_creation >= 24 	& hours_since_bug_creation 	< 72),
												activity_lt_7days		= as.logical(hours_since_bug_creation >= 72 	& hours_since_bug_creation 	< 168),
												activity_lt_15days		= as.logical(hours_since_bug_creation >= 168 	& hours_since_bug_creation 	< 360),
												activity_lt_45days		= as.logical(hours_since_bug_creation >= 360 	& hours_since_bug_creation 	< 1080),
												activity_lt_90days		= as.logical(hours_since_bug_creation >= 1080 	& hours_since_bug_creation 	< 2160),
												activity_lt_180days		= as.logical(hours_since_bug_creation >= 2160 	& hours_since_bug_creation 	< 4320),
												activity_lt_1year		= as.logical(hours_since_bug_creation >= 4320 	& hours_since_bug_creation 	< 8760),
												activity_lt_2years		= as.logical(hours_since_bug_creation >= 8760 	& hours_since_bug_creation 	< 17520),
												activity_gt_2years		= as.logical(hours_since_bug_creation >= 17520));
												
# Group according to bug_id to allow for summarize number of activities per bug per time threshold
activity_working_grouped <- group_by(select(activity_working, bug_id, starts_with("activity_")), bug_id);

# Use summarize() to sum each of the columns of thresholds per bug_id
activity_working_grouped_summary <- summarize(activity_working_grouped, activity_lt_1hour_count			= sum(activity_lt_1hour),
																		activity_1_3hours_count			= sum(activity_lt_3hours),
                                                                        activity_3_6hours_count			= sum(activity_lt_6hours),
                                                                        activity_6_12hours_count		= sum(activity_lt_12hours),
                                                                        activity_12hours_1day_count		= sum(activity_lt_1day),
                                                                        activity_1_3days_count			= sum(activity_lt_3days),
                                                                        activity_3_7days_count			= sum(activity_lt_7days),
                                                                        activity_7_15days_count			= sum(activity_lt_15days),
                                                                        activity_15_45days_count		= sum(activity_lt_45days),
                                                                        activity_45_90days_count		= sum(activity_lt_90days),
                                                                        activity_90_180days_count		= sum(activity_lt_180days),
                                                                        activity_180days_1year_count	= sum(activity_lt_1year),
                                                                        activity_1_2years_count			= sum(activity_lt_2years),
                                                                        activity_gt_2years_count		= sum(activity_gt_2years));

# Merge the activity_working_grouped_summary and bugs_working tables based on bug_id to add the count of activities in each time threshold
setkey(activity_working_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_working_grouped_summary, by="bug_id", all.x=TRUE);

# Any NA values in the newly merged bugs_working table are the result of one of two situations, either
# 1) There are no activities for the bug in question (should not be possible, but does exist, probably from manual changes to DB fields not captured by scripts)
# 2) The creation_ts of the bug is somehow after the first activity timestamp for that bug_id. Also should not happen, but is in database a few times
# For 1), we can correctly set those NA's to "0".  For 2), they should be left as NA, since we don't have reliable time measures.
bugs_working <- mutate(bugs_working, activity_lt_1hour_count		= safe_ifelse(is.na(activity_lt_1hour_count) 		& activity_all_actors_count==0, 0, activity_lt_1hour_count),
                                     activity_1_3hours_count		= safe_ifelse(is.na(activity_1_3hours_count) 		& activity_all_actors_count==0, 0, activity_1_3hours_count),
                                     activity_3_6hours_count		= safe_ifelse(is.na(activity_3_6hours_count) 		& activity_all_actors_count==0, 0, activity_3_6hours_count),
                                     activity_6_12hours_count		= safe_ifelse(is.na(activity_6_12hours_count) 		& activity_all_actors_count==0, 0, activity_6_12hours_count),
                                     activity_12hours_1day_count	= safe_ifelse(is.na(activity_12hours_1day_count) 	& activity_all_actors_count==0, 0, activity_12hours_1day_count),
                                     activity_1_3days_count			= safe_ifelse(is.na(activity_1_3days_count) 		& activity_all_actors_count==0, 0, activity_1_3days_count),
                                     activity_3_7days_count			= safe_ifelse(is.na(activity_3_7days_count) 		& activity_all_actors_count==0, 0, activity_3_7days_count),
                                     activity_7_15days_count		= safe_ifelse(is.na(activity_7_15days_count) 		& activity_all_actors_count==0, 0, activity_7_15days_count),
                                     activity_15_45days_count		= safe_ifelse(is.na(activity_15_45days_count) 		& activity_all_actors_count==0, 0, activity_15_45days_count),
                                     activity_45_90days_count		= safe_ifelse(is.na(activity_45_90days_count) 		& activity_all_actors_count==0, 0, activity_45_90days_count),
                                     activity_90_180days_count		= safe_ifelse(is.na(activity_90_180days_count) 		& activity_all_actors_count==0, 0, activity_90_180days_count),
                                     activity_180days_1year_count	= safe_ifelse(is.na(activity_180days_1year_count) 	& activity_all_actors_count==0, 0, activity_180days_1year_count),
                                     activity_1_2years_count		= safe_ifelse(is.na(activity_1_2years_count) 		& activity_all_actors_count==0, 0, activity_1_2years_count),
                                     activity_gt_2years_count		= safe_ifelse(is.na(activity_gt_2years_count) 		& activity_all_actors_count==0, 0, activity_gt_2years_count));
						 
									 
# BUGS-PROFILES_REPORTER_AND_ASSIGNED_TO_AND_QA_CONTACT_ACTOR_TYPE
# (Set logical column entries for the type of each person involved in the bug)

# Cross-reference user actor type flags with different users involved in bugs
bugs_working <- mutate(bugs_working, reporter_knowledge_actor 	= safe_ifelse(reporter 		%in% user_knowledge_actors, 	TRUE, FALSE),
									 reporter_core_actor		= safe_ifelse(reporter 		%in% user_core_actors, 			TRUE, FALSE),
									 reporter_peripheral_actor	= safe_ifelse(reporter 		%in% user_peripheral_actors, 	TRUE, FALSE),
									 assigned_knowledge_actor	= safe_ifelse(assigned_to 	%in% user_knowledge_actors, 	TRUE, FALSE),
									 assigned_core_actor		= safe_ifelse(assigned_to 	%in% user_core_actors, 			TRUE, FALSE),
									 assigned_peripheral_actor	= safe_ifelse(assigned_to 	%in% user_peripheral_actors, 	TRUE, FALSE),
									 qa_knowledge_actor			= safe_ifelse(qa_contact	%in% user_knowledge_actors, 	TRUE, FALSE),
									 qa_core_actor				= safe_ifelse(qa_contact	%in% user_core_actors, 			TRUE, FALSE),
									 qa_peripheral_actor		= safe_ifelse(qa_contact	%in% user_peripheral_actors, 	TRUE, FALSE));

									 
# BUGS-KEYWORDS
# (Count how many keywords are associated with each bug)

# There are too many types of keywords to count the different types
# Further, many of the types are not clearly defined, redundant, etc.
# So we'll just get an overall count.

# Group the keywords_clean table by bug_id to prepare it for summarize()
keywords_working_grouped <- group_by(keywords_clean, bug_id);

# Use summarize() to count the number of entries for each bug_id
keywords_working_grouped_summary <- summarize(keywords_working_grouped, keywords_count = n());

# Merge the keywords_working_grouped_summary and bugs_working tables based on bug_id to add the count of keywords for each bug
setkey(keywords_working_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, keywords_working_grouped_summary, by="bug_id", all.x=TRUE);

# Any NA values means no keywords at all, so replace them with 0
bugs_working <- mutate(bugs_working, keywords_count = safe_ifelse(is.na(keywords_count), 0, keywords_count));


# BUGS-FLAGS							 
# (Count how many flags are associated with each bug)

# There are too many types of flags to count the different types
# Further, many of the types are not clearly defined, redundant, etc.
# So we'll just get an overall count.
# Note that the "status" field in the flags table means that it's possible that we'll double count the same getting set and then removed
# However, we can treat "setting a flag" as one count and "removing a flag" as another count.  So this variable
# should better be understood as treating "postiive" and "negative" flags separately.  There's really no other clena way given the DB format

# Group the flags_clean table by bug_id to prepare it for summarize()
flags_working_grouped <- group_by(flags_clean, bug_id);

# Use summarize() to count the number of entries for each bug_id
flags_working_grouped_summary <- summarize(flags_working_grouped, flags_count = n());

# Merge the flags_working_grouped_summary and bugs_working tables based on bug_id to add the count of flags for each bug
setkey(flags_working_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, flags_working_grouped_summary, by="bug_id", all.x=TRUE);

# Any NA values means no flags at all, so replace them with 0
bugs_working <- mutate(bugs_working, flags_count = safe_ifelse(is.na(flags_count), 0, flags_count));									 
									 

# BUGS-VOTES_KNOWLEDGE_ACTORS
# (Count of knowledge actors who voted for each bug)

# Filter the votes_base database to knowledge actors who have defined organizations
votes_knowledge_actors <- filter(votes_base, who %in% user_knowledge_actors);

# Use Dplyr's group_by() command to sort votes_knowledge_actors by bug_id
votes_knowledge_actors_grouped_bug_id <- group_by(votes_knowledge_actors, bug_id);

# Apply Dplyr's summarize() command to extract the count of votes for each bug_id by knowledge actors
votes_knowledge_actors_bug_id_summary <- summarize(votes_knowledge_actors_grouped_bug_id, votes_knowledge_actors_count = n());

# Merge the votes_knowledge_actors_bug_id_summary and bugs_working tables based on bug_id to add votes count
setkey(votes_knowledge_actors_bug_id_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, votes_knowledge_actors_bug_id_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "votes_knowledge_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, votes_knowledge_actors_count = safe_ifelse(is.na(votes_knowledge_actors_count), 0, votes_knowledge_actors_count));


# BUGS-VOTES_CORE_ACTORS
# (Count of core actors who voted for each bug)

# Filter the votes_base database to core actors who have defined organizations
votes_core_actors <- filter(votes_base, who %in% user_core_actors);

# Use Dplyr's group_by() command to sort votes_core_actors by bug_id
votes_core_actors_grouped_bug_id <- group_by(votes_core_actors, bug_id);

# Apply Dplyr's summarize() command to extract the count of votes for each bug_id by core actors
votes_core_actors_bug_id_summary <- summarize(votes_core_actors_grouped_bug_id, votes_core_actors_count = n());

# Merge the votes_core_actors_bug_id_summary and bugs_working tables based on bug_id to add votes count
setkey(votes_core_actors_bug_id_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, votes_core_actors_bug_id_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "votes_core_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, votes_core_actors_count = safe_ifelse(is.na(votes_core_actors_count), 0, votes_core_actors_count));


# BUGS-VOTES_PERIPHERAL_ACTORS
# (Count of peripheral actors who voted for each bug)

# Filter the votes_base database to peripheral actors who have defined organizations
votes_peripheral_actors <- filter(votes_base, who %in% user_peripheral_actors);

# Use Dplyr's group_by() command to sort votes_peripheral_actors by bug_id
votes_peripheral_actors_grouped_bug_id <- group_by(votes_peripheral_actors, bug_id);

# Apply Dplyr's summarize() command to extract the count of votes for each bug_id by peripheral actors
votes_peripheral_actors_bug_id_summary <- summarize(votes_peripheral_actors_grouped_bug_id, votes_peripheral_actors_count = n());

# Merge the votes_peripheral_actors_bug_id_summary and bugs_working tables based on bug_id to add votes count
setkey(votes_peripheral_actors_bug_id_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, votes_peripheral_actors_bug_id_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "votes_peripheral_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, votes_peripheral_actors_count = safe_ifelse(is.na(votes_peripheral_actors_count), 0, votes_peripheral_actors_count));


# BUGS-DUPLICATES

# Group duplicates table according to the bug_ids that have been duplicated by other bugs (dupe_of)
duplicates_working_grouped <- group_by(duplicates_clean, dupe_of);

# Summarize to count the number of times each bug was duplicated by another bug
duplicates_working_grouped_summary <- summarize(duplicates_working_grouped, duplicates_count = n());

# Merge the duplicates_working_grouped_summary and bugs_working tables based on "bug_id" and "dupe_of" to add duplicates count
setkey(duplicates_working_grouped_summary, dupe_of);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, duplicates_working_grouped_summary, by.x="bug_id", by.y="dupe_of", all.x=TRUE);

# For any NA entries, that means the bug was never duplicated, so mutate it to 0
# Also add a logical column that is TRUE if the bug is a duplicate of another bug and FALSE otherwise
bugs_working <- mutate(bugs_working, duplicates_count 	= safe_ifelse(is.na(duplicates_count), 			 0, 	duplicates_count),
									 is_duplicate		= safe_ifelse(bug_id %in% duplicates_clean$dupe, TRUE, 	FALSE));


# BUGS-ATTACHMENTS_ALL_TYPES
# (Count how many attachments were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_all_grouped_bugid <- group_by(attachments_clean, bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_all_grouped_bugid_summary <- summarize(attachments_clean_all_grouped_bugid, attachments_all_types_count = n());

# Merge the "attachments_clean_all_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_all_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_all_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_all_types_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_all_types_count = safe_ifelse(is.na(attachments_all_types_count), 0, attachments_all_types_count));


# BUGS-ATTACHMENTS_PATCH
# (Count how many attachments that were patches were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_patch_grouped_bugid <- group_by(filter(attachments_clean, ispatch==TRUE), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_patch_grouped_bugid_summary <- summarize(attachments_clean_patch_grouped_bugid, attachments_patch_count = n());

# Merge the "attachments_clean_patch_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_patch_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_patch_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_patch_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_patch_count = safe_ifelse(is.na(attachments_patch_count), 0, attachments_patch_count));


# BUGS-ATTACHMENTS_APPLICATION
# (Count how many attachments that were applications were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_application_grouped_bugid <- group_by(filter(attachments_clean, mimetype %in% application_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_application_grouped_bugid_summary <- summarize(attachments_clean_application_grouped_bugid, attachments_application_count = n());

# Merge the "attachments_clean_application_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_application_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_application_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_application_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_application_count = safe_ifelse(is.na(attachments_application_count), 0, attachments_application_count));


# BUGS-ATTACHMENTS_AUDIO
# (Count how many attachments that were audio were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_audio_grouped_bugid <- group_by(filter(attachments_clean, mimetype %in% audio_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_audio_grouped_bugid_summary <- summarize(attachments_clean_audio_grouped_bugid, attachments_audio_count = n());

# Merge the "attachments_clean_audio_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_audio_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_audio_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_audio_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_audio_count = safe_ifelse(is.na(attachments_audio_count), 0, attachments_audio_count));


# BUGS-ATTACHMENTS_IMAGE
# (Count how many attachments that were images were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_image_grouped_bugid <- group_by(filter(attachments_clean, mimetype %in% image_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_image_grouped_bugid_summary <- summarize(attachments_clean_image_grouped_bugid, attachments_image_count = n());

# Merge the "attachments_clean_image_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_image_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_image_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_image_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_image_count = safe_ifelse(is.na(attachments_image_count), 0, attachments_image_count));


# BUGS-ATTACHMENTS_MESSAGE
# (Count how many attachments that were messages were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_message_grouped_bugid <- group_by(filter(attachments_clean, mimetype %in% message_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_message_grouped_bugid_summary <- summarize(attachments_clean_message_grouped_bugid, attachments_message_count = n());

# Merge the "attachments_clean_message_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_message_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_message_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_message_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_message_count = safe_ifelse(is.na(attachments_message_count), 0, attachments_message_count));


# BUGS-ATTACHMENTS_MODEL
# (Count how many attachments that were models were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_model_grouped_bugid <- group_by(filter(attachments_clean, mimetype %in% model_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_model_grouped_bugid_summary <- summarize(attachments_clean_model_grouped_bugid, attachments_model_count = n());

# Merge the "attachments_clean_model_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_model_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_model_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_model_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_model_count = safe_ifelse(is.na(attachments_model_count), 0, attachments_model_count));


# BUGS-ATTACHMENTS_MULTIPART
# (Count how many attachments that were multipart were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_multipart_grouped_bugid <- group_by(filter(attachments_clean, mimetype %in% multipart_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_multipart_grouped_bugid_summary <- summarize(attachments_clean_multipart_grouped_bugid, attachments_multipart_count = n());

# Merge the "attachments_clean_multipart_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_multipart_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_multipart_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_multipart_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_multipart_count = safe_ifelse(is.na(attachments_multipart_count), 0, attachments_multipart_count));


# BUGS-ATTACHMENTS_TEXT
# (Count how many attachments that were text were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_text_grouped_bugid <- group_by(filter(attachments_clean, mimetype %in% text_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_text_grouped_bugid_summary <- summarize(attachments_clean_text_grouped_bugid, attachments_text_count = n());

# Merge the "attachments_clean_text_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_text_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_text_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_text_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_text_count = safe_ifelse(is.na(attachments_text_count), 0, attachments_text_count));


# BUGS-ATTACHMENTS_VIDEO
# (Count how many attachments that were video were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_video_grouped_bugid <- group_by(filter(attachments_clean, mimetype %in% video_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_video_grouped_bugid_summary <- summarize(attachments_clean_video_grouped_bugid, attachments_video_count = n());

# Merge the "attachments_clean_video_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_video_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_video_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_video_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_video_count = safe_ifelse(is.na(attachments_video_count), 0, attachments_video_count));


# BUGS-ATTACHMENTS_UNKNOWN
# (Count how many attachments that were an unknown type were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_clean table according to the "bug_id" to which each attachment is submitted
attachments_clean_unknown_grouped_bugid <- group_by(filter(attachments_clean, !(mimetype %in% c(application_mimetypes$Template,
																								  audio_mimetypes$Template,
																								  image_mimetypes$Template,
																								  message_mimetypes$Template,
																								  model_mimetypes$Template,
																								  multipart_mimetypes$Template,
																								  text_mimetypes$Template,
																								  video_mimetypes$Template))), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_clean_unknown_grouped_bugid_summary <- summarize(attachments_clean_unknown_grouped_bugid, attachments_unknown_count = n());

# Merge the "attachments_clean_unknown_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_clean_unknown_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_clean_unknown_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_unknown_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_unknown_count = safe_ifelse(is.na(attachments_unknown_count), 0, attachments_unknown_count));


# BUGS-ATTACHMENTS_KNOWLEDGE_ACTORS
# (Number of attachments by knowledge_actors for each bug)

# Filter according to attachments submitted by knowledge actors
attachments_knowledge_actors <- filter(attachments_base, submitter_id %in% user_knowledge_actors);

# Group the attachments table by bug_id to prepare for DPLYR's summarize() function
attachments_knowledge_actors_grouped <- group_by(attachments_knowledge_actors, bug_id);

# Summarize the number of entries for each bug_id in the attachments table:
attachments_knowledge_actors_grouped_summary <- summarize(attachments_knowledge_actors_grouped, attachments_knowledge_actors_count = n());

# Merge the attachments_knowledge_actors_grouped_summary and bugs_working tables based on bug_id to add column attachments_knowledge_actors_count
setkey(attachments_knowledge_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_knowledge_actors_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_knowledge_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_knowledge_actors_count = safe_ifelse(is.na(attachments_knowledge_actors_count), 0, attachments_knowledge_actors_count));


# BUGS-ATTACHMENTS_CORE_ACTORS
# (Number of attachments by core_actors for each bug)

# Filter according to attachments submitted by core actors
attachments_core_actors <- filter(attachments_base, submitter_id %in% user_core_actors);

# Group the attachments table by bug_id to prepare for DPLYR's summarize() function
attachments_core_actors_grouped <- group_by(attachments_core_actors, bug_id);

# Summarize the number of entries for each bug_id in the attachments table:
attachments_core_actors_grouped_summary <- summarize(attachments_core_actors_grouped, attachments_core_actors_count = n());

# Merge the attachments_core_actors_grouped_summary and bugs_working tables based on bug_id to add column attachments_core_actors_count
setkey(attachments_core_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_core_actors_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_core_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_core_actors_count = safe_ifelse(is.na(attachments_core_actors_count), 0, attachments_core_actors_count));


# BUGS-ATTACHMENTS_PERIPHERAL_ACTORS
# (Number of attachments by peripheral_actors for each bug)

# Filter according to attachments submitted by peripheral actors
attachments_peripheral_actors <- filter(attachments_base, submitter_id %in% user_peripheral_actors);

# Group the attachments table by bug_id to prepare for DPLYR's summarize() function
attachments_peripheral_actors_grouped <- group_by(attachments_peripheral_actors, bug_id);

# Summarize the number of entries for each bug_id in the attachments table:
attachments_peripheral_actors_grouped_summary <- summarize(attachments_peripheral_actors_grouped, attachments_peripheral_actors_count = n());

# Merge the attachments_peripheral_actors_grouped_summary and bugs_working tables based on bug_id to add column attachments_peripheral_actors_count
setkey(attachments_peripheral_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_peripheral_actors_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_peripheral_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_peripheral_actors_count = safe_ifelse(is.na(attachments_peripheral_actors_count), 0, attachments_peripheral_actors_count));


# BUGS-LONGDESCS-COMMENTS_KNOWLEDGE_ACTORS

# We can reuse the longdescs_working variable from above, so no need to import it again
# Filter it to just knowledge actors
longdescs_knowledge_actors <- filter(longdescs_working, who %in% user_knowledge_actors);

# Group according to bug_id
longdescs_working_knowledge_actors_grouped <- group_by(longdescs_knowledge_actors, bug_id);

# Now we'll use Dplyr's summarize() command to extract the count of the comments column for each bug_id
longdescs_working_knowledge_actors_grouped_summary <- summarize(longdescs_working_knowledge_actors_grouped, comments_knowledge_actors_count	= n());

# Merge the longdescs_working_knowledge_actors_grouped_summary and bugs_working tables based on bug_id to add the new column
setkey(longdescs_working_knowledge_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_working_knowledge_actors_grouped_summary, by="bug_id", all.x=TRUE);

# If the submitter was a knowledge-actor, then the first comment is actually the "description", so we have to subtract 1 from the count
# For any NA entries, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, comments_knowledge_actors_count = safe_ifelse( is.na(comments_knowledge_actors_count), 0, safe_ifelse(reporter %in% user_knowledge_actors, comments_knowledge_actors_count - 1, comments_knowledge_actors_count)));


# BUGS-LONGDESCS_COMMENTS_CORE_ACTORS

# We can reuse the longdescs_working variable from above, so no need to import it again
# Filter it to just core actors
longdescs_core_actors <- filter(longdescs_working, who %in% user_core_actors);

# Group according to bug_id
longdescs_working_core_actors_grouped <- group_by(longdescs_core_actors, bug_id);

# Now we'll use Dplyr's summarize() command to extract the count of the comments column for each bug_id
longdescs_working_core_actors_grouped_summary <- summarize(longdescs_working_core_actors_grouped, comments_core_actors_count = n());

# Merge the longdescs_working_core_actors_grouped_summary and bugs_working tables based on bug_id to add the new column
setkey(longdescs_working_core_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_working_core_actors_grouped_summary, by="bug_id", all.x=TRUE);

# If the submitter was a core-actor, then the first comment is actually the "description", so we have to subtract 1 from the count
# For any NA entries, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, comments_core_actors_count = safe_ifelse(is.na(comments_core_actors_count), 0, safe_ifelse(reporter %in% user_core_actors, comments_core_actors_count - 1, comments_core_actors_count)));


# BUGS-LONGDESCS_COMMENTS_PERIPHERAL_ACTORS

# We can reuse the longdescs_working variable from above, so no need to import it again
# Filter it to just peripheral actors
longdescs_peripheral_actors <- filter(longdescs_working, who %in% user_peripheral_actors);

# Group according to bug_id
longdescs_working_peripheral_actors_grouped <- group_by(longdescs_peripheral_actors, bug_id);

# Now we'll use Dplyr's summarize() command to extract the count of the comments column for each bug_id
# Peripheral actors, by definition, have never submitted a bug, so can't be the submitter, so no need to subtract 1.
longdescs_working_peripheral_actors_grouped_summary <- summarize(longdescs_working_peripheral_actors_grouped, comments_peripheral_actors_count	= n());

# Merge the longdescs_working_peripheral_actors_grouped_summary and bugs_working tables based on bug_id to add the new column
setkey(longdescs_working_peripheral_actors_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_working_peripheral_actors_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, comments_peripheral_actors_count = safe_ifelse(is.na(comments_peripheral_actors_count), 0, comments_peripheral_actors_count));


# BUGS-LONGDESCS_COMMENTS_AUTOMATIC_COUNT_AND_MANUAL

# We can reuse the longdescs_working variable from above, so no need to import it again
# Filter it to just comments that are automatic, meaning types 2 & 3, which are marking another as dupe or transition to NEW
# Type 0 means regular, type 1 means flagging a bug as duplicate, but isn't automatic because it is a manual choice that requires explanation of reason it's a duplicate
# Type 4 doesn't exist anymore ( was moving bug), types 5 & 6 are for attachments, but require manually entered explanations of attachments
# Types 2 & 3 are "has dupe" and "move to new by popular vote", the latter of which doesn't exist anymore but has historical entries
# Types 2 & 3 are clearly automatic because they never have any comment text (blank).
longdescs_automatic <- filter(longdescs_working, type==2 | type==3);

# Group according to bug_id
longdescs_automatic_grouped <- group_by(longdescs_automatic, bug_id);

# Now we'll use Dplyr's summarize() command to extract the count of the comments column for each bug_id
longdescs_automatic_grouped_summary <- summarize(longdescs_automatic_grouped, comments_automatic_count	= n());

# Merge the longdescs_automatic_grouped_summary and bugs_working tables based on bug_id to add the new column
setkey(longdescs_automatic_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_automatic_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries, that means 0, so mutate it accordingly.
# Add comments_manual_count from simple subtraction
bugs_working <- mutate(bugs_working, comments_automatic_count 	= safe_ifelse(is.na(comments_automatic_count), 0, comments_automatic_count),
									 comments_manual_count 		= comments_all_actors_count - comments_automatic_count);


# BUGS-LONGDESCS_COMMENTS_ATTACHMENTS

# Count the comments that are related to attachments specifically (types 5 & 6)
longdescs_attachments <- filter(longdescs_working, type==5 | type==6);

# Group according to bug_id
longdescs_attachments_grouped <- group_by(longdescs_attachments, bug_id);

# Now we'll use Dplyr's summarize() command to extract the count of the comments column for each bug_id
longdescs_attachments_grouped_summary <- summarize(longdescs_attachments_grouped, comments_attachments_count	= n());

# Merge the longdescs_attachments_grouped_summary and bugs_working tables based on bug_id to add the new column
setkey(longdescs_attachments_grouped_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_attachments_grouped_summary, by="bug_id", all.x=TRUE);

# For any NA entries, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, comments_attachments_count = safe_ifelse(is.na(comments_attachments_count), 0, comments_attachments_count));							 
									 
									 
# PROFILES-DUPLICATES_USER_REPORTED_IS_DUPLICATE

# Count the number of bugs each user reported that were duplicates OF other bugs
# We can use the "is_duplicate" field that we created earlier in bugs_working to look it up easily
# Filter bugs working to cases where is_duplicate is TRUE
bugs_working_duplicates <- filter(bugs_working, is_duplicate==TRUE);

# Group according to bug reporter's userid (reporter)
bugs_working_duplicates_grouped_user_reporter <- group_by(bugs_working_duplicates, reporter);

# Use summarize() function to count number of bugs that are duplicate for each user
bugs_working_duplicates_grouped_user_reporter_summary <- summarize(bugs_working_duplicates_grouped_user_reporter, user_bugs_reported_is_duplicate_count = n());

# Merge the bugs_working_duplicates_grouped_user_reporter_summary and profiles_working tables based on "reporter" and "userid" to add new count column
setkey(bugs_working_duplicates_grouped_user_reporter_summary, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_duplicates_grouped_user_reporter_summary, by.x="userid", by.y="reporter", all.x=TRUE);

# For any NA entries, that means that user did not report any bugs that were duplicates, so set it to 0.
profiles_working <- mutate(profiles_working, user_bugs_reported_is_duplicate_count = safe_ifelse(is.na(user_bugs_reported_is_duplicate_count), 0, user_bugs_reported_is_duplicate_count));
							 
									 
# PROFILES-DUPLICATES_USER_REPORTED_DUPLICATED_BY

# Count the number of bugs each user reported that were duplicated BY at least one other bug
# We only want to count the number of bugs that were duplicated BY other bugs, so filter for duplicates_count > 0
bugs_working_duplicated <- filter(bugs_working, duplicates_count > 0);

# Group according to bug reporter's userid (reporter)
bugs_working_duplicated_grouped_user_reporter <- group_by(bugs_working, reporter);

# Use summarize() function to count number of bugs that were duplicated at least once
bugs_working_duplicated_grouped_user_reporter_summary <- summarize(bugs_working_duplicated_grouped_user_reporter, user_bugs_reported_was_duplicated_count = n());

# Merge the bugs_working_duplicated_grouped_user_reporter_summary and profiles_working tables based on "reporter" and "userid" to add new count column
setkey(bugs_working_duplicated_grouped_user_reporter_summary, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_duplicated_grouped_user_reporter_summary, by.x="userid", by.y="reporter", all.x=TRUE);

# For any NA entries, that means that user did not report any bugs that were duplicated BY at least one other bug, so set it to 0.
profiles_working <- mutate(profiles_working, user_bugs_reported_was_duplicated_count = safe_ifelse(is.na(user_bugs_reported_was_duplicated_count), 0, user_bugs_reported_was_duplicated_count));

									 
# PROFILES-DUPLICATES_USER_REPORTED_DUPLICATED_BY_TOTAL

# Count the total number of times any of the bugs reported by each user was later duplicated by another bug
# This count is distinct from the previous one in that each bug reported could be duplicated more than once, which is captured by this total count

# Bugs_working already has a duplicates_count variable, created earlier, so we can simply group by reporter and sum()
# Group according to bug reporter's userid (reporter)
bugs_working_user_reporter_grouped <- group_by(bugs_working, reporter);

# Use summarize() function to sum the duplicates_count across all bugs for each user reporter
bugs_working_user_reporter_grouped_summary <- summarize(bugs_working_user_reporter_grouped, user_bugs_reported_all_duplications_count = sum(duplicates_count));

# Merge the bugs_working_user_reporter_grouped_summary and profiles_working tables based on "reporter" and "userid" to add new count column
setkey(bugs_working_user_reporter_grouped_summary, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_user_reporter_grouped_summary, by.x="userid", by.y="reporter", all.x=TRUE);

# For any NA entries, that means that user did not report any bugs that were duplicated BY at least one other bug, so set it to 0.
profiles_working <- mutate(profiles_working, user_bugs_reported_all_duplications_count = safe_ifelse(is.na(user_bugs_reported_all_duplications_count), 0, user_bugs_reported_all_duplications_count));


# PROFILES-FLAGS_USER_SET
# (Count how many flags were set by each user)

# There are too many types of flags to count the different types
# Further, many of the types are not clearly defined, redundant, etc.
# So we'll just get an overall count.
# Note that the "status" field in the flags table means that it's possible that we'll double count the same getting set and then removed
# However, we can treat "setting a flag" as one count and "removing a flag" as another count.  So this variable
# should better be understood as treating "postiive" and "negative" flags separately.  There's really no other clena way given the DB format

# Group the flags_base table by setter_id to prepare it for summarize()
# Since we're updated only the profiles_working table, we don't need flags_clean
flags_working_grouped_setter_id <- group_by(flags_base, setter_id);

# Use summarize() to count the number of entries for each setter_id
flags_working_grouped_setter_id_summary <- summarize(flags_working_grouped_setter_id, user_flags_set_count = n());

# Merge the flags_working_grouped_setter_id_summary and profiles_working tables based on setter_id and userid to add the count of flags set by each user
setkey(flags_working_grouped_setter_id_summary, setter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, flags_working_grouped_setter_id_summary, by.x="userid", by.y="setter_id", all.x=TRUE);

# Any NA values means that the user set no flags, so replace with 0
profiles_working <- mutate(profiles_working, user_flags_set_count = safe_ifelse(is.na(user_flags_set_count), 0, user_flags_set_count));				


# PROFILES-WATCHING_USER_ALL_ACTORS
# (Track how many other users each user is watching)

# Use DPLYR's group_by() function to organize the watch_base table according to the "watcher"
watch_base_grouped_watcher <- group_by(watch_base, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_summary <- summarize(watch_base_grouped_watcher, user_watching_all_actors_count = n());

# Merge the "watch_base_grouped_watcher_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "user_watching_all_actors_count" column, that means the user is watching nobody, so set it to zero
profiles_working <- mutate(profiles_working, user_watching_all_actors_count = safe_ifelse(is.na(user_watching_all_actors_count), 0, user_watching_all_actors_count));


# PROFILES-WATCHING_USER_ALL_DOMAINS
# (Track how many other domains each user is watching)

# Select only entries with distinct pairs of "watcher" users and "watched_domains"
watch_base_distinct_watcher_watched_domains <- distinct(select(watch_base, watcher, watched_domain));

# Use DPLYR's group_by() function to organize the watch_base_distinct_watcher_watched_domains table according to the "watcher"
watch_base_grouped_watcher_watched_domain <- group_by(watch_base_distinct_watcher_watched_domains, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_domain_summary <- summarize(watch_base_grouped_watcher_watched_domain, user_watching_all_domains_count = n());

# Merge the "watch_base_grouped_watcher_watched_domain_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_domain_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_domain_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "user_watching_all_domains_count" column, that means the user isn't watching any domains, so set it to zero
profiles_working <- mutate(profiles_working, user_watching_all_domains_count = safe_ifelse(is.na(user_watching_all_domains_count), 0, user_watching_all_domains_count));


# PROFILES-WATCHING_USER_KNOWLEDGE_ACTORS
# (Track how many knowledge actor users each user is watching)

# Filter watch_base to "watched" knowledge actors
watch_base_watched_knowledge_actors <- filter(watch_base, watched %in% user_knowledge_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the "watcher"
watch_base_grouped_watcher_watched_knowledge_actors <- group_by(watch_base_watched_knowledge_actors, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_knowledge_actors_summary <- summarize(watch_base_grouped_watcher_watched_knowledge_actors, user_watching_knowledge_actors_count = n());

# Merge the "watch_base_grouped_watcher_watched_knowledge_actors_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_knowledge_actors_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_knowledge_actors_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "user_watching_knowledge_actors_count" column, that means the user is not watching any knowledge actors, so set it to zero
profiles_working <- mutate(profiles_working, user_watching_knowledge_actors_count = safe_ifelse(is.na(user_watching_knowledge_actors_count), 0, user_watching_knowledge_actors_count));


# PROFILES-WATCHING_USER_CORE_ACTORS
# (Track how many core actor users each user is watching)

# Filter watch_base to "watched" core actors
watch_base_watched_core_actors <- filter(watch_base, watched %in% user_core_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the "watcher"
watch_base_grouped_watcher_watched_core_actors <- group_by(watch_base_watched_core_actors, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_core_actors_summary <- summarize(watch_base_grouped_watcher_watched_core_actors, user_watching_core_actors_count = n());

# Merge the "watch_base_grouped_watcher_watched_core_actors_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_core_actors_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_core_actors_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "user_watching_core_actors_count" column, that means the user is not watching any core actors, so set it to zero
profiles_working <- mutate(profiles_working, user_watching_core_actors_count = safe_ifelse(is.na(user_watching_core_actors_count), 0, user_watching_core_actors_count));


# PROFILES-WATCHING_USER_PERIPHERAL_ACTORS
# (Track how many peripheral actor users each user is watching)

# Filter watch_base to "watched" peripheral actors
watch_base_watched_peripheral_actors <- filter(watch_base, watched %in% user_peripheral_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the "watcher"
watch_base_grouped_watcher_watched_peripheral_actors <- group_by(watch_base_watched_peripheral_actors, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_peripheral_actors_summary <- summarize(watch_base_grouped_watcher_watched_peripheral_actors, user_watching_peripheral_actors_count = n());

# Merge the "watch_base_grouped_watcher_watched_peripheral_actors_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_peripheral_actors_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_peripheral_actors_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "user_watching_peripheral_actors_count" column, that means the user is not watching any peripheral actors, so set it to zero
profiles_working <- mutate(profiles_working, user_watching_peripheral_actors_count = safe_ifelse(is.na(user_watching_peripheral_actors_count), 0, user_watching_peripheral_actors_count));








# Clean up functions before creating global variables

# Longdescs loses domain since we used longdescs_clean in this subroutine, not longdescs_base
# Select the comment_id as unique identifier, and matching domain, if any.
longdescs_base_select <- select(longdescs_base, comment_id, domain);

# Merge to re-add domain when possible, use comment_id as unique identifier for each row
setkey(longdescs_base_select, comment_id);
setkey(longdescs_working, comment_id);
longdescs_working <- merge(longdescs_working, longdescs_base_select, by="comment_id", all.x=TRUE);

# For any NA entries in "domain", that means user who wrote comment has no domain, so leave as is.


# Set global variables for other functions
profiles_interactions 	<<- profiles_working;
bugs_interactions 		<<- bugs_working;
longdescs_interactions	<<- longdescs_working;


} # End operationalize_interactions function


# OPERATIONALIZE ORGANIZATION-LEVEL VARIABLES

operationalize_org_level <- function() {

# PROFILES-ALL_TABLES_ORG_SUMS
# (Summarize all the individual user counts into org-based counts for the various table interactions)
# Using the user-level variables created in previous functions, we can simply sum() by domain

# Import the profiles_interaction table to use in this function
profiles_working <- profiles_interactions;

# Group profiles according to domains
profiles_working_grouped_domain <- group_by(profiles_working, domain);

# Use summarize() function to sum the various user counts for each domain
profiles_working_grouped_domain_summary <- summarize(profiles_working_grouped_domain ,  org_all_actors_count						= n(),
																						org_bugs_reported_is_duplicate_count 		= sum(user_bugs_reported_is_duplicate_count),
																						org_bugs_reported_was_duplicated_count 		= sum(user_bugs_reported_was_duplicated_count),
																						org_bugs_reported_all_duplications_count 	= sum(user_bugs_reported_all_duplications_count),
																						org_flags_set_count 						= sum(user_flags_set_count),
																						org_watching_all_actors_count 				= sum(user_watching_all_actors_count),
																						org_watching_all_domains_count 				= sum(user_watching_all_domains_count),
																						org_watching_knowledge_actors_count 		= sum(user_watching_knowledge_actors_count),
																						org_watching_core_actors_count				= sum(user_watching_core_actors_count),
																						org_watching_peripheral_actors_count		= sum(user_watching_peripheral_actors_count),
																						org_activity_all_actors_count 				= sum(user_activity_count),
																						org_bugs_reported_count 					= sum(user_bugs_reported_count),
																						org_bugs_assigned_count 					= sum(user_bugs_assigned_count),
																						org_bugs_qa_count 							= sum(user_bugs_qa_count),
																						org_bugs_reported_reopened_count 			= sum(user_bugs_reported_reopened_count),
																						org_bugs_reported_assigned_count 			= sum(user_bugs_reported_assigned_count),
																						org_bugs_reported_reassigned_count 			= sum(user_bugs_reported_reassigned_count),
																						org_bugs_assigned_to_reopened_count 		= sum(user_bugs_assigned_to_reopened_count),	
																						org_bugs_assigned_to_assigned_count			= sum(user_bugs_assigned_to_assigned_count), 	
																						org_bugs_assigned_to_reassigned_count		= sum(user_bugs_assigned_to_reassigned_count),
																						org_bugs_qa_contact_reopened_count 			= sum(user_bugs_qa_contact_reopened_count),
																						org_bugs_qa_contact_assigned_count 			= sum(user_bugs_qa_contact_assigned_count), 
																						org_bugs_qa_contact_reassigned_count 		= sum(user_bugs_qa_contact_reassigned_count),
																						org_activity_assigning_count				= sum(user_activity_assigning_count),
																						org_activity_reassigning_count				= sum(user_activity_reassigning_count),
																						org_activity_reopening_count				= sum(user_activity_reopening_count),
																						org_attachments_all_types_count				= sum(user_attachments_all_types_count),
																						org_attachments_patch_count					= sum(user_attachments_patch_count),
																						org_attachments_application_count			= sum(user_attachments_application_count),
																						org_attachments_audio_count					= sum(user_attachments_audio_count),
																						org_attachments_image_count					= sum(user_attachments_image_count),
																						org_attachments_message_count				= sum(user_attachments_message_count),
																						org_attachments_model_count					= sum(user_attachments_model_count),
																						org_attachments_multipart_count				= sum(user_attachments_multipart_count),
																						org_attachments_text_count					= sum(user_attachments_text_count),
																						org_attachments_video_count					= sum(user_attachments_video_count),
																						org_attachments_unknown_count				= sum(user_attachments_unknown_count),
																						org_knowledge_actors_count					= sum(user_knowledge_actor),
																						org_core_actors_count						= sum(user_core_actor),
																						org_peripheral_actors_count					= sum(user_peripheral_actor));
																						

# Somehow, the domain gets set as an integer, not a character string, so fix it:
profiles_working_grouped_domain_summary$domain <- as.character(profiles_working_grouped_domain_summary$domain);
																						
# Merge	profiles_working_grouped_domain_summary and profiles_working tables based on domain to add new count columns
setkey(profiles_working_grouped_domain_summary, domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, profiles_working_grouped_domain_summary, by="domain", all.x=TRUE);


# PROFILES_ORG_LOGICAL

# Create logical variables that depend on org-level count variables
profiles_working <- mutate(profiles_working, org_knowledge_actor		= safe_ifelse(org_knowledge_actors_count	> 0, 					 			TRUE, FALSE),
											 org_core_actor				= safe_ifelse(org_core_actors_count			> 0, 					 			TRUE, FALSE));
profiles_working <- mutate(profiles_working, org_peripheral_actor		= safe_ifelse(org_knowledge_actor 			== FALSE & org_core_actor == FALSE, TRUE, FALSE));
											 

# Should be no NA entries possible in this function since we're working from the profiles_interactions table that always has a defined domain for each user


# Set global variables for other functions
profiles_org 	<<- profiles_working;
	
} # End operationalize_org_level function







# MAIN
# Run our desired functions
	
set_options();
load_libraries();
set_parameters();
load_bugzilla_data();
# load_compustat_data();
load_mimetypes();
# clean_compustat_data();
clean_bugzilla_data();
operationalize_base();
# Remove global variables that we no longer need
rm(longdescs, activity, cc, attachments, votes, watch, duplicates, group_members, keywords, flags, group_list);

# Perform garbage collection to free memory
gc();
operationalize_interactions();
operationalize_org_level();

# Perform garbage collection again to free memory
gc();

#
# EOF

