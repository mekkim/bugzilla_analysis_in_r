#################################################################################
#																				#
# 		ANALYZING MOZILLA'S BUGZILLA DATABASE USING R							#
#																				#
#		© 2015 by Mekki MacAulay, mekki@mekki.ca, http://mekki.ca				#
#		Twitter: @mekki - http://twitter.com/mekki								#
#		Some rights reserved.													#
#																				#
#		Current version created on December 8, 2015								#
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

# Imputation parameters
MERGE_MOZILLA_DOMAINS 			<<- TRUE;
MERGE_DOT_BUGS_DOMAINS			<<- TRUE;
MERGE_BUGZILLA_DOMAINS			<<- TRUE;
MERGE_KNOWN_ORG_DOMAINS			<<- TRUE;
MERGE_FORMERLY_NETSCAPE_DOMAINS	<<- FALSE;
MERGE_KNOWN_USER_DOMAINS		<<- FALSE;
DELETE_NOBODY_PROFILE			<<- FALSE;
CORRECT_TYPO_DOMAINS			<<- TRUE;
DELETE_TEST_BUGS				<<- FALSE;
ALLOW_INVALID_TLDS				<<- TRUE;
ALLOW_UNUSUAL_TLDS				<<-	TRUE;

} # End set_parameters function


# SET R OPTIONS FOR CODE EXECUTION ENVIRONMENT
set_options <- function () {

# Increase the memory limit to force Windows to use the pagefile for all other processes and allocate 
# maximum amount of physical RAM to R
memory.limit(100000);

# Set warnings to display as they occur and give verbose output
options(warn=1, verbose=TRUE);

} # End set_options function


# LOAD LIBRARIES
load_libraries <- function () {

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
		if (length(preserved_class) > 1) {
			class(return_obj) <- preserved_class;
		}
	} else {
		class(return_obj) 	<- preserved_class;
	}
	return(return_obj);
  
} # End safe if-else function


# DATA INPUT

# In this step, we create and populate all of the data frames/tables that will be manipulated in the research
# from their data sources including the MySQL database and/or CSV files.

# Load Bugzilla data frames/tables from the MySQL DB
load_bugzilla_data_from_DB <- function () {

# Load MySQl connection library
library(RMySQL);

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
products		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM products;');
dependencies	<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM dependencies;');


# We're now done with the RMySQL library, so detach it to prevent any problems
detach("package:RMySQL", unload=TRUE);

# After we've loaded all the data, the MySQL server hogs RAM because of its cashing, so restart it
# with the following commands to free up memory:
system("net stop MySQL");
system("net start MySQL");

} # End load_bugzilla_data_from_DB function



# Compustat functions are included for my dissertation work and depend on access to a specific set of
# compustat data that I cannot redistribute.  They're commented out in the main() function so you can safely ignore.
# Compustat data frames/tables
load_compustat_data_from_CSV <- function () {

# Create data frame variables from the COMPUSTAT CSV files
# We'll use the fread function in data.table

compustatna 	<<- fread("./data/compustatna.csv");
compustatint 	<<- fread("./data/compustatint.csv");

} # End load_compustat_data function


# Mimetypes / Internet Media Types from Internet Assigned Numbers Authority (IANA)
load_mimetypes_from_remote_DB <- function () {

# Read all 8 CSV files, one for each registry, from IANA update list at http://www.iana.org/assignments/media-types/media-types.xml
# We only really care about the "Template" column, which we'll use for matching later
# data.table's fread() could be a better choice but since these CSVs are small and well defined, might not be needed.
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

} # End load_mimetypes_from_remote_DB function


# Load mimetypes / Internet Media Types from previously saved local CSV files to not repeatedly hit remote server
# data.table's fread() could be a better choice but since these CSVs are small and well defined, might not be needed.
load_mimetypes_from_CSV <- function () {

application_mimetypes	<<- read.csv('./data/application_mimetypes.csv');
audio_mimetypes			<<- read.csv('./data/audio_mimetypes.csv');
image_mimetypes			<<- read.csv('./data/image_mimetypes.csv');
message_mimetypes		<<- read.csv('./data/message_mimetypes.csv');
model_mimetypes			<<- read.csv('./data/model_mimetypes.csv');
multipart_mimetypes		<<- read.csv('./data/multipart_mimetypes.csv');
text_mimetypes			<<- read.csv('./data/text_mimetypes.csv');
video_mimetypes			<<- read.csv('./data/video_mimetypes.csv');

} # End load_mimetypes_from_CSV


# Write mimetype data tables to csv files to not have to hit the IANA database servers over and over
write_mimetypes <- function () {

# Write each table as CSV to specified output folder
write.csv(application_mimetypes,	'application_mimetypes.csv');
write.csv(audio_mimetypes,			'audio_mimetypes.csv');
write.csv(image_mimetypes,			'image_mimetypes.csv');
write.csv(message_mimetypes,		'message_mimetypes.csv');
write.csv(model_mimetypes,			'model_mimetypes.csv');
write.csv(multipart_mimetypes,		'multipart_mimetypes.csv');
write.csv(text_mimetypes,			'text_mimetypes.csv');
write.csv(video_mimetypes,			'video_mimetypes.csv');

} # End write_mimetypes function


# END DATA INPUT


# CLEAN DATA TABLES

# These functions are used to clean/set/fix data types 
# and adjust basic variables within the tables

 
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

# PROFILES

# Import the profiles table from the previous subroutine to work on
profiles_working <- profiles;

# Adjust variable class and type as appropriate when auto-detection wasn't good
profiles_working <- mutate(profiles_working, userid 					= as.factor(userid),
											 disable_mail				= as.logical(disable_mail),
											 first_patch_bug_id 		= as.factor(first_patch_bug_id),
											 is_enabled					= as.logical(is_enabled),
											 first_patch_approved_id	= as.factor(first_patch_approved_id),
											 mybugslink					= as.logical(mybugslink),
											 creation_ts				= as.POSIXct(creation_ts, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
											 login_name					= as.character(login_name),
											 realname					= as.character(realname),
											 disabledtext				= as.character(disabledtext),
											 public_key					= as.character(public_key));
													
if (DELETE_NOBODY_PROFILE) {

	# The userid "1" means "nobody", but has a "mozilla.org" domain, so would otherwise be retained.
	# Can optionally delete it
	profiles_working			<- filter(profiles_working, userid != 1);
}
																										
# Rename the "comment_count" column to be clear why it is always slightly larger than the calculated user_comments_all_bugs_all_count later on
profiles_working <- dplyr::rename(profiles_working, comment_count_including_sanitized_bugs = comment_count);


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
									 cf_last_resolved			= as.POSIXct(cf_last_resolved, 	format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
									 resolution					= as.factor(as.character(resolution)),
									 short_desc					= as.character(short_desc),
									 status_whiteboard			= as.character(status_whiteboard),
									 alias						= as.character(alias));	

if (DELETE_TEST_BUGS) {									 
	# Bugs 8358, 14616, 16198, 16199, 16473, & 16532 are incomplete "test" bugs that aren't real, so can delete them
	bugs_working <- filter(bugs_working, !(bug_id %in% c("8358", "14616", "16198", "16199", "16473", "16532")));
}
	
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
											   bug_when			= as.POSIXct(bug_when, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
											   thetext			= as.character(thetext));


# ACTIVITY

# Import the activity table from the previous subroutine to work on
activity_working <- activity;

# Set fields that were incorrectly set as integer to factors
activity_working <- mutate(activity_working, bug_id 	= as.factor(bug_id),
											 who		= as.factor(who),
											 fieldid	= as.factor(fieldid),
											 attach_id	= as.factor(attach_id),
											 comment_id = as.factor(comment_id),
											 bug_when 	= as.POSIXct(bug_when, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
											 removed	= as.character(removed),
											 added		= as.character(added));


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
												   modification_time 	= as.POSIXct(modification_time, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
												   description			= as.character(description),
												   filename				= as.character(filename));


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
										id					= as.factor(id),
										type_id				= as.factor(type_id),
										attach_id			= as.factor(attach_id),
										requestee_id		= as.factor(requestee_id),
										creation_date		= as.POSIXct(creation_date, 	format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
										modification_date	= as.POSIXct(modification_date, format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01"),
										status				= as.factor(as.character(status)));
										
											 
# PRODUCTS

# Import the products table from the previous subroutine to work on
products_working <- products;

# Set the field classes and types as appropriate when auto-detection sucked
products_working <- mutate(products_working, name				= as.factor(as.character(name)),
											 description		= as.character(description),
											 votesperuser		= as.factor(votesperuser),
											 maxvotesperbug		= as.factor(maxvotesperbug),
											 votestoconfirm		= as.factor(votestoconfirm),
											 defaultmilestone	= as.factor(as.character(defaultmilestone)),
											 id					= as.factor(id),
											 classification_id	= as.factor(classification_id),
											 isactive			= as.logical(isactive),
											 allows_unconfirmed	= as.logical(allows_unconfirmed));

# DEPENDENCIES

# Import the dependencies table from the previous subroutine to work on
dependencies_working <- dependencies;

# Set the field classes and types as appropriate when auto-detection sucked
dependencies_working <- mutate(dependencies_working, blocked 	= as.factor(blocked),
													 dependson	= as.factor(dependson)); 
							 
											 
# GROUP LIST

# Import the group_list table from the previous subroutine to work on
group_list_working <- group_list;											 

# Set the field classes and types as appropriate when auto-detection sucked
group_list_working <- mutate(group_list_working, name			= as.factor(as.character(name)),
												 description	= as.character(description),
												 isbuggroup		= as.logical(isbuggroup),
												 userregexp		= as.character(userregexp),
												 isactive		= as.logical(isactive),
												 id				= as.factor(id),
												 icon_url		= as.character(icon_url),
												 secure_mail	= as.logical(secure_mail));

												 
# CLEANUP											 
											 
# Create global variable to use in other functions
# Make them all data.tables along the way since we'll use functions from the data.tables library throughout

profiles_clean 					<<- as.data.table(profiles_working);
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
products_clean					<<- as.data.table(products_working);
dependencies_clean              <<- as.data.table(dependencies_working);
group_list_clean				<<- as.data.table(group_list_working);

} # End clean_bugzilla_data function

# END CLEAN DATA TABLES


# CREATE BASE OPERATIONALIZED VARIABLES

# This function adds a domain columns to all the tables
# In cases where a given domain is part of the webmails/ISP/other non-org list, new variable is_org_domain is set to FALSE
# Cases where domain is NA and their relevant is_org_domain values are left as NA to be easily filtered out later as desired
add_domains <- function () {

# All the domains are derived from the login_name column of the profiles (profiles_clean) table
# So we first have to create the domain column for profiles

# PROFILES

# Import the profiles table from the previous functions to work on
profiles_working <- profiles_clean;

# Createa a new variable called "stripped_email" based on the "login_name" column that removes the portion before the @ symbol
stripped_emails <- sub("^[a-z0-9_%+-.]+@((?:[a-z0-9-]+\\.)+[a-z]{2,4})$", "\\1", profiles_working$login_name, ignore.case = TRUE, perl = TRUE);

# Write the stripped emails to file to later input into the PHP script
write(stripped_emails, "stripped_emails.txt");

# Call the PHP script described at the start of this file to trim the stripped emails to registerable domain portion only
domain_list_unclean <- system("php -f domainparser.php", intern=TRUE);

# The PHP script returns an unclean version of the registerable domains, so parse out only the registerable domain part
domain_list <- sub('^.+\\\"(.+)\\\"$', "\\1", domain_list_unclean, ignore.case = TRUE, perl = TRUE);

# Add the original_domain (not imputed) column to the profiles table from the created list
# Set the class to factor and type to character to be sure it's read correctly
# And set the characters to all lowercase, to ensure matching
profiles_working$original_domain <- as.factor(tolower(as.character(domain_list)));

# Clean up the original_domain entries to correctly be as "NA" where appropriate
profiles_working <- mutate(profiles_working, original_domain = safe_ifelse(original_domain=="NULL" | original_domain =="", NA, original_domain));

# Read in the text file that has the list of known webmail, ISP, and other non-org domains
# It is read in as a data.table, with V1 as the only column
webmail_domains	<- fread("webmaildomains.txt", header=FALSE);

# Set the class to factor and type to character to be sure it's matched correctly
# Also, make it a vector list instead of a data.table for simplicity
# And set the characters to all lowercase, to ensure matching
webmail_domains <- as.factor(tolower(as.character(webmail_domains$V1)));

# Create a new column in the profiles table that flags non-org domains so that they can be easily excluded later
# Also create new column domain that will hold the imputed version of original_domain
profiles_working <- mutate(profiles_working, is_org_domain = safe_ifelse(is.na(original_domain), NA, safe_ifelse(original_domain %in% webmail_domains, FALSE, TRUE)),
											 domain		   = original_domain);
											 

# DOMAIN IMPUTATION
											 
# Use manual imputation to clean up the domain column, merging together known organizations that use multiple domain names
# Uses user-specified variables at top of script to determine which imputations are used in a given run

if (MERGE_DOT_BUGS_DOMAINS) {

	# Mozilla uses some fake email addresses that end in ".bugs" for tracking purposes.
	profiles_working$domain	<- sub("^.+\\.bugs$", "mozilla\\.org", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
}

if (MERGE_MOZILLA_DOMAINS) {

	# Mozilla internally uses "mozilla.org", "mozilla.com" and "mozillafoundation.org" addresses.  Let's merge them to "mozilla.org" as a single organization
	profiles_working$domain	<- sub("^mozilla\\.com$", 			"mozilla\\.org", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^mozillafoundation\\.org$", "mozilla\\.org", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
}

if (MERGE_BUGZILLA_DOMAINS) {

	# Bugzilla used to use .com, but now it's just .org
	profiles_working$domain	<- sub("^bugzilla\\.com$", "bugzilla\\.org", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
}

if (MERGE_KNOWN_ORG_DOMAINS) {

	# Some organizations use multiple domains. Hard to catch them all, but these are the ones noticed:
	profiles_working$domain	<- sub("^mot\\.com$", 			"motorola\\.com", 		profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^nortel\\.com$", 		"nortelnetworks\\.com", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^nortel\\.ca$", 		"nortelnetworks\\.com", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^nrc\\.ca$", 			"nrc\\.gc\\.ca", 		profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^nrc-cnrc\\.gc\\.ca$", 	"nrc\\.gc\\.ca", 		profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^mohawkcollege\\.ca$", 	"mohawkc\\.on\\.ca", 	profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^senecacollege\\.ca$", 	"senecac\\.on\\.ca", 	profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^crc\\.ca$", 			"ic\\.gc\\.ca", 		profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^hamilton\\.ca$", 		"hamilton\\.on\\.ca", 	profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^humber\\.ca$", 		"humberc\\.on\\.ca", 	profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^nfy\\.ca$", 			"nfy\\.bc\\.ca", 		profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^ocad\\.ca$", 			"ocadu\\.ca", 			profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^stclaircollege\\.ca$", "stclairc\\.on\\.ca", 	profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^toronto\\.ca$", 		"toronto\\.on\\.ca", 	profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^unitz\\.ca$", 			"unitz\\.on\\.ca", 		profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^usherb\\.ca$", 		"usherbrooke\\.ca", 	profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^yknet\\.ca$", 			"yknet\\.yk\\.ca", 		profiles_working$domain, ignore.case = TRUE, perl = TRUE);
	profiles_working$domain	<- sub("^ieee\\.com$", 			"ieee\\.org", 			profiles_working$domain, ignore.case = TRUE, perl = TRUE);
}

if (CORRECT_TYPO_DOMAINS) {

	# Manual inspection reveals many common typos in domain names that would otherwise be valid.
	# Here we make educated guesses at the intended values and correct them
	profiles_working$domain	<- sub("^iee\\.org", "ieee\\.org", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
}

if (MERGE_FORMERLY_NETSCAPE_DOMAINS) {

	# Old Netscape profiles are deprecated to this format. Can optionally merge them with the other Netscape accounts.
	profiles_working$domain	<- sub("^formerly-netscape\\.com$", "netscape\\.com", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
}

if (MERGE_KNOWN_USER_DOMAINS) {

	# Some users are known to have organizational affiliations not related to their domain.  This list is necessarily incomplete.
	# Can optionally merge them with their known organizational affiliations
	profiles_working$domain	<- sub("^joshmatthews\\.met", "mozilla\\.org", profiles_working$domain, ignore.case = TRUE, perl = TRUE);
}

if (ALLOW_UNUSUAL_TLDS | ALLOW_INVALID_TLDS) {
	
	# The address <name>@nic.in is technically valid but only for National Infoatics Center of India. All other uses require a third level domain, so it's classified as "not valid" by default
	profiles_working <- mutate(profiles_working, domain = safe_ifelse(domain=="null" & grepl("\\@nic\\.in$", login_name, ignore.case = TRUE, perl = TRUE), "nic.in", domain));
}

if (ALLOW_INVALID_TLDS) { 
	
	# ALLOW_INVALID_TLDS implies ALLOW_UNUSUAL_TLDS so these will have already been imputed above
	# Examples of invalid TLDs include .iki.fi, .homedns.org, nowhere.tld, and any country-specific TLDs that aren't following the second or third level domain rules
	# Our imputation will necessarily be bad, so we'll make the domain whatever is after the @ symbol.  This isn't recommended, which is why default is "false"
	profiles_working <- mutate(profiles_working, domain = safe_ifelse(domain=="null", sub("^[a-z0-9_%+-.]+@((?:[a-z0-9-]+\\.)+[a-z]{2,4})$", "\\1", login_name, ignore.case = TRUE, perl = TRUE), domain));
}

if(DELETE_NOBODY_PROFILE == FALSE) {
	# The "nobody" profile will end up with domain "mozilla.org", which isn't correct, especially since it is the default  "assigned_to" value
	# If we keep that profile, need to impute the domain and is_org_domain to NA 
	profiles_working <- mutate(profiles_working, domain 		= safe_ifelse(userid==1, NA, domain),
												 is_org_domain	= safe_ifelse(userid==1, NA, is_org_domain));
}												 
												 
# Clean up any remaining "null" entries by setting them to NA
# If ALLOW_INVALID_TLDS was TRUE, there will be no "null" domains left as they will already have been imputed.
profiles_working <- mutate(profiles_working, is_org_domain 	= safe_ifelse(domain=="null", NA, is_org_domain),
											 domain			= safe_ifelse(domain=="null", NA, domain));

# BUGS

# Import the bugs table from the previous functions to work on
bugs_working <- bugs_clean;

# Add the domain and is_org_domain status of reporter, assigned_to, and qa_contact users for each bug

# First for the bug's reporter
setkey(profiles_working, userid);
setkey(bugs_working, reporter);
bugs_working <- merge(bugs_working, select(profiles_working, userid, domain, is_org_domain), by.x="reporter", by.y="userid", all.x=TRUE);

# Rename them to "reporter_domain" & "is_org_reporter_domain" so that we won't clober the columns when we repeat for assigned_to and qa_contact
bugs_working <- dplyr::rename(bugs_working, reporter_domain 		= domain,
											is_org_reporter_domain	= is_org_domain);
																						
# Repeat with assigned_to
setkey(profiles_working, userid);
setkey(bugs_working, assigned_to);
bugs_working <- merge(bugs_working, select(profiles_working, userid, domain, is_org_domain), by.x="assigned_to", by.y="userid", all.x=TRUE);

# Rename them to "assigned_to_domain" & "is_org_assigned_to_domain" so that we won't clober the columns when we repeat for qa_contact
bugs_working <- dplyr::rename(bugs_working, assigned_to_domain 			= domain,
											is_org_assigned_to_domain	= is_org_domain);
											
# Repeat with qa_contact
setkey(profiles_working, userid);
setkey(bugs_working, qa_contact);
bugs_working <- merge(bugs_working, select(profiles_working, userid, domain, is_org_domain), by.x="qa_contact", by.y="userid", all.x=TRUE);

# Rename them to "qa_contact_domain" & "is_org_qa_contact_domain" so that we know what they are
bugs_working <- dplyr::rename(bugs_working, qa_contact_domain 			= domain,
											is_org_qa_contact_domain	= is_org_domain);


# ACTIVITY

# Import the activity table from the previous functions to work on
activity_working <- activity_clean;

# Add the domain and is_org_domain status of who variable, the user who did the activity
setkey(profiles_working, userid);
setkey(activity_working, who);

activity_working <- merge(activity_working, select(profiles_working, userid, domain, is_org_domain), by.x="who", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who did the activity
activity_working <- dplyr::rename(activity_working, who_domain			= domain,
													is_org_who_domain	= is_org_domain);
													
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each the bug_id related to each activity
setkey(bugs_working, bug_id);
setkey(activity_working, bug_id);

activity_working <- merge(activity_working, select(bugs_working, bug_id, 
																 reporter_domain, 		 assigned_to_domain, 		qa_contact_domain,
																 is_org_reporter_domain, is_org_assigned_to_domain, is_org_qa_contact_domain),
																 by="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug associated with the activity
activity_working <- dplyr::rename(activity_working, bug_reporter_domain				= reporter_domain,
													bug_assigned_to_domain			= assigned_to_domain,
													bug_qa_contact_domain			= qa_contact_domain,
													is_org_bug_reporter_domain		= is_org_reporter_domain,
													is_org_bug_assigned_to_domain	= is_org_assigned_to_domain,
													is_org_bug_qa_contact_domain	= is_org_qa_contact_domain);
																

# CC

# Import the cc table from the previous functions to work on
cc_working <- cc_clean;

# Add the domain and is_org_domain status of who variable, the user who requested the cc
setkey(profiles_working, userid);
setkey(cc_working, who);

cc_working <- merge(cc_working, select(profiles_working, userid, domain, is_org_domain), by.x="who", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who requested the CC
cc_working <- dplyr::rename(cc_working, who_domain			= domain,
										is_org_who_domain	= is_org_domain);
										
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each the bug_id related to each cc
setkey(bugs_working, bug_id);
setkey(cc_working, bug_id);

cc_working <- merge(cc_working, select(bugs_working, bug_id, 
													 reporter_domain, 		 assigned_to_domain, 		qa_contact_domain,
													 is_org_reporter_domain, is_org_assigned_to_domain, is_org_qa_contact_domain),
													 by="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug associated with the cc
cc_working <- dplyr::rename(cc_working, bug_reporter_domain				= reporter_domain,
										bug_assigned_to_domain			= assigned_to_domain,
										bug_qa_contact_domain			= qa_contact_domain,
										is_org_bug_reporter_domain		= is_org_reporter_domain,
										is_org_bug_assigned_to_domain	= is_org_assigned_to_domain,
										is_org_bug_qa_contact_domain	= is_org_qa_contact_domain);


# ATTACHMENTS

# Import the attachments table from the previous functions to work on
attachments_working <- attachments_clean;

# Add the domain and is_org_domain status of submitter_id variable, the user who submitted the attachments
setkey(profiles_working, userid);
setkey(attachments_working, submitter_id);

attachments_working <- merge(attachments_working, select(profiles_working, userid, domain, is_org_domain), by.x="submitter_id", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who submitted the attachments
attachments_working <- dplyr::rename(attachments_working, submitter_id_domain			= domain,
														  is_org_submitter_id_domain	= is_org_domain);
													
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each the bug_id related to each attachments
setkey(bugs_working, bug_id);
setkey(attachments_working, bug_id);

attachments_working <- merge(attachments_working, select(bugs_working, bug_id, 
																	   reporter_domain, 		 assigned_to_domain, 		qa_contact_domain,
																	   is_org_reporter_domain, is_org_assigned_to_domain, is_org_qa_contact_domain),
																	   by="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug associated with the attachments
attachments_working <- dplyr::rename(attachments_working, bug_reporter_domain				= reporter_domain,
														  bug_assigned_to_domain			= assigned_to_domain,
														  bug_qa_contact_domain				= qa_contact_domain,
														  is_org_bug_reporter_domain		= is_org_reporter_domain,
														  is_org_bug_assigned_to_domain		= is_org_assigned_to_domain,
														  is_org_bug_qa_contact_domain		= is_org_qa_contact_domain);


# VOTES

# Import the votes table from the previous functions to work on
votes_working <- votes_clean;

# Add the domain and is_org_domain status of who variable, the user who voted
setkey(profiles_working, userid);
setkey(votes_working, who);

votes_working <- merge(votes_working, select(profiles_working, userid, domain, is_org_domain), by.x="who", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who voted
votes_working <- dplyr::rename(votes_working, who_domain			= domain,
											  is_org_who_domain		= is_org_domain);
										
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each the bug_id related to each vote
setkey(bugs_working, bug_id);
setkey(votes_working, bug_id);

votes_working <- merge(votes_working, select(bugs_working, bug_id, 
														   reporter_domain, 		assigned_to_domain, 		qa_contact_domain,
														   is_org_reporter_domain,  is_org_assigned_to_domain, 	is_org_qa_contact_domain),
														   by="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug associated with the votes
votes_working <- dplyr::rename(votes_working, bug_reporter_domain				= reporter_domain,
											  bug_assigned_to_domain			= assigned_to_domain,
											  bug_qa_contact_domain				= qa_contact_domain,
											  is_org_bug_reporter_domain		= is_org_reporter_domain,
											  is_org_bug_assigned_to_domain		= is_org_assigned_to_domain,
											  is_org_bug_qa_contact_domain		= is_org_qa_contact_domain);														  
																

# LONGDESCS

# Import the longdescs table from the previous functions to work on
longdescs_working <- longdescs_clean;

# Add the domain and is_org_domain status of who variable, the user who commented
setkey(profiles_working, userid);
setkey(longdescs_working, who);

longdescs_working <- merge(longdescs_working, select(profiles_working, userid, domain, is_org_domain), by.x="who", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who commented
longdescs_working <- dplyr::rename(longdescs_working, who_domain			= domain,
													  is_org_who_domain		= is_org_domain);
										
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each the bug_id related to each comment
setkey(bugs_working, bug_id);
setkey(longdescs_working, bug_id);

longdescs_working <- merge(longdescs_working, select(bugs_working, bug_id, 
																   reporter_domain, 		assigned_to_domain, 		qa_contact_domain,
																   is_org_reporter_domain,  is_org_assigned_to_domain, 	is_org_qa_contact_domain),
																   by="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug associated with the comment
longdescs_working <- dplyr::rename(longdescs_working, bug_reporter_domain				= reporter_domain,
													  bug_assigned_to_domain			= assigned_to_domain,
													  bug_qa_contact_domain				= qa_contact_domain,
													  is_org_bug_reporter_domain		= is_org_reporter_domain,
													  is_org_bug_assigned_to_domain		= is_org_assigned_to_domain,
													  is_org_bug_qa_contact_domain		= is_org_qa_contact_domain);				


# WATCH

# Import the watch table from the previous functions to work on
watch_working <- watch_clean;

# Add the domain and is_org_domain status of "watcher" variable, the user who is doing the watching
setkey(profiles_working, userid);
setkey(watch_working, watcher);

watch_working <- merge(watch_working, select(profiles_working, userid, domain, is_org_domain), by.x="watcher", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who is doing the watching
watch_working <- dplyr::rename(watch_working, watcher_domain			= domain,
											  is_org_watcher_domain		= is_org_domain);
											  
# Repeat for "watched", the user who is watched by another user
setkey(profiles_working, userid);
setkey(watch_working, watched);

watch_working <- merge(watch_working, select(profiles_working, userid, domain, is_org_domain), by.x="watched", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who is watched by another user
watch_working <- dplyr::rename(watch_working, watched_domain			= domain,
											  is_org_watched_domain		= is_org_domain);

											  
# DUPLICATES

# Import the duplicates table from the previous functions to work on
duplicates_working <- duplicates_clean;

# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each bug that is a "dupe_of" another bug
setkey(bugs_working, bug_id);
setkey(duplicates_working, dupe_of);

duplicates_working <- merge(duplicates_working, select(bugs_working, bug_id, 
																	 reporter_domain, 		  assigned_to_domain, 		 qa_contact_domain,
																	 is_org_reporter_domain,  is_org_assigned_to_domain, is_org_qa_contact_domain),
																	 by.x="dupe_of", by.y="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug that is the "dupe_of" another bug
duplicates_working <- dplyr::rename(duplicates_working, dupe_of_bug_reporter_domain				= reporter_domain,
														dupe_of_bug_assigned_to_domain			= assigned_to_domain,
														dupe_of_bug_qa_contact_domain			= qa_contact_domain,
														is_org_dupe_of_bug_reporter_domain		= is_org_reporter_domain,
														is_org_dupe_of_bug_assigned_to_domain	= is_org_assigned_to_domain,
														is_org_dupe_of_bug_qa_contact_domain	= is_org_qa_contact_domain);

# Repeat with each "dupe" bug, which is the bug that has been duplicated by another bug
setkey(bugs_working, bug_id);
setkey(duplicates_working, dupe);

duplicates_working <- merge(duplicates_working, select(bugs_working, bug_id, 
																		 reporter_domain, 		  assigned_to_domain, 		 qa_contact_domain,
																		 is_org_reporter_domain,  is_org_assigned_to_domain, is_org_qa_contact_domain),
																		 by.x="dupe", by.y="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug that is duplicated by another bug
duplicates_working <- dplyr::rename(duplicates_working, dupe_bug_reporter_domain			= reporter_domain,
														dupe_bug_assigned_to_domain			= assigned_to_domain,
														dupe_bug_qa_contact_domain			= qa_contact_domain,
														is_org_dupe_bug_reporter_domain		= is_org_reporter_domain,
														is_org_dupe_bug_assigned_to_domain	= is_org_assigned_to_domain,
														is_org_dupe_bug_qa_contact_domain	= is_org_qa_contact_domain);
														

# GROUP MEMBERS

# Import the watch table from the previous functions to work on
group_members_working <- group_members_clean;

# Add the domain and is_org_domain status of "user_id" variable, the user who is assigned the group permissions
setkey(profiles_working, userid);
setkey(group_members_working, user_id);

group_members_working <- merge(group_members_working, select(profiles_working, userid, domain, is_org_domain), by.x="user_id", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who is assigned the grou ppermissions
group_members_working <- dplyr::rename(group_members_working, user_id_domain		= domain,
															  is_org_user_id_domain	= is_org_domain);
											  

# KEYWORDS

# Import the keywords table from the previous functions to work on
keywords_working <- keywords_clean;

# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each the bug_id related to each keyword
setkey(bugs_working, bug_id);
setkey(keywords_working, bug_id);

keywords_working <- merge(keywords_working, select(bugs_working, bug_id, 
																 reporter_domain, 		  assigned_to_domain, 		 qa_contact_domain,
																 is_org_reporter_domain,  is_org_assigned_to_domain, is_org_qa_contact_domain),
																 by="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug associated with the keyword
keywords_working <- dplyr::rename(keywords_working, bug_reporter_domain				= reporter_domain,
													bug_assigned_to_domain			= assigned_to_domain,
													bug_qa_contact_domain			= qa_contact_domain,
													is_org_bug_reporter_domain		= is_org_reporter_domain,
													is_org_bug_assigned_to_domain	= is_org_assigned_to_domain,
													is_org_bug_qa_contact_domain	= is_org_qa_contact_domain);														  
											  
											  
# FLAGS

# Import the flags table from the previous functions to work on
flags_working <- flags_clean;

# Add the domain and is_org_domain status of "setter_id" variable, the user who is setting the flags
setkey(profiles_working, userid);
setkey(flags_working, setter_id);

flags_working <- merge(flags_working, select(profiles_working, userid, domain, is_org_domain), by.x="setter_id", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who is setting the flags
flags_working <- dplyr::rename(flags_working, setter_id_domain			= domain,
											  is_org_setter_id_domain	= is_org_domain);
											  
# Repeat for "requestee_id", the user who requested the flag
setkey(profiles_working, userid);
setkey(flags_working, requestee_id);

flags_working <- merge(flags_working, select(profiles_working, userid, domain, is_org_domain), by.x="requestee_id", by.y="userid", all.x=TRUE);

# Rename them to make clear that they're for the user who is requested the flag
flags_working <- dplyr::rename(flags_working, requestee_id_domain			= domain,
											  is_org_requestee_id_domain	= is_org_domain);

# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each the bug_id related to each flag
setkey(bugs_working, bug_id);
setkey(flags_working, bug_id);

flags_working <- merge(flags_working, select(bugs_working, bug_id, 
														   reporter_domain, 		assigned_to_domain, 		qa_contact_domain,
														   is_org_reporter_domain,  is_org_assigned_to_domain, 	is_org_qa_contact_domain),
														   by="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug associated with the flag
flags_working <- dplyr::rename(flags_working, bug_reporter_domain				= reporter_domain,
											  bug_assigned_to_domain			= assigned_to_domain,
											  bug_qa_contact_domain				= qa_contact_domain,
											  is_org_bug_reporter_domain		= is_org_reporter_domain,
											  is_org_bug_assigned_to_domain		= is_org_assigned_to_domain,
											  is_org_bug_qa_contact_domain		= is_org_qa_contact_domain);				


# DEPENDENCIES

# Import the dependencies table from the previous functions to work on
dependencies_working <- dependencies_clean;

# Add the reporter/assigned_to/qa_contact domains & is_org_domains for each "blocked" bug
setkey(bugs_working, bug_id);
setkey(dependencies_working, blocked);

dependencies_working <- merge(dependencies_working, select(bugs_working, bug_id, 
																		 reporter_domain, 		  assigned_to_domain, 		 qa_contact_domain,
																		 is_org_reporter_domain,  is_org_assigned_to_domain, is_org_qa_contact_domain),
																		 by.x="blocked", by.y="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug that is blocked
dependencies_working <- dplyr::rename(dependencies_working, blocked_bug_reporter_domain				= reporter_domain,
															blocked_bug_assigned_to_domain			= assigned_to_domain,
															blocked_bug_qa_contact_domain			= qa_contact_domain,
															is_org_blocked_bug_reporter_domain		= is_org_reporter_domain,
															is_org_blocked_bug_assigned_to_domain	= is_org_assigned_to_domain,
															is_org_blocked_bug_qa_contact_domain	= is_org_qa_contact_domain);

# Repeat with each "dependson" bug, which is the bug doing the blocking
setkey(bugs_working, bug_id);
setkey(dependencies_working, dependson);

dependencies_working <- merge(dependencies_working, select(bugs_working, bug_id, 
																		 reporter_domain, 		  assigned_to_domain, 		 qa_contact_domain,
																		 is_org_reporter_domain,  is_org_assigned_to_domain, is_org_qa_contact_domain),
																		 by.x="dependson", by.y="bug_id", all.x=TRUE);
																 
# Rename them to make clear that they're for the bug bug that is doing the blocking
dependencies_working <- dplyr::rename(dependencies_working, dependson_bug_reporter_domain			= reporter_domain,
															dependson_bug_assigned_to_domain		= assigned_to_domain,
															dependson_bug_qa_contact_domain			= qa_contact_domain,
															is_org_dependson_bug_reporter_domain	= is_org_reporter_domain,
															is_org_dependson_bug_assigned_to_domain	= is_org_assigned_to_domain,
															is_org_dependson_bug_qa_contact_domain	= is_org_qa_contact_domain);

															
# CLEAN UP

# Create global variable to use in other functions

profiles_domains 		<<- profiles_working;
bugs_domains			<<- bugs_working;
activity_domains		<<- activity_working;
cc_domains				<<- cc_working;
attachments_domains 	<<- attachments_working;
votes_domains			<<- votes_working;
longdescs_domains		<<- longdescs_working;
watch_domains			<<- watch_working;
duplicates_domains		<<- duplicates_working;
group_members_domains	<<- group_members_working;
keywords_domains		<<- keywords_working;
flags_domains			<<- flags_working;
dependencies_domains	<<- dependencies_working;

} # End function add_domains



# This function does basic calculations, lookups, and so on to set additional values
# in the major tables

operationalize_base <- function () {

# PROFILES

# Import the profiles_domains table from the previous subroutine to work on
profiles_working <- profiles_domains;

# Create a new column that subtracts the profile creation timestamp from the DATABASE_END_TIMESTAMP parameter to get age of profile in days
# There is no way to get a timestamp of when disabled accounts were disabled, so we can't calculate their age when disabled, unfortunately

# Another unfortunate problem is that about 30% of the creation_ts values are the same value, suggesting that some sort of merge/restore happened
# on April 23, 2011 (2011-04-23 07:05:38), which incorrectly reset the creation timestamps to that date/time.  As such, those values are bad and have to be set to NA instead
profiles_working <- mutate(profiles_working, profile_age = safe_ifelse(creation_ts==BAD_PROFILE_CREATION_TIMESTAMP, NA, as.double(difftime(DATABASE_END_TIMESTAMP, creation_ts, units = "secs")) / 86400));


# BUGS

# Import the bugs_domains table from the previous subroutine to work on
bugs_working <- bugs_domains;

# Add a numerical version of "bug_severity" field since it's ordered factors
# Read in the bug_severity lookup table from file
severity_lookup <- read.table("severity_lookup.txt", sep=",", header=TRUE);
severity_lookup <- as.data.table(severity_lookup);

# Bug_severity column gets types set wrong, so reset it here
severity_lookup$bug_severity <- as.factor(as.character(severity_lookup$bug_severity));
severity_lookup$severity	 <- as.factor(severity_lookup$severity);

# Merge the new "severity" numerical column according to "bug_severity"
setkey(severity_lookup, bug_severity);
setkey(bugs_working, bug_severity);
bugs_working <- merge(bugs_working, severity_lookup, by='bug_severity', all.x=TRUE);


# Add a outcome variable that reduces all combinations "bug_status" and "resolution" to one of "fixed", "not_fixed", or "pending"
# Read in the outcome lookup table from file
outcome_lookup <- read.table("outcome_lookup.txt", sep=",", header=TRUE);
outcome_lookup <- as.data.table(outcome_lookup);

# Outcome lookup status gets type set wrong, so reset it here
outcome_lookup$bug_status 	<- as.factor(as.character(outcome_lookup$bug_status));
outcome_lookup$resolution	<- as.factor(as.character(outcome_lookup$resolution));
outcome_lookup$outcome		<- as.factor(as.character(outcome_lookup$outcome));

# Merge the new "outcome" column according to "bug_status" and "resolution" combinations
setkey(outcome_lookup, bug_status, resolution);
setkey(bugs_working, bug_status, resolution);
bugs_working <- merge(bugs_working, outcome_lookup, by=c('bug_status', 'resolution'), all.x=TRUE);


# Create a variable called "days_to_last_resolved", which counts from creation_ts to cf_last_resolved or DATABASE_END_TIMESTAMP if NA
bugs_working <- mutate(bugs_working, days_to_last_resolved = safe_ifelse(is.na(cf_last_resolved), as.double(difftime(DATABASE_END_TIMESTAMP, creation_ts, units = "secs")) / 86400,
																								  as.double(difftime(cf_last_resolved, 		creation_ts, units = "secs"))  / 86400));


# Count the number of chracters in the title ("short_desc") and make that its own column, "title_length"
# Since nchar() returns 2 when title is blank, our ifelse catches that case and sets it to 0
bugs_working <- mutate(bugs_working, title_length = safe_ifelse(short_desc=="", 0, nchar(short_desc)));
																								  
																								  
 
# LONGDESCS

# Import longdescs table from previous function to work on
longdescs_working <- longdescs_domains;

# Create a new column in the longdescs_working table that has the character length of each comment
# Since nchar() returns 2 when comment is blank, our ifelse catches that case and sets it to 0
longdescs_working <- mutate(longdescs_working, comment_length = safe_ifelse(thetext=="" | is.na(thetext), 0, nchar(thetext)));


# CLEAN UP
 
# Set global variables for other functions
profiles_base 		<<- profiles_working;
bugs_base 			<<- bugs_working;
longdescs_base		<<- longdescs_working;
activity_base		<<- activity_domains;
cc_base				<<- cc_domains;
attachments_base	<<- attachments_domains;
votes_base			<<- votes_domains;
watch_base			<<- watch_domains;
group_members_base	<<- group_members_domains;
flags_base			<<- flags_domains;
duplicates_base		<<- duplicates_domains;
keywords_base		<<-	keywords_domains;
dependencies_base	<<- dependencies_domains;

# These ones are carried forward from "clean" subroutine so that we can be consistent with _base suffix in next subroutine
group_list_base		<<- group_list_clean;
products_base		<<- products_clean;

} # End operationalize_base function


# OPERATIONALIZE INTERACTIONS BETWEEN TABLES

operationalize_interactions <- function () {

# The primary focus of this function is to make the profiles & bugs tables, the two primary tables
# longer by adding columns that are based on various index manipulations with other tables
# This way, all of the rows will constitute the "cases" for analysis, and all of the columns will be the dependent or independent variables as appropriate
# Doing this upfront makes the actual statistical portion of the research a lot clearer and easier to interpret


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


# PROFILES-BUGS_USER_REPORTED

# Count the bugs reported by each user in the bugs table
bug_user_reported_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$reporter)), -Freq), reporter = Var1));

# Merge the "user_bugs_reported_count" with the profiles table based on "reporter" and "userid"
setkey(bug_user_reported_count, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_reported_count, by.x="userid", by.y="reporter", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_bugs_reported_count = Freq);

# For any NA entries in the "user_bugs_reported_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_reported_count = safe_ifelse(is.na(user_bugs_reported_count), 0, user_bugs_reported_count));


# PROFILES-BUGS_USER_ASSIGNED

# Count the bugs assigned to each user in the bugs table
bug_user_assigned_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$assigned_to)), -Freq), assigned = Var1));

# Merge the "user_bugs_assigned_count" with the profiles table based on "assigned_to" and "userid"
setkey(bug_user_assigned_count, assigned);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_assigned_count, by.x="userid", by.y="assigned", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, user_bugs_assigned_count = Freq);

# For any NA entries in the "user_bugs_assigned_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, user_bugs_assigned_count = safe_ifelse(is.na(user_bugs_assigned_count), 0, user_bugs_assigned_count));


# PROFILES-BUGS_USER_QA

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
activity_working_grouped <- group_by(activity_base, bug_id);

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
# The possible resolutions are in "added" and are "CLOSED", "RESOLVED" or "VERIFIED"
# These SHOULD only appear in fieldid 29 which is "bug_status", but sometimes they end up elsewhere, so check for fieldid
activity_resolved <- filter(activity_base, (added=="CLOSED" 		& fieldid==29) | 
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
# It SHOULD only appear in fieldid 29 which is "bug_status", but sometimes it ends up elsewhere, so check for fieldid
# "Reopening" can happen from quite a few transitions, not all of which use the actual "REOPENED" status
# Many of these are not legal according to the workflow table, but may exist for historical resons before the current workflow flags
# The possible transitions are listed below as alternatives in the filters
activity_reopened <- filter(activity_base, (				  added=="REOPENED" 	& fieldid==29) |	# All transitions 			to reopened
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

activity_assigned <- filter(activity_base, (removed=="NEW"			& added=="ASSIGNED"		& fieldid==29) |
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
# Reassignment is measured by transitions in fieldid==29
# "Reassigning" can happen from several transitions
# Further, it's possible that reassignment happens as part of reopening, so this status change isn't only measure
# Same reasoning for using transitions instead of changes in "assigned_to" as above
# The possible transitions are listed below as alternatives in the filters as follows:
activity_reassigned <- filter(activity_base, (removed=="REOPENED"	& added=="NEW"			& fieldid==29) |
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

# We want to count the number of characters in the initial comment when the bug was filed. This is effectively the
# "bug description" even though it's handled the same way as other comments.

# Rearrange the longdescs in the table by date, leaving most distant dates first, and most recent dates last
longdescs_working_arranged <- arrange(longdescs_base, bug_when);

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

longdescs_working_grouped <- group_by(longdescs_base, bug_id);

# Now we'll use Dplyr's summarize() command to extract the count/sums/means of the comments column for each bug_id
# We subtract 1 from n() because the first comment is the "description" of which there will always be one.
longdescs_working_summary <- summarize(longdescs_working_grouped, comments_all_actors_count	= n() - 1,
																  comments_combined_length 	= sum(comment_length),
																  comments_mean_length		= safe_ifelse(sum(comment_length)==0, 0, mean(comment_length, na.rm=TRUE)));

# Merge the longdescs_working_summary and bugs_working tables based on bug_id to add the new columns
setkey(longdescs_working_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_working_summary, by="bug_id", all.x=TRUE);

# The comments_combined_length variable includes the description_length, so subtract it
# The comments_mean_length included the description_length in its calculation, so recalculate the mean without it
# NA values appear for the rare cases few cases where bugs have no comments at all, so set to 0.
# This case is distinct from other mean cases in that the mean length of a nonexisting comment is correctly 0
# Mean of an NA makes less sense in terms of time to resolution later on in this function, where NA is correctly set instead 
bugs_working <- mutate(bugs_working, comments_combined_length 	= comments_combined_length - description_length,
									 comments_mean_length		= safe_ifelse(is.na(comments_mean_length) | comments_mean_length==0 | comments_all_actors_count==0, 0, ((comments_mean_length * (comments_all_actors_count + 1)) - description_length) / comments_all_actors_count));


# BUGS-CC_ALL_ACTORS

# First, we'll use Dplyr's group_by() command to set a flag in the data.frame that bug_ids should be grouped
cc_working_bug_id_grouped <- group_by(cc_base, bug_id);

# Apply Dplyr's summarize() command to extract the count of CCs for each bug_id
cc_working_bug_id_summary <- summarize(cc_working_bug_id_grouped, cc_all_actors_count = n());

# Merge the cc_working_bug_id summary and bugs_working tables based on bug_id to add CC count
setkey(cc_working_bug_id_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, cc_working_bug_id_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "cc_all_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, cc_all_actors_count = safe_ifelse(is.na(cc_all_actors_count), 0, cc_all_actors_count));


# PROFILES-BUGS_USER_REPORTED_REOPENED_OR_ASSIGNED_OR_REASSIGNED
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


# PROFILES-BUGS_USER_ASSIGNED_TO_REOPENED_OR_ASSIGNED_OR_REASSIGNED
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


# PROFILES-BUGS_USER_QA_CONTACT_REOPENED_OR_ASSIGNED_OR_REASSIGNED
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

activity_types_working <- select(filter(activity_base, fieldid %in% c(37, 21, 25, 33, 29, 30, 69, 22, 40, 24, 32, 31)), bug_id, fieldid);

# Use data.table's dcast() function to recast the table such that each row is a single bug_id and there is
# a column for each field_id
activity_types_recast <- dcast(activity_types_working, bug_id ~ fieldid, drop=FALSE, value.var="fieldid", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_types_recast) <- gsub("^(\\d)", "arg\\1", names(activity_types_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns
activity_types_recast <- transmute(activity_types_recast, 	bug_id 							= bug_id,
															cc_change_count 				= if (exists('arg37',		where = activity_types_recast)) arg37 else 0,
															keywords_change_count			= if (exists('arg21',		where = activity_types_recast)) arg21 else 0,
															product_change_count			= if (exists('arg25',		where = activity_types_recast)) arg25 else 0,
															component_change_count			= if (exists('arg33',		where = activity_types_recast)) arg33 else 0,
															status_change_count				= if (exists('arg29',		where = activity_types_recast)) arg29 else 0,
															resolution_change_count			= if (exists('arg30',		where = activity_types_recast)) arg30 else 0,
															flags_change_count				= if (exists('arg69',		where = activity_types_recast)) arg69 else 0,
															whiteboard_change_count			= if (exists('arg22',		where = activity_types_recast)) arg22 else 0,
															target_milestone_change_count	= if (exists('arg40',		where = activity_types_recast)) arg40 else 0,
															description_change_count		= if (exists('arg24',		where = activity_types_recast)) arg24 else 0,
															priority_change_count			= if (exists('arg32',		where = activity_types_recast)) arg32 else 0,
															severity_change_count		 	= if (exists('arg31',		where = activity_types_recast)) arg31 else 0);

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
bugs_creation_ts <- transmute(bugs_base, bug_id = bug_id, bug_creation_ts = as.POSIXct(creation_ts, tz="UTC", origin="1970-01-01"));

# Merge the bugs_creation_ts table with the activity_base (as activity_working) table to set our bug_creation_ts column for calculations
activity_working <- activity_base;
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

# Group the keywords_base table by bug_id to prepare it for summarize()
keywords_working_grouped <- group_by(keywords_base, bug_id);

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

# Group the flags_base table by bug_id to prepare it for summarize()
flags_working_grouped <- group_by(flags_base, bug_id);

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
duplicates_working_grouped <- group_by(duplicates_base, dupe_of);

# Summarize to count the number of times each bug was duplicated by another bug
duplicates_working_grouped_summary <- summarize(duplicates_working_grouped, duplicates_count = n());

# Merge the duplicates_working_grouped_summary and bugs_working tables based on "bug_id" and "dupe_of" to add duplicates count
setkey(duplicates_working_grouped_summary, dupe_of);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, duplicates_working_grouped_summary, by.x="bug_id", by.y="dupe_of", all.x=TRUE);

# For any NA entries, that means the bug was never duplicated, so mutate it to 0
# Also add a logical column that is TRUE if the bug is a duplicate of another bug and FALSE otherwise
bugs_working <- mutate(bugs_working, duplicates_count 	= safe_ifelse(is.na(duplicates_count), 			 0, 	duplicates_count),
									 is_duplicate		= safe_ifelse(bug_id %in% duplicates_base$dupe, TRUE, 	FALSE));


# BUGS-ATTACHMENTS_ALL_TYPES
# (Count how many attachments were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_all_grouped_bugid <- group_by(attachments_base, bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_all_grouped_bugid_summary <- summarize(attachments_base_all_grouped_bugid, attachments_all_types_count = n());

# Merge the "attachments_base_all_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_all_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_all_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_all_types_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_all_types_count = safe_ifelse(is.na(attachments_all_types_count), 0, attachments_all_types_count));


# BUGS-ATTACHMENTS_PATCH
# (Count how many attachments that were patches were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_patch_grouped_bugid <- group_by(filter(attachments_base, ispatch==TRUE), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_patch_grouped_bugid_summary <- summarize(attachments_base_patch_grouped_bugid, attachments_patch_count = n());

# Merge the "attachments_base_patch_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_patch_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_patch_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_patch_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_patch_count = safe_ifelse(is.na(attachments_patch_count), 0, attachments_patch_count));


# BUGS-ATTACHMENTS_APPLICATION
# (Count how many attachments that were applications were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_application_grouped_bugid <- group_by(filter(attachments_base, mimetype %in% application_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_application_grouped_bugid_summary <- summarize(attachments_base_application_grouped_bugid, attachments_application_count = n());

# Merge the "attachments_base_application_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_application_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_application_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_application_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_application_count = safe_ifelse(is.na(attachments_application_count), 0, attachments_application_count));


# BUGS-ATTACHMENTS_AUDIO
# (Count how many attachments that were audio were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_audio_grouped_bugid <- group_by(filter(attachments_base, mimetype %in% audio_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_audio_grouped_bugid_summary <- summarize(attachments_base_audio_grouped_bugid, attachments_audio_count = n());

# Merge the "attachments_base_audio_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_audio_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_audio_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_audio_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_audio_count = safe_ifelse(is.na(attachments_audio_count), 0, attachments_audio_count));


# BUGS-ATTACHMENTS_IMAGE
# (Count how many attachments that were images were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_image_grouped_bugid <- group_by(filter(attachments_base, mimetype %in% image_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_image_grouped_bugid_summary <- summarize(attachments_base_image_grouped_bugid, attachments_image_count = n());

# Merge the "attachments_base_image_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_image_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_image_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_image_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_image_count = safe_ifelse(is.na(attachments_image_count), 0, attachments_image_count));


# BUGS-ATTACHMENTS_MESSAGE
# (Count how many attachments that were messages were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_message_grouped_bugid <- group_by(filter(attachments_base, mimetype %in% message_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_message_grouped_bugid_summary <- summarize(attachments_base_message_grouped_bugid, attachments_message_count = n());

# Merge the "attachments_base_message_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_message_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_message_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_message_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_message_count = safe_ifelse(is.na(attachments_message_count), 0, attachments_message_count));


# BUGS-ATTACHMENTS_MODEL
# (Count how many attachments that were models were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_model_grouped_bugid <- group_by(filter(attachments_base, mimetype %in% model_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_model_grouped_bugid_summary <- summarize(attachments_base_model_grouped_bugid, attachments_model_count = n());

# Merge the "attachments_base_model_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_model_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_model_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_model_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_model_count = safe_ifelse(is.na(attachments_model_count), 0, attachments_model_count));


# BUGS-ATTACHMENTS_MULTIPART
# (Count how many attachments that were multipart were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_multipart_grouped_bugid <- group_by(filter(attachments_base, mimetype %in% multipart_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_multipart_grouped_bugid_summary <- summarize(attachments_base_multipart_grouped_bugid, attachments_multipart_count = n());

# Merge the "attachments_base_multipart_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_multipart_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_multipart_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_multipart_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_multipart_count = safe_ifelse(is.na(attachments_multipart_count), 0, attachments_multipart_count));


# BUGS-ATTACHMENTS_TEXT
# (Count how many attachments that were text were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_text_grouped_bugid <- group_by(filter(attachments_base, mimetype %in% text_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_text_grouped_bugid_summary <- summarize(attachments_base_text_grouped_bugid, attachments_text_count = n());

# Merge the "attachments_base_text_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_text_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_text_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_text_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_text_count = safe_ifelse(is.na(attachments_text_count), 0, attachments_text_count));


# BUGS-ATTACHMENTS_VIDEO
# (Count how many attachments that were video were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_video_grouped_bugid <- group_by(filter(attachments_base, mimetype %in% video_mimetypes$Template), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_video_grouped_bugid_summary <- summarize(attachments_base_video_grouped_bugid, attachments_video_count = n());

# Merge the "attachments_base_video_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_video_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_video_grouped_bugid_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "attachments_video_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, attachments_video_count = safe_ifelse(is.na(attachments_video_count), 0, attachments_video_count));


# BUGS-ATTACHMENTS_UNKNOWN
# (Count how many attachments that were an unknown type were submitted to each bug)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "bug_id" to which each attachment is submitted
attachments_base_unknown_grouped_bugid <- group_by(filter(attachments_base, !(mimetype %in% c(application_mimetypes$Template,
																								  audio_mimetypes$Template,
																								  image_mimetypes$Template,
																								  message_mimetypes$Template,
																								  model_mimetypes$Template,
																								  multipart_mimetypes$Template,
																								  text_mimetypes$Template,
																								  video_mimetypes$Template))), bug_id);

# Use DPLYR's summarize() function to count attachment submissions for each bug
attachments_base_unknown_grouped_bugid_summary <- summarize(attachments_base_unknown_grouped_bugid, attachments_unknown_count = n());

# Merge the "attachments_base_unknown_grouped_bugid_summary" table with the bugs table according to "bug_id"
setkey(attachments_base_unknown_grouped_bugid_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, attachments_base_unknown_grouped_bugid_summary, by="bug_id", all.x=TRUE);

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

# Filter longdescs_base to just knowledge actors
longdescs_knowledge_actors <- filter(longdescs_base, who %in% user_knowledge_actors);

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

# Filter longdescs_base to just core actors
longdescs_core_actors <- filter(longdescs_base, who %in% user_core_actors);

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

# Filter longdescs_base to just peripheral actors
longdescs_peripheral_actors <- filter(longdescs_base, who %in% user_peripheral_actors);

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


# Filter longdescs_base to just comments that are automatic, meaning types 2 & 3, which are marking another as dupe or transition to NEW
# Type 0 means regular, type 1 means flagging a bug as duplicate, but isn't automatic because it is a manual choice that requires explanation of reason it's a duplicate
# Type 4 doesn't exist anymore ( was moving bug), types 5 & 6 are for attachments, but require manually entered explanations of attachments
# Types 2 & 3 are "has dupe" and "move to new by popular vote", the latter of which doesn't exist anymore but has historical entries
# Types 2 & 3 are clearly automatic because they never have any comment text (blank).
longdescs_automatic <- filter(longdescs_base, type==2 | type==3);

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
longdescs_attachments <- filter(longdescs_base, type==5 | type==6);

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


# PROFILES-WATCHING_USER_ALL_ORGS
# (Track how many other organizations each user is watching)

# Since we only care about organizations, we want to filter out webmail domains for this count
watch_base_is_org_watched_domain <- filter(watch_base, is_org_watched_domain==TRUE);

# Select only entries with distinct pairs of "watcher" users and "watched_domains"
watch_base_distinct_watcher_watched_domains <- distinct(select(watch_base_is_org_watched_domain, watcher, watched_domain));

# Use DPLYR's group_by() function to organize the watch_base_distinct_watcher_watched_domains table according to the "watcher"
watch_base_grouped_watcher_watched_domain <- group_by(watch_base_distinct_watcher_watched_domains, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_domain_summary <- summarize(watch_base_grouped_watcher_watched_domain, user_watching_all_orgs_count = n());

# Merge the "watch_base_grouped_watcher_watched_domain_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_domain_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_domain_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "user_watching_all_orgs_count" column, that means the user isn't watching any organizations, so set it to zero
profiles_working <- mutate(profiles_working, user_watching_all_orgs_count = safe_ifelse(is.na(user_watching_all_orgs_count), 0, user_watching_all_orgs_count));


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


# PROFILES-WATCHED_BY_USER_ALL_ACTORS
# (Track how many other users each user is watched by)

# Use DPLYR's group_by() function to organize the watch_base table according to the person "watched"
watch_base_grouped_watched <- group_by(watch_base, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_summary <- summarize(watch_base_grouped_watched, user_watched_by_all_actors_count = n());

# Merge the "watch_base_grouped_watched_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "user_watched_by_all_actors_count" column, that means the user not watched by anyone, so set it to zero
profiles_working <- mutate(profiles_working, user_watched_by_all_actors_count = safe_ifelse(is.na(user_watched_by_all_actors_count), 0, user_watched_by_all_actors_count));


# PROFILES-WATCHED_BY_USER_ALL_ORGS
# (Track how many other organizations each user is watched by)

# Since we only care about organizations, we want to filter out webmail domains for this count
watch_base_is_org_watcher_domain <- filter(watch_base, is_org_watcher_domain==TRUE);

# Select only entries with distinct pairs of "watched" users and "watcher_domains"
watch_base_distinct_watched_watcher_domains <- distinct(select(watch_base_is_org_watcher_domain, watched, watcher_domain));

# Use DPLYR's group_by() function to organize the watch_base_distinct_watched_watcher_domains table according to the person "watched"
watch_base_grouped_watched_watcher_domain <- group_by(watch_base_distinct_watched_watcher_domains, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_watcher_domain_summary <- summarize(watch_base_grouped_watched_watcher_domain, user_watched_by_all_orgs_count = n());

# Merge the "watch_base_grouped_watched_watcher_domain_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_watcher_domain_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_watcher_domain_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "user_watched_by_all_orgs_count" column, that means the user isn't watched by any domains, so set it to zero
profiles_working <- mutate(profiles_working, user_watched_by_all_orgs_count = safe_ifelse(is.na(user_watched_by_all_orgs_count), 0, user_watched_by_all_orgs_count));


# PROFILES-WATCHED_BY_USER_KNOWLEDGE_ACTORS
# (Track how many knowledge actor users each user is watched by)

# Filter watch_base to "watcher" knowledge actors
watch_base_watcher_knowledge_actors <- filter(watch_base, watcher %in% user_knowledge_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the person "watched"
watch_base_grouped_watched_watcher_knowledge_actors <- group_by(watch_base_watcher_knowledge_actors, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_watcher_knowledge_actors_summary <- summarize(watch_base_grouped_watched_watcher_knowledge_actors, user_watched_by_knowledge_actors_count = n());

# Merge the "watch_base_grouped_watched_watcher_knowledge_actors_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_watcher_knowledge_actors_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_watcher_knowledge_actors_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "user_watched_by_knowledge_actors_count" column, that means the user is not watched by any knowledge actors, so set it to zero
profiles_working <- mutate(profiles_working, user_watched_by_knowledge_actors_count = safe_ifelse(is.na(user_watched_by_knowledge_actors_count), 0, user_watched_by_knowledge_actors_count));


# PROFILES-WATCHED_BY_USER_CORE_ACTORS
# (Track how many core actor users each user is watched by)

# Filter watch_base to "watcher" core actors
watch_base_watcher_core_actors <- filter(watch_base, watcher %in% user_core_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the person "watched"
watch_base_grouped_watched_watcher_core_actors <- group_by(watch_base_watcher_core_actors, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_watcher_core_actors_summary <- summarize(watch_base_grouped_watched_watcher_core_actors, user_watched_by_core_actors_count = n());

# Merge the "watch_base_grouped_watched_watcher_core_actors_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_watcher_core_actors_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_watcher_core_actors_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "user_watched_by_core_actors_count" column, that means the user is not watched by any core actors, so set it to zero
profiles_working <- mutate(profiles_working, user_watched_by_core_actors_count = safe_ifelse(is.na(user_watched_by_core_actors_count), 0, user_watched_by_core_actors_count));


# PROFILES-WATCHED_BY_USER_PERIPHERAL_ACTORS
# (Track how many peripheral actor users each user is watched by)

# Filter watch_base to "watcher" peripheral actors
watch_base_watcher_peripheral_actors <- filter(watch_base, watcher %in% user_peripheral_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the person "watched"
watch_base_grouped_watched_watcher_peripheral_actors <- group_by(watch_base_watcher_peripheral_actors, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_watcher_peripheral_actors_summary <- summarize(watch_base_grouped_watched_watcher_peripheral_actors, user_watched_by_peripheral_actors_count = n());

# Merge the "watch_base_grouped_watched_watcher_peripheral_actors_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_watcher_peripheral_actors_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_watcher_peripheral_actors_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "user_watched_by_peripheral_actors_count" column, that means the user is not watched by any peripheral actors, so set it to zero
profiles_working <- mutate(profiles_working, user_watched_by_peripheral_actors_count = safe_ifelse(is.na(user_watched_by_peripheral_actors_count), 0, user_watched_by_peripheral_actors_count));


# PROFILES-BUGS_USER_REPORTED_SEVERITY
# (Count the bugs reported by each user for each severity level)

# Select just the fields in the bugs_working table that we want to look at, namely reporter and bug_severity
bugs_working_reporter_severity <- select(bugs_working, reporter, bug_severity);

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user reported a bug with each of the 7 severity types
bugs_working_reporter_severity_recast <- dcast(bugs_working_reporter_severity, reporter ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length);

# Transmute all of the columns to the set the desired names and check for NA's
bugs_working_reporter_severity_recast <- transmute(bugs_working_reporter_severity_recast,   reporter								= reporter,
																							user_bugs_reported_enhancement_count 	= if (exists('enhancement',	where = bugs_working_reporter_severity_recast)) enhancement else 0,
																							user_bugs_reported_trivial_count 		= if (exists('trivial',		where = bugs_working_reporter_severity_recast)) trivial else 0,
																							user_bugs_reported_minor_count			= if (exists('minor',		where = bugs_working_reporter_severity_recast)) minor else 0,
																							user_bugs_reported_normal_count 		= if (exists('normal',		where = bugs_working_reporter_severity_recast)) normal else 0,
																							user_bugs_reported_major_count 			= if (exists('major',		where = bugs_working_reporter_severity_recast)) major else 0,
																							user_bugs_reported_critical_count 		= if (exists('critical',	where = bugs_working_reporter_severity_recast)) critical else 0,
																							user_bugs_reported_blocker_count 		= if (exists('blocker',		where = bugs_working_reporter_severity_recast)) blocker else 0);
																						
# Merge the bugs_working_reporter_severity_recast and profiles_working tables based on reporter & userid to add the severity types count columns
setkey(bugs_working_reporter_severity_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_severity_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, user_bugs_reported_enhancement_count 	= safe_ifelse(is.na(user_bugs_reported_enhancement_count), 	0, user_bugs_reported_enhancement_count), 
                                             user_bugs_reported_trivial_count 		= safe_ifelse(is.na(user_bugs_reported_trivial_count), 		0, user_bugs_reported_trivial_count),
                                             user_bugs_reported_minor_count			= safe_ifelse(is.na(user_bugs_reported_minor_count), 		0, user_bugs_reported_minor_count),
                                             user_bugs_reported_normal_count 		= safe_ifelse(is.na(user_bugs_reported_normal_count), 		0, user_bugs_reported_normal_count),
                                             user_bugs_reported_major_count 		= safe_ifelse(is.na(user_bugs_reported_major_count), 		0, user_bugs_reported_major_count),
                                             user_bugs_reported_critical_count 		= safe_ifelse(is.na(user_bugs_reported_critical_count), 	0, user_bugs_reported_critical_count),
                                             user_bugs_reported_blocker_count 		= safe_ifelse(is.na(user_bugs_reported_blocker_count), 		0, user_bugs_reported_blocker_count));

# PROFILES-BUGS_USER_ASSIGNED_TO_SEVERITY
# (Count the bugs assigned_to each user for each severity level)

# Select just the fields in the bugs_working table that we want to look at, namely assigned_to and bug_severity
bugs_working_assigned_to_severity <- select(bugs_working, assigned_to, bug_severity);

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user was assigned_to a bug with each of the 7 severity types
bugs_working_assigned_to_severity_recast <- dcast(bugs_working_assigned_to_severity, assigned_to ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length);

# Transmute all of the columns to the desired values
bugs_working_assigned_to_severity_recast <- transmute(bugs_working_assigned_to_severity_recast, assigned_to 							= assigned_to,
																								user_bugs_assigned_to_enhancement_count = if (exists('enhancement',	where = bugs_working_assigned_to_severity_recast)) enhancement else 0,
																								user_bugs_assigned_to_trivial_count 	= if (exists('trivial',		where = bugs_working_assigned_to_severity_recast)) trivial else 0,
																								user_bugs_assigned_to_minor_count		= if (exists('minor',		where = bugs_working_assigned_to_severity_recast)) minor else 0,
																								user_bugs_assigned_to_normal_count 		= if (exists('normal',		where = bugs_working_assigned_to_severity_recast)) normal else 0,
																								user_bugs_assigned_to_major_count 		= if (exists('major',		where = bugs_working_assigned_to_severity_recast)) major else 0,
																								user_bugs_assigned_to_critical_count 	= if (exists('critical',	where = bugs_working_assigned_to_severity_recast)) critical else 0,
																								user_bugs_assigned_to_blocker_count 	= if (exists('blocker',		where = bugs_working_assigned_to_severity_recast)) blocker else 0);
																						
# Merge the bugs_working_assigned_to_severity_recast and profiles_working tables based on assigned_to & userid to add the severity types count columns
setkey(bugs_working_assigned_to_severity_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_severity_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user was not assigned any bugs, so change to 0
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_enhancement_count 	= safe_ifelse(is.na(user_bugs_assigned_to_enhancement_count), 	0, user_bugs_assigned_to_enhancement_count), 
                                             user_bugs_assigned_to_trivial_count 		= safe_ifelse(is.na(user_bugs_assigned_to_trivial_count), 		0, user_bugs_assigned_to_trivial_count),
                                             user_bugs_assigned_to_minor_count			= safe_ifelse(is.na(user_bugs_assigned_to_minor_count), 		0, user_bugs_assigned_to_minor_count),
                                             user_bugs_assigned_to_normal_count 		= safe_ifelse(is.na(user_bugs_assigned_to_normal_count), 		0, user_bugs_assigned_to_normal_count),
                                             user_bugs_assigned_to_major_count 			= safe_ifelse(is.na(user_bugs_assigned_to_major_count), 		0, user_bugs_assigned_to_major_count),
                                             user_bugs_assigned_to_critical_count 		= safe_ifelse(is.na(user_bugs_assigned_to_critical_count), 		0, user_bugs_assigned_to_critical_count),
                                             user_bugs_assigned_to_blocker_count 		= safe_ifelse(is.na(user_bugs_assigned_to_blocker_count), 		0, user_bugs_assigned_to_blocker_count));


# PROFILES-BUGS_USER_QA_CONTACT_SEVERITY
# (Count the bugs for which each user is qa_contact for each severity level)

# Select just the fields in the bugs_working table that we want to look at, namely qa_contact and bug_severity
bugs_working_qa_contact_severity <- select(bugs_working, qa_contact, bug_severity);

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user was qa_contact for a bug with each of the 7 severity types
bugs_working_qa_contact_severity_recast <- dcast(bugs_working_qa_contact_severity, qa_contact ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length);

# Transmute all of the columns to the desired values
bugs_working_qa_contact_severity_recast <- transmute(bugs_working_qa_contact_severity_recast,  	qa_contact 								= qa_contact,
																								user_bugs_qa_contact_enhancement_count 	= if (exists('enhancement',	where = bugs_working_qa_contact_severity_recast)) enhancement else 0,
																								user_bugs_qa_contact_trivial_count 		= if (exists('trivial',		where = bugs_working_qa_contact_severity_recast)) trivial else 0,
																								user_bugs_qa_contact_minor_count		= if (exists('minor',		where = bugs_working_qa_contact_severity_recast)) minor else 0,
																								user_bugs_qa_contact_normal_count 		= if (exists('normal',		where = bugs_working_qa_contact_severity_recast)) normal else 0,
																								user_bugs_qa_contact_major_count 		= if (exists('major',		where = bugs_working_qa_contact_severity_recast)) major else 0,
																								user_bugs_qa_contact_critical_count 	= if (exists('critical',	where = bugs_working_qa_contact_severity_recast)) critical else 0,
																								user_bugs_qa_contact_blocker_count 		= if (exists('blocker',		where = bugs_working_qa_contact_severity_recast)) blocker else 0);
																						
# Merge the bugs_working_qa_contact_severity_recast and profiles_working tables based on qa_contact & userid to add the severity types count columns
setkey(bugs_working_qa_contact_severity_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_severity_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user was not set as qa_contact for any bugs, so change to 0
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_enhancement_count 	= safe_ifelse(is.na(user_bugs_qa_contact_enhancement_count), 	0, user_bugs_qa_contact_enhancement_count), 
                                             user_bugs_qa_contact_trivial_count 		= safe_ifelse(is.na(user_bugs_qa_contact_trivial_count), 		0, user_bugs_qa_contact_trivial_count),
                                             user_bugs_qa_contact_minor_count			= safe_ifelse(is.na(user_bugs_qa_contact_minor_count), 			0, user_bugs_qa_contact_minor_count),
                                             user_bugs_qa_contact_normal_count 			= safe_ifelse(is.na(user_bugs_qa_contact_normal_count), 		0, user_bugs_qa_contact_normal_count),
                                             user_bugs_qa_contact_major_count 			= safe_ifelse(is.na(user_bugs_qa_contact_major_count), 			0, user_bugs_qa_contact_major_count),
                                             user_bugs_qa_contact_critical_count 		= safe_ifelse(is.na(user_bugs_qa_contact_critical_count), 		0, user_bugs_qa_contact_critical_count),
                                             user_bugs_qa_contact_blocker_count 		= safe_ifelse(is.na(user_bugs_qa_contact_blocker_count), 		0, user_bugs_qa_contact_blocker_count));


# PROFILES-BUGS_USER_REPORTED_YEAR
# (Count the bugs reported by each user for each year)

# Select just the fields in the bugs_working table that we want to look at, namely reporter and creation_ts
bugs_working_reporter_creation_ts <- select(bugs_working, reporter, creation_ts);

# Transmute to get just the year of the creation_ts column
bugs_working_reporter_year <- transmute(bugs_working_reporter_creation_ts, reporter = reporter, creation_ts_year = format(creation_ts, format='%Y'));

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user reported a bug during each of the years in the database
bugs_working_reporter_year_recast <- dcast(bugs_working_reporter_year, reporter ~ creation_ts_year, drop=FALSE, value.var="creation_ts_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(bugs_working_reporter_year_recast) <- gsub("^(\\d)", "arg\\1", names(bugs_working_reporter_year_recast), perl=TRUE);

# Transmute all of the columns to the desired values
bugs_working_reporter_year_recast <- transmute(bugs_working_reporter_year_recast,	reporter					  = reporter,
																					user_bugs_reported_1994_count = if (exists('arg1994', where = bugs_working_reporter_year_recast)) arg1994 else 0,
																					user_bugs_reported_1995_count = if (exists('arg1995', where = bugs_working_reporter_year_recast)) arg1995 else 0,
																					user_bugs_reported_1996_count = if (exists('arg1996', where = bugs_working_reporter_year_recast)) arg1996 else 0,
																					user_bugs_reported_1997_count = if (exists('arg1997', where = bugs_working_reporter_year_recast)) arg1997 else 0,
																					user_bugs_reported_1998_count = if (exists('arg1998', where = bugs_working_reporter_year_recast)) arg1998 else 0,
																					user_bugs_reported_1999_count = if (exists('arg1999', where = bugs_working_reporter_year_recast)) arg1999 else 0,
																					user_bugs_reported_2000_count = if (exists('arg2000', where = bugs_working_reporter_year_recast)) arg2000 else 0,
																					user_bugs_reported_2001_count = if (exists('arg2001', where = bugs_working_reporter_year_recast)) arg2001 else 0,
																					user_bugs_reported_2002_count = if (exists('arg2002', where = bugs_working_reporter_year_recast)) arg2002 else 0,
																					user_bugs_reported_2003_count = if (exists('arg2003', where = bugs_working_reporter_year_recast)) arg2003 else 0,
																					user_bugs_reported_2004_count = if (exists('arg2004', where = bugs_working_reporter_year_recast)) arg2004 else 0,
																					user_bugs_reported_2005_count = if (exists('arg2005', where = bugs_working_reporter_year_recast)) arg2005 else 0,
																					user_bugs_reported_2006_count = if (exists('arg2006', where = bugs_working_reporter_year_recast)) arg2006 else 0,
																					user_bugs_reported_2007_count = if (exists('arg2007', where = bugs_working_reporter_year_recast)) arg2007 else 0,
																					user_bugs_reported_2008_count = if (exists('arg2008', where = bugs_working_reporter_year_recast)) arg2008 else 0,
																					user_bugs_reported_2009_count = if (exists('arg2009', where = bugs_working_reporter_year_recast)) arg2009 else 0,
																					user_bugs_reported_2010_count = if (exists('arg2010', where = bugs_working_reporter_year_recast)) arg2010 else 0,
																					user_bugs_reported_2011_count = if (exists('arg2011', where = bugs_working_reporter_year_recast)) arg2011 else 0,
																					user_bugs_reported_2012_count = if (exists('arg2012', where = bugs_working_reporter_year_recast)) arg2012 else 0,
																					user_bugs_reported_2013_count = if (exists('arg2013', where = bugs_working_reporter_year_recast)) arg2013 else 0);
																						
# Merge the bugs_working_reporter_year_recast and profiles_working tables based on reporter & userid to add the years count columns
setkey(bugs_working_reporter_year_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_year_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, user_bugs_reported_1994_count = safe_ifelse(is.na(user_bugs_reported_1994_count), 0, user_bugs_reported_1994_count), 
                                             user_bugs_reported_1995_count = safe_ifelse(is.na(user_bugs_reported_1995_count), 0, user_bugs_reported_1995_count),
                                             user_bugs_reported_1996_count = safe_ifelse(is.na(user_bugs_reported_1996_count), 0, user_bugs_reported_1996_count),
                                             user_bugs_reported_1997_count = safe_ifelse(is.na(user_bugs_reported_1997_count), 0, user_bugs_reported_1997_count),
                                             user_bugs_reported_1998_count = safe_ifelse(is.na(user_bugs_reported_1998_count), 0, user_bugs_reported_1998_count),
                                             user_bugs_reported_1999_count = safe_ifelse(is.na(user_bugs_reported_1999_count), 0, user_bugs_reported_1999_count),
                                             user_bugs_reported_2000_count = safe_ifelse(is.na(user_bugs_reported_2000_count), 0, user_bugs_reported_2000_count),
											 user_bugs_reported_2001_count = safe_ifelse(is.na(user_bugs_reported_2001_count), 0, user_bugs_reported_2001_count),
											 user_bugs_reported_2002_count = safe_ifelse(is.na(user_bugs_reported_2002_count), 0, user_bugs_reported_2002_count),
											 user_bugs_reported_2003_count = safe_ifelse(is.na(user_bugs_reported_2003_count), 0, user_bugs_reported_2003_count),
											 user_bugs_reported_2004_count = safe_ifelse(is.na(user_bugs_reported_2004_count), 0, user_bugs_reported_2004_count),
											 user_bugs_reported_2005_count = safe_ifelse(is.na(user_bugs_reported_2005_count), 0, user_bugs_reported_2005_count),
											 user_bugs_reported_2006_count = safe_ifelse(is.na(user_bugs_reported_2006_count), 0, user_bugs_reported_2006_count),
											 user_bugs_reported_2007_count = safe_ifelse(is.na(user_bugs_reported_2007_count), 0, user_bugs_reported_2007_count),
											 user_bugs_reported_2008_count = safe_ifelse(is.na(user_bugs_reported_2008_count), 0, user_bugs_reported_2008_count),
											 user_bugs_reported_2009_count = safe_ifelse(is.na(user_bugs_reported_2009_count), 0, user_bugs_reported_2009_count),
											 user_bugs_reported_2010_count = safe_ifelse(is.na(user_bugs_reported_2010_count), 0, user_bugs_reported_2010_count),
											 user_bugs_reported_2011_count = safe_ifelse(is.na(user_bugs_reported_2011_count), 0, user_bugs_reported_2011_count),
											 user_bugs_reported_2012_count = safe_ifelse(is.na(user_bugs_reported_2012_count), 0, user_bugs_reported_2012_count),
											 user_bugs_reported_2013_count = safe_ifelse(is.na(user_bugs_reported_2013_count), 0, user_bugs_reported_2013_count)); 


# PROFILES-BUGS_USER_ASSIGNED_TO_YEAR
# (Count the bugs assigned_to each user for each year)

# Select just the fields in the bugs_working table that we want to look at, namely assigned_to and creation_ts
bugs_working_assigned_to_creation_ts <- select(bugs_working, assigned_to, creation_ts);

# Transmute to get just the year of the creation_ts column
bugs_working_assigned_to_year <- transmute(bugs_working_assigned_to_creation_ts, assigned_to = assigned_to, creation_ts_year = format(creation_ts, format='%Y'));

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user was assigned_to a bug during each of the years in the database
bugs_working_assigned_to_year_recast <- dcast(bugs_working_assigned_to_year, assigned_to ~ creation_ts_year, drop=FALSE, value.var="creation_ts_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(bugs_working_assigned_to_year_recast) <- gsub("^(\\d)", "arg\\1", names(bugs_working_assigned_to_year_recast), perl=TRUE);

# Transmute all of the columns to the desired values
bugs_working_assigned_to_year_recast <- transmute(bugs_working_assigned_to_year_recast, assigned_to						 = assigned_to, 
																						user_bugs_assigned_to_1994_count = if (exists('arg1994', where = bugs_working_assigned_to_year_recast)) arg1994 else 0,
																						user_bugs_assigned_to_1995_count = if (exists('arg1995', where = bugs_working_assigned_to_year_recast)) arg1995 else 0,
																						user_bugs_assigned_to_1996_count = if (exists('arg1996', where = bugs_working_assigned_to_year_recast)) arg1996 else 0,
																						user_bugs_assigned_to_1997_count = if (exists('arg1997', where = bugs_working_assigned_to_year_recast)) arg1997 else 0,
																						user_bugs_assigned_to_1998_count = if (exists('arg1998', where = bugs_working_assigned_to_year_recast)) arg1998 else 0,
																						user_bugs_assigned_to_1999_count = if (exists('arg1999', where = bugs_working_assigned_to_year_recast)) arg1999 else 0,
																						user_bugs_assigned_to_2000_count = if (exists('arg2000', where = bugs_working_assigned_to_year_recast)) arg2000 else 0,
																						user_bugs_assigned_to_2001_count = if (exists('arg2001', where = bugs_working_assigned_to_year_recast)) arg2001 else 0,
																						user_bugs_assigned_to_2002_count = if (exists('arg2002', where = bugs_working_assigned_to_year_recast)) arg2002 else 0,
																						user_bugs_assigned_to_2003_count = if (exists('arg2003', where = bugs_working_assigned_to_year_recast)) arg2003 else 0,
																						user_bugs_assigned_to_2004_count = if (exists('arg2004', where = bugs_working_assigned_to_year_recast)) arg2004 else 0,
																						user_bugs_assigned_to_2005_count = if (exists('arg2005', where = bugs_working_assigned_to_year_recast)) arg2005 else 0,
																						user_bugs_assigned_to_2006_count = if (exists('arg2006', where = bugs_working_assigned_to_year_recast)) arg2006 else 0,
																						user_bugs_assigned_to_2007_count = if (exists('arg2007', where = bugs_working_assigned_to_year_recast)) arg2007 else 0,
																						user_bugs_assigned_to_2008_count = if (exists('arg2008', where = bugs_working_assigned_to_year_recast)) arg2008 else 0,
																						user_bugs_assigned_to_2009_count = if (exists('arg2009', where = bugs_working_assigned_to_year_recast)) arg2009 else 0,
																						user_bugs_assigned_to_2010_count = if (exists('arg2010', where = bugs_working_assigned_to_year_recast)) arg2010 else 0,
																						user_bugs_assigned_to_2011_count = if (exists('arg2011', where = bugs_working_assigned_to_year_recast)) arg2011 else 0,
																						user_bugs_assigned_to_2012_count = if (exists('arg2012', where = bugs_working_assigned_to_year_recast)) arg2012 else 0,
																						user_bugs_assigned_to_2013_count = if (exists('arg2013', where = bugs_working_assigned_to_year_recast)) arg2013 else 0);
																					 																						
# Merge the bugs_working_assigned_to_year_recast and profiles_working tables based on assigned_to & userid to add the years count columns
setkey(bugs_working_assigned_to_year_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_year_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user was not assigned any bugs, so change to 0
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_1994_count = safe_ifelse(is.na(user_bugs_assigned_to_1994_count), 0, user_bugs_assigned_to_1994_count),
											 user_bugs_assigned_to_1995_count = safe_ifelse(is.na(user_bugs_assigned_to_1995_count), 0, user_bugs_assigned_to_1995_count),
											 user_bugs_assigned_to_1996_count = safe_ifelse(is.na(user_bugs_assigned_to_1996_count), 0, user_bugs_assigned_to_1996_count),
											 user_bugs_assigned_to_1997_count = safe_ifelse(is.na(user_bugs_assigned_to_1997_count), 0, user_bugs_assigned_to_1997_count),
											 user_bugs_assigned_to_1998_count = safe_ifelse(is.na(user_bugs_assigned_to_1998_count), 0, user_bugs_assigned_to_1998_count),
											 user_bugs_assigned_to_1999_count = safe_ifelse(is.na(user_bugs_assigned_to_1999_count), 0, user_bugs_assigned_to_1999_count),
											 user_bugs_assigned_to_2000_count = safe_ifelse(is.na(user_bugs_assigned_to_2000_count), 0, user_bugs_assigned_to_2000_count),
											 user_bugs_assigned_to_2001_count = safe_ifelse(is.na(user_bugs_assigned_to_2001_count), 0, user_bugs_assigned_to_2001_count),
											 user_bugs_assigned_to_2002_count = safe_ifelse(is.na(user_bugs_assigned_to_2002_count), 0, user_bugs_assigned_to_2002_count),
											 user_bugs_assigned_to_2003_count = safe_ifelse(is.na(user_bugs_assigned_to_2003_count), 0, user_bugs_assigned_to_2003_count),
											 user_bugs_assigned_to_2004_count = safe_ifelse(is.na(user_bugs_assigned_to_2004_count), 0, user_bugs_assigned_to_2004_count),
											 user_bugs_assigned_to_2005_count = safe_ifelse(is.na(user_bugs_assigned_to_2005_count), 0, user_bugs_assigned_to_2005_count),
											 user_bugs_assigned_to_2006_count = safe_ifelse(is.na(user_bugs_assigned_to_2006_count), 0, user_bugs_assigned_to_2006_count),
											 user_bugs_assigned_to_2007_count = safe_ifelse(is.na(user_bugs_assigned_to_2007_count), 0, user_bugs_assigned_to_2007_count),
											 user_bugs_assigned_to_2008_count = safe_ifelse(is.na(user_bugs_assigned_to_2008_count), 0, user_bugs_assigned_to_2008_count),
											 user_bugs_assigned_to_2009_count = safe_ifelse(is.na(user_bugs_assigned_to_2009_count), 0, user_bugs_assigned_to_2009_count),
											 user_bugs_assigned_to_2010_count = safe_ifelse(is.na(user_bugs_assigned_to_2010_count), 0, user_bugs_assigned_to_2010_count),
											 user_bugs_assigned_to_2011_count = safe_ifelse(is.na(user_bugs_assigned_to_2011_count), 0, user_bugs_assigned_to_2011_count),
											 user_bugs_assigned_to_2012_count = safe_ifelse(is.na(user_bugs_assigned_to_2012_count), 0, user_bugs_assigned_to_2012_count),
											 user_bugs_assigned_to_2013_count = safe_ifelse(is.na(user_bugs_assigned_to_2013_count), 0, user_bugs_assigned_to_2013_count));



# PROFILES-BUGS_USER_QA_CONTACT_YEAR
# (Count the bugs for which each user is qa_contact for each year)

# Select just the fields in the bugs_working table that we want to look at, namely qa_contact and creation_ts
bugs_working_qa_contact_creation_ts <- select(bugs_working, qa_contact, creation_ts);

# Transmute to get just the year of the creation_ts column
bugs_working_qa_contact_year <- transmute(bugs_working_qa_contact_creation_ts, qa_contact = qa_contact, creation_ts_year = format(creation_ts, format='%Y'));

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user was qa_contact for a bug during each of the years in the database
bugs_working_qa_contact_year_recast <- dcast(bugs_working_qa_contact_year, qa_contact ~ creation_ts_year, drop=FALSE, value.var="creation_ts_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(bugs_working_qa_contact_year_recast) <- gsub("^(\\d)", "arg\\1", names(bugs_working_qa_contact_year_recast), perl=TRUE);

# Transmute all of the columns to the desired values
bugs_working_qa_contact_year_recast <- transmute(bugs_working_qa_contact_year_recast, 	qa_contact						= qa_contact,
																						user_bugs_qa_contact_1994_count = if (exists('arg1994', where = bugs_working_qa_contact_year_recast)) arg1994 else 0,
																						user_bugs_qa_contact_1995_count = if (exists('arg1995', where = bugs_working_qa_contact_year_recast)) arg1995 else 0,
																						user_bugs_qa_contact_1996_count = if (exists('arg1996', where = bugs_working_qa_contact_year_recast)) arg1996 else 0,
																						user_bugs_qa_contact_1997_count = if (exists('arg1997', where = bugs_working_qa_contact_year_recast)) arg1997 else 0,
																						user_bugs_qa_contact_1998_count = if (exists('arg1998', where = bugs_working_qa_contact_year_recast)) arg1998 else 0,
																						user_bugs_qa_contact_1999_count = if (exists('arg1999', where = bugs_working_qa_contact_year_recast)) arg1999 else 0,
																						user_bugs_qa_contact_2000_count = if (exists('arg2000', where = bugs_working_qa_contact_year_recast)) arg2000 else 0,
																						user_bugs_qa_contact_2001_count = if (exists('arg2001', where = bugs_working_qa_contact_year_recast)) arg2001 else 0,
																						user_bugs_qa_contact_2002_count = if (exists('arg2002', where = bugs_working_qa_contact_year_recast)) arg2002 else 0,
																						user_bugs_qa_contact_2003_count = if (exists('arg2003', where = bugs_working_qa_contact_year_recast)) arg2003 else 0,
																						user_bugs_qa_contact_2004_count = if (exists('arg2004', where = bugs_working_qa_contact_year_recast)) arg2004 else 0,
																						user_bugs_qa_contact_2005_count = if (exists('arg2005', where = bugs_working_qa_contact_year_recast)) arg2005 else 0,
																						user_bugs_qa_contact_2006_count = if (exists('arg2006', where = bugs_working_qa_contact_year_recast)) arg2006 else 0,
																						user_bugs_qa_contact_2007_count = if (exists('arg2007', where = bugs_working_qa_contact_year_recast)) arg2007 else 0,
																						user_bugs_qa_contact_2008_count = if (exists('arg2008', where = bugs_working_qa_contact_year_recast)) arg2008 else 0,
																						user_bugs_qa_contact_2009_count = if (exists('arg2009', where = bugs_working_qa_contact_year_recast)) arg2009 else 0,
																						user_bugs_qa_contact_2010_count = if (exists('arg2010', where = bugs_working_qa_contact_year_recast)) arg2010 else 0,
																						user_bugs_qa_contact_2011_count = if (exists('arg2011', where = bugs_working_qa_contact_year_recast)) arg2011 else 0,
																						user_bugs_qa_contact_2012_count = if (exists('arg2012', where = bugs_working_qa_contact_year_recast)) arg2012 else 0,
																						user_bugs_qa_contact_2013_count = if (exists('arg2013', where = bugs_working_qa_contact_year_recast)) arg2013 else 0);
																						
# Merge the bugs_working_qa_contact_year_recast and profiles_working tables based on qa_contact & userid to add the years count columns
setkey(bugs_working_qa_contact_year_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_year_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user was not set as qa_contact for any bugs, so change to 0
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_1994_count = safe_ifelse(is.na(user_bugs_qa_contact_1994_count), 0, user_bugs_qa_contact_1994_count),
                                             user_bugs_qa_contact_1995_count = safe_ifelse(is.na(user_bugs_qa_contact_1995_count), 0, user_bugs_qa_contact_1995_count),
											 user_bugs_qa_contact_1996_count = safe_ifelse(is.na(user_bugs_qa_contact_1996_count), 0, user_bugs_qa_contact_1996_count),
											 user_bugs_qa_contact_1997_count = safe_ifelse(is.na(user_bugs_qa_contact_1997_count), 0, user_bugs_qa_contact_1997_count),
											 user_bugs_qa_contact_1998_count = safe_ifelse(is.na(user_bugs_qa_contact_1998_count), 0, user_bugs_qa_contact_1998_count),
											 user_bugs_qa_contact_1999_count = safe_ifelse(is.na(user_bugs_qa_contact_1999_count), 0, user_bugs_qa_contact_1999_count),
											 user_bugs_qa_contact_2000_count = safe_ifelse(is.na(user_bugs_qa_contact_2000_count), 0, user_bugs_qa_contact_2000_count),
											 user_bugs_qa_contact_2001_count = safe_ifelse(is.na(user_bugs_qa_contact_2001_count), 0, user_bugs_qa_contact_2001_count),
											 user_bugs_qa_contact_2002_count = safe_ifelse(is.na(user_bugs_qa_contact_2002_count), 0, user_bugs_qa_contact_2002_count),
											 user_bugs_qa_contact_2003_count = safe_ifelse(is.na(user_bugs_qa_contact_2003_count), 0, user_bugs_qa_contact_2003_count),
											 user_bugs_qa_contact_2004_count = safe_ifelse(is.na(user_bugs_qa_contact_2004_count), 0, user_bugs_qa_contact_2004_count),
											 user_bugs_qa_contact_2005_count = safe_ifelse(is.na(user_bugs_qa_contact_2005_count), 0, user_bugs_qa_contact_2005_count),
											 user_bugs_qa_contact_2006_count = safe_ifelse(is.na(user_bugs_qa_contact_2006_count), 0, user_bugs_qa_contact_2006_count),
											 user_bugs_qa_contact_2007_count = safe_ifelse(is.na(user_bugs_qa_contact_2007_count), 0, user_bugs_qa_contact_2007_count),
											 user_bugs_qa_contact_2008_count = safe_ifelse(is.na(user_bugs_qa_contact_2008_count), 0, user_bugs_qa_contact_2008_count),
											 user_bugs_qa_contact_2009_count = safe_ifelse(is.na(user_bugs_qa_contact_2009_count), 0, user_bugs_qa_contact_2009_count),
											 user_bugs_qa_contact_2010_count = safe_ifelse(is.na(user_bugs_qa_contact_2010_count), 0, user_bugs_qa_contact_2010_count),
											 user_bugs_qa_contact_2011_count = safe_ifelse(is.na(user_bugs_qa_contact_2011_count), 0, user_bugs_qa_contact_2011_count),
											 user_bugs_qa_contact_2012_count = safe_ifelse(is.na(user_bugs_qa_contact_2012_count), 0, user_bugs_qa_contact_2012_count),
											 user_bugs_qa_contact_2013_count = safe_ifelse(is.na(user_bugs_qa_contact_2013_count), 0, user_bugs_qa_contact_2013_count));


# PROFILES-ACTIVITY_TYPES_YEARS
# (Count the types of activity done by each user per year)

# The types of interest to count are changes to the following bug fields: CC, keywords, product, component, status, resolution, 
# flags, whiteboard, target_milestone, description, priority, & severity
# Their respective fieldid's are: 37, 21, 25, 33, 29, 30, 69, 22, 40, 24, 32, 31 in the activity table
# Since we only care about count per year, all we need is "who", "fieldid", and year(bug_when) . Other columns don't matter here.

activity_working_types_who_year <- transmute(filter(activity_base, fieldid %in% c(37, 21, 25, 33, 29, 30, 69, 22, 40, 24, 32, 31)), who = who, fieldid = fieldid, bug_when_year = format(bug_when, format='%Y'));

# Use data.table's dcast() function to recast the table such that each row is a single user and there is
# a column for each field_id that is the sum of each activities of that type by each user for each year
activity_working_types_who_year_recast <- dcast(activity_working_types_who_year, who ~ fieldid + bug_when_year, drop=FALSE, value.var="fieldid", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_working_types_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(activity_working_types_who_year_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns to our desired names
activity_working_types_who_year_recast <- transmute(activity_working_types_who_year_recast, 	who 												= who,
																								user_activity_cc_change_1998_count 					= if (exists('arg37_1998', where = activity_working_types_who_year_recast)) arg37_1998 else 0,
																								user_activity_cc_change_1999_count 					= if (exists('arg37_1999', where = activity_working_types_who_year_recast)) arg37_1999 else 0,
																								user_activity_cc_change_2000_count 					= if (exists('arg37_2000', where = activity_working_types_who_year_recast)) arg37_2000 else 0,
																								user_activity_cc_change_2001_count 					= if (exists('arg37_2001', where = activity_working_types_who_year_recast)) arg37_2001 else 0,
																								user_activity_cc_change_2002_count 					= if (exists('arg37_2002', where = activity_working_types_who_year_recast)) arg37_2002 else 0,
																								user_activity_cc_change_2003_count 					= if (exists('arg37_2003', where = activity_working_types_who_year_recast)) arg37_2003 else 0,
																								user_activity_cc_change_2004_count 					= if (exists('arg37_2004', where = activity_working_types_who_year_recast)) arg37_2004 else 0,
																								user_activity_cc_change_2005_count 					= if (exists('arg37_2005', where = activity_working_types_who_year_recast)) arg37_2005 else 0,
																								user_activity_cc_change_2006_count 					= if (exists('arg37_2006', where = activity_working_types_who_year_recast)) arg37_2006 else 0,
																								user_activity_cc_change_2007_count 					= if (exists('arg37_2007', where = activity_working_types_who_year_recast)) arg37_2007 else 0,
																								user_activity_cc_change_2008_count 					= if (exists('arg37_2008', where = activity_working_types_who_year_recast)) arg37_2008 else 0,
																								user_activity_cc_change_2009_count 					= if (exists('arg37_2009', where = activity_working_types_who_year_recast)) arg37_2009 else 0,
																								user_activity_cc_change_2010_count 					= if (exists('arg37_2010', where = activity_working_types_who_year_recast)) arg37_2010 else 0,
																								user_activity_cc_change_2011_count 					= if (exists('arg37_2011', where = activity_working_types_who_year_recast)) arg37_2011 else 0,
																								user_activity_cc_change_2012_count 					= if (exists('arg37_2012', where = activity_working_types_who_year_recast)) arg37_2012 else 0,
																								user_activity_cc_change_2013_count 					= if (exists('arg37_2013', where = activity_working_types_who_year_recast)) arg37_2013 else 0,
																								user_activity_keywords_change_1998_count 			= if (exists('arg21_1998', where = activity_working_types_who_year_recast)) arg21_1998 else 0,
																								user_activity_keywords_change_1999_count 			= if (exists('arg21_1999', where = activity_working_types_who_year_recast)) arg21_1999 else 0,
																								user_activity_keywords_change_2000_count 			= if (exists('arg21_2000', where = activity_working_types_who_year_recast)) arg21_2000 else 0,
																								user_activity_keywords_change_2001_count 			= if (exists('arg21_2001', where = activity_working_types_who_year_recast)) arg21_2001 else 0,
																								user_activity_keywords_change_2002_count 			= if (exists('arg21_2002', where = activity_working_types_who_year_recast)) arg21_2002 else 0,
																								user_activity_keywords_change_2003_count 			= if (exists('arg21_2003', where = activity_working_types_who_year_recast)) arg21_2003 else 0,
																								user_activity_keywords_change_2004_count 			= if (exists('arg21_2004', where = activity_working_types_who_year_recast)) arg21_2004 else 0,
																								user_activity_keywords_change_2005_count 			= if (exists('arg21_2005', where = activity_working_types_who_year_recast)) arg21_2005 else 0,
																								user_activity_keywords_change_2006_count 			= if (exists('arg21_2006', where = activity_working_types_who_year_recast)) arg21_2006 else 0,
																								user_activity_keywords_change_2007_count 			= if (exists('arg21_2007', where = activity_working_types_who_year_recast)) arg21_2007 else 0,
																								user_activity_keywords_change_2008_count 			= if (exists('arg21_2008', where = activity_working_types_who_year_recast)) arg21_2008 else 0,
																								user_activity_keywords_change_2009_count 			= if (exists('arg21_2009', where = activity_working_types_who_year_recast)) arg21_2009 else 0,
																								user_activity_keywords_change_2010_count 			= if (exists('arg21_2010', where = activity_working_types_who_year_recast)) arg21_2010 else 0,
																								user_activity_keywords_change_2011_count 			= if (exists('arg21_2011', where = activity_working_types_who_year_recast)) arg21_2011 else 0,
																								user_activity_keywords_change_2012_count 			= if (exists('arg21_2012', where = activity_working_types_who_year_recast)) arg21_2012 else 0,
																								user_activity_keywords_change_2013_count 			= if (exists('arg21_2013', where = activity_working_types_who_year_recast)) arg21_2013 else 0,
																								user_activity_product_change_1998_count 			= if (exists('arg25_1998', where = activity_working_types_who_year_recast)) arg25_1998 else 0,
																								user_activity_product_change_1999_count 			= if (exists('arg25_1999', where = activity_working_types_who_year_recast)) arg25_1999 else 0,
																								user_activity_product_change_2000_count 			= if (exists('arg25_2000', where = activity_working_types_who_year_recast)) arg25_2000 else 0,
																								user_activity_product_change_2001_count 			= if (exists('arg25_2001', where = activity_working_types_who_year_recast)) arg25_2001 else 0,
																								user_activity_product_change_2002_count 			= if (exists('arg25_2002', where = activity_working_types_who_year_recast)) arg25_2002 else 0,
																								user_activity_product_change_2003_count 			= if (exists('arg25_2003', where = activity_working_types_who_year_recast)) arg25_2003 else 0,
																								user_activity_product_change_2004_count 			= if (exists('arg25_2004', where = activity_working_types_who_year_recast)) arg25_2004 else 0,
																								user_activity_product_change_2005_count 			= if (exists('arg25_2005', where = activity_working_types_who_year_recast)) arg25_2005 else 0,
																								user_activity_product_change_2006_count 			= if (exists('arg25_2006', where = activity_working_types_who_year_recast)) arg25_2006 else 0,
																								user_activity_product_change_2007_count 			= if (exists('arg25_2007', where = activity_working_types_who_year_recast)) arg25_2007 else 0,
																								user_activity_product_change_2008_count 			= if (exists('arg25_2008', where = activity_working_types_who_year_recast)) arg25_2008 else 0,
																								user_activity_product_change_2009_count 			= if (exists('arg25_2009', where = activity_working_types_who_year_recast)) arg25_2009 else 0,
																								user_activity_product_change_2010_count 			= if (exists('arg25_2010', where = activity_working_types_who_year_recast)) arg25_2010 else 0,
																								user_activity_product_change_2011_count 			= if (exists('arg25_2011', where = activity_working_types_who_year_recast)) arg25_2011 else 0,
																								user_activity_product_change_2012_count 			= if (exists('arg25_2012', where = activity_working_types_who_year_recast)) arg25_2012 else 0,
																								user_activity_product_change_2013_count 			= if (exists('arg25_2013', where = activity_working_types_who_year_recast)) arg25_2013 else 0,
																								user_activity_component_change_1998_count 			= if (exists('arg33_1998', where = activity_working_types_who_year_recast)) arg33_1998 else 0,
																								user_activity_component_change_1999_count 			= if (exists('arg33_1999', where = activity_working_types_who_year_recast)) arg33_1999 else 0,
																								user_activity_component_change_2000_count 			= if (exists('arg33_2000', where = activity_working_types_who_year_recast)) arg33_2000 else 0,
																								user_activity_component_change_2001_count 			= if (exists('arg33_2001', where = activity_working_types_who_year_recast)) arg33_2001 else 0,
																								user_activity_component_change_2002_count 			= if (exists('arg33_2002', where = activity_working_types_who_year_recast)) arg33_2002 else 0,
																								user_activity_component_change_2003_count 			= if (exists('arg33_2003', where = activity_working_types_who_year_recast)) arg33_2003 else 0,
																								user_activity_component_change_2004_count 			= if (exists('arg33_2004', where = activity_working_types_who_year_recast)) arg33_2004 else 0,
																								user_activity_component_change_2005_count 			= if (exists('arg33_2005', where = activity_working_types_who_year_recast)) arg33_2005 else 0,
																								user_activity_component_change_2006_count 			= if (exists('arg33_2006', where = activity_working_types_who_year_recast)) arg33_2006 else 0,
																								user_activity_component_change_2007_count 			= if (exists('arg33_2007', where = activity_working_types_who_year_recast)) arg33_2007 else 0,
																								user_activity_component_change_2008_count 			= if (exists('arg33_2008', where = activity_working_types_who_year_recast)) arg33_2008 else 0,
																								user_activity_component_change_2009_count 			= if (exists('arg33_2009', where = activity_working_types_who_year_recast)) arg33_2009 else 0,
																								user_activity_component_change_2010_count 			= if (exists('arg33_2010', where = activity_working_types_who_year_recast)) arg33_2010 else 0,
																								user_activity_component_change_2011_count 			= if (exists('arg33_2011', where = activity_working_types_who_year_recast)) arg33_2011 else 0,
																								user_activity_component_change_2012_count 			= if (exists('arg33_2012', where = activity_working_types_who_year_recast)) arg33_2012 else 0,
																								user_activity_component_change_2013_count 			= if (exists('arg33_2013', where = activity_working_types_who_year_recast)) arg33_2013 else 0,
																								user_activity_status_change_1998_count 				= if (exists('arg29_1998', where = activity_working_types_who_year_recast)) arg29_1998 else 0,
																								user_activity_status_change_1999_count 				= if (exists('arg29_1999', where = activity_working_types_who_year_recast)) arg29_1999 else 0,
																								user_activity_status_change_2000_count 				= if (exists('arg29_2000', where = activity_working_types_who_year_recast)) arg29_2000 else 0,
																								user_activity_status_change_2001_count 				= if (exists('arg29_2001', where = activity_working_types_who_year_recast)) arg29_2001 else 0,
																								user_activity_status_change_2002_count 				= if (exists('arg29_2002', where = activity_working_types_who_year_recast)) arg29_2002 else 0,
																								user_activity_status_change_2003_count 				= if (exists('arg29_2003', where = activity_working_types_who_year_recast)) arg29_2003 else 0,
																								user_activity_status_change_2004_count 				= if (exists('arg29_2004', where = activity_working_types_who_year_recast)) arg29_2004 else 0,
																								user_activity_status_change_2005_count 				= if (exists('arg29_2005', where = activity_working_types_who_year_recast)) arg29_2005 else 0,
																								user_activity_status_change_2006_count 				= if (exists('arg29_2006', where = activity_working_types_who_year_recast)) arg29_2006 else 0,
																								user_activity_status_change_2007_count 				= if (exists('arg29_2007', where = activity_working_types_who_year_recast)) arg29_2007 else 0,
																								user_activity_status_change_2008_count 				= if (exists('arg29_2008', where = activity_working_types_who_year_recast)) arg29_2008 else 0,
																								user_activity_status_change_2009_count 				= if (exists('arg29_2009', where = activity_working_types_who_year_recast)) arg29_2009 else 0,
																								user_activity_status_change_2010_count 				= if (exists('arg29_2010', where = activity_working_types_who_year_recast)) arg29_2010 else 0,
																								user_activity_status_change_2011_count 				= if (exists('arg29_2011', where = activity_working_types_who_year_recast)) arg29_2011 else 0,
																								user_activity_status_change_2012_count 				= if (exists('arg29_2012', where = activity_working_types_who_year_recast)) arg29_2012 else 0,
																								user_activity_status_change_2013_count 				= if (exists('arg29_2013', where = activity_working_types_who_year_recast)) arg29_2013 else 0,
																								user_activity_resolution_change_1998_count 			= if (exists('arg30_1998', where = activity_working_types_who_year_recast)) arg30_1998 else 0,
																								user_activity_resolution_change_1999_count 			= if (exists('arg30_1999', where = activity_working_types_who_year_recast)) arg30_1999 else 0,
																								user_activity_resolution_change_2000_count 			= if (exists('arg30_2000', where = activity_working_types_who_year_recast)) arg30_2000 else 0,
																								user_activity_resolution_change_2001_count 			= if (exists('arg30_2001', where = activity_working_types_who_year_recast)) arg30_2001 else 0,
																								user_activity_resolution_change_2002_count 			= if (exists('arg30_2002', where = activity_working_types_who_year_recast)) arg30_2002 else 0,
																								user_activity_resolution_change_2003_count 			= if (exists('arg30_2003', where = activity_working_types_who_year_recast)) arg30_2003 else 0,
																								user_activity_resolution_change_2004_count 			= if (exists('arg30_2004', where = activity_working_types_who_year_recast)) arg30_2004 else 0,
																								user_activity_resolution_change_2005_count 			= if (exists('arg30_2005', where = activity_working_types_who_year_recast)) arg30_2005 else 0,
																								user_activity_resolution_change_2006_count 			= if (exists('arg30_2006', where = activity_working_types_who_year_recast)) arg30_2006 else 0,
																								user_activity_resolution_change_2007_count 			= if (exists('arg30_2007', where = activity_working_types_who_year_recast)) arg30_2007 else 0,
																								user_activity_resolution_change_2008_count 			= if (exists('arg30_2008', where = activity_working_types_who_year_recast)) arg30_2008 else 0,
																								user_activity_resolution_change_2009_count 			= if (exists('arg30_2009', where = activity_working_types_who_year_recast)) arg30_2009 else 0,
																								user_activity_resolution_change_2010_count 			= if (exists('arg30_2010', where = activity_working_types_who_year_recast)) arg30_2010 else 0,
																								user_activity_resolution_change_2011_count 			= if (exists('arg30_2011', where = activity_working_types_who_year_recast)) arg30_2011 else 0,
																								user_activity_resolution_change_2012_count 			= if (exists('arg30_2012', where = activity_working_types_who_year_recast)) arg30_2012 else 0,
																								user_activity_resolution_change_2013_count 			= if (exists('arg30_2013', where = activity_working_types_who_year_recast)) arg30_2013 else 0,
																								user_activity_flags_change_1998_count 				= if (exists('arg69_1998', where = activity_working_types_who_year_recast)) arg69_1998 else 0,
																								user_activity_flags_change_1999_count 				= if (exists('arg69_1999', where = activity_working_types_who_year_recast)) arg69_1999 else 0,
																								user_activity_flags_change_2000_count 				= if (exists('arg69_2000', where = activity_working_types_who_year_recast)) arg69_2000 else 0,
																								user_activity_flags_change_2001_count 				= if (exists('arg69_2001', where = activity_working_types_who_year_recast)) arg69_2001 else 0,
																								user_activity_flags_change_2002_count 				= if (exists('arg69_2002', where = activity_working_types_who_year_recast)) arg69_2002 else 0,
																								user_activity_flags_change_2003_count 				= if (exists('arg69_2003', where = activity_working_types_who_year_recast)) arg69_2003 else 0,
																								user_activity_flags_change_2004_count 				= if (exists('arg69_2004', where = activity_working_types_who_year_recast)) arg69_2004 else 0,
																								user_activity_flags_change_2005_count 				= if (exists('arg69_2005', where = activity_working_types_who_year_recast)) arg69_2005 else 0,
																								user_activity_flags_change_2006_count 				= if (exists('arg69_2006', where = activity_working_types_who_year_recast)) arg69_2006 else 0,
																								user_activity_flags_change_2007_count 				= if (exists('arg69_2007', where = activity_working_types_who_year_recast)) arg69_2007 else 0,
																								user_activity_flags_change_2008_count 				= if (exists('arg69_2008', where = activity_working_types_who_year_recast)) arg69_2008 else 0,
																								user_activity_flags_change_2009_count 				= if (exists('arg69_2009', where = activity_working_types_who_year_recast)) arg69_2009 else 0,
																								user_activity_flags_change_2010_count 				= if (exists('arg69_2010', where = activity_working_types_who_year_recast)) arg69_2010 else 0,
																								user_activity_flags_change_2011_count 				= if (exists('arg69_2011', where = activity_working_types_who_year_recast)) arg69_2011 else 0,
																								user_activity_flags_change_2012_count 				= if (exists('arg69_2012', where = activity_working_types_who_year_recast)) arg69_2012 else 0,
																								user_activity_flags_change_2013_count 				= if (exists('arg69_2013', where = activity_working_types_who_year_recast)) arg69_2013 else 0,
																								user_activity_whiteboard_change_1998_count 			= if (exists('arg22_1998', where = activity_working_types_who_year_recast)) arg22_1998 else 0,
																								user_activity_whiteboard_change_1999_count 			= if (exists('arg22_1999', where = activity_working_types_who_year_recast)) arg22_1999 else 0,
																								user_activity_whiteboard_change_2000_count 			= if (exists('arg22_2000', where = activity_working_types_who_year_recast)) arg22_2000 else 0,
																								user_activity_whiteboard_change_2001_count 			= if (exists('arg22_2001', where = activity_working_types_who_year_recast)) arg22_2001 else 0,
																								user_activity_whiteboard_change_2002_count 			= if (exists('arg22_2002', where = activity_working_types_who_year_recast)) arg22_2002 else 0,
																								user_activity_whiteboard_change_2003_count 			= if (exists('arg22_2003', where = activity_working_types_who_year_recast)) arg22_2003 else 0,
																								user_activity_whiteboard_change_2004_count 			= if (exists('arg22_2004', where = activity_working_types_who_year_recast)) arg22_2004 else 0,
																								user_activity_whiteboard_change_2005_count 			= if (exists('arg22_2005', where = activity_working_types_who_year_recast)) arg22_2005 else 0,
																								user_activity_whiteboard_change_2006_count 			= if (exists('arg22_2006', where = activity_working_types_who_year_recast)) arg22_2006 else 0,
																								user_activity_whiteboard_change_2007_count 			= if (exists('arg22_2007', where = activity_working_types_who_year_recast)) arg22_2007 else 0,
																								user_activity_whiteboard_change_2008_count 			= if (exists('arg22_2008', where = activity_working_types_who_year_recast)) arg22_2008 else 0,
																								user_activity_whiteboard_change_2009_count 			= if (exists('arg22_2009', where = activity_working_types_who_year_recast)) arg22_2009 else 0,
																								user_activity_whiteboard_change_2010_count 			= if (exists('arg22_2010', where = activity_working_types_who_year_recast)) arg22_2010 else 0,
																								user_activity_whiteboard_change_2011_count 			= if (exists('arg22_2011', where = activity_working_types_who_year_recast)) arg22_2011 else 0,
																								user_activity_whiteboard_change_2012_count 			= if (exists('arg22_2012', where = activity_working_types_who_year_recast)) arg22_2012 else 0,
																								user_activity_whiteboard_change_2013_count 			= if (exists('arg22_2013', where = activity_working_types_who_year_recast)) arg22_2013 else 0,
																								user_activity_target_milestone_change_1998_count 	= if (exists('arg40_1998', where = activity_working_types_who_year_recast)) arg40_1998 else 0,
																								user_activity_target_milestone_change_1999_count 	= if (exists('arg40_1999', where = activity_working_types_who_year_recast)) arg40_1999 else 0,
																								user_activity_target_milestone_change_2000_count 	= if (exists('arg40_2000', where = activity_working_types_who_year_recast)) arg40_2000 else 0,
																								user_activity_target_milestone_change_2001_count 	= if (exists('arg40_2001', where = activity_working_types_who_year_recast)) arg40_2001 else 0,
																								user_activity_target_milestone_change_2002_count 	= if (exists('arg40_2002', where = activity_working_types_who_year_recast)) arg40_2002 else 0,
																								user_activity_target_milestone_change_2003_count 	= if (exists('arg40_2003', where = activity_working_types_who_year_recast)) arg40_2003 else 0,
																								user_activity_target_milestone_change_2004_count 	= if (exists('arg40_2004', where = activity_working_types_who_year_recast)) arg40_2004 else 0,
																								user_activity_target_milestone_change_2005_count 	= if (exists('arg40_2005', where = activity_working_types_who_year_recast)) arg40_2005 else 0,
																								user_activity_target_milestone_change_2006_count 	= if (exists('arg40_2006', where = activity_working_types_who_year_recast)) arg40_2006 else 0,
																								user_activity_target_milestone_change_2007_count 	= if (exists('arg40_2007', where = activity_working_types_who_year_recast)) arg40_2007 else 0,
																								user_activity_target_milestone_change_2008_count 	= if (exists('arg40_2008', where = activity_working_types_who_year_recast)) arg40_2008 else 0,
																								user_activity_target_milestone_change_2009_count 	= if (exists('arg40_2009', where = activity_working_types_who_year_recast)) arg40_2009 else 0,
																								user_activity_target_milestone_change_2010_count 	= if (exists('arg40_2010', where = activity_working_types_who_year_recast)) arg40_2010 else 0,
																								user_activity_target_milestone_change_2011_count 	= if (exists('arg40_2011', where = activity_working_types_who_year_recast)) arg40_2011 else 0,
																								user_activity_target_milestone_change_2012_count 	= if (exists('arg40_2012', where = activity_working_types_who_year_recast)) arg40_2012 else 0,
																								user_activity_target_milestone_change_2013_count 	= if (exists('arg40_2013', where = activity_working_types_who_year_recast)) arg40_2013 else 0,
																								user_activity_description_change_1998_count 		= if (exists('arg24_1998', where = activity_working_types_who_year_recast)) arg24_1998 else 0,
																								user_activity_description_change_1999_count 		= if (exists('arg24_1999', where = activity_working_types_who_year_recast)) arg24_1999 else 0,
																								user_activity_description_change_2000_count 		= if (exists('arg24_2000', where = activity_working_types_who_year_recast)) arg24_2000 else 0,
																								user_activity_description_change_2001_count 		= if (exists('arg24_2001', where = activity_working_types_who_year_recast)) arg24_2001 else 0,
																								user_activity_description_change_2002_count 		= if (exists('arg24_2002', where = activity_working_types_who_year_recast)) arg24_2002 else 0,
																								user_activity_description_change_2003_count 		= if (exists('arg24_2003', where = activity_working_types_who_year_recast)) arg24_2003 else 0,
																								user_activity_description_change_2004_count 		= if (exists('arg24_2004', where = activity_working_types_who_year_recast)) arg24_2004 else 0,
																								user_activity_description_change_2005_count 		= if (exists('arg24_2005', where = activity_working_types_who_year_recast)) arg24_2005 else 0,
																								user_activity_description_change_2006_count 		= if (exists('arg24_2006', where = activity_working_types_who_year_recast)) arg24_2006 else 0,
																								user_activity_description_change_2007_count 		= if (exists('arg24_2007', where = activity_working_types_who_year_recast)) arg24_2007 else 0,
																								user_activity_description_change_2008_count 		= if (exists('arg24_2008', where = activity_working_types_who_year_recast)) arg24_2008 else 0,
																								user_activity_description_change_2009_count 		= if (exists('arg24_2009', where = activity_working_types_who_year_recast)) arg24_2009 else 0,
																								user_activity_description_change_2010_count 		= if (exists('arg24_2010', where = activity_working_types_who_year_recast)) arg24_2010 else 0,
																								user_activity_description_change_2011_count 		= if (exists('arg24_2011', where = activity_working_types_who_year_recast)) arg24_2011 else 0,
																								user_activity_description_change_2012_count 		= if (exists('arg24_2012', where = activity_working_types_who_year_recast)) arg24_2012 else 0,
																								user_activity_description_change_2013_count 		= if (exists('arg24_2013', where = activity_working_types_who_year_recast)) arg24_2013 else 0,
																								user_activity_priority_change_1998_count 			= if (exists('arg32_1998', where = activity_working_types_who_year_recast)) arg32_1998 else 0,
																								user_activity_priority_change_1999_count 			= if (exists('arg32_1999', where = activity_working_types_who_year_recast)) arg32_1999 else 0,
																								user_activity_priority_change_2000_count 			= if (exists('arg32_2000', where = activity_working_types_who_year_recast)) arg32_2000 else 0,
																								user_activity_priority_change_2001_count 			= if (exists('arg32_2001', where = activity_working_types_who_year_recast)) arg32_2001 else 0,
																								user_activity_priority_change_2002_count 			= if (exists('arg32_2002', where = activity_working_types_who_year_recast)) arg32_2002 else 0,
																								user_activity_priority_change_2003_count 			= if (exists('arg32_2003', where = activity_working_types_who_year_recast)) arg32_2003 else 0,
																								user_activity_priority_change_2004_count 			= if (exists('arg32_2004', where = activity_working_types_who_year_recast)) arg32_2004 else 0,
																								user_activity_priority_change_2005_count 			= if (exists('arg32_2005', where = activity_working_types_who_year_recast)) arg32_2005 else 0,
																								user_activity_priority_change_2006_count 			= if (exists('arg32_2006', where = activity_working_types_who_year_recast)) arg32_2006 else 0,
																								user_activity_priority_change_2007_count 			= if (exists('arg32_2007', where = activity_working_types_who_year_recast)) arg32_2007 else 0,
																								user_activity_priority_change_2008_count 			= if (exists('arg32_2008', where = activity_working_types_who_year_recast)) arg32_2008 else 0,
																								user_activity_priority_change_2009_count 			= if (exists('arg32_2009', where = activity_working_types_who_year_recast)) arg32_2009 else 0,
																								user_activity_priority_change_2010_count 			= if (exists('arg32_2010', where = activity_working_types_who_year_recast)) arg32_2010 else 0,
																								user_activity_priority_change_2011_count 			= if (exists('arg32_2011', where = activity_working_types_who_year_recast)) arg32_2011 else 0,
																								user_activity_priority_change_2012_count 			= if (exists('arg32_2012', where = activity_working_types_who_year_recast)) arg32_2012 else 0,
																								user_activity_priority_change_2013_count 			= if (exists('arg32_2013', where = activity_working_types_who_year_recast)) arg32_2013 else 0,
																								user_activity_severity_change_1998_count 			= if (exists('arg31_1998', where = activity_working_types_who_year_recast)) arg31_1998 else 0,
																								user_activity_severity_change_1999_count 			= if (exists('arg31_1999', where = activity_working_types_who_year_recast)) arg31_1999 else 0,
																								user_activity_severity_change_2000_count 			= if (exists('arg31_2000', where = activity_working_types_who_year_recast)) arg31_2000 else 0,
																								user_activity_severity_change_2001_count 			= if (exists('arg31_2001', where = activity_working_types_who_year_recast)) arg31_2001 else 0,
																								user_activity_severity_change_2002_count 			= if (exists('arg31_2002', where = activity_working_types_who_year_recast)) arg31_2002 else 0,
																								user_activity_severity_change_2003_count 			= if (exists('arg31_2003', where = activity_working_types_who_year_recast)) arg31_2003 else 0,
																								user_activity_severity_change_2004_count 			= if (exists('arg31_2004', where = activity_working_types_who_year_recast)) arg31_2004 else 0,
																								user_activity_severity_change_2005_count 			= if (exists('arg31_2005', where = activity_working_types_who_year_recast)) arg31_2005 else 0,
																								user_activity_severity_change_2006_count 			= if (exists('arg31_2006', where = activity_working_types_who_year_recast)) arg31_2006 else 0,
																								user_activity_severity_change_2007_count 			= if (exists('arg31_2007', where = activity_working_types_who_year_recast)) arg31_2007 else 0,
																								user_activity_severity_change_2008_count 			= if (exists('arg31_2008', where = activity_working_types_who_year_recast)) arg31_2008 else 0,
																								user_activity_severity_change_2009_count 			= if (exists('arg31_2009', where = activity_working_types_who_year_recast)) arg31_2009 else 0,
																								user_activity_severity_change_2010_count 			= if (exists('arg31_2010', where = activity_working_types_who_year_recast)) arg31_2010 else 0,
																								user_activity_severity_change_2011_count 			= if (exists('arg31_2011', where = activity_working_types_who_year_recast)) arg31_2011 else 0,
																								user_activity_severity_change_2012_count 			= if (exists('arg31_2012', where = activity_working_types_who_year_recast)) arg31_2012 else 0,
																								user_activity_severity_change_2013_count 			= if (exists('arg31_2013', where = activity_working_types_who_year_recast)) arg31_2013 else 0);
																								
																								
activity_working_types_who_year_recast <- mutate(activity_working_types_who_year_recast, 
												user_activity_cc_change_all_count				= 	user_activity_cc_change_1998_count +
																									user_activity_cc_change_1999_count +
																									user_activity_cc_change_2000_count +
																									user_activity_cc_change_2001_count +
																									user_activity_cc_change_2002_count +
																									user_activity_cc_change_2003_count +
																									user_activity_cc_change_2004_count +
																									user_activity_cc_change_2005_count +
																									user_activity_cc_change_2006_count +
																									user_activity_cc_change_2007_count +
																									user_activity_cc_change_2008_count +
																									user_activity_cc_change_2009_count +
																									user_activity_cc_change_2010_count +
																									user_activity_cc_change_2011_count +
																									user_activity_cc_change_2012_count +
																									user_activity_cc_change_2013_count,

												user_activity_keywords_change_all_count			= 	user_activity_keywords_change_1998_count +
																									user_activity_keywords_change_1999_count +
																									user_activity_keywords_change_2000_count +
																									user_activity_keywords_change_2001_count +
																									user_activity_keywords_change_2002_count +
																									user_activity_keywords_change_2003_count +
																									user_activity_keywords_change_2004_count +
																									user_activity_keywords_change_2005_count +
																									user_activity_keywords_change_2006_count +
																									user_activity_keywords_change_2007_count +
																									user_activity_keywords_change_2008_count +
																									user_activity_keywords_change_2009_count +
																									user_activity_keywords_change_2010_count +
																									user_activity_keywords_change_2011_count +
																									user_activity_keywords_change_2012_count +
																									user_activity_keywords_change_2013_count,

												user_activity_product_change_all_count			= 	user_activity_product_change_1998_count  +
																									user_activity_product_change_1999_count +
																									user_activity_product_change_2000_count +
																									user_activity_product_change_2001_count +
																									user_activity_product_change_2002_count +
																									user_activity_product_change_2003_count +
																									user_activity_product_change_2004_count +
																									user_activity_product_change_2005_count +
																									user_activity_product_change_2006_count +
																									user_activity_product_change_2007_count +
																									user_activity_product_change_2008_count +
																									user_activity_product_change_2009_count +
																									user_activity_product_change_2010_count +
																									user_activity_product_change_2011_count +
																									user_activity_product_change_2012_count +
																									user_activity_product_change_2013_count,

												user_activity_component_change_all_count		= 	user_activity_component_change_1998_count +
																									user_activity_component_change_1999_count +
																									user_activity_component_change_2000_count +
																									user_activity_component_change_2001_count +
																									user_activity_component_change_2002_count +
																									user_activity_component_change_2003_count +
																									user_activity_component_change_2004_count +
																									user_activity_component_change_2005_count +
																									user_activity_component_change_2006_count +
																									user_activity_component_change_2007_count +
																									user_activity_component_change_2008_count +
																									user_activity_component_change_2009_count +
																									user_activity_component_change_2010_count +
																									user_activity_component_change_2011_count +
																									user_activity_component_change_2012_count +
																									user_activity_component_change_2013_count,

												user_activity_status_change_all_count			= 	user_activity_status_change_1998_count +
																									user_activity_status_change_1999_count +
																									user_activity_status_change_2000_count +
																									user_activity_status_change_2001_count +
																									user_activity_status_change_2002_count +
																									user_activity_status_change_2003_count +
																									user_activity_status_change_2004_count +
																									user_activity_status_change_2005_count +
																									user_activity_status_change_2006_count +
																									user_activity_status_change_2007_count +
																									user_activity_status_change_2008_count +
																									user_activity_status_change_2009_count +
																									user_activity_status_change_2010_count +
																									user_activity_status_change_2011_count +
																									user_activity_status_change_2012_count +
																									user_activity_status_change_2013_count,

												user_activity_resolution_change_all_count		= 	user_activity_resolution_change_1998_count +
																									user_activity_resolution_change_1999_count +
																									user_activity_resolution_change_2000_count +
																									user_activity_resolution_change_2001_count +
																									user_activity_resolution_change_2002_count +
																									user_activity_resolution_change_2003_count +
																									user_activity_resolution_change_2004_count +
																									user_activity_resolution_change_2005_count +
																									user_activity_resolution_change_2006_count +
																									user_activity_resolution_change_2007_count +
																									user_activity_resolution_change_2008_count +
																									user_activity_resolution_change_2009_count +
																									user_activity_resolution_change_2010_count +
																									user_activity_resolution_change_2011_count +
																									user_activity_resolution_change_2012_count +
																									user_activity_resolution_change_2013_count,
																									

												user_activity_flags_change_all_count			= 	user_activity_flags_change_1998_count +
																									user_activity_flags_change_1999_count +
																									user_activity_flags_change_2000_count +
																									user_activity_flags_change_2001_count +
																									user_activity_flags_change_2002_count +
																									user_activity_flags_change_2003_count +
																									user_activity_flags_change_2004_count +
																									user_activity_flags_change_2005_count +
																									user_activity_flags_change_2006_count +
																									user_activity_flags_change_2007_count +
																									user_activity_flags_change_2008_count +
																									user_activity_flags_change_2009_count +
																									user_activity_flags_change_2010_count +
																									user_activity_flags_change_2011_count +
																									user_activity_flags_change_2012_count +
																									user_activity_flags_change_2013_count,

												user_activity_whiteboard_change_all_count		= 	user_activity_whiteboard_change_1998_count +
																									user_activity_whiteboard_change_1999_count +
																									user_activity_whiteboard_change_2000_count +
																									user_activity_whiteboard_change_2001_count +
																									user_activity_whiteboard_change_2002_count +
																									user_activity_whiteboard_change_2003_count +
																									user_activity_whiteboard_change_2004_count +
																									user_activity_whiteboard_change_2005_count +
																									user_activity_whiteboard_change_2006_count +
																									user_activity_whiteboard_change_2007_count +
																									user_activity_whiteboard_change_2008_count +
																									user_activity_whiteboard_change_2009_count +
																									user_activity_whiteboard_change_2010_count +
																									user_activity_whiteboard_change_2011_count +
																									user_activity_whiteboard_change_2012_count +
																									user_activity_whiteboard_change_2013_count,

												user_activity_target_milestone_change_all_count	= 	user_activity_target_milestone_change_1998_count +
																									user_activity_target_milestone_change_1999_count +
																									user_activity_target_milestone_change_2000_count +
																									user_activity_target_milestone_change_2001_count +
																									user_activity_target_milestone_change_2002_count +
																									user_activity_target_milestone_change_2003_count +
																									user_activity_target_milestone_change_2004_count +
																									user_activity_target_milestone_change_2005_count +
																									user_activity_target_milestone_change_2006_count +
																									user_activity_target_milestone_change_2007_count +
																									user_activity_target_milestone_change_2008_count +
																									user_activity_target_milestone_change_2009_count +
																									user_activity_target_milestone_change_2010_count +
																									user_activity_target_milestone_change_2011_count +
																									user_activity_target_milestone_change_2012_count +
																									user_activity_target_milestone_change_2013_count,

												user_activity_description_change_all_count		= 	user_activity_description_change_1998_count +
																									user_activity_description_change_1999_count +
																									user_activity_description_change_2000_count +
																									user_activity_description_change_2001_count +
																									user_activity_description_change_2002_count +
																									user_activity_description_change_2003_count +
																									user_activity_description_change_2004_count +
																									user_activity_description_change_2005_count +
																									user_activity_description_change_2006_count +
																									user_activity_description_change_2007_count +
																									user_activity_description_change_2008_count +
																									user_activity_description_change_2009_count +
																									user_activity_description_change_2010_count +
																									user_activity_description_change_2011_count +
																									user_activity_description_change_2012_count +
																									user_activity_description_change_2013_count,

												user_activity_priority_change_all_count			= 	user_activity_priority_change_1998_count +
																									user_activity_priority_change_1999_count +
																									user_activity_priority_change_2000_count +
																									user_activity_priority_change_2001_count +
																									user_activity_priority_change_2002_count +
																									user_activity_priority_change_2003_count +
																									user_activity_priority_change_2004_count +
																									user_activity_priority_change_2005_count +
																									user_activity_priority_change_2006_count +
																									user_activity_priority_change_2007_count +
																									user_activity_priority_change_2008_count +
																									user_activity_priority_change_2009_count +
																									user_activity_priority_change_2010_count +
																									user_activity_priority_change_2011_count +
																									user_activity_priority_change_2012_count +
																									user_activity_priority_change_2013_count,

												user_activity_severity_change_all_count			= 	user_activity_severity_change_1998_count +
																									user_activity_severity_change_1999_count +
																									user_activity_severity_change_2000_count +
																									user_activity_severity_change_2001_count +
																									user_activity_severity_change_2002_count +
																									user_activity_severity_change_2003_count +
																									user_activity_severity_change_2004_count +
																									user_activity_severity_change_2005_count +
																									user_activity_severity_change_2006_count +
																									user_activity_severity_change_2007_count +
																									user_activity_severity_change_2008_count +
																									user_activity_severity_change_2009_count +
																									user_activity_severity_change_2010_count +
																									user_activity_severity_change_2011_count +
																									user_activity_severity_change_2012_count +
																									user_activity_severity_change_2013_count); 


# Merge the activity_working_types_who_year_recast and profiles_working tables based on who to add the activity type count columns
setkey(activity_working_types_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_working_types_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# Any NA entries mean that that user has no activity of that type and/or year so set it to 0
profiles_working <- mutate(profiles_working, user_activity_cc_change_1998_count					= safe_ifelse(is.na(user_activity_cc_change_1998_count),				0, user_activity_cc_change_1998_count), 	
											 user_activity_cc_change_1999_count					= safe_ifelse(is.na(user_activity_cc_change_1999_count),				0, user_activity_cc_change_1999_count),
											 user_activity_cc_change_2000_count					= safe_ifelse(is.na(user_activity_cc_change_2000_count),				0, user_activity_cc_change_2000_count),
											 user_activity_cc_change_2001_count					= safe_ifelse(is.na(user_activity_cc_change_2001_count),				0, user_activity_cc_change_2001_count),
											 user_activity_cc_change_2002_count					= safe_ifelse(is.na(user_activity_cc_change_2002_count),				0, user_activity_cc_change_2002_count),
											 user_activity_cc_change_2003_count					= safe_ifelse(is.na(user_activity_cc_change_2003_count),				0, user_activity_cc_change_2003_count),
											 user_activity_cc_change_2004_count					= safe_ifelse(is.na(user_activity_cc_change_2004_count),				0, user_activity_cc_change_2004_count),
											 user_activity_cc_change_2005_count					= safe_ifelse(is.na(user_activity_cc_change_2005_count),				0, user_activity_cc_change_2005_count),
											 user_activity_cc_change_2006_count					= safe_ifelse(is.na(user_activity_cc_change_2006_count),				0, user_activity_cc_change_2006_count),
											 user_activity_cc_change_2007_count					= safe_ifelse(is.na(user_activity_cc_change_2007_count),				0, user_activity_cc_change_2007_count),
											 user_activity_cc_change_2008_count					= safe_ifelse(is.na(user_activity_cc_change_2008_count),				0, user_activity_cc_change_2008_count),
											 user_activity_cc_change_2009_count					= safe_ifelse(is.na(user_activity_cc_change_2009_count),				0, user_activity_cc_change_2009_count),		
											 user_activity_cc_change_2010_count					= safe_ifelse(is.na(user_activity_cc_change_2010_count),				0, user_activity_cc_change_2010_count), 	
											 user_activity_cc_change_2011_count                 = safe_ifelse(is.na(user_activity_cc_change_2011_count),				0, user_activity_cc_change_2011_count),
	                                         user_activity_cc_change_2012_count                 = safe_ifelse(is.na(user_activity_cc_change_2012_count),				0, user_activity_cc_change_2012_count),
	                                         user_activity_cc_change_2013_count                 = safe_ifelse(is.na(user_activity_cc_change_2013_count),				0, user_activity_cc_change_2013_count),
	                                         user_activity_cc_change_all_count                  = safe_ifelse(is.na(user_activity_cc_change_all_count), 				0, user_activity_cc_change_all_count),
	                                         user_activity_keywords_change_1998_count           = safe_ifelse(is.na(user_activity_keywords_change_1998_count),			0, user_activity_keywords_change_1998_count),
	                                         user_activity_keywords_change_1999_count           = safe_ifelse(is.na(user_activity_keywords_change_1999_count),			0, user_activity_keywords_change_1999_count),
	                                         user_activity_keywords_change_2000_count           = safe_ifelse(is.na(user_activity_keywords_change_2000_count),			0, user_activity_keywords_change_2000_count),
	                                         user_activity_keywords_change_2001_count           = safe_ifelse(is.na(user_activity_keywords_change_2001_count),			0, user_activity_keywords_change_2001_count),
	                                         user_activity_keywords_change_2002_count           = safe_ifelse(is.na(user_activity_keywords_change_2002_count),			0, user_activity_keywords_change_2002_count),
	                                         user_activity_keywords_change_2003_count           = safe_ifelse(is.na(user_activity_keywords_change_2003_count),			0, user_activity_keywords_change_2003_count),
	                                         user_activity_keywords_change_2004_count           = safe_ifelse(is.na(user_activity_keywords_change_2004_count),			0, user_activity_keywords_change_2004_count),		
	                                         user_activity_keywords_change_2005_count			= safe_ifelse(is.na(user_activity_keywords_change_2005_count),			0, user_activity_keywords_change_2005_count), 	
	                                         user_activity_keywords_change_2006_count           = safe_ifelse(is.na(user_activity_keywords_change_2006_count),			0, user_activity_keywords_change_2006_count),
	                                         user_activity_keywords_change_2007_count           = safe_ifelse(is.na(user_activity_keywords_change_2007_count),			0, user_activity_keywords_change_2007_count),
	                                         user_activity_keywords_change_2008_count           = safe_ifelse(is.na(user_activity_keywords_change_2008_count),			0, user_activity_keywords_change_2008_count),
	                                         user_activity_keywords_change_2009_count           = safe_ifelse(is.na(user_activity_keywords_change_2009_count),			0, user_activity_keywords_change_2009_count),
	                                         user_activity_keywords_change_2010_count           = safe_ifelse(is.na(user_activity_keywords_change_2010_count),			0, user_activity_keywords_change_2010_count),
	                                         user_activity_keywords_change_2011_count           = safe_ifelse(is.na(user_activity_keywords_change_2011_count),			0, user_activity_keywords_change_2011_count),
	                                         user_activity_keywords_change_2012_count           = safe_ifelse(is.na(user_activity_keywords_change_2012_count),			0, user_activity_keywords_change_2012_count),
	                                         user_activity_keywords_change_2013_count           = safe_ifelse(is.na(user_activity_keywords_change_2013_count),			0, user_activity_keywords_change_2013_count),
	                                         user_activity_keywords_change_all_count            = safe_ifelse(is.na(user_activity_keywords_change_all_count), 			0, user_activity_keywords_change_all_count),
	                                         user_activity_product_change_1998_count            = safe_ifelse(is.na(user_activity_product_change_1998_count), 			0, user_activity_product_change_1998_count),
	                                         user_activity_product_change_1999_count            = safe_ifelse(is.na(user_activity_product_change_1999_count), 			0, user_activity_product_change_1999_count),		
	                                         user_activity_product_change_2000_count			= safe_ifelse(is.na(user_activity_product_change_2000_count), 			0, user_activity_product_change_2000_count), 	
	                                         user_activity_product_change_2001_count            = safe_ifelse(is.na(user_activity_product_change_2001_count), 			0, user_activity_product_change_2001_count),
	                                         user_activity_product_change_2002_count            = safe_ifelse(is.na(user_activity_product_change_2002_count), 			0, user_activity_product_change_2002_count),
	                                         user_activity_product_change_2003_count            = safe_ifelse(is.na(user_activity_product_change_2003_count), 			0, user_activity_product_change_2003_count),
	                                         user_activity_product_change_2004_count            = safe_ifelse(is.na(user_activity_product_change_2004_count), 			0, user_activity_product_change_2004_count),
	                                         user_activity_product_change_2005_count            = safe_ifelse(is.na(user_activity_product_change_2005_count), 			0, user_activity_product_change_2005_count),
	                                         user_activity_product_change_2006_count            = safe_ifelse(is.na(user_activity_product_change_2006_count), 			0, user_activity_product_change_2006_count),
	                                         user_activity_product_change_2007_count            = safe_ifelse(is.na(user_activity_product_change_2007_count), 			0, user_activity_product_change_2007_count),
	                                         user_activity_product_change_2008_count            = safe_ifelse(is.na(user_activity_product_change_2008_count),			0, user_activity_product_change_2008_count),
	                                         user_activity_product_change_2009_count            = safe_ifelse(is.na(user_activity_product_change_2009_count), 			0, user_activity_product_change_2009_count),
	                                         user_activity_product_change_2010_count            = safe_ifelse(is.na(user_activity_product_change_2010_count), 			0, user_activity_product_change_2010_count),
	                                         user_activity_product_change_2011_count            = safe_ifelse(is.na(user_activity_product_change_2011_count), 			0, user_activity_product_change_2011_count),		
	                                         user_activity_product_change_2012_count			= safe_ifelse(is.na(user_activity_product_change_2012_count), 			0, user_activity_product_change_2012_count),
	                                         user_activity_product_change_2013_count            = safe_ifelse(is.na(user_activity_product_change_2013_count), 			0, user_activity_product_change_2013_count),
	                                         user_activity_product_change_all_count             = safe_ifelse(is.na(user_activity_product_change_all_count), 			0, user_activity_product_change_all_count),
	                                         user_activity_component_change_1998_count          = safe_ifelse(is.na(user_activity_component_change_1998_count), 		0, user_activity_component_change_1998_count),
	                                         user_activity_component_change_1999_count          = safe_ifelse(is.na(user_activity_component_change_1999_count), 		0, user_activity_component_change_1999_count),
	                                         user_activity_component_change_2000_count          = safe_ifelse(is.na(user_activity_component_change_2000_count), 		0, user_activity_component_change_2000_count),
	                                         user_activity_component_change_2001_count          = safe_ifelse(is.na(user_activity_component_change_2001_count), 		0, user_activity_component_change_2001_count),
	                                         user_activity_component_change_2002_count          = safe_ifelse(is.na(user_activity_component_change_2002_count), 		0, user_activity_component_change_2002_count),
	                                         user_activity_component_change_2003_count          = safe_ifelse(is.na(user_activity_component_change_2003_count),			0, user_activity_component_change_2003_count),
	                                         user_activity_component_change_2004_count          = safe_ifelse(is.na(user_activity_component_change_2004_count), 		0, user_activity_component_change_2004_count),
	                                         user_activity_component_change_2005_count          = safe_ifelse(is.na(user_activity_component_change_2005_count), 		0, user_activity_component_change_2005_count),
	                                         user_activity_component_change_2006_count          = safe_ifelse(is.na(user_activity_component_change_2006_count), 		0, user_activity_component_change_2006_count),
	                                         user_activity_component_change_2007_count          = safe_ifelse(is.na(user_activity_component_change_2007_count), 		0, user_activity_component_change_2007_count),
	                                         user_activity_component_change_2008_count          = safe_ifelse(is.na(user_activity_component_change_2008_count), 		0, user_activity_component_change_2008_count),
	                                         user_activity_component_change_2009_count          = safe_ifelse(is.na(user_activity_component_change_2009_count), 		0, user_activity_component_change_2009_count),
	                                         user_activity_component_change_2010_count          = safe_ifelse(is.na(user_activity_component_change_2010_count), 		0, user_activity_component_change_2010_count),
	                                         user_activity_component_change_2011_count          = safe_ifelse(is.na(user_activity_component_change_2011_count), 		0, user_activity_component_change_2011_count),
	                                         user_activity_component_change_2012_count          = safe_ifelse(is.na(user_activity_component_change_2012_count), 		0, user_activity_component_change_2012_count),
	                                         user_activity_component_change_2013_count          = safe_ifelse(is.na(user_activity_component_change_2013_count), 		0, user_activity_component_change_2013_count),
	                                         user_activity_component_change_all_count           = safe_ifelse(is.na(user_activity_component_change_all_count), 			0, user_activity_component_change_all_count),
	                                         user_activity_status_change_1998_count             = safe_ifelse(is.na(user_activity_status_change_1998_count),			0, user_activity_status_change_1998_count),
	                                         user_activity_status_change_1999_count             = safe_ifelse(is.na(user_activity_status_change_1999_count), 			0, user_activity_status_change_1999_count),
	                                         user_activity_status_change_2000_count             = safe_ifelse(is.na(user_activity_status_change_2000_count), 			0, user_activity_status_change_2000_count),
	                                         user_activity_status_change_2001_count             = safe_ifelse(is.na(user_activity_status_change_2001_count), 			0, user_activity_status_change_2001_count),
	                                         user_activity_status_change_2002_count             = safe_ifelse(is.na(user_activity_status_change_2002_count), 			0, user_activity_status_change_2002_count),
	                                         user_activity_status_change_2003_count             = safe_ifelse(is.na(user_activity_status_change_2003_count), 			0, user_activity_status_change_2003_count),
	                                         user_activity_status_change_2004_count             = safe_ifelse(is.na(user_activity_status_change_2004_count), 			0, user_activity_status_change_2004_count),
	                                         user_activity_status_change_2005_count             = safe_ifelse(is.na(user_activity_status_change_2005_count), 			0, user_activity_status_change_2005_count),
	                                         user_activity_status_change_2006_count             = safe_ifelse(is.na(user_activity_status_change_2006_count), 			0, user_activity_status_change_2006_count),
	                                         user_activity_status_change_2007_count             = safe_ifelse(is.na(user_activity_status_change_2007_count), 			0, user_activity_status_change_2007_count),
	                                         user_activity_status_change_2008_count             = safe_ifelse(is.na(user_activity_status_change_2008_count), 			0, user_activity_status_change_2008_count),
	                                         user_activity_status_change_2009_count             = safe_ifelse(is.na(user_activity_status_change_2009_count), 			0, user_activity_status_change_2009_count),
	                                         user_activity_status_change_2010_count             = safe_ifelse(is.na(user_activity_status_change_2010_count),			0, user_activity_status_change_2010_count),
	                                         user_activity_status_change_2011_count             = safe_ifelse(is.na(user_activity_status_change_2011_count), 			0, user_activity_status_change_2011_count),
	                                         user_activity_status_change_2012_count             = safe_ifelse(is.na(user_activity_status_change_2012_count), 			0, user_activity_status_change_2012_count),
	                                         user_activity_status_change_2013_count             = safe_ifelse(is.na(user_activity_status_change_2013_count), 			0, user_activity_status_change_2013_count),
	                                         user_activity_status_change_all_count              = safe_ifelse(is.na(user_activity_status_change_all_count), 			0, user_activity_status_change_all_count),
	                                         user_activity_resolution_change_1998_count         = safe_ifelse(is.na(user_activity_resolution_change_1998_count),		0, user_activity_resolution_change_1998_count),
	                                         user_activity_resolution_change_1999_count         = safe_ifelse(is.na(user_activity_resolution_change_1999_count),		0, user_activity_resolution_change_1999_count),
	                                         user_activity_resolution_change_2000_count         = safe_ifelse(is.na(user_activity_resolution_change_2000_count),		0, user_activity_resolution_change_2000_count),
	                                         user_activity_resolution_change_2001_count         = safe_ifelse(is.na(user_activity_resolution_change_2001_count),		0, user_activity_resolution_change_2001_count),
	                                         user_activity_resolution_change_2002_count         = safe_ifelse(is.na(user_activity_resolution_change_2002_count),		0, user_activity_resolution_change_2002_count),
	                                         user_activity_resolution_change_2003_count         = safe_ifelse(is.na(user_activity_resolution_change_2003_count),		0, user_activity_resolution_change_2003_count),
	                                         user_activity_resolution_change_2004_count         = safe_ifelse(is.na(user_activity_resolution_change_2004_count),		0, user_activity_resolution_change_2004_count),
	                                         user_activity_resolution_change_2005_count         = safe_ifelse(is.na(user_activity_resolution_change_2005_count),		0, user_activity_resolution_change_2005_count),
	                                         user_activity_resolution_change_2006_count         = safe_ifelse(is.na(user_activity_resolution_change_2006_count),		0, user_activity_resolution_change_2006_count),
	                                         user_activity_resolution_change_2007_count         = safe_ifelse(is.na(user_activity_resolution_change_2007_count),		0, user_activity_resolution_change_2007_count),
	                                         user_activity_resolution_change_2008_count         = safe_ifelse(is.na(user_activity_resolution_change_2008_count),		0, user_activity_resolution_change_2008_count),
	                                         user_activity_resolution_change_2009_count			= safe_ifelse(is.na(user_activity_resolution_change_2009_count),		0, user_activity_resolution_change_2009_count),
	                                         user_activity_resolution_change_2010_count         = safe_ifelse(is.na(user_activity_resolution_change_2010_count),		0, user_activity_resolution_change_2010_count),
	                                         user_activity_resolution_change_2011_count         = safe_ifelse(is.na(user_activity_resolution_change_2011_count),		0, user_activity_resolution_change_2011_count),
	                                         user_activity_resolution_change_2012_count         = safe_ifelse(is.na(user_activity_resolution_change_2012_count),		0, user_activity_resolution_change_2012_count),
	                                         user_activity_resolution_change_2013_count         = safe_ifelse(is.na(user_activity_resolution_change_2013_count),		0, user_activity_resolution_change_2013_count),
	                                         user_activity_resolution_change_all_count          = safe_ifelse(is.na(user_activity_resolution_change_all_count), 		0, user_activity_resolution_change_all_count),
	                                         user_activity_flags_change_1998_count              = safe_ifelse(is.na(user_activity_flags_change_1998_count), 			0, user_activity_flags_change_1998_count),
	                                         user_activity_flags_change_1999_count              = safe_ifelse(is.na(user_activity_flags_change_1999_count), 			0, user_activity_flags_change_1999_count),
	                                         user_activity_flags_change_2000_count              = safe_ifelse(is.na(user_activity_flags_change_2000_count),				0, user_activity_flags_change_2000_count),
	                                         user_activity_flags_change_2001_count              = safe_ifelse(is.na(user_activity_flags_change_2001_count), 			0, user_activity_flags_change_2001_count),
	                                         user_activity_flags_change_2002_count              = safe_ifelse(is.na(user_activity_flags_change_2002_count), 			0, user_activity_flags_change_2002_count),
	                                         user_activity_flags_change_2003_count              = safe_ifelse(is.na(user_activity_flags_change_2003_count), 			0, user_activity_flags_change_2003_count),
	                                         user_activity_flags_change_2004_count              = safe_ifelse(is.na(user_activity_flags_change_2004_count), 			0, user_activity_flags_change_2004_count),
	                                         user_activity_flags_change_2005_count              = safe_ifelse(is.na(user_activity_flags_change_2005_count), 			0, user_activity_flags_change_2005_count),
	                                         user_activity_flags_change_2006_count              = safe_ifelse(is.na(user_activity_flags_change_2006_count), 			0, user_activity_flags_change_2006_count),
	                                         user_activity_flags_change_2007_count              = safe_ifelse(is.na(user_activity_flags_change_2007_count), 			0, user_activity_flags_change_2007_count),
	                                         user_activity_flags_change_2008_count              = safe_ifelse(is.na(user_activity_flags_change_2008_count), 			0, user_activity_flags_change_2008_count),
	                                         user_activity_flags_change_2009_count              = safe_ifelse(is.na(user_activity_flags_change_2009_count), 			0, user_activity_flags_change_2009_count),
	                                         user_activity_flags_change_2010_count              = safe_ifelse(is.na(user_activity_flags_change_2010_count), 			0, user_activity_flags_change_2010_count),
	                                         user_activity_flags_change_2011_count              = safe_ifelse(is.na(user_activity_flags_change_2011_count), 			0, user_activity_flags_change_2011_count),
	                                         user_activity_flags_change_2012_count              = safe_ifelse(is.na(user_activity_flags_change_2012_count),				0, user_activity_flags_change_2012_count),
	                                         user_activity_flags_change_2013_count              = safe_ifelse(is.na(user_activity_flags_change_2013_count), 			0, user_activity_flags_change_2013_count),
	                                         user_activity_flags_change_all_count               = safe_ifelse(is.na(user_activity_flags_change_all_count), 				0, user_activity_flags_change_all_count),
	                                         user_activity_whiteboard_change_1998_count         = safe_ifelse(is.na(user_activity_whiteboard_change_1998_count),		0, user_activity_whiteboard_change_1998_count),
	                                         user_activity_whiteboard_change_1999_count         = safe_ifelse(is.na(user_activity_whiteboard_change_1999_count),		0, user_activity_whiteboard_change_1999_count),
	                                         user_activity_whiteboard_change_2000_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2000_count),		0, user_activity_whiteboard_change_2000_count),
	                                         user_activity_whiteboard_change_2001_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2001_count),		0, user_activity_whiteboard_change_2001_count),
	                                         user_activity_whiteboard_change_2002_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2002_count),		0, user_activity_whiteboard_change_2002_count),
	                                         user_activity_whiteboard_change_2003_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2003_count),		0, user_activity_whiteboard_change_2003_count),
	                                         user_activity_whiteboard_change_2004_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2004_count),		0, user_activity_whiteboard_change_2004_count),
	                                         user_activity_whiteboard_change_2005_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2005_count),		0, user_activity_whiteboard_change_2005_count),
	                                         user_activity_whiteboard_change_2006_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2006_count),		0, user_activity_whiteboard_change_2006_count),
	                                         user_activity_whiteboard_change_2007_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2007_count),		0, user_activity_whiteboard_change_2007_count),
	                                         user_activity_whiteboard_change_2008_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2008_count),		0, user_activity_whiteboard_change_2008_count),
	                                         user_activity_whiteboard_change_2009_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2009_count),		0, user_activity_whiteboard_change_2009_count),
	                                         user_activity_whiteboard_change_2010_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2010_count),		0, user_activity_whiteboard_change_2010_count),
	                                         user_activity_whiteboard_change_2011_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2011_count),		0, user_activity_whiteboard_change_2011_count),
	                                         user_activity_whiteboard_change_2012_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2012_count),		0, user_activity_whiteboard_change_2012_count),
	                                         user_activity_whiteboard_change_2013_count         = safe_ifelse(is.na(user_activity_whiteboard_change_2013_count),		0, user_activity_whiteboard_change_2013_count),
	                                         user_activity_whiteboard_change_all_count          = safe_ifelse(is.na(user_activity_whiteboard_change_all_count), 		0, user_activity_whiteboard_change_all_count),
	                                         user_activity_target_milestone_change_1998_count   = safe_ifelse(is.na(user_activity_target_milestone_change_1998_count), 	0, user_activity_target_milestone_change_1998_count),
	                                         user_activity_target_milestone_change_1999_count   = safe_ifelse(is.na(user_activity_target_milestone_change_1999_count), 	0, user_activity_target_milestone_change_1999_count),
	                                         user_activity_target_milestone_change_2000_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2000_count), 	0, user_activity_target_milestone_change_2000_count),
	                                         user_activity_target_milestone_change_2001_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2001_count), 	0, user_activity_target_milestone_change_2001_count),
	                                         user_activity_target_milestone_change_2002_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2002_count),	0, user_activity_target_milestone_change_2002_count),
	                                         user_activity_target_milestone_change_2003_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2003_count), 	0, user_activity_target_milestone_change_2003_count),
	                                         user_activity_target_milestone_change_2004_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2004_count), 	0, user_activity_target_milestone_change_2004_count),
	                                         user_activity_target_milestone_change_2005_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2005_count), 	0, user_activity_target_milestone_change_2005_count),
	                                         user_activity_target_milestone_change_2006_count	= safe_ifelse(is.na(user_activity_target_milestone_change_2006_count), 	0, user_activity_target_milestone_change_2006_count),
	                                         user_activity_target_milestone_change_2007_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2007_count), 	0, user_activity_target_milestone_change_2007_count),
	                                         user_activity_target_milestone_change_2008_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2008_count), 	0, user_activity_target_milestone_change_2008_count),
	                                         user_activity_target_milestone_change_2009_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2009_count), 	0, user_activity_target_milestone_change_2009_count),
	                                         user_activity_target_milestone_change_2010_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2010_count), 	0, user_activity_target_milestone_change_2010_count),
	                                         user_activity_target_milestone_change_2011_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2011_count), 	0, user_activity_target_milestone_change_2011_count),
	                                         user_activity_target_milestone_change_2012_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2012_count), 	0, user_activity_target_milestone_change_2012_count),
	                                         user_activity_target_milestone_change_2013_count   = safe_ifelse(is.na(user_activity_target_milestone_change_2013_count), 	0, user_activity_target_milestone_change_2013_count),
	                                         user_activity_target_milestone_change_all_count    = safe_ifelse(is.na(user_activity_target_milestone_change_all_count),	0, user_activity_target_milestone_change_all_count),
	                                         user_activity_description_change_1998_count        = safe_ifelse(is.na(user_activity_description_change_1998_count), 		0, user_activity_description_change_1998_count),
	                                         user_activity_description_change_1999_count        = safe_ifelse(is.na(user_activity_description_change_1999_count), 		0, user_activity_description_change_1999_count),
	                                         user_activity_description_change_2000_count        = safe_ifelse(is.na(user_activity_description_change_2000_count), 		0, user_activity_description_change_2000_count),
	                                         user_activity_description_change_2001_count        = safe_ifelse(is.na(user_activity_description_change_2001_count), 		0, user_activity_description_change_2001_count),
	                                         user_activity_description_change_2002_count        = safe_ifelse(is.na(user_activity_description_change_2002_count), 		0, user_activity_description_change_2002_count),
	                                         user_activity_description_change_2003_count        = safe_ifelse(is.na(user_activity_description_change_2003_count), 		0, user_activity_description_change_2003_count),
	                                         user_activity_description_change_2004_count        = safe_ifelse(is.na(user_activity_description_change_2004_count), 		0, user_activity_description_change_2004_count),
	                                         user_activity_description_change_2005_count        = safe_ifelse(is.na(user_activity_description_change_2005_count), 		0, user_activity_description_change_2005_count),
	                                         user_activity_description_change_2006_count        = safe_ifelse(is.na(user_activity_description_change_2006_count), 		0, user_activity_description_change_2006_count),
	                                         user_activity_description_change_2007_count        = safe_ifelse(is.na(user_activity_description_change_2007_count), 		0, user_activity_description_change_2007_count),
	                                         user_activity_description_change_2008_count        = safe_ifelse(is.na(user_activity_description_change_2008_count), 		0, user_activity_description_change_2008_count),
	                                         user_activity_description_change_2009_count        = safe_ifelse(is.na(user_activity_description_change_2009_count),		0, user_activity_description_change_2009_count),
	                                         user_activity_description_change_2010_count        = safe_ifelse(is.na(user_activity_description_change_2010_count), 		0, user_activity_description_change_2010_count),
	                                         user_activity_description_change_2011_count        = safe_ifelse(is.na(user_activity_description_change_2011_count), 		0, user_activity_description_change_2011_count),
	                                         user_activity_description_change_2012_count        = safe_ifelse(is.na(user_activity_description_change_2012_count), 		0, user_activity_description_change_2012_count),
	                                         user_activity_description_change_2013_count        = safe_ifelse(is.na(user_activity_description_change_2013_count), 		0, user_activity_description_change_2013_count),
	                                         user_activity_description_change_all_count         = safe_ifelse(is.na(user_activity_description_change_all_count), 		0, user_activity_description_change_all_count),
	                                         user_activity_priority_change_1998_count           = safe_ifelse(is.na(user_activity_priority_change_1998_count), 			0, user_activity_priority_change_1998_count),
	                                         user_activity_priority_change_1999_count           = safe_ifelse(is.na(user_activity_priority_change_1999_count), 			0, user_activity_priority_change_1999_count),
	                                         user_activity_priority_change_2000_count           = safe_ifelse(is.na(user_activity_priority_change_2000_count), 			0, user_activity_priority_change_2000_count),
	                                         user_activity_priority_change_2001_count           = safe_ifelse(is.na(user_activity_priority_change_2001_count), 			0, user_activity_priority_change_2001_count),
	                                         user_activity_priority_change_2002_count           = safe_ifelse(is.na(user_activity_priority_change_2002_count), 			0, user_activity_priority_change_2002_count),
	                                         user_activity_priority_change_2003_count           = safe_ifelse(is.na(user_activity_priority_change_2003_count), 			0, user_activity_priority_change_2003_count),
	                                         user_activity_priority_change_2004_count           = safe_ifelse(is.na(user_activity_priority_change_2004_count),			0, user_activity_priority_change_2004_count),
	                                         user_activity_priority_change_2005_count           = safe_ifelse(is.na(user_activity_priority_change_2005_count), 			0, user_activity_priority_change_2005_count),
	                                         user_activity_priority_change_2006_count           = safe_ifelse(is.na(user_activity_priority_change_2006_count), 			0, user_activity_priority_change_2006_count),
	                                         user_activity_priority_change_2007_count           = safe_ifelse(is.na(user_activity_priority_change_2007_count), 			0, user_activity_priority_change_2007_count),
	                                         user_activity_priority_change_2008_count           = safe_ifelse(is.na(user_activity_priority_change_2008_count), 			0, user_activity_priority_change_2008_count),
	                                         user_activity_priority_change_2009_count           = safe_ifelse(is.na(user_activity_priority_change_2009_count), 			0, user_activity_priority_change_2009_count),
	                                         user_activity_priority_change_2010_count           = safe_ifelse(is.na(user_activity_priority_change_2010_count), 			0, user_activity_priority_change_2010_count),
	                                         user_activity_priority_change_2011_count           = safe_ifelse(is.na(user_activity_priority_change_2011_count), 			0, user_activity_priority_change_2011_count),
	                                         user_activity_priority_change_2012_count           = safe_ifelse(is.na(user_activity_priority_change_2012_count), 			0, user_activity_priority_change_2012_count),
	                                         user_activity_priority_change_2013_count           = safe_ifelse(is.na(user_activity_priority_change_2013_count), 			0, user_activity_priority_change_2013_count),
	                                         user_activity_priority_change_all_count            = safe_ifelse(is.na(user_activity_priority_change_all_count), 			0, user_activity_priority_change_all_count),
	                                         user_activity_severity_change_1998_count           = safe_ifelse(is.na(user_activity_severity_change_1998_count), 			0, user_activity_severity_change_1998_count),
	                                         user_activity_severity_change_1999_count           = safe_ifelse(is.na(user_activity_severity_change_1999_count),			0, user_activity_severity_change_1999_count),
	                                         user_activity_severity_change_2000_count           = safe_ifelse(is.na(user_activity_severity_change_2000_count), 			0, user_activity_severity_change_2000_count),
	                                         user_activity_severity_change_2001_count           = safe_ifelse(is.na(user_activity_severity_change_2001_count), 			0, user_activity_severity_change_2001_count),
	                                         user_activity_severity_change_2002_count           = safe_ifelse(is.na(user_activity_severity_change_2002_count), 			0, user_activity_severity_change_2002_count),
	                                         user_activity_severity_change_2003_count			= safe_ifelse(is.na(user_activity_severity_change_2003_count), 			0, user_activity_severity_change_2003_count),
	                                         user_activity_severity_change_2004_count           = safe_ifelse(is.na(user_activity_severity_change_2004_count), 			0, user_activity_severity_change_2004_count),
	                                         user_activity_severity_change_2005_count           = safe_ifelse(is.na(user_activity_severity_change_2005_count), 			0, user_activity_severity_change_2005_count),
	                                         user_activity_severity_change_2006_count           = safe_ifelse(is.na(user_activity_severity_change_2006_count), 			0, user_activity_severity_change_2006_count),
	                                         user_activity_severity_change_2007_count           = safe_ifelse(is.na(user_activity_severity_change_2007_count), 			0, user_activity_severity_change_2007_count),
	                                         user_activity_severity_change_2008_count           = safe_ifelse(is.na(user_activity_severity_change_2008_count), 			0, user_activity_severity_change_2008_count),
	                                         user_activity_severity_change_2009_count           = safe_ifelse(is.na(user_activity_severity_change_2009_count), 			0, user_activity_severity_change_2009_count),
	                                         user_activity_severity_change_2010_count           = safe_ifelse(is.na(user_activity_severity_change_2010_count), 			0, user_activity_severity_change_2010_count),
	                                         user_activity_severity_change_2011_count           = safe_ifelse(is.na(user_activity_severity_change_2011_count), 			0, user_activity_severity_change_2011_count),
	                                         user_activity_severity_change_2012_count           = safe_ifelse(is.na(user_activity_severity_change_2012_count),			0, user_activity_severity_change_2012_count),
	                                         user_activity_severity_change_2013_count           = safe_ifelse(is.na(user_activity_severity_change_2013_count), 			0, user_activity_severity_change_2013_count),
	                                         user_activity_severity_change_all_count            = safe_ifelse(is.na(user_activity_severity_change_all_count), 			0, user_activity_severity_change_all_count));
	                                                                                            

# PROFILES-ACTIVITY_USER_ASSIGNING_YEAR
# (Track how many times each user has done the activity of assigning a bug per year)

# Assigning a bug is defined as an activity with one of the changes of fieldid 29 (bug status) as follows:
activity_working_assigning <- filter(activity_base, (removed=="NEW"			& added=="ASSIGNED"		& fieldid==29) |
													(removed=="REOPENED"	& added=="ASSIGNED"		& fieldid==29) |
													(removed=="UNCONFIRMED"	& added=="ASSIGNED"		& fieldid==29) |
													(removed=="VERIFIED" 	& added=="ASSIGNED" 	& fieldid==29) |
													(removed=="RESOLVED" 	& added=="ASSIGNED"		& fieldid==29));

# We only need the user ("who") and year of the bug_when column, so drop the rest.
activity_working_assigning_who_year <- transmute(activity_working_assigning, who = who, bug_when_year = format(bug_when, format='%Y'));


# Use data.table's dcast() function to recast the table such that each row is a single user and there is
# a column for each field_id that is the sum of activities in each year for each user
activity_working_assigning_who_year_recast <- dcast(activity_working_assigning_who_year, who ~ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_working_assigning_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(activity_working_assigning_who_year_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns to our desired names
# We also need to check if all columns exist since not all years might show up
activity_working_assigning_who_year_recast <- transmute(activity_working_assigning_who_year_recast, who 							   = who,
																									user_activity_assigning_1998_count = if (exists('arg1998', where = activity_working_assigning_who_year_recast)) arg1998 else 0,
																									user_activity_assigning_1999_count = if (exists('arg1999', where = activity_working_assigning_who_year_recast)) arg1999 else 0,
																									user_activity_assigning_2000_count = if (exists('arg2000', where = activity_working_assigning_who_year_recast)) arg2000 else 0,
																									user_activity_assigning_2001_count = if (exists('arg2001', where = activity_working_assigning_who_year_recast)) arg2001 else 0,
																									user_activity_assigning_2002_count = if (exists('arg2002', where = activity_working_assigning_who_year_recast)) arg2002 else 0,
																									user_activity_assigning_2003_count = if (exists('arg2003', where = activity_working_assigning_who_year_recast)) arg2003 else 0,
																									user_activity_assigning_2004_count = if (exists('arg2004', where = activity_working_assigning_who_year_recast)) arg2004 else 0,
																									user_activity_assigning_2005_count = if (exists('arg2005', where = activity_working_assigning_who_year_recast)) arg2005 else 0,
																									user_activity_assigning_2006_count = if (exists('arg2006', where = activity_working_assigning_who_year_recast)) arg2006 else 0,
																									user_activity_assigning_2007_count = if (exists('arg2007', where = activity_working_assigning_who_year_recast)) arg2007 else 0,
																									user_activity_assigning_2008_count = if (exists('arg2008', where = activity_working_assigning_who_year_recast)) arg2008 else 0,
																									user_activity_assigning_2009_count = if (exists('arg2009', where = activity_working_assigning_who_year_recast)) arg2009 else 0,
																									user_activity_assigning_2010_count = if (exists('arg2010', where = activity_working_assigning_who_year_recast)) arg2010 else 0,
																									user_activity_assigning_2011_count = if (exists('arg2011', where = activity_working_assigning_who_year_recast)) arg2011 else 0,
																									user_activity_assigning_2012_count = if (exists('arg2012', where = activity_working_assigning_who_year_recast)) arg2012 else 0,
																									user_activity_assigning_2013_count = if (exists('arg2013', where = activity_working_assigning_who_year_recast)) arg2013 else 0);

# Sum the yearly counts to get all activity of that type for each user 																									
activity_working_assigning_who_year_recast <- mutate(activity_working_assigning_who_year_recast, user_activity_assigning_all_count  = 	user_activity_assigning_1998_count +
																																		user_activity_assigning_1999_count +
																																		user_activity_assigning_2000_count +
																																		user_activity_assigning_2001_count +
																																		user_activity_assigning_2002_count +
																																		user_activity_assigning_2003_count +
																																		user_activity_assigning_2004_count +
																																		user_activity_assigning_2005_count +
																																		user_activity_assigning_2006_count +
																																		user_activity_assigning_2007_count +
																																		user_activity_assigning_2008_count +
																																		user_activity_assigning_2009_count +
																																		user_activity_assigning_2010_count +
																																		user_activity_assigning_2011_count +
																																		user_activity_assigning_2012_count +
																																		user_activity_assigning_2013_count); 

# Merge the "activity_working_assigning_who_year_recast" table with the profiles table according to "who" and "userid"
setkey(activity_working_assigning_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_working_assigning_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries that means the user did no reassigning activities, so set it to 0
profiles_working <- mutate(profiles_working, user_activity_assigning_1998_count = safe_ifelse(is.na(user_activity_assigning_1998_count), 0, user_activity_assigning_1998_count),
                                             user_activity_assigning_1999_count = safe_ifelse(is.na(user_activity_assigning_1999_count), 0, user_activity_assigning_1999_count),
                                             user_activity_assigning_2000_count = safe_ifelse(is.na(user_activity_assigning_2000_count), 0, user_activity_assigning_2000_count),
                                             user_activity_assigning_2001_count = safe_ifelse(is.na(user_activity_assigning_2001_count), 0, user_activity_assigning_2001_count),
                                             user_activity_assigning_2002_count = safe_ifelse(is.na(user_activity_assigning_2002_count), 0, user_activity_assigning_2002_count),
                                             user_activity_assigning_2003_count = safe_ifelse(is.na(user_activity_assigning_2003_count), 0, user_activity_assigning_2003_count),
                                             user_activity_assigning_2004_count = safe_ifelse(is.na(user_activity_assigning_2004_count), 0, user_activity_assigning_2004_count),
                                             user_activity_assigning_2005_count = safe_ifelse(is.na(user_activity_assigning_2005_count), 0, user_activity_assigning_2005_count),
                                             user_activity_assigning_2006_count = safe_ifelse(is.na(user_activity_assigning_2006_count), 0, user_activity_assigning_2006_count),
                                             user_activity_assigning_2007_count = safe_ifelse(is.na(user_activity_assigning_2007_count), 0, user_activity_assigning_2007_count),
                                             user_activity_assigning_2008_count = safe_ifelse(is.na(user_activity_assigning_2008_count), 0, user_activity_assigning_2008_count),
                                             user_activity_assigning_2009_count = safe_ifelse(is.na(user_activity_assigning_2009_count), 0, user_activity_assigning_2009_count),
                                             user_activity_assigning_2010_count = safe_ifelse(is.na(user_activity_assigning_2010_count), 0, user_activity_assigning_2010_count),
                                             user_activity_assigning_2011_count = safe_ifelse(is.na(user_activity_assigning_2011_count), 0, user_activity_assigning_2011_count),
                                             user_activity_assigning_2012_count = safe_ifelse(is.na(user_activity_assigning_2012_count), 0, user_activity_assigning_2012_count),
                                             user_activity_assigning_2013_count = safe_ifelse(is.na(user_activity_assigning_2013_count), 0, user_activity_assigning_2013_count),
                                             user_activity_assigning_all_count	= safe_ifelse(is.na(user_activity_assigning_all_count ), 0, user_activity_assigning_all_count ));


# PROFILES-ACTIVITY_USER_REASSIGNING_YEAR
# (Track how many times each user has done the activity of reassigning a bug per year)

# Reassigning a bug is defined as an activity with one of the changes of fieldid 29 (bug status) as follows:
activity_working_reassigning <- filter(activity_base, 	(removed=="REOPENED"	& added=="NEW"			& fieldid==29) |
														(removed=="REOPENED"	& added=="UNCONFIRMED"	& fieldid==29) |
														(removed=="VERIFIED"	& added=="RESOLVED"		& fieldid==29) |
														(removed=="ASSIGNED"	& added=="NEW" 			& fieldid==29) |
														(removed=="ASSIGNED"	& added=="UNCONFIRMED" 	& fieldid==29) |
														(removed=="ASSIGNED"	& added=="REOPENED"		& fieldid==29));

# We only need the user ("who") and year of the bug_when column, so drop the rest.
activity_working_reassigning_who_year <- transmute(activity_working_reassigning, who = who, bug_when_year = format(bug_when, format='%Y'));


# Use data.table's dcast() function to recast the table such that each row is a single user and there is
# a column for each field_id that is the sum of activities in each year for each user
activity_working_reassigning_who_year_recast <- dcast(activity_working_reassigning_who_year, who ~ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_working_reassigning_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(activity_working_reassigning_who_year_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns to our desired names
activity_working_reassigning_who_year_recast <- transmute(activity_working_reassigning_who_year_recast, who 							 	 = who,
																										user_activity_reassigning_1998_count = if (exists('arg1998', where = activity_working_reassigning_who_year_recast)) arg1998 else 0,
																										user_activity_reassigning_1999_count = if (exists('arg1999', where = activity_working_reassigning_who_year_recast)) arg1999 else 0,
																										user_activity_reassigning_2000_count = if (exists('arg2000', where = activity_working_reassigning_who_year_recast)) arg2000 else 0,
																										user_activity_reassigning_2001_count = if (exists('arg2001', where = activity_working_reassigning_who_year_recast)) arg2001 else 0,
																										user_activity_reassigning_2002_count = if (exists('arg2002', where = activity_working_reassigning_who_year_recast)) arg2002 else 0,
																										user_activity_reassigning_2003_count = if (exists('arg2003', where = activity_working_reassigning_who_year_recast)) arg2003 else 0,
																										user_activity_reassigning_2004_count = if (exists('arg2004', where = activity_working_reassigning_who_year_recast)) arg2004 else 0,
																										user_activity_reassigning_2005_count = if (exists('arg2005', where = activity_working_reassigning_who_year_recast)) arg2005 else 0,
																										user_activity_reassigning_2006_count = if (exists('arg2006', where = activity_working_reassigning_who_year_recast)) arg2006 else 0,
																										user_activity_reassigning_2007_count = if (exists('arg2007', where = activity_working_reassigning_who_year_recast)) arg2007 else 0,
																										user_activity_reassigning_2008_count = if (exists('arg2008', where = activity_working_reassigning_who_year_recast)) arg2008 else 0,
																										user_activity_reassigning_2009_count = if (exists('arg2009', where = activity_working_reassigning_who_year_recast)) arg2009 else 0,
																										user_activity_reassigning_2010_count = if (exists('arg2010', where = activity_working_reassigning_who_year_recast)) arg2010 else 0,
																										user_activity_reassigning_2011_count = if (exists('arg2011', where = activity_working_reassigning_who_year_recast)) arg2011 else 0,
																										user_activity_reassigning_2012_count = if (exists('arg2012', where = activity_working_reassigning_who_year_recast)) arg2012 else 0,
																										user_activity_reassigning_2013_count = if (exists('arg2013', where = activity_working_reassigning_who_year_recast)) arg2013 else 0);
																										
activity_working_reassigning_who_year_recast <- mutate(activity_working_reassigning_who_year_recast, user_activity_reassigning_all_count = 	user_activity_reassigning_1998_count +
																																			user_activity_reassigning_1999_count +
																																			user_activity_reassigning_2000_count +
																																			user_activity_reassigning_2001_count +
																																			user_activity_reassigning_2002_count +
																																			user_activity_reassigning_2003_count +
																																			user_activity_reassigning_2004_count +
																																			user_activity_reassigning_2005_count +
																																			user_activity_reassigning_2006_count +
																																			user_activity_reassigning_2007_count +
																																			user_activity_reassigning_2008_count +
																																			user_activity_reassigning_2009_count +
																																			user_activity_reassigning_2010_count +
																																			user_activity_reassigning_2011_count +
																																			user_activity_reassigning_2012_count +
																																			user_activity_reassigning_2013_count); 

# Merge the "activity_working_reassigning_who_year_recast" table with the profiles table according to "who" and "userid"
setkey(activity_working_reassigning_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_working_reassigning_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries that means the user did no rereassigning activities, so set it to 0
profiles_working <- mutate(profiles_working, user_activity_reassigning_1998_count = safe_ifelse(is.na(user_activity_reassigning_1998_count), 0, user_activity_reassigning_1998_count),
                                             user_activity_reassigning_1999_count = safe_ifelse(is.na(user_activity_reassigning_1999_count), 0, user_activity_reassigning_1999_count),
                                             user_activity_reassigning_2000_count = safe_ifelse(is.na(user_activity_reassigning_2000_count), 0, user_activity_reassigning_2000_count),
                                             user_activity_reassigning_2001_count = safe_ifelse(is.na(user_activity_reassigning_2001_count), 0, user_activity_reassigning_2001_count),
                                             user_activity_reassigning_2002_count = safe_ifelse(is.na(user_activity_reassigning_2002_count), 0, user_activity_reassigning_2002_count),
                                             user_activity_reassigning_2003_count = safe_ifelse(is.na(user_activity_reassigning_2003_count), 0, user_activity_reassigning_2003_count),
                                             user_activity_reassigning_2004_count = safe_ifelse(is.na(user_activity_reassigning_2004_count), 0, user_activity_reassigning_2004_count),
                                             user_activity_reassigning_2005_count = safe_ifelse(is.na(user_activity_reassigning_2005_count), 0, user_activity_reassigning_2005_count),
                                             user_activity_reassigning_2006_count = safe_ifelse(is.na(user_activity_reassigning_2006_count), 0, user_activity_reassigning_2006_count),
                                             user_activity_reassigning_2007_count = safe_ifelse(is.na(user_activity_reassigning_2007_count), 0, user_activity_reassigning_2007_count),
                                             user_activity_reassigning_2008_count = safe_ifelse(is.na(user_activity_reassigning_2008_count), 0, user_activity_reassigning_2008_count),
                                             user_activity_reassigning_2009_count = safe_ifelse(is.na(user_activity_reassigning_2009_count), 0, user_activity_reassigning_2009_count),
                                             user_activity_reassigning_2010_count = safe_ifelse(is.na(user_activity_reassigning_2010_count), 0, user_activity_reassigning_2010_count),
                                             user_activity_reassigning_2011_count = safe_ifelse(is.na(user_activity_reassigning_2011_count), 0, user_activity_reassigning_2011_count),
                                             user_activity_reassigning_2012_count = safe_ifelse(is.na(user_activity_reassigning_2012_count), 0, user_activity_reassigning_2012_count),
                                             user_activity_reassigning_2013_count = safe_ifelse(is.na(user_activity_reassigning_2013_count), 0, user_activity_reassigning_2013_count),
                                             user_activity_reassigning_all_count  = safe_ifelse(is.na(user_activity_reassigning_all_count ), 0, user_activity_reassigning_all_count ));


# PROFILES-ACTIVITY_USER_REOPENING_YEAR
# (Track how many times each user has done the activity of reopening a bug per year)

# Reopening a bug is defined as an activity with one of the changes of fieldid 29 (bug status) as follows:
activity_working_reopening <- filter(activity_base, (		  added=="REOPENED" 	& fieldid==29) |	# All transitions 			to reopened
									  (removed=="CLOSED" 	& added=="UNCONFIRMED" 	& fieldid==29) |	# Transition from closed 	to unconfirmed
									  (removed=="CLOSED" 	& added=="NEW" 			& fieldid==29) |	# Transition from closed 	to new
									  (removed=="CLOSED" 	& added=="ASSIGNED"		& fieldid==29) |	# Transition from closed 	to assigned
									  (removed=="RESOLVED" 	& added=="ASSIGNED"		& fieldid==29) |	# Transition from resolved 	to assigned
									  (removed=="RESOLVED" 	& added=="NEW"			& fieldid==29) |	# Transition from resolved	to new
									  (removed=="RESOLVED" 	& added=="UNCONFIRMED"	& fieldid==29) |	# Transition from resolved 	to unconfirmed
									  (removed=="VERIFIED" 	& added=="NEW"			& fieldid==29) |	# Transition from verified 	to new
									  (removed=="VERIFIED" 	& added=="UNCONFIRMED"	& fieldid==29) |	# Transition from verified 	to unconfirmed
									  (removed=="VERIFIED" 	& added=="ASSIGNED"		& fieldid==29));	# Transition from verified 	to assigned

# We only need the user ("who") and year of the bug_when column, so drop the rest.
activity_working_reopening_who_year <- transmute(activity_working_reopening, who = who, bug_when_year = format(bug_when, format='%Y'));


# Use data.table's dcast() function to recast the table such that each row is a single user and there is
# a column for each field_id that is the sum of activities in each year for each user
activity_working_reopening_who_year_recast <- dcast(activity_working_reopening_who_year, who ~ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_working_reopening_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(activity_working_reopening_who_year_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns to our desired names
activity_working_reopening_who_year_recast <- transmute(activity_working_reopening_who_year_recast, who 							   = who,
																									user_activity_reopening_1998_count = if (exists('arg1998', where = activity_working_reopening_who_year_recast)) arg1998 else 0,
																									user_activity_reopening_1999_count = if (exists('arg1999', where = activity_working_reopening_who_year_recast)) arg1999 else 0,
																									user_activity_reopening_2000_count = if (exists('arg2000', where = activity_working_reopening_who_year_recast)) arg2000 else 0,
																									user_activity_reopening_2001_count = if (exists('arg2001', where = activity_working_reopening_who_year_recast)) arg2001 else 0,
																									user_activity_reopening_2002_count = if (exists('arg2002', where = activity_working_reopening_who_year_recast)) arg2002 else 0,
																									user_activity_reopening_2003_count = if (exists('arg2003', where = activity_working_reopening_who_year_recast)) arg2003 else 0,
																									user_activity_reopening_2004_count = if (exists('arg2004', where = activity_working_reopening_who_year_recast)) arg2004 else 0,
																									user_activity_reopening_2005_count = if (exists('arg2005', where = activity_working_reopening_who_year_recast)) arg2005 else 0,
																									user_activity_reopening_2006_count = if (exists('arg2006', where = activity_working_reopening_who_year_recast)) arg2006 else 0,
																									user_activity_reopening_2007_count = if (exists('arg2007', where = activity_working_reopening_who_year_recast)) arg2007 else 0,
																									user_activity_reopening_2008_count = if (exists('arg2008', where = activity_working_reopening_who_year_recast)) arg2008 else 0,
																									user_activity_reopening_2009_count = if (exists('arg2009', where = activity_working_reopening_who_year_recast)) arg2009 else 0,
																									user_activity_reopening_2010_count = if (exists('arg2010', where = activity_working_reopening_who_year_recast)) arg2010 else 0,
																									user_activity_reopening_2011_count = if (exists('arg2011', where = activity_working_reopening_who_year_recast)) arg2011 else 0,
																									user_activity_reopening_2012_count = if (exists('arg2012', where = activity_working_reopening_who_year_recast)) arg2012 else 0,
																									user_activity_reopening_2013_count = if (exists('arg2013', where = activity_working_reopening_who_year_recast)) arg2013 else 0);
																									
activity_working_reopening_who_year_recast <- mutate(activity_working_reopening_who_year_recast, user_activity_reopening_all_count = 	user_activity_reopening_1998_count +
																																		user_activity_reopening_1999_count +
																																		user_activity_reopening_2000_count +
																																		user_activity_reopening_2001_count +
																																		user_activity_reopening_2002_count +
																																		user_activity_reopening_2003_count +
																																		user_activity_reopening_2004_count +
																																		user_activity_reopening_2005_count +
																																		user_activity_reopening_2006_count +
																																		user_activity_reopening_2007_count +
																																		user_activity_reopening_2008_count +
																																		user_activity_reopening_2009_count +
																																		user_activity_reopening_2010_count +
																																		user_activity_reopening_2011_count +
																																		user_activity_reopening_2012_count +
																																		user_activity_reopening_2013_count); 

# Merge the "activity_working_reopening_who_year_recast" table with the profiles table according to "who" and "userid"
setkey(activity_working_reopening_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_working_reopening_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries that means the user did no rereopening activities, so set it to 0
profiles_working <- mutate(profiles_working, user_activity_reopening_1998_count = safe_ifelse(is.na(user_activity_reopening_1998_count), 0, user_activity_reopening_1998_count),
                                             user_activity_reopening_1999_count = safe_ifelse(is.na(user_activity_reopening_1999_count), 0, user_activity_reopening_1999_count),
                                             user_activity_reopening_2000_count = safe_ifelse(is.na(user_activity_reopening_2000_count), 0, user_activity_reopening_2000_count),
                                             user_activity_reopening_2001_count = safe_ifelse(is.na(user_activity_reopening_2001_count), 0, user_activity_reopening_2001_count),
                                             user_activity_reopening_2002_count = safe_ifelse(is.na(user_activity_reopening_2002_count), 0, user_activity_reopening_2002_count),
                                             user_activity_reopening_2003_count = safe_ifelse(is.na(user_activity_reopening_2003_count), 0, user_activity_reopening_2003_count),
                                             user_activity_reopening_2004_count = safe_ifelse(is.na(user_activity_reopening_2004_count), 0, user_activity_reopening_2004_count),
                                             user_activity_reopening_2005_count = safe_ifelse(is.na(user_activity_reopening_2005_count), 0, user_activity_reopening_2005_count),
                                             user_activity_reopening_2006_count = safe_ifelse(is.na(user_activity_reopening_2006_count), 0, user_activity_reopening_2006_count),
                                             user_activity_reopening_2007_count = safe_ifelse(is.na(user_activity_reopening_2007_count), 0, user_activity_reopening_2007_count),
                                             user_activity_reopening_2008_count = safe_ifelse(is.na(user_activity_reopening_2008_count), 0, user_activity_reopening_2008_count),
                                             user_activity_reopening_2009_count = safe_ifelse(is.na(user_activity_reopening_2009_count), 0, user_activity_reopening_2009_count),
                                             user_activity_reopening_2010_count = safe_ifelse(is.na(user_activity_reopening_2010_count), 0, user_activity_reopening_2010_count),
                                             user_activity_reopening_2011_count = safe_ifelse(is.na(user_activity_reopening_2011_count), 0, user_activity_reopening_2011_count),
                                             user_activity_reopening_2012_count = safe_ifelse(is.na(user_activity_reopening_2012_count), 0, user_activity_reopening_2012_count),
                                             user_activity_reopening_2013_count = safe_ifelse(is.na(user_activity_reopening_2013_count), 0, user_activity_reopening_2013_count),
                                             user_activity_reopening_all_count  = safe_ifelse(is.na(user_activity_reopening_all_count ), 0, user_activity_reopening_all_count ));


# PROFILES-ATTACHMENTS_USER_ALL_TYPES_YEAR
#(Count the attachments of all types made for each user for each year)

# We only need the attachments_base table since we're working on the profiles_working table
attachments_working <- attachments_base;

# Select just the fields in the attachments_working table that we want to look at, namely submitter_id and creation_ts
attachments_working_submitter_id_creation_ts <- select(attachments_working, submitter_id, creation_ts);

# Transmute to get just the year of the creation_ts column
attachments_working_submitter_id_year <- transmute(attachments_working_submitter_id_creation_ts, submitter_id = submitter_id, creation_ts_year = format(creation_ts, format='%Y'));

# Use data.table's dcast() function to recast the table such that each row is a single submitter_id and there
# is a column with the count of each time a user submitted an attachment each of the years in the database
attachments_working_submitter_id_year_recast <- dcast(attachments_working_submitter_id_year, submitter_id ~ creation_ts_year, drop=FALSE, value.var="creation_ts_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(attachments_working_submitter_id_year_recast) <- gsub("^(\\d)", "arg\\1", names(attachments_working_submitter_id_year_recast), perl=TRUE);

# Transmute all of the columns to the desired values
attachments_working_submitter_id_year_recast <- transmute(attachments_working_submitter_id_year_recast,
														  submitter_id							= submitter_id,
														  user_attachments_all_types_1998_count = if (exists('arg1998', where = attachments_working_submitter_id_year_recast)) arg1998 else 0,
														  user_attachments_all_types_1999_count = if (exists('arg1999', where = attachments_working_submitter_id_year_recast)) arg1999 else 0,
														  user_attachments_all_types_2000_count = if (exists('arg2000', where = attachments_working_submitter_id_year_recast)) arg2000 else 0,
														  user_attachments_all_types_2001_count = if (exists('arg2001', where = attachments_working_submitter_id_year_recast)) arg2001 else 0,
														  user_attachments_all_types_2002_count = if (exists('arg2002', where = attachments_working_submitter_id_year_recast)) arg2002 else 0,
														  user_attachments_all_types_2003_count = if (exists('arg2003', where = attachments_working_submitter_id_year_recast)) arg2003 else 0,
														  user_attachments_all_types_2004_count = if (exists('arg2004', where = attachments_working_submitter_id_year_recast)) arg2004 else 0,
														  user_attachments_all_types_2005_count = if (exists('arg2005', where = attachments_working_submitter_id_year_recast)) arg2005 else 0,
														  user_attachments_all_types_2006_count = if (exists('arg2006', where = attachments_working_submitter_id_year_recast)) arg2006 else 0,
														  user_attachments_all_types_2007_count = if (exists('arg2007', where = attachments_working_submitter_id_year_recast)) arg2007 else 0,
														  user_attachments_all_types_2008_count = if (exists('arg2008', where = attachments_working_submitter_id_year_recast)) arg2008 else 0,
														  user_attachments_all_types_2009_count = if (exists('arg2009', where = attachments_working_submitter_id_year_recast)) arg2009 else 0,
														  user_attachments_all_types_2010_count = if (exists('arg2010', where = attachments_working_submitter_id_year_recast)) arg2010 else 0,
														  user_attachments_all_types_2011_count = if (exists('arg2011', where = attachments_working_submitter_id_year_recast)) arg2011 else 0,
														  user_attachments_all_types_2012_count = if (exists('arg2012', where = attachments_working_submitter_id_year_recast)) arg2012 else 0,
														  user_attachments_all_types_2013_count = if (exists('arg2013', where = attachments_working_submitter_id_year_recast)) arg2013 else 0);
																						
# Merge the attachments_working_submitter_id_year_recast and profiles_working tables based on submitter_id & userid to add the years count columns
setkey(attachments_working_submitter_id_year_recast, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_working_submitter_id_year_recast, by.x="userid", by.y="submitter_id", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, user_attachments_all_types_1998_count = safe_ifelse(is.na(user_attachments_all_types_1998_count), 0, user_attachments_all_types_1998_count),
                                             user_attachments_all_types_1999_count = safe_ifelse(is.na(user_attachments_all_types_1999_count), 0, user_attachments_all_types_1999_count),
                                             user_attachments_all_types_2000_count = safe_ifelse(is.na(user_attachments_all_types_2000_count), 0, user_attachments_all_types_2000_count),
											 user_attachments_all_types_2001_count = safe_ifelse(is.na(user_attachments_all_types_2001_count), 0, user_attachments_all_types_2001_count),
											 user_attachments_all_types_2002_count = safe_ifelse(is.na(user_attachments_all_types_2002_count), 0, user_attachments_all_types_2002_count),
											 user_attachments_all_types_2003_count = safe_ifelse(is.na(user_attachments_all_types_2003_count), 0, user_attachments_all_types_2003_count),
											 user_attachments_all_types_2004_count = safe_ifelse(is.na(user_attachments_all_types_2004_count), 0, user_attachments_all_types_2004_count),
											 user_attachments_all_types_2005_count = safe_ifelse(is.na(user_attachments_all_types_2005_count), 0, user_attachments_all_types_2005_count),
											 user_attachments_all_types_2006_count = safe_ifelse(is.na(user_attachments_all_types_2006_count), 0, user_attachments_all_types_2006_count),
											 user_attachments_all_types_2007_count = safe_ifelse(is.na(user_attachments_all_types_2007_count), 0, user_attachments_all_types_2007_count),
											 user_attachments_all_types_2008_count = safe_ifelse(is.na(user_attachments_all_types_2008_count), 0, user_attachments_all_types_2008_count),
											 user_attachments_all_types_2009_count = safe_ifelse(is.na(user_attachments_all_types_2009_count), 0, user_attachments_all_types_2009_count),
											 user_attachments_all_types_2010_count = safe_ifelse(is.na(user_attachments_all_types_2010_count), 0, user_attachments_all_types_2010_count),
											 user_attachments_all_types_2011_count = safe_ifelse(is.na(user_attachments_all_types_2011_count), 0, user_attachments_all_types_2011_count),
											 user_attachments_all_types_2012_count = safe_ifelse(is.na(user_attachments_all_types_2012_count), 0, user_attachments_all_types_2012_count),
											 user_attachments_all_types_2013_count = safe_ifelse(is.na(user_attachments_all_types_2013_count), 0, user_attachments_all_types_2013_count)); 


# PROFILES-ATTACHMENTS_USER_PATCHES_YEAR
#(Count the attachments that are patches made for each user for each year)

# Select just the fields in the attachments_working table that we want to look at, namely submitter_id and creation_ts
# Filter for just patches
attachments_working_patches_submitter_id_creation_ts <- select(filter(attachments_working, ispatch==TRUE), submitter_id, creation_ts);

# Transmute to get just the year of the creation_ts column
attachments_working_patches_submitter_id_year <- transmute(attachments_working_patches_submitter_id_creation_ts, submitter_id = submitter_id, creation_ts_year = format(creation_ts, format='%Y'));

# Use data.table's dcast() function to recast the table such that each row is a single submitter_id and there
# is a column with the count of each time a user submitted an attachment that was a patch each of the years in the database
attachments_working_patches_submitter_id_year_recast <- dcast(attachments_working_patches_submitter_id_year, submitter_id ~ creation_ts_year, drop=FALSE, value.var="creation_ts_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(attachments_working_patches_submitter_id_year_recast) <- gsub("^(\\d)", "arg\\1", names(attachments_working_patches_submitter_id_year_recast), perl=TRUE);

# Transmute all of the columns to the desired values
attachments_working_patches_submitter_id_year_recast <- transmute(attachments_working_patches_submitter_id_year_recast,
														  submitter_id							= submitter_id,
														  user_attachments_patches_1998_count = if (exists('arg1998', where = attachments_working_patches_submitter_id_year_recast)) arg1998 else 0,
														  user_attachments_patches_1999_count = if (exists('arg1999', where = attachments_working_patches_submitter_id_year_recast)) arg1999 else 0,
														  user_attachments_patches_2000_count = if (exists('arg2000', where = attachments_working_patches_submitter_id_year_recast)) arg2000 else 0,
														  user_attachments_patches_2001_count = if (exists('arg2001', where = attachments_working_patches_submitter_id_year_recast)) arg2001 else 0,
														  user_attachments_patches_2002_count = if (exists('arg2002', where = attachments_working_patches_submitter_id_year_recast)) arg2002 else 0,
														  user_attachments_patches_2003_count = if (exists('arg2003', where = attachments_working_patches_submitter_id_year_recast)) arg2003 else 0,
														  user_attachments_patches_2004_count = if (exists('arg2004', where = attachments_working_patches_submitter_id_year_recast)) arg2004 else 0,
														  user_attachments_patches_2005_count = if (exists('arg2005', where = attachments_working_patches_submitter_id_year_recast)) arg2005 else 0,
														  user_attachments_patches_2006_count = if (exists('arg2006', where = attachments_working_patches_submitter_id_year_recast)) arg2006 else 0,
														  user_attachments_patches_2007_count = if (exists('arg2007', where = attachments_working_patches_submitter_id_year_recast)) arg2007 else 0,
														  user_attachments_patches_2008_count = if (exists('arg2008', where = attachments_working_patches_submitter_id_year_recast)) arg2008 else 0,
														  user_attachments_patches_2009_count = if (exists('arg2009', where = attachments_working_patches_submitter_id_year_recast)) arg2009 else 0,
														  user_attachments_patches_2010_count = if (exists('arg2010', where = attachments_working_patches_submitter_id_year_recast)) arg2010 else 0,
														  user_attachments_patches_2011_count = if (exists('arg2011', where = attachments_working_patches_submitter_id_year_recast)) arg2011 else 0,
														  user_attachments_patches_2012_count = if (exists('arg2012', where = attachments_working_patches_submitter_id_year_recast)) arg2012 else 0,
														  user_attachments_patches_2013_count = if (exists('arg2013', where = attachments_working_patches_submitter_id_year_recast)) arg2013 else 0);
																						
# Merge the attachments_working_patches_submitter_id_year_recast and profiles_working tables based on submitter_id & userid to add the years count columns
setkey(attachments_working_patches_submitter_id_year_recast, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_working_patches_submitter_id_year_recast, by.x="userid", by.y="submitter_id", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, user_attachments_patches_1998_count = safe_ifelse(is.na(user_attachments_patches_1998_count), 0, user_attachments_patches_1998_count),
                                             user_attachments_patches_1999_count = safe_ifelse(is.na(user_attachments_patches_1999_count), 0, user_attachments_patches_1999_count),
                                             user_attachments_patches_2000_count = safe_ifelse(is.na(user_attachments_patches_2000_count), 0, user_attachments_patches_2000_count),
											 user_attachments_patches_2001_count = safe_ifelse(is.na(user_attachments_patches_2001_count), 0, user_attachments_patches_2001_count),
											 user_attachments_patches_2002_count = safe_ifelse(is.na(user_attachments_patches_2002_count), 0, user_attachments_patches_2002_count),
											 user_attachments_patches_2003_count = safe_ifelse(is.na(user_attachments_patches_2003_count), 0, user_attachments_patches_2003_count),
											 user_attachments_patches_2004_count = safe_ifelse(is.na(user_attachments_patches_2004_count), 0, user_attachments_patches_2004_count),
											 user_attachments_patches_2005_count = safe_ifelse(is.na(user_attachments_patches_2005_count), 0, user_attachments_patches_2005_count),
											 user_attachments_patches_2006_count = safe_ifelse(is.na(user_attachments_patches_2006_count), 0, user_attachments_patches_2006_count),
											 user_attachments_patches_2007_count = safe_ifelse(is.na(user_attachments_patches_2007_count), 0, user_attachments_patches_2007_count),
											 user_attachments_patches_2008_count = safe_ifelse(is.na(user_attachments_patches_2008_count), 0, user_attachments_patches_2008_count),
											 user_attachments_patches_2009_count = safe_ifelse(is.na(user_attachments_patches_2009_count), 0, user_attachments_patches_2009_count),
											 user_attachments_patches_2010_count = safe_ifelse(is.na(user_attachments_patches_2010_count), 0, user_attachments_patches_2010_count),
											 user_attachments_patches_2011_count = safe_ifelse(is.na(user_attachments_patches_2011_count), 0, user_attachments_patches_2011_count),
											 user_attachments_patches_2012_count = safe_ifelse(is.na(user_attachments_patches_2012_count), 0, user_attachments_patches_2012_count),
											 user_attachments_patches_2013_count = safe_ifelse(is.na(user_attachments_patches_2013_count), 0, user_attachments_patches_2013_count)); 


# PROFILES-LONGDESCS_USER_COMMENTS_ALL_BUGS_YEAR
#(Count the comments on all bugs made by each user for each year)

# Select just the fields in the longdescs_base table that we want to look at, namely who and bug_when
longdescs_working_who_bug_when <- select(longdescs_base, who, bug_when);

# Transmute to get just the year of the bug_when column
longdescs_working_who_year <- transmute(longdescs_working_who_bug_when, who = who, bug_when_year = format(bug_when, format='%Y'));

# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the count of each time a user made a comment each of the years in the database
longdescs_working_who_year_recast <- dcast(longdescs_working_who_year, who ~ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(longdescs_working_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(longdescs_working_who_year_recast), perl=TRUE);

# Transmute all of the columns to the desired values
longdescs_working_who_year_recast <- transmute(longdescs_working_who_year_recast,
											   who									 = who,
											   user_comments_all_bugs_1995_count = if (exists('arg1995', where = longdescs_working_who_year_recast)) arg1995 else 0,
											   user_comments_all_bugs_1996_count = if (exists('arg1996', where = longdescs_working_who_year_recast)) arg1996 else 0,
											   user_comments_all_bugs_1997_count = if (exists('arg1997', where = longdescs_working_who_year_recast)) arg1997 else 0,
											   user_comments_all_bugs_1998_count = if (exists('arg1998', where = longdescs_working_who_year_recast)) arg1998 else 0,
											   user_comments_all_bugs_1999_count = if (exists('arg1999', where = longdescs_working_who_year_recast)) arg1999 else 0,
											   user_comments_all_bugs_2000_count = if (exists('arg2000', where = longdescs_working_who_year_recast)) arg2000 else 0,
											   user_comments_all_bugs_2001_count = if (exists('arg2001', where = longdescs_working_who_year_recast)) arg2001 else 0,
											   user_comments_all_bugs_2002_count = if (exists('arg2002', where = longdescs_working_who_year_recast)) arg2002 else 0,
											   user_comments_all_bugs_2003_count = if (exists('arg2003', where = longdescs_working_who_year_recast)) arg2003 else 0,
											   user_comments_all_bugs_2004_count = if (exists('arg2004', where = longdescs_working_who_year_recast)) arg2004 else 0,
											   user_comments_all_bugs_2005_count = if (exists('arg2005', where = longdescs_working_who_year_recast)) arg2005 else 0,
											   user_comments_all_bugs_2006_count = if (exists('arg2006', where = longdescs_working_who_year_recast)) arg2006 else 0,
											   user_comments_all_bugs_2007_count = if (exists('arg2007', where = longdescs_working_who_year_recast)) arg2007 else 0,
											   user_comments_all_bugs_2008_count = if (exists('arg2008', where = longdescs_working_who_year_recast)) arg2008 else 0,
											   user_comments_all_bugs_2009_count = if (exists('arg2009', where = longdescs_working_who_year_recast)) arg2009 else 0,
											   user_comments_all_bugs_2010_count = if (exists('arg2010', where = longdescs_working_who_year_recast)) arg2010 else 0,
											   user_comments_all_bugs_2011_count = if (exists('arg2011', where = longdescs_working_who_year_recast)) arg2011 else 0,
											   user_comments_all_bugs_2012_count = if (exists('arg2012', where = longdescs_working_who_year_recast)) arg2012 else 0,
											   user_comments_all_bugs_2013_count = if (exists('arg2013', where = longdescs_working_who_year_recast)) arg2013 else 0);
																						
longdescs_working_who_year_recast <- mutate(longdescs_working_who_year_recast, user_comments_all_bugs_all_count = 	user_comments_all_bugs_1995_count +
																													user_comments_all_bugs_1996_count +
																													user_comments_all_bugs_1997_count +
																													user_comments_all_bugs_1998_count +
																													user_comments_all_bugs_1999_count +
																													user_comments_all_bugs_2000_count +
																													user_comments_all_bugs_2001_count +
																													user_comments_all_bugs_2002_count +
																													user_comments_all_bugs_2003_count +
																													user_comments_all_bugs_2004_count +
																													user_comments_all_bugs_2005_count +
																													user_comments_all_bugs_2006_count +
																													user_comments_all_bugs_2007_count +
																													user_comments_all_bugs_2008_count +
																													user_comments_all_bugs_2009_count +
																													user_comments_all_bugs_2010_count + 
																						                            user_comments_all_bugs_2011_count +
																						                            user_comments_all_bugs_2012_count +
																						                            user_comments_all_bugs_2013_count);
																						
# Merge the longdescs_working_who_year_recast and profiles_working tables based on who & userid to add the years count columns
setkey(longdescs_working_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, longdescs_working_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, 
											 user_comments_all_bugs_1995_count = safe_ifelse(is.na(user_comments_all_bugs_1995_count), 0, user_comments_all_bugs_1995_count),
											 user_comments_all_bugs_1996_count = safe_ifelse(is.na(user_comments_all_bugs_1996_count), 0, user_comments_all_bugs_1996_count),
											 user_comments_all_bugs_1997_count = safe_ifelse(is.na(user_comments_all_bugs_1997_count), 0, user_comments_all_bugs_1997_count),
											 user_comments_all_bugs_1998_count = safe_ifelse(is.na(user_comments_all_bugs_1998_count), 0, user_comments_all_bugs_1998_count),
                                             user_comments_all_bugs_1999_count = safe_ifelse(is.na(user_comments_all_bugs_1999_count), 0, user_comments_all_bugs_1999_count),
                                             user_comments_all_bugs_2000_count = safe_ifelse(is.na(user_comments_all_bugs_2000_count), 0, user_comments_all_bugs_2000_count),
											 user_comments_all_bugs_2001_count = safe_ifelse(is.na(user_comments_all_bugs_2001_count), 0, user_comments_all_bugs_2001_count),
											 user_comments_all_bugs_2002_count = safe_ifelse(is.na(user_comments_all_bugs_2002_count), 0, user_comments_all_bugs_2002_count),
											 user_comments_all_bugs_2003_count = safe_ifelse(is.na(user_comments_all_bugs_2003_count), 0, user_comments_all_bugs_2003_count),
											 user_comments_all_bugs_2004_count = safe_ifelse(is.na(user_comments_all_bugs_2004_count), 0, user_comments_all_bugs_2004_count),
											 user_comments_all_bugs_2005_count = safe_ifelse(is.na(user_comments_all_bugs_2005_count), 0, user_comments_all_bugs_2005_count),
											 user_comments_all_bugs_2006_count = safe_ifelse(is.na(user_comments_all_bugs_2006_count), 0, user_comments_all_bugs_2006_count),
											 user_comments_all_bugs_2007_count = safe_ifelse(is.na(user_comments_all_bugs_2007_count), 0, user_comments_all_bugs_2007_count),
											 user_comments_all_bugs_2008_count = safe_ifelse(is.na(user_comments_all_bugs_2008_count), 0, user_comments_all_bugs_2008_count),
											 user_comments_all_bugs_2009_count = safe_ifelse(is.na(user_comments_all_bugs_2009_count), 0, user_comments_all_bugs_2009_count),
											 user_comments_all_bugs_2010_count = safe_ifelse(is.na(user_comments_all_bugs_2010_count), 0, user_comments_all_bugs_2010_count),
											 user_comments_all_bugs_2011_count = safe_ifelse(is.na(user_comments_all_bugs_2011_count), 0, user_comments_all_bugs_2011_count),
											 user_comments_all_bugs_2012_count = safe_ifelse(is.na(user_comments_all_bugs_2012_count), 0, user_comments_all_bugs_2012_count),
											 user_comments_all_bugs_2013_count = safe_ifelse(is.na(user_comments_all_bugs_2013_count), 0, user_comments_all_bugs_2013_count),
											 user_comments_all_bugs_all_count  = safe_ifelse(is.na(user_comments_all_bugs_all_count),  0, user_comments_all_bugs_all_count)); 
											 
# Since the longdescs table also includes the "description" for a reported bug as the first "comment" for that bug
# if a user reported bugs during each of the above years, their comments count will be artificially inflated
# Need to subtract the bugs_reported for that year from the comment count for each user to remove description
profiles_working <- mutate(profiles_working, user_comments_all_bugs_1995_count = safe_ifelse((user_comments_all_bugs_1995_count - user_bugs_reported_1995_count) < 0, 0, user_comments_all_bugs_1995_count - user_bugs_reported_1995_count),
											 user_comments_all_bugs_1996_count = safe_ifelse((user_comments_all_bugs_1996_count - user_bugs_reported_1996_count) < 0, 0, user_comments_all_bugs_1996_count - user_bugs_reported_1996_count),
											 user_comments_all_bugs_1997_count = safe_ifelse((user_comments_all_bugs_1997_count - user_bugs_reported_1997_count) < 0, 0, user_comments_all_bugs_1997_count - user_bugs_reported_1997_count),
											 user_comments_all_bugs_1998_count = safe_ifelse((user_comments_all_bugs_1998_count - user_bugs_reported_1998_count) < 0, 0, user_comments_all_bugs_1998_count - user_bugs_reported_1998_count),
                                             user_comments_all_bugs_1999_count = safe_ifelse((user_comments_all_bugs_1999_count - user_bugs_reported_1999_count) < 0, 0, user_comments_all_bugs_1999_count - user_bugs_reported_1999_count),
                                             user_comments_all_bugs_2000_count = safe_ifelse((user_comments_all_bugs_2000_count - user_bugs_reported_2000_count) < 0, 0, user_comments_all_bugs_2000_count - user_bugs_reported_2000_count),
											 user_comments_all_bugs_2001_count = safe_ifelse((user_comments_all_bugs_2001_count - user_bugs_reported_2001_count) < 0, 0, user_comments_all_bugs_2001_count - user_bugs_reported_2001_count),
											 user_comments_all_bugs_2002_count = safe_ifelse((user_comments_all_bugs_2002_count - user_bugs_reported_2002_count) < 0, 0, user_comments_all_bugs_2002_count - user_bugs_reported_2002_count),
											 user_comments_all_bugs_2003_count = safe_ifelse((user_comments_all_bugs_2003_count - user_bugs_reported_2003_count) < 0, 0, user_comments_all_bugs_2003_count - user_bugs_reported_2003_count),
											 user_comments_all_bugs_2004_count = safe_ifelse((user_comments_all_bugs_2004_count - user_bugs_reported_2004_count) < 0, 0, user_comments_all_bugs_2004_count - user_bugs_reported_2004_count),
											 user_comments_all_bugs_2005_count = safe_ifelse((user_comments_all_bugs_2005_count - user_bugs_reported_2005_count) < 0, 0, user_comments_all_bugs_2005_count - user_bugs_reported_2005_count),
											 user_comments_all_bugs_2006_count = safe_ifelse((user_comments_all_bugs_2006_count - user_bugs_reported_2006_count) < 0, 0, user_comments_all_bugs_2006_count - user_bugs_reported_2006_count),
											 user_comments_all_bugs_2007_count = safe_ifelse((user_comments_all_bugs_2007_count - user_bugs_reported_2007_count) < 0, 0, user_comments_all_bugs_2007_count - user_bugs_reported_2007_count),
											 user_comments_all_bugs_2008_count = safe_ifelse((user_comments_all_bugs_2008_count - user_bugs_reported_2008_count) < 0, 0, user_comments_all_bugs_2008_count - user_bugs_reported_2008_count),
											 user_comments_all_bugs_2009_count = safe_ifelse((user_comments_all_bugs_2009_count - user_bugs_reported_2009_count) < 0, 0, user_comments_all_bugs_2009_count - user_bugs_reported_2009_count),
											 user_comments_all_bugs_2010_count = safe_ifelse((user_comments_all_bugs_2010_count - user_bugs_reported_2010_count) < 0, 0, user_comments_all_bugs_2010_count - user_bugs_reported_2010_count),
											 user_comments_all_bugs_2011_count = safe_ifelse((user_comments_all_bugs_2011_count - user_bugs_reported_2011_count) < 0, 0, user_comments_all_bugs_2011_count - user_bugs_reported_2011_count),
											 user_comments_all_bugs_2012_count = safe_ifelse((user_comments_all_bugs_2012_count - user_bugs_reported_2012_count) < 0, 0, user_comments_all_bugs_2012_count - user_bugs_reported_2012_count),
											 user_comments_all_bugs_2013_count = safe_ifelse((user_comments_all_bugs_2013_count - user_bugs_reported_2013_count) < 0, 0, user_comments_all_bugs_2013_count - user_bugs_reported_2013_count),
											 user_comments_all_bugs_all_count  = safe_ifelse((user_comments_all_bugs_all_count  - user_bugs_reported_count)      < 0, 0, user_comments_all_bugs_all_count  - user_bugs_reported_count)); 
                                                                                                                   

# PROFILES-LONGDESCS_BUGS_REPORTED_SEVERITY_DESCRIPTION_MEAN_LENGTH
# (Calculate the mean description length for the bugs that were reported by each user)

# We need to reduce the bugs_working table to just reporter + description_length + bug_severity
bugs_working_reporter_description_length_severity <- select(bugs_working, reporter, description_length, bug_severity);


# Use data.table's dcast() function to recast the table such that each row is a single "reporter" and there
# is a column with the mean description length for each severity level of all the bugs reported by each user, defaulting to mean of 0 if no bugs of that severity were reported by a given user
bugs_working_reporter_description_length_severity_recast <- dcast(bugs_working_reporter_description_length_severity, reporter ~ bug_severity, drop=FALSE, value.var="description_length", fun=mean, fill=0, na.rm=TRUE);


# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_reporter_description_length_severity_recast <- transmute(bugs_working_reporter_description_length_severity_recast,  	
																	  reporter 									= reporter,
																	  user_bugs_reported_enhancement_description_mean_length	= if (exists('enhancement',	where = bugs_working_reporter_description_length_severity_recast)) enhancement 	else 0,
																	  user_bugs_reported_trivial_description_mean_length		= if (exists('trivial',		where = bugs_working_reporter_description_length_severity_recast)) trivial 		else 0,
																	  user_bugs_reported_minor_description_mean_length			= if (exists('minor',		where = bugs_working_reporter_description_length_severity_recast)) minor 		else 0,
																	  user_bugs_reported_normal_description_mean_length			= if (exists('normal',		where = bugs_working_reporter_description_length_severity_recast)) normal 		else 0,
																	  user_bugs_reported_major_description_mean_length			= if (exists('major',		where = bugs_working_reporter_description_length_severity_recast)) major 		else 0,
																	  user_bugs_reported_critical_description_mean_length		= if (exists('critical',	where = bugs_working_reporter_description_length_severity_recast)) critical 	else 0,
																	  user_bugs_reported_blocker_description_mean_length		= if (exists('blocker',		where = bugs_working_reporter_description_length_severity_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs for which each user reported
bugs_working_reporter_description_length_severity_recast <- mutate(bugs_working_reporter_description_length_severity_recast,
																	 user_bugs_reported_all_types_description_mean_length = (user_bugs_reported_enhancement_description_mean_length +
																	                                                         user_bugs_reported_trivial_description_mean_length 	+
																	                                                         user_bugs_reported_minor_description_mean_length 		+	
																	                                                         user_bugs_reported_normal_description_mean_length 		+
																	                                                         user_bugs_reported_major_description_mean_length 		+	
																	                                                         user_bugs_reported_critical_description_mean_length 	+
																	                                                         user_bugs_reported_blocker_description_mean_length) 	/ 7);
																																   
																																   
# Merge the bugs_working_reporter_description_length_severity_recast and profiles_working tables based on reporter & userid to add the severity types description mean length columns
setkey(bugs_working_reporter_description_length_severity_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_description_length_severity_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user was not set as reporter for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
profiles_working <- mutate(profiles_working, user_bugs_reported_enhancement_description_mean_length	= safe_ifelse(user_bugs_reported_enhancement_description_mean_length	<= 0, NA, user_bugs_reported_enhancement_description_mean_length),
                                             user_bugs_reported_trivial_description_mean_length		= safe_ifelse(user_bugs_reported_trivial_description_mean_length		<= 0, NA, user_bugs_reported_trivial_description_mean_length),	
                                             user_bugs_reported_minor_description_mean_length		= safe_ifelse(user_bugs_reported_minor_description_mean_length			<= 0, NA, user_bugs_reported_minor_description_mean_length),		
                                             user_bugs_reported_normal_description_mean_length		= safe_ifelse(user_bugs_reported_normal_description_mean_length			<= 0, NA, user_bugs_reported_normal_description_mean_length),		
                                             user_bugs_reported_major_description_mean_length		= safe_ifelse(user_bugs_reported_major_description_mean_length			<= 0, NA, user_bugs_reported_major_description_mean_length),		
                                             user_bugs_reported_critical_description_mean_length	= safe_ifelse(user_bugs_reported_critical_description_mean_length		<= 0, NA, user_bugs_reported_critical_description_mean_length),	
                                             user_bugs_reported_blocker_description_mean_length		= safe_ifelse(user_bugs_reported_blocker_description_mean_length		<= 0, NA, user_bugs_reported_blocker_description_mean_length),
											 user_bugs_reported_all_types_description_mean_length	= safe_ifelse(user_bugs_reported_all_types_description_mean_length		<= 0, NA, user_bugs_reported_all_types_description_mean_length));	


# PROFILES-LONGDESCS_BUGS_ASSIGNED_SEVERITY_DESCRIPTION_MEAN_LENGTH
# (Calculate the mean description length for the bugs that were assigned to each user)

# We need to reduce the bugs_working table to just assigned_to + description_length + bug_severity
bugs_working_assigned_to_description_length_severity <- select(bugs_working, assigned_to, description_length, bug_severity);


# Use data.table's dcast() function to recast the table such that each row is a single "assigned_to" and there
# is a column with the mean description length for each severity level of the bugs each user was assigned, defaulting to mean of 0 if no bugs of that severity were assigned to a given user
bugs_working_assigned_to_description_length_severity_recast <- dcast(bugs_working_assigned_to_description_length_severity, assigned_to ~ bug_severity, drop=FALSE, value.var="description_length", fun=mean, fill=0, na.rm=TRUE);


# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_assigned_to_description_length_severity_recast <- transmute(bugs_working_assigned_to_description_length_severity_recast,  	
															assigned_to 												= assigned_to,
															user_bugs_assigned_to_enhancement_description_mean_length	= if (exists('enhancement',	where = bugs_working_assigned_to_description_length_severity_recast)) enhancement	 else 0,
															user_bugs_assigned_to_trivial_description_mean_length		= if (exists('trivial',		where = bugs_working_assigned_to_description_length_severity_recast)) trivial 		 else 0,
															user_bugs_assigned_to_minor_description_mean_length			= if (exists('minor',		where = bugs_working_assigned_to_description_length_severity_recast)) minor 		 else 0,
															user_bugs_assigned_to_normal_description_mean_length		= if (exists('normal',		where = bugs_working_assigned_to_description_length_severity_recast)) normal 		 else 0,
															user_bugs_assigned_to_major_description_mean_length			= if (exists('major',		where = bugs_working_assigned_to_description_length_severity_recast)) major 		 else 0,
															user_bugs_assigned_to_critical_description_mean_length		= if (exists('critical',	where = bugs_working_assigned_to_description_length_severity_recast)) critical 		 else 0,
															user_bugs_assigned_to_blocker_description_mean_length		= if (exists('blocker',		where = bugs_working_assigned_to_description_length_severity_recast)) blocker 		 else 0);
																		
# Mutate to add the overall mean description length for bugs for which each user was assigned_to
bugs_working_assigned_to_description_length_severity_recast <- mutate(bugs_working_assigned_to_description_length_severity_recast,
																	 user_bugs_assigned_to_all_types_description_mean_length = (user_bugs_assigned_to_enhancement_description_mean_length 	+
																															    user_bugs_assigned_to_trivial_description_mean_length 		+
																															    user_bugs_assigned_to_minor_description_mean_length 		+	
																															    user_bugs_assigned_to_normal_description_mean_length 		+
																															    user_bugs_assigned_to_major_description_mean_length 		+	
																															    user_bugs_assigned_to_critical_description_mean_length 		+
																															    user_bugs_assigned_to_blocker_description_mean_length) 		/ 7);
																																   
# Merge the bugs_working_assigned_to_description_length_severity_recast and profiles_working tables based on assigned_to & userid to add the severity types description mean length columns
setkey(bugs_working_assigned_to_description_length_severity_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_description_length_severity_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user was not set as assigned_to for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_enhancement_description_mean_length	= safe_ifelse(user_bugs_assigned_to_enhancement_description_mean_length	<= 0, NA, user_bugs_assigned_to_enhancement_description_mean_length),
                                             user_bugs_assigned_to_trivial_description_mean_length		= safe_ifelse(user_bugs_assigned_to_trivial_description_mean_length		<= 0, NA, user_bugs_assigned_to_trivial_description_mean_length),	
                                             user_bugs_assigned_to_minor_description_mean_length		= safe_ifelse(user_bugs_assigned_to_minor_description_mean_length       <= 0, NA, user_bugs_assigned_to_minor_description_mean_length),		
                                             user_bugs_assigned_to_normal_description_mean_length		= safe_ifelse(user_bugs_assigned_to_normal_description_mean_length		<= 0, NA, user_bugs_assigned_to_normal_description_mean_length),		
                                             user_bugs_assigned_to_major_description_mean_length		= safe_ifelse(user_bugs_assigned_to_major_description_mean_length		<= 0, NA, user_bugs_assigned_to_major_description_mean_length),		
                                             user_bugs_assigned_to_critical_description_mean_length		= safe_ifelse(user_bugs_assigned_to_critical_description_mean_length	<= 0, NA, user_bugs_assigned_to_critical_description_mean_length),	
                                             user_bugs_assigned_to_blocker_description_mean_length		= safe_ifelse(user_bugs_assigned_to_blocker_description_mean_length		<= 0, NA, user_bugs_assigned_to_blocker_description_mean_length),
											 user_bugs_assigned_to_all_types_description_mean_length	= safe_ifelse(user_bugs_assigned_to_all_types_description_mean_length	<= 0, NA, user_bugs_assigned_to_all_types_description_mean_length));	
											 
											 
# PROFILES-LONGDESCS_BUGS_QA_CONTACT_SEVERITY_DESCRIPTION_MEAN_LENGTH
# (Calculate the mean description length for the bugs for which each user was set as qa_contact)

# We need to reduce the bugs_working table to just qa_contact + description_length + bug_severity
bugs_working_qa_contact_description_length_severity <- select(bugs_working, qa_contact, description_length, bug_severity);


# Use data.table's dcast() function to recast the table such that each row is a single "qa_contact" and there
# is a column with the mean description length for each severity level of each qa_contact bug, defaulting to mean of 0 if no bugs of that severity were qa_contact by a given user
bugs_working_qa_contact_description_length_severity_recast <- dcast(bugs_working_qa_contact_description_length_severity, qa_contact ~ bug_severity, drop=FALSE, value.var="description_length", fun=mean, fill=0, na.rm=TRUE);


# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_qa_contact_description_length_severity_recast <- transmute(bugs_working_qa_contact_description_length_severity_recast,  	
														   qa_contact 												= qa_contact,
														   user_bugs_qa_contact_enhancement_description_mean_length	= if (exists('enhancement',	where = bugs_working_qa_contact_description_length_severity_recast)) enhancement 	else 0,
														   user_bugs_qa_contact_trivial_description_mean_length		= if (exists('trivial',		where = bugs_working_qa_contact_description_length_severity_recast)) trivial 		else 0,
														   user_bugs_qa_contact_minor_description_mean_length		= if (exists('minor',		where = bugs_working_qa_contact_description_length_severity_recast)) minor 			else 0,
														   user_bugs_qa_contact_normal_description_mean_length		= if (exists('normal',		where = bugs_working_qa_contact_description_length_severity_recast)) normal 		else 0,
														   user_bugs_qa_contact_major_description_mean_length		= if (exists('major',		where = bugs_working_qa_contact_description_length_severity_recast)) major 			else 0,
														   user_bugs_qa_contact_critical_description_mean_length	= if (exists('critical',	where = bugs_working_qa_contact_description_length_severity_recast)) critical 		else 0,
														   user_bugs_qa_contact_blocker_description_mean_length		= if (exists('blocker',		where = bugs_working_qa_contact_description_length_severity_recast)) blocker 		else 0);

# Mutate to add the overall mean description length for bugs for which each user was qa_contact
bugs_working_qa_contact_description_length_severity_recast <- mutate(bugs_working_qa_contact_description_length_severity_recast,
																	 user_bugs_qa_contact_all_types_description_mean_length = (user_bugs_qa_contact_enhancement_description_mean_length +
																	                                                           user_bugs_qa_contact_trivial_description_mean_length 	+
																	                                                           user_bugs_qa_contact_minor_description_mean_length 		+	
																	                                                           user_bugs_qa_contact_normal_description_mean_length 		+
																	                                                           user_bugs_qa_contact_major_description_mean_length 		+	
																	                                                           user_bugs_qa_contact_critical_description_mean_length 	+
																	                                                           user_bugs_qa_contact_blocker_description_mean_length) 	/ 7);

# Merge the bugs_working_qa_contact_description_length_severity_recast and profiles_working tables based on qa_contact & userid to add the severity types description mean length columns
setkey(bugs_working_qa_contact_description_length_severity_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_description_length_severity_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user was not set as qa_contact for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_enhancement_description_mean_length	= safe_ifelse(user_bugs_qa_contact_enhancement_description_mean_length	<= 0, NA, user_bugs_qa_contact_enhancement_description_mean_length),
                                             user_bugs_qa_contact_trivial_description_mean_length		= safe_ifelse(user_bugs_qa_contact_trivial_description_mean_length		<= 0, NA, user_bugs_qa_contact_trivial_description_mean_length),	
                                             user_bugs_qa_contact_minor_description_mean_length			= safe_ifelse(user_bugs_qa_contact_minor_description_mean_length		<= 0, NA, user_bugs_qa_contact_minor_description_mean_length),		
                                             user_bugs_qa_contact_normal_description_mean_length		= safe_ifelse(user_bugs_qa_contact_normal_description_mean_length		<= 0, NA, user_bugs_qa_contact_normal_description_mean_length),		
                                             user_bugs_qa_contact_major_description_mean_length			= safe_ifelse(user_bugs_qa_contact_major_description_mean_length		<= 0, NA, user_bugs_qa_contact_major_description_mean_length),		
                                             user_bugs_qa_contact_critical_description_mean_length		= safe_ifelse(user_bugs_qa_contact_critical_description_mean_length		<= 0, NA, user_bugs_qa_contact_critical_description_mean_length),	
                                             user_bugs_qa_contact_blocker_description_mean_length		= safe_ifelse(user_bugs_qa_contact_blocker_description_mean_length		<= 0, NA, user_bugs_qa_contact_blocker_description_mean_length),
											 user_bugs_qa_contact_all_types_description_mean_length		= safe_ifelse(user_bugs_qa_contact_all_types_description_mean_length	<= 0, NA, user_bugs_qa_contact_all_types_description_mean_length));	


# PROFILES-LONGDESCS_BUGS_REPORTED_SEVERITY_COMMENTS_MEAN_LENGTH
# (Calculate the mean comment length for the bugs that were reported by each user)

# We need to reduce the bugs_working table to just reporter + comments_mean_length + bug_severity
bugs_working_reporter_comments_mean_length_severity <- select(bugs_working, reporter, comments_mean_length, bug_severity);


# Use data.table's dcast() function to recast the table such that each row is a single "reporter" and there
# is a column with the mean comment length for each severity level of all the bugs reported by each user, defaulting to mean of 0 if no bugs of that severity were reported by a given user
bugs_working_reporter_comments_mean_length_severity_recast <- dcast(bugs_working_reporter_comments_mean_length_severity, reporter ~ bug_severity, drop=FALSE, value.var="comments_mean_length", fun=mean, fill=0, na.rm=TRUE);


# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_reporter_comments_mean_length_severity_recast <- transmute(bugs_working_reporter_comments_mean_length_severity_recast,  	
														   reporter 											= reporter,
														   user_bugs_reported_enhancement_comments_mean_length	= if (exists('enhancement',	where = bugs_working_reporter_comments_mean_length_severity_recast)) enhancement 	else 0,
														   user_bugs_reported_trivial_comments_mean_length		= if (exists('trivial',		where = bugs_working_reporter_comments_mean_length_severity_recast)) trivial 		else 0,
														   user_bugs_reported_minor_comments_mean_length		= if (exists('minor',		where = bugs_working_reporter_comments_mean_length_severity_recast)) minor 			else 0,
														   user_bugs_reported_normal_comments_mean_length		= if (exists('normal',		where = bugs_working_reporter_comments_mean_length_severity_recast)) normal 		else 0,
														   user_bugs_reported_major_comments_mean_length		= if (exists('major',		where = bugs_working_reporter_comments_mean_length_severity_recast)) major 			else 0,
														   user_bugs_reported_critical_comments_mean_length		= if (exists('critical',	where = bugs_working_reporter_comments_mean_length_severity_recast)) critical 		else 0,
														   user_bugs_reported_blocker_comments_mean_length		= if (exists('blocker',		where = bugs_working_reporter_comments_mean_length_severity_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean comment length for bugs for which each user reported
bugs_working_reporter_comments_mean_length_severity_recast <- mutate(bugs_working_reporter_comments_mean_length_severity_recast,
																	 user_bugs_reported_all_types_comments_mean_length = (user_bugs_reported_enhancement_comments_mean_length 	+
																														  user_bugs_reported_trivial_comments_mean_length 		+
																														  user_bugs_reported_minor_comments_mean_length 		+	
																														  user_bugs_reported_normal_comments_mean_length 		+
																														  user_bugs_reported_major_comments_mean_length 		+	
																														  user_bugs_reported_critical_comments_mean_length 		+
																														  user_bugs_reported_blocker_comments_mean_length) 		/ 7);
																																   
																																   
# Merge the bugs_working_reporter_comments_mean_length_severity_recast and profiles_working tables based on reporter & userid to add the severity types comment mean length columns
setkey(bugs_working_reporter_comments_mean_length_severity_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_comments_mean_length_severity_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user was not set as reporter for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
profiles_working <- mutate(profiles_working, user_bugs_reported_enhancement_comments_mean_length	= safe_ifelse(user_bugs_reported_enhancement_comments_mean_length	<= 0, NA, user_bugs_reported_enhancement_comments_mean_length),
                                             user_bugs_reported_trivial_comments_mean_length		= safe_ifelse(user_bugs_reported_trivial_comments_mean_length		<= 0, NA, user_bugs_reported_trivial_comments_mean_length),	
                                             user_bugs_reported_minor_comments_mean_length			= safe_ifelse(user_bugs_reported_minor_comments_mean_length			<= 0, NA, user_bugs_reported_minor_comments_mean_length),		
                                             user_bugs_reported_normal_comments_mean_length			= safe_ifelse(user_bugs_reported_normal_comments_mean_length		<= 0, NA, user_bugs_reported_normal_comments_mean_length),		
                                             user_bugs_reported_major_comments_mean_length			= safe_ifelse(user_bugs_reported_major_comments_mean_length			<= 0, NA, user_bugs_reported_major_comments_mean_length),		
                                             user_bugs_reported_critical_comments_mean_length		= safe_ifelse(user_bugs_reported_critical_comments_mean_length		<= 0, NA, user_bugs_reported_critical_comments_mean_length),	
                                             user_bugs_reported_blocker_comments_mean_length		= safe_ifelse(user_bugs_reported_blocker_comments_mean_length		<= 0, NA, user_bugs_reported_blocker_comments_mean_length),
											 user_bugs_reported_all_types_comments_mean_length		= safe_ifelse(user_bugs_reported_all_types_comments_mean_length		<= 0, NA, user_bugs_reported_all_types_comments_mean_length));	


# PROFILES-LONGDESCS_BUGS_ASSIGNED_SEVERITY_COMMENTS_MEAN_LENGTH
# (Calculate the mean comment length for the bugs that were assigned to each user)

# We need to reduce the bugs_working table to just assigned_to + comments_mean_length + bug_severity
bugs_working_assigned_to_comments_mean_length_severity <- select(bugs_working, assigned_to, comments_mean_length, bug_severity);


# Use data.table's dcast() function to recast the table such that each row is a single "assigned_to" and there
# is a column with the mean comment length for each severity level of the bugs each user was assigned, defaulting to mean of 0 if no bugs of that severity were assigned to a given user
bugs_working_assigned_to_comments_mean_length_severity_recast <- dcast(bugs_working_assigned_to_comments_mean_length_severity, assigned_to ~ bug_severity, drop=FALSE, value.var="comments_mean_length", fun=mean, fill=0, na.rm=TRUE);


# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_assigned_to_comments_mean_length_severity_recast <- transmute(bugs_working_assigned_to_comments_mean_length_severity_recast,  	
															  assigned_to 												= assigned_to,
															  user_bugs_assigned_to_enhancement_comments_mean_length	= if (exists('enhancement',	where = bugs_working_assigned_to_comments_mean_length_severity_recast)) enhancement	 else 0,
															  user_bugs_assigned_to_trivial_comments_mean_length		= if (exists('trivial',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) trivial 	 else 0,
															  user_bugs_assigned_to_minor_comments_mean_length			= if (exists('minor',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) minor 		 else 0,
															  user_bugs_assigned_to_normal_comments_mean_length			= if (exists('normal',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) normal 		 else 0,
															  user_bugs_assigned_to_major_comments_mean_length			= if (exists('major',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) major 		 else 0,
															  user_bugs_assigned_to_critical_comments_mean_length		= if (exists('critical',	where = bugs_working_assigned_to_comments_mean_length_severity_recast)) critical 	 else 0,
															  user_bugs_assigned_to_blocker_comments_mean_length		= if (exists('blocker',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) blocker 	 else 0);
																		
# Mutate to add the overall mean comment length for bugs for which each user was assigned_to
bugs_working_assigned_to_comments_mean_length_severity_recast <- mutate(bugs_working_assigned_to_comments_mean_length_severity_recast,
																	    user_bugs_assigned_to_all_types_comments_mean_length = (user_bugs_assigned_to_enhancement_comments_mean_length 	+
																																user_bugs_assigned_to_trivial_comments_mean_length 		+
																																user_bugs_assigned_to_minor_comments_mean_length 		+	
																																user_bugs_assigned_to_normal_comments_mean_length 		+
																																user_bugs_assigned_to_major_comments_mean_length 		+	
																																user_bugs_assigned_to_critical_comments_mean_length 	+
																																user_bugs_assigned_to_blocker_comments_mean_length) 	/ 7);
																																   
# Merge the bugs_working_assigned_to_comments_mean_length_severity_recast and profiles_working tables based on assigned_to & userid to add the severity types comment mean length columns
setkey(bugs_working_assigned_to_comments_mean_length_severity_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_comments_mean_length_severity_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user was not set as assigned_to for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_enhancement_comments_mean_length	= safe_ifelse(user_bugs_assigned_to_enhancement_comments_mean_length	<= 0, NA, user_bugs_assigned_to_enhancement_comments_mean_length),
                                             user_bugs_assigned_to_trivial_comments_mean_length		= safe_ifelse(user_bugs_assigned_to_trivial_comments_mean_length		<= 0, NA, user_bugs_assigned_to_trivial_comments_mean_length),	
                                             user_bugs_assigned_to_minor_comments_mean_length		= safe_ifelse(user_bugs_assigned_to_minor_comments_mean_length			<= 0, NA, user_bugs_assigned_to_minor_comments_mean_length),		
                                             user_bugs_assigned_to_normal_comments_mean_length		= safe_ifelse(user_bugs_assigned_to_normal_comments_mean_length			<= 0, NA, user_bugs_assigned_to_normal_comments_mean_length),		
                                             user_bugs_assigned_to_major_comments_mean_length		= safe_ifelse(user_bugs_assigned_to_major_comments_mean_length			<= 0, NA, user_bugs_assigned_to_major_comments_mean_length),		
                                             user_bugs_assigned_to_critical_comments_mean_length	= safe_ifelse(user_bugs_assigned_to_critical_comments_mean_length		<= 0, NA, user_bugs_assigned_to_critical_comments_mean_length),	
                                             user_bugs_assigned_to_blocker_comments_mean_length		= safe_ifelse(user_bugs_assigned_to_blocker_comments_mean_length		<= 0, NA, user_bugs_assigned_to_blocker_comments_mean_length),
											 user_bugs_assigned_to_all_types_comments_mean_length	= safe_ifelse(user_bugs_assigned_to_all_types_comments_mean_length		<= 0, NA, user_bugs_assigned_to_all_types_comments_mean_length));	
											 
											 
# PROFILES-LONGDESCS_BUGS_QA_CONTACT_SEVERITY_COMMENTS_MEAN_LENGTH
# (Calculate the mean comment length for the bugs for which each user was set as qa_contact)

# We need to reduce the bugs_working table to just qa_contact + comments_mean_length + bug_severity
bugs_working_qa_contact_comments_mean_length_severity <- select(bugs_working, qa_contact, comments_mean_length, bug_severity);


# Use data.table's dcast() function to recast the table such that each row is a single "qa_contact" and there
# is a column with the mean comment length for each severity level of each qa_contact bug, defaulting to mean of 0 if no bugs of that severity were qa_contact by a given user
bugs_working_qa_contact_comments_mean_length_severity_recast <- dcast(bugs_working_qa_contact_comments_mean_length_severity, qa_contact ~ bug_severity, drop=FALSE, value.var="comments_mean_length", fun=mean, fill=0, na.rm=TRUE);


# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_qa_contact_comments_mean_length_severity_recast <- transmute(bugs_working_qa_contact_comments_mean_length_severity_recast,  	
														     qa_contact 											= qa_contact,
														     user_bugs_qa_contact_enhancement_comments_mean_length	= if (exists('enhancement',	where = bugs_working_qa_contact_comments_mean_length_severity_recast)) enhancement 		else 0,
														     user_bugs_qa_contact_trivial_comments_mean_length		= if (exists('trivial',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) trivial 			else 0,
														     user_bugs_qa_contact_minor_comments_mean_length		= if (exists('minor',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) minor 			else 0,
														     user_bugs_qa_contact_normal_comments_mean_length		= if (exists('normal',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) normal 			else 0,
														     user_bugs_qa_contact_major_comments_mean_length		= if (exists('major',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) major 			else 0,
														     user_bugs_qa_contact_critical_comments_mean_length		= if (exists('critical',	where = bugs_working_qa_contact_comments_mean_length_severity_recast)) critical 		else 0,
														     user_bugs_qa_contact_blocker_comments_mean_length		= if (exists('blocker',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) blocker 			else 0);

# Mutate to add the overall mean comment length for bugs for which each user was qa_contact
bugs_working_qa_contact_comments_mean_length_severity_recast <- mutate(bugs_working_qa_contact_comments_mean_length_severity_recast,
																	   user_bugs_qa_contact_all_types_comments_mean_length = (user_bugs_qa_contact_enhancement_comments_mean_length +
																	                                                          user_bugs_qa_contact_trivial_comments_mean_length 	+
																	                                                          user_bugs_qa_contact_minor_comments_mean_length 		+	
																	                                                          user_bugs_qa_contact_normal_comments_mean_length 		+
																	                                                          user_bugs_qa_contact_major_comments_mean_length 		+	
																	                                                          user_bugs_qa_contact_critical_comments_mean_length 	+
																	                                                          user_bugs_qa_contact_blocker_comments_mean_length) 	/ 7);

# Merge the bugs_working_qa_contact_comments_mean_length_severity_recast and profiles_working tables based on qa_contact & userid to add the severity types comment mean length columns
setkey(bugs_working_qa_contact_comments_mean_length_severity_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_comments_mean_length_severity_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user was not set as qa_contact for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_enhancement_comments_mean_length	= safe_ifelse(user_bugs_qa_contact_enhancement_comments_mean_length		<= 0, NA, user_bugs_qa_contact_enhancement_comments_mean_length),
                                             user_bugs_qa_contact_trivial_comments_mean_length		= safe_ifelse(user_bugs_qa_contact_trivial_comments_mean_length			<= 0, NA, user_bugs_qa_contact_trivial_comments_mean_length),	
                                             user_bugs_qa_contact_minor_comments_mean_length		= safe_ifelse(user_bugs_qa_contact_minor_comments_mean_length			<= 0, NA, user_bugs_qa_contact_minor_comments_mean_length),		
                                             user_bugs_qa_contact_normal_comments_mean_length		= safe_ifelse(user_bugs_qa_contact_normal_comments_mean_length			<= 0, NA, user_bugs_qa_contact_normal_comments_mean_length),		
                                             user_bugs_qa_contact_major_comments_mean_length		= safe_ifelse(user_bugs_qa_contact_major_comments_mean_length			<= 0, NA, user_bugs_qa_contact_major_comments_mean_length),		
                                             user_bugs_qa_contact_critical_comments_mean_length		= safe_ifelse(user_bugs_qa_contact_critical_comments_mean_length		<= 0, NA, user_bugs_qa_contact_critical_comments_mean_length),	
                                             user_bugs_qa_contact_blocker_comments_mean_length		= safe_ifelse(user_bugs_qa_contact_blocker_comments_mean_length			<= 0, NA, user_bugs_qa_contact_blocker_comments_mean_length),
											 user_bugs_qa_contact_all_types_comments_mean_length	= safe_ifelse(user_bugs_qa_contact_all_types_comments_mean_length		<= 0, NA, user_bugs_qa_contact_all_types_comments_mean_length));	


# PROFILES-LONGDESCS-BUG_SEVERITY_COMMENTS
# (Count the number of comments each user made on bugs of each severity level)
# This count includes comments that are "automatic" as the result of an action by the user
# As a result, not all "comments" necessarily contain text, but all are related to deliberate user action

# Create a subset of the bugs_base table table that includes just bug_id, bug_severity
# We use bugs_base because user may have made comments on bugs that didn't have a defined org reporter/assigned/QA
bugs_working_bug_id_severity <- select(bugs_base, bug_id, bug_severity);

# Merge the bugs and longdescs tables to add the severity for each bug_id listed
# This will facilitate our next lookup by bug severity type
setkey(bugs_working_bug_id_severity, bug_id);
setkey(longdescs_base, bug_id);
longdescs_working <- merge(longdescs_base, bugs_working_bug_id_severity, by="bug_id", all.x=TRUE);

# Should be no NA entries possible, but a small number (currently only 1 out of ~10M entries) show up, 
# Leave them as is. They'll be imputed later as necessary as they are correctly "NA".
					
# Drop all the columns of the longdescs_working table other than "who" and bug_severity
# Also filter out any NA entries to not screw up bug_severity levels
longdescs_working_who_severity <- select(filter(longdescs_working, !(is.na(bug_severity))), who, bug_severity);
					
# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the comment count for each bug severity level, defaulting to 0 if no bugs of that severity were commented on
longdescs_working_who_severity_recast <- dcast(longdescs_working_who_severity, who ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length, fill=0);


# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
longdescs_working_who_severity_recast <- transmute(longdescs_working_who_severity_recast,  	
														     who 									= who,
														     user_comments_bugs_enhancement_count 	= if (exists('enhancement',	where = longdescs_working_who_severity_recast)) enhancement 	else 0,
														     user_comments_bugs_trivial_count		= if (exists('trivial',		where = longdescs_working_who_severity_recast)) trivial 		else 0,
														     user_comments_bugs_minor_count			= if (exists('minor',		where = longdescs_working_who_severity_recast)) minor 			else 0,
														     user_comments_bugs_normal_count		= if (exists('normal',		where = longdescs_working_who_severity_recast)) normal 			else 0,
														     user_comments_bugs_major_count			= if (exists('major',		where = longdescs_working_who_severity_recast)) major 			else 0,
														     user_comments_bugs_critical_count		= if (exists('critical',	where = longdescs_working_who_severity_recast)) critical 		else 0,
														     user_comments_bugs_blocker_count		= if (exists('blocker',		where = longdescs_working_who_severity_recast)) blocker 		else 0);

# Merge the longdescs_working_who_severity_recast and profiles_working tables based on who and userid to add the severity types comments count columns
setkey(longdescs_working_who_severity_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, longdescs_working_who_severity_recast, by.x="userid", by.y="who", all.x=TRUE);

# NA values mean that the user did not make any comments, so change it to 0
profiles_working <- mutate(profiles_working, user_comments_bugs_enhancement_count 	= safe_ifelse(is.na(user_comments_bugs_enhancement_count),	0, user_comments_bugs_enhancement_count),
                                             user_comments_bugs_trivial_count		= safe_ifelse(is.na(user_comments_bugs_trivial_count),		0, user_comments_bugs_trivial_count),
                                             user_comments_bugs_minor_count			= safe_ifelse(is.na(user_comments_bugs_minor_count), 		0, user_comments_bugs_minor_count),		
                                             user_comments_bugs_normal_count		= safe_ifelse(is.na(user_comments_bugs_normal_count),		0, user_comments_bugs_normal_count),	
                                             user_comments_bugs_major_count			= safe_ifelse(is.na(user_comments_bugs_major_count),		0, user_comments_bugs_major_count),		
                                             user_comments_bugs_critical_count		= safe_ifelse(is.na(user_comments_bugs_critical_count),		0, user_comments_bugs_critical_count),	
                                             user_comments_bugs_blocker_count		= safe_ifelse(is.na(user_comments_bugs_blocker_count),		0, user_comments_bugs_blocker_count));


# PROFILES-VOTES-BUG_SEVERITY
# (Count the votes made by each user on bugs of each severity level)

# Merge the bugs and votes tables to add the severity for each bug_id
setkey(bugs_working_bug_id_severity, bug_id);
setkey(votes_base, bug_id);
votes_working <- merge(votes_base, bugs_working_bug_id_severity, by="bug_id", all.x=TRUE);

# Should be no NA entries possible, but if any show up, they are correctly NA since there is no explanation for them


# Drop all the columns of the votes_working table other than "who" and bug_severity
# Also filter out any NA entries to not screw up bug_severity levels
votes_working_who_severity <- select(filter(votes_working, !(is.na(bug_severity))), who, bug_severity);
					
# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the votes count for each bug severity level, defaulting to 0 if no bugs of that severity were voted for by that user
votes_working_who_severity_recast <- dcast(votes_working_who_severity, who ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
votes_working_who_severity_recast <- transmute(votes_working_who_severity_recast,  	
														     who 									= who,
														     user_votes_bugs_enhancement_count 	= if (exists('enhancement',	where = votes_working_who_severity_recast)) enhancement 	else 0,
														     user_votes_bugs_trivial_count		= if (exists('trivial',		where = votes_working_who_severity_recast)) trivial 		else 0,
														     user_votes_bugs_minor_count		= if (exists('minor',		where = votes_working_who_severity_recast)) minor 			else 0,
														     user_votes_bugs_normal_count		= if (exists('normal',		where = votes_working_who_severity_recast)) normal 			else 0,
														     user_votes_bugs_major_count		= if (exists('major',		where = votes_working_who_severity_recast)) major 			else 0,
														     user_votes_bugs_critical_count		= if (exists('critical',	where = votes_working_who_severity_recast)) critical 		else 0,
														     user_votes_bugs_blocker_count		= if (exists('blocker',		where = votes_working_who_severity_recast)) blocker 		else 0);

# Mutate to add the overall count of votes by each user on all types of bugs
votes_working_who_severity_recast <- mutate(votes_working_who_severity_recast,
																	   user_votes_all_bugs_count =  user_votes_bugs_enhancement_count 	+
																	                                user_votes_bugs_trivial_count		+
																	                                user_votes_bugs_minor_count			+
																	                                user_votes_bugs_normal_count		+
																	                                user_votes_bugs_major_count			+
																	                                user_votes_bugs_critical_count		+
																	                                user_votes_bugs_blocker_count);
																	   																	   
# Merge the votes_working_who_severity_recast and profiles_working tables based on who and userid to add the severity types votes count columns
setkey(votes_working_who_severity_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, votes_working_who_severity_recast, by.x="userid", by.y="who", all.x=TRUE);

# NA values mean that the user did not vote on any bugs, so change it to 0
profiles_working <- mutate(profiles_working, user_votes_bugs_enhancement_count 	= safe_ifelse(is.na(user_votes_bugs_enhancement_count),	0, user_votes_bugs_enhancement_count),
                                             user_votes_bugs_trivial_count		= safe_ifelse(is.na(user_votes_bugs_trivial_count),		0, user_votes_bugs_trivial_count),
                                             user_votes_bugs_minor_count		= safe_ifelse(is.na(user_votes_bugs_minor_count), 		0, user_votes_bugs_minor_count),		
                                             user_votes_bugs_normal_count		= safe_ifelse(is.na(user_votes_bugs_normal_count),		0, user_votes_bugs_normal_count),	
                                             user_votes_bugs_major_count		= safe_ifelse(is.na(user_votes_bugs_major_count),		0, user_votes_bugs_major_count),		
                                             user_votes_bugs_critical_count		= safe_ifelse(is.na(user_votes_bugs_critical_count),	0, user_votes_bugs_critical_count),	
                                             user_votes_bugs_blocker_count		= safe_ifelse(is.na(user_votes_bugs_blocker_count),		0, user_votes_bugs_blocker_count),
											 user_votes_all_bugs_count			= safe_ifelse(is.na(user_votes_all_bugs_count), 		0, user_votes_all_bugs_count));


# PROFILES-CC-BUG_SEVERITY
# (Count number of bugs that each user is following for each bug severity level)

# Merge the bugs and cc tables to add the severity for each bug_id
setkey(bugs_working_bug_id_severity, bug_id);
setkey(cc_base, bug_id);
cc_working <- merge(cc_base, bugs_working_bug_id_severity, by="bug_id", all.x=TRUE);

# Should be no NA entries possible, but if any show up, they are correctly NA since there is no explanation for them


# Drop all the columns of the cc_working table other than "who" and bug_severity
# Also filter out any NA entries to not screw up bug_severity levels
cc_working_who_severity <- select(filter(cc_working, !(is.na(bug_severity))), who, bug_severity);
					
# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the cc count for each bug severity level, defaulting to 0 if no bugs of that severity were followed by that user
cc_working_who_severity_recast <- dcast(cc_working_who_severity, who ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
cc_working_who_severity_recast <- transmute(cc_working_who_severity_recast,  	
														     who 								= who,
														     user_cc_bugs_enhancement_count 	= if (exists('enhancement',	where = cc_working_who_severity_recast)) enhancement 	else 0,
														     user_cc_bugs_trivial_count			= if (exists('trivial',		where = cc_working_who_severity_recast)) trivial 		else 0,
														     user_cc_bugs_minor_count			= if (exists('minor',		where = cc_working_who_severity_recast)) minor 			else 0,
														     user_cc_bugs_normal_count			= if (exists('normal',		where = cc_working_who_severity_recast)) normal 		else 0,
														     user_cc_bugs_major_count			= if (exists('major',		where = cc_working_who_severity_recast)) major 			else 0,
														     user_cc_bugs_critical_count		= if (exists('critical',	where = cc_working_who_severity_recast)) critical 		else 0,
														     user_cc_bugs_blocker_count			= if (exists('blocker',		where = cc_working_who_severity_recast)) blocker 		else 0);

# Mutate to add the overall count of cc's by each user on all types of bugs
cc_working_who_severity_recast <- mutate(cc_working_who_severity_recast, user_cc_all_bugs_count =  user_cc_bugs_enhancement_count 	+
																	                               user_cc_bugs_trivial_count		+
																	                               user_cc_bugs_minor_count			+
																	                               user_cc_bugs_normal_count		+
																	                               user_cc_bugs_major_count			+
																	                               user_cc_bugs_critical_count		+
																	                               user_cc_bugs_blocker_count);
																	   																	   
# Merge the cc_working_who_severity_recast and profiles_working tables based on who and userid to add the severity types cc count columns
setkey(cc_working_who_severity_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, cc_working_who_severity_recast, by.x="userid", by.y="who", all.x=TRUE);

# NA values mean that the user did not cc any bugs, so change it to 0
profiles_working <- mutate(profiles_working, user_cc_bugs_enhancement_count 	= safe_ifelse(is.na(user_cc_bugs_enhancement_count),	0, user_cc_bugs_enhancement_count),
                                             user_cc_bugs_trivial_count			= safe_ifelse(is.na(user_cc_bugs_trivial_count),		0, user_cc_bugs_trivial_count),
                                             user_cc_bugs_minor_count			= safe_ifelse(is.na(user_cc_bugs_minor_count), 			0, user_cc_bugs_minor_count),		
                                             user_cc_bugs_normal_count			= safe_ifelse(is.na(user_cc_bugs_normal_count),			0, user_cc_bugs_normal_count),	
                                             user_cc_bugs_major_count			= safe_ifelse(is.na(user_cc_bugs_major_count),			0, user_cc_bugs_major_count),		
                                             user_cc_bugs_critical_count		= safe_ifelse(is.na(user_cc_bugs_critical_count),		0, user_cc_bugs_critical_count),	
                                             user_cc_bugs_blocker_count			= safe_ifelse(is.na(user_cc_bugs_blocker_count),		0, user_cc_bugs_blocker_count),
											 user_cc_all_bugs_count				= safe_ifelse(is.na(user_cc_all_bugs_count), 			0, user_cc_all_bugs_count));
											 
											 
# PROFILES-BUGS_REPORTED_OUTCOME
# (Count the number of bugs that each user reported for each outcome status of fixed, not_fixed, and pending)

# Isolate the reporter & outcome columns of bugs_working
bugs_working_reporter_outcome <- select(bugs_working, reporter, outcome);
				
# Use data.table's dcast() function to recast the table such that each row is a single "reporter" and there
# is a column with the count of each outcome for all the bugs each user reported, defaulting to 0 if the reporter has no bugs of that outcome level
bugs_working_reporter_outcome_recast <- dcast(bugs_working_reporter_outcome, reporter ~ outcome, drop=FALSE, value.var="outcome", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of outcome levels for the given dataset
bugs_working_reporter_outcome_recast <- transmute(bugs_working_reporter_outcome_recast,  	
														     reporter 						= reporter,
														     user_bugs_reported_fixed_count			= if (exists('fixed',		where = bugs_working_reporter_outcome_recast)) fixed 		else 0,
														     user_bugs_reported_not_fixed_count		= if (exists('not_fixed',	where = bugs_working_reporter_outcome_recast)) not_fixed 	else 0,
														     user_bugs_reported_pending_count		= if (exists('pending',		where = bugs_working_reporter_outcome_recast)) pending 		else 0);
									   																	   
# Merge the bugs_working_reporter_outcome_recast and profiles_working tables based on reporter and userid to add the outcome count columns
setkey(bugs_working_reporter_outcome_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_outcome_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user did not report any bugs, so change it to 0
profiles_working <- mutate(profiles_working, user_bugs_reported_fixed_count			= safe_ifelse(is.na(user_bugs_reported_fixed_count),	 0, user_bugs_reported_fixed_count),	
                                             user_bugs_reported_not_fixed_count		= safe_ifelse(is.na(user_bugs_reported_not_fixed_count), 0, user_bugs_reported_not_fixed_count),
											 user_bugs_reported_pending_count		= safe_ifelse(is.na(user_bugs_reported_pending_count),   0, user_bugs_reported_pending_count));
											 											 

# PROFILES-BUGS_ASSIGNED_TO_OUTCOME
# (Count the number of bugs to which each user is assigned for each outcome status of fixed, not_fixed, and pending)

# Isolate the assigned_to & outcome columns of bugs_working
bugs_working_assigned_to_outcome <- select(bugs_working, assigned_to, outcome);
				
# Use data.table's dcast() function to recast the table such that each row is a single "assigned_to" and there
# is a column with the count of each outcome for all the bugs each user was assigned_to, defaulting to 0 if the user was not assigned any bugs of that outcome level
bugs_working_assigned_to_outcome_recast <- dcast(bugs_working_assigned_to_outcome, assigned_to ~ outcome, drop=FALSE, value.var="outcome", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of outcome levels for the given dataset
bugs_working_assigned_to_outcome_recast <- transmute(bugs_working_assigned_to_outcome_recast,  	
														     assigned_to 								= assigned_to,
														     user_bugs_assigned_to_fixed_count			= if (exists('fixed',		where = bugs_working_assigned_to_outcome_recast)) fixed 		else 0,
														     user_bugs_assigned_to_not_fixed_count		= if (exists('not_fixed',	where = bugs_working_assigned_to_outcome_recast)) not_fixed 	else 0,
														     user_bugs_assigned_to_pending_count		= if (exists('pending',		where = bugs_working_assigned_to_outcome_recast)) pending 		else 0);
									   																	   
# Merge the bugs_working_assigned_to_outcome_recast and profiles_working tables based on assigned_to and userid to add the outcome count columns
setkey(bugs_working_assigned_to_outcome_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_outcome_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user did not report any bugs, so change it to 0
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_fixed_count			= safe_ifelse(is.na(user_bugs_assigned_to_fixed_count),		0, user_bugs_assigned_to_fixed_count),	
                                             user_bugs_assigned_to_not_fixed_count		= safe_ifelse(is.na(user_bugs_assigned_to_not_fixed_count), 0, user_bugs_assigned_to_not_fixed_count),
											 user_bugs_assigned_to_pending_count		= safe_ifelse(is.na(user_bugs_assigned_to_pending_count),   0, user_bugs_assigned_to_pending_count));

											 
# PROFILES-BUGS_QA_CONTACT_OUTCOME
# (Count the number of bugs for which each user is set as qa_contact for each outcome status of fixed, not_fixed, and pending)

# Isolate the qa_contact & outcome columns of bugs_working
bugs_working_qa_contact_outcome <- select(bugs_working, qa_contact, outcome);
				
# Use data.table's dcast() function to recast the table such that each row is a single "qa_contact" and there
# is a column with the count of each outcome for all the bugs for which each user is set as qa_contact, defaulting to 0 if the user was not set as qa_contact for any bugs of that outcome level
bugs_working_qa_contact_outcome_recast <- dcast(bugs_working_qa_contact_outcome, qa_contact ~ outcome, drop=FALSE, value.var="outcome", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of outcome levels for the given dataset
bugs_working_qa_contact_outcome_recast <- transmute(bugs_working_qa_contact_outcome_recast,  	
														     qa_contact 							= qa_contact,
														     user_bugs_qa_contact_fixed_count		= if (exists('fixed',		where = bugs_working_qa_contact_outcome_recast)) fixed 		else 0,
														     user_bugs_qa_contact_not_fixed_count	= if (exists('not_fixed',	where = bugs_working_qa_contact_outcome_recast)) not_fixed 	else 0,
														     user_bugs_qa_contact_pending_count		= if (exists('pending',		where = bugs_working_qa_contact_outcome_recast)) pending 	else 0);
									   																	   
# Merge the bugs_working_qa_contact_outcome_recast and profiles_working tables based on qa_contact and userid to add the outcome count columns
setkey(bugs_working_qa_contact_outcome_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_outcome_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user did not report any bugs, so change it to 0
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_fixed_count		= safe_ifelse(is.na(user_bugs_qa_contact_fixed_count),		0, user_bugs_qa_contact_fixed_count),	
                                             user_bugs_qa_contact_not_fixed_count	= safe_ifelse(is.na(user_bugs_qa_contact_not_fixed_count),	0, user_bugs_qa_contact_not_fixed_count),
											 user_bugs_qa_contact_pending_count		= safe_ifelse(is.na(user_bugs_qa_contact_pending_count),	0, user_bugs_qa_contact_pending_count));

	
# PROFILES-BUG_SEVERITY_USER_REPORTED_MEAN_DAYS_TO_RESOLVED
# (Calculate the mean days_to_last_resolved for bugs reported by each user for each severity level)

# Isolate the reporter, bug_severity, and days_to_last_resolved columns of bugs_working
bugs_working_reporter_severity_days_to_last_resolved <- select(bugs_working, reporter, bug_severity, days_to_last_resolved);

# Use data.table's dcast() function to recast the table such that each row is a single "reporter" and there
# is a column with the mean	days_to_last_resolved for all the bugs each user reported for each severity level, defaulting to NA if the user did not report any bugs of that severity level
bugs_working_reporter_severity_days_to_last_resolved_recast <- dcast(bugs_working_reporter_severity_days_to_last_resolved, reporter ~ bug_severity, drop=FALSE, value.var="days_to_last_resolved", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_reporter_severity_days_to_last_resolved_recast <- transmute(bugs_working_reporter_severity_days_to_last_resolved_recast,  	
															reporter 													= reporter,
															user_bugs_reported_enhancement_mean_days_to_last_resolved	= if (exists('enhancement',	where = bugs_working_reporter_severity_days_to_last_resolved_recast)) enhancement 	else 0,
															user_bugs_reported_trivial_mean_days_to_last_resolved		= if (exists('trivial',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) trivial 		else 0,
															user_bugs_reported_minor_mean_days_to_last_resolved			= if (exists('minor',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) minor 		else 0,
															user_bugs_reported_normal_mean_days_to_last_resolved		= if (exists('normal',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) normal 		else 0,
															user_bugs_reported_major_mean_days_to_last_resolved			= if (exists('major',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) major 		else 0,
															user_bugs_reported_critical_mean_days_to_last_resolved		= if (exists('critical',	where = bugs_working_reporter_severity_days_to_last_resolved_recast)) critical 		else 0,
															user_bugs_reported_blocker_mean_days_to_last_resolved		= if (exists('blocker',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs each user reported
bugs_working_reporter_severity_days_to_last_resolved_recast <- mutate(bugs_working_reporter_severity_days_to_last_resolved_recast,
																	 user_bugs_reported_all_types_mean_days_to_last_resolved = (user_bugs_reported_enhancement_mean_days_to_last_resolved 	+
																																user_bugs_reported_trivial_mean_days_to_last_resolved 		+
																																user_bugs_reported_minor_mean_days_to_last_resolved 		+	
																																user_bugs_reported_normal_mean_days_to_last_resolved 		+
																																user_bugs_reported_major_mean_days_to_last_resolved 		+	
																																user_bugs_reported_critical_mean_days_to_last_resolved 		+
																																user_bugs_reported_blocker_mean_days_to_last_resolved) 		/ 7);
																																   
																																   
# Merge the bugs_working_reporter_severity_days_to_last_resolved_recast and profiles_working tables based on reporter & userid to add the severity types description mean times columns
setkey(bugs_working_reporter_severity_days_to_last_resolved_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_severity_days_to_last_resolved_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user was not set as reporter for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
profiles_working <- mutate(profiles_working, user_bugs_reported_enhancement_mean_days_to_last_resolved	= safe_ifelse(user_bugs_reported_enhancement_mean_days_to_last_resolved	<= 0, NA, user_bugs_reported_enhancement_mean_days_to_last_resolved),
                                             user_bugs_reported_trivial_mean_days_to_last_resolved		= safe_ifelse(user_bugs_reported_trivial_mean_days_to_last_resolved		<= 0, NA, user_bugs_reported_trivial_mean_days_to_last_resolved),	
                                             user_bugs_reported_minor_mean_days_to_last_resolved		= safe_ifelse(user_bugs_reported_minor_mean_days_to_last_resolved		<= 0, NA, user_bugs_reported_minor_mean_days_to_last_resolved),		
                                             user_bugs_reported_normal_mean_days_to_last_resolved		= safe_ifelse(user_bugs_reported_normal_mean_days_to_last_resolved		<= 0, NA, user_bugs_reported_normal_mean_days_to_last_resolved),		
                                             user_bugs_reported_major_mean_days_to_last_resolved		= safe_ifelse(user_bugs_reported_major_mean_days_to_last_resolved		<= 0, NA, user_bugs_reported_major_mean_days_to_last_resolved),		
                                             user_bugs_reported_critical_mean_days_to_last_resolved		= safe_ifelse(user_bugs_reported_critical_mean_days_to_last_resolved	<= 0, NA, user_bugs_reported_critical_mean_days_to_last_resolved),	
                                             user_bugs_reported_blocker_mean_days_to_last_resolved		= safe_ifelse(user_bugs_reported_blocker_mean_days_to_last_resolved	  	<= 0, NA, user_bugs_reported_blocker_mean_days_to_last_resolved),
											 user_bugs_reported_all_types_mean_days_to_last_resolved	= safe_ifelse(user_bugs_reported_all_types_mean_days_to_last_resolved 	<= 0, NA, user_bugs_reported_all_types_mean_days_to_last_resolved));	

	
# PROFILES-BUG_SEVERITY_USER_REPORTED_MEAN_DAYS_OPEN
# (Calculate the mean days_open for bugs reported by each user for each severity level)

# Isolate the reporter, bug_severity, and days_open columns of bugs_working
bugs_working_reporter_severity_days_open <- select(bugs_working, reporter, bug_severity, days_open);

# Use data.table's dcast() function to recast the table such that each row is a single "reporter" and there
# is a column with the mean	days_open for all the bugs each user reported for each severity level, defaulting to NA if the user did not report any bugs of that severity level
bugs_working_reporter_severity_days_open_recast <- dcast(bugs_working_reporter_severity_days_open, reporter ~ bug_severity, drop=FALSE, value.var="days_open", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_reporter_severity_days_open_recast <- transmute(bugs_working_reporter_severity_days_open_recast,  	
															reporter 										= reporter,
															user_bugs_reported_enhancement_mean_days_open	= if (exists('enhancement',	where = bugs_working_reporter_severity_days_open_recast)) enhancement 	else 0,
															user_bugs_reported_trivial_mean_days_open		= if (exists('trivial',		where = bugs_working_reporter_severity_days_open_recast)) trivial 		else 0,
															user_bugs_reported_minor_mean_days_open			= if (exists('minor',		where = bugs_working_reporter_severity_days_open_recast)) minor 		else 0,
															user_bugs_reported_normal_mean_days_open		= if (exists('normal',		where = bugs_working_reporter_severity_days_open_recast)) normal 		else 0,
															user_bugs_reported_major_mean_days_open			= if (exists('major',		where = bugs_working_reporter_severity_days_open_recast)) major 		else 0,
															user_bugs_reported_critical_mean_days_open		= if (exists('critical',	where = bugs_working_reporter_severity_days_open_recast)) critical 		else 0,
															user_bugs_reported_blocker_mean_days_open		= if (exists('blocker',		where = bugs_working_reporter_severity_days_open_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs each user reported
bugs_working_reporter_severity_days_open_recast <- mutate(bugs_working_reporter_severity_days_open_recast,
																	 user_bugs_reported_all_types_mean_days_open = (user_bugs_reported_enhancement_mean_days_open 	+
																													user_bugs_reported_trivial_mean_days_open 		+
																													user_bugs_reported_minor_mean_days_open 		+	
																													user_bugs_reported_normal_mean_days_open 		+
																													user_bugs_reported_major_mean_days_open 		+	
																													user_bugs_reported_critical_mean_days_open 		+
																													user_bugs_reported_blocker_mean_days_open) 		/ 7);
																																   
																																   
# Merge the bugs_working_reporter_severity_days_open_recast and profiles_working tables based on reporter & userid to add the severity types description mean times columns
setkey(bugs_working_reporter_severity_days_open_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_severity_days_open_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user was not set as reporter for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
profiles_working <- mutate(profiles_working, user_bugs_reported_enhancement_mean_days_open	= safe_ifelse(user_bugs_reported_enhancement_mean_days_open	<= 0, NA, user_bugs_reported_enhancement_mean_days_open),
                                             user_bugs_reported_trivial_mean_days_open		= safe_ifelse(user_bugs_reported_trivial_mean_days_open		<= 0, NA, user_bugs_reported_trivial_mean_days_open),	
                                             user_bugs_reported_minor_mean_days_open		= safe_ifelse(user_bugs_reported_minor_mean_days_open		<= 0, NA, user_bugs_reported_minor_mean_days_open),		
                                             user_bugs_reported_normal_mean_days_open		= safe_ifelse(user_bugs_reported_normal_mean_days_open		<= 0, NA, user_bugs_reported_normal_mean_days_open),		
                                             user_bugs_reported_major_mean_days_open		= safe_ifelse(user_bugs_reported_major_mean_days_open		<= 0, NA, user_bugs_reported_major_mean_days_open),		
                                             user_bugs_reported_critical_mean_days_open		= safe_ifelse(user_bugs_reported_critical_mean_days_open	<= 0, NA, user_bugs_reported_critical_mean_days_open),	
                                             user_bugs_reported_blocker_mean_days_open		= safe_ifelse(user_bugs_reported_blocker_mean_days_open	  	<= 0, NA, user_bugs_reported_blocker_mean_days_open),
											 user_bugs_reported_all_types_mean_days_open	= safe_ifelse(user_bugs_reported_all_types_mean_days_open 	<= 0, NA, user_bugs_reported_all_types_mean_days_open));	

		
# PROFILES-BUG_SEVERITY_USER_ASSIGNED_TO_MEAN_DAYS_TO_RESOLVED
# (Calculate the mean days_to_last_resolved for bugs assigned_to by each user for each severity level)

# Isolate the assigned_to, bug_severity, and days_to_last_resolved columns of bugs_working
bugs_working_assigned_to_severity_days_to_last_resolved <- select(bugs_working, assigned_to, bug_severity, days_to_last_resolved);

# Use data.table's dcast() function to recast the table such that each row is a single "assigned_to" and there
# is a column with the mean	days_to_last_resolved for all the bugs to which each user was assigned for each severity level, defaulting to NA if the user did not get assigned_to any bugs of that severity level
bugs_working_assigned_to_severity_days_to_last_resolved_recast <- dcast(bugs_working_assigned_to_severity_days_to_last_resolved, assigned_to ~ bug_severity, drop=FALSE, value.var="days_to_last_resolved", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_assigned_to_severity_days_to_last_resolved_recast <- transmute(bugs_working_assigned_to_severity_days_to_last_resolved_recast,  	
															assigned_to 													= assigned_to,
															user_bugs_assigned_to_enhancement_mean_days_to_last_resolved	= if (exists('enhancement',	where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) enhancement 	else 0,
															user_bugs_assigned_to_trivial_mean_days_to_last_resolved		= if (exists('trivial',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) trivial 		else 0,
															user_bugs_assigned_to_minor_mean_days_to_last_resolved			= if (exists('minor',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) minor 			else 0,
															user_bugs_assigned_to_normal_mean_days_to_last_resolved			= if (exists('normal',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) normal 		else 0,
															user_bugs_assigned_to_major_mean_days_to_last_resolved			= if (exists('major',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) major 			else 0,
															user_bugs_assigned_to_critical_mean_days_to_last_resolved		= if (exists('critical',	where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) critical 		else 0,
															user_bugs_assigned_to_blocker_mean_days_to_last_resolved		= if (exists('blocker',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs to which each user was assigned
bugs_working_assigned_to_severity_days_to_last_resolved_recast <- mutate(bugs_working_assigned_to_severity_days_to_last_resolved_recast,
																	     user_bugs_assigned_to_all_types_mean_days_to_last_resolved = (user_bugs_assigned_to_enhancement_mean_days_to_last_resolved +
																																	   user_bugs_assigned_to_trivial_mean_days_to_last_resolved 	+
																																	   user_bugs_assigned_to_minor_mean_days_to_last_resolved 		+	
																																	   user_bugs_assigned_to_normal_mean_days_to_last_resolved 		+
																																	   user_bugs_assigned_to_major_mean_days_to_last_resolved 		+	
																																	   user_bugs_assigned_to_critical_mean_days_to_last_resolved 	+
																																	   user_bugs_assigned_to_blocker_mean_days_to_last_resolved) 	/ 7);
																																   
																																   
# Merge the bugs_working_assigned_to_severity_days_to_last_resolved_recast and profiles_working tables based on assigned_to & userid to add the severity types description mean times columns
setkey(bugs_working_assigned_to_severity_days_to_last_resolved_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_severity_days_to_last_resolved_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user was not set as assigned_to for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_enhancement_mean_days_to_last_resolved	= safe_ifelse(user_bugs_assigned_to_enhancement_mean_days_to_last_resolved	<= 0, NA, user_bugs_assigned_to_enhancement_mean_days_to_last_resolved),
                                             user_bugs_assigned_to_trivial_mean_days_to_last_resolved		= safe_ifelse(user_bugs_assigned_to_trivial_mean_days_to_last_resolved		<= 0, NA, user_bugs_assigned_to_trivial_mean_days_to_last_resolved),	
                                             user_bugs_assigned_to_minor_mean_days_to_last_resolved			= safe_ifelse(user_bugs_assigned_to_minor_mean_days_to_last_resolved		<= 0, NA, user_bugs_assigned_to_minor_mean_days_to_last_resolved),		
                                             user_bugs_assigned_to_normal_mean_days_to_last_resolved		= safe_ifelse(user_bugs_assigned_to_normal_mean_days_to_last_resolved		<= 0, NA, user_bugs_assigned_to_normal_mean_days_to_last_resolved),		
                                             user_bugs_assigned_to_major_mean_days_to_last_resolved			= safe_ifelse(user_bugs_assigned_to_major_mean_days_to_last_resolved		<= 0, NA, user_bugs_assigned_to_major_mean_days_to_last_resolved),		
                                             user_bugs_assigned_to_critical_mean_days_to_last_resolved		= safe_ifelse(user_bugs_assigned_to_critical_mean_days_to_last_resolved		<= 0, NA, user_bugs_assigned_to_critical_mean_days_to_last_resolved),	
                                             user_bugs_assigned_to_blocker_mean_days_to_last_resolved		= safe_ifelse(user_bugs_assigned_to_blocker_mean_days_to_last_resolved	  	<= 0, NA, user_bugs_assigned_to_blocker_mean_days_to_last_resolved),
											 user_bugs_assigned_to_all_types_mean_days_to_last_resolved		= safe_ifelse(user_bugs_assigned_to_all_types_mean_days_to_last_resolved 	<= 0, NA, user_bugs_assigned_to_all_types_mean_days_to_last_resolved));	

	
# PROFILES-BUG_SEVERITY_USER_ASSIGNED_TO_MEAN_DAYS_OPEN
# (Calculate the mean days_open for bugs assigned_to by each user for each severity level)

# Isolate the assigned_to, bug_severity, and days_open columns of bugs_working
bugs_working_assigned_to_severity_days_open <- select(bugs_working, assigned_to, bug_severity, days_open);

# Use data.table's dcast() function to recast the table such that each row is a single "assigned_to" and there
# is a column with the mean	days_open for all the bugs to which each user each user was assigned for each severity level, defaulting to NA if the user did not get assigned_to any bugs of that severity level
bugs_working_assigned_to_severity_days_open_recast <- dcast(bugs_working_assigned_to_severity_days_open, assigned_to ~ bug_severity, drop=FALSE, value.var="days_open", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_assigned_to_severity_days_open_recast <- transmute(bugs_working_assigned_to_severity_days_open_recast,  	
															assigned_to 										= assigned_to,
															user_bugs_assigned_to_enhancement_mean_days_open	= if (exists('enhancement',	where = bugs_working_assigned_to_severity_days_open_recast)) enhancement 	else 0,
															user_bugs_assigned_to_trivial_mean_days_open		= if (exists('trivial',		where = bugs_working_assigned_to_severity_days_open_recast)) trivial 		else 0,
															user_bugs_assigned_to_minor_mean_days_open			= if (exists('minor',		where = bugs_working_assigned_to_severity_days_open_recast)) minor 			else 0,
															user_bugs_assigned_to_normal_mean_days_open			= if (exists('normal',		where = bugs_working_assigned_to_severity_days_open_recast)) normal 		else 0,
															user_bugs_assigned_to_major_mean_days_open			= if (exists('major',		where = bugs_working_assigned_to_severity_days_open_recast)) major 			else 0,
															user_bugs_assigned_to_critical_mean_days_open		= if (exists('critical',	where = bugs_working_assigned_to_severity_days_open_recast)) critical 		else 0,
															user_bugs_assigned_to_blocker_mean_days_open		= if (exists('blocker',		where = bugs_working_assigned_to_severity_days_open_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs to which each user was assigned
bugs_working_assigned_to_severity_days_open_recast <- mutate(bugs_working_assigned_to_severity_days_open_recast,
																	 user_bugs_assigned_to_all_types_mean_days_open = (user_bugs_assigned_to_enhancement_mean_days_open +
																													   user_bugs_assigned_to_trivial_mean_days_open 	+
																													   user_bugs_assigned_to_minor_mean_days_open 		+	
																													   user_bugs_assigned_to_normal_mean_days_open 		+
																													   user_bugs_assigned_to_major_mean_days_open 		+	
																													   user_bugs_assigned_to_critical_mean_days_open 	+
																													   user_bugs_assigned_to_blocker_mean_days_open) 	/ 7);
																																   
																																   
# Merge the bugs_working_assigned_to_severity_days_open_recast and profiles_working tables based on assigned_to & userid to add the severity types description mean times columns
setkey(bugs_working_assigned_to_severity_days_open_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_severity_days_open_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user was not set as assigned_to for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
profiles_working <- mutate(profiles_working, user_bugs_assigned_to_enhancement_mean_days_open	= safe_ifelse(user_bugs_assigned_to_enhancement_mean_days_open	<= 0, NA, user_bugs_assigned_to_enhancement_mean_days_open),
                                             user_bugs_assigned_to_trivial_mean_days_open		= safe_ifelse(user_bugs_assigned_to_trivial_mean_days_open		<= 0, NA, user_bugs_assigned_to_trivial_mean_days_open),	
                                             user_bugs_assigned_to_minor_mean_days_open			= safe_ifelse(user_bugs_assigned_to_minor_mean_days_open		<= 0, NA, user_bugs_assigned_to_minor_mean_days_open),		
                                             user_bugs_assigned_to_normal_mean_days_open		= safe_ifelse(user_bugs_assigned_to_normal_mean_days_open		<= 0, NA, user_bugs_assigned_to_normal_mean_days_open),		
                                             user_bugs_assigned_to_major_mean_days_open			= safe_ifelse(user_bugs_assigned_to_major_mean_days_open		<= 0, NA, user_bugs_assigned_to_major_mean_days_open),		
                                             user_bugs_assigned_to_critical_mean_days_open		= safe_ifelse(user_bugs_assigned_to_critical_mean_days_open		<= 0, NA, user_bugs_assigned_to_critical_mean_days_open),	
                                             user_bugs_assigned_to_blocker_mean_days_open		= safe_ifelse(user_bugs_assigned_to_blocker_mean_days_open	  	<= 0, NA, user_bugs_assigned_to_blocker_mean_days_open),
											 user_bugs_assigned_to_all_types_mean_days_open		= safe_ifelse(user_bugs_assigned_to_all_types_mean_days_open 	<= 0, NA, user_bugs_assigned_to_all_types_mean_days_open));	


# PROFILES-BUG_SEVERITY_USER_QA_CONTACT_MEAN_DAYS_TO_RESOLVED
# (Calculate the mean days_to_last_resolved for bugs for which each user was set as qa_contact for each severity level)

# Isolate the qa_contact, bug_severity, and days_to_last_resolved columns of bugs_working
bugs_working_qa_contact_severity_days_to_last_resolved <- select(bugs_working, qa_contact, bug_severity, days_to_last_resolved);

# Use data.table's dcast() function to recast the table such that each row is a single "qa_contact" and there
# is a column with the mean	days_to_last_resolved for all the bugs to which each user was set as qa_contact for each severity level, defaulting to NA if the user did not get set as qa_contact for any bugs of that severity level
bugs_working_qa_contact_severity_days_to_last_resolved_recast <- dcast(bugs_working_qa_contact_severity_days_to_last_resolved, qa_contact ~ bug_severity, drop=FALSE, value.var="days_to_last_resolved", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_qa_contact_severity_days_to_last_resolved_recast <- transmute(bugs_working_qa_contact_severity_days_to_last_resolved_recast,  	
															qa_contact 													= qa_contact,
															user_bugs_qa_contact_enhancement_mean_days_to_last_resolved	= if (exists('enhancement',	where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) enhancement 	else 0,
															user_bugs_qa_contact_trivial_mean_days_to_last_resolved		= if (exists('trivial',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) trivial 		else 0,
															user_bugs_qa_contact_minor_mean_days_to_last_resolved		= if (exists('minor',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) minor 			else 0,
															user_bugs_qa_contact_normal_mean_days_to_last_resolved		= if (exists('normal',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) normal 			else 0,
															user_bugs_qa_contact_major_mean_days_to_last_resolved		= if (exists('major',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) major 			else 0,
															user_bugs_qa_contact_critical_mean_days_to_last_resolved	= if (exists('critical',	where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) critical 		else 0,
															user_bugs_qa_contact_blocker_mean_days_to_last_resolved		= if (exists('blocker',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs for which each user was set as qa_contact
bugs_working_qa_contact_severity_days_to_last_resolved_recast <- mutate(bugs_working_qa_contact_severity_days_to_last_resolved_recast,
																	     user_bugs_qa_contact_all_types_mean_days_to_last_resolved = (user_bugs_qa_contact_enhancement_mean_days_to_last_resolved 	+
																																	  user_bugs_qa_contact_trivial_mean_days_to_last_resolved 		+
																																	  user_bugs_qa_contact_minor_mean_days_to_last_resolved 		+	
																																	  user_bugs_qa_contact_normal_mean_days_to_last_resolved 		+
																																	  user_bugs_qa_contact_major_mean_days_to_last_resolved 		+	
																																	  user_bugs_qa_contact_critical_mean_days_to_last_resolved 		+
																																	  user_bugs_qa_contact_blocker_mean_days_to_last_resolved) 		/ 7);
																																   
																																   
# Merge the bugs_working_qa_contact_severity_days_to_last_resolved_recast and profiles_working tables based on qa_contact & userid to add the severity types description mean times columns
setkey(bugs_working_qa_contact_severity_days_to_last_resolved_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_severity_days_to_last_resolved_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user was not set as qa_contact for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_enhancement_mean_days_to_last_resolved	= safe_ifelse(user_bugs_qa_contact_enhancement_mean_days_to_last_resolved	<= 0, NA, user_bugs_qa_contact_enhancement_mean_days_to_last_resolved),
                                             user_bugs_qa_contact_trivial_mean_days_to_last_resolved		= safe_ifelse(user_bugs_qa_contact_trivial_mean_days_to_last_resolved		<= 0, NA, user_bugs_qa_contact_trivial_mean_days_to_last_resolved),	
                                             user_bugs_qa_contact_minor_mean_days_to_last_resolved			= safe_ifelse(user_bugs_qa_contact_minor_mean_days_to_last_resolved			<= 0, NA, user_bugs_qa_contact_minor_mean_days_to_last_resolved),		
                                             user_bugs_qa_contact_normal_mean_days_to_last_resolved			= safe_ifelse(user_bugs_qa_contact_normal_mean_days_to_last_resolved		<= 0, NA, user_bugs_qa_contact_normal_mean_days_to_last_resolved),		
                                             user_bugs_qa_contact_major_mean_days_to_last_resolved			= safe_ifelse(user_bugs_qa_contact_major_mean_days_to_last_resolved			<= 0, NA, user_bugs_qa_contact_major_mean_days_to_last_resolved),		
                                             user_bugs_qa_contact_critical_mean_days_to_last_resolved		= safe_ifelse(user_bugs_qa_contact_critical_mean_days_to_last_resolved		<= 0, NA, user_bugs_qa_contact_critical_mean_days_to_last_resolved),	
                                             user_bugs_qa_contact_blocker_mean_days_to_last_resolved		= safe_ifelse(user_bugs_qa_contact_blocker_mean_days_to_last_resolved	  	<= 0, NA, user_bugs_qa_contact_blocker_mean_days_to_last_resolved),
											 user_bugs_qa_contact_all_types_mean_days_to_last_resolved		= safe_ifelse(user_bugs_qa_contact_all_types_mean_days_to_last_resolved 	<= 0, NA, user_bugs_qa_contact_all_types_mean_days_to_last_resolved));	

	
# PROFILES-BUG_SEVERITY_USER_QA_CONTACT_MEAN_DAYS_OPEN
# (Calculate the mean days_open for bugs for which each user was set as qa_contact for each severity level)

# Isolate the qa_contact, bug_severity, and days_open columns of bugs_working
bugs_working_qa_contact_severity_days_open <- select(bugs_working, qa_contact, bug_severity, days_open);

# Use data.table's dcast() function to recast the table such that each row is a single "qa_contact" and there
# is a column with the mean	days_open for all the bugs to which each user each user was set as qa_contact for each severity level, defaulting to NA if the user did not get set as qa_contact for any bugs of that severity level
bugs_working_qa_contact_severity_days_open_recast <- dcast(bugs_working_qa_contact_severity_days_open, qa_contact ~ bug_severity, drop=FALSE, value.var="days_open", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_qa_contact_severity_days_open_recast <- transmute(bugs_working_qa_contact_severity_days_open_recast,  	
															qa_contact 										= qa_contact,
															user_bugs_qa_contact_enhancement_mean_days_open	= if (exists('enhancement',	where = bugs_working_qa_contact_severity_days_open_recast)) enhancement 	else 0,
															user_bugs_qa_contact_trivial_mean_days_open		= if (exists('trivial',		where = bugs_working_qa_contact_severity_days_open_recast)) trivial 		else 0,
															user_bugs_qa_contact_minor_mean_days_open		= if (exists('minor',		where = bugs_working_qa_contact_severity_days_open_recast)) minor 			else 0,
															user_bugs_qa_contact_normal_mean_days_open		= if (exists('normal',		where = bugs_working_qa_contact_severity_days_open_recast)) normal 			else 0,
															user_bugs_qa_contact_major_mean_days_open		= if (exists('major',		where = bugs_working_qa_contact_severity_days_open_recast)) major 			else 0,
															user_bugs_qa_contact_critical_mean_days_open	= if (exists('critical',	where = bugs_working_qa_contact_severity_days_open_recast)) critical 		else 0,
															user_bugs_qa_contact_blocker_mean_days_open		= if (exists('blocker',		where = bugs_working_qa_contact_severity_days_open_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs for which each user was set as qa_contact
bugs_working_qa_contact_severity_days_open_recast <- mutate(bugs_working_qa_contact_severity_days_open_recast,
																	 user_bugs_qa_contact_all_types_mean_days_open = (user_bugs_qa_contact_enhancement_mean_days_open 	+
																													   user_bugs_qa_contact_trivial_mean_days_open 		+
																													   user_bugs_qa_contact_minor_mean_days_open 		+	
																													   user_bugs_qa_contact_normal_mean_days_open 		+
																													   user_bugs_qa_contact_major_mean_days_open 		+	
																													   user_bugs_qa_contact_critical_mean_days_open 	+
																													   user_bugs_qa_contact_blocker_mean_days_open) 	/ 7);
																																   
																																   
# Merge the bugs_working_qa_contact_severity_days_open_recast and profiles_working tables based on qa_contact & userid to add the severity types description mean times columns
setkey(bugs_working_qa_contact_severity_days_open_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_severity_days_open_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user was not set as qa_contact for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
profiles_working <- mutate(profiles_working, user_bugs_qa_contact_enhancement_mean_days_open	= safe_ifelse(user_bugs_qa_contact_enhancement_mean_days_open	<= 0, NA, user_bugs_qa_contact_enhancement_mean_days_open),
                                             user_bugs_qa_contact_trivial_mean_days_open		= safe_ifelse(user_bugs_qa_contact_trivial_mean_days_open		<= 0, NA, user_bugs_qa_contact_trivial_mean_days_open),	
                                             user_bugs_qa_contact_minor_mean_days_open			= safe_ifelse(user_bugs_qa_contact_minor_mean_days_open			<= 0, NA, user_bugs_qa_contact_minor_mean_days_open),		
                                             user_bugs_qa_contact_normal_mean_days_open			= safe_ifelse(user_bugs_qa_contact_normal_mean_days_open		<= 0, NA, user_bugs_qa_contact_normal_mean_days_open),		
                                             user_bugs_qa_contact_major_mean_days_open			= safe_ifelse(user_bugs_qa_contact_major_mean_days_open			<= 0, NA, user_bugs_qa_contact_major_mean_days_open),		
                                             user_bugs_qa_contact_critical_mean_days_open		= safe_ifelse(user_bugs_qa_contact_critical_mean_days_open		<= 0, NA, user_bugs_qa_contact_critical_mean_days_open),	
                                             user_bugs_qa_contact_blocker_mean_days_open		= safe_ifelse(user_bugs_qa_contact_blocker_mean_days_open	  	<= 0, NA, user_bugs_qa_contact_blocker_mean_days_open),
											 user_bugs_qa_contact_all_types_mean_days_open		= safe_ifelse(user_bugs_qa_contact_all_types_mean_days_open 	<= 0, NA, user_bugs_qa_contact_all_types_mean_days_open));	

		
	
		
			
	
		
	



	


# CLEAN UP


# Set global variables for other functions
profiles_interactions 	<<- profiles_working;
bugs_interactions 		<<- bugs_working;
longdescs_interactions	<<- longdescs_working;


} # End operationalize_interactions function


# OPERATIONALIZE CALCULATED VARIABLES

operationalize_calculated_variables <- function() {

# Import profiles & bugs tables that we'll modify in this function
profiles_working 	<- profiles_interactions;
bugs_working 		<- bugs_interactions;	

# PROFILES-BUGS_OUTCOME_PERCENTS
# (Calculate the various percents of outcomes in terms of fixed, not-fixed, pending
profiles_working <- mutate(profiles_working, 
					user_percent_bugs_reported_all_outcomes_fixed         	= safe_ifelse((user_bugs_reported_fixed_count 	  	+ 
																					   user_bugs_reported_not_fixed_count 		+ 
																					   user_bugs_reported_pending_count) 		<= 0, NA, user_bugs_reported_fixed_count 		/ (user_bugs_reported_fixed_count + user_bugs_reported_not_fixed_count + user_bugs_reported_pending_count)),
					user_percent_bugs_reported_defined_outcomes_fixed     	= safe_ifelse((user_bugs_reported_fixed_count 		+ 
																					   user_bugs_reported_not_fixed_count) 		<= 0, NA, user_bugs_reported_fixed_count 		/ (user_bugs_reported_fixed_count + user_bugs_reported_not_fixed_count)),
					user_percent_bugs_reported_all_outcomes_not_fixed     	= safe_ifelse((user_bugs_reported_fixed_count 		+
																					   user_bugs_reported_not_fixed_count 		+ 
																					   user_bugs_reported_pending_count) 		<= 0, NA, user_bugs_reported_not_fixed_count 	/ (user_bugs_reported_fixed_count + user_bugs_reported_not_fixed_count + user_bugs_reported_pending_count)),
					user_percent_bugs_reported_defined_outcomes_not_fixed 	= safe_ifelse((user_bugs_reported_fixed_count 		+
																					   user_bugs_reported_not_fixed_count) 		<= 0, NA, user_bugs_reported_not_fixed_count 	/ (user_bugs_reported_fixed_count + user_bugs_reported_not_fixed_count)),
					user_percent_bugs_reported_all_outcomes_pending       	= safe_ifelse((user_bugs_reported_fixed_count 		+
																					   user_bugs_reported_not_fixed_count 		+ 
																					   user_bugs_reported_pending_count) 		<= 0, NA, user_bugs_reported_pending_count 		/ (user_bugs_reported_fixed_count + user_bugs_reported_not_fixed_count + user_bugs_reported_pending_count)),
					user_percent_bugs_assigned_to_all_outcomes_fixed         = safe_ifelse((user_bugs_assigned_to_fixed_count 	+ 
																					   user_bugs_assigned_to_not_fixed_count 	+ 
																					   user_bugs_assigned_to_pending_count) 	<= 0, NA, user_bugs_assigned_to_fixed_count 	/ (user_bugs_assigned_to_fixed_count + user_bugs_assigned_to_not_fixed_count + user_bugs_assigned_to_pending_count)),
					user_percent_bugs_assigned_to_defined_outcomes_fixed     = safe_ifelse((user_bugs_assigned_to_fixed_count 	+ 
																					   user_bugs_assigned_to_not_fixed_count) 	<= 0, NA, user_bugs_assigned_to_fixed_count 	/ (user_bugs_assigned_to_fixed_count + user_bugs_assigned_to_not_fixed_count)),
					user_percent_bugs_assigned_to_all_outcomes_not_fixed     = safe_ifelse((user_bugs_assigned_to_fixed_count 	+
																					   user_bugs_assigned_to_not_fixed_count 	+ 
																					   user_bugs_assigned_to_pending_count) 	<= 0, NA, user_bugs_assigned_to_not_fixed_count / (user_bugs_assigned_to_fixed_count + user_bugs_assigned_to_not_fixed_count + user_bugs_assigned_to_pending_count)),
					user_percent_bugs_assigned_to_defined_outcomes_not_fixed = safe_ifelse((user_bugs_assigned_to_fixed_count 	+
																					   user_bugs_assigned_to_not_fixed_count) 	<= 0, NA, user_bugs_assigned_to_not_fixed_count / (user_bugs_assigned_to_fixed_count + user_bugs_assigned_to_not_fixed_count)),
					user_percent_bugs_assigned_to_all_outcomes_pending       = safe_ifelse((user_bugs_assigned_to_fixed_count 	+
																					   user_bugs_assigned_to_not_fixed_count 	+ 
																					   user_bugs_assigned_to_pending_count) 	<= 0, NA, user_bugs_assigned_to_pending_count 	/ (user_bugs_assigned_to_fixed_count + user_bugs_assigned_to_not_fixed_count + user_bugs_assigned_to_pending_count)),
					user_percent_bugs_qa_contact_all_outcomes_fixed         	= safe_ifelse((user_bugs_qa_contact_fixed_count + 
																					   user_bugs_qa_contact_not_fixed_count 	+ 
																					   user_bugs_qa_contact_pending_count) 		<= 0, NA, user_bugs_qa_contact_fixed_count 		/ (user_bugs_qa_contact_fixed_count + user_bugs_qa_contact_not_fixed_count + user_bugs_qa_contact_pending_count)),
					user_percent_bugs_qa_contact_defined_outcomes_fixed     	= safe_ifelse((user_bugs_qa_contact_fixed_count + 
																					   user_bugs_qa_contact_not_fixed_count) 	<= 0, NA, user_bugs_qa_contact_fixed_count 		/ (user_bugs_qa_contact_fixed_count + user_bugs_qa_contact_not_fixed_count)),
					user_percent_bugs_qa_contact_all_outcomes_not_fixed     	= safe_ifelse((user_bugs_qa_contact_fixed_count +
																					   user_bugs_qa_contact_not_fixed_count 	+ 
																					   user_bugs_qa_contact_pending_count) 		<= 0, NA, user_bugs_qa_contact_not_fixed_count 	/ (user_bugs_qa_contact_fixed_count + user_bugs_qa_contact_not_fixed_count + user_bugs_qa_contact_pending_count)),
					user_percent_bugs_qa_contact_defined_outcomes_not_fixed 	= safe_ifelse((user_bugs_qa_contact_fixed_count +
																					   user_bugs_qa_contact_not_fixed_count) 	<= 0, NA, user_bugs_qa_contact_not_fixed_count 	/ (user_bugs_qa_contact_fixed_count + user_bugs_qa_contact_not_fixed_count)),
					user_percent_bugs_qa_contact_all_outcomes_pending       	= safe_ifelse((user_bugs_qa_contact_fixed_count +
																					   user_bugs_qa_contact_not_fixed_count 	+ 
																					   user_bugs_qa_contact_pending_count) 		<= 0, NA, user_bugs_qa_contact_pending_count 	/ (user_bugs_qa_contact_fixed_count + user_bugs_qa_contact_not_fixed_count + user_bugs_qa_contact_pending_count)));
										








# CLEAN UP

# Set global variables for other functions
profiles_calculated <<- profiles_working;
bugs_calculated 	<<- bugs_working;

} # End operationalize_calculated_variables function




# OPERATIONALIZE ORGANIZATION-LEVEL VARIABLES

operationalize_org_level <- function() {

# PROFILES-ALL_TABLES_ORG_SUMS
# (Summarize all the individual user counts into org-based counts for the various table interactions)
# Using the user-level variables created in previous functions, we can simply sum() by domain

# Import the profiles_interaction table to use in this function
profiles_working <- profiles_calculated;

# Group profiles according to domains
profiles_working_grouped_domain_sums <- group_by(profiles_working, domain);

# Use summarize() function to sum the various user counts for each domain
profiles_working_grouped_domain_sums_summary <- summarize(profiles_working_grouped_domain_sums ,  org_all_actors_count								= n(),
																						org_bugs_reported_is_duplicate_count 						= sum(user_bugs_reported_is_duplicate_count),
																						org_bugs_reported_was_duplicated_count 						= sum(user_bugs_reported_was_duplicated_count),
																						org_bugs_reported_all_duplications_count					= sum(user_bugs_reported_all_duplications_count),
																						org_flags_set_count 										= sum(user_flags_set_count),
																						org_watching_all_actors_count 								= sum(user_watching_all_actors_count),
																						org_watching_all_orgs_count 								= sum(user_watching_all_orgs_count),
																						org_watching_knowledge_actors_count 						= sum(user_watching_knowledge_actors_count),
																						org_watching_core_actors_count								= sum(user_watching_core_actors_count),
																						org_watching_peripheral_actors_count						= sum(user_watching_peripheral_actors_count),
																						org_watched_by_all_actors_count								= sum(user_watched_by_all_actors_count),
																						org_watched_by_all_orgs_count								= sum(user_watched_by_all_orgs_count),
																						org_watched_by_knowledge_actors_count						= sum(user_watched_by_knowledge_actors_count),
																						org_watched_by_core_actors_count							= sum(user_watched_by_core_actors_count),
																						org_watched_by_peripheral_actors_count						= sum(user_watched_by_peripheral_actors_count),
																						org_activity_all_actors_count 								= sum(user_activity_count),
																						org_bugs_reported_count 									= sum(user_bugs_reported_count),
																						org_bugs_assigned_count 									= sum(user_bugs_assigned_count),
																						org_bugs_qa_count 											= sum(user_bugs_qa_count),
																						org_bugs_reported_reopened_count 							= sum(user_bugs_reported_reopened_count),
																						org_bugs_reported_assigned_count 							= sum(user_bugs_reported_assigned_count),
																						org_bugs_reported_reassigned_count 							= sum(user_bugs_reported_reassigned_count),
																						org_bugs_reported_enhancement_count 						= sum(user_bugs_reported_enhancement_count), 	
																						org_bugs_reported_trivial_count 							= sum(user_bugs_reported_trivial_count), 		
																						org_bugs_reported_minor_count								= sum(user_bugs_reported_minor_count), 		
																						org_bugs_reported_normal_count 								= sum(user_bugs_reported_normal_count), 		
																						org_bugs_reported_major_count 								= sum(user_bugs_reported_major_count), 		
																						org_bugs_reported_critical_count 							= sum(user_bugs_reported_critical_count), 	
																						org_bugs_reported_blocker_count 							= sum(user_bugs_reported_blocker_count),
																						org_bugs_assigned_to_enhancement_count 						= sum(user_bugs_assigned_to_enhancement_count), 	
																						org_bugs_assigned_to_trivial_count 							= sum(user_bugs_assigned_to_trivial_count), 		
																						org_bugs_assigned_to_minor_count							= sum(user_bugs_assigned_to_minor_count), 		
																						org_bugs_assigned_to_normal_count 							= sum(user_bugs_assigned_to_normal_count), 		
																						org_bugs_assigned_to_major_count 							= sum(user_bugs_assigned_to_major_count), 		
																						org_bugs_assigned_to_critical_count 						= sum(user_bugs_assigned_to_critical_count), 	
																						org_bugs_assigned_to_blocker_count 							= sum(user_bugs_assigned_to_blocker_count),
																						org_bugs_qa_contact_enhancement_count 						= sum(user_bugs_qa_contact_enhancement_count), 	
																						org_bugs_qa_contact_trivial_count 							= sum(user_bugs_qa_contact_trivial_count), 		
																						org_bugs_qa_contact_minor_count								= sum(user_bugs_qa_contact_minor_count), 		
																						org_bugs_qa_contact_normal_count 							= sum(user_bugs_qa_contact_normal_count), 		
																						org_bugs_qa_contact_major_count 							= sum(user_bugs_qa_contact_major_count), 		
																						org_bugs_qa_contact_critical_count 							= sum(user_bugs_qa_contact_critical_count), 	
																						org_bugs_qa_contact_blocker_count 							= sum(user_bugs_qa_contact_blocker_count),
																						org_bugs_assigned_to_reopened_count 						= sum(user_bugs_assigned_to_reopened_count),	
																						org_bugs_assigned_to_assigned_count							= sum(user_bugs_assigned_to_assigned_count), 	
																						org_bugs_assigned_to_reassigned_count						= sum(user_bugs_assigned_to_reassigned_count),
																						org_bugs_qa_contact_reopened_count 							= sum(user_bugs_qa_contact_reopened_count),
																						org_bugs_qa_contact_assigned_count 							= sum(user_bugs_qa_contact_assigned_count), 
																						org_bugs_qa_contact_reassigned_count 						= sum(user_bugs_qa_contact_reassigned_count),
																						org_activity_assigning_1998_count							= sum(user_activity_assigning_1998_count),
																						org_activity_assigning_1999_count							= sum(user_activity_assigning_1999_count),
																						org_activity_assigning_2000_count							= sum(user_activity_assigning_2000_count),
																						org_activity_assigning_2001_count							= sum(user_activity_assigning_2001_count),
																						org_activity_assigning_2002_count							= sum(user_activity_assigning_2002_count),
																						org_activity_assigning_2003_count							= sum(user_activity_assigning_2003_count),
																						org_activity_assigning_2004_count							= sum(user_activity_assigning_2004_count),
																						org_activity_assigning_2005_count							= sum(user_activity_assigning_2005_count),
																						org_activity_assigning_2006_count							= sum(user_activity_assigning_2006_count),
																						org_activity_assigning_2007_count							= sum(user_activity_assigning_2007_count),
																						org_activity_assigning_2008_count							= sum(user_activity_assigning_2008_count),
																						org_activity_assigning_2009_count							= sum(user_activity_assigning_2009_count),
																						org_activity_assigning_2010_count							= sum(user_activity_assigning_2010_count),
																						org_activity_assigning_2011_count							= sum(user_activity_assigning_2011_count),
																						org_activity_assigning_2012_count							= sum(user_activity_assigning_2012_count),
																						org_activity_assigning_2013_count							= sum(user_activity_assigning_2013_count),
																						org_activity_assigning_all_count							= sum(user_activity_assigning_all_count),
																						org_activity_reassigning_1998_count							= sum(user_activity_reassigning_1998_count),
																						org_activity_reassigning_1999_count							= sum(user_activity_reassigning_1999_count),
																						org_activity_reassigning_2000_count							= sum(user_activity_reassigning_2000_count),
																						org_activity_reassigning_2001_count							= sum(user_activity_reassigning_2001_count),
																						org_activity_reassigning_2002_count							= sum(user_activity_reassigning_2002_count),
																						org_activity_reassigning_2003_count							= sum(user_activity_reassigning_2003_count),
																						org_activity_reassigning_2004_count							= sum(user_activity_reassigning_2004_count),
																						org_activity_reassigning_2005_count							= sum(user_activity_reassigning_2005_count),
																						org_activity_reassigning_2006_count							= sum(user_activity_reassigning_2006_count),
																						org_activity_reassigning_2007_count							= sum(user_activity_reassigning_2007_count),
																						org_activity_reassigning_2008_count							= sum(user_activity_reassigning_2008_count),
																						org_activity_reassigning_2009_count							= sum(user_activity_reassigning_2009_count),
																						org_activity_reassigning_2010_count							= sum(user_activity_reassigning_2010_count),
																						org_activity_reassigning_2011_count							= sum(user_activity_reassigning_2011_count),
																						org_activity_reassigning_2012_count							= sum(user_activity_reassigning_2012_count),
																						org_activity_reassigning_2013_count							= sum(user_activity_reassigning_2013_count),
																						org_activity_reassigning_all_count							= sum(user_activity_reassigning_all_count),
																						org_activity_reopening_1998_count							= sum(user_activity_reopening_1998_count),
																						org_activity_reopening_1999_count							= sum(user_activity_reopening_1999_count),
																						org_activity_reopening_2000_count							= sum(user_activity_reopening_2000_count),
																						org_activity_reopening_2001_count							= sum(user_activity_reopening_2001_count),
																						org_activity_reopening_2002_count							= sum(user_activity_reopening_2002_count),
																						org_activity_reopening_2003_count							= sum(user_activity_reopening_2003_count),
																						org_activity_reopening_2004_count							= sum(user_activity_reopening_2004_count),
																						org_activity_reopening_2005_count							= sum(user_activity_reopening_2005_count),
																						org_activity_reopening_2006_count							= sum(user_activity_reopening_2006_count),
																						org_activity_reopening_2007_count							= sum(user_activity_reopening_2007_count),
																						org_activity_reopening_2008_count							= sum(user_activity_reopening_2008_count),
																						org_activity_reopening_2009_count							= sum(user_activity_reopening_2009_count),
																						org_activity_reopening_2010_count							= sum(user_activity_reopening_2010_count),
																						org_activity_reopening_2011_count							= sum(user_activity_reopening_2011_count),
																						org_activity_reopening_2012_count							= sum(user_activity_reopening_2012_count),
																						org_activity_reopening_2013_count							= sum(user_activity_reopening_2013_count),
																						org_activity_reopening_all_count							= sum(user_activity_reopening_all_count),
																						org_activity_cc_change_1998_count							= sum(user_activity_cc_change_1998_count),
																						org_activity_cc_change_1999_count               			= sum(user_activity_cc_change_1999_count),
																						org_activity_cc_change_2000_count							= sum(user_activity_cc_change_2000_count),
																						org_activity_cc_change_2001_count							= sum(user_activity_cc_change_2001_count),
																						org_activity_cc_change_2002_count							= sum(user_activity_cc_change_2002_count),
																						org_activity_cc_change_2003_count							= sum(user_activity_cc_change_2003_count),
																						org_activity_cc_change_2004_count							= sum(user_activity_cc_change_2004_count),
																						org_activity_cc_change_2005_count               			= sum(user_activity_cc_change_2005_count),
																						org_activity_cc_change_2006_count               			= sum(user_activity_cc_change_2006_count),
																						org_activity_cc_change_2007_count               			= sum(user_activity_cc_change_2007_count),
																						org_activity_cc_change_2008_count               			= sum(user_activity_cc_change_2008_count),
																						org_activity_cc_change_2009_count               			= sum(user_activity_cc_change_2009_count),
																						org_activity_cc_change_2010_count							= sum(user_activity_cc_change_2010_count),
																						org_activity_cc_change_2011_count               			= sum(user_activity_cc_change_2011_count),
																						org_activity_cc_change_2012_count               			= sum(user_activity_cc_change_2012_count),
																						org_activity_cc_change_2013_count               			= sum(user_activity_cc_change_2013_count),
																						org_activity_cc_change_all_count                			= sum(user_activity_cc_change_all_count),
																						org_activity_keywords_change_1998_count         			= sum(user_activity_keywords_change_1998_count),
																						org_activity_keywords_change_1999_count						= sum(user_activity_keywords_change_1999_count),
																						org_activity_keywords_change_2000_count         			= sum(user_activity_keywords_change_2000_count),
																						org_activity_keywords_change_2001_count         			= sum(user_activity_keywords_change_2001_count),
																						org_activity_keywords_change_2002_count         			= sum(user_activity_keywords_change_2002_count),
																						org_activity_keywords_change_2003_count         			= sum(user_activity_keywords_change_2003_count),
																						org_activity_keywords_change_2004_count         			= sum(user_activity_keywords_change_2004_count),
																						org_activity_keywords_change_2005_count						= sum(user_activity_keywords_change_2005_count),
																						org_activity_keywords_change_2006_count         			= sum(user_activity_keywords_change_2006_count),
																						org_activity_keywords_change_2007_count         			= sum(user_activity_keywords_change_2007_count),
																						org_activity_keywords_change_2008_count         			= sum(user_activity_keywords_change_2008_count),
																						org_activity_keywords_change_2009_count         			= sum(user_activity_keywords_change_2009_count),
																						org_activity_keywords_change_2010_count         			= sum(user_activity_keywords_change_2010_count),
																						org_activity_keywords_change_2011_count         			= sum(user_activity_keywords_change_2011_count),
																						org_activity_keywords_change_2012_count         			= sum(user_activity_keywords_change_2012_count),
																						org_activity_keywords_change_2013_count         			= sum(user_activity_keywords_change_2013_count),
																						org_activity_keywords_change_all_count          			= sum(user_activity_keywords_change_all_count),
																						org_activity_product_change_1998_count          			= sum(user_activity_product_change_1998_count),
																						org_activity_product_change_1999_count          			= sum(user_activity_product_change_1999_count),
																						org_activity_product_change_2000_count          			= sum(user_activity_product_change_2000_count),
																						org_activity_product_change_2001_count          			= sum(user_activity_product_change_2001_count),
																						org_activity_product_change_2002_count          			= sum(user_activity_product_change_2002_count),
																						org_activity_product_change_2003_count          			= sum(user_activity_product_change_2003_count),
																						org_activity_product_change_2004_count          			= sum(user_activity_product_change_2004_count),
																						org_activity_product_change_2005_count          			= sum(user_activity_product_change_2005_count),
																						org_activity_product_change_2006_count          			= sum(user_activity_product_change_2006_count),
																						org_activity_product_change_2007_count          			= sum(user_activity_product_change_2007_count),
																						org_activity_product_change_2008_count          			= sum(user_activity_product_change_2008_count),
																						org_activity_product_change_2009_count          			= sum(user_activity_product_change_2009_count),
																						org_activity_product_change_2010_count          			= sum(user_activity_product_change_2010_count),
																						org_activity_product_change_2011_count          			= sum(user_activity_product_change_2011_count),
																						org_activity_product_change_2012_count						= sum(user_activity_product_change_2012_count),
																						org_activity_product_change_2013_count          			= sum(user_activity_product_change_2013_count),
																						org_activity_product_change_all_count           			= sum(user_activity_product_change_all_count),
																						org_activity_component_change_1998_count        			= sum(user_activity_component_change_1998_count),
																						org_activity_component_change_1999_count        			= sum(user_activity_component_change_1999_count),
																						org_activity_component_change_2000_count        			= sum(user_activity_component_change_2000_count),
																						org_activity_component_change_2001_count        			= sum(user_activity_component_change_2001_count),
																						org_activity_component_change_2002_count        			= sum(user_activity_component_change_2002_count),
																						org_activity_component_change_2003_count        			= sum(user_activity_component_change_2003_count),
																						org_activity_component_change_2004_count        			= sum(user_activity_component_change_2004_count),
																						org_activity_component_change_2005_count        			= sum(user_activity_component_change_2005_count),
																						org_activity_component_change_2006_count        			= sum(user_activity_component_change_2006_count),
																						org_activity_component_change_2007_count        			= sum(user_activity_component_change_2007_count),
																						org_activity_component_change_2008_count        			= sum(user_activity_component_change_2008_count),
																						org_activity_component_change_2009_count        			= sum(user_activity_component_change_2009_count),
																						org_activity_component_change_2010_count        			= sum(user_activity_component_change_2010_count),
																						org_activity_component_change_2011_count        			= sum(user_activity_component_change_2011_count),
																						org_activity_component_change_2012_count        			= sum(user_activity_component_change_2012_count),
																						org_activity_component_change_2013_count        			= sum(user_activity_component_change_2013_count),
																						org_activity_component_change_all_count         			= sum(user_activity_component_change_all_count),
																						org_activity_status_change_1998_count           			= sum(user_activity_status_change_1998_count),
																						org_activity_status_change_1999_count           			= sum(user_activity_status_change_1999_count),
																						org_activity_status_change_2000_count           			= sum(user_activity_status_change_2000_count),
																						org_activity_status_change_2001_count           			= sum(user_activity_status_change_2001_count),
																						org_activity_status_change_2002_count						= sum(user_activity_status_change_2002_count),
																						org_activity_status_change_2003_count           			= sum(user_activity_status_change_2003_count),
																						org_activity_status_change_2004_count           			= sum(user_activity_status_change_2004_count),
																						org_activity_status_change_2005_count           			= sum(user_activity_status_change_2005_count),
																						org_activity_status_change_2006_count           			= sum(user_activity_status_change_2006_count),
																						org_activity_status_change_2007_count           			= sum(user_activity_status_change_2007_count),
																						org_activity_status_change_2008_count           			= sum(user_activity_status_change_2008_count),
																						org_activity_status_change_2009_count           			= sum(user_activity_status_change_2009_count),
																						org_activity_status_change_2010_count           			= sum(user_activity_status_change_2010_count),
																						org_activity_status_change_2011_count           			= sum(user_activity_status_change_2011_count),
																						org_activity_status_change_2012_count           			= sum(user_activity_status_change_2012_count),
																						org_activity_status_change_2013_count           			= sum(user_activity_status_change_2013_count),
																						org_activity_status_change_all_count            			= sum(user_activity_status_change_all_count),
																						org_activity_resolution_change_1998_count       			= sum(user_activity_resolution_change_1998_count),
																						org_activity_resolution_change_1999_count       			= sum(user_activity_resolution_change_1999_count),
																						org_activity_resolution_change_2000_count       			= sum(user_activity_resolution_change_2000_count),
																						org_activity_resolution_change_2001_count       			= sum(user_activity_resolution_change_2001_count),
																						org_activity_resolution_change_2002_count       			= sum(user_activity_resolution_change_2002_count),
																						org_activity_resolution_change_2003_count       			= sum(user_activity_resolution_change_2003_count),
																						org_activity_resolution_change_2004_count       			= sum(user_activity_resolution_change_2004_count),
																						org_activity_resolution_change_2005_count       			= sum(user_activity_resolution_change_2005_count),
																						org_activity_resolution_change_2006_count       			= sum(user_activity_resolution_change_2006_count),
																						org_activity_resolution_change_2007_count       			= sum(user_activity_resolution_change_2007_count),
																						org_activity_resolution_change_2008_count       			= sum(user_activity_resolution_change_2008_count),
																						org_activity_resolution_change_2009_count					= sum(user_activity_resolution_change_2009_count),
																						org_activity_resolution_change_2010_count       			= sum(user_activity_resolution_change_2010_count),
																						org_activity_resolution_change_2011_count       			= sum(user_activity_resolution_change_2011_count),
																						org_activity_resolution_change_2012_count       			= sum(user_activity_resolution_change_2012_count),
																						org_activity_resolution_change_2013_count       			= sum(user_activity_resolution_change_2013_count),
																						org_activity_resolution_change_all_count        			= sum(user_activity_resolution_change_all_count),
																						org_activity_flags_change_1998_count            			= sum(user_activity_flags_change_1998_count),
																						org_activity_flags_change_1999_count            			= sum(user_activity_flags_change_1999_count),
																						org_activity_flags_change_2000_count            			= sum(user_activity_flags_change_2000_count),
																						org_activity_flags_change_2001_count            			= sum(user_activity_flags_change_2001_count),
																						org_activity_flags_change_2002_count            			= sum(user_activity_flags_change_2002_count),
																						org_activity_flags_change_2003_count            			= sum(user_activity_flags_change_2003_count),
																						org_activity_flags_change_2004_count            			= sum(user_activity_flags_change_2004_count),
																						org_activity_flags_change_2005_count            			= sum(user_activity_flags_change_2005_count),
																						org_activity_flags_change_2006_count            			= sum(user_activity_flags_change_2006_count),
																						org_activity_flags_change_2007_count            			= sum(user_activity_flags_change_2007_count),
																						org_activity_flags_change_2008_count            			= sum(user_activity_flags_change_2008_count),
																						org_activity_flags_change_2009_count            			= sum(user_activity_flags_change_2009_count),
																						org_activity_flags_change_2010_count            			= sum(user_activity_flags_change_2010_count),
																						org_activity_flags_change_2011_count            			= sum(user_activity_flags_change_2011_count),
																						org_activity_flags_change_2012_count            			= sum(user_activity_flags_change_2012_count),
																						org_activity_flags_change_2013_count            			= sum(user_activity_flags_change_2013_count),
																						org_activity_flags_change_all_count             			= sum(user_activity_flags_change_all_count),
																						org_activity_whiteboard_change_1998_count       			= sum(user_activity_whiteboard_change_1998_count),
																						org_activity_whiteboard_change_1999_count					= sum(user_activity_whiteboard_change_1999_count),
																						org_activity_whiteboard_change_2000_count       			= sum(user_activity_whiteboard_change_2000_count),
																						org_activity_whiteboard_change_2001_count       			= sum(user_activity_whiteboard_change_2001_count),
																						org_activity_whiteboard_change_2002_count       			= sum(user_activity_whiteboard_change_2002_count),
																						org_activity_whiteboard_change_2003_count       			= sum(user_activity_whiteboard_change_2003_count),
																						org_activity_whiteboard_change_2004_count       			= sum(user_activity_whiteboard_change_2004_count),
																						org_activity_whiteboard_change_2005_count       			= sum(user_activity_whiteboard_change_2005_count),
																						org_activity_whiteboard_change_2006_count       			= sum(user_activity_whiteboard_change_2006_count),
																						org_activity_whiteboard_change_2007_count       			= sum(user_activity_whiteboard_change_2007_count),
																						org_activity_whiteboard_change_2008_count       			= sum(user_activity_whiteboard_change_2008_count),
																						org_activity_whiteboard_change_2009_count       			= sum(user_activity_whiteboard_change_2009_count),
																						org_activity_whiteboard_change_2010_count       			= sum(user_activity_whiteboard_change_2010_count),
																						org_activity_whiteboard_change_2011_count       			= sum(user_activity_whiteboard_change_2011_count),
																						org_activity_whiteboard_change_2012_count       			= sum(user_activity_whiteboard_change_2012_count),
																						org_activity_whiteboard_change_2013_count       			= sum(user_activity_whiteboard_change_2013_count),
																						org_activity_whiteboard_change_all_count        			= sum(user_activity_whiteboard_change_all_count),
																						org_activity_target_milestone_change_1998_count 			= sum(user_activity_target_milestone_change_1998_count),
																						org_activity_target_milestone_change_1999_count 			= sum(user_activity_target_milestone_change_1999_count),
																						org_activity_target_milestone_change_2000_count 			= sum(user_activity_target_milestone_change_2000_count),
																						org_activity_target_milestone_change_2001_count 			= sum(user_activity_target_milestone_change_2001_count),
																						org_activity_target_milestone_change_2002_count 			= sum(user_activity_target_milestone_change_2002_count),
																						org_activity_target_milestone_change_2003_count 			= sum(user_activity_target_milestone_change_2003_count),
																						org_activity_target_milestone_change_2004_count 			= sum(user_activity_target_milestone_change_2004_count),
																						org_activity_target_milestone_change_2005_count 			= sum(user_activity_target_milestone_change_2005_count),
																						org_activity_target_milestone_change_2006_count				= sum(user_activity_target_milestone_change_2006_count),
																						org_activity_target_milestone_change_2007_count 			= sum(user_activity_target_milestone_change_2007_count),
																						org_activity_target_milestone_change_2008_count 			= sum(user_activity_target_milestone_change_2008_count),
																						org_activity_target_milestone_change_2009_count 			= sum(user_activity_target_milestone_change_2009_count),
																						org_activity_target_milestone_change_2010_count 			= sum(user_activity_target_milestone_change_2010_count),
																						org_activity_target_milestone_change_2011_count 			= sum(user_activity_target_milestone_change_2011_count),
																						org_activity_target_milestone_change_2012_count 			= sum(user_activity_target_milestone_change_2012_count),
																						org_activity_target_milestone_change_2013_count 			= sum(user_activity_target_milestone_change_2013_count),
																						org_activity_target_milestone_change_all_count  			= sum(user_activity_target_milestone_change_all_count),
																						org_activity_description_change_1998_count      			= sum(user_activity_description_change_1998_count),
																						org_activity_description_change_1999_count      			= sum(user_activity_description_change_1999_count),
																						org_activity_description_change_2000_count      			= sum(user_activity_description_change_2000_count),
																						org_activity_description_change_2001_count      			= sum(user_activity_description_change_2001_count),
																						org_activity_description_change_2002_count      			= sum(user_activity_description_change_2002_count),
																						org_activity_description_change_2003_count      			= sum(user_activity_description_change_2003_count),
																						org_activity_description_change_2004_count      			= sum(user_activity_description_change_2004_count),
																						org_activity_description_change_2005_count      			= sum(user_activity_description_change_2005_count),
																						org_activity_description_change_2006_count      			= sum(user_activity_description_change_2006_count),
																						org_activity_description_change_2007_count      			= sum(user_activity_description_change_2007_count),
																						org_activity_description_change_2008_count      			= sum(user_activity_description_change_2008_count),
																						org_activity_description_change_2009_count      			= sum(user_activity_description_change_2009_count),
																						org_activity_description_change_2010_count      			= sum(user_activity_description_change_2010_count),
																						org_activity_description_change_2011_count      			= sum(user_activity_description_change_2011_count),
																						org_activity_description_change_2012_count      			= sum(user_activity_description_change_2012_count),
																						org_activity_description_change_2013_count					= sum(user_activity_description_change_2013_count),
																						org_activity_description_change_all_count       			= sum(user_activity_description_change_all_count),
																						org_activity_priority_change_1998_count         			= sum(user_activity_priority_change_1998_count),
																						org_activity_priority_change_1999_count         			= sum(user_activity_priority_change_1999_count),
																						org_activity_priority_change_2000_count         			= sum(user_activity_priority_change_2000_count),
																						org_activity_priority_change_2001_count         			= sum(user_activity_priority_change_2001_count),
																						org_activity_priority_change_2002_count         			= sum(user_activity_priority_change_2002_count),
																						org_activity_priority_change_2003_count         			= sum(user_activity_priority_change_2003_count),
																						org_activity_priority_change_2004_count         			= sum(user_activity_priority_change_2004_count),
																						org_activity_priority_change_2005_count         			= sum(user_activity_priority_change_2005_count),
																						org_activity_priority_change_2006_count         			= sum(user_activity_priority_change_2006_count),
																						org_activity_priority_change_2007_count         			= sum(user_activity_priority_change_2007_count),
																						org_activity_priority_change_2008_count         			= sum(user_activity_priority_change_2008_count),
																						org_activity_priority_change_2009_count         			= sum(user_activity_priority_change_2009_count),
																						org_activity_priority_change_2010_count         			= sum(user_activity_priority_change_2010_count),
																						org_activity_priority_change_2011_count         			= sum(user_activity_priority_change_2011_count),
																						org_activity_priority_change_2012_count         			= sum(user_activity_priority_change_2012_count),
																						org_activity_priority_change_2013_count         			= sum(user_activity_priority_change_2013_count),
																						org_activity_priority_change_all_count          			= sum(user_activity_priority_change_all_count),
																						org_activity_severity_change_1998_count         			= sum(user_activity_severity_change_1998_count),
																						org_activity_severity_change_1999_count         			= sum(user_activity_severity_change_1999_count),
																						org_activity_severity_change_2000_count         			= sum(user_activity_severity_change_2000_count),
																						org_activity_severity_change_2001_count         			= sum(user_activity_severity_change_2001_count),
																						org_activity_severity_change_2002_count         			= sum(user_activity_severity_change_2002_count),
																						org_activity_severity_change_2003_count						= sum(user_activity_severity_change_2003_count),
																						org_activity_severity_change_2004_count         			= sum(user_activity_severity_change_2004_count),
																						org_activity_severity_change_2005_count         			= sum(user_activity_severity_change_2005_count),
																						org_activity_severity_change_2006_count         			= sum(user_activity_severity_change_2006_count),
																						org_activity_severity_change_2007_count         			= sum(user_activity_severity_change_2007_count),
																						org_activity_severity_change_2008_count         			= sum(user_activity_severity_change_2008_count),
																						org_activity_severity_change_2009_count         			= sum(user_activity_severity_change_2009_count),
																						org_activity_severity_change_2010_count         			= sum(user_activity_severity_change_2010_count),
																						org_activity_severity_change_2011_count         			= sum(user_activity_severity_change_2011_count),
																						org_activity_severity_change_2012_count         			= sum(user_activity_severity_change_2012_count),
																						org_activity_severity_change_2013_count         			= sum(user_activity_severity_change_2013_count),
																						org_activity_severity_change_all_count          			= sum(user_activity_severity_change_all_count),
																						org_attachments_all_types_count								= sum(user_attachments_all_types_count),
																						org_attachments_patch_count									= sum(user_attachments_patch_count),
																						org_attachments_application_count							= sum(user_attachments_application_count),
																						org_attachments_audio_count									= sum(user_attachments_audio_count),
																						org_attachments_image_count									= sum(user_attachments_image_count),
																						org_attachments_message_count								= sum(user_attachments_message_count),
																						org_attachments_model_count									= sum(user_attachments_model_count),
																						org_attachments_multipart_count								= sum(user_attachments_multipart_count),
																						org_attachments_text_count									= sum(user_attachments_text_count),
																						org_attachments_video_count									= sum(user_attachments_video_count),
																						org_attachments_unknown_count								= sum(user_attachments_unknown_count),
																						org_attachments_all_types_1998_count 						= sum(user_attachments_all_types_1998_count),
																						org_attachments_all_types_1999_count 						= sum(user_attachments_all_types_1999_count),
																						org_attachments_all_types_2000_count 						= sum(user_attachments_all_types_2000_count),
																						org_attachments_all_types_2001_count 						= sum(user_attachments_all_types_2001_count),
																						org_attachments_all_types_2002_count 						= sum(user_attachments_all_types_2002_count),
																						org_attachments_all_types_2003_count 						= sum(user_attachments_all_types_2003_count),
																						org_attachments_all_types_2004_count 						= sum(user_attachments_all_types_2004_count),
																						org_attachments_all_types_2005_count 						= sum(user_attachments_all_types_2005_count),
																						org_attachments_all_types_2006_count 						= sum(user_attachments_all_types_2006_count),
																						org_attachments_all_types_2007_count 						= sum(user_attachments_all_types_2007_count),
																						org_attachments_all_types_2008_count 						= sum(user_attachments_all_types_2008_count),
																						org_attachments_all_types_2009_count 						= sum(user_attachments_all_types_2009_count),
																						org_attachments_all_types_2010_count 						= sum(user_attachments_all_types_2010_count),
																						org_attachments_all_types_2011_count 						= sum(user_attachments_all_types_2011_count),
																						org_attachments_all_types_2012_count 						= sum(user_attachments_all_types_2012_count),
																						org_attachments_all_types_2013_count 						= sum(user_attachments_all_types_2013_count),
																						org_attachments_patches_1998_count 							= sum(user_attachments_patches_1998_count),
																						org_attachments_patches_1999_count 							= sum(user_attachments_patches_1999_count),
																						org_attachments_patches_2000_count 							= sum(user_attachments_patches_2000_count),
																						org_attachments_patches_2001_count 							= sum(user_attachments_patches_2001_count),
																						org_attachments_patches_2002_count 							= sum(user_attachments_patches_2002_count),
																						org_attachments_patches_2003_count 							= sum(user_attachments_patches_2003_count),
																						org_attachments_patches_2004_count 							= sum(user_attachments_patches_2004_count),
																						org_attachments_patches_2005_count 							= sum(user_attachments_patches_2005_count),
																						org_attachments_patches_2006_count 							= sum(user_attachments_patches_2006_count),
																						org_attachments_patches_2007_count 							= sum(user_attachments_patches_2007_count),
																						org_attachments_patches_2008_count 							= sum(user_attachments_patches_2008_count),
																						org_attachments_patches_2009_count 							= sum(user_attachments_patches_2009_count),
																						org_attachments_patches_2010_count 							= sum(user_attachments_patches_2010_count),
																						org_attachments_patches_2011_count 							= sum(user_attachments_patches_2011_count),
																						org_attachments_patches_2012_count 							= sum(user_attachments_patches_2012_count),
																						org_attachments_patches_2013_count 							= sum(user_attachments_patches_2013_count),
																						org_knowledge_actors_count									= sum(user_knowledge_actor),
																						org_core_actors_count										= sum(user_core_actor),
																						org_peripheral_actors_count									= sum(user_peripheral_actor),
																						org_bugs_reported_1994_count 								= sum(user_bugs_reported_1994_count),
																						org_bugs_reported_1995_count 								= sum(user_bugs_reported_1995_count),
																						org_bugs_reported_1996_count 								= sum(user_bugs_reported_1996_count),
																						org_bugs_reported_1997_count 								= sum(user_bugs_reported_1997_count),
																						org_bugs_reported_1998_count 								= sum(user_bugs_reported_1998_count),
																						org_bugs_reported_1999_count 								= sum(user_bugs_reported_1999_count),
																						org_bugs_reported_2000_count 								= sum(user_bugs_reported_2000_count),
																						org_bugs_reported_2001_count 								= sum(user_bugs_reported_2001_count),
																						org_bugs_reported_2002_count 								= sum(user_bugs_reported_2002_count),
																						org_bugs_reported_2003_count 								= sum(user_bugs_reported_2003_count),
																						org_bugs_reported_2004_count 								= sum(user_bugs_reported_2004_count),
																						org_bugs_reported_2005_count 								= sum(user_bugs_reported_2005_count),
																						org_bugs_reported_2006_count 								= sum(user_bugs_reported_2006_count),
																						org_bugs_reported_2007_count 								= sum(user_bugs_reported_2007_count),
																						org_bugs_reported_2008_count 								= sum(user_bugs_reported_2008_count),
																						org_bugs_reported_2009_count 								= sum(user_bugs_reported_2009_count),
																						org_bugs_reported_2010_count 								= sum(user_bugs_reported_2010_count),
																						org_bugs_reported_2011_count 								= sum(user_bugs_reported_2011_count),
																						org_bugs_reported_2012_count 								= sum(user_bugs_reported_2012_count),
																						org_bugs_reported_2013_count 								= sum(user_bugs_reported_2013_count),
																						org_bugs_assigned_to_1994_count 							= sum(user_bugs_assigned_to_1994_count),
																						org_bugs_assigned_to_1995_count 							= sum(user_bugs_assigned_to_1995_count),
																						org_bugs_assigned_to_1996_count 							= sum(user_bugs_assigned_to_1996_count),
																						org_bugs_assigned_to_1997_count 							= sum(user_bugs_assigned_to_1997_count),
																						org_bugs_assigned_to_1998_count 							= sum(user_bugs_assigned_to_1998_count),
																						org_bugs_assigned_to_1999_count 							= sum(user_bugs_assigned_to_1999_count),
																						org_bugs_assigned_to_2000_count 							= sum(user_bugs_assigned_to_2000_count),
																						org_bugs_assigned_to_2001_count 							= sum(user_bugs_assigned_to_2001_count),
																						org_bugs_assigned_to_2002_count 							= sum(user_bugs_assigned_to_2002_count),
																						org_bugs_assigned_to_2003_count 							= sum(user_bugs_assigned_to_2003_count),
																						org_bugs_assigned_to_2004_count 							= sum(user_bugs_assigned_to_2004_count),
																						org_bugs_assigned_to_2005_count 							= sum(user_bugs_assigned_to_2005_count),
																						org_bugs_assigned_to_2006_count 							= sum(user_bugs_assigned_to_2006_count),
																						org_bugs_assigned_to_2007_count 							= sum(user_bugs_assigned_to_2007_count),
																						org_bugs_assigned_to_2008_count 							= sum(user_bugs_assigned_to_2008_count),
																						org_bugs_assigned_to_2009_count 							= sum(user_bugs_assigned_to_2009_count),
																						org_bugs_assigned_to_2010_count 							= sum(user_bugs_assigned_to_2010_count),
																						org_bugs_assigned_to_2011_count 							= sum(user_bugs_assigned_to_2011_count),
																						org_bugs_assigned_to_2012_count 							= sum(user_bugs_assigned_to_2012_count),
																						org_bugs_assigned_to_2013_count 							= sum(user_bugs_assigned_to_2013_count),
																						org_bugs_qa_contact_1994_count 								= sum(user_bugs_qa_contact_1994_count),
																						org_bugs_qa_contact_1995_count 								= sum(user_bugs_qa_contact_1995_count),
																						org_bugs_qa_contact_1996_count 								= sum(user_bugs_qa_contact_1996_count),
																						org_bugs_qa_contact_1997_count 								= sum(user_bugs_qa_contact_1997_count),
																						org_bugs_qa_contact_1998_count 								= sum(user_bugs_qa_contact_1998_count),
																						org_bugs_qa_contact_1999_count 								= sum(user_bugs_qa_contact_1999_count),
																						org_bugs_qa_contact_2000_count 								= sum(user_bugs_qa_contact_2000_count),
																						org_bugs_qa_contact_2001_count 								= sum(user_bugs_qa_contact_2001_count),
																						org_bugs_qa_contact_2002_count 								= sum(user_bugs_qa_contact_2002_count),
																						org_bugs_qa_contact_2003_count 								= sum(user_bugs_qa_contact_2003_count),
																						org_bugs_qa_contact_2004_count 								= sum(user_bugs_qa_contact_2004_count),
																						org_bugs_qa_contact_2005_count 								= sum(user_bugs_qa_contact_2005_count),
																						org_bugs_qa_contact_2006_count 								= sum(user_bugs_qa_contact_2006_count),
																						org_bugs_qa_contact_2007_count 								= sum(user_bugs_qa_contact_2007_count),
																						org_bugs_qa_contact_2008_count 								= sum(user_bugs_qa_contact_2008_count),
																						org_bugs_qa_contact_2009_count 								= sum(user_bugs_qa_contact_2009_count),
																						org_bugs_qa_contact_2010_count 								= sum(user_bugs_qa_contact_2010_count),
																						org_bugs_qa_contact_2011_count 								= sum(user_bugs_qa_contact_2011_count),
																						org_bugs_qa_contact_2012_count 								= sum(user_bugs_qa_contact_2012_count),
																						org_bugs_qa_contact_2013_count 								= sum(user_bugs_qa_contact_2013_count),
																						org_comments_all_bugs_1995_count 							= sum(user_comments_all_bugs_1995_count),
																						org_comments_all_bugs_1996_count 							= sum(user_comments_all_bugs_1996_count),
																						org_comments_all_bugs_1997_count 							= sum(user_comments_all_bugs_1997_count),
																						org_comments_all_bugs_1998_count 							= sum(user_comments_all_bugs_1998_count),
																						org_comments_all_bugs_1999_count 							= sum(user_comments_all_bugs_1999_count),
																						org_comments_all_bugs_2000_count 							= sum(user_comments_all_bugs_2000_count),
																						org_comments_all_bugs_2001_count 							= sum(user_comments_all_bugs_2001_count),
																						org_comments_all_bugs_2002_count 							= sum(user_comments_all_bugs_2002_count),
																						org_comments_all_bugs_2003_count 							= sum(user_comments_all_bugs_2003_count),
																						org_comments_all_bugs_2004_count 							= sum(user_comments_all_bugs_2004_count),
																						org_comments_all_bugs_2005_count 							= sum(user_comments_all_bugs_2005_count),
																						org_comments_all_bugs_2006_count 							= sum(user_comments_all_bugs_2006_count),
																						org_comments_all_bugs_2007_count 							= sum(user_comments_all_bugs_2007_count),
																						org_comments_all_bugs_2008_count 							= sum(user_comments_all_bugs_2008_count),
																						org_comments_all_bugs_2009_count 							= sum(user_comments_all_bugs_2009_count),
																						org_comments_all_bugs_2010_count 							= sum(user_comments_all_bugs_2010_count),
																						org_comments_all_bugs_2011_count 							= sum(user_comments_all_bugs_2011_count),
																						org_comments_all_bugs_2012_count 							= sum(user_comments_all_bugs_2012_count),
																						org_comments_all_bugs_2013_count 							= sum(user_comments_all_bugs_2013_count),
																						org_comments_all_bugs_all_count  							= sum(user_comments_all_bugs_all_count),
																						org_comments_bugs_enhancement_count 						= sum(user_comments_bugs_enhancement_count),
																						org_comments_bugs_trivial_count								= sum(user_comments_bugs_trivial_count),
																						org_comments_bugs_minor_count								= sum(user_comments_bugs_minor_count),	
																						org_comments_bugs_normal_count								= sum(user_comments_bugs_normal_count),	
																						org_comments_bugs_major_count								= sum(user_comments_bugs_major_count),
																						org_comments_bugs_critical_count							= sum(user_comments_bugs_critical_count),	
																						org_comments_bugs_blocker_count								= sum(user_comments_bugs_blocker_count),
																						org_votes_bugs_enhancement_count 							= sum(user_votes_bugs_enhancement_count),
																						org_votes_bugs_trivial_count								= sum(user_votes_bugs_trivial_count),
																						org_votes_bugs_minor_count									= sum(user_votes_bugs_minor_count),
																						org_votes_bugs_normal_count									= sum(user_votes_bugs_normal_count),
																						org_votes_bugs_major_count									= sum(user_votes_bugs_major_count),
																						org_votes_bugs_critical_count								= sum(user_votes_bugs_critical_count),
																						org_votes_bugs_blocker_count								= sum(user_votes_bugs_blocker_count),
																						org_votes_all_bugs_count									= sum(user_votes_all_bugs_count),
																						org_cc_bugs_enhancement_count 								= sum(user_cc_bugs_enhancement_count),
																						org_cc_bugs_trivial_count									= sum(user_cc_bugs_trivial_count),	
																						org_cc_bugs_minor_count										= sum(user_cc_bugs_minor_count), 		
																						org_cc_bugs_normal_count									= sum(user_cc_bugs_normal_count),		
																						org_cc_bugs_major_count										= sum(user_cc_bugs_major_count),		
																						org_cc_bugs_critical_count									= sum(user_cc_bugs_critical_count),	
																						org_cc_bugs_blocker_count									= sum(user_cc_bugs_blocker_count),	
																						org_cc_all_bugs_count										= sum(user_cc_all_bugs_count),
																						org_bugs_reported_fixed_count								= sum(user_bugs_reported_fixed_count),	
																						org_bugs_reported_not_fixed_count							= sum(user_bugs_reported_not_fixed_count),
																						org_bugs_reported_pending_count								= sum(user_bugs_reported_pending_count),  
																						org_bugs_assigned_to_fixed_count							= sum(user_bugs_assigned_to_fixed_count),		
																						org_bugs_assigned_to_not_fixed_count						= sum(user_bugs_assigned_to_not_fixed_count),
																						org_bugs_assigned_to_pending_count							= sum(user_bugs_assigned_to_pending_count),
																						org_bugs_qa_contact_fixed_count								= sum(user_bugs_qa_contact_fixed_count),		
																						org_bugs_qa_contact_not_fixed_count							= sum(user_bugs_qa_contact_not_fixed_count),	
																						org_bugs_qa_contact_pending_count							= sum(user_bugs_qa_contact_pending_count));
 																					
# Somehow, the domain gets set as an integer, not a character string, so fix it:
profiles_working_grouped_domain_sums_summary$domain <- as.factor(as.character(profiles_working_grouped_domain_sums_summary$domain));
																						
# Merge	profiles_working_grouped_domain_sums_summary and profiles_working tables based on domain to add new count columns
setkey(profiles_working_grouped_domain_sums_summary, domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, profiles_working_grouped_domain_sums_summary, by="domain", all.x=TRUE);


# PROFILES_ORG_LOGICAL

# Create logical variables that depend on org-level count variables
profiles_working <- mutate(profiles_working, org_knowledge_actor		= safe_ifelse(org_knowledge_actors_count	> 0, 					 			TRUE, FALSE),
											 org_core_actor				= safe_ifelse(org_core_actors_count			> 0, 					 			TRUE, FALSE));
profiles_working <- mutate(profiles_working, org_peripheral_actor		= safe_ifelse(org_knowledge_actor 			== FALSE & org_core_actor == FALSE, TRUE, FALSE));
											 

# Any NA values are for correctly NA domains, so should be left as is.


# PROFILES_ORG_CALCULATED

profiles_working <- mutate(profiles_working, 
					org_percent_bugs_reported_all_outcomes_fixed         	= safe_ifelse((org_bugs_reported_fixed_count 	  	+ 
																					   org_bugs_reported_not_fixed_count 		+ 
																					   org_bugs_reported_pending_count) 		<= 0, NA, org_bugs_reported_fixed_count 		/ (org_bugs_reported_fixed_count + org_bugs_reported_not_fixed_count + org_bugs_reported_pending_count)),
					org_percent_bugs_reported_defined_outcomes_fixed     	= safe_ifelse((org_bugs_reported_fixed_count 		+ 
																					   org_bugs_reported_not_fixed_count) 		<= 0, NA, org_bugs_reported_fixed_count 		/ (org_bugs_reported_fixed_count + org_bugs_reported_not_fixed_count)),
					org_percent_bugs_reported_all_outcomes_not_fixed     	= safe_ifelse((org_bugs_reported_fixed_count 		+
																					   org_bugs_reported_not_fixed_count 		+ 
																					   org_bugs_reported_pending_count) 		<= 0, NA, org_bugs_reported_not_fixed_count 	/ (org_bugs_reported_fixed_count + org_bugs_reported_not_fixed_count + org_bugs_reported_pending_count)),
					org_percent_bugs_reported_defined_outcomes_not_fixed 	= safe_ifelse((org_bugs_reported_fixed_count 		+
																					   org_bugs_reported_not_fixed_count) 		<= 0, NA, org_bugs_reported_not_fixed_count 	/ (org_bugs_reported_fixed_count + org_bugs_reported_not_fixed_count)),
					org_percent_bugs_reported_all_outcomes_pending       	= safe_ifelse((org_bugs_reported_fixed_count 		+
																					   org_bugs_reported_not_fixed_count 		+ 
																					   org_bugs_reported_pending_count) 		<= 0, NA, org_bugs_reported_pending_count 		/ (org_bugs_reported_fixed_count + org_bugs_reported_not_fixed_count + org_bugs_reported_pending_count)),
					org_percent_bugs_assigned_to_all_outcomes_fixed         = safe_ifelse((org_bugs_assigned_to_fixed_count 	+ 
																					   org_bugs_assigned_to_not_fixed_count 	+ 
																					   org_bugs_assigned_to_pending_count) 		<= 0, NA, org_bugs_assigned_to_fixed_count 	/ (org_bugs_assigned_to_fixed_count + org_bugs_assigned_to_not_fixed_count + org_bugs_assigned_to_pending_count)),
					org_percent_bugs_assigned_to_defined_outcomes_fixed     = safe_ifelse((org_bugs_assigned_to_fixed_count 	+ 
																					   org_bugs_assigned_to_not_fixed_count) 	<= 0, NA, org_bugs_assigned_to_fixed_count 	/ (org_bugs_assigned_to_fixed_count + org_bugs_assigned_to_not_fixed_count)),
					org_percent_bugs_assigned_to_all_outcomes_not_fixed     = safe_ifelse((org_bugs_assigned_to_fixed_count 	+
																					   org_bugs_assigned_to_not_fixed_count 	+ 
																					   org_bugs_assigned_to_pending_count) 		<= 0, NA, org_bugs_assigned_to_not_fixed_count / (org_bugs_assigned_to_fixed_count + org_bugs_assigned_to_not_fixed_count + org_bugs_assigned_to_pending_count)),
					org_percent_bugs_assigned_to_defined_outcomes_not_fixed = safe_ifelse((org_bugs_assigned_to_fixed_count 	+
																					   org_bugs_assigned_to_not_fixed_count) 	<= 0, NA, org_bugs_assigned_to_not_fixed_count / (org_bugs_assigned_to_fixed_count + org_bugs_assigned_to_not_fixed_count)),
					org_percent_bugs_assigned_to_all_outcomes_pending       = safe_ifelse((org_bugs_assigned_to_fixed_count 	+
																					   org_bugs_assigned_to_not_fixed_count 	+ 
																					   org_bugs_assigned_to_pending_count) 		<= 0, NA, org_bugs_assigned_to_pending_count 	/ (org_bugs_assigned_to_fixed_count + org_bugs_assigned_to_not_fixed_count + org_bugs_assigned_to_pending_count)),
					org_percent_bugs_qa_contact_all_outcomes_fixed         	= safe_ifelse((org_bugs_qa_contact_fixed_count 		+ 
																					   org_bugs_qa_contact_not_fixed_count 		+ 
																					   org_bugs_qa_contact_pending_count) 		<= 0, NA, org_bugs_qa_contact_fixed_count 		/ (org_bugs_qa_contact_fixed_count + org_bugs_qa_contact_not_fixed_count + org_bugs_qa_contact_pending_count)),
					org_percent_bugs_qa_contact_defined_outcomes_fixed     	= safe_ifelse((org_bugs_qa_contact_fixed_count 		+ 
																					   org_bugs_qa_contact_not_fixed_count) 	<= 0, NA, org_bugs_qa_contact_fixed_count 		/ (org_bugs_qa_contact_fixed_count + org_bugs_qa_contact_not_fixed_count)),
					org_percent_bugs_qa_contact_all_outcomes_not_fixed     	= safe_ifelse((org_bugs_qa_contact_fixed_count 		+
																					   org_bugs_qa_contact_not_fixed_count 		+ 
																					   org_bugs_qa_contact_pending_count) 		<= 0, NA, org_bugs_qa_contact_not_fixed_count 	/ (org_bugs_qa_contact_fixed_count + org_bugs_qa_contact_not_fixed_count + org_bugs_qa_contact_pending_count)),
					org_percent_bugs_qa_contact_defined_outcomes_not_fixed 	= safe_ifelse((org_bugs_qa_contact_fixed_count 		+
																					   org_bugs_qa_contact_not_fixed_count) 	<= 0, NA, org_bugs_qa_contact_not_fixed_count 	/ (org_bugs_qa_contact_fixed_count + org_bugs_qa_contact_not_fixed_count)),
					org_percent_bugs_qa_contact_all_outcomes_pending       	= safe_ifelse((org_bugs_qa_contact_fixed_count 		+
																					   org_bugs_qa_contact_not_fixed_count 		+ 
																					   org_bugs_qa_contact_pending_count) 		<= 0, NA, org_bugs_qa_contact_pending_count 	/ (org_bugs_qa_contact_fixed_count + org_bugs_qa_contact_not_fixed_count + org_bugs_qa_contact_pending_count)));

																					   
# PROFILES-ALL_TABLES_ORG_MEANS
# (Summarize all the individual user counts into org-based counts for the various table interactions)
# Using the user-level variables created in previous functions, we can simply mean() by domain for relevant variables

# Group profiles according to domains
profiles_working_grouped_domain_means <- group_by(profiles_working, domain);

# Use summarize() function to sum the various user counts for each domain
profiles_working_grouped_domain_means_summary <- summarize(profiles_working_grouped_domain_means ,  org_bugs_reported_enhancement_mean_days_to_last_resolved		= mean(user_bugs_reported_enhancement_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_reported_trivial_mean_days_to_last_resolved			= mean(user_bugs_reported_trivial_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_reported_minor_mean_days_to_last_resolved				= mean(user_bugs_reported_minor_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_reported_normal_mean_days_to_last_resolved				= mean(user_bugs_reported_normal_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_reported_major_mean_days_to_last_resolved				= mean(user_bugs_reported_major_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_reported_critical_mean_days_to_last_resolved			= mean(user_bugs_reported_critical_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_reported_blocker_mean_days_to_last_resolved			= mean(user_bugs_reported_blocker_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_reported_all_types_mean_days_to_last_resolved			= mean(user_bugs_reported_all_types_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_reported_enhancement_mean_days_open					= mean(user_bugs_reported_enhancement_mean_days_open, na.rm = TRUE),
																									org_bugs_reported_trivial_mean_days_open						= mean(user_bugs_reported_trivial_mean_days_open, na.rm = TRUE),
																									org_bugs_reported_minor_mean_days_open							= mean(user_bugs_reported_minor_mean_days_open, na.rm = TRUE),
																									org_bugs_reported_normal_mean_days_open							= mean(user_bugs_reported_normal_mean_days_open, na.rm = TRUE),
																									org_bugs_reported_major_mean_days_open							= mean(user_bugs_reported_major_mean_days_open, na.rm = TRUE),
																									org_bugs_reported_critical_mean_days_open						= mean(user_bugs_reported_critical_mean_days_open, na.rm = TRUE),
																									org_bugs_reported_blocker_mean_days_open						= mean(user_bugs_reported_blocker_mean_days_open, na.rm = TRUE),
																									org_bugs_reported_all_types_mean_days_open						= mean(user_bugs_reported_all_types_mean_days_open, na.rm = TRUE),
																									org_bugs_assigned_to_enhancement_mean_days_to_last_resolved		= mean(user_bugs_assigned_to_enhancement_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_assigned_to_trivial_mean_days_to_last_resolved			= mean(user_bugs_assigned_to_trivial_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_assigned_to_minor_mean_days_to_last_resolved			= mean(user_bugs_assigned_to_minor_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_assigned_to_normal_mean_days_to_last_resolved			= mean(user_bugs_assigned_to_normal_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_assigned_to_major_mean_days_to_last_resolved			= mean(user_bugs_assigned_to_major_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_assigned_to_critical_mean_days_to_last_resolved		= mean(user_bugs_assigned_to_critical_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_assigned_to_blocker_mean_days_to_last_resolved			= mean(user_bugs_assigned_to_blocker_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_assigned_to_all_types_mean_days_to_last_resolved		= mean(user_bugs_assigned_to_all_types_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_assigned_to_enhancement_mean_days_open					= mean(user_bugs_assigned_to_enhancement_mean_days_open, na.rm = TRUE),
																									org_bugs_assigned_to_trivial_mean_days_open						= mean(user_bugs_assigned_to_trivial_mean_days_open, na.rm = TRUE),
																									org_bugs_assigned_to_minor_mean_days_open						= mean(user_bugs_assigned_to_minor_mean_days_open, na.rm = TRUE),
																									org_bugs_assigned_to_normal_mean_days_open						= mean(user_bugs_assigned_to_normal_mean_days_open, na.rm = TRUE),
																									org_bugs_assigned_to_major_mean_days_open						= mean(user_bugs_assigned_to_major_mean_days_open, na.rm = TRUE),
																									org_bugs_assigned_to_critical_mean_days_open					= mean(user_bugs_assigned_to_critical_mean_days_open, na.rm = TRUE),
																									org_bugs_assigned_to_blocker_mean_days_open						= mean(user_bugs_assigned_to_blocker_mean_days_open, na.rm = TRUE),
																									org_bugs_assigned_to_all_types_mean_days_open					= mean(user_bugs_assigned_to_all_types_mean_days_open, na.rm = TRUE),
																									org_bugs_qa_contact_enhancement_mean_days_to_last_resolved		= mean(user_bugs_qa_contact_enhancement_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_qa_contact_trivial_mean_days_to_last_resolved			= mean(user_bugs_qa_contact_trivial_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_qa_contact_minor_mean_days_to_last_resolved			= mean(user_bugs_qa_contact_minor_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_qa_contact_normal_mean_days_to_last_resolved			= mean(user_bugs_qa_contact_normal_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_qa_contact_major_mean_days_to_last_resolved			= mean(user_bugs_qa_contact_major_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_qa_contact_critical_mean_days_to_last_resolved			= mean(user_bugs_qa_contact_critical_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_qa_contact_blocker_mean_days_to_last_resolved			= mean(user_bugs_qa_contact_blocker_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_qa_contact_all_types_mean_days_to_last_resolved		= mean(user_bugs_qa_contact_all_types_mean_days_to_last_resolved, na.rm = TRUE),
																									org_bugs_qa_contact_enhancement_mean_days_open					= mean(user_bugs_qa_contact_enhancement_mean_days_open, na.rm = TRUE),
																									org_bugs_qa_contact_trivial_mean_days_open						= mean(user_bugs_qa_contact_trivial_mean_days_open, na.rm = TRUE),
																									org_bugs_qa_contact_minor_mean_days_open						= mean(user_bugs_qa_contact_minor_mean_days_open, na.rm = TRUE),
																									org_bugs_qa_contact_normal_mean_days_open						= mean(user_bugs_qa_contact_normal_mean_days_open, na.rm = TRUE),
																									org_bugs_qa_contact_major_mean_days_open						= mean(user_bugs_qa_contact_major_mean_days_open, na.rm = TRUE),
																									org_bugs_qa_contact_critical_mean_days_open						= mean(user_bugs_qa_contact_critical_mean_days_open, na.rm = TRUE),
																									org_bugs_qa_contact_blocker_mean_days_open						= mean(user_bugs_qa_contact_blocker_mean_days_open, na.rm = TRUE),
																									org_bugs_qa_contact_all_types_mean_days_open					= mean(user_bugs_qa_contact_all_types_mean_days_open, na.rm = TRUE),
																									org_bugs_reported_enhancement_description_mean_length			= mean(user_bugs_reported_enhancement_description_mean_length, na.rm = TRUE),
																									org_bugs_reported_trivial_description_mean_length				= mean(user_bugs_reported_trivial_description_mean_length, na.rm = TRUE),	
																									org_bugs_reported_minor_description_mean_length					= mean(user_bugs_reported_minor_description_mean_length, na.rm = TRUE),		
																									org_bugs_reported_normal_description_mean_length				= mean(user_bugs_reported_normal_description_mean_length, na.rm = TRUE),		
																									org_bugs_reported_major_description_mean_length					= mean(user_bugs_reported_major_description_mean_length, na.rm = TRUE),		
																									org_bugs_reported_critical_description_mean_length				= mean(user_bugs_reported_critical_description_mean_length, na.rm = TRUE),	
																									org_bugs_reported_blocker_description_mean_length				= mean(user_bugs_reported_blocker_description_mean_length, na.rm = TRUE),
																									org_bugs_assigned_to_enhancement_description_mean_length		= mean(user_bugs_assigned_to_enhancement_description_mean_length, na.rm = TRUE),
																									org_bugs_assigned_to_trivial_description_mean_length			= mean(user_bugs_assigned_to_trivial_description_mean_length, na.rm = TRUE),	
																									org_bugs_assigned_to_minor_description_mean_length				= mean(user_bugs_assigned_to_minor_description_mean_length, na.rm = TRUE),		
																									org_bugs_assigned_to_normal_description_mean_length				= mean(user_bugs_assigned_to_normal_description_mean_length, na.rm = TRUE),		
																									org_bugs_assigned_to_major_description_mean_length				= mean(user_bugs_assigned_to_major_description_mean_length, na.rm = TRUE),		
																									org_bugs_assigned_to_critical_description_mean_length			= mean(user_bugs_assigned_to_critical_description_mean_length, na.rm = TRUE),	
																									org_bugs_assigned_to_blocker_description_mean_length			= mean(user_bugs_assigned_to_blocker_description_mean_length, na.rm = TRUE),
																									org_bugs_qa_contact_enhancement_description_mean_length			= mean(user_bugs_qa_contact_enhancement_description_mean_length, na.rm = TRUE),
																									org_bugs_qa_contact_trivial_description_mean_length				= mean(user_bugs_qa_contact_trivial_description_mean_length, na.rm = TRUE),	
																									org_bugs_qa_contact_minor_description_mean_length				= mean(user_bugs_qa_contact_minor_description_mean_length, na.rm = TRUE),		
																									org_bugs_qa_contact_normal_description_mean_length				= mean(user_bugs_qa_contact_normal_description_mean_length, na.rm = TRUE),		
																									org_bugs_qa_contact_major_description_mean_length				= mean(user_bugs_qa_contact_major_description_mean_length, na.rm = TRUE),		
																									org_bugs_qa_contact_critical_description_mean_length			= mean(user_bugs_qa_contact_critical_description_mean_length, na.rm = TRUE),	
																									org_bugs_qa_contact_blocker_description_mean_length				= mean(user_bugs_qa_contact_blocker_description_mean_length, na.rm = TRUE),
																									org_bugs_reported_all_types_description_mean_length				= mean(user_bugs_reported_all_types_description_mean_length, na.rm = TRUE),
																									org_bugs_assigned_to_all_types_description_mean_length			= mean(user_bugs_assigned_to_all_types_description_mean_length, na.rm = TRUE),
																									org_bugs_qa_contact_all_types_description_mean_length			= mean(user_bugs_qa_contact_all_types_description_mean_length, na.rm = TRUE),
																									org_bugs_reported_enhancement_comments_mean_length				= mean(user_bugs_reported_enhancement_comments_mean_length, na.rm = TRUE),
																									org_bugs_reported_trivial_comments_mean_length					= mean(user_bugs_reported_trivial_comments_mean_length, na.rm = TRUE),	
																									org_bugs_reported_minor_comments_mean_length					= mean(user_bugs_reported_minor_comments_mean_length, na.rm = TRUE),		
																									org_bugs_reported_normal_comments_mean_length					= mean(user_bugs_reported_normal_comments_mean_length, na.rm = TRUE),		
																									org_bugs_reported_major_comments_mean_length					= mean(user_bugs_reported_major_comments_mean_length, na.rm = TRUE),		
																									org_bugs_reported_critical_comments_mean_length					= mean(user_bugs_reported_critical_comments_mean_length, na.rm = TRUE),	
																									org_bugs_reported_blocker_comments_mean_length					= mean(user_bugs_reported_blocker_comments_mean_length, na.rm = TRUE),
																									org_bugs_assigned_to_enhancement_comments_mean_length			= mean(user_bugs_assigned_to_enhancement_comments_mean_length, na.rm = TRUE),
																									org_bugs_assigned_to_trivial_comments_mean_length				= mean(user_bugs_assigned_to_trivial_comments_mean_length, na.rm = TRUE),	
																									org_bugs_assigned_to_minor_comments_mean_length					= mean(user_bugs_assigned_to_minor_comments_mean_length, na.rm = TRUE),		
																									org_bugs_assigned_to_normal_comments_mean_length				= mean(user_bugs_assigned_to_normal_comments_mean_length, na.rm = TRUE),		
																									org_bugs_assigned_to_major_comments_mean_length					= mean(user_bugs_assigned_to_major_comments_mean_length, na.rm = TRUE),		
																									org_bugs_assigned_to_critical_comments_mean_length				= mean(user_bugs_assigned_to_critical_comments_mean_length, na.rm = TRUE),	
																									org_bugs_assigned_to_blocker_comments_mean_length				= mean(user_bugs_assigned_to_blocker_comments_mean_length, na.rm = TRUE),
																									org_bugs_qa_contact_enhancement_comments_mean_length			= mean(user_bugs_qa_contact_enhancement_comments_mean_length, na.rm = TRUE),
																									org_bugs_qa_contact_trivial_comments_mean_length				= mean(user_bugs_qa_contact_trivial_comments_mean_length, na.rm = TRUE),	
																									org_bugs_qa_contact_minor_comments_mean_length					= mean(user_bugs_qa_contact_minor_comments_mean_length, na.rm = TRUE),		
																									org_bugs_qa_contact_normal_comments_mean_length					= mean(user_bugs_qa_contact_normal_comments_mean_length, na.rm = TRUE),		
																									org_bugs_qa_contact_major_comments_mean_length					= mean(user_bugs_qa_contact_major_comments_mean_length, na.rm = TRUE),		
																									org_bugs_qa_contact_critical_comments_mean_length				= mean(user_bugs_qa_contact_critical_comments_mean_length, na.rm = TRUE),	
																									org_bugs_qa_contact_blocker_comments_mean_length				= mean(user_bugs_qa_contact_blocker_comments_mean_length, na.rm = TRUE),
																									org_bugs_reported_all_types_comments_mean_length				= mean(user_bugs_reported_all_types_comments_mean_length, na.rm = TRUE),
																									org_bugs_assigned_to_all_types_comments_mean_length				= mean(user_bugs_assigned_to_all_types_comments_mean_length, na.rm = TRUE),
																									org_bugs_qa_contact_all_types_comments_mean_length				= mean(user_bugs_qa_contact_all_types_comments_mean_length, na.rm = TRUE));
	
# Somehow, the domain gets set as an integer, not a character string, so fix it:
profiles_working_grouped_domain_means_summary$domain <- as.factor(as.character(profiles_working_grouped_domain_means_summary$domain));
																						
# Merge	profiles_working_grouped_domain_means_summary and profiles_working tables based on domain to add new mean columns
setkey(profiles_working_grouped_domain_means_summary, domain);
setkey(profiles_working, domain);
profiles_working <- merge(profiles_working, profiles_working_grouped_domain_means_summary, by="domain", all.x=TRUE);

# Not A Number (NaN) entries are division by zero, meaning there are no relevant cases to assess the mean(), so replace with NA
profiles_working <- mutate(profiles_working, org_bugs_reported_enhancement_mean_days_to_last_resolved	    = safe_ifelse(is.nan(org_bugs_reported_enhancement_mean_days_to_last_resolved), 		NA, org_bugs_reported_enhancement_mean_days_to_last_resolved),
                                             org_bugs_reported_trivial_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_reported_trivial_mean_days_to_last_resolved), 			NA, org_bugs_reported_trivial_mean_days_to_last_resolved),
                                             org_bugs_reported_minor_mean_days_to_last_resolved			    = safe_ifelse(is.nan(org_bugs_reported_minor_mean_days_to_last_resolved), 				NA, org_bugs_reported_minor_mean_days_to_last_resolved),
                                             org_bugs_reported_normal_mean_days_to_last_resolved			= safe_ifelse(is.nan(org_bugs_reported_normal_mean_days_to_last_resolved), 				NA, org_bugs_reported_normal_mean_days_to_last_resolved),
                                             org_bugs_reported_major_mean_days_to_last_resolved			    = safe_ifelse(is.nan(org_bugs_reported_major_mean_days_to_last_resolved), 				NA, org_bugs_reported_major_mean_days_to_last_resolved),
                                             org_bugs_reported_critical_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_reported_critical_mean_days_to_last_resolved), 			NA, org_bugs_reported_critical_mean_days_to_last_resolved),
                                             org_bugs_reported_blocker_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_reported_blocker_mean_days_to_last_resolved), 			NA, org_bugs_reported_blocker_mean_days_to_last_resolved),
                                             org_bugs_reported_all_types_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_reported_all_types_mean_days_to_last_resolved), 			NA, org_bugs_reported_all_types_mean_days_to_last_resolved),
                                             org_bugs_reported_enhancement_mean_days_open				    = safe_ifelse(is.nan(org_bugs_reported_enhancement_mean_days_open), 					NA, org_bugs_reported_enhancement_mean_days_open),
                                             org_bugs_reported_trivial_mean_days_open					    = safe_ifelse(is.nan(org_bugs_reported_trivial_mean_days_open), 						NA, org_bugs_reported_trivial_mean_days_open),
                                             org_bugs_reported_minor_mean_days_open						    = safe_ifelse(is.nan(org_bugs_reported_minor_mean_days_open), 							NA, org_bugs_reported_minor_mean_days_open),
                                             org_bugs_reported_normal_mean_days_open						= safe_ifelse(is.nan(org_bugs_reported_normal_mean_days_open), 							NA, org_bugs_reported_normal_mean_days_open),
                                             org_bugs_reported_major_mean_days_open						    = safe_ifelse(is.nan(org_bugs_reported_major_mean_days_open), 							NA, org_bugs_reported_major_mean_days_open),
                                             org_bugs_reported_critical_mean_days_open					    = safe_ifelse(is.nan(org_bugs_reported_critical_mean_days_open), 						NA, org_bugs_reported_critical_mean_days_open),
                                             org_bugs_reported_blocker_mean_days_open					    = safe_ifelse(is.nan(org_bugs_reported_blocker_mean_days_open), 						NA, org_bugs_reported_blocker_mean_days_open),
                                             org_bugs_reported_all_types_mean_days_open					    = safe_ifelse(is.nan(org_bugs_reported_all_types_mean_days_open), 						NA, org_bugs_reported_all_types_mean_days_open),
                                             org_bugs_assigned_to_enhancement_mean_days_to_last_resolved	= safe_ifelse(is.nan(org_bugs_assigned_to_enhancement_mean_days_to_last_resolved), 		NA, org_bugs_assigned_to_enhancement_mean_days_to_last_resolved),
                                             org_bugs_assigned_to_trivial_mean_days_to_last_resolved		= safe_ifelse(is.nan(org_bugs_assigned_to_trivial_mean_days_to_last_resolved), 			NA, org_bugs_assigned_to_trivial_mean_days_to_last_resolved),
                                             org_bugs_assigned_to_minor_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_assigned_to_minor_mean_days_to_last_resolved), 			NA, org_bugs_assigned_to_minor_mean_days_to_last_resolved),
                                             org_bugs_assigned_to_normal_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_assigned_to_normal_mean_days_to_last_resolved), 			NA, org_bugs_assigned_to_normal_mean_days_to_last_resolved),
                                             org_bugs_assigned_to_major_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_assigned_to_major_mean_days_to_last_resolved), 			NA, org_bugs_assigned_to_major_mean_days_to_last_resolved),
                                             org_bugs_assigned_to_critical_mean_days_to_last_resolved	    = safe_ifelse(is.nan(org_bugs_assigned_to_critical_mean_days_to_last_resolved), 		NA, org_bugs_assigned_to_critical_mean_days_to_last_resolved),
                                             org_bugs_assigned_to_blocker_mean_days_to_last_resolved		= safe_ifelse(is.nan(org_bugs_assigned_to_blocker_mean_days_to_last_resolved), 			NA, org_bugs_assigned_to_blocker_mean_days_to_last_resolved),
                                             org_bugs_assigned_to_all_types_mean_days_to_last_resolved	    = safe_ifelse(is.nan(org_bugs_assigned_to_all_types_mean_days_to_last_resolved), 		NA, org_bugs_assigned_to_all_types_mean_days_to_last_resolved),
                                             org_bugs_assigned_to_enhancement_mean_days_open				= safe_ifelse(is.nan(org_bugs_assigned_to_enhancement_mean_days_open), 					NA, org_bugs_assigned_to_enhancement_mean_days_open),
                                             org_bugs_assigned_to_trivial_mean_days_open					= safe_ifelse(is.nan(org_bugs_assigned_to_trivial_mean_days_open), 						NA, org_bugs_assigned_to_trivial_mean_days_open),
                                             org_bugs_assigned_to_minor_mean_days_open					    = safe_ifelse(is.nan(org_bugs_assigned_to_minor_mean_days_open), 						NA, org_bugs_assigned_to_minor_mean_days_open),
                                             org_bugs_assigned_to_normal_mean_days_open					    = safe_ifelse(is.nan(org_bugs_assigned_to_normal_mean_days_open), 						NA, org_bugs_assigned_to_normal_mean_days_open),
                                             org_bugs_assigned_to_major_mean_days_open					    = safe_ifelse(is.nan(org_bugs_assigned_to_major_mean_days_open), 						NA, org_bugs_assigned_to_major_mean_days_open),
                                             org_bugs_assigned_to_critical_mean_days_open				    = safe_ifelse(is.nan(org_bugs_assigned_to_critical_mean_days_open), 					NA, org_bugs_assigned_to_critical_mean_days_open),
                                             org_bugs_assigned_to_blocker_mean_days_open					= safe_ifelse(is.nan(org_bugs_assigned_to_blocker_mean_days_open), 						NA, org_bugs_assigned_to_blocker_mean_days_open),
                                             org_bugs_assigned_to_all_types_mean_days_open				    = safe_ifelse(is.nan(org_bugs_assigned_to_all_types_mean_days_open), 					NA, org_bugs_assigned_to_all_types_mean_days_open),
                                             org_bugs_qa_contact_enhancement_mean_days_to_last_resolved	    = safe_ifelse(is.nan(org_bugs_qa_contact_enhancement_mean_days_to_last_resolved), 		NA, org_bugs_qa_contact_enhancement_mean_days_to_last_resolved),
                                             org_bugs_qa_contact_trivial_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_qa_contact_trivial_mean_days_to_last_resolved), 			NA, org_bugs_qa_contact_trivial_mean_days_to_last_resolved),
                                             org_bugs_qa_contact_minor_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_qa_contact_minor_mean_days_to_last_resolved), 			NA, org_bugs_qa_contact_minor_mean_days_to_last_resolved),
                                             org_bugs_qa_contact_normal_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_qa_contact_normal_mean_days_to_last_resolved), 			NA, org_bugs_qa_contact_normal_mean_days_to_last_resolved),
                                             org_bugs_qa_contact_major_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_qa_contact_major_mean_days_to_last_resolved), 			NA, org_bugs_qa_contact_major_mean_days_to_last_resolved),
                                             org_bugs_qa_contact_critical_mean_days_to_last_resolved		= safe_ifelse(is.nan(org_bugs_qa_contact_critical_mean_days_to_last_resolved), 			NA, org_bugs_qa_contact_critical_mean_days_to_last_resolved),
                                             org_bugs_qa_contact_blocker_mean_days_to_last_resolved		    = safe_ifelse(is.nan(org_bugs_qa_contact_blocker_mean_days_to_last_resolved), 			NA, org_bugs_qa_contact_blocker_mean_days_to_last_resolved),
                                             org_bugs_qa_contact_all_types_mean_days_to_last_resolved	    = safe_ifelse(is.nan(org_bugs_qa_contact_all_types_mean_days_to_last_resolved), 		NA, org_bugs_qa_contact_all_types_mean_days_to_last_resolved),
                                             org_bugs_qa_contact_enhancement_mean_days_open				    = safe_ifelse(is.nan(org_bugs_qa_contact_enhancement_mean_days_open), 					NA, org_bugs_qa_contact_enhancement_mean_days_open),
                                             org_bugs_qa_contact_trivial_mean_days_open					    = safe_ifelse(is.nan(org_bugs_qa_contact_trivial_mean_days_open), 						NA, org_bugs_qa_contact_trivial_mean_days_open),
                                             org_bugs_qa_contact_minor_mean_days_open					    = safe_ifelse(is.nan(org_bugs_qa_contact_minor_mean_days_open), 						NA, org_bugs_qa_contact_minor_mean_days_open),
                                             org_bugs_qa_contact_normal_mean_days_open					    = safe_ifelse(is.nan(org_bugs_qa_contact_normal_mean_days_open), 						NA, org_bugs_qa_contact_normal_mean_days_open),
                                             org_bugs_qa_contact_major_mean_days_open					    = safe_ifelse(is.nan(org_bugs_qa_contact_major_mean_days_open), 						NA, org_bugs_qa_contact_major_mean_days_open),
                                             org_bugs_qa_contact_critical_mean_days_open					= safe_ifelse(is.nan(org_bugs_qa_contact_critical_mean_days_open), 						NA, org_bugs_qa_contact_critical_mean_days_open),
                                             org_bugs_qa_contact_blocker_mean_days_open					    = safe_ifelse(is.nan(org_bugs_qa_contact_blocker_mean_days_open), 						NA, org_bugs_qa_contact_blocker_mean_days_open),
                                             org_bugs_qa_contact_all_types_mean_days_open				    = safe_ifelse(is.nan(org_bugs_qa_contact_all_types_mean_days_open), 					NA, org_bugs_qa_contact_all_types_mean_days_open),
											 org_bugs_reported_enhancement_description_mean_length	  		= safe_ifelse(is.nan(org_bugs_reported_enhancement_description_mean_length),    		NA, org_bugs_reported_enhancement_description_mean_length),
											 org_bugs_reported_trivial_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_reported_trivial_description_mean_length),        		NA, org_bugs_reported_trivial_description_mean_length),
											 org_bugs_reported_minor_description_mean_length				= safe_ifelse(is.nan(org_bugs_reported_minor_description_mean_length),          		NA, org_bugs_reported_minor_description_mean_length),
											 org_bugs_reported_normal_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_reported_normal_description_mean_length),         		NA, org_bugs_reported_normal_description_mean_length),
											 org_bugs_reported_major_description_mean_length				= safe_ifelse(is.nan(org_bugs_reported_major_description_mean_length),          		NA, org_bugs_reported_major_description_mean_length),
											 org_bugs_reported_critical_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_reported_critical_description_mean_length),       		NA, org_bugs_reported_critical_description_mean_length),
											 org_bugs_reported_blocker_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_reported_blocker_description_mean_length),        		NA, org_bugs_reported_blocker_description_mean_length),
											 org_bugs_assigned_to_enhancement_description_mean_length 		= safe_ifelse(is.nan(org_bugs_assigned_to_enhancement_description_mean_length), 		NA, org_bugs_assigned_to_enhancement_description_mean_length),
											 org_bugs_assigned_to_trivial_description_mean_length	  		= safe_ifelse(is.nan(org_bugs_assigned_to_trivial_description_mean_length),     		NA, org_bugs_assigned_to_trivial_description_mean_length),
											 org_bugs_assigned_to_minor_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_assigned_to_minor_description_mean_length),       		NA, org_bugs_assigned_to_minor_description_mean_length),
											 org_bugs_assigned_to_normal_description_mean_length			= safe_ifelse(is.nan(org_bugs_assigned_to_normal_description_mean_length),      		NA, org_bugs_assigned_to_normal_description_mean_length),
											 org_bugs_assigned_to_major_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_assigned_to_major_description_mean_length),       		NA, org_bugs_assigned_to_major_description_mean_length),
											 org_bugs_assigned_to_critical_description_mean_length	  		= safe_ifelse(is.nan(org_bugs_assigned_to_critical_description_mean_length),    		NA, org_bugs_assigned_to_critical_description_mean_length),
											 org_bugs_assigned_to_blocker_description_mean_length	  		= safe_ifelse(is.nan(org_bugs_assigned_to_blocker_description_mean_length),     		NA, org_bugs_assigned_to_blocker_description_mean_length),
											 org_bugs_qa_contact_enhancement_description_mean_length		= safe_ifelse(is.nan(org_bugs_qa_contact_enhancement_description_mean_length),  		NA, org_bugs_qa_contact_enhancement_description_mean_length),
											 org_bugs_qa_contact_trivial_description_mean_length			= safe_ifelse(is.nan(org_bugs_qa_contact_trivial_description_mean_length),      		NA, org_bugs_qa_contact_trivial_description_mean_length),
											 org_bugs_qa_contact_minor_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_qa_contact_minor_description_mean_length),        		NA, org_bugs_qa_contact_minor_description_mean_length),
											 org_bugs_qa_contact_normal_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_qa_contact_normal_description_mean_length),       		NA, org_bugs_qa_contact_normal_description_mean_length),
											 org_bugs_qa_contact_major_description_mean_length		  		= safe_ifelse(is.nan(org_bugs_qa_contact_major_description_mean_length),        		NA, org_bugs_qa_contact_major_description_mean_length),
											 org_bugs_qa_contact_critical_description_mean_length	  		= safe_ifelse(is.nan(org_bugs_qa_contact_critical_description_mean_length),     		NA, org_bugs_qa_contact_critical_description_mean_length),
											 org_bugs_qa_contact_blocker_description_mean_length			= safe_ifelse(is.nan(org_bugs_qa_contact_blocker_description_mean_length),      		NA, org_bugs_qa_contact_blocker_description_mean_length),
											 org_bugs_reported_all_types_description_mean_length			= safe_ifelse(is.nan(org_bugs_reported_all_types_description_mean_length),      		NA, org_bugs_reported_all_types_description_mean_length),
											 org_bugs_assigned_to_all_types_description_mean_length	  		= safe_ifelse(is.nan(org_bugs_assigned_to_all_types_description_mean_length),   		NA, org_bugs_assigned_to_all_types_description_mean_length),
											 org_bugs_qa_contact_all_types_description_mean_length	  		= safe_ifelse(is.nan(org_bugs_qa_contact_all_types_description_mean_length),    		NA, org_bugs_qa_contact_all_types_description_mean_length),
											 org_bugs_reported_enhancement_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_reported_enhancement_comments_mean_length),       		NA, org_bugs_reported_enhancement_comments_mean_length),
											 org_bugs_reported_trivial_comments_mean_length			  		= safe_ifelse(is.nan(org_bugs_reported_trivial_comments_mean_length),           		NA, org_bugs_reported_trivial_comments_mean_length),
											 org_bugs_reported_minor_comments_mean_length			  		= safe_ifelse(is.nan(org_bugs_reported_minor_comments_mean_length),             		NA, org_bugs_reported_minor_comments_mean_length),
											 org_bugs_reported_normal_comments_mean_length			  		= safe_ifelse(is.nan(org_bugs_reported_normal_comments_mean_length),            		NA, org_bugs_reported_normal_comments_mean_length),
											 org_bugs_reported_major_comments_mean_length			  		= safe_ifelse(is.nan(org_bugs_reported_major_comments_mean_length),             		NA, org_bugs_reported_major_comments_mean_length),
											 org_bugs_reported_critical_comments_mean_length				= safe_ifelse(is.nan(org_bugs_reported_critical_comments_mean_length),          		NA, org_bugs_reported_critical_comments_mean_length),
											 org_bugs_reported_blocker_comments_mean_length			  		= safe_ifelse(is.nan(org_bugs_reported_blocker_comments_mean_length),           		NA, org_bugs_reported_blocker_comments_mean_length),
											 org_bugs_assigned_to_enhancement_comments_mean_length	  		= safe_ifelse(is.nan(org_bugs_assigned_to_enhancement_comments_mean_length),    		NA, org_bugs_assigned_to_enhancement_comments_mean_length),
											 org_bugs_assigned_to_trivial_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_assigned_to_trivial_comments_mean_length),        		NA, org_bugs_assigned_to_trivial_comments_mean_length),
											 org_bugs_assigned_to_minor_comments_mean_length				= safe_ifelse(is.nan(org_bugs_assigned_to_minor_comments_mean_length),          		NA, org_bugs_assigned_to_minor_comments_mean_length),
											 org_bugs_assigned_to_normal_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_assigned_to_normal_comments_mean_length),         		NA, org_bugs_assigned_to_normal_comments_mean_length),
											 org_bugs_assigned_to_major_comments_mean_length				= safe_ifelse(is.nan(org_bugs_assigned_to_major_comments_mean_length),          		NA, org_bugs_assigned_to_major_comments_mean_length),
											 org_bugs_assigned_to_critical_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_assigned_to_critical_comments_mean_length),       		NA, org_bugs_assigned_to_critical_comments_mean_length),
											 org_bugs_assigned_to_blocker_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_assigned_to_blocker_comments_mean_length),        		NA, org_bugs_assigned_to_blocker_comments_mean_length),
											 org_bugs_qa_contact_enhancement_comments_mean_length	  		= safe_ifelse(is.nan(org_bugs_qa_contact_enhancement_comments_mean_length),     		NA, org_bugs_qa_contact_enhancement_comments_mean_length),
											 org_bugs_qa_contact_trivial_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_qa_contact_trivial_comments_mean_length),         		NA, org_bugs_qa_contact_trivial_comments_mean_length),
											 org_bugs_qa_contact_minor_comments_mean_length			  		= safe_ifelse(is.nan(org_bugs_qa_contact_minor_comments_mean_length),           		NA, org_bugs_qa_contact_minor_comments_mean_length),
											 org_bugs_qa_contact_normal_comments_mean_length				= safe_ifelse(is.nan(org_bugs_qa_contact_normal_comments_mean_length),          		NA, org_bugs_qa_contact_normal_comments_mean_length),
											 org_bugs_qa_contact_major_comments_mean_length			  		= safe_ifelse(is.nan(org_bugs_qa_contact_major_comments_mean_length),           		NA, org_bugs_qa_contact_major_comments_mean_length),
											 org_bugs_qa_contact_critical_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_qa_contact_critical_comments_mean_length),        		NA, org_bugs_qa_contact_critical_comments_mean_length),
											 org_bugs_qa_contact_blocker_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_qa_contact_blocker_comments_mean_length),         		NA, org_bugs_qa_contact_blocker_comments_mean_length),
											 org_bugs_reported_all_types_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_reported_all_types_comments_mean_length),         		NA, org_bugs_reported_all_types_comments_mean_length),
											 org_bugs_assigned_to_all_types_comments_mean_length			= safe_ifelse(is.nan(org_bugs_assigned_to_all_types_comments_mean_length),      		NA, org_bugs_assigned_to_all_types_comments_mean_length),
											 org_bugs_qa_contact_all_types_comments_mean_length		  		= safe_ifelse(is.nan(org_bugs_qa_contact_all_types_comments_mean_length),       		NA, org_bugs_qa_contact_all_types_comments_mean_length));
											 
											 
											 
										
		
# CLEAN UP

# Set global variables for other functions
profiles_org 	<<- profiles_working;
	
} # End operationalize_org_level function








# Run our desired functions
# And time them.
	start_time <- Sys.time();
	
	set_options();
	load_libraries();
	set_parameters();
	load_bugzilla_data_from_DB();
#   load_compustat_data_from_CSV();
#	load_mimetypes_from_remote_DB();
	load_mimetypes_from_CSV();
	
#	clean_compustat_data();
	clean_bugzilla_data();
	add_domains();
	operationalize_base();
	
# Remove global variables that we no longer need to free up memory
	# Original input variables
	rm(bugs, profiles, longdescs, activity, cc, attachments, votes, watch, duplicates, group_members, keywords, flags, products, dependencies, group_list);

	# Cleaned variables
	rm(bugs_clean, profiles_clean, longdescs_clean, activity_clean, cc_clean, attachments_clean, votes_clean, watch_clean, duplicates_clean, group_members_clean, keywords_clean, flags_clean, products_clean, dependencies_clean, group_list_clean);
	
	# Variables with appended domains
	rm(bugs_domains, profiles_domains, longdescs_domains, activity_domains, cc_domains, attachments_domains, votes_domains, watch_domains, duplicates_domains, group_members_domains, keywords_domains, flags_domains, dependencies_domains);

	# That leaves us with just the "_base" variables taking up memory!	
	
	# Run garbage collection to free up memory
	gc();
	
	operationalize_interactions();
	
	gc();
	operationalize_calculated_variables();
	
	operationalize_org_level();

	
	end_time <- Sys.time();
	total_time <- difftime(end_time, start_time);
	print(paste0("Execution time was: ", total_time));
	

# Perform garbage collection to free memory

gc();

#
# EOF


