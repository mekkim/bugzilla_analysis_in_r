#################################################################################
#																				#
#		ANALYZING MOZILLA'S BUGZILLA DATABASE USING R							#
#																				#
#		© 2015-2016 by Mekki MacAulay, mekki@mekki.ca, http://mekki.ca			#
#		Twitter: @mekki - http://twitter.com/mekki								#
#		Some rights reserved.													#
#																				#
#		Current version created on February 4, 2016								#
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
# This script depends on:
#
# 1) An updated (>3.2.0) R installation with the appropriate packages
# 2) A MySQL (tested on 5.5.xx) installation containing the Mozilla Bugzilla database to analyze
# 3) A PHP installation (tested on 5.6.14)
# 4) A PHP utility script for domain name parsing
# 5) A PERL installation (tested on ActivePerl 5.22.1.2201)
# 6) A Tree-Tagger installation
#
# The following sections describe the process for installing these necesities
#
# INSTALL MYSQL SERVER
#
# Visit: https://dev.mysql.com/downloads/windows/installer/5.5.html
# 
# Download the MySQL MSI installer for Windows 
# (Version 5.5.xx will do just fine - Later versions have the annoying Oracle installer that makes things more complicated)
#
# Run the installer as administrator and complete the MySQL install with default settings (or minor tweaks if you wish)
# During install, set the  default username to "root" and password to "password" in the configuration
# Default host will be "localhost" and default port will be "3306"
# 
# Reboot.
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
# I'll assume that the file name is "bugzilla.sql". If it's not, change the name in the commands below.
# This dumpfile only works with MySQl databases.  It cannot be restored to other databases such as SQLite, PostGRESQL, MSSQL, etc.
# It is also sufficiently complex that scripts cannot readily be used to convert it to a dumpfile of a different format
# 
# Open the standard command prompt as administrator and type the following 3 commands, hitting enter after each one:
#
# mysql -uroot -ppassword --execute="DROP DATABASE `bugs`;"
# mysql -uroot -ppassword --execute="CREATE DATABASE `bugs`;"
# mysql -uroot -ppassword bugs < bugzilla.sql
# 
# The last command will execute for several minutes as it populates the database with the dumpfile data 
# The result will be a database named "bugs" on the MySQL server, filled with the Bugzilla data
# 
# 
# INSTALL AND CONFIGURE R (Statistical package) or Microsoft R Open (MRO - From Revolution Analytics)
#
# Visit: http://cran.utstat.utoronto.ca/bin/windows/base/ or another mirror
# 
# Download the installer for the latest version for Windows (32/64 bit)
#
# Alternatively, visit: http://mran.revolutionanalytics.com/download/#download
#
# Download the installer for the latest version of Microsoft R Open, MRO, an alternative R distribution 
# primarily developed by Revolution Analytics (now owned by Microsoft) (http://revolutionanalytics.com/), which is also open source
# Revolution Analytics maintains a Managed R Archive Network (MRAN) that mirrors the base CRAN with optimizations
#
# This script might execute slightly faster with MRO vs base R, especially when using multiple cores
#
# You are encouraged to use an R or MRO version of at least 3.2.x as versions 3.1.3 and earlier execute this script significantly
# slower (~45% speed decrease), likely due to different memory heap management discussed here: 
# http://cran.r-project.org/src/base/NEWS
#
# Run the installer (either one) as administrator and complete the R install with default settings (or minor tweaks if you wish)
#
# Create a shortcut to R x64 X.X.X on the desktop (or suitable place - the installers offer to create one for you)
# Right-click on the shortcut and choose "Properties"
# Change the "Start in:" field to the location of this script file 
# That will ensure that R can find this script when executed from within the R shell
#
# Install additional packages from the package manager including at least the following:
#
# bit64 
# chron
# curl
# data.table
# DBI
# devtools
# dplyr
# DT
# FactoMineR
# ggplot2
# graphics
# gWidgets
# gWidgetsRGtk2
# highr
# itertools
# iterators
# koRpus (With caps: "koRpus") -> Development is moving quickly, so might be best to use Dev version: install.packages("koRpus", repo="http://R.reaktanz.de") which depends on package:devtools, so install that first
# longitudinalData
# lubridate
# doParallel (And its many Windows dependencies including "foreach", "snow", and "parallel"
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
# sqldf
# sqlutils
# stargazer
# textcat
# tidyr
# timeDate
# tm (for text mining)
# utils
# xkcd
# xlsx
# zipcode
# ...
# and all of the recursive dependencies of these listed packages (should do it automatically for you)
# This might take a while...
#
# Example:
# install.packages(c("bit64", "curl", "data.table", "devtools", "dplyr", "ggplot2", "RGtk2", "RMySQL", "stargazer", "textcat", "tidyr", "utils", "xlsx", "doParallel", "itertools", "iterators", "RCurl", "sqlutils", "timeDate", "tm"));
#
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
#
#
# INSTALL AND CONFIGURE TREE TAGER
# 
# Download the latest Tree Tager version from http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/
# If using Windows, see the specific details for Windows further down the page
# Download the english parameter file from here: http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/english-par-linux-3.2-utf8.bin.gz (or as listed elsewhere on the page above)
# If desired, download other language parameter files (not described in this script)
# Unzip the downloaded package, and VERY CAREFULLY follow ALL the instructions in the INSTALL.txt file contained within.
# This script assumes you install Tree Tagger to its default of c:/TreeTagger.  If not, adjust accordingly in the user-defined parameters below
# Pay particular attention to the PATH environment variable setting so that the R script can find the Tree Tagger script files
#
# After you're all done, to to the treetagger/lib directory and copy the english-utf8.par file to english.par because
# koRpus has the name hardcoded.
#
#
# INSTALL AND CONFIGURE PERL
#
# Tree Tagger depends on PERL, so we need to intall it.
# We assume Windows, so use download the latest version of Active Perl 64-bit here: http://www.activestate.com/activeperl/downloads
# Run the installer as administrator.  Default values should be fine.
# Reboot the system
# Verify that the PERL executable shows up in the system PATH
#
#
#
# END OF DEPENDENCIES TO RUN SCRIPT
#
#################################################################################

#################################################################################
# 								START OF SCRIPT									#
#################################################################################


# SET USER-DEFINED PARAMETERS
set_parameters <- function () {

# Set the number of logical CPU cores that will be used for parallel execution functions
CPU_CORES						<<- 8L;

# Set the full path to the Tree Tagger root install directory (not /bin!!!)
TREETAGGER_LOCATION				<<- "c:/TreeTagger";

# Set full path to the default Tree Tagger english tagging script
TREETAGGER_SCRIPT_LOCATION		<<- "c:/TreeTagger/bin/tag-english.bat";


# Set the date & time for the end of the database snapshot
DATABASE_END_TIMESTAMP			<<- as.POSIXct("2013-01-01 10:01:00", format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01");

# This timestamp identifies profiles that have bad "creation_ts" values
BAD_PROFILE_CREATION_TIMESTAMP 	<<- as.POSIXct("2011-04-23 07:05:38", format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01");

# This timestamp identifies the date on which Firefox switched to the fast-release  cycle
FAST_RELEASE_START_TIMESTAMP	<<- as.POSIXct("2011-04-12 00:00:00", format="%Y-%m-%d %H:%M:%S", tz="UTC", origin="1970-01-01");

# Imputation parameters
MERGE_MOZILLA_DOMAINS 			<<- TRUE;
MERGE_DOT_BUGS_DOMAINS			<<- TRUE;
MERGE_BUGZILLA_DOMAINS			<<- TRUE;
MERGE_KNOWN_ORG_DOMAINS			<<- TRUE;
MERGE_FORMERLY_NETSCAPE_DOMAINS	<<- FALSE;
MERGE_KNOWN_USER_DOMAINS		<<- FALSE;
DELETE_NOBODY_PROFILE			<<- FALSE;
DELETE_COMPONENT_WATCH_PROFILES <<- FALSE;
CORRECT_TYPO_DOMAINS			<<- TRUE;
DELETE_TEST_BUGS				<<- FALSE;
ALLOW_INVALID_TLDS				<<- TRUE;
ALLOW_UNUSUAL_TLDS				<<-	TRUE;

# Call slower functions?

RUN_SLOW_FUNCTIONS				<<- FALSE; # Adds around 40 minutes to base time of 26 minutes (+200% roughly) on hardware described above
RUN_VERY_SLOW_FUNCTIONS			<<- FALSE; # Contains two functions, each of which takes 7-10 DAYS to run on hardware described above. Consider yourself warned! ^_^
RUN_BUGS_SUMMARY_FUNCTION		<<- FALSE; # Adds around 40 minutes to base time of 26 minutes (+200% roughly) on hardware described above

# Output parameters
OUTPUT_SUMMARY_TABLES_TO_FILE	<<- FALSE; # Currently only outputs bugs_summary tables to file. Ignored if RUN_BUGS_SUMMARY_FUNCTION=FALSE

} # End set_parameters function


# SET R OPTIONS FOR CODE EXECUTION ENVIRONMENT
set_options <- function () {

# Increase the memory limit to force Windows to use the pagefile for all other processes and allocate 
# maximum amount of physical RAM to R
memory.limit(100000);

# Set warnings to display as they occur and give verbose output and limit printed output
options(warn=1, verbose=TRUE, max.print=1000L);

} # End set_options function


# LOAD LIBRARIES
load_libraries <- function () {

# Load the Data.table library for data.table objects and fread() function
library(data.table);

# Load plyr and dplyr and tidyr libraries for data table manipulation functions
library(dplyr);
library(tidyr);

# Load chron for easy date-time manipulation and calculation
library(chron);

# Load output libraries.  Only needed if outputting to file is being done.
if(OUTPUT_SUMMARY_TABLES_TO_FILE) {
	library(knitr);
	library(xtable);
	library(xlsx);
}

# Load doParallel and its dependencies, foreach, parallel, and iterators & itertoolsfor parallel processing speedups
library(doParallel);
library(itertools);

# Load textcat for our text prediction and koRpus for text readability calculations
library(textcat);
library(koRpus);

# koRpus can also use optional package tm for some optimizations, so load it too.
library(tm);

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


# REMOVE COLUMNS WITH ALL ZEROES
# Most solutions assume matrices or data.frames
# This function operates on data.tables as well
# Adapted from version posted by @user3969377 (http://stackoverflow.com/users/3969377/user3969377)
# Posted here: http://stackoverflow.com/a/26845958/5103848
remove_all_zero_cols <- function(ddt) {

	# Identify  indexes of cols with all zeros
	idx_all_zeros 	<- ddt[, lapply(.SD, function(x){ (is.numeric(x) & all(x==0))  })];
	idx_all_zeros 	<- which(unlist(idx_all_zeros));
		
	# Determine the numeric columns that have nonzero values
	idx_good 	<- setdiff(seq(1,ncol(ddt)), idx_all_zeros);

	# Return nonzero numeric data
	return(ddt[, names(ddt)[idx_good], with=FALSE]);

} # End remove_all_zero_cols function


# SHOW TRUE UNICODE CHARACTERS
# This function converts the format <U+xxxx> values to their actual unicode characters
# Adapted from version provided by MrFlick (http://stackoverflow.com/users/2372064/mrflick) at
# http://stackoverflow.com/questions/28248457/gsub-in-r-with-unicode-replacement-give-different-results-under-windows-compared

true_unicode <- function(x) {
    packuni		<-Vectorize(function(cp) {
        bv 		<- intToBits(cp);
        maxbit 	<- tail(which(bv!=as.raw(0)),1);
        if(maxbit < 8) {
            rawToChar(as.raw(codepoint));
        } else if (maxbit < 12) {
            rawToChar(rev(packBits(c(bv[1:6], as.raw(c(0,1)), bv[7:11], as.raw(c(0,1,1))), "raw")));
        } else if (maxbit < 17){
            rawToChar(rev(packBits(c(bv[1:6], as.raw(c(0,1)), bv[7:12], as.raw(c(0,1)), bv[13:16], as.raw(c(0,1,1,1))), "raw")));    
        } else {
           stop("too many bits");
        }
    });
    m 			<- gregexpr("<U\\+[0-9a-fA-F]{4}>", x);
    codes 		<- regmatches(x,m);
    chars 		<- lapply(codes, function(x) {
        codepoints <- strtoi(paste0("0x", substring(x,4,7)));
        packuni(codepoints);

    });
    regmatches(x,m) <- chars;
    Encoding(x)<-"UTF-8";
    return(x);
} # End show true unicode characters function


# ROWMODES
# Returns a vector of the modal value of each row of a data.frame/data.table/matrix

# Adapted from http://stackoverflow.com/a/28200369/5103848
# By : http://stackoverflow.com/users/3732271/akrun

rowmodes <- function (data_table) {
				rowmodes_vector <-	setDT(melt(as.matrix(data_table)))[, .N ,.(Var1, value)][,value[which.max(N)], Var1]$V1;
				return(rowmodes_vector);
			}


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
bugs 				<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM bugs;');
profiles 			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM profiles;');
activity 			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM bugs_activity;');
cc 					<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM cc;');
attachments 		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM attachments;');
votes 				<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM votes;');
longdescs 			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM longdescs;');
watch 				<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM watch;');
duplicates			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM duplicates;');
group_list			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM groups;');
group_members		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM user_group_map;');
keywords			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM keywords;');
flags				<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM flags;');
products			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM products;');
dependencies		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM dependencies;');
components			<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM components;');
components_cc		<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM component_cc;');
components_watch	<<- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM component_watch;');

# We're now done with the RMySQL library, so detach it to prevent any problems
detach("package:RMySQL", unload=TRUE);

# After we've loaded all the data, the MySQL server hogs RAM because of its cashing, so restart it
# with the following commands to free up memory:
system("net stop MySQL55");
system("net start MySQL55");

# Note: If this command fails, check your services to see what the name of the MySQL service is and replace it here
# The installer is frustratingly inconsistent in this respect

} # End load_bugzilla_data_from_DB function


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
																										
# Rename the "comment_count" column to be clear why it is always slightly larger than the calculated comments_all_bugs_all_count later on
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
									 alias						= as.character(alias),
									 rep_platform				= as.factor(as.character(rep_platform)),
									 op_sys						= as.factor(as.character(op_sys)));	

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

	
# COMPONENTS

# Import the components table from the previous subroutine to work on
components_working <- components;

components_working <- mutate(components_working, name				= as.factor(as.character(name)),
												 initialowner		= as.factor(initialowner),
												 initialqacontact	= as.factor(initialqacontact),
												 description		= as.character(description),
												 product_id			= as.factor(product_id),
												 id					= as.factor(id),
												 isactive			= as.logical(isactive),
												 watch_user			= as.factor(watch_user));


# COMPONENTS_CC

# Import the components table from the previous subroutine to work on
components_cc_working <- components_cc;

components_cc_working <- mutate(components_cc, user_id		= as.factor(user_id),
											   component_id	= as.factor(component_id));


# COMPONENTS_WATCH

# Import the components table from the previous subroutine to work on
components_watch_working <- components_watch;

components_watch_working <- mutate(components_watch_working, user_id		= as.factor(user_id),
															 component_id	= as.factor(component_id),
															 product_id		= as.factor(product_id));



												 
# CLEANUP											 
											 
# Create global variable to use in other functions
# Make them all data.tables along the way since we'll use functions from the data.tables library throughout

profiles_clean 			<<- as.data.table(profiles_working);
bugs_clean				<<- as.data.table(bugs_working);
longdescs_clean			<<- as.data.table(longdescs_working);
activity_clean			<<- as.data.table(activity_working);
cc_clean				<<- as.data.table(cc_working);
attachments_clean		<<- as.data.table(attachments_working);
votes_clean				<<- as.data.table(votes_working);
watch_clean				<<- as.data.table(watch_working);
duplicates_clean		<<- as.data.table(duplicates_working);
group_members_clean		<<- as.data.table(group_members_working);
keywords_clean			<<- as.data.table(keywords_working);
flags_clean				<<- as.data.table(flags_working);
products_clean			<<- as.data.table(products_working);
dependencies_clean  	<<- as.data.table(dependencies_working);
group_list_clean		<<- as.data.table(group_list_working);
components_clean		<<- as.data.table(components_working);
components_cc_clean		<<- as.data.table(components_cc_working);
components_watch_clean	<<- as.data.table(components_watch_working);	


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

if (DELETE_NOBODY_PROFILE == FALSE) {
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
													
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for the bug_id related to each activity
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
										
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for the bug_id related to each cc
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
													
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for the bug_id related to each attachments
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
										
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for the bug_id related to each vote
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
										
# Add the reporter/assigned_to/qa_contact domains & is_org_domains for the bug_id related to each comment
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

# Add the reporter/assigned_to/qa_contact domains & is_org_domains for the bug_id related to each keyword
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

# Add the reporter/assigned_to/qa_contact domains & is_org_domains for the bug_id related to each flag
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


# COMPONENTS

# Import the components table from the previous functions to work on
components_working <- components_clean;

# Add the initialowner domain & is_org_domain for the user_id related to each component
setkey(profiles_working, userid);
setkey(components_working, initialowner);
components_working <- merge(components_working, select(profiles_working, userid, domain, is_org_domain), by.x="initialowner", by.y="userid", all.x=TRUE);			

# Rename the new variables to not clobber with subsequent merges
components_working <- dplyr::rename(components_working, initialowner_domain			= domain,
														is_org_initialowner_domain 	= is_org_domain);

															
# Repeat for initialqacontact
setkey(components_working, initialqacontact);
components_working <- merge(components_working, select(profiles_working, userid, domain, is_org_domain), by.x="initialqacontact", by.y="userid", all.x=TRUE);			

# Rename the new variables to not clobber with subsequent merges
components_working <- dplyr::rename(components_working, initialqacontact_domain			= domain,
														is_org_initialqacontact_domain 	= is_org_domain);

# Repeat for watch_user	
setkey(components_working, watch_user);
components_working <- merge(components_working, select(profiles_working, userid, domain, is_org_domain), by.x="watch_user", by.y="userid", all.x=TRUE);			

# Rename the new variables to make clear what they are
components_working <- dplyr::rename(components_working, watch_user_domain			= domain,
														is_org_watch_user_domain 	= is_org_domain);


# COMPONENTS_CC

# Import the components_cc table from the previous functions to work on
components_cc_working <- components_cc_clean;

# Add the user_id domain & is_org_domain for the user_id related to each component
setkey(profiles_working, userid);
setkey(components_cc_working, user_id);
components_cc_working <- merge(components_cc_working, select(profiles_working, userid, domain, is_org_domain), by.x="user_id", by.y="userid", all.x=TRUE);			

# Rename the new variables to make clear what they are
components_cc_working <- dplyr::rename(components_cc_working, user_id_domain		= domain,
															  is_org_user_id_domain = is_org_domain);
	

# COMPONENTS_WATCH

# Import the components_watch table from the previous functions to work on
components_watch_working <- components_watch_clean;

# Add the user_id domain & is_org_domain for the user_id related to each component
setkey(profiles_working, userid);
setkey(components_watch_working, user_id);
components_watch_working <- merge(components_watch_working, select(profiles_working, userid, domain, is_org_domain), by.x="user_id", by.y="userid", all.x=TRUE);			

# Rename the new variables to make clear what they are
components_watch_working <- dplyr::rename(components_watch_working, user_id_domain			= domain,
																	is_org_user_id_domain 	= is_org_domain);	
	
	
	
	
	
# CLEAN UP

# Create global variable to use in other functions

profiles_domains 			<<- profiles_working;
bugs_domains				<<- bugs_working;
activity_domains			<<- activity_working;
cc_domains					<<- cc_working;
attachments_domains 		<<- attachments_working;
votes_domains				<<- votes_working;
longdescs_domains			<<- longdescs_working;
watch_domains				<<- watch_working;
duplicates_domains			<<- duplicates_working;
group_members_domains		<<- group_members_working;
keywords_domains			<<- keywords_working;
flags_domains				<<- flags_working;
dependencies_domains		<<- dependencies_working;
components_domains			<<- components_working;
components_cc_domains		<<- components_cc_working;
components_watch_domains	<<- components_watch_working;


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

# Set three variables that specify whether the each user is a default component owner or default component qa_contact or default component CC
# It's a simple matter of checking if their user_id shows up in the respective fields in the components & components_CC tables

profiles_working <- mutate(profiles_working, component_owner 		= as.logical(userid %in% components_domains$initialowner),
											 component_qa_contact 	= as.logical(userid %in% components_domains$initialqacontact),
											 component_cc			= as.logical(userid %in% components_cc_domains$user_id));
											 

# Set three variables that are the numeric counts of the logical versions above
# It's a simple matter of grouping by user in each of the columns and using summarize to check n() count

# Group the components table by initialowner to prepare for DPLYR's summarize() function
components_initialowner 			<- group_by(components_domains, initialowner);

# Summarize the number of entries for each userid in the initialowner column of the components table:
components_initialowner_summary 	<- summarize(components_initialowner, component_owner_count = n());

# Repeat with components initialqacontact column & components_cc user_id column
components_initialqacontact 		<- group_by(components_domains, initialqacontact);
components_initialqacontact_summary <- summarize(components_initialqacontact, component_qa_contact_count = n());

components_cc_user_id 				<- group_by(components_cc_domains, user_id);
components_cc_user_id_summary		<- summarize(components_cc_user_id, component_cc_count = n());


# Merge the summary tables and profiles_working tables based on the different userid fields to add the three new count columns
setkey(components_initialowner_summary, 	initialowner);
setkey(components_initialqacontact_summary, initialqacontact);
setkey(components_cc_user_id_summary,		user_id);
setkey(profiles_working, userid);

profiles_working <- merge(profiles_working, components_initialowner_summary, by.x="userid", 	by.y="initialowner", 	 all.x=TRUE);
profiles_working <- merge(profiles_working, components_initialqacontact_summary, by.x="userid", by.y="initialqacontact", all.x=TRUE);
profiles_working <- merge(profiles_working, components_cc_user_id_summary, by.x="userid", 		by.y="user_id", 		 all.x=TRUE);


# For any NA entries in the new count columns column, that means 0, so mutate them accordingly.
profiles_working <- mutate(profiles_working, component_owner_count 		= safe_ifelse(is.na(component_owner_count), 		0, component_owner_count),
											 component_qa_contact_count 	= safe_ifelse(is.na(component_qa_contact_count), 	0, component_qa_contact_count),
											 component_cc_count		 	= safe_ifelse(is.na(component_cc_count), 			0, component_cc_count));


# Set a variable if the user is designated as a "component watch" user, not a real user
# Component watch users are accounts created simply for the CC system to allow users to follow other (watch) users in order to follow a whole component
# It's a strange qwerk of the Mozilla Bugzilla implementation

profiles_working <- mutate(profiles_working, component_watch_profile = as.logical(userid %in% components_domains$watch_user));


# If the flag is set at the beginning of the program to delete profiles that are just component_watch profiles, delete them here

if (DELETE_COMPONENT_WATCH_PROFILES) {
	profiles_working <- filter(profiles_working, component_watch_profile==FALSE);
}


# Count the number of distinct components & products watched by each user
# Group the components_watch table by distinct pairs of user_id & component_id to prepare for DPLYR's summarize() function
components_watch_user_id_component_id 			<- group_by(distinct(components_watch_domains, user_id, component_id), user_id);

# Summarize the number of entries for each userid in the component_id column of the components_watch table:
components_watch_user_id_component_id_summary 	<- summarize(components_watch_user_id_component_id, component_watch_count = n());


# Repeat with product_id
components_watch_user_id_product_id 			<- group_by(distinct(components_watch_domains, user_id, product_id), user_id);
components_watch_user_id_product_id_summary 	<- summarize(components_watch_user_id_product_id, product_watch_count = n());


# Merge the summary tables and profiles_working tables based on the different userid fields to add the two new count columns
setkey(components_watch_user_id_component_id_summary, 	user_id);
setkey(components_watch_user_id_product_id_summary, 	user_id);
setkey(profiles_working, userid);

profiles_working <- merge(profiles_working, components_watch_user_id_component_id_summary, by.x="userid", 	by.y="user_id", 	 all.x=TRUE);
profiles_working <- merge(profiles_working, components_watch_user_id_product_id_summary,   by.x="userid", 	by.y="user_id", 	 all.x=TRUE);



# For any NA entries in the new count columns column, that means 0, so mutate them accordingly.
profiles_working <- mutate(profiles_working, component_watch_count = safe_ifelse(is.na(component_watch_count), 0, component_watch_count),
											 product_watch_count	= safe_ifelse(is.na(product_watch_count), 	 0, product_watch_count));
	


	
# BUGS

# Import the bugs_domains table from the previous subroutine to work on
bugs_working <- bugs_domains;

# Add a numerical version of "bug_severity" field since it's ordered factors
# Read in the bug_severity lookup table from file
severity_lookup <- read.table("severity_lookup.txt", sep=",", header=TRUE);
severity_lookup <- as.data.table(severity_lookup);

# Bug_severity column gets types set wrong, so reset it here
severity_lookup <- mutate(severity_lookup, bug_severity = as.factor(as.character(bug_severity)),
										   severity		= as.factor(severity));


# Merge the new "severity" numerical column according to "bug_severity"
setkey(severity_lookup, bug_severity);
setkey(bugs_working, bug_severity);
bugs_working <- merge(bugs_working, severity_lookup, by='bug_severity', all.x=TRUE);


# Add a outcome variable that reduces all combinations "bug_status" and "resolution" to one of "fixed", "not_fixed", or "pending"
# Read in the outcome lookup table from file
outcome_lookup <- read.table("outcome_lookup.txt", sep=",", header=TRUE);
outcome_lookup <- as.data.table(outcome_lookup);

# Outcome lookup status gets type set wrong, so reset it here
outcome_lookup <- mutate(outcome_lookup, bug_status = as.factor(as.character(bug_status)),
										 resolution = as.factor(as.character(resolution)),
										 outcome 	= as.factor(as.character(outcome)));

# Merge the new "outcome" column according to "bug_status" and "resolution" combinations
setkey(outcome_lookup, bug_status, resolution);
setkey(bugs_working, bug_status, resolution);
bugs_working <- merge(bugs_working, outcome_lookup, by=c('bug_status', 'resolution'), all.x=TRUE);


# Count the number of chracters in the title ("short_desc") and make that its own column, "title_length"
# Since nchar() returns 2 when title is blank, our ifelse catches that case and sets it to 0
bugs_working <- mutate(bugs_working, title_length = safe_ifelse(short_desc=="", 0, nchar(short_desc)));
																								  

# Add the product_classification to the bugs list to allow easy filtering all of the many products into 6 major categories
# Classifications range from 1 to 6 as follows:
# 1: Unclassified 		(Not used; classification required to file bug)
# 2: Client software 	(End user products developed by Mozilla and contributors)
# 3: Components 		(Standalone components that can be used by multiple products)
# 4: Server software 	(Web server software developed by Mozilla and contributors)
# 5: Other 				(Everything else; mostly things that don't involve programming/software code)
# 6: Graveyard 			(Retired products)

# Import just the "id" and "classification_id" columns of the products_clean table that will act as our lookup
products_id_classification <- select(products_clean, id, classification_id, product_name = name);

# Make the names lowercase and substitute spaces with underscores
products_id_classification <- mutate(products_id_classification, product_name = tolower(product_name));
products_id_classification$product_name <- gsub(" ", "_", products_id_classification$product_name, fixed=TRUE);


# Merge the new product_classification column into the bugs_working table based on product_id
setkey(products_id_classification, id);
setkey(bugs_working, product_id);
bugs_working <- merge(bugs_working, products_id_classification, by.x="product_id", by.y="id", all.x=TRUE);


# Create a table that acts as a lookup for the classification names for simplicity
classification_names_lookup <- data.table(classification_id 	= as.factor(c(1:6)),
										  classification_name	= as.factor(c("unclassified", "client_software", "components", "server_software", "other", "graveyard")));

# Merge the classification names lookup table based on classification_id to add a names column
setkey(classification_names_lookup, classification_id);
setkey(bugs_working, classification_id);
bugs_working <- merge(bugs_working, classification_names_lookup, by="classification_id", all.x=TRUE);


# Use the components table to merge the component_name variable with each bug based on component_id
setkey(components_domains, id);
setkey(bugs_working, component_id);
bugs_working <- merge(bugs_working, select(components_domains, id, component_name = name), by.x="component_id", by.y="id", all.x=TRUE);


# Add a logical column for is_pre_fast_release if bug's creation_ts is before FAST_RELEASE_START_TIMESTAMP
bugs_working <- mutate(bugs_working, is_pre_fast_release = as.logical(creation_ts <= FAST_RELEASE_START_TIMESTAMP));


# Add numerical columns for the year, month, monthday, weekday the bug was reported, for easier lookup later without additional calculations
bugs_working <- mutate(bugs_working, creation_year 		= as.factor(year  	(creation_ts)),	 # integer factor
									 creation_month		= as.factor(months	(creation_ts)),	 # character factor
									 creation_monthday	= as.factor(days  	(creation_ts)),	 # integer factor
									 creation_weekday	= as.factor(weekdays(creation_ts))); # character factor

									 

# ACTIVITY

# Import activity table from previous function to work on
activity_working <- activity_domains;


# Merge the newly created bugs_working columns for products, classifications, components, rep_platform, and op_sys
activity_working <- merge(activity_working, select(bugs_working, bug_id,
																 bug_product_id 	   = product_id, 		bug_product_name 		= product_name,
														         bug_classification_id = classification_id, bug_classification_name = classification_name,
																 bug_component_id 	   = component_id, 	 	bug_component_name 	 	= component_name,
																 bug_rep_platform	   = rep_platform,		bug_op_sys				= op_sys),
																																						   by="bug_id", all.x=TRUE);
							 
# LONGDESCS

# Import longdescs table from previous function to work on
longdescs_working <- longdescs_domains;

# Create a new column in the longdescs_working table that has the character length of each comment
# Since nchar() returns 2 when comment is blank, our ifelse catches that case and sets it to 0
longdescs_working <- mutate(longdescs_working, comment_length = safe_ifelse(thetext=="" | is.na(thetext), 0, nchar(thetext)));

setkey(longdescs_working, bug_id);
setkey(bugs_working,      bug_id);
longdescs_working <- merge(longdescs_working, select(bugs_working, bug_id,
																   bug_product_id 	     = product_id, 		  bug_product_name 		  = product_name,
																   bug_classification_id = classification_id, bug_classification_name = classification_name,
																   bug_component_id 	 = component_id, 	  bug_component_name 	  = component_name,
																   bug_rep_platform	     = rep_platform,	  bug_op_sys			  = op_sys,
																   bug_priority		     = priority, 		  bug_severity),
																																							 by="bug_id", all.x=TRUE);

# KEYWORDS

# Import keywords table from previous function to work on
keywords_working <- keywords_domains;

# Add columns if keyword id is top_3/10/25/50_keyword.  Present database has 375 keywords
# First group the table according to keywordid to prepare for summarise()
keywords_working_grouped <- group_by(keywords_working, keywordid);

# Count the number of times each keyword is used
keywords_working_summarized <- summarize(keywords_working_grouped, bugs_using_keyword_count = n()) %>% arrange(-bugs_using_keyword_count);

# Identify the top 3/10/25/50
top_3_keyword_ids 	<- top_n(keywords_working_summarized,  3)$keywordid;
top_10_keyword_ids 	<- top_n(keywords_working_summarized, 10)$keywordid;
top_25_keyword_ids 	<- top_n(keywords_working_summarized, 25)$keywordid;
top_50_keyword_ids 	<- top_n(keywords_working_summarized, 50)$keywordid;

# Set the columns in the keywords_working table
keywords_working <- mutate(keywords_working, is_top_3_keyword	= as.logical(keywordid %in% top_3_keyword_ids),
											 is_top_10_keyword	= as.logical(keywordid %in% top_10_keyword_ids),
											 is_top_25_keyword	= as.logical(keywordid %in% top_25_keyword_ids),
											 is_top_50_keyword	= as.logical(keywordid %in% top_50_keyword_ids));

	
# VOTES

# Import votes table from previous function to work on
votes_working <- votes_domains;	

setkey(votes_working, bug_id);
setkey(bugs_working,  bug_id);
votes_working <- merge(votes_working, select(bugs_working, bug_id,
														   bug_product_id 	     = product_id, 		  bug_product_name 		  = product_name,
														   bug_classification_id = classification_id, bug_classification_name = classification_name,
														   bug_component_id 	 = component_id, 	  bug_component_name 	  = component_name,
														   bug_rep_platform	     = rep_platform,	  bug_op_sys			  = op_sys,
														   bug_priority		     = priority, 		  bug_severity),
																																					 by="bug_id", all.x=TRUE);


# CC

# Import CC table from previous function to work on
cc_working <- cc_domains;	

setkey(cc_working,   bug_id);
setkey(bugs_working, bug_id);
cc_working <- merge(cc_working, select(bugs_working, bug_id,
													 bug_product_id 	   = product_id, 		  bug_product_name 		= product_name,
													 bug_classification_id = classification_id, bug_classification_name = classification_name,
													 bug_component_id 	   = component_id, 	  bug_component_name 	    = component_name,
													 bug_rep_platform	   = rep_platform,	  bug_op_sys			    = op_sys,
													 bug_priority		   = priority, 		  bug_severity),
																																				by="bug_id", all.x=TRUE);

# CLEAN UP
 
# Set global variables for other functions
profiles_base 			<<- profiles_working;
bugs_base 				<<- bugs_working;
activity_base			<<- activity_working;
longdescs_base			<<- longdescs_working;
keywords_base			<<-	keywords_working;
votes_base				<<- votes_working;
cc_base					<<- cc_working;

# Carried forward from domains since not changed in base
activity_base			<<- activity_working;
attachments_base		<<- attachments_domains;
watch_base				<<- watch_domains;
group_members_base		<<- group_members_domains;
flags_base				<<- flags_domains;
duplicates_base			<<- duplicates_domains;
dependencies_base		<<- dependencies_domains;
components_base			<<- components_domains;
components_cc_base		<<- components_cc_domains;
components_watch_base	<<- components_watch_domains;

# Carried forward from clean function since not changed in base or domains
group_list_base			<<- group_list_clean;
products_base			<<- products_clean;

} # End operationalize_base function


# OPERATIONALIZE INTERACTIONS BETWEEN TABLES
# We split this function into two for better memory management in R

operationalize_interactions_partial <- function () {

# The primary focus of this function is to make the profiles & bugs tables, the two primary tables
# longer by adding columns that are based on various index manipulations with other tables
# This way, all of the rows will constitute the "cases" for analysis, and all of the columns will be the dependent or independent variables as appropriate
# Doing this upfront makes the actual statistical portion of the research a lot clearer and easier to interpret


# PROFILES-USER-ACTIVITY

# Import profiles from previous subroutine
profiles_working <- profiles_base;

# Count the activities for each user in the activity table
activity_user_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(activity_base$who)), -Freq), who = Var1));

# Merge the "activity_count" with the profiles table based on "who" and "userid"
setkey(activity_user_count, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_user_count, by.x="userid", by.y="who", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, activity_count = Freq);

# For any NA entries in the "activity_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, activity_count = safe_ifelse(is.na(activity_count), 0, activity_count));


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

# Merge the "bugs_reported_count" with the profiles table based on "reporter" and "userid"
setkey(bug_user_reported_count, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_reported_count, by.x="userid", by.y="reporter", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, bugs_reported_count = Freq);

# For any NA entries in the "bugs_reported_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, bugs_reported_count = safe_ifelse(is.na(bugs_reported_count), 0, bugs_reported_count));


# PROFILES-BUGS_USER_ASSIGNED

# Count the bugs assigned to each user in the bugs table
bug_user_assigned_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$assigned_to)), -Freq), assigned = Var1));

# Merge the "bugs_assigned_to_count" with the profiles table based on "assigned_to" and "userid"
setkey(bug_user_assigned_count, assigned);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_assigned_count, by.x="userid", by.y="assigned", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, bugs_assigned_to_count = Freq);

# For any NA entries in the "bugs_assigned_to_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, bugs_assigned_to_count = safe_ifelse(is.na(bugs_assigned_to_count), 0, bugs_assigned_to_count));


# PROFILES-BUGS_USER_QA

# Count the bugs where each user is set as QA in the bugs table
bug_user_qa_count <- as.data.table(dplyr::rename(arrange(as.data.frame(table(bugs_base$qa_contact)), -Freq), qa = Var1));

# Merge the "bugs_qa_contact_count" with the profiles table based on "qa" and "userid"
setkey(bug_user_qa_count, qa);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bug_user_qa_count, by.x="userid", by.y="qa", all.x=TRUE);
profiles_working <- dplyr::rename(profiles_working, bugs_qa_contact_count = Freq);

# For any NA entries in the "bugs_qa_contact_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, bugs_qa_contact_count = safe_ifelse(is.na(bugs_qa_contact_count), 0, bugs_qa_contact_count));


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


# BUGS-ACTIVITY_CENSOR_TS

# Filter the activities table for cases where some sort of resolution has occured by setting of status
# This measure is sometimes distinct from time between creation_ts & cf_last_resolved (if not NA), so both are created
# The possible resolutions are in "added" and are "CLOSED", "RESOLVED" or "VERIFIED"
# These SHOULD only appear in fieldid 29 which is "bug_status", but sometimes they end up elsewhere, so check for fieldid
activity_resolved <- filter(activity_base,(added=="CLOSED" 		& fieldid==29) | 
										  (added=="RESOLVED" 	& fieldid==29) | 
										  (added=="VERIFIED" 	& fieldid==29));

# Rearrange the resolved activities by descending date, meaning present, backwards, or most recent dates first
activity_resolved <- arrange(activity_resolved, desc(bug_when));

# Filter the resolved activities to the most recent (last) one per unique bug
# This way, if there are multiple "CLOSED", etc. because of reopening, we only catch the most recent (ast) one
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

# We'll use the censor_ts in the calculated function later on to get days_to_resolution


# BUGS-ACTIVITY_LIFECYCLE

# The purpose of this section is to set a logical value (violated_bug_lifecycle) that is
# TRUE when the bug has one or more illegal state transitions as defined below and
# FALSE otherwise
# Unfortunately, the result will be a conservative subset since state transitions can happen with
# multiple activities, making it difficult to determine all the possible combinations of bad state transitions
# The conservative subset here only captures illegal state transitions done in a single activity
# This is an acceptable tradeoff because it guarantees that the same actor did both the "removed" and "added" action
# so the illegal state transition can't be said to be the result of two or more actors misunderstanding or poorly coordinating
# multiple activities


# We can filter the activities table for illegal state transitions
# The bug_ids associated with those activities can then be used to set the violated_bug_lifecycle value
# Illegal state transitions are determined based on the Bugzilla 3.0 bug lifecycle, which was in use for the whole time of this DB snapshot
# See: https://commons.wikimedia.org/wiki/File:Bugzilla_Lifecycle_color-aqua.svg

# For reference, all of the distinct removed/added pairs can be easily looked up in the activity table
# with the following command
# filter(activity_base, fieldid==29) %>% select(removed, added) %>% distinct(removed, added) %>% arrange(removed);

activity_illegal <- filter(activity_base,	(removed=="ASSIGNED"		&	added=="UNCONFIRMED"  	& fieldid==29)	|
											(removed=="ASSIGNED"		&	added=="REOPENED" 		& fieldid==29)	|
											(removed=="CLOSED" 			& 	added=="VERIFIED" 		& fieldid==29)	|
											(removed=="CLOSED" 			& 	added=="RESOLVED" 		& fieldid==29)	|
											(removed=="NEW"				&	added=="UNCONFIRMED"  	& fieldid==29)	|
											(removed=="NEW"				&	added=="VERIFIED"	  	& fieldid==29)	|
											(removed=="NEW"				&	added=="REOPENED"	  	& fieldid==29)	|
											(removed=="REOPENED"		&	added=="NEW"	  		& fieldid==29)	|
											(removed=="REOPENED"		&	added=="CLOSED"	  		& fieldid==29)	|
											(removed=="REOPENED"		&	added=="VERIFIED"	  	& fieldid==29)	|
											(removed=="REOPENED"		&	added=="UNCONFIRMED"  	& fieldid==29)	|
											(removed=="RESOLVED"		&	added=="ASSIGNED"  		& fieldid==29)	|
											(removed=="UNCONFIRMED"		&	added=="CLOSED"	  		& fieldid==29)	|
											(removed=="UNCONFIRMED"		&	added=="VERIFIED"	  	& fieldid==29)	|
											(removed=="VERIFIED"		&	added=="RESOLVED"	  	& fieldid==29)	|
											(removed=="VERIFIED"		&	added=="ASSIGNED"	  	& fieldid==29));
											
# Compare the bug_ids in the activity_illegal list to set the logical violated_bug_lifecycle variable 											
bugs_working <- mutate(bugs_working, violated_bug_lifecycle = as.logical(bug_id %in% activity_illegal$bug_id));



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


# BUGS-ACTIVITY_ASSIGNED_AND_ASSIGNING_TIMESTAMPS

# Filter the activity table for entries that represent bug assignment count
# Bug assignment is defined by transition, although sometimes the transition is ignored and the
# change of "assigned_to" person in field 34 is the only evidence of assignment
# We'll operationalize it as transition only because change of "assigned_to" person is most often a bounce rejection
# Or, the assigned_to person is userid "1" which is actually a placeholder for "nobody", so screws up analysis
# It's not ideal, but the transitions should be a conservative subset that are actually assignments, whereas
# the inclusion of change of "assigned_to" person is likely to hit a lot of false positives, espeically with tracking userids
# As such, this conservative subset can be thought of as "assigned_and_accepted_count", which is distinct from the case in
# profiles_user_bugs_assigned_to_count, where we treat it as "assigned_but_maybe_not_accepted_count"
#
# Further, jump transitions from new or unconfirmed directly to resolved may indicate a assignment and fix 
# or it may indicate a rejection as wontfix or invalid, so can't include in this conservative measure
# Manual inspection of the rare cases of new or unconfirmed going straight to verified suggest no assignment took place
# so we don't include those cases.
# The possible transitions are listed as alternatives int he filters as follows:

activity_assigned <- filter(activity_base,  (removed=="NEW"			& added=="ASSIGNED"		& fieldid==29) |
											(removed=="REOPENED"	& added=="ASSIGNED"		& fieldid==29) |
											(removed=="UNCONFIRMED"	& added=="ASSIGNED"		& fieldid==29) |
											(removed=="VERIFIED" 	& added=="ASSIGNED" 	& fieldid==29) |
											(removed=="RESOLVED" 	& added=="ASSIGNED"		& fieldid==29));

# Arrange them by date so that the first entries for each bug are the oldest
# That way, the first "assigned" entry for each bug can be used to calculate the "time to first assignment"
activity_assigned_arranged <- arrange(activity_assigned, bug_when);

# Capture the first entry of each bug_id to get our "time of first assignment" timestamp for each bug
activity_assigned_arranged_distinct <- distinct(activity_assigned_arranged, bug_id);

# Drop all the columns except bug_id & bug_when and rename bug_when to first_assignment_ts
activity_assigned_arranged_distinct_subset <- select(activity_assigned_arranged_distinct, bug_id, first_assignment_ts = bug_when);

# Merge the activity_assigned_arranged_distinct_subset and bugs_working tables based on bug_id to add first_assignment_ts column
setkey(activity_assigned_arranged_distinct_subset, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_assigned_arranged_distinct_subset, by="bug_id", all.x=TRUE);

# NA values mean the bug was never assigned, so leave them as NA as there is no valid value for first_assignment_ts possible

# Repeat with sort order of activities reversed to get "time to last assignment"
activity_assigned_reversed <- arrange(activity_assigned, desc(bug_when));

# Capture the last entry of each bug_id to get our "time of last assignment" timestamp for each bug
activity_assigned_reversed_distinct <- distinct(activity_assigned_reversed, bug_id);

# Drop all the columns except bug_id & bug_when and rename bug_when to last_assignment_ts
activity_assigned_reversed_distinct_subset <- select(activity_assigned_reversed_distinct, bug_id, last_assignment_ts = bug_when);

# Merge the activity_assigned_reversed_distinct_subset and bugs_working tables based on bug_id to add last_assignment_ts column
setkey(activity_assigned_reversed_distinct_subset, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_assigned_reversed_distinct_subset, by="bug_id", all.x=TRUE);

# NA values mean the bug was never assigned, so leave them as NA as there is no valid value for last_assignment_ts possible
# We'll use these new timestamps in the calculated function later
					 
									 
# Continuing with the whole activity_assigned (not just distinct bugs) table, we can now count the number of "assigning" activities for each bug
											
# Use DPLYR group_by() function to organize the full activity_assigned table by bug_id to prepare for summarize() function
activity_assigned_grouped <- group_by(activity_assigned, bug_id);

# Use DPLYR summarize() to get the count of assignment activities per bug_id
activity_assigned_summary <- summarize(activity_assigned_grouped, assigned_count = n());

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
activity_reassigned <- filter(activity_base,  (removed=="REOPENED"	& added=="NEW"			& fieldid==29) |
											  (removed=="REOPENED"	& added=="UNCONFIRMED"	& fieldid==29) |
											  (removed=="VERIFIED"	& added=="RESOLVED"		& fieldid==29) |
											  (removed=="ASSIGNED"  & added=="NEW" 			& fieldid==29) |
											  (removed=="ASSIGNED" 	& added=="UNCONFIRMED" 	& fieldid==29) |
											  (removed=="ASSIGNED" 	& added=="REOPENED"		& fieldid==29));

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


# BUGS-ACTIVITY_QA_CONTACTS_QA_CONTACT_SETTING_TIMESTAMPS

# There's no clean way to identify a transition TO the setting of a qa_contact, only FROM with "verified" status
# As a result, we have to use the setting of the "qa_contact" value (fieldid 36) to something other than "" or "1" or "nobody@mozilla.org" 
# as the identification of the setting qa_contact person.  It's ugly, but that's all we have!
# First we need to identify all the cases of valid "qa_contacts" being set, ignoring "removed" for a moment
activity_qa_contact <- filter(activity_base, added != "" & added != "1" & added != "nobody@mozilla.org" & !(is.na(added)) & fieldid==36);

# Sort by date (oldest to newest) to get the first setting of qa_contact
activity_qa_contact_arranged = arrange(activity_qa_contact, bug_when);

# Capture the last entry of each bug_id to get our "time of first qa_contact" timestamp for each bug
activity_qa_contact_arranged_distinct = distinct(activity_qa_contact_arranged, bug_id);

# Drop all the columns except bug_id & bug_when and rename bug_when to first_qa_contact_ts
activity_qa_contact_arranged_distinct_subset <- select(activity_qa_contact_arranged_distinct, bug_id, first_qa_contact_ts = bug_when);

# Merge the activity_qa_contact_arranged_distinct_subset and bugs_working tables based on bug_id to add first_qa_contact_ts column
setkey(activity_qa_contact_arranged_distinct_subset, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_qa_contact_arranged_distinct_subset, by="bug_id", all.x=TRUE);

# NA values mean the bug never had a qa_contact, so leave them as NA as there is no valid value for first_qa_contact_ts possible

# Repeat with sort order of activities reversed to get "time to last qa_contact"
activity_qa_contact_reversed <- arrange(activity_qa_contact, desc(bug_when));

# Capture the last entry of each bug_id to get our "time of last qa_contact" timestamp for each bug
activity_qa_contact_reversed_distinct <- distinct(activity_qa_contact_reversed, bug_id);

# Drop all the columns except bug_id & bug_when and rename bug_when to last_qa_contact_ts
activity_qa_contact_reversed_distinct_subset <- select(activity_qa_contact_reversed_distinct, bug_id, last_qa_contact_ts = bug_when);

# Merge the activity_qa_contact_reversed_distinct_subset and bugs_working tables based on bug_id to add last_qa_contact_ts column
setkey(activity_qa_contact_reversed_distinct_subset, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_qa_contact_reversed_distinct_subset, by="bug_id", all.x=TRUE);

# NA values mean the bug never had a qa_contact, so leave them as NA as there is no valid value for last_qa_contact_ts possible
# We'll use these new timestamps in the calculated function later


# Continuing with the whole activity_qa_contact (not just distinct bugs) table, we can now count the number of "qa_contact setting" activities for each bug

								
# Use DPLYR group_by() function to organize the full activity_qa_contact table by bug_id to prepare for summarize() function
activity_qa_contact_grouped <- group_by(activity_qa_contact, bug_id);

# Use DPLYR summarize() to get the count of qa_contact setting activities per bug_id
activity_qa_contact_summary <- summarize(activity_qa_contact_grouped, qa_contact_set_count = n());

# Merge the activity_qa_contact_summary table with the bugs_working table based on "bug_id"
setkey(activity_qa_contact_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_qa_contact_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "qa_contact_set_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, qa_contact_set_count = safe_ifelse(is.na(qa_contact_set_count), 0, qa_contact_set_count));
									 

# BUGS-ACTIVITY_DISTINCT_QA_CONTACTS_AND_ASSIGNED_TO
# (Count the number of distinct users who show up in the assigned_to and qa_contact fields for each bug over its lifecycle)
# The assigned_to_distinct_count value will be an underestimation because the assigned_to value could be set at bug creation time so may not show up in 
# the activity table at all.  At worst it's an underestimation of 1.

# We have already filtered the activity_qa_contact variable above, excluding distinct but invalid values
# We can now reduce it to distinct bug + "added" values
activity_qa_contact_distinct_added <- distinct(activity_qa_contact, bug_id, added);

# Use DPLYR group_by() function to organize the full activity_qa_contact_distinct_added table by bug_id to prepare for summarize() function
activity_qa_contact_distinct_added_grouped <- group_by(activity_qa_contact_distinct_added, bug_id);

# Use DPLYR summarize() to get the count of distinct qa_contact added values per bug_id
activity_qa_contact_distinct_added_summary <- summarize(activity_qa_contact_distinct_added_grouped, qa_contact_distinct_count = n());

# Merge the activity_qa_contact_distinct_added_summary table with the bugs_working table based on "bug_id"
setkey(activity_qa_contact_distinct_added_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_qa_contact_distinct_added_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "qa_contact_distinct_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, qa_contact_distinct_count = safe_ifelse(is.na(qa_contact_distinct_count), 0, qa_contact_distinct_count));


# Repeat with assigned_to
# The assigned_to field is 34, so we just need to count distinct "added" values for activities in field 34 for each bug
# We also want to exclude distinct but invalid values from our count just as we did with qa_contact
activity_assigned_to <- filter(activity_base, added != "" & added != "1" & added != "nobody@mozilla.org" & !(is.na(added)) & fieldid==34);
	
# We can now reduce it to distinct bug + "added" values
activity_assigned_to_distinct_added <- distinct(activity_assigned_to, bug_id, added);

# Use DPLYR group_by() function to organize the full activity_assigned_to_distinct_added table by bug_id to prepare for summarize() function
activity_assigned_to_distinct_added_grouped <- group_by(activity_assigned_to_distinct_added, bug_id);

# Use DPLYR summarize() to get the count of distinct assigned_to added values per bug_id
activity_assigned_to_distinct_added_summary <- summarize(activity_assigned_to_distinct_added_grouped, assigned_to_distinct_count = n());

# Merge the activity_assigned_to_distinct_added_summary table with the bugs_working table based on "bug_id"
setkey(activity_assigned_to_distinct_added_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_assigned_to_distinct_added_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "assigned_to_distinct_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, assigned_to_distinct_count = safe_ifelse(is.na(assigned_to_distinct_count), 0, assigned_to_distinct_count));	
	

# BUGS-ACTIVITY_DISTINCT_WHO
# (Count the number of distinct users who participate in each bug, showing up in the "who" field)

# Reduce the activity table to distinct bug_id & who pairs
activity_bug_id_who_distinct <- distinct(activity_base, bug_id, who);

# Use DPLYR group_by() function to organize the activity_bug_id_who_distinct table by bug_id to prepare for summarize() function
activity_bug_id_who_distinct_grouped <- group_by(activity_bug_id_who_distinct, bug_id);

# Use DPLYR summarize() to get the count of distinct who values per bug_id
activity_bug_id_who_distinct_summary <- summarize(activity_bug_id_who_distinct_grouped, activity_distinct_actors_count = n());

# Merge the activity_bug_id_who_distinct_summary table with the bugs_working table based on "bug_id"
setkey(activity_bug_id_who_distinct_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, activity_bug_id_who_distinct_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "activity_distinct_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, activity_distinct_actors_count = safe_ifelse(is.na(activity_distinct_actors_count), 0, activity_distinct_actors_count));

	
# BUGS-LONGDESCS_DESCRIPTION_LENGTH

# We want to count the number of characters in the initial comment when the bug was filed. This is effectively the
# "bug description" even though it's handled the same way as other comments.

# Rearrange the longdescs in the table by date, leaving most distant dates first, and most recent dates last
longdescs_working_arranged <- arrange(longdescs_base, bug_when);

# Filter to the first comment for each bug_id, which should be the submission full bug description
longdescs_working_distinct <- distinct(longdescs_working_arranged, bug_id);

# Drop all the columns except bug_id, description_length as comment_length field, description as thetext field, and description_comment_id as the comment_id field
longdescs_working_distinct_select <- select(longdescs_working_distinct, bug_id, 
																		description_length		= comment_length, 
																		description_comment_id 	= comment_id, 
																		description 			= thetext);

# Merge the "longdescs_working_distinct_select" and "bugs_working" tables based on bug_id to add columns "description_length", "description", and "description_comment_id"
setkey(longdescs_working_distinct_select, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_working_distinct_select, by="bug_id", all.x=TRUE);


# BUGS-LONGDESCS_DISTINCT_WHO
# (Count the number of distinct users who comment on each bug, showing up in the "who" field)

# The longdescs_working_distinct table provides us with a list of comments to ignore because they are actually "descriptions" for the bugs
description_comment_ids <<- longdescs_working_distinct$comment_id;

# Now filter the longdescs table to exclude descriptions
longdescs_comments_only <- filter(longdescs_base, !(comment_id %in% description_comment_ids));

# Reduce the longdescs table to distinct bug_id & who pairs
longdescs_comments_only_bug_id_who_distinct <- distinct(longdescs_comments_only, bug_id, who);

# Use DPLYR group_by() function to organize the longdescs_comments_only_bug_id_who_distinct table by bug_id to prepare for summarize() function
longdescs_comments_only_bug_id_who_distinct_grouped <- group_by(longdescs_comments_only_bug_id_who_distinct, bug_id);

# Use DPLYR summarize() to get the count of distinct who values per bug_id
longdescs_comments_only_bug_id_who_distinct_summary <- summarize(longdescs_comments_only_bug_id_who_distinct_grouped, comments_distinct_actors_count = n());

# Merge the longdescs_comments_only_bug_id_who_distinct_summary table with the bugs_working table based on "bug_id"
setkey(longdescs_comments_only_bug_id_who_distinct_summary, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, longdescs_comments_only_bug_id_who_distinct_summary, by="bug_id", all.x=TRUE);

# For any NA entries in the "comments_distinct_actors_count" column, that means 0, so mutate it accordingly.
bugs_working <- mutate(bugs_working, comments_distinct_actors_count = safe_ifelse(is.na(comments_distinct_actors_count), 0, comments_distinct_actors_count));


# BUGS-LONGDESCS_COMMENTS_ALL_ACTORS_AND_COMBINED_LENGTH_AND_MEAN_LENGTH

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
									 comments_mean_length		= safe_ifelse(is.na(comments_mean_length) 		| 
																			  comments_mean_length==0 			|
																			  comments_all_actors_count==0, 	  0, ((comments_mean_length * (comments_all_actors_count + 1)) - description_length) / comments_all_actors_count));


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


# PROFILES-BUGS_USER_REPORTED_REOPENED_OR_ASSIGNED_OR_REASSIGNED_OR_TARGET_MILESTONE_CHANGE_OR_SEVERITY_CHANGE
# (Track how many times each user that reported a bug, had it reopened, assigned or reassigned, or its target_milestone changed, or its severity changed)

# Use DPLYR's group_by() function to organize bugs_working table according to reporter userid
bugs_working_grouped_reporter <- group_by(bugs_working, reporter);

# Use DPLYR's summarize() function to sum reopened, assigned, and reassigned count across all bugs for each reporter
bugs_working_grouped_user_reporter_summary <- summarize(bugs_working_grouped_reporter,	bugs_reported_reopened_count				   = sum(reopened_count, 				 na.rm=TRUE),
																						bugs_reported_reopened_at_least_once_count	   = sum(reopened_count   >=1, 			 na.rm=TRUE),
																						bugs_reported_reopened_at_least_twice_count   = sum(reopened_count   >=2, 			 na.rm=TRUE),
																						bugs_reported_reopened_thrice_or_more_count   = sum(reopened_count   >=3, 			 na.rm=TRUE),
																						bugs_reported_assigned_count				   = sum(assigned_count, 				 na.rm=TRUE),
																						bugs_reported_reassigned_count 			   = sum(reassigned_count, 			     na.rm=TRUE),
																						bugs_reported_reassigned_at_least_once_count  = sum(reassigned_count >=1, 			 na.rm=TRUE),
																						bugs_reported_reassigned_at_least_twice_count = sum(reassigned_count >=2, 			 na.rm=TRUE),
																						bugs_reported_reassigned_thrice_or_more_count = sum(reassigned_count >=3, 			 na.rm=TRUE),
																						bugs_reported_target_milestone_change_count   = sum(target_milestone_change_count,  na.rm=TRUE),
																						bugs_reported_severity_change_count 		   = sum(severity_change_count,  		 na.rm=TRUE),
																						bugs_reported_priority_change_count 		   = sum(priority_change_count,  		 na.rm=TRUE),
																						bugs_reported_reopened_mean				   = mean(reopened_count, 			   	 na.rm=TRUE),
																						bugs_reported_assigned_mean				   = mean(assigned_count, 			     na.rm=TRUE),
																						bugs_reported_reassigned_mean	 			   = mean(reassigned_count, 			 na.rm=TRUE),
																						bugs_reported_target_milestone_change_mean    = mean(target_milestone_change_count, na.rm=TRUE),
																						bugs_reported_severity_change_mean 		   = mean(severity_change_count,  	     na.rm=TRUE),
																						bugs_reported_priority_change_mean 		   = mean(priority_change_count,  	     na.rm=TRUE));

																					

# Merge the "bugs_working_grouped_user_reporter_summary" table with the profiles table based on "reporter" and "userid"
setkey(bugs_working_grouped_user_reporter_summary, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_grouped_user_reporter_summary, by.x="userid", by.y="reporter", all.x=TRUE);


# For any NA entries in the count columns, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, bugs_reported_reopened_count 					= safe_ifelse(is.na(bugs_reported_reopened_count), 	 		     0, bugs_reported_reopened_count),
											 bugs_reported_reopened_at_least_once_count 	= safe_ifelse(is.na(bugs_reported_reopened_at_least_once_count),    0, bugs_reported_reopened_at_least_once_count),
											 bugs_reported_reopened_at_least_twice_count 	= safe_ifelse(is.na(bugs_reported_reopened_at_least_twice_count),   0, bugs_reported_reopened_at_least_twice_count),
											 bugs_reported_reopened_thrice_or_more_count 	= safe_ifelse(is.na(bugs_reported_reopened_thrice_or_more_count),   0, bugs_reported_reopened_thrice_or_more_count),
											 bugs_reported_assigned_count 					= safe_ifelse(is.na(bugs_reported_assigned_count), 	 		     0, bugs_reported_assigned_count),
											 bugs_reported_reassigned_count 				= safe_ifelse(is.na(bugs_reported_reassigned_count), 	 		     0, bugs_reported_reassigned_count),
											 bugs_reported_reassigned_at_least_once_count 	= safe_ifelse(is.na(bugs_reported_reassigned_at_least_once_count),  0, bugs_reported_reassigned_at_least_once_count),
											 bugs_reported_reassigned_at_least_twice_count = safe_ifelse(is.na(bugs_reported_reassigned_at_least_twice_count), 0, bugs_reported_reassigned_at_least_twice_count),
											 bugs_reported_reassigned_thrice_or_more_count = safe_ifelse(is.na(bugs_reported_reassigned_thrice_or_more_count), 0, bugs_reported_reassigned_thrice_or_more_count),
											 bugs_reported_target_milestone_change_count	= safe_ifelse(is.na(bugs_reported_target_milestone_change_count),   0, bugs_reported_target_milestone_change_count),
											 bugs_reported_severity_change_count 			= safe_ifelse(is.na(bugs_reported_severity_change_count), 	 	     0, bugs_reported_severity_change_count),
											 bugs_reported_priority_change_count 			= safe_ifelse(is.na(bugs_reported_priority_change_count), 	 	     0, bugs_reported_priority_change_count),
											 bugs_reported_reopened_mean 					= safe_ifelse(is.na(bugs_reported_reopened_mean), 	 		   	     0, bugs_reported_reopened_mean),
											 bugs_reported_assigned_mean 					= safe_ifelse(is.na(bugs_reported_assigned_mean), 	 		   	     0, bugs_reported_assigned_mean),
											 bugs_reported_reassigned_mean 				= safe_ifelse(is.na(bugs_reported_reassigned_mean), 	 		     0, bugs_reported_reassigned_mean),
											 bugs_reported_target_milestone_change_mean	= safe_ifelse(is.na(bugs_reported_target_milestone_change_mean),    0, bugs_reported_target_milestone_change_mean),
											 bugs_reported_severity_change_mean			= safe_ifelse(is.na(bugs_reported_severity_change_mean), 		     0, bugs_reported_severity_change_mean),
											 bugs_reported_priority_change_mean			= safe_ifelse(is.na(bugs_reported_priority_change_mean), 		     0, bugs_reported_priority_change_mean));



# PROFILES-BUGS_USER_ASSIGNED_TO_REOPENED_OR_ASSIGNED_OR_REASSIGNED_OR_TARGET_MILESTONE_CHANGE_OR_SEVERITY_CHANGE
# (Track how many times each user that was set as assigned_to a bug, had it reopened, assigned, or reassigned, or its target_milestone changed, or its severity changed)

# Use DPLYR's group_by() function to organize bugs_working table according to assigned userid
bugs_working_grouped_assigned_to <- group_by(bugs_working, assigned_to);

# Use DPLYR's summarize() function to sum reopened, assigned, and reassigned count across all bugs for each assigned_to user
bugs_working_grouped_user_assigned_to_summary <- summarize(bugs_working_grouped_assigned_to, bugs_assigned_to_reopened_count 				   = sum(reopened_count, 				 na.rm=TRUE),
																							 bugs_assigned_to_reopened_at_least_once_count	   = sum(reopened_count   >=1, 		   	 na.rm=TRUE),
																							 bugs_assigned_to_reopened_at_least_twice_count   = sum(reopened_count   >=2, 			 na.rm=TRUE),
																							 bugs_assigned_to_reopened_thrice_or_more_count   = sum(reopened_count   >=3, 			 na.rm=TRUE),
																							 bugs_assigned_to_assigned_count 				   = sum(assigned_count, 				 na.rm=TRUE),
																							 bugs_assigned_to_reassigned_count				   = sum(reassigned_count, 			     na.rm=TRUE),
																							 bugs_assigned_to_reassigned_at_least_once_count  = sum(reassigned_count >=1, 			 na.rm=TRUE),
																							 bugs_assigned_to_reassigned_at_least_twice_count = sum(reassigned_count >=2, 			 na.rm=TRUE),
																							 bugs_assigned_to_reassigned_thrice_or_more_count = sum(reassigned_count >=3, 			 na.rm=TRUE),
																							 bugs_assigned_to_target_milestone_change_count   = sum(target_milestone_change_count,  na.rm=TRUE),
																							 bugs_assigned_to_severity_change_count 		   = sum(severity_change_count,  		 na.rm=TRUE),
																							 bugs_assigned_to_priority_change_count 		   = sum(priority_change_count,  		 na.rm=TRUE),
																							 bugs_assigned_to_reopened_mean 				   = mean(reopened_count, 			     na.rm=TRUE),
																							 bugs_assigned_to_assigned_mean 				   = mean(assigned_count, 			     na.rm=TRUE),
																							 bugs_assigned_to_reassigned_mean 				   = mean(reassigned_count, 			 na.rm=TRUE),
																							 bugs_assigned_to_target_milestone_change_mean    = mean(target_milestone_change_count, na.rm=TRUE),
																							 bugs_assigned_to_severity_change_mean 		   = mean(severity_change_count,  	     na.rm=TRUE),
																							 bugs_assigned_to_priority_change_mean 		   = mean(priority_change_count,  	     na.rm=TRUE));
																							 																					 

# Merge the "bugs_working_grouped_user_assigned_to_summary" table with the profiles table based on "assigned_to" and "userid"
setkey(bugs_working_grouped_user_assigned_to_summary, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_grouped_user_assigned_to_summary, by.x="userid", by.y="assigned_to", all.x=TRUE);

# For any 0 entries in the assigned_count column, that's silly because at least the assigned_to user was assigned, so set to 1
# Note that here we're referring to "assigned_to" as not necessarily accepted assignment by the user in the assigned_to field, unlike with bugs assigned_count
profiles_working <- mutate(profiles_working, bugs_assigned_to_assigned_count = safe_ifelse(bugs_assigned_to_assigned_count == 0, 1, bugs_assigned_to_assigned_count));						  
											 
# NA entries in the count columns, that means 0, so mutate it accordingly.											 
profiles_working <- mutate(profiles_working, bugs_assigned_to_reopened_count				   = safe_ifelse(is.na(bugs_assigned_to_reopened_count), 			   	   0, bugs_assigned_to_reopened_count),
											 bugs_assigned_to_reopened_at_least_once_count    = safe_ifelse(is.na(bugs_assigned_to_reopened_at_least_once_count),    0, bugs_assigned_to_reopened_at_least_once_count),
											 bugs_assigned_to_reopened_at_least_twice_count   = safe_ifelse(is.na(bugs_assigned_to_reopened_at_least_twice_count),   0, bugs_assigned_to_reopened_at_least_twice_count),
											 bugs_assigned_to_reopened_thrice_or_more_count   = safe_ifelse(is.na(bugs_assigned_to_reopened_thrice_or_more_count),   0, bugs_assigned_to_reopened_thrice_or_more_count),
											 bugs_assigned_to_assigned_count				   = safe_ifelse(is.na(bugs_assigned_to_assigned_count), 	 		   	   0, bugs_assigned_to_assigned_count),
											 bugs_assigned_to_reassigned_count 			   = safe_ifelse(is.na(bugs_assigned_to_reassigned_count),   		   	   0, bugs_assigned_to_reassigned_count),
											 bugs_assigned_to_reassigned_at_least_once_count  = safe_ifelse(is.na(bugs_assigned_to_reassigned_at_least_once_count),  0, bugs_assigned_to_reassigned_at_least_once_count),
											 bugs_assigned_to_reassigned_at_least_twice_count = safe_ifelse(is.na(bugs_assigned_to_reassigned_at_least_twice_count), 0, bugs_assigned_to_reassigned_at_least_twice_count),
											 bugs_assigned_to_reassigned_thrice_or_more_count = safe_ifelse(is.na(bugs_assigned_to_reassigned_thrice_or_more_count), 0, bugs_assigned_to_reassigned_thrice_or_more_count),
											 bugs_assigned_to_target_milestone_change_count   = safe_ifelse(is.na(bugs_assigned_to_target_milestone_change_count),   0, bugs_assigned_to_target_milestone_change_count),
											 bugs_assigned_to_severity_change_count		   = safe_ifelse(is.na(bugs_assigned_to_severity_change_count), 		   0, bugs_assigned_to_severity_change_count),
											 bugs_assigned_to_priority_change_count		   = safe_ifelse(is.na(bugs_assigned_to_priority_change_count), 		   0, bugs_assigned_to_priority_change_count),
											 bugs_assigned_to_reopened_mean 				   = safe_ifelse(is.na(bugs_assigned_to_reopened_mean), 	 		       0, bugs_assigned_to_reopened_mean),
											 bugs_assigned_to_assigned_mean				   = safe_ifelse(is.na(bugs_assigned_to_assigned_mean), 	 		       0, bugs_assigned_to_assigned_mean),
											 bugs_assigned_to_reassigned_mean 			 	   = safe_ifelse(is.na(bugs_assigned_to_reassigned_mean), 			   	   0, bugs_assigned_to_reassigned_mean),
											 bugs_assigned_to_target_milestone_change_mean    = safe_ifelse(is.na(bugs_assigned_to_target_milestone_change_mean),    0, bugs_assigned_to_target_milestone_change_mean),
											 bugs_assigned_to_severity_change_mean		 	   = safe_ifelse(is.na(bugs_assigned_to_severity_change_mean), 		   0, bugs_assigned_to_severity_change_mean),
											 bugs_assigned_to_priority_change_mean		 	   = safe_ifelse(is.na(bugs_assigned_to_priority_change_mean), 		   0, bugs_assigned_to_priority_change_mean));


											 
# PROFILES-BUGS_USER_QA_CONTACT_REOPENED_OR_ASSIGNED_OR_REASSIGNED_OR_TARGET_MILESTONE_CHANGE_OR_SEVERITY_CHANGE
# (Track how many times each user that was set as qa_contact a bug, had it reopened, assigned, or reassigned, or its target_milestone changed, or its severity changed)

# Use DPLYR's group_by() function to organize bugs_working table according to qa_contact userid
bugs_working_grouped_qa_contact <- group_by(bugs_working, qa_contact);

# Use DPLYR's summarize() function to sum reopened, assigned, and reassigned count across all bugs for each qa_contact user
bugs_working_grouped_user_qa_contact_summary <- summarize(bugs_working_grouped_qa_contact,  bugs_qa_contact_reopened_count 			     = sum(reopened_count, 				   na.rm=TRUE),
																							bugs_qa_contact_reopened_at_least_once_count	 = sum(reopened_count   >=1, 		   na.rm=TRUE),
																							bugs_qa_contact_reopened_at_least_twice_count   = sum(reopened_count   >=2, 		   na.rm=TRUE),
																							bugs_qa_contact_reopened_thrice_or_more_count   = sum(reopened_count   >=3, 		   na.rm=TRUE),
																							bugs_qa_contact_assigned_count 			     = sum(assigned_count, 				   na.rm=TRUE),
																							bugs_qa_contact_reassigned_count 			     = sum(reassigned_count, 			   na.rm=TRUE),
																							bugs_qa_contact_reassigned_at_least_once_count  = sum(reassigned_count >=1, 		   na.rm=TRUE),
																							bugs_qa_contact_reassigned_at_least_twice_count = sum(reassigned_count >=2, 		   na.rm=TRUE),
																							bugs_qa_contact_reassigned_thrice_or_more_count = sum(reassigned_count >=3, 		   na.rm=TRUE),
																							bugs_qa_contact_target_milestone_change_count   = sum(target_milestone_change_count,  na.rm=TRUE),
																							bugs_qa_contact_severity_change_count		     = sum(severity_change_count,  		   na.rm=TRUE),
																							bugs_qa_contact_priority_change_count		     = sum(priority_change_count,  		   na.rm=TRUE),
																							bugs_qa_contact_reopened_mean 			   	     = mean(reopened_count, 			   na.rm=TRUE),
																							bugs_qa_contact_assigned_mean 			   	     = mean(assigned_count, 			   na.rm=TRUE),
																							bugs_qa_contact_reassigned_mean 			     = mean(reassigned_count, 			   na.rm=TRUE),
																							bugs_qa_contact_target_milestone_change_mean    = mean(target_milestone_change_count, na.rm=TRUE),
																							bugs_qa_contact_severity_change_mean		     = mean(severity_change_count,  	   na.rm=TRUE),
																							bugs_qa_contact_priority_change_mean		     = mean(priority_change_count,  	   na.rm=TRUE));
																							
																							
# Merge the "bugs_working_grouped_user_qa_contact_summary" table with the profiles table based on "qa_contact" and "userid"
setkey(bugs_working_grouped_user_qa_contact_summary, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_grouped_user_qa_contact_summary, by.x="userid", by.y="qa_contact", all.x=TRUE);


# For any NA (includes NaN) entries in the count columns, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, bugs_qa_contact_reopened_count 				  = safe_ifelse(is.na(bugs_qa_contact_reopened_count), 				 0, bugs_qa_contact_reopened_count),
											 bugs_qa_contact_reopened_at_least_once_count    = safe_ifelse(is.na(bugs_qa_contact_reopened_at_least_once_count),    0, bugs_qa_contact_reopened_at_least_once_count),
											 bugs_qa_contact_reopened_at_least_twice_count   = safe_ifelse(is.na(bugs_qa_contact_reopened_at_least_twice_count),   0, bugs_qa_contact_reopened_at_least_twice_count),
											 bugs_qa_contact_reopened_thrice_or_more_count   = safe_ifelse(is.na(bugs_qa_contact_reopened_thrice_or_more_count),   0, bugs_qa_contact_reopened_thrice_or_more_count),
											 bugs_qa_contact_assigned_count 				  = safe_ifelse(is.na(bugs_qa_contact_assigned_count), 				 0, bugs_qa_contact_assigned_count),
											 bugs_qa_contact_reassigned_count 				  = safe_ifelse(is.na(bugs_qa_contact_reassigned_count), 			 	 0, bugs_qa_contact_reassigned_count),
											 bugs_qa_contact_reassigned_at_least_once_count  = safe_ifelse(is.na(bugs_qa_contact_reassigned_at_least_once_count),  0, bugs_qa_contact_reassigned_at_least_once_count),
											 bugs_qa_contact_reassigned_at_least_twice_count = safe_ifelse(is.na(bugs_qa_contact_reassigned_at_least_twice_count), 0, bugs_qa_contact_reassigned_at_least_twice_count),
											 bugs_qa_contact_reassigned_thrice_or_more_count = safe_ifelse(is.na(bugs_qa_contact_reassigned_thrice_or_more_count), 0, bugs_qa_contact_reassigned_thrice_or_more_count),
											 bugs_qa_contact_target_milestone_change_count   = safe_ifelse(is.na(bugs_qa_contact_target_milestone_change_count),   0, bugs_qa_contact_target_milestone_change_count),
											 bugs_qa_contact_severity_change_count 		  = safe_ifelse(is.na(bugs_qa_contact_severity_change_count), 		 	 0, bugs_qa_contact_severity_change_count),
											 bugs_qa_contact_priority_change_count 		  = safe_ifelse(is.na(bugs_qa_contact_priority_change_count), 		 	 0, bugs_qa_contact_priority_change_count),
											 bugs_qa_contact_reopened_mean 				  = safe_ifelse(is.na(bugs_qa_contact_reopened_mean), 				 	 0, bugs_qa_contact_reopened_mean),
											 bugs_qa_contact_assigned_mean 				  = safe_ifelse(is.na(bugs_qa_contact_assigned_mean), 				 	 0, bugs_qa_contact_assigned_mean),
											 bugs_qa_contact_reassigned_mean 				  = safe_ifelse(is.na(bugs_qa_contact_reassigned_mean), 			 	 0, bugs_qa_contact_reassigned_mean),
											 bugs_qa_contact_target_milestone_change_mean    = safe_ifelse(is.na(bugs_qa_contact_target_milestone_change_mean),    0, bugs_qa_contact_target_milestone_change_mean),
											 bugs_qa_contact_severity_change_mean  		  = safe_ifelse(is.na(bugs_qa_contact_severity_change_mean),  		 	 0, bugs_qa_contact_severity_change_mean),
											 bugs_qa_contact_priority_change_mean  		  = safe_ifelse(is.na(bugs_qa_contact_priority_change_mean),  		 	 0, bugs_qa_contact_priority_change_mean));




# PROFILES-ATTACHMENTS_USER_ALL_TYPES
# (Track how many attachments each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_all_grouped_submitter <- group_by(attachments_base, submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_all_grouped_submitter_summary <- summarize(attachments_base_all_grouped_submitter, attachments_all_types_count = n());

# Merge the "attachments_base_all_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_all_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_all_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_all_types_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_all_types_count = safe_ifelse(is.na(attachments_all_types_count), 0, attachments_all_types_count));


# PROFILES-ATTACHMENTS_USER_PATCH
# (Track how many attachments that were patches each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_patch_grouped_submitter <- group_by(filter(attachments_base, ispatch==TRUE), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_patch_grouped_submitter_summary <- summarize(attachments_base_patch_grouped_submitter, attachments_patch_count = n());

# Merge the "attachments_base_patch_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_patch_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_patch_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_patch_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_patch_count = safe_ifelse(is.na(attachments_patch_count), 0, attachments_patch_count));


# PROFILES-ATTACHMENTS_USER_APPLICATION
# (Track how many attachments that were applications each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_application_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% application_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_application_grouped_submitter_summary <- summarize(attachments_base_application_grouped_submitter, attachments_application_count = n());

# Merge the "attachments_base_application_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_application_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_application_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_application_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_application_count = safe_ifelse(is.na(attachments_application_count), 0, attachments_application_count));

# PROFILES-ATTACHMENTS_USER_AUDIO
# (Track how many attachments that were audio each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_audio_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% audio_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_audio_grouped_submitter_summary <- summarize(attachments_base_audio_grouped_submitter, attachments_audio_count = n());

# Merge the "attachments_base_audio_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_audio_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_audio_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_audio_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_audio_count = safe_ifelse(is.na(attachments_audio_count), 0, attachments_audio_count));

# PROFILES-ATTACHMENTS_USER_IMAGE
# (Track how many attachments that were images each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_image_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% image_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_image_grouped_submitter_summary <- summarize(attachments_base_image_grouped_submitter, attachments_image_count = n());

# Merge the "attachments_base_image_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_image_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_image_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_image_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_image_count = safe_ifelse(is.na(attachments_image_count), 0, attachments_image_count));


# PROFILES-ATTACHMENTS_USER_MESSAGE
# (Track how many attachments that were messages each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_message_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% message_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_message_grouped_submitter_summary <- summarize(attachments_base_message_grouped_submitter, attachments_message_count = n());

# Merge the "attachments_base_message_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_message_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_message_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_message_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_message_count = safe_ifelse(is.na(attachments_message_count), 0, attachments_message_count));


# PROFILES-ATTACHMENTS_USER_MODEL
# (Track how many attachments that were models each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_model_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% model_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_model_grouped_submitter_summary <- summarize(attachments_base_model_grouped_submitter, attachments_model_count = n());

# Merge the "attachments_base_model_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_model_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_model_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_model_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_model_count = safe_ifelse(is.na(attachments_model_count), 0, attachments_model_count));


# PROFILES-ATTACHMENTS_USER_MULTIPART
# (Track how many attachments that were multipart each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_multipart_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% multipart_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_multipart_grouped_submitter_summary <- summarize(attachments_base_multipart_grouped_submitter, attachments_multipart_count = n());

# Merge the "attachments_base_multipart_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_multipart_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_multipart_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_multipart_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_multipart_count = safe_ifelse(is.na(attachments_multipart_count), 0, attachments_multipart_count));


# PROFILES-ATTACHMENTS_USER_TEXT
# (Track how many attachments that were text each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_text_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% text_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_text_grouped_submitter_summary <- summarize(attachments_base_text_grouped_submitter, attachments_text_count = n());

# Merge the "attachments_base_text_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_text_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_text_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_text_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_text_count = safe_ifelse(is.na(attachments_text_count), 0, attachments_text_count));


# PROFILES-ATTACHMENTS_USER_VIDEO
# (Track how many attachments that were video each user has submitted)

# Use DPLYR's group_by() function to organize the attachments_base table according to the "submitter_id" who submitted the attachment
attachments_base_video_grouped_submitter <- group_by(filter(attachments_base, mimetype %in% video_mimetypes$Template), submitter_id);

# Use DPLYR's summarize() function to count attachment submission activity according for each user
attachments_base_video_grouped_submitter_summary <- summarize(attachments_base_video_grouped_submitter, attachments_video_count = n());

# Merge the "attachments_base_video_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_video_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_video_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_video_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_video_count = safe_ifelse(is.na(attachments_video_count), 0, attachments_video_count));


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
attachments_base_unknown_grouped_submitter_summary <- summarize(attachments_base_unknown_grouped_submitter, attachments_unknown_count = n());

# Merge the "attachments_base_unknown_grouped_submitter_summary" table with the profiles table according to "submitter_id" and "userid"
setkey(attachments_base_unknown_grouped_submitter_summary, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_base_unknown_grouped_submitter_summary, by.x="userid", by.y="submitter_id", all.x=TRUE);

# For any NA entries in the "attachments_unknown_count" column, that means 0, so mutate it accordingly.
profiles_working <- mutate(profiles_working, attachments_unknown_count = safe_ifelse(is.na(attachments_unknown_count), 0, attachments_unknown_count));


# PROFILES-BUGS-ATTACHMENTS_USER_KNOWLEDGE_ACTORS
# I operationalize user/org knowledge actors as users/orgs who have done at least one of: report a bug, be assigned_to a bug, be qa_contact for a bug, submit an attachment of any type for a bug
profiles_working <- mutate(profiles_working, knowledge_actor = safe_ifelse((bugs_reported_count  			> 	0 |
																				bugs_assigned_to_count  			>	0 |
																				bugs_qa_contact_count		  			>	0 |
																				attachments_all_types_count	>	0 ), TRUE, FALSE)); 


# PROFILES-GROUPS_USER_CORE_ACTORS
# I operationalize user/org core actors as users/orgs who have one or more group membership
# As of the end of 2012, that includes 2478 core profiles out of 109765 total profiles, or roughly 2.25%, which seems a reasonable subset to define as "core"
# Since we set the group membership flags in the profiles earlier, all we have to do is look for a true entry to set the "user" core actor field
# At present, there are 24 group flags (12 for membership and 12 for bless ability for each group)
profiles_working <- mutate(profiles_working, core_actor = safe_ifelse((can_edit_parameters 			 == TRUE |
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
profiles_working <- mutate(profiles_working, peripheral_actor = safe_ifelse((knowledge_actor	== FALSE &
																				  core_actor		== FALSE), TRUE, FALSE));
																			 

# BUGS-CC_KNOWLEDGE_ACTORS
# (Count of knowledge actors who are following bug)

# Create a list of userids that are knowledge actors with defined organizations (not full profile list)
profiles_knowledge_actors <- filter(profiles_working, knowledge_actor==TRUE);
knowledge_actors <- select(profiles_knowledge_actors, userid);

# Make it a vector list instead of data.table
knowledge_actors <- knowledge_actors$userid;

# Filter the cc_base database to knowledge actors who have defined organizations
cc_knowledge_actors <- filter(cc_base, who %in% knowledge_actors);

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
profiles_core_actors <- filter(profiles_working, core_actor==TRUE);
core_actors <- select(profiles_core_actors, userid);

# Make it a vector list instead of data.table
core_actors <- core_actors$userid;

# Filter the cc_base database to core actors who have defined organizations
cc_core_actors <- filter(cc_base, who %in% core_actors);

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
profiles_peripheral_actors <- filter(profiles_working, peripheral_actor==TRUE);
peripheral_actors <- select(profiles_peripheral_actors, userid);

# Make it a vector list instead of data.table
peripheral_actors <- peripheral_actors$userid;

# Filter the cc_base database to peripheral actors who have defined organizations
cc_peripheral_actors <- filter(cc_base, who %in% peripheral_actors);

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
activity_knowledge_actors <- filter(activity_base, who %in% knowledge_actors);

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
activity_core_actors <- filter(activity_base, who %in% core_actors);

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
activity_peripheral_actors <- filter(activity_base, who %in% peripheral_actors);

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
bugs_working <- mutate(bugs_working, reporter_knowledge_actor 	= safe_ifelse(reporter 		%in% knowledge_actors, 	TRUE, FALSE),
									 reporter_core_actor		= safe_ifelse(reporter 		%in% core_actors, 			TRUE, FALSE),
									 reporter_peripheral_actor	= safe_ifelse(reporter 		%in% peripheral_actors, 	TRUE, FALSE),
									 assigned_knowledge_actor	= safe_ifelse(assigned_to 	%in% knowledge_actors, 	TRUE, FALSE),
									 assigned_core_actor		= safe_ifelse(assigned_to 	%in% core_actors, 			TRUE, FALSE),
									 assigned_peripheral_actor	= safe_ifelse(assigned_to 	%in% peripheral_actors, 	TRUE, FALSE),
									 qa_knowledge_actor			= safe_ifelse(qa_contact	%in% knowledge_actors, 	TRUE, FALSE),
									 qa_core_actor				= safe_ifelse(qa_contact	%in% core_actors, 			TRUE, FALSE),
									 qa_peripheral_actor		= safe_ifelse(qa_contact	%in% peripheral_actors, 	TRUE, FALSE));

									 
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
votes_knowledge_actors <- filter(votes_base, who %in% knowledge_actors);

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
votes_core_actors <- filter(votes_base, who %in% core_actors);

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
votes_peripheral_actors <- filter(votes_base, who %in% peripheral_actors);

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
attachments_knowledge_actors <- filter(attachments_base, submitter_id %in% knowledge_actors);

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
attachments_core_actors <- filter(attachments_base, submitter_id %in% core_actors);

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
attachments_peripheral_actors <- filter(attachments_base, submitter_id %in% peripheral_actors);

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
longdescs_knowledge_actors <- filter(longdescs_base, who %in% knowledge_actors);

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
bugs_working <- mutate(bugs_working, comments_knowledge_actors_count = safe_ifelse( is.na(comments_knowledge_actors_count), 0, safe_ifelse(reporter %in% knowledge_actors, comments_knowledge_actors_count - 1, comments_knowledge_actors_count)));


# BUGS-LONGDESCS_COMMENTS_CORE_ACTORS

# Filter longdescs_base to just core actors
longdescs_core_actors <- filter(longdescs_base, who %in% core_actors);

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
bugs_working <- mutate(bugs_working, comments_core_actors_count = safe_ifelse(is.na(comments_core_actors_count), 0, safe_ifelse(reporter %in% core_actors, comments_core_actors_count - 1, comments_core_actors_count)));


# BUGS-LONGDESCS_COMMENTS_PERIPHERAL_ACTORS

# Filter longdescs_base to just peripheral actors
longdescs_peripheral_actors <- filter(longdescs_base, who %in% peripheral_actors);

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


# BUGS-LONGDESCS_COMMENTS_AUTOMATIC_AND_MANUAL

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
bugs_working_duplicates_grouped_user_reporter_summary <- summarize(bugs_working_duplicates_grouped_user_reporter, bugs_reported_is_duplicate_count = n());

# Merge the bugs_working_duplicates_grouped_user_reporter_summary and profiles_working tables based on "reporter" and "userid" to add new count column
setkey(bugs_working_duplicates_grouped_user_reporter_summary, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_duplicates_grouped_user_reporter_summary, by.x="userid", by.y="reporter", all.x=TRUE);

# For any NA entries, that means that user did not report any bugs that were duplicates, so set it to 0.
profiles_working <- mutate(profiles_working, bugs_reported_is_duplicate_count = safe_ifelse(is.na(bugs_reported_is_duplicate_count), 0, bugs_reported_is_duplicate_count));
							 
									 
# PROFILES-DUPLICATES_USER_REPORTED_DUPLICATED_BY

# Count the number of bugs each user reported that were duplicated BY at least one other bug
# We only want to count the number of bugs that were duplicated BY other bugs, so filter for duplicates_count > 0
bugs_working_duplicated <- filter(bugs_working, duplicates_count > 0);

# Group according to bug reporter's userid (reporter)
bugs_working_duplicated_grouped_user_reporter <- group_by(bugs_working, reporter);

# Use summarize() function to count number of bugs that were duplicated at least once
bugs_working_duplicated_grouped_user_reporter_summary <- summarize(bugs_working_duplicated_grouped_user_reporter, bugs_reported_was_duplicated_count = n());

# Merge the bugs_working_duplicated_grouped_user_reporter_summary and profiles_working tables based on "reporter" and "userid" to add new count column
setkey(bugs_working_duplicated_grouped_user_reporter_summary, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_duplicated_grouped_user_reporter_summary, by.x="userid", by.y="reporter", all.x=TRUE);

# For any NA entries, that means that user did not report any bugs that were duplicated BY at least one other bug, so set it to 0.
profiles_working <- mutate(profiles_working, bugs_reported_was_duplicated_count = safe_ifelse(is.na(bugs_reported_was_duplicated_count), 0, bugs_reported_was_duplicated_count));

									 
# PROFILES-DUPLICATES_USER_REPORTED_DUPLICATED_BY_TOTAL

# Count the total number of times any of the bugs reported by each user was later duplicated by another bug
# This count is distinct from the previous one in that each bug reported could be duplicated more than once, which is captured by this total count

# Bugs_working already has a duplicates_count variable, created earlier, so we can simply group by reporter and sum()
# Group according to bug reporter's userid (reporter)
bugs_working_user_reporter_grouped <- group_by(bugs_working, reporter);

# Use summarize() function to sum the duplicates_count across all bugs for each user reporter
bugs_working_user_reporter_grouped_summary <- summarize(bugs_working_user_reporter_grouped, bugs_reported_all_duplications_count = sum(duplicates_count));

# Merge the bugs_working_user_reporter_grouped_summary and profiles_working tables based on "reporter" and "userid" to add new count column
setkey(bugs_working_user_reporter_grouped_summary, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_user_reporter_grouped_summary, by.x="userid", by.y="reporter", all.x=TRUE);

# For any NA entries, that means that user did not report any bugs that were duplicated BY at least one other bug, so set it to 0.
profiles_working <- mutate(profiles_working, bugs_reported_all_duplications_count = safe_ifelse(is.na(bugs_reported_all_duplications_count), 0, bugs_reported_all_duplications_count));


# PROFILES-FLAGS_USER_SET
# (Count how many flags were set by each user)

# There are too many types of flags to count the different types
# Further, many of the types are not clearly defined, redundant, etc.
# So we'll just get an overall count.
# Note that the "status" field in the flags table means that it's possible that we'll double count the same getting set and then removed
# However, we can treat "setting a flag" as one count and "removing a flag" as another count.  So this variable
# should better be understood as treating "postiive" and "negative" flags separately.  There's really no other clena way given the DB format

# Group the flags_base table by setter_id to prepare it for summarize()
# Since we're updated only the profiles_working table, we don't need flags_base
flags_working_grouped_setter_id <- group_by(flags_base, setter_id);

# Use summarize() to count the number of entries for each setter_id
flags_working_grouped_setter_id_summary <- summarize(flags_working_grouped_setter_id, flags_set_count = n());

# Merge the flags_working_grouped_setter_id_summary and profiles_working tables based on setter_id and userid to add the count of flags set by each user
setkey(flags_working_grouped_setter_id_summary, setter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, flags_working_grouped_setter_id_summary, by.x="userid", by.y="setter_id", all.x=TRUE);

# Any NA values means that the user set no flags, so replace with 0
profiles_working <- mutate(profiles_working, flags_set_count = safe_ifelse(is.na(flags_set_count), 0, flags_set_count));				


# PROFILES-WATCHING_USER_ALL_ACTORS
# (Track how many other users each user is watching)

# Use DPLYR's group_by() function to organize the watch_base table according to the "watcher"
watch_base_grouped_watcher <- group_by(watch_base, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_summary <- summarize(watch_base_grouped_watcher, watching_all_actors_count = n());

# Merge the "watch_base_grouped_watcher_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "watching_all_actors_count" column, that means the user is watching nobody, so set it to zero
profiles_working <- mutate(profiles_working, watching_all_actors_count = safe_ifelse(is.na(watching_all_actors_count), 0, watching_all_actors_count));


# PROFILES-WATCHING_USER_ALL_ORGS
# (Track how many other organizations each user is watching)

# Since we only care about organizations, we want to filter out webmail domains for this count
watch_base_is_org_watched_domain <- filter(watch_base, is_org_watched_domain==TRUE);

# Select only entries with distinct pairs of "watcher" users and "watched_domains"
watch_base_distinct_watcher_watched_domains <- distinct(select(watch_base_is_org_watched_domain, watcher, watched_domain));

# Use DPLYR's group_by() function to organize the watch_base_distinct_watcher_watched_domains table according to the "watcher"
watch_base_grouped_watcher_watched_domain <- group_by(watch_base_distinct_watcher_watched_domains, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_domain_summary <- summarize(watch_base_grouped_watcher_watched_domain, watching_all_orgs_count = n());

# Merge the "watch_base_grouped_watcher_watched_domain_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_domain_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_domain_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "watching_all_orgs_count" column, that means the user isn't watching any organizations, so set it to zero
profiles_working <- mutate(profiles_working, watching_all_orgs_count = safe_ifelse(is.na(watching_all_orgs_count), 0, watching_all_orgs_count));


# PROFILES-WATCHING_USER_KNOWLEDGE_ACTORS
# (Track how many knowledge actor users each user is watching)

# Filter watch_base to "watched" knowledge actors
watch_base_watched_knowledge_actors <- filter(watch_base, watched %in% knowledge_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the "watcher"
watch_base_grouped_watcher_watched_knowledge_actors <- group_by(watch_base_watched_knowledge_actors, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_knowledge_actors_summary <- summarize(watch_base_grouped_watcher_watched_knowledge_actors, watching_knowledge_actors_count = n());

# Merge the "watch_base_grouped_watcher_watched_knowledge_actors_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_knowledge_actors_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_knowledge_actors_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "watching_knowledge_actors_count" column, that means the user is not watching any knowledge actors, so set it to zero
profiles_working <- mutate(profiles_working, watching_knowledge_actors_count = safe_ifelse(is.na(watching_knowledge_actors_count), 0, watching_knowledge_actors_count));


# PROFILES-WATCHING_USER_CORE_ACTORS
# (Track how many core actor users each user is watching)

# Filter watch_base to "watched" core actors
watch_base_watched_core_actors <- filter(watch_base, watched %in% core_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the "watcher"
watch_base_grouped_watcher_watched_core_actors <- group_by(watch_base_watched_core_actors, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_core_actors_summary <- summarize(watch_base_grouped_watcher_watched_core_actors, watching_core_actors_count = n());

# Merge the "watch_base_grouped_watcher_watched_core_actors_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_core_actors_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_core_actors_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "watching_core_actors_count" column, that means the user is not watching any core actors, so set it to zero
profiles_working <- mutate(profiles_working, watching_core_actors_count = safe_ifelse(is.na(watching_core_actors_count), 0, watching_core_actors_count));


# PROFILES-WATCHING_USER_PERIPHERAL_ACTORS
# (Track how many peripheral actor users each user is watching)

# Filter watch_base to "watched" peripheral actors
watch_base_watched_peripheral_actors <- filter(watch_base, watched %in% peripheral_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the "watcher"
watch_base_grouped_watcher_watched_peripheral_actors <- group_by(watch_base_watched_peripheral_actors, watcher);

# Use DPLYR's summarize() function to count watching entries for each user
watch_base_grouped_watcher_watched_peripheral_actors_summary <- summarize(watch_base_grouped_watcher_watched_peripheral_actors, watching_peripheral_actors_count = n());

# Merge the "watch_base_grouped_watcher_watched_peripheral_actors_summary" table with the profiles_working table according to "watcher" and "userid"
setkey(watch_base_grouped_watcher_watched_peripheral_actors_summary, watcher);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watcher_watched_peripheral_actors_summary, by.x="userid", by.y="watcher", all.x=TRUE);

# For any NA entries in the "watching_peripheral_actors_count" column, that means the user is not watching any peripheral actors, so set it to zero
profiles_working <- mutate(profiles_working, watching_peripheral_actors_count = safe_ifelse(is.na(watching_peripheral_actors_count), 0, watching_peripheral_actors_count));


# PROFILES-WATCHED_BY_USER_ALL_ACTORS
# (Track how many other users each user is watched by)

# Use DPLYR's group_by() function to organize the watch_base table according to the person "watched"
watch_base_grouped_watched <- group_by(watch_base, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_summary <- summarize(watch_base_grouped_watched, watched_by_all_actors_count = n());

# Merge the "watch_base_grouped_watched_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "watched_by_all_actors_count" column, that means the user not watched by anyone, so set it to zero
profiles_working <- mutate(profiles_working, watched_by_all_actors_count = safe_ifelse(is.na(watched_by_all_actors_count), 0, watched_by_all_actors_count));


# PROFILES-WATCHED_BY_USER_ALL_ORGS
# (Track how many other organizations each user is watched by)

# Since we only care about organizations, we want to filter out webmail domains for this count
watch_base_is_org_watcher_domain <- filter(watch_base, is_org_watcher_domain==TRUE);

# Select only entries with distinct pairs of "watched" users and "watcher_domains"
watch_base_distinct_watched_watcher_domains <- distinct(select(watch_base_is_org_watcher_domain, watched, watcher_domain));

# Use DPLYR's group_by() function to organize the watch_base_distinct_watched_watcher_domains table according to the person "watched"
watch_base_grouped_watched_watcher_domain <- group_by(watch_base_distinct_watched_watcher_domains, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_watcher_domain_summary <- summarize(watch_base_grouped_watched_watcher_domain, watched_by_all_orgs_count = n());

# Merge the "watch_base_grouped_watched_watcher_domain_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_watcher_domain_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_watcher_domain_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "watched_by_all_orgs_count" column, that means the user isn't watched by any domains, so set it to zero
profiles_working <- mutate(profiles_working, watched_by_all_orgs_count = safe_ifelse(is.na(watched_by_all_orgs_count), 0, watched_by_all_orgs_count));


# PROFILES-WATCHED_BY_USER_KNOWLEDGE_ACTORS
# (Track how many knowledge actor users each user is watched by)

# Filter watch_base to "watcher" knowledge actors
watch_base_watcher_knowledge_actors <- filter(watch_base, watcher %in% knowledge_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the person "watched"
watch_base_grouped_watched_watcher_knowledge_actors <- group_by(watch_base_watcher_knowledge_actors, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_watcher_knowledge_actors_summary <- summarize(watch_base_grouped_watched_watcher_knowledge_actors, watched_by_knowledge_actors_count = n());

# Merge the "watch_base_grouped_watched_watcher_knowledge_actors_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_watcher_knowledge_actors_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_watcher_knowledge_actors_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "watched_by_knowledge_actors_count" column, that means the user is not watched by any knowledge actors, so set it to zero
profiles_working <- mutate(profiles_working, watched_by_knowledge_actors_count = safe_ifelse(is.na(watched_by_knowledge_actors_count), 0, watched_by_knowledge_actors_count));


# PROFILES-WATCHED_BY_USER_CORE_ACTORS
# (Track how many core actor users each user is watched by)

# Filter watch_base to "watcher" core actors
watch_base_watcher_core_actors <- filter(watch_base, watcher %in% core_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the person "watched"
watch_base_grouped_watched_watcher_core_actors <- group_by(watch_base_watcher_core_actors, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_watcher_core_actors_summary <- summarize(watch_base_grouped_watched_watcher_core_actors, watched_by_core_actors_count = n());

# Merge the "watch_base_grouped_watched_watcher_core_actors_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_watcher_core_actors_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_watcher_core_actors_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "watched_by_core_actors_count" column, that means the user is not watched by any core actors, so set it to zero
profiles_working <- mutate(profiles_working, watched_by_core_actors_count = safe_ifelse(is.na(watched_by_core_actors_count), 0, watched_by_core_actors_count));


# PROFILES-WATCHED_BY_USER_PERIPHERAL_ACTORS
# (Track how many peripheral actor users each user is watched by)

# Filter watch_base to "watcher" peripheral actors
watch_base_watcher_peripheral_actors <- filter(watch_base, watcher %in% peripheral_actors);

# Use DPLYR's group_by() function to organize the watch_base table according to the person "watched"
watch_base_grouped_watched_watcher_peripheral_actors <- group_by(watch_base_watcher_peripheral_actors, watched);

# Use DPLYR's summarize() function to count watcher entries for each user
watch_base_grouped_watched_watcher_peripheral_actors_summary <- summarize(watch_base_grouped_watched_watcher_peripheral_actors, watched_by_peripheral_actors_count = n());

# Merge the "watch_base_grouped_watched_watcher_peripheral_actors_summary" table with the profiles_working table according to "watched" and "userid"
setkey(watch_base_grouped_watched_watcher_peripheral_actors_summary, watched);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, watch_base_grouped_watched_watcher_peripheral_actors_summary, by.x="userid", by.y="watched", all.x=TRUE);

# For any NA entries in the "watched_by_peripheral_actors_count" column, that means the user is not watched by any peripheral actors, so set it to zero
profiles_working <- mutate(profiles_working, watched_by_peripheral_actors_count = safe_ifelse(is.na(watched_by_peripheral_actors_count), 0, watched_by_peripheral_actors_count));


# PROFILES-BUGS_USER_REPORTED_SEVERITY
# (Count the bugs reported by each user for each severity level)

# Select just the fields in the bugs_working table that we want to look at, namely reporter and bug_severity
bugs_working_reporter_severity <- select(bugs_base, reporter, bug_severity);

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user reported a bug with each of the 7 severity types
bugs_working_reporter_severity_recast <- dcast(bugs_working_reporter_severity, reporter ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length);

# Transmute all of the columns to the set the desired names and check for NA's
bugs_working_reporter_severity_recast <- transmute(bugs_working_reporter_severity_recast,   reporter								= reporter,
																							bugs_reported_enhancement_count 	= if (exists('enhancement',	where = bugs_working_reporter_severity_recast)) enhancement else 0,
																							bugs_reported_trivial_count 		= if (exists('trivial',		where = bugs_working_reporter_severity_recast)) trivial else 0,
																							bugs_reported_minor_count			= if (exists('minor',		where = bugs_working_reporter_severity_recast)) minor else 0,
																							bugs_reported_normal_count 		= if (exists('normal',		where = bugs_working_reporter_severity_recast)) normal else 0,
																							bugs_reported_major_count 			= if (exists('major',		where = bugs_working_reporter_severity_recast)) major else 0,
																							bugs_reported_critical_count 		= if (exists('critical',	where = bugs_working_reporter_severity_recast)) critical else 0,
																							bugs_reported_blocker_count 		= if (exists('blocker',		where = bugs_working_reporter_severity_recast)) blocker else 0);
																						
# Merge the bugs_working_reporter_severity_recast and profiles_working tables based on reporter & userid to add the severity types count columns
setkey(bugs_working_reporter_severity_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_severity_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, bugs_reported_enhancement_count 	= safe_ifelse(is.na(bugs_reported_enhancement_count), 	0, bugs_reported_enhancement_count), 
                                             bugs_reported_trivial_count 		= safe_ifelse(is.na(bugs_reported_trivial_count), 		0, bugs_reported_trivial_count),
                                             bugs_reported_minor_count			= safe_ifelse(is.na(bugs_reported_minor_count), 		0, bugs_reported_minor_count),
                                             bugs_reported_normal_count 		= safe_ifelse(is.na(bugs_reported_normal_count), 		0, bugs_reported_normal_count),
                                             bugs_reported_major_count 		= safe_ifelse(is.na(bugs_reported_major_count), 		0, bugs_reported_major_count),
                                             bugs_reported_critical_count 		= safe_ifelse(is.na(bugs_reported_critical_count), 	0, bugs_reported_critical_count),
                                             bugs_reported_blocker_count 		= safe_ifelse(is.na(bugs_reported_blocker_count), 		0, bugs_reported_blocker_count));

# PROFILES-BUGS_USER_ASSIGNED_TO_SEVERITY
# (Count the bugs assigned_to each user for each severity level)

# Select just the fields in the bugs_working table that we want to look at, namely assigned_to and bug_severity
bugs_working_assigned_to_severity <- select(bugs_base, assigned_to, bug_severity);

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user was assigned_to a bug with each of the 7 severity types
bugs_working_assigned_to_severity_recast <- dcast(bugs_working_assigned_to_severity, assigned_to ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length);

# Transmute all of the columns to the desired values
bugs_working_assigned_to_severity_recast <- transmute(bugs_working_assigned_to_severity_recast, assigned_to 							= assigned_to,
																								bugs_assigned_to_enhancement_count = if (exists('enhancement',	where = bugs_working_assigned_to_severity_recast)) enhancement else 0,
																								bugs_assigned_to_trivial_count 	= if (exists('trivial',		where = bugs_working_assigned_to_severity_recast)) trivial else 0,
																								bugs_assigned_to_minor_count		= if (exists('minor',		where = bugs_working_assigned_to_severity_recast)) minor else 0,
																								bugs_assigned_to_normal_count 		= if (exists('normal',		where = bugs_working_assigned_to_severity_recast)) normal else 0,
																								bugs_assigned_to_major_count 		= if (exists('major',		where = bugs_working_assigned_to_severity_recast)) major else 0,
																								bugs_assigned_to_critical_count 	= if (exists('critical',	where = bugs_working_assigned_to_severity_recast)) critical else 0,
																								bugs_assigned_to_blocker_count 	= if (exists('blocker',		where = bugs_working_assigned_to_severity_recast)) blocker else 0);
																						
# Merge the bugs_working_assigned_to_severity_recast and profiles_working tables based on assigned_to & userid to add the severity types count columns
setkey(bugs_working_assigned_to_severity_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_severity_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user was not assigned any bugs, so change to 0
profiles_working <- mutate(profiles_working, bugs_assigned_to_enhancement_count 	= safe_ifelse(is.na(bugs_assigned_to_enhancement_count), 	0, bugs_assigned_to_enhancement_count), 
                                             bugs_assigned_to_trivial_count 		= safe_ifelse(is.na(bugs_assigned_to_trivial_count), 		0, bugs_assigned_to_trivial_count),
                                             bugs_assigned_to_minor_count			= safe_ifelse(is.na(bugs_assigned_to_minor_count), 		0, bugs_assigned_to_minor_count),
                                             bugs_assigned_to_normal_count 		= safe_ifelse(is.na(bugs_assigned_to_normal_count), 		0, bugs_assigned_to_normal_count),
                                             bugs_assigned_to_major_count 			= safe_ifelse(is.na(bugs_assigned_to_major_count), 		0, bugs_assigned_to_major_count),
                                             bugs_assigned_to_critical_count 		= safe_ifelse(is.na(bugs_assigned_to_critical_count), 		0, bugs_assigned_to_critical_count),
                                             bugs_assigned_to_blocker_count 		= safe_ifelse(is.na(bugs_assigned_to_blocker_count), 		0, bugs_assigned_to_blocker_count));


# PROFILES-BUGS_USER_QA_CONTACT_SEVERITY
# (Count the bugs for which each user is qa_contact for each severity level)

# Select just the fields in the bugs_working table that we want to look at, namely qa_contact and bug_severity
bugs_working_qa_contact_severity <- select(bugs_base, qa_contact, bug_severity);

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user was qa_contact for a bug with each of the 7 severity types
bugs_working_qa_contact_severity_recast <- dcast(bugs_working_qa_contact_severity, qa_contact ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length);

# Transmute all of the columns to the desired values
bugs_working_qa_contact_severity_recast <- transmute(bugs_working_qa_contact_severity_recast,  	qa_contact 								= qa_contact,
																								bugs_qa_contact_enhancement_count 	= if (exists('enhancement',	where = bugs_working_qa_contact_severity_recast)) enhancement else 0,
																								bugs_qa_contact_trivial_count 		= if (exists('trivial',		where = bugs_working_qa_contact_severity_recast)) trivial else 0,
																								bugs_qa_contact_minor_count		= if (exists('minor',		where = bugs_working_qa_contact_severity_recast)) minor else 0,
																								bugs_qa_contact_normal_count 		= if (exists('normal',		where = bugs_working_qa_contact_severity_recast)) normal else 0,
																								bugs_qa_contact_major_count 		= if (exists('major',		where = bugs_working_qa_contact_severity_recast)) major else 0,
																								bugs_qa_contact_critical_count 	= if (exists('critical',	where = bugs_working_qa_contact_severity_recast)) critical else 0,
																								bugs_qa_contact_blocker_count 		= if (exists('blocker',		where = bugs_working_qa_contact_severity_recast)) blocker else 0);
																						
# Merge the bugs_working_qa_contact_severity_recast and profiles_working tables based on qa_contact & userid to add the severity types count columns
setkey(bugs_working_qa_contact_severity_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_severity_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user was not set as qa_contact for any bugs, so change to 0
profiles_working <- mutate(profiles_working, bugs_qa_contact_enhancement_count 	= safe_ifelse(is.na(bugs_qa_contact_enhancement_count), 	0, bugs_qa_contact_enhancement_count), 
                                             bugs_qa_contact_trivial_count 		= safe_ifelse(is.na(bugs_qa_contact_trivial_count), 		0, bugs_qa_contact_trivial_count),
                                             bugs_qa_contact_minor_count			= safe_ifelse(is.na(bugs_qa_contact_minor_count), 			0, bugs_qa_contact_minor_count),
                                             bugs_qa_contact_normal_count 			= safe_ifelse(is.na(bugs_qa_contact_normal_count), 		0, bugs_qa_contact_normal_count),
                                             bugs_qa_contact_major_count 			= safe_ifelse(is.na(bugs_qa_contact_major_count), 			0, bugs_qa_contact_major_count),
                                             bugs_qa_contact_critical_count 		= safe_ifelse(is.na(bugs_qa_contact_critical_count), 		0, bugs_qa_contact_critical_count),
                                             bugs_qa_contact_blocker_count 		= safe_ifelse(is.na(bugs_qa_contact_blocker_count), 		0, bugs_qa_contact_blocker_count));


# PROFILES-BUGS_USER_REPORTED_OR_ASSINGED_TO_OR_QA_CONTACT_PRIORITY
# (Count the bugs reported/assigned_to/qa_contact set by each user for each priority level)

# Select just the fields in the bugs_working table that we want to look at, namely reporter and priority
bugs_working_priority <- select(bugs_base, reporter, assigned_to, qa_contact, priority);

# Append text to the priority levels to make them clearer
bugs_working_priority <- mutate(bugs_working_priority, reported_priority 		= paste0("bugs_reported_priority_", 	priority, "_count"),
													   assigned_to_priority 	= paste0("bugs_assigned_to_priority_", priority, "_count"),
													   qa_contact_priority 		= paste0("bugs_qa_contact_priority_", 	priority, "_count"));

# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with the count of each time a user reported/was assigned_to/set as qa_contact for a bug with each of the 6 priority types
bugs_working_reporter_priority_recast 	 <- dcast(bugs_working_priority, reporter 	 ~ reported_priority, 	 drop=FALSE, value.var="reported_priority",    fun=length);
bugs_working_assigned_to_priority_recast <- dcast(bugs_working_priority, assigned_to ~ assigned_to_priority, drop=FALSE, value.var="assigned_to_priority", fun=length);
bugs_working_qa_contact_priority_recast  <- dcast(bugs_working_priority, qa_contact  ~ qa_contact_priority,  drop=FALSE, value.var="qa_contact_priority",  fun=length);


																						
# Merge the newly recast tables and profiles_working tables based on reporter/assigned_to/qa_contact userids & profiles_working userid to add the priority types count columns
setkey(bugs_working_reporter_priority_recast, 	 reporter);
setkey(bugs_working_assigned_to_priority_recast, assigned_to);
setkey(bugs_working_qa_contact_priority_recast,  qa_contact);

# Because there are so many new columns being added, instead of creating a long list of ifelse looking NA values to set to zero, we'll do the merge in three stages
# The first stage merges against the whole profiles_working$userid column alone, creating a table with just the new columns and userid
# Second, we replace all the NA values with 0
# Third, we merge the NA-free table with the profiles_working table

# Step 1
profiles_working_userids <- select(profiles_working, userid);
setkey(profiles_working_userids, userid);

profiles_working_new_priority_columns <- merge(profiles_working_userids, 			  bugs_working_reporter_priority_recast, 	by.x="userid", by.y="reporter",    all.x=TRUE);
profiles_working_new_priority_columns <- merge(profiles_working_new_priority_columns, bugs_working_assigned_to_priority_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);
profiles_working_new_priority_columns <- merge(profiles_working_new_priority_columns, bugs_working_qa_contact_priority_recast,	by.x="userid", by.y="qa_contact",  all.x=TRUE);


# Step 2 - Using data.table's convenient format
profiles_working_new_priority_columns[is.na(profiles_working_new_priority_columns)] <- 0;

# Step 3
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, profiles_working_new_priority_columns, by="userid", all.x=TRUE);
	
	
# PROFILES-BUGS_USER_REPORTER_OR_ASSIGNED_TO_OR_QA_CONTACT_BUG_TYPES
# Count the number of bugs each user reported, was assigned to, or was set as qa_contact for each bug type
# The bug types are defined here as rep_platform, op_sys, product_classification
# Product_id, component_id, target_milestones are omitted as there are faaar too many to summarize meaningfully


# Select just the columns of the bugs_base table that we need, namely roles & types
bugs_roles_types <- select(bugs_base, reporter, assigned_to, qa_contact, rep_platform, op_sys, classification_name);

# Add a prefix to each type to make the column names easier to understand after the dcast
bugs_roles_types <- mutate(bugs_roles_types, reported_rep_platform		  	 = paste0("bugs_reported_rep_platform_", 			   rep_platform, 		"_count"),
											 reported_op_sys			  	 = paste0("bugs_reported_op_sys_", 				   op_sys, 			  	"_count"),
											 reported_classification_name 	 = paste0("bugs_reported_product_classification_",    classification_name, "_count"),
											 assigned_to_rep_platform		 = paste0("bugs_assigned_to_rep_platform_", 		   rep_platform, 		"_count"),
											 assigned_to_op_sys			  	 = paste0("bugs_assigned_to_op_sys_", 				   op_sys, 			   	"_count"),
											 assigned_to_classification_name = paste0("bugs_assigned_to_product_classification_", classification_name, "_count"),
											 qa_contact_rep_platform		 = paste0("bugs_qa_contact_rep_platform_", 		   rep_platform, 		"_count"),
											 qa_contact_op_sys			  	 = paste0("bugs_qa_contact_op_sys_", 				   op_sys, 			   	"_count"),
											 qa_contact_classification_name  = paste0("bugs_qa_contact_product_classification_",  classification_name, "_count"));

# Use data.table::dcast() to recast the table with each row as a single user id of either reporter, assigned_to, or qa_contact, and each column the values of each type
# Start with reporter and type rep_platform, then repeat with reporter + op_sys and reporter + classification_name											 
bugs_reporter_rep_platform_dcast 		   <- data.table::dcast(bugs_roles_types, reporter ~ reported_rep_platform, 			 drop=FALSE, value.var="reported_rep_platform", 	  	  fun=length);
bugs_reporter_op_sys_dcast 				   <- data.table::dcast(bugs_roles_types, reporter ~ reported_op_sys, 		 			 drop=FALSE, value.var="reported_op_sys", 			  	  fun=length);	
bugs_reporter_classification_name_dcast    <- data.table::dcast(bugs_roles_types, reporter ~ reported_classification_name, 		 drop=FALSE, value.var="reported_classification_name",    fun=length);	
	
# Repeat with assigned_to and qa_contact and their respective types
bugs_assigned_to_rep_platform_dcast 	   <- data.table::dcast(bugs_roles_types, assigned_to ~ assigned_to_rep_platform, 		 drop=FALSE, value.var="assigned_to_rep_platform", 	  	  fun=length);
bugs_assigned_to_op_sys_dcast 			   <- data.table::dcast(bugs_roles_types, assigned_to ~ assigned_to_op_sys, 		 	 drop=FALSE, value.var="assigned_to_op_sys", 			  fun=length);	
bugs_assigned_to_classification_name_dcast <- data.table::dcast(bugs_roles_types, assigned_to ~ assigned_to_classification_name, drop=FALSE, value.var="assigned_to_classification_name", fun=length);	

bugs_qa_contact_rep_platform_dcast 	   	   <- data.table::dcast(bugs_roles_types, qa_contact ~ qa_contact_rep_platform, 		 drop=FALSE, value.var="qa_contact_rep_platform", 	  	  fun=length);
bugs_qa_contact_op_sys_dcast 			   <- data.table::dcast(bugs_roles_types, qa_contact ~ qa_contact_op_sys, 		 	 	 drop=FALSE, value.var="qa_contact_op_sys", 			  fun=length);	
bugs_qa_contact_classification_name_dcast  <- data.table::dcast(bugs_roles_types, qa_contact ~ qa_contact_classification_name,   drop=FALSE, value.var="qa_contact_classification_name",  fun=length);	


# Merge each resulting table with profiles_working table by userid & who
setkey(bugs_reporter_rep_platform_dcast, 		   reporter);
setkey(bugs_reporter_op_sys_dcast, 				   reporter);
setkey(bugs_reporter_classification_name_dcast,    reporter);
setkey(bugs_assigned_to_rep_platform_dcast, 	   assigned_to);
setkey(bugs_assigned_to_op_sys_dcast, 			   assigned_to);
setkey(bugs_assigned_to_classification_name_dcast, assigned_to);
setkey(bugs_qa_contact_rep_platform_dcast, 	   	   qa_contact);
setkey(bugs_qa_contact_op_sys_dcast, 			   qa_contact);
setkey(bugs_qa_contact_classification_name_dcast,  qa_contact);

# Because there are so many new columns being added, instead of creating a long list of ifelse looking NA values to set to zero, we'll do the merge in three stages
# The first stage merges against the whole profiles_working$userid column alone, creating a table with just the new columns and userid
# Second, we replace all the NA values with 0
# Third, we merge the NA-free table with the profiles_working table	

# Step 1	
profiles_working_userids <- select(profiles_working, userid);	
setkey(profiles_working_userids, userid);	
	
profiles_working_new_bug_columns <- merge(profiles_working_userids, 		bugs_reporter_rep_platform_dcast, 			by.x="userid", by.y="reporter",    all.x=TRUE);
profiles_working_new_bug_columns <- merge(profiles_working_new_bug_columns, bugs_reporter_op_sys_dcast, 				by.x="userid", by.y="reporter",    all.x=TRUE);
profiles_working_new_bug_columns <- merge(profiles_working_new_bug_columns, bugs_reporter_classification_name_dcast,	by.x="userid", by.y="reporter",    all.x=TRUE);	
profiles_working_new_bug_columns <- merge(profiles_working_new_bug_columns, bugs_assigned_to_rep_platform_dcast, 		by.x="userid", by.y="assigned_to", all.x=TRUE);
profiles_working_new_bug_columns <- merge(profiles_working_new_bug_columns, bugs_assigned_to_op_sys_dcast,				by.x="userid", by.y="assigned_to", all.x=TRUE);
profiles_working_new_bug_columns <- merge(profiles_working_new_bug_columns, bugs_assigned_to_classification_name_dcast, by.x="userid", by.y="assigned_to", all.x=TRUE);
profiles_working_new_bug_columns <- merge(profiles_working_new_bug_columns, bugs_qa_contact_rep_platform_dcast,			by.x="userid", by.y="qa_contact",  all.x=TRUE);	
profiles_working_new_bug_columns <- merge(profiles_working_new_bug_columns, bugs_qa_contact_op_sys_dcast, 				by.x="userid", by.y="qa_contact",  all.x=TRUE);
profiles_working_new_bug_columns <- merge(profiles_working_new_bug_columns, bugs_qa_contact_classification_name_dcast,	by.x="userid", by.y="qa_contact",  all.x=TRUE);		

# Step 2 - Using data.table's convenient format
profiles_working_new_bug_columns[is.na(profiles_working_new_bug_columns)] <- 0;


# Step 3
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, profiles_working_new_bug_columns, by="userid", all.x=TRUE);


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
																					bugs_reported_1994_count = if (exists('arg1994', where = bugs_working_reporter_year_recast)) arg1994 else 0,
																					bugs_reported_1995_count = if (exists('arg1995', where = bugs_working_reporter_year_recast)) arg1995 else 0,
																					bugs_reported_1996_count = if (exists('arg1996', where = bugs_working_reporter_year_recast)) arg1996 else 0,
																					bugs_reported_1997_count = if (exists('arg1997', where = bugs_working_reporter_year_recast)) arg1997 else 0,
																					bugs_reported_1998_count = if (exists('arg1998', where = bugs_working_reporter_year_recast)) arg1998 else 0,
																					bugs_reported_1999_count = if (exists('arg1999', where = bugs_working_reporter_year_recast)) arg1999 else 0,
																					bugs_reported_2000_count = if (exists('arg2000', where = bugs_working_reporter_year_recast)) arg2000 else 0,
																					bugs_reported_2001_count = if (exists('arg2001', where = bugs_working_reporter_year_recast)) arg2001 else 0,
																					bugs_reported_2002_count = if (exists('arg2002', where = bugs_working_reporter_year_recast)) arg2002 else 0,
																					bugs_reported_2003_count = if (exists('arg2003', where = bugs_working_reporter_year_recast)) arg2003 else 0,
																					bugs_reported_2004_count = if (exists('arg2004', where = bugs_working_reporter_year_recast)) arg2004 else 0,
																					bugs_reported_2005_count = if (exists('arg2005', where = bugs_working_reporter_year_recast)) arg2005 else 0,
																					bugs_reported_2006_count = if (exists('arg2006', where = bugs_working_reporter_year_recast)) arg2006 else 0,
																					bugs_reported_2007_count = if (exists('arg2007', where = bugs_working_reporter_year_recast)) arg2007 else 0,
																					bugs_reported_2008_count = if (exists('arg2008', where = bugs_working_reporter_year_recast)) arg2008 else 0,
																					bugs_reported_2009_count = if (exists('arg2009', where = bugs_working_reporter_year_recast)) arg2009 else 0,
																					bugs_reported_2010_count = if (exists('arg2010', where = bugs_working_reporter_year_recast)) arg2010 else 0,
																					bugs_reported_2011_count = if (exists('arg2011', where = bugs_working_reporter_year_recast)) arg2011 else 0,
																					bugs_reported_2012_count = if (exists('arg2012', where = bugs_working_reporter_year_recast)) arg2012 else 0,
																					bugs_reported_2013_count = if (exists('arg2013', where = bugs_working_reporter_year_recast)) arg2013 else 0);
																						
# Merge the bugs_working_reporter_year_recast and profiles_working tables based on reporter & userid to add the years count columns
setkey(bugs_working_reporter_year_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_year_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, bugs_reported_1994_count = safe_ifelse(is.na(bugs_reported_1994_count), 0, bugs_reported_1994_count), 
                                             bugs_reported_1995_count = safe_ifelse(is.na(bugs_reported_1995_count), 0, bugs_reported_1995_count),
                                             bugs_reported_1996_count = safe_ifelse(is.na(bugs_reported_1996_count), 0, bugs_reported_1996_count),
                                             bugs_reported_1997_count = safe_ifelse(is.na(bugs_reported_1997_count), 0, bugs_reported_1997_count),
                                             bugs_reported_1998_count = safe_ifelse(is.na(bugs_reported_1998_count), 0, bugs_reported_1998_count),
                                             bugs_reported_1999_count = safe_ifelse(is.na(bugs_reported_1999_count), 0, bugs_reported_1999_count),
                                             bugs_reported_2000_count = safe_ifelse(is.na(bugs_reported_2000_count), 0, bugs_reported_2000_count),
											 bugs_reported_2001_count = safe_ifelse(is.na(bugs_reported_2001_count), 0, bugs_reported_2001_count),
											 bugs_reported_2002_count = safe_ifelse(is.na(bugs_reported_2002_count), 0, bugs_reported_2002_count),
											 bugs_reported_2003_count = safe_ifelse(is.na(bugs_reported_2003_count), 0, bugs_reported_2003_count),
											 bugs_reported_2004_count = safe_ifelse(is.na(bugs_reported_2004_count), 0, bugs_reported_2004_count),
											 bugs_reported_2005_count = safe_ifelse(is.na(bugs_reported_2005_count), 0, bugs_reported_2005_count),
											 bugs_reported_2006_count = safe_ifelse(is.na(bugs_reported_2006_count), 0, bugs_reported_2006_count),
											 bugs_reported_2007_count = safe_ifelse(is.na(bugs_reported_2007_count), 0, bugs_reported_2007_count),
											 bugs_reported_2008_count = safe_ifelse(is.na(bugs_reported_2008_count), 0, bugs_reported_2008_count),
											 bugs_reported_2009_count = safe_ifelse(is.na(bugs_reported_2009_count), 0, bugs_reported_2009_count),
											 bugs_reported_2010_count = safe_ifelse(is.na(bugs_reported_2010_count), 0, bugs_reported_2010_count),
											 bugs_reported_2011_count = safe_ifelse(is.na(bugs_reported_2011_count), 0, bugs_reported_2011_count),
											 bugs_reported_2012_count = safe_ifelse(is.na(bugs_reported_2012_count), 0, bugs_reported_2012_count),
											 bugs_reported_2013_count = safe_ifelse(is.na(bugs_reported_2013_count), 0, bugs_reported_2013_count)); 


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
																						bugs_assigned_to_1994_count = if (exists('arg1994', where = bugs_working_assigned_to_year_recast)) arg1994 else 0,
																						bugs_assigned_to_1995_count = if (exists('arg1995', where = bugs_working_assigned_to_year_recast)) arg1995 else 0,
																						bugs_assigned_to_1996_count = if (exists('arg1996', where = bugs_working_assigned_to_year_recast)) arg1996 else 0,
																						bugs_assigned_to_1997_count = if (exists('arg1997', where = bugs_working_assigned_to_year_recast)) arg1997 else 0,
																						bugs_assigned_to_1998_count = if (exists('arg1998', where = bugs_working_assigned_to_year_recast)) arg1998 else 0,
																						bugs_assigned_to_1999_count = if (exists('arg1999', where = bugs_working_assigned_to_year_recast)) arg1999 else 0,
																						bugs_assigned_to_2000_count = if (exists('arg2000', where = bugs_working_assigned_to_year_recast)) arg2000 else 0,
																						bugs_assigned_to_2001_count = if (exists('arg2001', where = bugs_working_assigned_to_year_recast)) arg2001 else 0,
																						bugs_assigned_to_2002_count = if (exists('arg2002', where = bugs_working_assigned_to_year_recast)) arg2002 else 0,
																						bugs_assigned_to_2003_count = if (exists('arg2003', where = bugs_working_assigned_to_year_recast)) arg2003 else 0,
																						bugs_assigned_to_2004_count = if (exists('arg2004', where = bugs_working_assigned_to_year_recast)) arg2004 else 0,
																						bugs_assigned_to_2005_count = if (exists('arg2005', where = bugs_working_assigned_to_year_recast)) arg2005 else 0,
																						bugs_assigned_to_2006_count = if (exists('arg2006', where = bugs_working_assigned_to_year_recast)) arg2006 else 0,
																						bugs_assigned_to_2007_count = if (exists('arg2007', where = bugs_working_assigned_to_year_recast)) arg2007 else 0,
																						bugs_assigned_to_2008_count = if (exists('arg2008', where = bugs_working_assigned_to_year_recast)) arg2008 else 0,
																						bugs_assigned_to_2009_count = if (exists('arg2009', where = bugs_working_assigned_to_year_recast)) arg2009 else 0,
																						bugs_assigned_to_2010_count = if (exists('arg2010', where = bugs_working_assigned_to_year_recast)) arg2010 else 0,
																						bugs_assigned_to_2011_count = if (exists('arg2011', where = bugs_working_assigned_to_year_recast)) arg2011 else 0,
																						bugs_assigned_to_2012_count = if (exists('arg2012', where = bugs_working_assigned_to_year_recast)) arg2012 else 0,
																						bugs_assigned_to_2013_count = if (exists('arg2013', where = bugs_working_assigned_to_year_recast)) arg2013 else 0);
																					 																						
# Merge the bugs_working_assigned_to_year_recast and profiles_working tables based on assigned_to & userid to add the years count columns
setkey(bugs_working_assigned_to_year_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_year_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user was not assigned any bugs, so change to 0
profiles_working <- mutate(profiles_working, bugs_assigned_to_1994_count = safe_ifelse(is.na(bugs_assigned_to_1994_count), 0, bugs_assigned_to_1994_count),
											 bugs_assigned_to_1995_count = safe_ifelse(is.na(bugs_assigned_to_1995_count), 0, bugs_assigned_to_1995_count),
											 bugs_assigned_to_1996_count = safe_ifelse(is.na(bugs_assigned_to_1996_count), 0, bugs_assigned_to_1996_count),
											 bugs_assigned_to_1997_count = safe_ifelse(is.na(bugs_assigned_to_1997_count), 0, bugs_assigned_to_1997_count),
											 bugs_assigned_to_1998_count = safe_ifelse(is.na(bugs_assigned_to_1998_count), 0, bugs_assigned_to_1998_count),
											 bugs_assigned_to_1999_count = safe_ifelse(is.na(bugs_assigned_to_1999_count), 0, bugs_assigned_to_1999_count),
											 bugs_assigned_to_2000_count = safe_ifelse(is.na(bugs_assigned_to_2000_count), 0, bugs_assigned_to_2000_count),
											 bugs_assigned_to_2001_count = safe_ifelse(is.na(bugs_assigned_to_2001_count), 0, bugs_assigned_to_2001_count),
											 bugs_assigned_to_2002_count = safe_ifelse(is.na(bugs_assigned_to_2002_count), 0, bugs_assigned_to_2002_count),
											 bugs_assigned_to_2003_count = safe_ifelse(is.na(bugs_assigned_to_2003_count), 0, bugs_assigned_to_2003_count),
											 bugs_assigned_to_2004_count = safe_ifelse(is.na(bugs_assigned_to_2004_count), 0, bugs_assigned_to_2004_count),
											 bugs_assigned_to_2005_count = safe_ifelse(is.na(bugs_assigned_to_2005_count), 0, bugs_assigned_to_2005_count),
											 bugs_assigned_to_2006_count = safe_ifelse(is.na(bugs_assigned_to_2006_count), 0, bugs_assigned_to_2006_count),
											 bugs_assigned_to_2007_count = safe_ifelse(is.na(bugs_assigned_to_2007_count), 0, bugs_assigned_to_2007_count),
											 bugs_assigned_to_2008_count = safe_ifelse(is.na(bugs_assigned_to_2008_count), 0, bugs_assigned_to_2008_count),
											 bugs_assigned_to_2009_count = safe_ifelse(is.na(bugs_assigned_to_2009_count), 0, bugs_assigned_to_2009_count),
											 bugs_assigned_to_2010_count = safe_ifelse(is.na(bugs_assigned_to_2010_count), 0, bugs_assigned_to_2010_count),
											 bugs_assigned_to_2011_count = safe_ifelse(is.na(bugs_assigned_to_2011_count), 0, bugs_assigned_to_2011_count),
											 bugs_assigned_to_2012_count = safe_ifelse(is.na(bugs_assigned_to_2012_count), 0, bugs_assigned_to_2012_count),
											 bugs_assigned_to_2013_count = safe_ifelse(is.na(bugs_assigned_to_2013_count), 0, bugs_assigned_to_2013_count));



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
																						bugs_qa_contact_1994_count = if (exists('arg1994', where = bugs_working_qa_contact_year_recast)) arg1994 else 0,
																						bugs_qa_contact_1995_count = if (exists('arg1995', where = bugs_working_qa_contact_year_recast)) arg1995 else 0,
																						bugs_qa_contact_1996_count = if (exists('arg1996', where = bugs_working_qa_contact_year_recast)) arg1996 else 0,
																						bugs_qa_contact_1997_count = if (exists('arg1997', where = bugs_working_qa_contact_year_recast)) arg1997 else 0,
																						bugs_qa_contact_1998_count = if (exists('arg1998', where = bugs_working_qa_contact_year_recast)) arg1998 else 0,
																						bugs_qa_contact_1999_count = if (exists('arg1999', where = bugs_working_qa_contact_year_recast)) arg1999 else 0,
																						bugs_qa_contact_2000_count = if (exists('arg2000', where = bugs_working_qa_contact_year_recast)) arg2000 else 0,
																						bugs_qa_contact_2001_count = if (exists('arg2001', where = bugs_working_qa_contact_year_recast)) arg2001 else 0,
																						bugs_qa_contact_2002_count = if (exists('arg2002', where = bugs_working_qa_contact_year_recast)) arg2002 else 0,
																						bugs_qa_contact_2003_count = if (exists('arg2003', where = bugs_working_qa_contact_year_recast)) arg2003 else 0,
																						bugs_qa_contact_2004_count = if (exists('arg2004', where = bugs_working_qa_contact_year_recast)) arg2004 else 0,
																						bugs_qa_contact_2005_count = if (exists('arg2005', where = bugs_working_qa_contact_year_recast)) arg2005 else 0,
																						bugs_qa_contact_2006_count = if (exists('arg2006', where = bugs_working_qa_contact_year_recast)) arg2006 else 0,
																						bugs_qa_contact_2007_count = if (exists('arg2007', where = bugs_working_qa_contact_year_recast)) arg2007 else 0,
																						bugs_qa_contact_2008_count = if (exists('arg2008', where = bugs_working_qa_contact_year_recast)) arg2008 else 0,
																						bugs_qa_contact_2009_count = if (exists('arg2009', where = bugs_working_qa_contact_year_recast)) arg2009 else 0,
																						bugs_qa_contact_2010_count = if (exists('arg2010', where = bugs_working_qa_contact_year_recast)) arg2010 else 0,
																						bugs_qa_contact_2011_count = if (exists('arg2011', where = bugs_working_qa_contact_year_recast)) arg2011 else 0,
																						bugs_qa_contact_2012_count = if (exists('arg2012', where = bugs_working_qa_contact_year_recast)) arg2012 else 0,
																						bugs_qa_contact_2013_count = if (exists('arg2013', where = bugs_working_qa_contact_year_recast)) arg2013 else 0);
																						
# Merge the bugs_working_qa_contact_year_recast and profiles_working tables based on qa_contact & userid to add the years count columns
setkey(bugs_working_qa_contact_year_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_year_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user was not set as qa_contact for any bugs, so change to 0
profiles_working <- mutate(profiles_working, bugs_qa_contact_1994_count = safe_ifelse(is.na(bugs_qa_contact_1994_count), 0, bugs_qa_contact_1994_count),
                                             bugs_qa_contact_1995_count = safe_ifelse(is.na(bugs_qa_contact_1995_count), 0, bugs_qa_contact_1995_count),
											 bugs_qa_contact_1996_count = safe_ifelse(is.na(bugs_qa_contact_1996_count), 0, bugs_qa_contact_1996_count),
											 bugs_qa_contact_1997_count = safe_ifelse(is.na(bugs_qa_contact_1997_count), 0, bugs_qa_contact_1997_count),
											 bugs_qa_contact_1998_count = safe_ifelse(is.na(bugs_qa_contact_1998_count), 0, bugs_qa_contact_1998_count),
											 bugs_qa_contact_1999_count = safe_ifelse(is.na(bugs_qa_contact_1999_count), 0, bugs_qa_contact_1999_count),
											 bugs_qa_contact_2000_count = safe_ifelse(is.na(bugs_qa_contact_2000_count), 0, bugs_qa_contact_2000_count),
											 bugs_qa_contact_2001_count = safe_ifelse(is.na(bugs_qa_contact_2001_count), 0, bugs_qa_contact_2001_count),
											 bugs_qa_contact_2002_count = safe_ifelse(is.na(bugs_qa_contact_2002_count), 0, bugs_qa_contact_2002_count),
											 bugs_qa_contact_2003_count = safe_ifelse(is.na(bugs_qa_contact_2003_count), 0, bugs_qa_contact_2003_count),
											 bugs_qa_contact_2004_count = safe_ifelse(is.na(bugs_qa_contact_2004_count), 0, bugs_qa_contact_2004_count),
											 bugs_qa_contact_2005_count = safe_ifelse(is.na(bugs_qa_contact_2005_count), 0, bugs_qa_contact_2005_count),
											 bugs_qa_contact_2006_count = safe_ifelse(is.na(bugs_qa_contact_2006_count), 0, bugs_qa_contact_2006_count),
											 bugs_qa_contact_2007_count = safe_ifelse(is.na(bugs_qa_contact_2007_count), 0, bugs_qa_contact_2007_count),
											 bugs_qa_contact_2008_count = safe_ifelse(is.na(bugs_qa_contact_2008_count), 0, bugs_qa_contact_2008_count),
											 bugs_qa_contact_2009_count = safe_ifelse(is.na(bugs_qa_contact_2009_count), 0, bugs_qa_contact_2009_count),
											 bugs_qa_contact_2010_count = safe_ifelse(is.na(bugs_qa_contact_2010_count), 0, bugs_qa_contact_2010_count),
											 bugs_qa_contact_2011_count = safe_ifelse(is.na(bugs_qa_contact_2011_count), 0, bugs_qa_contact_2011_count),
											 bugs_qa_contact_2012_count = safe_ifelse(is.na(bugs_qa_contact_2012_count), 0, bugs_qa_contact_2012_count),
											 bugs_qa_contact_2013_count = safe_ifelse(is.na(bugs_qa_contact_2013_count), 0, bugs_qa_contact_2013_count));

	
	
# CLEAN UP


# Set global variables for other functions
profiles_interactions_partial 	<<- profiles_working;
bugs_interactions_partial 		<<- bugs_working;
											 
} # End operationalize_interactions_partial function



###############################################
#
# We split the operationalize_interactions function here because it's too long and we need
# R to release system memory and dump function-scope objects
#
###############################################


operationalize_interactions <- function () {

# Import partial variables to continue building
profiles_working <- profiles_interactions_partial;
bugs_working 	 <- bugs_interactions_partial;

	
# PROFILES-ACTIVITY_TYPES_YEARS
# (Count the types of activity done by each user per year)

# The types of interest to count are changes to the following bug fields: CC, keywords, product, component, status, resolution, 
# flags, whiteboard, target_milestone, description, priority, & severity
# Their respective fieldid's are: 37, 21, 25, 33, 29, 30, 69, 22, 40, 24, 32, 31 in the activity table
# Since we only care about count per year, all we need is "who", "fieldid", and year(bug_when) . Other columns don't matter here.

activity_working_types_who_year <- transmute(filter(activity_base, fieldid %in% c(37, 21, 25, 33, 29, 30, 69, 22, 40, 24, 32, 31)), who = who, fieldid = fieldid, bug_when_year = chron::years(bug_when));

# Use data.table's dcast() function to recast the table such that each row is a single user and there is
# a column for each field_id that is the sum of each activities of that type by each user for each year
activity_working_types_who_year_recast <- dcast(activity_working_types_who_year, who ~ fieldid + bug_when_year, drop=FALSE, value.var="fieldid", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_working_types_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(activity_working_types_who_year_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns to our desired names
activity_working_types_who_year_recast <- transmute(activity_working_types_who_year_recast, 	who 												= who,
																								activity_cc_change_1998_count 					= if (exists('arg37_1998', where = activity_working_types_who_year_recast)) arg37_1998 else 0,
																								activity_cc_change_1999_count 					= if (exists('arg37_1999', where = activity_working_types_who_year_recast)) arg37_1999 else 0,
																								activity_cc_change_2000_count 					= if (exists('arg37_2000', where = activity_working_types_who_year_recast)) arg37_2000 else 0,
																								activity_cc_change_2001_count 					= if (exists('arg37_2001', where = activity_working_types_who_year_recast)) arg37_2001 else 0,
																								activity_cc_change_2002_count 					= if (exists('arg37_2002', where = activity_working_types_who_year_recast)) arg37_2002 else 0,
																								activity_cc_change_2003_count 					= if (exists('arg37_2003', where = activity_working_types_who_year_recast)) arg37_2003 else 0,
																								activity_cc_change_2004_count 					= if (exists('arg37_2004', where = activity_working_types_who_year_recast)) arg37_2004 else 0,
																								activity_cc_change_2005_count 					= if (exists('arg37_2005', where = activity_working_types_who_year_recast)) arg37_2005 else 0,
																								activity_cc_change_2006_count 					= if (exists('arg37_2006', where = activity_working_types_who_year_recast)) arg37_2006 else 0,
																								activity_cc_change_2007_count 					= if (exists('arg37_2007', where = activity_working_types_who_year_recast)) arg37_2007 else 0,
																								activity_cc_change_2008_count 					= if (exists('arg37_2008', where = activity_working_types_who_year_recast)) arg37_2008 else 0,
																								activity_cc_change_2009_count 					= if (exists('arg37_2009', where = activity_working_types_who_year_recast)) arg37_2009 else 0,
																								activity_cc_change_2010_count 					= if (exists('arg37_2010', where = activity_working_types_who_year_recast)) arg37_2010 else 0,
																								activity_cc_change_2011_count 					= if (exists('arg37_2011', where = activity_working_types_who_year_recast)) arg37_2011 else 0,
																								activity_cc_change_2012_count 					= if (exists('arg37_2012', where = activity_working_types_who_year_recast)) arg37_2012 else 0,
																								activity_cc_change_2013_count 					= if (exists('arg37_2013', where = activity_working_types_who_year_recast)) arg37_2013 else 0,
																								activity_keywords_change_1998_count 			= if (exists('arg21_1998', where = activity_working_types_who_year_recast)) arg21_1998 else 0,
																								activity_keywords_change_1999_count 			= if (exists('arg21_1999', where = activity_working_types_who_year_recast)) arg21_1999 else 0,
																								activity_keywords_change_2000_count 			= if (exists('arg21_2000', where = activity_working_types_who_year_recast)) arg21_2000 else 0,
																								activity_keywords_change_2001_count 			= if (exists('arg21_2001', where = activity_working_types_who_year_recast)) arg21_2001 else 0,
																								activity_keywords_change_2002_count 			= if (exists('arg21_2002', where = activity_working_types_who_year_recast)) arg21_2002 else 0,
																								activity_keywords_change_2003_count 			= if (exists('arg21_2003', where = activity_working_types_who_year_recast)) arg21_2003 else 0,
																								activity_keywords_change_2004_count 			= if (exists('arg21_2004', where = activity_working_types_who_year_recast)) arg21_2004 else 0,
																								activity_keywords_change_2005_count 			= if (exists('arg21_2005', where = activity_working_types_who_year_recast)) arg21_2005 else 0,
																								activity_keywords_change_2006_count 			= if (exists('arg21_2006', where = activity_working_types_who_year_recast)) arg21_2006 else 0,
																								activity_keywords_change_2007_count 			= if (exists('arg21_2007', where = activity_working_types_who_year_recast)) arg21_2007 else 0,
																								activity_keywords_change_2008_count 			= if (exists('arg21_2008', where = activity_working_types_who_year_recast)) arg21_2008 else 0,
																								activity_keywords_change_2009_count 			= if (exists('arg21_2009', where = activity_working_types_who_year_recast)) arg21_2009 else 0,
																								activity_keywords_change_2010_count 			= if (exists('arg21_2010', where = activity_working_types_who_year_recast)) arg21_2010 else 0,
																								activity_keywords_change_2011_count 			= if (exists('arg21_2011', where = activity_working_types_who_year_recast)) arg21_2011 else 0,
																								activity_keywords_change_2012_count 			= if (exists('arg21_2012', where = activity_working_types_who_year_recast)) arg21_2012 else 0,
																								activity_keywords_change_2013_count 			= if (exists('arg21_2013', where = activity_working_types_who_year_recast)) arg21_2013 else 0,
																								activity_product_change_1998_count 			= if (exists('arg25_1998', where = activity_working_types_who_year_recast)) arg25_1998 else 0,
																								activity_product_change_1999_count 			= if (exists('arg25_1999', where = activity_working_types_who_year_recast)) arg25_1999 else 0,
																								activity_product_change_2000_count 			= if (exists('arg25_2000', where = activity_working_types_who_year_recast)) arg25_2000 else 0,
																								activity_product_change_2001_count 			= if (exists('arg25_2001', where = activity_working_types_who_year_recast)) arg25_2001 else 0,
																								activity_product_change_2002_count 			= if (exists('arg25_2002', where = activity_working_types_who_year_recast)) arg25_2002 else 0,
																								activity_product_change_2003_count 			= if (exists('arg25_2003', where = activity_working_types_who_year_recast)) arg25_2003 else 0,
																								activity_product_change_2004_count 			= if (exists('arg25_2004', where = activity_working_types_who_year_recast)) arg25_2004 else 0,
																								activity_product_change_2005_count 			= if (exists('arg25_2005', where = activity_working_types_who_year_recast)) arg25_2005 else 0,
																								activity_product_change_2006_count 			= if (exists('arg25_2006', where = activity_working_types_who_year_recast)) arg25_2006 else 0,
																								activity_product_change_2007_count 			= if (exists('arg25_2007', where = activity_working_types_who_year_recast)) arg25_2007 else 0,
																								activity_product_change_2008_count 			= if (exists('arg25_2008', where = activity_working_types_who_year_recast)) arg25_2008 else 0,
																								activity_product_change_2009_count 			= if (exists('arg25_2009', where = activity_working_types_who_year_recast)) arg25_2009 else 0,
																								activity_product_change_2010_count 			= if (exists('arg25_2010', where = activity_working_types_who_year_recast)) arg25_2010 else 0,
																								activity_product_change_2011_count 			= if (exists('arg25_2011', where = activity_working_types_who_year_recast)) arg25_2011 else 0,
																								activity_product_change_2012_count 			= if (exists('arg25_2012', where = activity_working_types_who_year_recast)) arg25_2012 else 0,
																								activity_product_change_2013_count 			= if (exists('arg25_2013', where = activity_working_types_who_year_recast)) arg25_2013 else 0,
																								activity_component_change_1998_count 			= if (exists('arg33_1998', where = activity_working_types_who_year_recast)) arg33_1998 else 0,
																								activity_component_change_1999_count 			= if (exists('arg33_1999', where = activity_working_types_who_year_recast)) arg33_1999 else 0,
																								activity_component_change_2000_count 			= if (exists('arg33_2000', where = activity_working_types_who_year_recast)) arg33_2000 else 0,
																								activity_component_change_2001_count 			= if (exists('arg33_2001', where = activity_working_types_who_year_recast)) arg33_2001 else 0,
																								activity_component_change_2002_count 			= if (exists('arg33_2002', where = activity_working_types_who_year_recast)) arg33_2002 else 0,
																								activity_component_change_2003_count 			= if (exists('arg33_2003', where = activity_working_types_who_year_recast)) arg33_2003 else 0,
																								activity_component_change_2004_count 			= if (exists('arg33_2004', where = activity_working_types_who_year_recast)) arg33_2004 else 0,
																								activity_component_change_2005_count 			= if (exists('arg33_2005', where = activity_working_types_who_year_recast)) arg33_2005 else 0,
																								activity_component_change_2006_count 			= if (exists('arg33_2006', where = activity_working_types_who_year_recast)) arg33_2006 else 0,
																								activity_component_change_2007_count 			= if (exists('arg33_2007', where = activity_working_types_who_year_recast)) arg33_2007 else 0,
																								activity_component_change_2008_count 			= if (exists('arg33_2008', where = activity_working_types_who_year_recast)) arg33_2008 else 0,
																								activity_component_change_2009_count 			= if (exists('arg33_2009', where = activity_working_types_who_year_recast)) arg33_2009 else 0,
																								activity_component_change_2010_count 			= if (exists('arg33_2010', where = activity_working_types_who_year_recast)) arg33_2010 else 0,
																								activity_component_change_2011_count 			= if (exists('arg33_2011', where = activity_working_types_who_year_recast)) arg33_2011 else 0,
																								activity_component_change_2012_count 			= if (exists('arg33_2012', where = activity_working_types_who_year_recast)) arg33_2012 else 0,
																								activity_component_change_2013_count 			= if (exists('arg33_2013', where = activity_working_types_who_year_recast)) arg33_2013 else 0,
																								activity_status_change_1998_count 				= if (exists('arg29_1998', where = activity_working_types_who_year_recast)) arg29_1998 else 0,
																								activity_status_change_1999_count 				= if (exists('arg29_1999', where = activity_working_types_who_year_recast)) arg29_1999 else 0,
																								activity_status_change_2000_count 				= if (exists('arg29_2000', where = activity_working_types_who_year_recast)) arg29_2000 else 0,
																								activity_status_change_2001_count 				= if (exists('arg29_2001', where = activity_working_types_who_year_recast)) arg29_2001 else 0,
																								activity_status_change_2002_count 				= if (exists('arg29_2002', where = activity_working_types_who_year_recast)) arg29_2002 else 0,
																								activity_status_change_2003_count 				= if (exists('arg29_2003', where = activity_working_types_who_year_recast)) arg29_2003 else 0,
																								activity_status_change_2004_count 				= if (exists('arg29_2004', where = activity_working_types_who_year_recast)) arg29_2004 else 0,
																								activity_status_change_2005_count 				= if (exists('arg29_2005', where = activity_working_types_who_year_recast)) arg29_2005 else 0,
																								activity_status_change_2006_count 				= if (exists('arg29_2006', where = activity_working_types_who_year_recast)) arg29_2006 else 0,
																								activity_status_change_2007_count 				= if (exists('arg29_2007', where = activity_working_types_who_year_recast)) arg29_2007 else 0,
																								activity_status_change_2008_count 				= if (exists('arg29_2008', where = activity_working_types_who_year_recast)) arg29_2008 else 0,
																								activity_status_change_2009_count 				= if (exists('arg29_2009', where = activity_working_types_who_year_recast)) arg29_2009 else 0,
																								activity_status_change_2010_count 				= if (exists('arg29_2010', where = activity_working_types_who_year_recast)) arg29_2010 else 0,
																								activity_status_change_2011_count 				= if (exists('arg29_2011', where = activity_working_types_who_year_recast)) arg29_2011 else 0,
																								activity_status_change_2012_count 				= if (exists('arg29_2012', where = activity_working_types_who_year_recast)) arg29_2012 else 0,
																								activity_status_change_2013_count 				= if (exists('arg29_2013', where = activity_working_types_who_year_recast)) arg29_2013 else 0,
																								activity_resolution_change_1998_count 			= if (exists('arg30_1998', where = activity_working_types_who_year_recast)) arg30_1998 else 0,
																								activity_resolution_change_1999_count 			= if (exists('arg30_1999', where = activity_working_types_who_year_recast)) arg30_1999 else 0,
																								activity_resolution_change_2000_count 			= if (exists('arg30_2000', where = activity_working_types_who_year_recast)) arg30_2000 else 0,
																								activity_resolution_change_2001_count 			= if (exists('arg30_2001', where = activity_working_types_who_year_recast)) arg30_2001 else 0,
																								activity_resolution_change_2002_count 			= if (exists('arg30_2002', where = activity_working_types_who_year_recast)) arg30_2002 else 0,
																								activity_resolution_change_2003_count 			= if (exists('arg30_2003', where = activity_working_types_who_year_recast)) arg30_2003 else 0,
																								activity_resolution_change_2004_count 			= if (exists('arg30_2004', where = activity_working_types_who_year_recast)) arg30_2004 else 0,
																								activity_resolution_change_2005_count 			= if (exists('arg30_2005', where = activity_working_types_who_year_recast)) arg30_2005 else 0,
																								activity_resolution_change_2006_count 			= if (exists('arg30_2006', where = activity_working_types_who_year_recast)) arg30_2006 else 0,
																								activity_resolution_change_2007_count 			= if (exists('arg30_2007', where = activity_working_types_who_year_recast)) arg30_2007 else 0,
																								activity_resolution_change_2008_count 			= if (exists('arg30_2008', where = activity_working_types_who_year_recast)) arg30_2008 else 0,
																								activity_resolution_change_2009_count 			= if (exists('arg30_2009', where = activity_working_types_who_year_recast)) arg30_2009 else 0,
																								activity_resolution_change_2010_count 			= if (exists('arg30_2010', where = activity_working_types_who_year_recast)) arg30_2010 else 0,
																								activity_resolution_change_2011_count 			= if (exists('arg30_2011', where = activity_working_types_who_year_recast)) arg30_2011 else 0,
																								activity_resolution_change_2012_count 			= if (exists('arg30_2012', where = activity_working_types_who_year_recast)) arg30_2012 else 0,
																								activity_resolution_change_2013_count 			= if (exists('arg30_2013', where = activity_working_types_who_year_recast)) arg30_2013 else 0,
																								activity_flags_change_1998_count 				= if (exists('arg69_1998', where = activity_working_types_who_year_recast)) arg69_1998 else 0,
																								activity_flags_change_1999_count 				= if (exists('arg69_1999', where = activity_working_types_who_year_recast)) arg69_1999 else 0,
																								activity_flags_change_2000_count 				= if (exists('arg69_2000', where = activity_working_types_who_year_recast)) arg69_2000 else 0,
																								activity_flags_change_2001_count 				= if (exists('arg69_2001', where = activity_working_types_who_year_recast)) arg69_2001 else 0,
																								activity_flags_change_2002_count 				= if (exists('arg69_2002', where = activity_working_types_who_year_recast)) arg69_2002 else 0,
																								activity_flags_change_2003_count 				= if (exists('arg69_2003', where = activity_working_types_who_year_recast)) arg69_2003 else 0,
																								activity_flags_change_2004_count 				= if (exists('arg69_2004', where = activity_working_types_who_year_recast)) arg69_2004 else 0,
																								activity_flags_change_2005_count 				= if (exists('arg69_2005', where = activity_working_types_who_year_recast)) arg69_2005 else 0,
																								activity_flags_change_2006_count 				= if (exists('arg69_2006', where = activity_working_types_who_year_recast)) arg69_2006 else 0,
																								activity_flags_change_2007_count 				= if (exists('arg69_2007', where = activity_working_types_who_year_recast)) arg69_2007 else 0,
																								activity_flags_change_2008_count 				= if (exists('arg69_2008', where = activity_working_types_who_year_recast)) arg69_2008 else 0,
																								activity_flags_change_2009_count 				= if (exists('arg69_2009', where = activity_working_types_who_year_recast)) arg69_2009 else 0,
																								activity_flags_change_2010_count 				= if (exists('arg69_2010', where = activity_working_types_who_year_recast)) arg69_2010 else 0,
																								activity_flags_change_2011_count 				= if (exists('arg69_2011', where = activity_working_types_who_year_recast)) arg69_2011 else 0,
																								activity_flags_change_2012_count 				= if (exists('arg69_2012', where = activity_working_types_who_year_recast)) arg69_2012 else 0,
																								activity_flags_change_2013_count 				= if (exists('arg69_2013', where = activity_working_types_who_year_recast)) arg69_2013 else 0,
																								activity_whiteboard_change_1998_count 			= if (exists('arg22_1998', where = activity_working_types_who_year_recast)) arg22_1998 else 0,
																								activity_whiteboard_change_1999_count 			= if (exists('arg22_1999', where = activity_working_types_who_year_recast)) arg22_1999 else 0,
																								activity_whiteboard_change_2000_count 			= if (exists('arg22_2000', where = activity_working_types_who_year_recast)) arg22_2000 else 0,
																								activity_whiteboard_change_2001_count 			= if (exists('arg22_2001', where = activity_working_types_who_year_recast)) arg22_2001 else 0,
																								activity_whiteboard_change_2002_count 			= if (exists('arg22_2002', where = activity_working_types_who_year_recast)) arg22_2002 else 0,
																								activity_whiteboard_change_2003_count 			= if (exists('arg22_2003', where = activity_working_types_who_year_recast)) arg22_2003 else 0,
																								activity_whiteboard_change_2004_count 			= if (exists('arg22_2004', where = activity_working_types_who_year_recast)) arg22_2004 else 0,
																								activity_whiteboard_change_2005_count 			= if (exists('arg22_2005', where = activity_working_types_who_year_recast)) arg22_2005 else 0,
																								activity_whiteboard_change_2006_count 			= if (exists('arg22_2006', where = activity_working_types_who_year_recast)) arg22_2006 else 0,
																								activity_whiteboard_change_2007_count 			= if (exists('arg22_2007', where = activity_working_types_who_year_recast)) arg22_2007 else 0,
																								activity_whiteboard_change_2008_count 			= if (exists('arg22_2008', where = activity_working_types_who_year_recast)) arg22_2008 else 0,
																								activity_whiteboard_change_2009_count 			= if (exists('arg22_2009', where = activity_working_types_who_year_recast)) arg22_2009 else 0,
																								activity_whiteboard_change_2010_count 			= if (exists('arg22_2010', where = activity_working_types_who_year_recast)) arg22_2010 else 0,
																								activity_whiteboard_change_2011_count 			= if (exists('arg22_2011', where = activity_working_types_who_year_recast)) arg22_2011 else 0,
																								activity_whiteboard_change_2012_count 			= if (exists('arg22_2012', where = activity_working_types_who_year_recast)) arg22_2012 else 0,
																								activity_whiteboard_change_2013_count 			= if (exists('arg22_2013', where = activity_working_types_who_year_recast)) arg22_2013 else 0,
																								activity_target_milestone_change_1998_count 	= if (exists('arg40_1998', where = activity_working_types_who_year_recast)) arg40_1998 else 0,
																								activity_target_milestone_change_1999_count 	= if (exists('arg40_1999', where = activity_working_types_who_year_recast)) arg40_1999 else 0,
																								activity_target_milestone_change_2000_count 	= if (exists('arg40_2000', where = activity_working_types_who_year_recast)) arg40_2000 else 0,
																								activity_target_milestone_change_2001_count 	= if (exists('arg40_2001', where = activity_working_types_who_year_recast)) arg40_2001 else 0,
																								activity_target_milestone_change_2002_count 	= if (exists('arg40_2002', where = activity_working_types_who_year_recast)) arg40_2002 else 0,
																								activity_target_milestone_change_2003_count 	= if (exists('arg40_2003', where = activity_working_types_who_year_recast)) arg40_2003 else 0,
																								activity_target_milestone_change_2004_count 	= if (exists('arg40_2004', where = activity_working_types_who_year_recast)) arg40_2004 else 0,
																								activity_target_milestone_change_2005_count 	= if (exists('arg40_2005', where = activity_working_types_who_year_recast)) arg40_2005 else 0,
																								activity_target_milestone_change_2006_count 	= if (exists('arg40_2006', where = activity_working_types_who_year_recast)) arg40_2006 else 0,
																								activity_target_milestone_change_2007_count 	= if (exists('arg40_2007', where = activity_working_types_who_year_recast)) arg40_2007 else 0,
																								activity_target_milestone_change_2008_count 	= if (exists('arg40_2008', where = activity_working_types_who_year_recast)) arg40_2008 else 0,
																								activity_target_milestone_change_2009_count 	= if (exists('arg40_2009', where = activity_working_types_who_year_recast)) arg40_2009 else 0,
																								activity_target_milestone_change_2010_count 	= if (exists('arg40_2010', where = activity_working_types_who_year_recast)) arg40_2010 else 0,
																								activity_target_milestone_change_2011_count 	= if (exists('arg40_2011', where = activity_working_types_who_year_recast)) arg40_2011 else 0,
																								activity_target_milestone_change_2012_count 	= if (exists('arg40_2012', where = activity_working_types_who_year_recast)) arg40_2012 else 0,
																								activity_target_milestone_change_2013_count 	= if (exists('arg40_2013', where = activity_working_types_who_year_recast)) arg40_2013 else 0,
																								activity_description_change_1998_count 		= if (exists('arg24_1998', where = activity_working_types_who_year_recast)) arg24_1998 else 0,
																								activity_description_change_1999_count 		= if (exists('arg24_1999', where = activity_working_types_who_year_recast)) arg24_1999 else 0,
																								activity_description_change_2000_count 		= if (exists('arg24_2000', where = activity_working_types_who_year_recast)) arg24_2000 else 0,
																								activity_description_change_2001_count 		= if (exists('arg24_2001', where = activity_working_types_who_year_recast)) arg24_2001 else 0,
																								activity_description_change_2002_count 		= if (exists('arg24_2002', where = activity_working_types_who_year_recast)) arg24_2002 else 0,
																								activity_description_change_2003_count 		= if (exists('arg24_2003', where = activity_working_types_who_year_recast)) arg24_2003 else 0,
																								activity_description_change_2004_count 		= if (exists('arg24_2004', where = activity_working_types_who_year_recast)) arg24_2004 else 0,
																								activity_description_change_2005_count 		= if (exists('arg24_2005', where = activity_working_types_who_year_recast)) arg24_2005 else 0,
																								activity_description_change_2006_count 		= if (exists('arg24_2006', where = activity_working_types_who_year_recast)) arg24_2006 else 0,
																								activity_description_change_2007_count 		= if (exists('arg24_2007', where = activity_working_types_who_year_recast)) arg24_2007 else 0,
																								activity_description_change_2008_count 		= if (exists('arg24_2008', where = activity_working_types_who_year_recast)) arg24_2008 else 0,
																								activity_description_change_2009_count 		= if (exists('arg24_2009', where = activity_working_types_who_year_recast)) arg24_2009 else 0,
																								activity_description_change_2010_count 		= if (exists('arg24_2010', where = activity_working_types_who_year_recast)) arg24_2010 else 0,
																								activity_description_change_2011_count 		= if (exists('arg24_2011', where = activity_working_types_who_year_recast)) arg24_2011 else 0,
																								activity_description_change_2012_count 		= if (exists('arg24_2012', where = activity_working_types_who_year_recast)) arg24_2012 else 0,
																								activity_description_change_2013_count 		= if (exists('arg24_2013', where = activity_working_types_who_year_recast)) arg24_2013 else 0,
																								activity_priority_change_1998_count 			= if (exists('arg32_1998', where = activity_working_types_who_year_recast)) arg32_1998 else 0,
																								activity_priority_change_1999_count 			= if (exists('arg32_1999', where = activity_working_types_who_year_recast)) arg32_1999 else 0,
																								activity_priority_change_2000_count 			= if (exists('arg32_2000', where = activity_working_types_who_year_recast)) arg32_2000 else 0,
																								activity_priority_change_2001_count 			= if (exists('arg32_2001', where = activity_working_types_who_year_recast)) arg32_2001 else 0,
																								activity_priority_change_2002_count 			= if (exists('arg32_2002', where = activity_working_types_who_year_recast)) arg32_2002 else 0,
																								activity_priority_change_2003_count 			= if (exists('arg32_2003', where = activity_working_types_who_year_recast)) arg32_2003 else 0,
																								activity_priority_change_2004_count 			= if (exists('arg32_2004', where = activity_working_types_who_year_recast)) arg32_2004 else 0,
																								activity_priority_change_2005_count 			= if (exists('arg32_2005', where = activity_working_types_who_year_recast)) arg32_2005 else 0,
																								activity_priority_change_2006_count 			= if (exists('arg32_2006', where = activity_working_types_who_year_recast)) arg32_2006 else 0,
																								activity_priority_change_2007_count 			= if (exists('arg32_2007', where = activity_working_types_who_year_recast)) arg32_2007 else 0,
																								activity_priority_change_2008_count 			= if (exists('arg32_2008', where = activity_working_types_who_year_recast)) arg32_2008 else 0,
																								activity_priority_change_2009_count 			= if (exists('arg32_2009', where = activity_working_types_who_year_recast)) arg32_2009 else 0,
																								activity_priority_change_2010_count 			= if (exists('arg32_2010', where = activity_working_types_who_year_recast)) arg32_2010 else 0,
																								activity_priority_change_2011_count 			= if (exists('arg32_2011', where = activity_working_types_who_year_recast)) arg32_2011 else 0,
																								activity_priority_change_2012_count 			= if (exists('arg32_2012', where = activity_working_types_who_year_recast)) arg32_2012 else 0,
																								activity_priority_change_2013_count 			= if (exists('arg32_2013', where = activity_working_types_who_year_recast)) arg32_2013 else 0,
																								activity_severity_change_1998_count 			= if (exists('arg31_1998', where = activity_working_types_who_year_recast)) arg31_1998 else 0,
																								activity_severity_change_1999_count 			= if (exists('arg31_1999', where = activity_working_types_who_year_recast)) arg31_1999 else 0,
																								activity_severity_change_2000_count 			= if (exists('arg31_2000', where = activity_working_types_who_year_recast)) arg31_2000 else 0,
																								activity_severity_change_2001_count 			= if (exists('arg31_2001', where = activity_working_types_who_year_recast)) arg31_2001 else 0,
																								activity_severity_change_2002_count 			= if (exists('arg31_2002', where = activity_working_types_who_year_recast)) arg31_2002 else 0,
																								activity_severity_change_2003_count 			= if (exists('arg31_2003', where = activity_working_types_who_year_recast)) arg31_2003 else 0,
																								activity_severity_change_2004_count 			= if (exists('arg31_2004', where = activity_working_types_who_year_recast)) arg31_2004 else 0,
																								activity_severity_change_2005_count 			= if (exists('arg31_2005', where = activity_working_types_who_year_recast)) arg31_2005 else 0,
																								activity_severity_change_2006_count 			= if (exists('arg31_2006', where = activity_working_types_who_year_recast)) arg31_2006 else 0,
																								activity_severity_change_2007_count 			= if (exists('arg31_2007', where = activity_working_types_who_year_recast)) arg31_2007 else 0,
																								activity_severity_change_2008_count 			= if (exists('arg31_2008', where = activity_working_types_who_year_recast)) arg31_2008 else 0,
																								activity_severity_change_2009_count 			= if (exists('arg31_2009', where = activity_working_types_who_year_recast)) arg31_2009 else 0,
																								activity_severity_change_2010_count 			= if (exists('arg31_2010', where = activity_working_types_who_year_recast)) arg31_2010 else 0,
																								activity_severity_change_2011_count 			= if (exists('arg31_2011', where = activity_working_types_who_year_recast)) arg31_2011 else 0,
																								activity_severity_change_2012_count 			= if (exists('arg31_2012', where = activity_working_types_who_year_recast)) arg31_2012 else 0,
																								activity_severity_change_2013_count 			= if (exists('arg31_2013', where = activity_working_types_who_year_recast)) arg31_2013 else 0);
																								
																								
activity_working_types_who_year_recast <- mutate(activity_working_types_who_year_recast, 
												activity_cc_change_all_count				= 	activity_cc_change_1998_count +
																									activity_cc_change_1999_count +
																									activity_cc_change_2000_count +
																									activity_cc_change_2001_count +
																									activity_cc_change_2002_count +
																									activity_cc_change_2003_count +
																									activity_cc_change_2004_count +
																									activity_cc_change_2005_count +
																									activity_cc_change_2006_count +
																									activity_cc_change_2007_count +
																									activity_cc_change_2008_count +
																									activity_cc_change_2009_count +
																									activity_cc_change_2010_count +
																									activity_cc_change_2011_count +
																									activity_cc_change_2012_count +
																									activity_cc_change_2013_count,

												activity_keywords_change_all_count			= 	activity_keywords_change_1998_count +
																									activity_keywords_change_1999_count +
																									activity_keywords_change_2000_count +
																									activity_keywords_change_2001_count +
																									activity_keywords_change_2002_count +
																									activity_keywords_change_2003_count +
																									activity_keywords_change_2004_count +
																									activity_keywords_change_2005_count +
																									activity_keywords_change_2006_count +
																									activity_keywords_change_2007_count +
																									activity_keywords_change_2008_count +
																									activity_keywords_change_2009_count +
																									activity_keywords_change_2010_count +
																									activity_keywords_change_2011_count +
																									activity_keywords_change_2012_count +
																									activity_keywords_change_2013_count,

												activity_product_change_all_count			= 	activity_product_change_1998_count  +
																									activity_product_change_1999_count +
																									activity_product_change_2000_count +
																									activity_product_change_2001_count +
																									activity_product_change_2002_count +
																									activity_product_change_2003_count +
																									activity_product_change_2004_count +
																									activity_product_change_2005_count +
																									activity_product_change_2006_count +
																									activity_product_change_2007_count +
																									activity_product_change_2008_count +
																									activity_product_change_2009_count +
																									activity_product_change_2010_count +
																									activity_product_change_2011_count +
																									activity_product_change_2012_count +
																									activity_product_change_2013_count,

												activity_component_change_all_count		= 	activity_component_change_1998_count +
																									activity_component_change_1999_count +
																									activity_component_change_2000_count +
																									activity_component_change_2001_count +
																									activity_component_change_2002_count +
																									activity_component_change_2003_count +
																									activity_component_change_2004_count +
																									activity_component_change_2005_count +
																									activity_component_change_2006_count +
																									activity_component_change_2007_count +
																									activity_component_change_2008_count +
																									activity_component_change_2009_count +
																									activity_component_change_2010_count +
																									activity_component_change_2011_count +
																									activity_component_change_2012_count +
																									activity_component_change_2013_count,

												activity_status_change_all_count			= 	activity_status_change_1998_count +
																									activity_status_change_1999_count +
																									activity_status_change_2000_count +
																									activity_status_change_2001_count +
																									activity_status_change_2002_count +
																									activity_status_change_2003_count +
																									activity_status_change_2004_count +
																									activity_status_change_2005_count +
																									activity_status_change_2006_count +
																									activity_status_change_2007_count +
																									activity_status_change_2008_count +
																									activity_status_change_2009_count +
																									activity_status_change_2010_count +
																									activity_status_change_2011_count +
																									activity_status_change_2012_count +
																									activity_status_change_2013_count,

												activity_resolution_change_all_count		= 	activity_resolution_change_1998_count +
																									activity_resolution_change_1999_count +
																									activity_resolution_change_2000_count +
																									activity_resolution_change_2001_count +
																									activity_resolution_change_2002_count +
																									activity_resolution_change_2003_count +
																									activity_resolution_change_2004_count +
																									activity_resolution_change_2005_count +
																									activity_resolution_change_2006_count +
																									activity_resolution_change_2007_count +
																									activity_resolution_change_2008_count +
																									activity_resolution_change_2009_count +
																									activity_resolution_change_2010_count +
																									activity_resolution_change_2011_count +
																									activity_resolution_change_2012_count +
																									activity_resolution_change_2013_count,
																									

												activity_flags_change_all_count			= 	activity_flags_change_1998_count +
																									activity_flags_change_1999_count +
																									activity_flags_change_2000_count +
																									activity_flags_change_2001_count +
																									activity_flags_change_2002_count +
																									activity_flags_change_2003_count +
																									activity_flags_change_2004_count +
																									activity_flags_change_2005_count +
																									activity_flags_change_2006_count +
																									activity_flags_change_2007_count +
																									activity_flags_change_2008_count +
																									activity_flags_change_2009_count +
																									activity_flags_change_2010_count +
																									activity_flags_change_2011_count +
																									activity_flags_change_2012_count +
																									activity_flags_change_2013_count,

												activity_whiteboard_change_all_count		= 	activity_whiteboard_change_1998_count +
																									activity_whiteboard_change_1999_count +
																									activity_whiteboard_change_2000_count +
																									activity_whiteboard_change_2001_count +
																									activity_whiteboard_change_2002_count +
																									activity_whiteboard_change_2003_count +
																									activity_whiteboard_change_2004_count +
																									activity_whiteboard_change_2005_count +
																									activity_whiteboard_change_2006_count +
																									activity_whiteboard_change_2007_count +
																									activity_whiteboard_change_2008_count +
																									activity_whiteboard_change_2009_count +
																									activity_whiteboard_change_2010_count +
																									activity_whiteboard_change_2011_count +
																									activity_whiteboard_change_2012_count +
																									activity_whiteboard_change_2013_count,

												activity_target_milestone_change_all_count	= 	activity_target_milestone_change_1998_count +
																									activity_target_milestone_change_1999_count +
																									activity_target_milestone_change_2000_count +
																									activity_target_milestone_change_2001_count +
																									activity_target_milestone_change_2002_count +
																									activity_target_milestone_change_2003_count +
																									activity_target_milestone_change_2004_count +
																									activity_target_milestone_change_2005_count +
																									activity_target_milestone_change_2006_count +
																									activity_target_milestone_change_2007_count +
																									activity_target_milestone_change_2008_count +
																									activity_target_milestone_change_2009_count +
																									activity_target_milestone_change_2010_count +
																									activity_target_milestone_change_2011_count +
																									activity_target_milestone_change_2012_count +
																									activity_target_milestone_change_2013_count,

												activity_description_change_all_count		= 	activity_description_change_1998_count +
																									activity_description_change_1999_count +
																									activity_description_change_2000_count +
																									activity_description_change_2001_count +
																									activity_description_change_2002_count +
																									activity_description_change_2003_count +
																									activity_description_change_2004_count +
																									activity_description_change_2005_count +
																									activity_description_change_2006_count +
																									activity_description_change_2007_count +
																									activity_description_change_2008_count +
																									activity_description_change_2009_count +
																									activity_description_change_2010_count +
																									activity_description_change_2011_count +
																									activity_description_change_2012_count +
																									activity_description_change_2013_count,

												activity_priority_change_all_count			= 	activity_priority_change_1998_count +
																									activity_priority_change_1999_count +
																									activity_priority_change_2000_count +
																									activity_priority_change_2001_count +
																									activity_priority_change_2002_count +
																									activity_priority_change_2003_count +
																									activity_priority_change_2004_count +
																									activity_priority_change_2005_count +
																									activity_priority_change_2006_count +
																									activity_priority_change_2007_count +
																									activity_priority_change_2008_count +
																									activity_priority_change_2009_count +
																									activity_priority_change_2010_count +
																									activity_priority_change_2011_count +
																									activity_priority_change_2012_count +
																									activity_priority_change_2013_count,

												activity_severity_change_all_count			= 	activity_severity_change_1998_count +
																									activity_severity_change_1999_count +
																									activity_severity_change_2000_count +
																									activity_severity_change_2001_count +
																									activity_severity_change_2002_count +
																									activity_severity_change_2003_count +
																									activity_severity_change_2004_count +
																									activity_severity_change_2005_count +
																									activity_severity_change_2006_count +
																									activity_severity_change_2007_count +
																									activity_severity_change_2008_count +
																									activity_severity_change_2009_count +
																									activity_severity_change_2010_count +
																									activity_severity_change_2011_count +
																									activity_severity_change_2012_count +
																									activity_severity_change_2013_count); 


# Merge the activity_working_types_who_year_recast and profiles_working tables based on who to add the activity type count columns
setkey(activity_working_types_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_working_types_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# Any NA entries mean that that user has no activity of that type and/or year so set it to 0
profiles_working <- mutate(profiles_working, activity_cc_change_1998_count					= safe_ifelse(is.na(activity_cc_change_1998_count),				0, activity_cc_change_1998_count), 	
											 activity_cc_change_1999_count					= safe_ifelse(is.na(activity_cc_change_1999_count),				0, activity_cc_change_1999_count),
											 activity_cc_change_2000_count					= safe_ifelse(is.na(activity_cc_change_2000_count),				0, activity_cc_change_2000_count),
											 activity_cc_change_2001_count					= safe_ifelse(is.na(activity_cc_change_2001_count),				0, activity_cc_change_2001_count),
											 activity_cc_change_2002_count					= safe_ifelse(is.na(activity_cc_change_2002_count),				0, activity_cc_change_2002_count),
											 activity_cc_change_2003_count					= safe_ifelse(is.na(activity_cc_change_2003_count),				0, activity_cc_change_2003_count),
											 activity_cc_change_2004_count					= safe_ifelse(is.na(activity_cc_change_2004_count),				0, activity_cc_change_2004_count),
											 activity_cc_change_2005_count					= safe_ifelse(is.na(activity_cc_change_2005_count),				0, activity_cc_change_2005_count),
											 activity_cc_change_2006_count					= safe_ifelse(is.na(activity_cc_change_2006_count),				0, activity_cc_change_2006_count),
											 activity_cc_change_2007_count					= safe_ifelse(is.na(activity_cc_change_2007_count),				0, activity_cc_change_2007_count),
											 activity_cc_change_2008_count					= safe_ifelse(is.na(activity_cc_change_2008_count),				0, activity_cc_change_2008_count),
											 activity_cc_change_2009_count					= safe_ifelse(is.na(activity_cc_change_2009_count),				0, activity_cc_change_2009_count),		
											 activity_cc_change_2010_count					= safe_ifelse(is.na(activity_cc_change_2010_count),				0, activity_cc_change_2010_count), 	
											 activity_cc_change_2011_count                 = safe_ifelse(is.na(activity_cc_change_2011_count),				0, activity_cc_change_2011_count),
	                                         activity_cc_change_2012_count                 = safe_ifelse(is.na(activity_cc_change_2012_count),				0, activity_cc_change_2012_count),
	                                         activity_cc_change_2013_count                 = safe_ifelse(is.na(activity_cc_change_2013_count),				0, activity_cc_change_2013_count),
	                                         activity_cc_change_all_count                  = safe_ifelse(is.na(activity_cc_change_all_count), 				0, activity_cc_change_all_count),
	                                         activity_keywords_change_1998_count           = safe_ifelse(is.na(activity_keywords_change_1998_count),			0, activity_keywords_change_1998_count),
	                                         activity_keywords_change_1999_count           = safe_ifelse(is.na(activity_keywords_change_1999_count),			0, activity_keywords_change_1999_count),
	                                         activity_keywords_change_2000_count           = safe_ifelse(is.na(activity_keywords_change_2000_count),			0, activity_keywords_change_2000_count),
	                                         activity_keywords_change_2001_count           = safe_ifelse(is.na(activity_keywords_change_2001_count),			0, activity_keywords_change_2001_count),
	                                         activity_keywords_change_2002_count           = safe_ifelse(is.na(activity_keywords_change_2002_count),			0, activity_keywords_change_2002_count),
	                                         activity_keywords_change_2003_count           = safe_ifelse(is.na(activity_keywords_change_2003_count),			0, activity_keywords_change_2003_count),
	                                         activity_keywords_change_2004_count           = safe_ifelse(is.na(activity_keywords_change_2004_count),			0, activity_keywords_change_2004_count),		
	                                         activity_keywords_change_2005_count			= safe_ifelse(is.na(activity_keywords_change_2005_count),			0, activity_keywords_change_2005_count), 	
	                                         activity_keywords_change_2006_count           = safe_ifelse(is.na(activity_keywords_change_2006_count),			0, activity_keywords_change_2006_count),
	                                         activity_keywords_change_2007_count           = safe_ifelse(is.na(activity_keywords_change_2007_count),			0, activity_keywords_change_2007_count),
	                                         activity_keywords_change_2008_count           = safe_ifelse(is.na(activity_keywords_change_2008_count),			0, activity_keywords_change_2008_count),
	                                         activity_keywords_change_2009_count           = safe_ifelse(is.na(activity_keywords_change_2009_count),			0, activity_keywords_change_2009_count),
	                                         activity_keywords_change_2010_count           = safe_ifelse(is.na(activity_keywords_change_2010_count),			0, activity_keywords_change_2010_count),
	                                         activity_keywords_change_2011_count           = safe_ifelse(is.na(activity_keywords_change_2011_count),			0, activity_keywords_change_2011_count),
	                                         activity_keywords_change_2012_count           = safe_ifelse(is.na(activity_keywords_change_2012_count),			0, activity_keywords_change_2012_count),
	                                         activity_keywords_change_2013_count           = safe_ifelse(is.na(activity_keywords_change_2013_count),			0, activity_keywords_change_2013_count),
	                                         activity_keywords_change_all_count            = safe_ifelse(is.na(activity_keywords_change_all_count), 			0, activity_keywords_change_all_count),
	                                         activity_product_change_1998_count            = safe_ifelse(is.na(activity_product_change_1998_count), 			0, activity_product_change_1998_count),
	                                         activity_product_change_1999_count            = safe_ifelse(is.na(activity_product_change_1999_count), 			0, activity_product_change_1999_count),		
	                                         activity_product_change_2000_count			= safe_ifelse(is.na(activity_product_change_2000_count), 			0, activity_product_change_2000_count), 	
	                                         activity_product_change_2001_count            = safe_ifelse(is.na(activity_product_change_2001_count), 			0, activity_product_change_2001_count),
	                                         activity_product_change_2002_count            = safe_ifelse(is.na(activity_product_change_2002_count), 			0, activity_product_change_2002_count),
	                                         activity_product_change_2003_count            = safe_ifelse(is.na(activity_product_change_2003_count), 			0, activity_product_change_2003_count),
	                                         activity_product_change_2004_count            = safe_ifelse(is.na(activity_product_change_2004_count), 			0, activity_product_change_2004_count),
	                                         activity_product_change_2005_count            = safe_ifelse(is.na(activity_product_change_2005_count), 			0, activity_product_change_2005_count),
	                                         activity_product_change_2006_count            = safe_ifelse(is.na(activity_product_change_2006_count), 			0, activity_product_change_2006_count),
	                                         activity_product_change_2007_count            = safe_ifelse(is.na(activity_product_change_2007_count), 			0, activity_product_change_2007_count),
	                                         activity_product_change_2008_count            = safe_ifelse(is.na(activity_product_change_2008_count),			0, activity_product_change_2008_count),
	                                         activity_product_change_2009_count            = safe_ifelse(is.na(activity_product_change_2009_count), 			0, activity_product_change_2009_count),
	                                         activity_product_change_2010_count            = safe_ifelse(is.na(activity_product_change_2010_count), 			0, activity_product_change_2010_count),
	                                         activity_product_change_2011_count            = safe_ifelse(is.na(activity_product_change_2011_count), 			0, activity_product_change_2011_count),		
	                                         activity_product_change_2012_count			= safe_ifelse(is.na(activity_product_change_2012_count), 			0, activity_product_change_2012_count),
	                                         activity_product_change_2013_count            = safe_ifelse(is.na(activity_product_change_2013_count), 			0, activity_product_change_2013_count),
	                                         activity_product_change_all_count             = safe_ifelse(is.na(activity_product_change_all_count), 			0, activity_product_change_all_count),
	                                         activity_component_change_1998_count          = safe_ifelse(is.na(activity_component_change_1998_count), 		0, activity_component_change_1998_count),
	                                         activity_component_change_1999_count          = safe_ifelse(is.na(activity_component_change_1999_count), 		0, activity_component_change_1999_count),
	                                         activity_component_change_2000_count          = safe_ifelse(is.na(activity_component_change_2000_count), 		0, activity_component_change_2000_count),
	                                         activity_component_change_2001_count          = safe_ifelse(is.na(activity_component_change_2001_count), 		0, activity_component_change_2001_count),
	                                         activity_component_change_2002_count          = safe_ifelse(is.na(activity_component_change_2002_count), 		0, activity_component_change_2002_count),
	                                         activity_component_change_2003_count          = safe_ifelse(is.na(activity_component_change_2003_count),			0, activity_component_change_2003_count),
	                                         activity_component_change_2004_count          = safe_ifelse(is.na(activity_component_change_2004_count), 		0, activity_component_change_2004_count),
	                                         activity_component_change_2005_count          = safe_ifelse(is.na(activity_component_change_2005_count), 		0, activity_component_change_2005_count),
	                                         activity_component_change_2006_count          = safe_ifelse(is.na(activity_component_change_2006_count), 		0, activity_component_change_2006_count),
	                                         activity_component_change_2007_count          = safe_ifelse(is.na(activity_component_change_2007_count), 		0, activity_component_change_2007_count),
	                                         activity_component_change_2008_count          = safe_ifelse(is.na(activity_component_change_2008_count), 		0, activity_component_change_2008_count),
	                                         activity_component_change_2009_count          = safe_ifelse(is.na(activity_component_change_2009_count), 		0, activity_component_change_2009_count),
	                                         activity_component_change_2010_count          = safe_ifelse(is.na(activity_component_change_2010_count), 		0, activity_component_change_2010_count),
	                                         activity_component_change_2011_count          = safe_ifelse(is.na(activity_component_change_2011_count), 		0, activity_component_change_2011_count),
	                                         activity_component_change_2012_count          = safe_ifelse(is.na(activity_component_change_2012_count), 		0, activity_component_change_2012_count),
	                                         activity_component_change_2013_count          = safe_ifelse(is.na(activity_component_change_2013_count), 		0, activity_component_change_2013_count),
	                                         activity_component_change_all_count           = safe_ifelse(is.na(activity_component_change_all_count), 			0, activity_component_change_all_count),
	                                         activity_status_change_1998_count             = safe_ifelse(is.na(activity_status_change_1998_count),			0, activity_status_change_1998_count),
	                                         activity_status_change_1999_count             = safe_ifelse(is.na(activity_status_change_1999_count), 			0, activity_status_change_1999_count),
	                                         activity_status_change_2000_count             = safe_ifelse(is.na(activity_status_change_2000_count), 			0, activity_status_change_2000_count),
	                                         activity_status_change_2001_count             = safe_ifelse(is.na(activity_status_change_2001_count), 			0, activity_status_change_2001_count),
	                                         activity_status_change_2002_count             = safe_ifelse(is.na(activity_status_change_2002_count), 			0, activity_status_change_2002_count),
	                                         activity_status_change_2003_count             = safe_ifelse(is.na(activity_status_change_2003_count), 			0, activity_status_change_2003_count),
	                                         activity_status_change_2004_count             = safe_ifelse(is.na(activity_status_change_2004_count), 			0, activity_status_change_2004_count),
	                                         activity_status_change_2005_count             = safe_ifelse(is.na(activity_status_change_2005_count), 			0, activity_status_change_2005_count),
	                                         activity_status_change_2006_count             = safe_ifelse(is.na(activity_status_change_2006_count), 			0, activity_status_change_2006_count),
	                                         activity_status_change_2007_count             = safe_ifelse(is.na(activity_status_change_2007_count), 			0, activity_status_change_2007_count),
	                                         activity_status_change_2008_count             = safe_ifelse(is.na(activity_status_change_2008_count), 			0, activity_status_change_2008_count),
	                                         activity_status_change_2009_count             = safe_ifelse(is.na(activity_status_change_2009_count), 			0, activity_status_change_2009_count),
	                                         activity_status_change_2010_count             = safe_ifelse(is.na(activity_status_change_2010_count),			0, activity_status_change_2010_count),
	                                         activity_status_change_2011_count             = safe_ifelse(is.na(activity_status_change_2011_count), 			0, activity_status_change_2011_count),
	                                         activity_status_change_2012_count             = safe_ifelse(is.na(activity_status_change_2012_count), 			0, activity_status_change_2012_count),
	                                         activity_status_change_2013_count             = safe_ifelse(is.na(activity_status_change_2013_count), 			0, activity_status_change_2013_count),
	                                         activity_status_change_all_count              = safe_ifelse(is.na(activity_status_change_all_count), 			0, activity_status_change_all_count),
	                                         activity_resolution_change_1998_count         = safe_ifelse(is.na(activity_resolution_change_1998_count),		0, activity_resolution_change_1998_count),
	                                         activity_resolution_change_1999_count         = safe_ifelse(is.na(activity_resolution_change_1999_count),		0, activity_resolution_change_1999_count),
	                                         activity_resolution_change_2000_count         = safe_ifelse(is.na(activity_resolution_change_2000_count),		0, activity_resolution_change_2000_count),
	                                         activity_resolution_change_2001_count         = safe_ifelse(is.na(activity_resolution_change_2001_count),		0, activity_resolution_change_2001_count),
	                                         activity_resolution_change_2002_count         = safe_ifelse(is.na(activity_resolution_change_2002_count),		0, activity_resolution_change_2002_count),
	                                         activity_resolution_change_2003_count         = safe_ifelse(is.na(activity_resolution_change_2003_count),		0, activity_resolution_change_2003_count),
	                                         activity_resolution_change_2004_count         = safe_ifelse(is.na(activity_resolution_change_2004_count),		0, activity_resolution_change_2004_count),
	                                         activity_resolution_change_2005_count         = safe_ifelse(is.na(activity_resolution_change_2005_count),		0, activity_resolution_change_2005_count),
	                                         activity_resolution_change_2006_count         = safe_ifelse(is.na(activity_resolution_change_2006_count),		0, activity_resolution_change_2006_count),
	                                         activity_resolution_change_2007_count         = safe_ifelse(is.na(activity_resolution_change_2007_count),		0, activity_resolution_change_2007_count),
	                                         activity_resolution_change_2008_count         = safe_ifelse(is.na(activity_resolution_change_2008_count),		0, activity_resolution_change_2008_count),
	                                         activity_resolution_change_2009_count			= safe_ifelse(is.na(activity_resolution_change_2009_count),		0, activity_resolution_change_2009_count),
	                                         activity_resolution_change_2010_count         = safe_ifelse(is.na(activity_resolution_change_2010_count),		0, activity_resolution_change_2010_count),
	                                         activity_resolution_change_2011_count         = safe_ifelse(is.na(activity_resolution_change_2011_count),		0, activity_resolution_change_2011_count),
	                                         activity_resolution_change_2012_count         = safe_ifelse(is.na(activity_resolution_change_2012_count),		0, activity_resolution_change_2012_count),
	                                         activity_resolution_change_2013_count         = safe_ifelse(is.na(activity_resolution_change_2013_count),		0, activity_resolution_change_2013_count),
	                                         activity_resolution_change_all_count          = safe_ifelse(is.na(activity_resolution_change_all_count), 		0, activity_resolution_change_all_count),
	                                         activity_flags_change_1998_count              = safe_ifelse(is.na(activity_flags_change_1998_count), 			0, activity_flags_change_1998_count),
	                                         activity_flags_change_1999_count              = safe_ifelse(is.na(activity_flags_change_1999_count), 			0, activity_flags_change_1999_count),
	                                         activity_flags_change_2000_count              = safe_ifelse(is.na(activity_flags_change_2000_count),				0, activity_flags_change_2000_count),
	                                         activity_flags_change_2001_count              = safe_ifelse(is.na(activity_flags_change_2001_count), 			0, activity_flags_change_2001_count),
	                                         activity_flags_change_2002_count              = safe_ifelse(is.na(activity_flags_change_2002_count), 			0, activity_flags_change_2002_count),
	                                         activity_flags_change_2003_count              = safe_ifelse(is.na(activity_flags_change_2003_count), 			0, activity_flags_change_2003_count),
	                                         activity_flags_change_2004_count              = safe_ifelse(is.na(activity_flags_change_2004_count), 			0, activity_flags_change_2004_count),
	                                         activity_flags_change_2005_count              = safe_ifelse(is.na(activity_flags_change_2005_count), 			0, activity_flags_change_2005_count),
	                                         activity_flags_change_2006_count              = safe_ifelse(is.na(activity_flags_change_2006_count), 			0, activity_flags_change_2006_count),
	                                         activity_flags_change_2007_count              = safe_ifelse(is.na(activity_flags_change_2007_count), 			0, activity_flags_change_2007_count),
	                                         activity_flags_change_2008_count              = safe_ifelse(is.na(activity_flags_change_2008_count), 			0, activity_flags_change_2008_count),
	                                         activity_flags_change_2009_count              = safe_ifelse(is.na(activity_flags_change_2009_count), 			0, activity_flags_change_2009_count),
	                                         activity_flags_change_2010_count              = safe_ifelse(is.na(activity_flags_change_2010_count), 			0, activity_flags_change_2010_count),
	                                         activity_flags_change_2011_count              = safe_ifelse(is.na(activity_flags_change_2011_count), 			0, activity_flags_change_2011_count),
	                                         activity_flags_change_2012_count              = safe_ifelse(is.na(activity_flags_change_2012_count),				0, activity_flags_change_2012_count),
	                                         activity_flags_change_2013_count              = safe_ifelse(is.na(activity_flags_change_2013_count), 			0, activity_flags_change_2013_count),
	                                         activity_flags_change_all_count               = safe_ifelse(is.na(activity_flags_change_all_count), 				0, activity_flags_change_all_count),
	                                         activity_whiteboard_change_1998_count         = safe_ifelse(is.na(activity_whiteboard_change_1998_count),		0, activity_whiteboard_change_1998_count),
	                                         activity_whiteboard_change_1999_count         = safe_ifelse(is.na(activity_whiteboard_change_1999_count),		0, activity_whiteboard_change_1999_count),
	                                         activity_whiteboard_change_2000_count         = safe_ifelse(is.na(activity_whiteboard_change_2000_count),		0, activity_whiteboard_change_2000_count),
	                                         activity_whiteboard_change_2001_count         = safe_ifelse(is.na(activity_whiteboard_change_2001_count),		0, activity_whiteboard_change_2001_count),
	                                         activity_whiteboard_change_2002_count         = safe_ifelse(is.na(activity_whiteboard_change_2002_count),		0, activity_whiteboard_change_2002_count),
	                                         activity_whiteboard_change_2003_count         = safe_ifelse(is.na(activity_whiteboard_change_2003_count),		0, activity_whiteboard_change_2003_count),
	                                         activity_whiteboard_change_2004_count         = safe_ifelse(is.na(activity_whiteboard_change_2004_count),		0, activity_whiteboard_change_2004_count),
	                                         activity_whiteboard_change_2005_count         = safe_ifelse(is.na(activity_whiteboard_change_2005_count),		0, activity_whiteboard_change_2005_count),
	                                         activity_whiteboard_change_2006_count         = safe_ifelse(is.na(activity_whiteboard_change_2006_count),		0, activity_whiteboard_change_2006_count),
	                                         activity_whiteboard_change_2007_count         = safe_ifelse(is.na(activity_whiteboard_change_2007_count),		0, activity_whiteboard_change_2007_count),
	                                         activity_whiteboard_change_2008_count         = safe_ifelse(is.na(activity_whiteboard_change_2008_count),		0, activity_whiteboard_change_2008_count),
	                                         activity_whiteboard_change_2009_count         = safe_ifelse(is.na(activity_whiteboard_change_2009_count),		0, activity_whiteboard_change_2009_count),
	                                         activity_whiteboard_change_2010_count         = safe_ifelse(is.na(activity_whiteboard_change_2010_count),		0, activity_whiteboard_change_2010_count),
	                                         activity_whiteboard_change_2011_count         = safe_ifelse(is.na(activity_whiteboard_change_2011_count),		0, activity_whiteboard_change_2011_count),
	                                         activity_whiteboard_change_2012_count         = safe_ifelse(is.na(activity_whiteboard_change_2012_count),		0, activity_whiteboard_change_2012_count),
	                                         activity_whiteboard_change_2013_count         = safe_ifelse(is.na(activity_whiteboard_change_2013_count),		0, activity_whiteboard_change_2013_count),
	                                         activity_whiteboard_change_all_count          = safe_ifelse(is.na(activity_whiteboard_change_all_count), 		0, activity_whiteboard_change_all_count),
	                                         activity_target_milestone_change_1998_count   = safe_ifelse(is.na(activity_target_milestone_change_1998_count), 	0, activity_target_milestone_change_1998_count),
	                                         activity_target_milestone_change_1999_count   = safe_ifelse(is.na(activity_target_milestone_change_1999_count), 	0, activity_target_milestone_change_1999_count),
	                                         activity_target_milestone_change_2000_count   = safe_ifelse(is.na(activity_target_milestone_change_2000_count), 	0, activity_target_milestone_change_2000_count),
	                                         activity_target_milestone_change_2001_count   = safe_ifelse(is.na(activity_target_milestone_change_2001_count), 	0, activity_target_milestone_change_2001_count),
	                                         activity_target_milestone_change_2002_count   = safe_ifelse(is.na(activity_target_milestone_change_2002_count),	0, activity_target_milestone_change_2002_count),
	                                         activity_target_milestone_change_2003_count   = safe_ifelse(is.na(activity_target_milestone_change_2003_count), 	0, activity_target_milestone_change_2003_count),
	                                         activity_target_milestone_change_2004_count   = safe_ifelse(is.na(activity_target_milestone_change_2004_count), 	0, activity_target_milestone_change_2004_count),
	                                         activity_target_milestone_change_2005_count   = safe_ifelse(is.na(activity_target_milestone_change_2005_count), 	0, activity_target_milestone_change_2005_count),
	                                         activity_target_milestone_change_2006_count	= safe_ifelse(is.na(activity_target_milestone_change_2006_count), 	0, activity_target_milestone_change_2006_count),
	                                         activity_target_milestone_change_2007_count   = safe_ifelse(is.na(activity_target_milestone_change_2007_count), 	0, activity_target_milestone_change_2007_count),
	                                         activity_target_milestone_change_2008_count   = safe_ifelse(is.na(activity_target_milestone_change_2008_count), 	0, activity_target_milestone_change_2008_count),
	                                         activity_target_milestone_change_2009_count   = safe_ifelse(is.na(activity_target_milestone_change_2009_count), 	0, activity_target_milestone_change_2009_count),
	                                         activity_target_milestone_change_2010_count   = safe_ifelse(is.na(activity_target_milestone_change_2010_count), 	0, activity_target_milestone_change_2010_count),
	                                         activity_target_milestone_change_2011_count   = safe_ifelse(is.na(activity_target_milestone_change_2011_count), 	0, activity_target_milestone_change_2011_count),
	                                         activity_target_milestone_change_2012_count   = safe_ifelse(is.na(activity_target_milestone_change_2012_count), 	0, activity_target_milestone_change_2012_count),
	                                         activity_target_milestone_change_2013_count   = safe_ifelse(is.na(activity_target_milestone_change_2013_count), 	0, activity_target_milestone_change_2013_count),
	                                         activity_target_milestone_change_all_count    = safe_ifelse(is.na(activity_target_milestone_change_all_count),	0, activity_target_milestone_change_all_count),
	                                         activity_description_change_1998_count        = safe_ifelse(is.na(activity_description_change_1998_count), 		0, activity_description_change_1998_count),
	                                         activity_description_change_1999_count        = safe_ifelse(is.na(activity_description_change_1999_count), 		0, activity_description_change_1999_count),
	                                         activity_description_change_2000_count        = safe_ifelse(is.na(activity_description_change_2000_count), 		0, activity_description_change_2000_count),
	                                         activity_description_change_2001_count        = safe_ifelse(is.na(activity_description_change_2001_count), 		0, activity_description_change_2001_count),
	                                         activity_description_change_2002_count        = safe_ifelse(is.na(activity_description_change_2002_count), 		0, activity_description_change_2002_count),
	                                         activity_description_change_2003_count        = safe_ifelse(is.na(activity_description_change_2003_count), 		0, activity_description_change_2003_count),
	                                         activity_description_change_2004_count        = safe_ifelse(is.na(activity_description_change_2004_count), 		0, activity_description_change_2004_count),
	                                         activity_description_change_2005_count        = safe_ifelse(is.na(activity_description_change_2005_count), 		0, activity_description_change_2005_count),
	                                         activity_description_change_2006_count        = safe_ifelse(is.na(activity_description_change_2006_count), 		0, activity_description_change_2006_count),
	                                         activity_description_change_2007_count        = safe_ifelse(is.na(activity_description_change_2007_count), 		0, activity_description_change_2007_count),
	                                         activity_description_change_2008_count        = safe_ifelse(is.na(activity_description_change_2008_count), 		0, activity_description_change_2008_count),
	                                         activity_description_change_2009_count        = safe_ifelse(is.na(activity_description_change_2009_count),		0, activity_description_change_2009_count),
	                                         activity_description_change_2010_count        = safe_ifelse(is.na(activity_description_change_2010_count), 		0, activity_description_change_2010_count),
	                                         activity_description_change_2011_count        = safe_ifelse(is.na(activity_description_change_2011_count), 		0, activity_description_change_2011_count),
	                                         activity_description_change_2012_count        = safe_ifelse(is.na(activity_description_change_2012_count), 		0, activity_description_change_2012_count),
	                                         activity_description_change_2013_count        = safe_ifelse(is.na(activity_description_change_2013_count), 		0, activity_description_change_2013_count),
	                                         activity_description_change_all_count         = safe_ifelse(is.na(activity_description_change_all_count), 		0, activity_description_change_all_count),
	                                         activity_priority_change_1998_count           = safe_ifelse(is.na(activity_priority_change_1998_count), 			0, activity_priority_change_1998_count),
	                                         activity_priority_change_1999_count           = safe_ifelse(is.na(activity_priority_change_1999_count), 			0, activity_priority_change_1999_count),
	                                         activity_priority_change_2000_count           = safe_ifelse(is.na(activity_priority_change_2000_count), 			0, activity_priority_change_2000_count),
	                                         activity_priority_change_2001_count           = safe_ifelse(is.na(activity_priority_change_2001_count), 			0, activity_priority_change_2001_count),
	                                         activity_priority_change_2002_count           = safe_ifelse(is.na(activity_priority_change_2002_count), 			0, activity_priority_change_2002_count),
	                                         activity_priority_change_2003_count           = safe_ifelse(is.na(activity_priority_change_2003_count), 			0, activity_priority_change_2003_count),
	                                         activity_priority_change_2004_count           = safe_ifelse(is.na(activity_priority_change_2004_count),			0, activity_priority_change_2004_count),
	                                         activity_priority_change_2005_count           = safe_ifelse(is.na(activity_priority_change_2005_count), 			0, activity_priority_change_2005_count),
	                                         activity_priority_change_2006_count           = safe_ifelse(is.na(activity_priority_change_2006_count), 			0, activity_priority_change_2006_count),
	                                         activity_priority_change_2007_count           = safe_ifelse(is.na(activity_priority_change_2007_count), 			0, activity_priority_change_2007_count),
	                                         activity_priority_change_2008_count           = safe_ifelse(is.na(activity_priority_change_2008_count), 			0, activity_priority_change_2008_count),
	                                         activity_priority_change_2009_count           = safe_ifelse(is.na(activity_priority_change_2009_count), 			0, activity_priority_change_2009_count),
	                                         activity_priority_change_2010_count           = safe_ifelse(is.na(activity_priority_change_2010_count), 			0, activity_priority_change_2010_count),
	                                         activity_priority_change_2011_count           = safe_ifelse(is.na(activity_priority_change_2011_count), 			0, activity_priority_change_2011_count),
	                                         activity_priority_change_2012_count           = safe_ifelse(is.na(activity_priority_change_2012_count), 			0, activity_priority_change_2012_count),
	                                         activity_priority_change_2013_count           = safe_ifelse(is.na(activity_priority_change_2013_count), 			0, activity_priority_change_2013_count),
	                                         activity_priority_change_all_count            = safe_ifelse(is.na(activity_priority_change_all_count), 			0, activity_priority_change_all_count),
	                                         activity_severity_change_1998_count           = safe_ifelse(is.na(activity_severity_change_1998_count), 			0, activity_severity_change_1998_count),
	                                         activity_severity_change_1999_count           = safe_ifelse(is.na(activity_severity_change_1999_count),			0, activity_severity_change_1999_count),
	                                         activity_severity_change_2000_count           = safe_ifelse(is.na(activity_severity_change_2000_count), 			0, activity_severity_change_2000_count),
	                                         activity_severity_change_2001_count           = safe_ifelse(is.na(activity_severity_change_2001_count), 			0, activity_severity_change_2001_count),
	                                         activity_severity_change_2002_count           = safe_ifelse(is.na(activity_severity_change_2002_count), 			0, activity_severity_change_2002_count),
	                                         activity_severity_change_2003_count			= safe_ifelse(is.na(activity_severity_change_2003_count), 			0, activity_severity_change_2003_count),
	                                         activity_severity_change_2004_count           = safe_ifelse(is.na(activity_severity_change_2004_count), 			0, activity_severity_change_2004_count),
	                                         activity_severity_change_2005_count           = safe_ifelse(is.na(activity_severity_change_2005_count), 			0, activity_severity_change_2005_count),
	                                         activity_severity_change_2006_count           = safe_ifelse(is.na(activity_severity_change_2006_count), 			0, activity_severity_change_2006_count),
	                                         activity_severity_change_2007_count           = safe_ifelse(is.na(activity_severity_change_2007_count), 			0, activity_severity_change_2007_count),
	                                         activity_severity_change_2008_count           = safe_ifelse(is.na(activity_severity_change_2008_count), 			0, activity_severity_change_2008_count),
	                                         activity_severity_change_2009_count           = safe_ifelse(is.na(activity_severity_change_2009_count), 			0, activity_severity_change_2009_count),
	                                         activity_severity_change_2010_count           = safe_ifelse(is.na(activity_severity_change_2010_count), 			0, activity_severity_change_2010_count),
	                                         activity_severity_change_2011_count           = safe_ifelse(is.na(activity_severity_change_2011_count), 			0, activity_severity_change_2011_count),
	                                         activity_severity_change_2012_count           = safe_ifelse(is.na(activity_severity_change_2012_count),			0, activity_severity_change_2012_count),
	                                         activity_severity_change_2013_count           = safe_ifelse(is.na(activity_severity_change_2013_count), 			0, activity_severity_change_2013_count),
	                                         activity_severity_change_all_count            = safe_ifelse(is.na(activity_severity_change_all_count), 			0, activity_severity_change_all_count));
	                                                                                            

# PROFILES-ACTIVITY_USER_ASSIGNING_YEAR
# (Track how many times each user has done the activity of assigning a bug per year)

# Assigning a bug is defined as an activity with one of the changes of fieldid 29 (bug status) as follows:
activity_working_assigning <- filter(activity_base, (removed=="NEW"			& added=="ASSIGNED"		& fieldid==29) |
													(removed=="REOPENED"	& added=="ASSIGNED"		& fieldid==29) |
													(removed=="UNCONFIRMED"	& added=="ASSIGNED"		& fieldid==29) |
													(removed=="VERIFIED" 	& added=="ASSIGNED" 	& fieldid==29) |
													(removed=="RESOLVED" 	& added=="ASSIGNED"		& fieldid==29));

# We only need the user ("who") and year of the bug_when column, so drop the rest.
activity_working_assigning_who_year <- transmute(activity_working_assigning, who = who, bug_when_year = chron::years(bug_when));


# Use data.table's dcast() function to recast the table such that each row is a single user and there is
# a column for each field_id that is the sum of activities in each year for each user
activity_working_assigning_who_year_recast <- dcast(activity_working_assigning_who_year, who ~ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_working_assigning_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(activity_working_assigning_who_year_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns to our desired names
# We also need to check if all columns exist since not all years might show up
activity_working_assigning_who_year_recast <- transmute(activity_working_assigning_who_year_recast, who 							   = who,
																									activity_assigning_1998_count = if (exists('arg1998', where = activity_working_assigning_who_year_recast)) arg1998 else 0,
																									activity_assigning_1999_count = if (exists('arg1999', where = activity_working_assigning_who_year_recast)) arg1999 else 0,
																									activity_assigning_2000_count = if (exists('arg2000', where = activity_working_assigning_who_year_recast)) arg2000 else 0,
																									activity_assigning_2001_count = if (exists('arg2001', where = activity_working_assigning_who_year_recast)) arg2001 else 0,
																									activity_assigning_2002_count = if (exists('arg2002', where = activity_working_assigning_who_year_recast)) arg2002 else 0,
																									activity_assigning_2003_count = if (exists('arg2003', where = activity_working_assigning_who_year_recast)) arg2003 else 0,
																									activity_assigning_2004_count = if (exists('arg2004', where = activity_working_assigning_who_year_recast)) arg2004 else 0,
																									activity_assigning_2005_count = if (exists('arg2005', where = activity_working_assigning_who_year_recast)) arg2005 else 0,
																									activity_assigning_2006_count = if (exists('arg2006', where = activity_working_assigning_who_year_recast)) arg2006 else 0,
																									activity_assigning_2007_count = if (exists('arg2007', where = activity_working_assigning_who_year_recast)) arg2007 else 0,
																									activity_assigning_2008_count = if (exists('arg2008', where = activity_working_assigning_who_year_recast)) arg2008 else 0,
																									activity_assigning_2009_count = if (exists('arg2009', where = activity_working_assigning_who_year_recast)) arg2009 else 0,
																									activity_assigning_2010_count = if (exists('arg2010', where = activity_working_assigning_who_year_recast)) arg2010 else 0,
																									activity_assigning_2011_count = if (exists('arg2011', where = activity_working_assigning_who_year_recast)) arg2011 else 0,
																									activity_assigning_2012_count = if (exists('arg2012', where = activity_working_assigning_who_year_recast)) arg2012 else 0,
																									activity_assigning_2013_count = if (exists('arg2013', where = activity_working_assigning_who_year_recast)) arg2013 else 0);

# Sum the yearly counts to get all activity of that type for each user 																									
activity_working_assigning_who_year_recast <- mutate(activity_working_assigning_who_year_recast, activity_assigning_all_count  = 	activity_assigning_1998_count +
																																		activity_assigning_1999_count +
																																		activity_assigning_2000_count +
																																		activity_assigning_2001_count +
																																		activity_assigning_2002_count +
																																		activity_assigning_2003_count +
																																		activity_assigning_2004_count +
																																		activity_assigning_2005_count +
																																		activity_assigning_2006_count +
																																		activity_assigning_2007_count +
																																		activity_assigning_2008_count +
																																		activity_assigning_2009_count +
																																		activity_assigning_2010_count +
																																		activity_assigning_2011_count +
																																		activity_assigning_2012_count +
																																		activity_assigning_2013_count); 

# Merge the "activity_working_assigning_who_year_recast" table with the profiles table according to "who" and "userid"
setkey(activity_working_assigning_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_working_assigning_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries that means the user did no reassigning activities, so set it to 0
profiles_working <- mutate(profiles_working, activity_assigning_1998_count = safe_ifelse(is.na(activity_assigning_1998_count), 0, activity_assigning_1998_count),
                                             activity_assigning_1999_count = safe_ifelse(is.na(activity_assigning_1999_count), 0, activity_assigning_1999_count),
                                             activity_assigning_2000_count = safe_ifelse(is.na(activity_assigning_2000_count), 0, activity_assigning_2000_count),
                                             activity_assigning_2001_count = safe_ifelse(is.na(activity_assigning_2001_count), 0, activity_assigning_2001_count),
                                             activity_assigning_2002_count = safe_ifelse(is.na(activity_assigning_2002_count), 0, activity_assigning_2002_count),
                                             activity_assigning_2003_count = safe_ifelse(is.na(activity_assigning_2003_count), 0, activity_assigning_2003_count),
                                             activity_assigning_2004_count = safe_ifelse(is.na(activity_assigning_2004_count), 0, activity_assigning_2004_count),
                                             activity_assigning_2005_count = safe_ifelse(is.na(activity_assigning_2005_count), 0, activity_assigning_2005_count),
                                             activity_assigning_2006_count = safe_ifelse(is.na(activity_assigning_2006_count), 0, activity_assigning_2006_count),
                                             activity_assigning_2007_count = safe_ifelse(is.na(activity_assigning_2007_count), 0, activity_assigning_2007_count),
                                             activity_assigning_2008_count = safe_ifelse(is.na(activity_assigning_2008_count), 0, activity_assigning_2008_count),
                                             activity_assigning_2009_count = safe_ifelse(is.na(activity_assigning_2009_count), 0, activity_assigning_2009_count),
                                             activity_assigning_2010_count = safe_ifelse(is.na(activity_assigning_2010_count), 0, activity_assigning_2010_count),
                                             activity_assigning_2011_count = safe_ifelse(is.na(activity_assigning_2011_count), 0, activity_assigning_2011_count),
                                             activity_assigning_2012_count = safe_ifelse(is.na(activity_assigning_2012_count), 0, activity_assigning_2012_count),
                                             activity_assigning_2013_count = safe_ifelse(is.na(activity_assigning_2013_count), 0, activity_assigning_2013_count),
                                             activity_assigning_all_count	= safe_ifelse(is.na(activity_assigning_all_count ), 0, activity_assigning_all_count ));


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
activity_working_reassigning_who_year <- transmute(activity_working_reassigning, who = who, bug_when_year = chron::years(bug_when));


# Use data.table's dcast() function to recast the table such that each row is a single user and there is
# a column for each field_id that is the sum of activities in each year for each user
activity_working_reassigning_who_year_recast <- dcast(activity_working_reassigning_who_year, who ~ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_working_reassigning_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(activity_working_reassigning_who_year_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns to our desired names
activity_working_reassigning_who_year_recast <- transmute(activity_working_reassigning_who_year_recast, who 							 	 = who,
																										activity_reassigning_1998_count = if (exists('arg1998', where = activity_working_reassigning_who_year_recast)) arg1998 else 0,
																										activity_reassigning_1999_count = if (exists('arg1999', where = activity_working_reassigning_who_year_recast)) arg1999 else 0,
																										activity_reassigning_2000_count = if (exists('arg2000', where = activity_working_reassigning_who_year_recast)) arg2000 else 0,
																										activity_reassigning_2001_count = if (exists('arg2001', where = activity_working_reassigning_who_year_recast)) arg2001 else 0,
																										activity_reassigning_2002_count = if (exists('arg2002', where = activity_working_reassigning_who_year_recast)) arg2002 else 0,
																										activity_reassigning_2003_count = if (exists('arg2003', where = activity_working_reassigning_who_year_recast)) arg2003 else 0,
																										activity_reassigning_2004_count = if (exists('arg2004', where = activity_working_reassigning_who_year_recast)) arg2004 else 0,
																										activity_reassigning_2005_count = if (exists('arg2005', where = activity_working_reassigning_who_year_recast)) arg2005 else 0,
																										activity_reassigning_2006_count = if (exists('arg2006', where = activity_working_reassigning_who_year_recast)) arg2006 else 0,
																										activity_reassigning_2007_count = if (exists('arg2007', where = activity_working_reassigning_who_year_recast)) arg2007 else 0,
																										activity_reassigning_2008_count = if (exists('arg2008', where = activity_working_reassigning_who_year_recast)) arg2008 else 0,
																										activity_reassigning_2009_count = if (exists('arg2009', where = activity_working_reassigning_who_year_recast)) arg2009 else 0,
																										activity_reassigning_2010_count = if (exists('arg2010', where = activity_working_reassigning_who_year_recast)) arg2010 else 0,
																										activity_reassigning_2011_count = if (exists('arg2011', where = activity_working_reassigning_who_year_recast)) arg2011 else 0,
																										activity_reassigning_2012_count = if (exists('arg2012', where = activity_working_reassigning_who_year_recast)) arg2012 else 0,
																										activity_reassigning_2013_count = if (exists('arg2013', where = activity_working_reassigning_who_year_recast)) arg2013 else 0);
																										
activity_working_reassigning_who_year_recast <- mutate(activity_working_reassigning_who_year_recast, activity_reassigning_all_count = 	activity_reassigning_1998_count +
																																			activity_reassigning_1999_count +
																																			activity_reassigning_2000_count +
																																			activity_reassigning_2001_count +
																																			activity_reassigning_2002_count +
																																			activity_reassigning_2003_count +
																																			activity_reassigning_2004_count +
																																			activity_reassigning_2005_count +
																																			activity_reassigning_2006_count +
																																			activity_reassigning_2007_count +
																																			activity_reassigning_2008_count +
																																			activity_reassigning_2009_count +
																																			activity_reassigning_2010_count +
																																			activity_reassigning_2011_count +
																																			activity_reassigning_2012_count +
																																			activity_reassigning_2013_count); 

# Merge the "activity_working_reassigning_who_year_recast" table with the profiles table according to "who" and "userid"
setkey(activity_working_reassigning_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_working_reassigning_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries that means the user did no rereassigning activities, so set it to 0
profiles_working <- mutate(profiles_working, activity_reassigning_1998_count = safe_ifelse(is.na(activity_reassigning_1998_count), 0, activity_reassigning_1998_count),
                                             activity_reassigning_1999_count = safe_ifelse(is.na(activity_reassigning_1999_count), 0, activity_reassigning_1999_count),
                                             activity_reassigning_2000_count = safe_ifelse(is.na(activity_reassigning_2000_count), 0, activity_reassigning_2000_count),
                                             activity_reassigning_2001_count = safe_ifelse(is.na(activity_reassigning_2001_count), 0, activity_reassigning_2001_count),
                                             activity_reassigning_2002_count = safe_ifelse(is.na(activity_reassigning_2002_count), 0, activity_reassigning_2002_count),
                                             activity_reassigning_2003_count = safe_ifelse(is.na(activity_reassigning_2003_count), 0, activity_reassigning_2003_count),
                                             activity_reassigning_2004_count = safe_ifelse(is.na(activity_reassigning_2004_count), 0, activity_reassigning_2004_count),
                                             activity_reassigning_2005_count = safe_ifelse(is.na(activity_reassigning_2005_count), 0, activity_reassigning_2005_count),
                                             activity_reassigning_2006_count = safe_ifelse(is.na(activity_reassigning_2006_count), 0, activity_reassigning_2006_count),
                                             activity_reassigning_2007_count = safe_ifelse(is.na(activity_reassigning_2007_count), 0, activity_reassigning_2007_count),
                                             activity_reassigning_2008_count = safe_ifelse(is.na(activity_reassigning_2008_count), 0, activity_reassigning_2008_count),
                                             activity_reassigning_2009_count = safe_ifelse(is.na(activity_reassigning_2009_count), 0, activity_reassigning_2009_count),
                                             activity_reassigning_2010_count = safe_ifelse(is.na(activity_reassigning_2010_count), 0, activity_reassigning_2010_count),
                                             activity_reassigning_2011_count = safe_ifelse(is.na(activity_reassigning_2011_count), 0, activity_reassigning_2011_count),
                                             activity_reassigning_2012_count = safe_ifelse(is.na(activity_reassigning_2012_count), 0, activity_reassigning_2012_count),
                                             activity_reassigning_2013_count = safe_ifelse(is.na(activity_reassigning_2013_count), 0, activity_reassigning_2013_count),
                                             activity_reassigning_all_count  = safe_ifelse(is.na(activity_reassigning_all_count ), 0, activity_reassigning_all_count ));


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
activity_working_reopening_who_year <- transmute(activity_working_reopening, who = who, bug_when_year = chron::years(bug_when));


# Use data.table's dcast() function to recast the table such that each row is a single user and there is
# a column for each field_id that is the sum of activities in each year for each user
activity_working_reopening_who_year_recast <- dcast(activity_working_reopening_who_year, who ~ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(activity_working_reopening_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(activity_working_reopening_who_year_recast), perl=TRUE);

# Filter() keeps all the factor levels, so dcast created columns for those too, so drop'em while we rename the columns to our desired names
activity_working_reopening_who_year_recast <- transmute(activity_working_reopening_who_year_recast, who 							   = who,
																									activity_reopening_1998_count = if (exists('arg1998', where = activity_working_reopening_who_year_recast)) arg1998 else 0,
																									activity_reopening_1999_count = if (exists('arg1999', where = activity_working_reopening_who_year_recast)) arg1999 else 0,
																									activity_reopening_2000_count = if (exists('arg2000', where = activity_working_reopening_who_year_recast)) arg2000 else 0,
																									activity_reopening_2001_count = if (exists('arg2001', where = activity_working_reopening_who_year_recast)) arg2001 else 0,
																									activity_reopening_2002_count = if (exists('arg2002', where = activity_working_reopening_who_year_recast)) arg2002 else 0,
																									activity_reopening_2003_count = if (exists('arg2003', where = activity_working_reopening_who_year_recast)) arg2003 else 0,
																									activity_reopening_2004_count = if (exists('arg2004', where = activity_working_reopening_who_year_recast)) arg2004 else 0,
																									activity_reopening_2005_count = if (exists('arg2005', where = activity_working_reopening_who_year_recast)) arg2005 else 0,
																									activity_reopening_2006_count = if (exists('arg2006', where = activity_working_reopening_who_year_recast)) arg2006 else 0,
																									activity_reopening_2007_count = if (exists('arg2007', where = activity_working_reopening_who_year_recast)) arg2007 else 0,
																									activity_reopening_2008_count = if (exists('arg2008', where = activity_working_reopening_who_year_recast)) arg2008 else 0,
																									activity_reopening_2009_count = if (exists('arg2009', where = activity_working_reopening_who_year_recast)) arg2009 else 0,
																									activity_reopening_2010_count = if (exists('arg2010', where = activity_working_reopening_who_year_recast)) arg2010 else 0,
																									activity_reopening_2011_count = if (exists('arg2011', where = activity_working_reopening_who_year_recast)) arg2011 else 0,
																									activity_reopening_2012_count = if (exists('arg2012', where = activity_working_reopening_who_year_recast)) arg2012 else 0,
																									activity_reopening_2013_count = if (exists('arg2013', where = activity_working_reopening_who_year_recast)) arg2013 else 0);
																									
activity_working_reopening_who_year_recast <- mutate(activity_working_reopening_who_year_recast, activity_reopening_all_count = 	activity_reopening_1998_count +
																																		activity_reopening_1999_count +
																																		activity_reopening_2000_count +
																																		activity_reopening_2001_count +
																																		activity_reopening_2002_count +
																																		activity_reopening_2003_count +
																																		activity_reopening_2004_count +
																																		activity_reopening_2005_count +
																																		activity_reopening_2006_count +
																																		activity_reopening_2007_count +
																																		activity_reopening_2008_count +
																																		activity_reopening_2009_count +
																																		activity_reopening_2010_count +
																																		activity_reopening_2011_count +
																																		activity_reopening_2012_count +
																																		activity_reopening_2013_count); 

# Merge the "activity_working_reopening_who_year_recast" table with the profiles table according to "who" and "userid"
setkey(activity_working_reopening_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, activity_working_reopening_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# For any NA entries that means the user did no rereopening activities, so set it to 0
profiles_working <- mutate(profiles_working, activity_reopening_1998_count = safe_ifelse(is.na(activity_reopening_1998_count), 0, activity_reopening_1998_count),
                                             activity_reopening_1999_count = safe_ifelse(is.na(activity_reopening_1999_count), 0, activity_reopening_1999_count),
                                             activity_reopening_2000_count = safe_ifelse(is.na(activity_reopening_2000_count), 0, activity_reopening_2000_count),
                                             activity_reopening_2001_count = safe_ifelse(is.na(activity_reopening_2001_count), 0, activity_reopening_2001_count),
                                             activity_reopening_2002_count = safe_ifelse(is.na(activity_reopening_2002_count), 0, activity_reopening_2002_count),
                                             activity_reopening_2003_count = safe_ifelse(is.na(activity_reopening_2003_count), 0, activity_reopening_2003_count),
                                             activity_reopening_2004_count = safe_ifelse(is.na(activity_reopening_2004_count), 0, activity_reopening_2004_count),
                                             activity_reopening_2005_count = safe_ifelse(is.na(activity_reopening_2005_count), 0, activity_reopening_2005_count),
                                             activity_reopening_2006_count = safe_ifelse(is.na(activity_reopening_2006_count), 0, activity_reopening_2006_count),
                                             activity_reopening_2007_count = safe_ifelse(is.na(activity_reopening_2007_count), 0, activity_reopening_2007_count),
                                             activity_reopening_2008_count = safe_ifelse(is.na(activity_reopening_2008_count), 0, activity_reopening_2008_count),
                                             activity_reopening_2009_count = safe_ifelse(is.na(activity_reopening_2009_count), 0, activity_reopening_2009_count),
                                             activity_reopening_2010_count = safe_ifelse(is.na(activity_reopening_2010_count), 0, activity_reopening_2010_count),
                                             activity_reopening_2011_count = safe_ifelse(is.na(activity_reopening_2011_count), 0, activity_reopening_2011_count),
                                             activity_reopening_2012_count = safe_ifelse(is.na(activity_reopening_2012_count), 0, activity_reopening_2012_count),
                                             activity_reopening_2013_count = safe_ifelse(is.na(activity_reopening_2013_count), 0, activity_reopening_2013_count),
                                             activity_reopening_all_count  = safe_ifelse(is.na(activity_reopening_all_count ), 0, activity_reopening_all_count ));


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
														  attachments_all_types_1998_count = if (exists('arg1998', where = attachments_working_submitter_id_year_recast)) arg1998 else 0,
														  attachments_all_types_1999_count = if (exists('arg1999', where = attachments_working_submitter_id_year_recast)) arg1999 else 0,
														  attachments_all_types_2000_count = if (exists('arg2000', where = attachments_working_submitter_id_year_recast)) arg2000 else 0,
														  attachments_all_types_2001_count = if (exists('arg2001', where = attachments_working_submitter_id_year_recast)) arg2001 else 0,
														  attachments_all_types_2002_count = if (exists('arg2002', where = attachments_working_submitter_id_year_recast)) arg2002 else 0,
														  attachments_all_types_2003_count = if (exists('arg2003', where = attachments_working_submitter_id_year_recast)) arg2003 else 0,
														  attachments_all_types_2004_count = if (exists('arg2004', where = attachments_working_submitter_id_year_recast)) arg2004 else 0,
														  attachments_all_types_2005_count = if (exists('arg2005', where = attachments_working_submitter_id_year_recast)) arg2005 else 0,
														  attachments_all_types_2006_count = if (exists('arg2006', where = attachments_working_submitter_id_year_recast)) arg2006 else 0,
														  attachments_all_types_2007_count = if (exists('arg2007', where = attachments_working_submitter_id_year_recast)) arg2007 else 0,
														  attachments_all_types_2008_count = if (exists('arg2008', where = attachments_working_submitter_id_year_recast)) arg2008 else 0,
														  attachments_all_types_2009_count = if (exists('arg2009', where = attachments_working_submitter_id_year_recast)) arg2009 else 0,
														  attachments_all_types_2010_count = if (exists('arg2010', where = attachments_working_submitter_id_year_recast)) arg2010 else 0,
														  attachments_all_types_2011_count = if (exists('arg2011', where = attachments_working_submitter_id_year_recast)) arg2011 else 0,
														  attachments_all_types_2012_count = if (exists('arg2012', where = attachments_working_submitter_id_year_recast)) arg2012 else 0,
														  attachments_all_types_2013_count = if (exists('arg2013', where = attachments_working_submitter_id_year_recast)) arg2013 else 0);
																						
# Merge the attachments_working_submitter_id_year_recast and profiles_working tables based on submitter_id & userid to add the years count columns
setkey(attachments_working_submitter_id_year_recast, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_working_submitter_id_year_recast, by.x="userid", by.y="submitter_id", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, attachments_all_types_1998_count = safe_ifelse(is.na(attachments_all_types_1998_count), 0, attachments_all_types_1998_count),
                                             attachments_all_types_1999_count = safe_ifelse(is.na(attachments_all_types_1999_count), 0, attachments_all_types_1999_count),
                                             attachments_all_types_2000_count = safe_ifelse(is.na(attachments_all_types_2000_count), 0, attachments_all_types_2000_count),
											 attachments_all_types_2001_count = safe_ifelse(is.na(attachments_all_types_2001_count), 0, attachments_all_types_2001_count),
											 attachments_all_types_2002_count = safe_ifelse(is.na(attachments_all_types_2002_count), 0, attachments_all_types_2002_count),
											 attachments_all_types_2003_count = safe_ifelse(is.na(attachments_all_types_2003_count), 0, attachments_all_types_2003_count),
											 attachments_all_types_2004_count = safe_ifelse(is.na(attachments_all_types_2004_count), 0, attachments_all_types_2004_count),
											 attachments_all_types_2005_count = safe_ifelse(is.na(attachments_all_types_2005_count), 0, attachments_all_types_2005_count),
											 attachments_all_types_2006_count = safe_ifelse(is.na(attachments_all_types_2006_count), 0, attachments_all_types_2006_count),
											 attachments_all_types_2007_count = safe_ifelse(is.na(attachments_all_types_2007_count), 0, attachments_all_types_2007_count),
											 attachments_all_types_2008_count = safe_ifelse(is.na(attachments_all_types_2008_count), 0, attachments_all_types_2008_count),
											 attachments_all_types_2009_count = safe_ifelse(is.na(attachments_all_types_2009_count), 0, attachments_all_types_2009_count),
											 attachments_all_types_2010_count = safe_ifelse(is.na(attachments_all_types_2010_count), 0, attachments_all_types_2010_count),
											 attachments_all_types_2011_count = safe_ifelse(is.na(attachments_all_types_2011_count), 0, attachments_all_types_2011_count),
											 attachments_all_types_2012_count = safe_ifelse(is.na(attachments_all_types_2012_count), 0, attachments_all_types_2012_count),
											 attachments_all_types_2013_count = safe_ifelse(is.na(attachments_all_types_2013_count), 0, attachments_all_types_2013_count)); 


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
														  attachments_patches_1998_count = if (exists('arg1998', where = attachments_working_patches_submitter_id_year_recast)) arg1998 else 0,
														  attachments_patches_1999_count = if (exists('arg1999', where = attachments_working_patches_submitter_id_year_recast)) arg1999 else 0,
														  attachments_patches_2000_count = if (exists('arg2000', where = attachments_working_patches_submitter_id_year_recast)) arg2000 else 0,
														  attachments_patches_2001_count = if (exists('arg2001', where = attachments_working_patches_submitter_id_year_recast)) arg2001 else 0,
														  attachments_patches_2002_count = if (exists('arg2002', where = attachments_working_patches_submitter_id_year_recast)) arg2002 else 0,
														  attachments_patches_2003_count = if (exists('arg2003', where = attachments_working_patches_submitter_id_year_recast)) arg2003 else 0,
														  attachments_patches_2004_count = if (exists('arg2004', where = attachments_working_patches_submitter_id_year_recast)) arg2004 else 0,
														  attachments_patches_2005_count = if (exists('arg2005', where = attachments_working_patches_submitter_id_year_recast)) arg2005 else 0,
														  attachments_patches_2006_count = if (exists('arg2006', where = attachments_working_patches_submitter_id_year_recast)) arg2006 else 0,
														  attachments_patches_2007_count = if (exists('arg2007', where = attachments_working_patches_submitter_id_year_recast)) arg2007 else 0,
														  attachments_patches_2008_count = if (exists('arg2008', where = attachments_working_patches_submitter_id_year_recast)) arg2008 else 0,
														  attachments_patches_2009_count = if (exists('arg2009', where = attachments_working_patches_submitter_id_year_recast)) arg2009 else 0,
														  attachments_patches_2010_count = if (exists('arg2010', where = attachments_working_patches_submitter_id_year_recast)) arg2010 else 0,
														  attachments_patches_2011_count = if (exists('arg2011', where = attachments_working_patches_submitter_id_year_recast)) arg2011 else 0,
														  attachments_patches_2012_count = if (exists('arg2012', where = attachments_working_patches_submitter_id_year_recast)) arg2012 else 0,
														  attachments_patches_2013_count = if (exists('arg2013', where = attachments_working_patches_submitter_id_year_recast)) arg2013 else 0);
																						
# Merge the attachments_working_patches_submitter_id_year_recast and profiles_working tables based on submitter_id & userid to add the years count columns
setkey(attachments_working_patches_submitter_id_year_recast, submitter_id);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, attachments_working_patches_submitter_id_year_recast, by.x="userid", by.y="submitter_id", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, attachments_patches_1998_count = safe_ifelse(is.na(attachments_patches_1998_count), 0, attachments_patches_1998_count),
                                             attachments_patches_1999_count = safe_ifelse(is.na(attachments_patches_1999_count), 0, attachments_patches_1999_count),
                                             attachments_patches_2000_count = safe_ifelse(is.na(attachments_patches_2000_count), 0, attachments_patches_2000_count),
											 attachments_patches_2001_count = safe_ifelse(is.na(attachments_patches_2001_count), 0, attachments_patches_2001_count),
											 attachments_patches_2002_count = safe_ifelse(is.na(attachments_patches_2002_count), 0, attachments_patches_2002_count),
											 attachments_patches_2003_count = safe_ifelse(is.na(attachments_patches_2003_count), 0, attachments_patches_2003_count),
											 attachments_patches_2004_count = safe_ifelse(is.na(attachments_patches_2004_count), 0, attachments_patches_2004_count),
											 attachments_patches_2005_count = safe_ifelse(is.na(attachments_patches_2005_count), 0, attachments_patches_2005_count),
											 attachments_patches_2006_count = safe_ifelse(is.na(attachments_patches_2006_count), 0, attachments_patches_2006_count),
											 attachments_patches_2007_count = safe_ifelse(is.na(attachments_patches_2007_count), 0, attachments_patches_2007_count),
											 attachments_patches_2008_count = safe_ifelse(is.na(attachments_patches_2008_count), 0, attachments_patches_2008_count),
											 attachments_patches_2009_count = safe_ifelse(is.na(attachments_patches_2009_count), 0, attachments_patches_2009_count),
											 attachments_patches_2010_count = safe_ifelse(is.na(attachments_patches_2010_count), 0, attachments_patches_2010_count),
											 attachments_patches_2011_count = safe_ifelse(is.na(attachments_patches_2011_count), 0, attachments_patches_2011_count),
											 attachments_patches_2012_count = safe_ifelse(is.na(attachments_patches_2012_count), 0, attachments_patches_2012_count),
											 attachments_patches_2013_count = safe_ifelse(is.na(attachments_patches_2013_count), 0, attachments_patches_2013_count)); 


# PROFILES-LONGDESCS_USER_COMMENTS_ALL_BUGS_YEAR
#(Count the comments on all bugs made by each user for each year)

# Select just the fields in the longdescs_base table that we want to look at, namely who and bug_when
longdescs_working_who_bug_when <- select(longdescs_base, who, bug_when);

# Transmute to get just the year of the bug_when column
longdescs_working_who_year <- transmute(longdescs_working_who_bug_when, who = who, bug_when_year = chron::years(bug_when));

# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the count of each time a user made a comment each of the years in the database
longdescs_working_who_year_recast <- dcast(longdescs_working_who_year, who ~ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

# The dcast created columns that start with digits, which are difficult to work with, so first append "arg" in front of each column name
names(longdescs_working_who_year_recast) <- gsub("^(\\d)", "arg\\1", names(longdescs_working_who_year_recast), perl=TRUE);

# Transmute all of the columns to the desired values
longdescs_working_who_year_recast <- transmute(longdescs_working_who_year_recast,
											   who									 = who,
											   comments_all_bugs_1995_count = if (exists('arg1995', where = longdescs_working_who_year_recast)) arg1995 else 0,
											   comments_all_bugs_1996_count = if (exists('arg1996', where = longdescs_working_who_year_recast)) arg1996 else 0,
											   comments_all_bugs_1997_count = if (exists('arg1997', where = longdescs_working_who_year_recast)) arg1997 else 0,
											   comments_all_bugs_1998_count = if (exists('arg1998', where = longdescs_working_who_year_recast)) arg1998 else 0,
											   comments_all_bugs_1999_count = if (exists('arg1999', where = longdescs_working_who_year_recast)) arg1999 else 0,
											   comments_all_bugs_2000_count = if (exists('arg2000', where = longdescs_working_who_year_recast)) arg2000 else 0,
											   comments_all_bugs_2001_count = if (exists('arg2001', where = longdescs_working_who_year_recast)) arg2001 else 0,
											   comments_all_bugs_2002_count = if (exists('arg2002', where = longdescs_working_who_year_recast)) arg2002 else 0,
											   comments_all_bugs_2003_count = if (exists('arg2003', where = longdescs_working_who_year_recast)) arg2003 else 0,
											   comments_all_bugs_2004_count = if (exists('arg2004', where = longdescs_working_who_year_recast)) arg2004 else 0,
											   comments_all_bugs_2005_count = if (exists('arg2005', where = longdescs_working_who_year_recast)) arg2005 else 0,
											   comments_all_bugs_2006_count = if (exists('arg2006', where = longdescs_working_who_year_recast)) arg2006 else 0,
											   comments_all_bugs_2007_count = if (exists('arg2007', where = longdescs_working_who_year_recast)) arg2007 else 0,
											   comments_all_bugs_2008_count = if (exists('arg2008', where = longdescs_working_who_year_recast)) arg2008 else 0,
											   comments_all_bugs_2009_count = if (exists('arg2009', where = longdescs_working_who_year_recast)) arg2009 else 0,
											   comments_all_bugs_2010_count = if (exists('arg2010', where = longdescs_working_who_year_recast)) arg2010 else 0,
											   comments_all_bugs_2011_count = if (exists('arg2011', where = longdescs_working_who_year_recast)) arg2011 else 0,
											   comments_all_bugs_2012_count = if (exists('arg2012', where = longdescs_working_who_year_recast)) arg2012 else 0,
											   comments_all_bugs_2013_count = if (exists('arg2013', where = longdescs_working_who_year_recast)) arg2013 else 0);
																						
longdescs_working_who_year_recast <- mutate(longdescs_working_who_year_recast, comments_all_bugs_all_count = 	comments_all_bugs_1995_count +
																													comments_all_bugs_1996_count +
																													comments_all_bugs_1997_count +
																													comments_all_bugs_1998_count +
																													comments_all_bugs_1999_count +
																													comments_all_bugs_2000_count +
																													comments_all_bugs_2001_count +
																													comments_all_bugs_2002_count +
																													comments_all_bugs_2003_count +
																													comments_all_bugs_2004_count +
																													comments_all_bugs_2005_count +
																													comments_all_bugs_2006_count +
																													comments_all_bugs_2007_count +
																													comments_all_bugs_2008_count +
																													comments_all_bugs_2009_count +
																													comments_all_bugs_2010_count + 
																						                            comments_all_bugs_2011_count +
																						                            comments_all_bugs_2012_count +
																						                            comments_all_bugs_2013_count);
																						
# Merge the longdescs_working_who_year_recast and profiles_working tables based on who & userid to add the years count columns
setkey(longdescs_working_who_year_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, longdescs_working_who_year_recast, by.x="userid", by.y="who", all.x=TRUE);

# NA values mean that the user reported no bugs, so change to 0
profiles_working <- mutate(profiles_working, 
											 comments_all_bugs_1995_count = safe_ifelse(is.na(comments_all_bugs_1995_count), 0, comments_all_bugs_1995_count),
											 comments_all_bugs_1996_count = safe_ifelse(is.na(comments_all_bugs_1996_count), 0, comments_all_bugs_1996_count),
											 comments_all_bugs_1997_count = safe_ifelse(is.na(comments_all_bugs_1997_count), 0, comments_all_bugs_1997_count),
											 comments_all_bugs_1998_count = safe_ifelse(is.na(comments_all_bugs_1998_count), 0, comments_all_bugs_1998_count),
                                             comments_all_bugs_1999_count = safe_ifelse(is.na(comments_all_bugs_1999_count), 0, comments_all_bugs_1999_count),
                                             comments_all_bugs_2000_count = safe_ifelse(is.na(comments_all_bugs_2000_count), 0, comments_all_bugs_2000_count),
											 comments_all_bugs_2001_count = safe_ifelse(is.na(comments_all_bugs_2001_count), 0, comments_all_bugs_2001_count),
											 comments_all_bugs_2002_count = safe_ifelse(is.na(comments_all_bugs_2002_count), 0, comments_all_bugs_2002_count),
											 comments_all_bugs_2003_count = safe_ifelse(is.na(comments_all_bugs_2003_count), 0, comments_all_bugs_2003_count),
											 comments_all_bugs_2004_count = safe_ifelse(is.na(comments_all_bugs_2004_count), 0, comments_all_bugs_2004_count),
											 comments_all_bugs_2005_count = safe_ifelse(is.na(comments_all_bugs_2005_count), 0, comments_all_bugs_2005_count),
											 comments_all_bugs_2006_count = safe_ifelse(is.na(comments_all_bugs_2006_count), 0, comments_all_bugs_2006_count),
											 comments_all_bugs_2007_count = safe_ifelse(is.na(comments_all_bugs_2007_count), 0, comments_all_bugs_2007_count),
											 comments_all_bugs_2008_count = safe_ifelse(is.na(comments_all_bugs_2008_count), 0, comments_all_bugs_2008_count),
											 comments_all_bugs_2009_count = safe_ifelse(is.na(comments_all_bugs_2009_count), 0, comments_all_bugs_2009_count),
											 comments_all_bugs_2010_count = safe_ifelse(is.na(comments_all_bugs_2010_count), 0, comments_all_bugs_2010_count),
											 comments_all_bugs_2011_count = safe_ifelse(is.na(comments_all_bugs_2011_count), 0, comments_all_bugs_2011_count),
											 comments_all_bugs_2012_count = safe_ifelse(is.na(comments_all_bugs_2012_count), 0, comments_all_bugs_2012_count),
											 comments_all_bugs_2013_count = safe_ifelse(is.na(comments_all_bugs_2013_count), 0, comments_all_bugs_2013_count),
											 comments_all_bugs_all_count  = safe_ifelse(is.na(comments_all_bugs_all_count),  0, comments_all_bugs_all_count)); 
											 
# Since the longdescs table also includes the "description" for a reported bug as the first "comment" for that bug
# if a user reported bugs during each of the above years, their comments count will be artificially inflated
# Need to subtract the bugs_reported for that year from the comment count for each user to remove description
profiles_working <- mutate(profiles_working, comments_all_bugs_1995_count = safe_ifelse((comments_all_bugs_1995_count - bugs_reported_1995_count) < 0, 0, comments_all_bugs_1995_count - bugs_reported_1995_count),
											 comments_all_bugs_1996_count = safe_ifelse((comments_all_bugs_1996_count - bugs_reported_1996_count) < 0, 0, comments_all_bugs_1996_count - bugs_reported_1996_count),
											 comments_all_bugs_1997_count = safe_ifelse((comments_all_bugs_1997_count - bugs_reported_1997_count) < 0, 0, comments_all_bugs_1997_count - bugs_reported_1997_count),
											 comments_all_bugs_1998_count = safe_ifelse((comments_all_bugs_1998_count - bugs_reported_1998_count) < 0, 0, comments_all_bugs_1998_count - bugs_reported_1998_count),
                                             comments_all_bugs_1999_count = safe_ifelse((comments_all_bugs_1999_count - bugs_reported_1999_count) < 0, 0, comments_all_bugs_1999_count - bugs_reported_1999_count),
                                             comments_all_bugs_2000_count = safe_ifelse((comments_all_bugs_2000_count - bugs_reported_2000_count) < 0, 0, comments_all_bugs_2000_count - bugs_reported_2000_count),
											 comments_all_bugs_2001_count = safe_ifelse((comments_all_bugs_2001_count - bugs_reported_2001_count) < 0, 0, comments_all_bugs_2001_count - bugs_reported_2001_count),
											 comments_all_bugs_2002_count = safe_ifelse((comments_all_bugs_2002_count - bugs_reported_2002_count) < 0, 0, comments_all_bugs_2002_count - bugs_reported_2002_count),
											 comments_all_bugs_2003_count = safe_ifelse((comments_all_bugs_2003_count - bugs_reported_2003_count) < 0, 0, comments_all_bugs_2003_count - bugs_reported_2003_count),
											 comments_all_bugs_2004_count = safe_ifelse((comments_all_bugs_2004_count - bugs_reported_2004_count) < 0, 0, comments_all_bugs_2004_count - bugs_reported_2004_count),
											 comments_all_bugs_2005_count = safe_ifelse((comments_all_bugs_2005_count - bugs_reported_2005_count) < 0, 0, comments_all_bugs_2005_count - bugs_reported_2005_count),
											 comments_all_bugs_2006_count = safe_ifelse((comments_all_bugs_2006_count - bugs_reported_2006_count) < 0, 0, comments_all_bugs_2006_count - bugs_reported_2006_count),
											 comments_all_bugs_2007_count = safe_ifelse((comments_all_bugs_2007_count - bugs_reported_2007_count) < 0, 0, comments_all_bugs_2007_count - bugs_reported_2007_count),
											 comments_all_bugs_2008_count = safe_ifelse((comments_all_bugs_2008_count - bugs_reported_2008_count) < 0, 0, comments_all_bugs_2008_count - bugs_reported_2008_count),
											 comments_all_bugs_2009_count = safe_ifelse((comments_all_bugs_2009_count - bugs_reported_2009_count) < 0, 0, comments_all_bugs_2009_count - bugs_reported_2009_count),
											 comments_all_bugs_2010_count = safe_ifelse((comments_all_bugs_2010_count - bugs_reported_2010_count) < 0, 0, comments_all_bugs_2010_count - bugs_reported_2010_count),
											 comments_all_bugs_2011_count = safe_ifelse((comments_all_bugs_2011_count - bugs_reported_2011_count) < 0, 0, comments_all_bugs_2011_count - bugs_reported_2011_count),
											 comments_all_bugs_2012_count = safe_ifelse((comments_all_bugs_2012_count - bugs_reported_2012_count) < 0, 0, comments_all_bugs_2012_count - bugs_reported_2012_count),
											 comments_all_bugs_2013_count = safe_ifelse((comments_all_bugs_2013_count - bugs_reported_2013_count) < 0, 0, comments_all_bugs_2013_count - bugs_reported_2013_count),
											 comments_all_bugs_all_count  = safe_ifelse((comments_all_bugs_all_count  - bugs_reported_count)      < 0, 0, comments_all_bugs_all_count  - bugs_reported_count)); 
    


# PROFILES-ACTIVITY-BUG_TYPES_YEAR
# Determine the number of activities by each user on each type of bug for each year in the dataset
# Types are rep_platform, op_sys, and classification, 
# Target milestone is left out since we use "per year" instead and they're correlated
# Product & component are left out because there are far too many of them and would lead to 10,000+ columns being added
# Manual inspection reveals year range is 1998 to 2013, but we'll try to detect automatically this time
# That means 15 (years) * 65 (distinct types) new columns added
# We want the result to be a data table with the first column being userid
# And the other columns being activity_<TYPE>_<YEAR>_count
# We'll use data.table::dcast to create the necessary tables for each one

# Select just the columns we want to track on, namely year, who, and types
activity_type_year <- select(activity_base, who, 	bug_when_year = bug_when, bug_rep_platform,  bug_op_sys, bug_classification_name);
										
											
# Mutate the bug_when_year column to be just the year
# Also add a previx to each type and suffix to year with text to make the column names easier to understand
activity_type_year <- mutate(activity_type_year, bug_when_year 			 = paste0(chron::years(bug_when_year), "_count"),
												 bug_rep_platform		 = paste0("activity_rep_platform_", 			bug_rep_platform),
												 bug_op_sys				 = paste0("activity_op_sys_", 					bug_op_sys),
												 bug_classification_name = paste0("activity_product_classification_", 	bug_classification_name));
												 

												 
# Use data.table::dcast() to recast the table with each row as a single user id, and each column a combination of type + year
# Start with type rep_platform, then repeat with op_sys, and classification_name												 
activity_rep_platform_dcast 	<- data.table::dcast(activity_type_year, who ~ bug_rep_platform 		+ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

activity_op_sys_dcast 			<- data.table::dcast(activity_type_year, who ~ bug_op_sys 				+ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);

activity_classification_dcast 	<- data.table::dcast(activity_type_year, who ~ bug_classification_name 	+ bug_when_year, drop=FALSE, value.var="bug_when_year", fun=length);
								   
								  
# Merge each resulting table with profiles_working table by userid & who
setkey(activity_rep_platform_dcast, 	who);
setkey(activity_op_sys_dcast, 			who);
setkey(activity_classification_dcast, 	who);
setkey(profiles_working,				userid);

# Because there are so many new columns being added, instead of creating a long list of ifelse looking NA values to set to zero, we'll do the merge in three stages
# The first stage merges against the whole profiles_working$userid column alone, creating a table with just the new columns and userid
# Second, we replace all the NA values with 0
# Third, we merge the NA-free table with the profiles_working table

# Step 1
profiles_working_userids <- select(profiles_working, userid);
setkey(profiles_working_userids, userid);

profiles_working_new_columns <- merge(profiles_working_userids, 	activity_rep_platform_dcast, 	by.x="userid", by.y="who", all.x=TRUE);
profiles_working_new_columns <- merge(profiles_working_new_columns, activity_op_sys_dcast, 			by.x="userid", by.y="who", all.x=TRUE);
profiles_working_new_columns <- merge(profiles_working_new_columns, activity_classification_dcast,	by.x="userid", by.y="who", all.x=TRUE);

# Step 2 - Using data.table's convenient format
profiles_working_new_columns[is.na(profiles_working_new_columns)] <- 0;

# Step 3
profiles_working <- merge(profiles_working, profiles_working_new_columns, by="userid", all.x=TRUE);

						   


# PROFILES-LONGDESCS-BUG_SEVERITY_COMMENTS
# (Count the number of comments each user made on bugs of each severity level)
# This count includes comments that are "automatic" as the result of an action by the user
# As a result, not all "comments" necessarily contain text, but all are related to deliberate user action

# Should be no NA entries possible, but a small number (currently only 1 out of ~10M entries) show up, 
# Leave them as is. They'll be imputed later as necessary as they are correctly "NA".
					
# Drop all the columns of the longdescs table other than "who" and bug_severity
# Also filter out any NA entries to not screw up bug_severity levels
longdescs_working_who_severity <- select(filter(longdescs_base, !(is.na(bug_severity))), who, bug_severity);
					
# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the comment count for each bug severity level, defaulting to 0 if no bugs of that severity were commented on
longdescs_working_who_severity_recast <- dcast(longdescs_working_who_severity, who ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length, fill=0);


# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
longdescs_working_who_severity_recast <- transmute(longdescs_working_who_severity_recast,  	
														     who 									= who,
														     comments_bugs_enhancement_count 	= if (exists('enhancement',	where = longdescs_working_who_severity_recast)) enhancement 	else 0,
														     comments_bugs_trivial_count		= if (exists('trivial',		where = longdescs_working_who_severity_recast)) trivial 		else 0,
														     comments_bugs_minor_count			= if (exists('minor',		where = longdescs_working_who_severity_recast)) minor 			else 0,
														     comments_bugs_normal_count		= if (exists('normal',		where = longdescs_working_who_severity_recast)) normal 			else 0,
														     comments_bugs_major_count			= if (exists('major',		where = longdescs_working_who_severity_recast)) major 			else 0,
														     comments_bugs_critical_count		= if (exists('critical',	where = longdescs_working_who_severity_recast)) critical 		else 0,
														     comments_bugs_blocker_count		= if (exists('blocker',		where = longdescs_working_who_severity_recast)) blocker 		else 0);

# Merge the longdescs_working_who_severity_recast and profiles_working tables based on who and userid to add the severity types comments count columns
setkey(longdescs_working_who_severity_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, longdescs_working_who_severity_recast, by.x="userid", by.y="who", all.x=TRUE);

# NA values mean that the user did not make any comments, so change it to 0
profiles_working <- mutate(profiles_working, comments_bugs_enhancement_count 	= safe_ifelse(is.na(comments_bugs_enhancement_count),	0, comments_bugs_enhancement_count),
                                             comments_bugs_trivial_count		= safe_ifelse(is.na(comments_bugs_trivial_count),		0, comments_bugs_trivial_count),
                                             comments_bugs_minor_count			= safe_ifelse(is.na(comments_bugs_minor_count), 		0, comments_bugs_minor_count),		
                                             comments_bugs_normal_count		= safe_ifelse(is.na(comments_bugs_normal_count),		0, comments_bugs_normal_count),	
                                             comments_bugs_major_count			= safe_ifelse(is.na(comments_bugs_major_count),		0, comments_bugs_major_count),		
                                             comments_bugs_critical_count		= safe_ifelse(is.na(comments_bugs_critical_count),		0, comments_bugs_critical_count),	
                                             comments_bugs_blocker_count		= safe_ifelse(is.na(comments_bugs_blocker_count),		0, comments_bugs_blocker_count));


# PROFILES-VOTES-BUG_SEVERITY
# (Count the votes made by each user on bugs of each severity level)

# Drop all the columns of the votes table other than "who" and bug_severity
# Also filter out any NA entries to not screw up bug_severity levels
votes_working_who_severity <- select(filter(votes_base, !(is.na(bug_severity))), who, bug_severity);
					
# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the votes count for each bug severity level, defaulting to 0 if no bugs of that severity were voted for by that user
votes_working_who_severity_recast <- dcast(votes_working_who_severity, who ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
votes_working_who_severity_recast <- transmute(votes_working_who_severity_recast,  	
														     who 									= who,
														     votes_bugs_enhancement_count 	= if (exists('enhancement',	where = votes_working_who_severity_recast)) enhancement 	else 0,
														     votes_bugs_trivial_count		= if (exists('trivial',		where = votes_working_who_severity_recast)) trivial 		else 0,
														     votes_bugs_minor_count		= if (exists('minor',		where = votes_working_who_severity_recast)) minor 			else 0,
														     votes_bugs_normal_count		= if (exists('normal',		where = votes_working_who_severity_recast)) normal 			else 0,
														     votes_bugs_major_count		= if (exists('major',		where = votes_working_who_severity_recast)) major 			else 0,
														     votes_bugs_critical_count		= if (exists('critical',	where = votes_working_who_severity_recast)) critical 		else 0,
														     votes_bugs_blocker_count		= if (exists('blocker',		where = votes_working_who_severity_recast)) blocker 		else 0);

# Mutate to add the overall count of votes by each user on all types of bugs
votes_working_who_severity_recast <- mutate(votes_working_who_severity_recast,
																	   votes_all_bugs_count =  votes_bugs_enhancement_count 	+
																	                                votes_bugs_trivial_count		+
																	                                votes_bugs_minor_count			+
																	                                votes_bugs_normal_count		+
																	                                votes_bugs_major_count			+
																	                                votes_bugs_critical_count		+
																	                                votes_bugs_blocker_count);
																	   																	   
# Merge the votes_working_who_severity_recast and profiles_working tables based on who and userid to add the severity types votes count columns
setkey(votes_working_who_severity_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, votes_working_who_severity_recast, by.x="userid", by.y="who", all.x=TRUE);

# NA values mean that the user did not vote on any bugs, so change it to 0
profiles_working <- mutate(profiles_working, votes_bugs_enhancement_count 	= safe_ifelse(is.na(votes_bugs_enhancement_count),	0, votes_bugs_enhancement_count),
                                             votes_bugs_trivial_count		= safe_ifelse(is.na(votes_bugs_trivial_count),		0, votes_bugs_trivial_count),
                                             votes_bugs_minor_count		= safe_ifelse(is.na(votes_bugs_minor_count), 		0, votes_bugs_minor_count),		
                                             votes_bugs_normal_count		= safe_ifelse(is.na(votes_bugs_normal_count),		0, votes_bugs_normal_count),	
                                             votes_bugs_major_count		= safe_ifelse(is.na(votes_bugs_major_count),		0, votes_bugs_major_count),		
                                             votes_bugs_critical_count		= safe_ifelse(is.na(votes_bugs_critical_count),	0, votes_bugs_critical_count),	
                                             votes_bugs_blocker_count		= safe_ifelse(is.na(votes_bugs_blocker_count),		0, votes_bugs_blocker_count),
											 votes_all_bugs_count			= safe_ifelse(is.na(votes_all_bugs_count), 		0, votes_all_bugs_count));
	
	
# PROFILES-VOTES-BUG_PRIORITY
# (Count the votes made by each user on bugs of each priority level)	

# Drop all the columns of the votes_working table other than "who" and priority
# Also filter out any NA entries to not screw up priority levels
votes_working_who_priority <- select(filter(votes_base, !(is.na(bug_priority))), who, priority = bug_priority);	

# Add a prefix to the priority types to make the column names clearer in the dcast
votes_working_who_priority <- mutate(votes_working_who_priority, priority = paste0("votes_bugs_priority_", priority, "_count"));


# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the votes count for each bug priority level, defaulting to 0 if no bugs of that priority were voted for by that user
votes_working_who_priority_recast <- dcast(votes_working_who_priority, who ~ priority, drop=FALSE, value.var="priority", fun=length, fill=0);

# Because there are so many new columns being added, instead of creating a long list of ifelse looking NA values to set to zero, we'll do the merge in three stages
# The first stage merges against the whole profiles_working$userid column alone, creating a table with just the new columns and userid
# Second, we replace all the NA values with 0
# Third, we merge the NA-free table with the profiles_working table

# Step 1
profiles_working_userids <- select(profiles_working, userid);
setkey(profiles_working_userids, userid);

profiles_working_new_votes_columns <- merge(profiles_working_userids, votes_working_who_priority_recast, by.x="userid", by.y="who", all.x=TRUE);

# Step 2 - Using data.table's convenient format
profiles_working_new_votes_columns[is.na(profiles_working_new_votes_columns)] <- 0;

# Step 3
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, profiles_working_new_votes_columns, by="userid", all.x=TRUE);



# PROFILES-CC-BUG_SEVERITY
# (Count number of bugs that each user is following for each bug severity level)

# Drop all the columns of the CC table other than "who" and bug_severity
# Also filter out any NA entries to not screw up bug_severity levels
cc_working_who_severity <- select(filter(cc_base, !(is.na(bug_severity))), who, bug_severity);
					
# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the cc count for each bug severity level, defaulting to 0 if no bugs of that severity were followed by that user
cc_working_who_severity_recast <- dcast(cc_working_who_severity, who ~ bug_severity, drop=FALSE, value.var="bug_severity", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
cc_working_who_severity_recast <- transmute(cc_working_who_severity_recast,  	
														     who 								= who,
														     cc_bugs_enhancement_count 	= if (exists('enhancement',	where = cc_working_who_severity_recast)) enhancement 	else 0,
														     cc_bugs_trivial_count			= if (exists('trivial',		where = cc_working_who_severity_recast)) trivial 		else 0,
														     cc_bugs_minor_count			= if (exists('minor',		where = cc_working_who_severity_recast)) minor 			else 0,
														     cc_bugs_normal_count			= if (exists('normal',		where = cc_working_who_severity_recast)) normal 		else 0,
														     cc_bugs_major_count			= if (exists('major',		where = cc_working_who_severity_recast)) major 			else 0,
														     cc_bugs_critical_count		= if (exists('critical',	where = cc_working_who_severity_recast)) critical 		else 0,
														     cc_bugs_blocker_count			= if (exists('blocker',		where = cc_working_who_severity_recast)) blocker 		else 0);

# Mutate to add the overall count of cc's by each user on all types of bugs
cc_working_who_severity_recast <- mutate(cc_working_who_severity_recast, cc_all_bugs_count =  cc_bugs_enhancement_count 	+
																	                               cc_bugs_trivial_count		+
																	                               cc_bugs_minor_count			+
																	                               cc_bugs_normal_count		+
																	                               cc_bugs_major_count			+
																	                               cc_bugs_critical_count		+
																	                               cc_bugs_blocker_count);
																	   																	   
# Merge the cc_working_who_severity_recast and profiles_working tables based on who and userid to add the severity types cc count columns
setkey(cc_working_who_severity_recast, who);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, cc_working_who_severity_recast, by.x="userid", by.y="who", all.x=TRUE);

# NA values mean that the user did not cc any bugs, so change it to 0
profiles_working <- mutate(profiles_working, cc_bugs_enhancement_count 	= safe_ifelse(is.na(cc_bugs_enhancement_count),	0, cc_bugs_enhancement_count),
                                             cc_bugs_trivial_count			= safe_ifelse(is.na(cc_bugs_trivial_count),		0, cc_bugs_trivial_count),
                                             cc_bugs_minor_count			= safe_ifelse(is.na(cc_bugs_minor_count), 			0, cc_bugs_minor_count),		
                                             cc_bugs_normal_count			= safe_ifelse(is.na(cc_bugs_normal_count),			0, cc_bugs_normal_count),	
                                             cc_bugs_major_count			= safe_ifelse(is.na(cc_bugs_major_count),			0, cc_bugs_major_count),		
                                             cc_bugs_critical_count		= safe_ifelse(is.na(cc_bugs_critical_count),		0, cc_bugs_critical_count),	
                                             cc_bugs_blocker_count			= safe_ifelse(is.na(cc_bugs_blocker_count),		0, cc_bugs_blocker_count),
											 cc_all_bugs_count				= safe_ifelse(is.na(cc_all_bugs_count), 			0, cc_all_bugs_count));
	
	
# PROFILES-CC-BUG_PRIORITY
# (Count the cc's of each user of bugs of each priority level)	
	
# Drop all the columns of the CC table other than "who" and priority
# Also filter out any NA entries to not screw up priority levels
cc_working_who_priority <- select(filter(cc_base, !(is.na(bug_priority))), who, priority = bug_priority);	

# Add a prefix to the priority types to make the column names clearer in the dcast
cc_working_who_priority <- mutate(cc_working_who_priority, priority = paste0("cc_bugs_priority_", priority, "_count"));


# Use data.table's dcast() function to recast the table such that each row is a single "who" and there
# is a column with the cc count for each bug priority level, defaulting to 0 if no bugs of that priority were cc'ed by that user
cc_working_who_priority_recast <- dcast(cc_working_who_priority, who ~ priority, drop=FALSE, value.var="priority", fun=length, fill=0);

# Because there are so many new columns being added, instead of creating a long list of ifelse looking NA values to set to zero, we'll do the merge in three stages
# The first stage merges against the whole profiles_working$userid column alone, creating a table with just the new columns and userid
# Second, we replace all the NA values with 0
# Third, we merge the NA-free table with the profiles_working table

# Step 1
profiles_working_userids <- select(profiles_working, userid);
setkey(profiles_working_userids, userid);

profiles_working_new_cc_columns <- merge(profiles_working_userids, cc_working_who_priority_recast, by.x="userid", by.y="who", all.x=TRUE);

# Step 2 - Using data.table's convenient format
profiles_working_new_cc_columns[is.na(profiles_working_new_cc_columns)] <- 0;

# Step 3
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, profiles_working_new_cc_columns, by="userid", all.x=TRUE);
	
	
# PROFILES-BUGS_REPORTED_OUTCOME
# (Count the number of bugs that each user reported for each outcome status of fixed, not_fixed, and pending)

# Isolate the reporter & outcome columns of bugs_working
bugs_working_reporter_outcome <- select(bugs_working, reporter, outcome, attachments_patch_count);
				
# Use data.table's dcast() function to recast the table such that each row is a single "reporter" and there
# is a column with the count of each outcome for all the bugs each user reported, defaulting to 0 if the reporter has no bugs of that outcome level
bugs_working_reporter_outcome_recast <- dcast(bugs_working_reporter_outcome, reporter ~ outcome, drop=FALSE, value.var="outcome", fun=length, fill=0);

# We also want to catch cases where bugs where fixed with at least one patch, so we create a second dcast for that purpose
bugs_working_reporter_outcome_patch_recast <- dcast(bugs_working_reporter_outcome, reporter ~ (outcome == "fixed") + (attachments_patch_count > 0), drop=FALSE, value.var="outcome", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of outcome levels for the given dataset
bugs_working_reporter_outcome_recast <- transmute(bugs_working_reporter_outcome_recast,  	
												  reporter 								= reporter,
												  bugs_reported_fixed_count		= if (exists('fixed',		where = bugs_working_reporter_outcome_recast)) fixed 	 else 0,
												  bugs_reported_not_fixed_count	= if (exists('not_fixed',	where = bugs_working_reporter_outcome_recast)) not_fixed else 0,
												  bugs_reported_pending_count		= if (exists('pending',		where = bugs_working_reporter_outcome_recast)) pending 	 else 0);

# Repeat with fixed + patch check
bugs_working_reporter_outcome_patch_recast <- transmute(bugs_working_reporter_outcome_patch_recast, 
														reporter 										  = reporter,
														bugs_reported_fixed_at_least_one_patch_count = if (exists('TRUE_TRUE', where = bugs_working_reporter_outcome_patch_recast)) TRUE_TRUE else 0);
														
									   																	   
# Merge the bugs_working_reporter_outcome_recast and profiles_working tables based on reporter and userid to add the outcome count columns
setkey(bugs_working_reporter_outcome_recast, 	   reporter);
setkey(bugs_working_reporter_outcome_patch_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_outcome_recast, 		by.x="userid", by.y="reporter", all.x=TRUE);
profiles_working <- merge(profiles_working, bugs_working_reporter_outcome_patch_recast, by.x="userid", by.y="reporter", all.x=TRUE);

# NA values mean that the user did not report any bugs, so change it to 0
profiles_working <- mutate(profiles_working, bugs_reported_fixed_count						= safe_ifelse(is.na(bugs_reported_fixed_count),	 				0, bugs_reported_fixed_count),	
                                             bugs_reported_not_fixed_count					= safe_ifelse(is.na(bugs_reported_not_fixed_count), 				0, bugs_reported_not_fixed_count),
											 bugs_reported_pending_count					= safe_ifelse(is.na(bugs_reported_pending_count),   				0, bugs_reported_pending_count),
											 bugs_reported_fixed_at_least_one_patch_count  = safe_ifelse(is.na(bugs_reported_fixed_at_least_one_patch_count), 0, bugs_reported_fixed_at_least_one_patch_count));
											 											 

# PROFILES-BUGS_ASSIGNED_TO_OUTCOME
# (Count the number of bugs to which each user is assigned for each outcome status of fixed, not_fixed, and pending)

# Isolate the assigned_to & outcome columns of bugs_working
bugs_working_assigned_to_outcome <- select(bugs_working, assigned_to, outcome, attachments_patch_count);
				
# Use data.table's dcast() function to recast the table such that each row is a single "assigned_to" and there
# is a column with the count of each outcome for all the bugs each user was assigned_to, defaulting to 0 if the user was not assigned any bugs of that outcome level
bugs_working_assigned_to_outcome_recast <- dcast(bugs_working_assigned_to_outcome, assigned_to ~ outcome, drop=FALSE, value.var="outcome", fun=length, fill=0);

# We also want to catch cases where bugs where fixed with at least one patch, so we create a second dcast for that purpose
bugs_working_assigned_to_outcome_patch_recast <- dcast(bugs_working_assigned_to_outcome, assigned_to ~ (outcome == "fixed") + (attachments_patch_count > 0), drop=FALSE, value.var="outcome", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of outcome levels for the given dataset
bugs_working_assigned_to_outcome_recast <- transmute(bugs_working_assigned_to_outcome_recast,  	
														     assigned_to 								= assigned_to,
														     bugs_assigned_to_fixed_count			= if (exists('fixed',		where = bugs_working_assigned_to_outcome_recast)) fixed 		else 0,
														     bugs_assigned_to_not_fixed_count		= if (exists('not_fixed',	where = bugs_working_assigned_to_outcome_recast)) not_fixed 	else 0,
														     bugs_assigned_to_pending_count		= if (exists('pending',		where = bugs_working_assigned_to_outcome_recast)) pending 		else 0);
	
# Repeat with fixed + patch check
bugs_working_assigned_to_outcome_patch_recast <- transmute(bugs_working_assigned_to_outcome_patch_recast, 
														   assigned_to 										    = assigned_to,
														   bugs_assigned_to_fixed_at_least_one_patch_count = if (exists('TRUE_TRUE', where = bugs_working_assigned_to_outcome_patch_recast)) TRUE_TRUE else 0);	
	
# Merge the bugs_working_assigned_to_outcome_recast and profiles_working tables based on assigned_to and userid to add the outcome count columns
setkey(bugs_working_assigned_to_outcome_recast, 	  assigned_to);
setkey(bugs_working_assigned_to_outcome_patch_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_outcome_recast, 	   by.x="userid", by.y="assigned_to", all.x=TRUE);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_outcome_patch_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

# NA values mean that the user did not report any bugs, so change it to 0
profiles_working <- mutate(profiles_working, bugs_assigned_to_fixed_count					  = safe_ifelse(is.na(bugs_assigned_to_fixed_count),     				 0, bugs_assigned_to_fixed_count),	
                                             bugs_assigned_to_not_fixed_count				  = safe_ifelse(is.na(bugs_assigned_to_not_fixed_count), 				 0, bugs_assigned_to_not_fixed_count),
											 bugs_assigned_to_pending_count				  = safe_ifelse(is.na(bugs_assigned_to_pending_count),   				 0, bugs_assigned_to_pending_count),
											 bugs_assigned_to_fixed_at_least_one_patch_count = safe_ifelse(is.na(bugs_assigned_to_fixed_at_least_one_patch_count), 0, bugs_assigned_to_fixed_at_least_one_patch_count));

											 
# PROFILES-BUGS_QA_CONTACT_OUTCOME
# (Count the number of bugs for which each user is set as qa_contact for each outcome status of fixed, not_fixed, and pending)

# Isolate the qa_contact & outcome columns of bugs_working
bugs_working_qa_contact_outcome <- select(bugs_working, qa_contact, outcome, attachments_patch_count);
				
# Use data.table's dcast() function to recast the table such that each row is a single "qa_contact" and there
# is a column with the count of each outcome for all the bugs for which each user is set as qa_contact, defaulting to 0 if the user was not set as qa_contact for any bugs of that outcome level
bugs_working_qa_contact_outcome_recast <- dcast(bugs_working_qa_contact_outcome, qa_contact ~ outcome, drop=FALSE, value.var="outcome", fun=length, fill=0);

# We also want to catch cases where bugs where fixed with at least one patch, so we create a second dcast for that purpose
bugs_working_qa_contact_outcome_patch_recast <- dcast(bugs_working_qa_contact_outcome, qa_contact ~ (outcome == "fixed") + (attachments_patch_count > 0), drop=FALSE, value.var="outcome", fun=length, fill=0);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of outcome levels for the given dataset
bugs_working_qa_contact_outcome_recast <- transmute(bugs_working_qa_contact_outcome_recast,  	
														     qa_contact 							= qa_contact,
														     bugs_qa_contact_fixed_count		= if (exists('fixed',		where = bugs_working_qa_contact_outcome_recast)) fixed 		else 0,
														     bugs_qa_contact_not_fixed_count	= if (exists('not_fixed',	where = bugs_working_qa_contact_outcome_recast)) not_fixed 	else 0,
														     bugs_qa_contact_pending_count		= if (exists('pending',		where = bugs_working_qa_contact_outcome_recast)) pending 	else 0);
	
# Repeat with fixed + patch check
bugs_working_qa_contact_outcome_patch_recast <- transmute(bugs_working_qa_contact_outcome_patch_recast, 
														   qa_contact 										   = qa_contact,
														   bugs_qa_contact_fixed_at_least_one_patch_count = if (exists('TRUE_TRUE', where = bugs_working_qa_contact_outcome_patch_recast)) TRUE_TRUE else 0);		
	
# Merge the bugs_working_qa_contact_outcome_recast and profiles_working tables based on qa_contact and userid to add the outcome count columns
setkey(bugs_working_qa_contact_outcome_recast, 		 qa_contact);
setkey(bugs_working_qa_contact_outcome_patch_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_outcome_recast, 	  by.x="userid", by.y="qa_contact", all.x=TRUE);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_outcome_patch_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

# NA values mean that the user did not report any bugs, so change it to 0
profiles_working <- mutate(profiles_working, bugs_qa_contact_fixed_count					 = safe_ifelse(is.na(bugs_qa_contact_fixed_count),					   0, bugs_qa_contact_fixed_count),	
                                             bugs_qa_contact_not_fixed_count				 = safe_ifelse(is.na(bugs_qa_contact_not_fixed_count),				   0, bugs_qa_contact_not_fixed_count),
											 bugs_qa_contact_pending_count					 = safe_ifelse(is.na(bugs_qa_contact_pending_count),				   0, bugs_qa_contact_pending_count),
											 bugs_qa_contact_fixed_at_least_one_patch_count = safe_ifelse(is.na(bugs_qa_contact_fixed_at_least_one_patch_count), 0, bugs_qa_contact_fixed_at_least_one_patch_count));

	
# BUGS-DEPENDENCIES_BLOCKING
# (Count the number of bugs each bug is blocking)

# Import the dependencies table. We only need the "dependson" column for the count
dependencies_dependson <- select(dependencies_base, dependson);

# Use DPLYR's group_by() function to organize the dependencies_dependson table according to the bugs doing the blocking
dependencies_dependson_grouped <- group_by(dependencies_dependson, dependson);

# Use DPLYR's summarize() function to count number of bugs that each bug is blocking
dependencies_dependson_grouped_summary <- summarize(dependencies_dependson_grouped, bugs_blocking_count = n());		
			
# Merge the dependencies_dependson_grouped_summary table with bugs_working table according to bug_id to add count column
setkey(dependencies_dependson_grouped_summary, dependson);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, dependencies_dependson_grouped_summary, by.x="bug_id", by.y="dependson", all.x=TRUE);

# For any NA entries in the bugs_blocking_count column, that means the the bug is not blocking any other bugs, so set it to zero
bugs_working <- mutate(bugs_working, bugs_blocking_count = safe_ifelse(is.na(bugs_blocking_count), 0, bugs_blocking_count));
		

# BUGS-DEPENDENCIES_BLOCKED_BY
# (Count the number of bugs each bug is blocked by)

# Import the dependencies table. We only need the "blocked" column for the count
dependencies_blocked <- select(dependencies_base, blocked);

# Use DPLYR's group_by() function to organize the dependencies_blocked table according to the person bugs that have been blocked by other bugs
dependencies_blocked_grouped <- group_by(dependencies_blocked, blocked);

# Use DPLYR's summarize() function to count number of bugs that are blocking each bug
dependencies_blocked_grouped_summary <- summarize(dependencies_blocked_grouped, bugs_blocked_by_count = n());		
			
# Merge the dependencies_blocked_grouped_summary table with bugs_working table according to bug_id to add count column
setkey(dependencies_blocked_grouped_summary, blocked);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, dependencies_blocked_grouped_summary, by.x="bug_id", by.y="blocked", all.x=TRUE);

# For any NA entries in the bugs_blocked_by_count column, that means the the bug is not blocked by any other bugs, so set it to zero
bugs_working <- mutate(bugs_working, bugs_blocked_by_count = safe_ifelse(is.na(bugs_blocked_by_count), 0, bugs_blocked_by_count));		


# BUGS-KEYWORDS_TOP
# (Check to see if the bug has one or more top 5/10/25/50 keywords set)

bugs_working <- mutate(bugs_working, has_top_3_keyword	= as.logical(bug_id %in% filter(keywords_base, is_top_3_keyword== TRUE)$bug_id),
									 has_top_10_keyword = as.logical(bug_id %in% filter(keywords_base, is_top_10_keyword==TRUE)$bug_id),
									 has_top_25_keyword = as.logical(bug_id %in% filter(keywords_base, is_top_25_keyword==TRUE)$bug_id),
									 has_top_50_keyword = as.logical(bug_id %in% filter(keywords_base, is_top_50_keyword==TRUE)$bug_id));


# CLEAN UP


# Set global variables for other functions
profiles_interactions 	<<- profiles_working;
bugs_interactions 		<<- bugs_working;

} # End operationalize_interactions function


# OPERATIONALIZE CALCULATED VARIABLES

operationalize_calculated_variables <- function() {

# Import profiles & bugs tables that we'll modify in this function
profiles_working 	<- profiles_interactions;
bugs_working 		<- bugs_interactions;	


# BUGS-ACTIVITY_DAYS_BETWEEN_CALCULATIONS
							 
# Try to calculate the time between the following:
# 1)  Bug creation to last_resolved					days_to_last_resolved								  (uses cf_last_resolved value)								
# 2)  Bug creation to resolution					days_to_resolution									  (uses censor_ts value)
# 3)  Bug creation to first assignment				days_to_first_assignment
# 4)  Bug creation to last assignment				days_to_last_assignment
# 5)  Bug creation to first qa_contact set			days_to_first_qa_contact_set
# 6)  Bug creation to last qa_contact set			days_to_last_qa_contact_set
# 7)  First assignment to last assignment:			days_from_first_assignment_to_last_assignment
# 7)  First assignment to first qa_contact set:		days_from_first_assignment_to_first_qa_contact_set
# 8)  First assignment to last qa_contact set:		days_from_first_assignment_to_last_qa_contact_set
# 10) Last assignment to first qa_contact set:		days_from_last_assignment_to_first_qa_contact_set
# 11) Last assignment to last qa_contact set:		days_from_last_assignment_to_last_qa_contact_set
# 12) First qa_contact set to last qa_contact set:	days_from_first_qa_contact_set_to_last_qa_contact_set
# 13) First assignment to last_resolved:			days_from_first_assignment_to_last_resolved 		  (uses cf_last_resolved value)
# 14) First assignment to resolution:				days_from_first_assignment_to_resolution			  (uses censor_ts value)
# 15) Last assignment to last_resolved:				days_from_last_assignment_to_last_resolved 			  (uses cf_last_resolved value)
# 16) Last assignment to resolution:				days_from_last_assignment_to_resolution				  (uses censor_ts value)
# 17) First qa_contact set to last_resolved:		days_from_first_qa_contact_set_to_last_resolved 	  (uses cf_last_resolved value)
# 18) First qa_contact set to resolution:			days_from_first_qa_contact_set_to_resolution		  (uses censor_ts value)
# 19) Last qa_contact set to last_resolved:			days_from_last_qa_contact_set_to_last_resolved 		  (uses cf_last_resolved value)
# 20) Last qa_contact set to resolution:			days_from_last_qa_contact_set_to_resolution			  (uses censor_ts value)

# Calculate the days between first and last assignment
# If the result is negative, it means we have bad values, so set it to NA
# Bad values arise from bug lifecycle sequence breaking or manual changes to the database
bugs_working <- mutate(bugs_working, days_to_last_resolved 									= safe_ifelse(is.na(   cf_last_resolved), 		as.double(difftime(DATABASE_END_TIMESTAMP, creation_ts, units = "secs")) / 86400,
																								as.double(difftime(cf_last_resolved, 		creation_ts, units = "secs"))  / 86400),
									 days_to_resolution 									= safe_ifelse(		   censor_ts 			< 	creation_ts, 			NA,
																								as.double(difftime(censor_ts,			 	creation_ts, 		 units = "secs")) / 86400),
									 days_to_first_assignment								= safe_ifelse(		   first_assignment_ts	<	creation_ts, 			NA,
																								as.double(difftime(first_assignment_ts,		creation_ts,		 units = "secs")) / 86400),
									 days_to_last_assignment								= safe_ifelse(		   last_assignment_ts	<	creation_ts, 			NA,
																								as.double(difftime(last_assignment_ts,		creation_ts,		 units = "secs")) / 86400),
									 days_to_first_qa_contact_set							= safe_ifelse(		   first_qa_contact_ts	<	creation_ts, 			NA,
																								as.double(difftime(first_qa_contact_ts,		creation_ts,		 units = "secs")) / 86400),
									 days_to_last_qa_contact_set							= safe_ifelse(		   last_qa_contact_ts	<	creation_ts, 			NA,
																								as.double(difftime(last_qa_contact_ts,		creation_ts,		 units = "secs")) / 86400),
									 days_from_first_assignment_to_last_assignment 			= safe_ifelse(		   last_assignment_ts 	< 	first_assignment_ts, 	NA, 
																								as.double(difftime(last_assignment_ts, 		first_assignment_ts, units = "secs")) / 86400),
																								
# Since there's no reason a qa_contact can't be set before assignment, even though it doesn't match with the bug lifecycle, we can allow negative days values

									 days_from_first_assignment_to_first_qa_contact_set 	= as.double(difftime(first_qa_contact_ts, 		first_assignment_ts, units = "secs")) / 86400, 
									 days_from_first_assignment_to_last_qa_contact_set 		= as.double(difftime(last_qa_contact_ts, 		first_assignment_ts, units = "secs")) / 86400,
									 days_from_last_assignment_to_first_qa_contact_set 		= as.double(difftime(first_qa_contact_ts, 		last_assignment_ts,  units = "secs")) / 86400,
									 days_from_last_assignment_to_last_qa_contact_set 		= as.double(difftime(last_qa_contact_ts, 		last_assignment_ts,  units = "secs")) / 86400,
																								
									 days_from_first_qa_contact_set_to_last_qa_contact_set	= safe_ifelse(		   last_qa_contact_ts 	< 	first_qa_contact_ts, 	NA, 
																								as.double(difftime(last_qa_contact_ts, 		first_qa_contact_ts, units = "secs")) / 86400),
									
# Since the resolution values may not be the final resolution (usually "resolution" is the first and "last_resolved" is the last, but it can vary due to sequence hopping)
# negative values are possible and interpretable for assignment and qa_contact setting

									 days_from_first_assignment_to_last_resolved 			= as.double(difftime(cf_last_resolved, 			first_assignment_ts, units = "secs")) / 86400,
									 days_from_first_assignment_to_resolution 				= as.double(difftime(censor_ts,			 		first_assignment_ts, units = "secs")) / 86400,
									 days_from_last_assignment_to_last_resolved 			= as.double(difftime(cf_last_resolved, 			last_assignment_ts,  units = "secs")) / 86400,
									 days_from_last_assignment_to_resolution 				= as.double(difftime(censor_ts,			 		last_assignment_ts,  units = "secs")) / 86400,
									 days_from_first_qa_contact_set_to_last_resolved 		= as.double(difftime(cf_last_resolved, 			first_qa_contact_ts, units = "secs")) / 86400,
									 days_from_first_qa_contact_set_to_resolution 			= as.double(difftime(censor_ts,			 		first_qa_contact_ts, units = "secs")) / 86400,
									 days_from_last_qa_contact_set_to_last_resolved 		= as.double(difftime(cf_last_resolved, 			last_qa_contact_ts,  units = "secs")) / 86400,
									 days_from_last_qa_contact_set_to_resolution 			= as.double(difftime(censor_ts,			 		last_qa_contact_ts,  units = "secs")) / 86400);
																								
	
	

	
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
																	  bugs_reported_enhancement_description_mean_length	= if (exists('enhancement',	where = bugs_working_reporter_description_length_severity_recast)) enhancement 	else 0,
																	  bugs_reported_trivial_description_mean_length		= if (exists('trivial',		where = bugs_working_reporter_description_length_severity_recast)) trivial 		else 0,
																	  bugs_reported_minor_description_mean_length			= if (exists('minor',		where = bugs_working_reporter_description_length_severity_recast)) minor 		else 0,
																	  bugs_reported_normal_description_mean_length			= if (exists('normal',		where = bugs_working_reporter_description_length_severity_recast)) normal 		else 0,
																	  bugs_reported_major_description_mean_length			= if (exists('major',		where = bugs_working_reporter_description_length_severity_recast)) major 		else 0,
																	  bugs_reported_critical_description_mean_length		= if (exists('critical',	where = bugs_working_reporter_description_length_severity_recast)) critical 	else 0,
																	  bugs_reported_blocker_description_mean_length		= if (exists('blocker',		where = bugs_working_reporter_description_length_severity_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs for which each user reported
bugs_working_reporter_description_length_severity_recast <- mutate(bugs_working_reporter_description_length_severity_recast,
																	 bugs_reported_all_types_description_mean_length = (bugs_reported_enhancement_description_mean_length +
																	                                                         bugs_reported_trivial_description_mean_length 	+
																	                                                         bugs_reported_minor_description_mean_length 		+	
																	                                                         bugs_reported_normal_description_mean_length 		+
																	                                                         bugs_reported_major_description_mean_length 		+	
																	                                                         bugs_reported_critical_description_mean_length 	+
																	                                                         bugs_reported_blocker_description_mean_length) 	/ 7);
																																   
# NA values mean that the user was not set as reporter for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
bugs_working_reporter_description_length_severity_recast[bugs_working_reporter_description_length_severity_recast <= 0] 		<- NA;
bugs_working_reporter_description_length_severity_recast[is.na(bugs_working_reporter_description_length_severity_recast)] 		<- NA;
																																   
# Merge the bugs_working_reporter_description_length_severity_recast and profiles_working tables based on reporter & userid to add the severity types description mean length columns
setkey(bugs_working_reporter_description_length_severity_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_description_length_severity_recast, by.x="userid", by.y="reporter", all.x=TRUE);


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
															bugs_assigned_to_enhancement_description_mean_length	= if (exists('enhancement',	where = bugs_working_assigned_to_description_length_severity_recast)) enhancement	 else 0,
															bugs_assigned_to_trivial_description_mean_length		= if (exists('trivial',		where = bugs_working_assigned_to_description_length_severity_recast)) trivial 		 else 0,
															bugs_assigned_to_minor_description_mean_length			= if (exists('minor',		where = bugs_working_assigned_to_description_length_severity_recast)) minor 		 else 0,
															bugs_assigned_to_normal_description_mean_length		= if (exists('normal',		where = bugs_working_assigned_to_description_length_severity_recast)) normal 		 else 0,
															bugs_assigned_to_major_description_mean_length			= if (exists('major',		where = bugs_working_assigned_to_description_length_severity_recast)) major 		 else 0,
															bugs_assigned_to_critical_description_mean_length		= if (exists('critical',	where = bugs_working_assigned_to_description_length_severity_recast)) critical 		 else 0,
															bugs_assigned_to_blocker_description_mean_length		= if (exists('blocker',		where = bugs_working_assigned_to_description_length_severity_recast)) blocker 		 else 0);
																		
# Mutate to add the overall mean description length for bugs for which each user was assigned_to
bugs_working_assigned_to_description_length_severity_recast <- mutate(bugs_working_assigned_to_description_length_severity_recast,
																	 bugs_assigned_to_all_types_description_mean_length = (bugs_assigned_to_enhancement_description_mean_length 	+
																															    bugs_assigned_to_trivial_description_mean_length 		+
																															    bugs_assigned_to_minor_description_mean_length 		+	
																															    bugs_assigned_to_normal_description_mean_length 		+
																															    bugs_assigned_to_major_description_mean_length 		+	
																															    bugs_assigned_to_critical_description_mean_length 		+
																															    bugs_assigned_to_blocker_description_mean_length) 		/ 7);
																																   
# NA values mean that the user was not set as assigned_to for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
bugs_working_assigned_to_description_length_severity_recast[bugs_working_assigned_to_description_length_severity_recast <= 0] 		  <- NA;
bugs_working_assigned_to_description_length_severity_recast[is.na(bugs_working_assigned_to_description_length_severity_recast)] 	  <- NA;

																																
# Merge the bugs_working_assigned_to_description_length_severity_recast and profiles_working tables based on assigned_to & userid to add the severity types description mean length columns
setkey(bugs_working_assigned_to_description_length_severity_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_description_length_severity_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);


											 
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
														   bugs_qa_contact_enhancement_description_mean_length	= if (exists('enhancement',	where = bugs_working_qa_contact_description_length_severity_recast)) enhancement 	else 0,
														   bugs_qa_contact_trivial_description_mean_length		= if (exists('trivial',		where = bugs_working_qa_contact_description_length_severity_recast)) trivial 		else 0,
														   bugs_qa_contact_minor_description_mean_length		= if (exists('minor',		where = bugs_working_qa_contact_description_length_severity_recast)) minor 			else 0,
														   bugs_qa_contact_normal_description_mean_length		= if (exists('normal',		where = bugs_working_qa_contact_description_length_severity_recast)) normal 		else 0,
														   bugs_qa_contact_major_description_mean_length		= if (exists('major',		where = bugs_working_qa_contact_description_length_severity_recast)) major 			else 0,
														   bugs_qa_contact_critical_description_mean_length	= if (exists('critical',	where = bugs_working_qa_contact_description_length_severity_recast)) critical 		else 0,
														   bugs_qa_contact_blocker_description_mean_length		= if (exists('blocker',		where = bugs_working_qa_contact_description_length_severity_recast)) blocker 		else 0);

# Mutate to add the overall mean description length for bugs for which each user was qa_contact
bugs_working_qa_contact_description_length_severity_recast <- mutate(bugs_working_qa_contact_description_length_severity_recast,
																	 bugs_qa_contact_all_types_description_mean_length = (bugs_qa_contact_enhancement_description_mean_length +
																	                                                           bugs_qa_contact_trivial_description_mean_length 	+
																	                                                           bugs_qa_contact_minor_description_mean_length 		+	
																	                                                           bugs_qa_contact_normal_description_mean_length 		+
																	                                                           bugs_qa_contact_major_description_mean_length 		+	
																	                                                           bugs_qa_contact_critical_description_mean_length 	+
																	                                                           bugs_qa_contact_blocker_description_mean_length) 	/ 7);

																																   
# NA values mean that the user was not set as qa_contact for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
bugs_working_qa_contact_description_length_severity_recast[bugs_working_qa_contact_description_length_severity_recast <= 0] 		<- NA;
bugs_working_qa_contact_description_length_severity_recast[is.na(bugs_working_qa_contact_description_length_severity_recast)] 		<- NA;																															   
																															   
# Merge the bugs_working_qa_contact_description_length_severity_recast and profiles_working tables based on qa_contact & userid to add the severity types description mean length columns
setkey(bugs_working_qa_contact_description_length_severity_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_description_length_severity_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);



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
														   bugs_reported_enhancement_comments_mean_length	= if (exists('enhancement',	where = bugs_working_reporter_comments_mean_length_severity_recast)) enhancement 	else 0,
														   bugs_reported_trivial_comments_mean_length		= if (exists('trivial',		where = bugs_working_reporter_comments_mean_length_severity_recast)) trivial 		else 0,
														   bugs_reported_minor_comments_mean_length		= if (exists('minor',		where = bugs_working_reporter_comments_mean_length_severity_recast)) minor 			else 0,
														   bugs_reported_normal_comments_mean_length		= if (exists('normal',		where = bugs_working_reporter_comments_mean_length_severity_recast)) normal 		else 0,
														   bugs_reported_major_comments_mean_length		= if (exists('major',		where = bugs_working_reporter_comments_mean_length_severity_recast)) major 			else 0,
														   bugs_reported_critical_comments_mean_length		= if (exists('critical',	where = bugs_working_reporter_comments_mean_length_severity_recast)) critical 		else 0,
														   bugs_reported_blocker_comments_mean_length		= if (exists('blocker',		where = bugs_working_reporter_comments_mean_length_severity_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean comment length for bugs for which each user reported
bugs_working_reporter_comments_mean_length_severity_recast <- mutate(bugs_working_reporter_comments_mean_length_severity_recast,
																	 bugs_reported_all_types_comments_mean_length = (bugs_reported_enhancement_comments_mean_length 	+
																														  bugs_reported_trivial_comments_mean_length 		+
																														  bugs_reported_minor_comments_mean_length 		+	
																														  bugs_reported_normal_comments_mean_length 		+
																														  bugs_reported_major_comments_mean_length 		+	
																														  bugs_reported_critical_comments_mean_length 		+
																														  bugs_reported_blocker_comments_mean_length) 		/ 7);
																																   

# NA values mean that the user was not set as reporter for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
bugs_working_reporter_comments_mean_length_severity_recast[bugs_working_reporter_comments_mean_length_severity_recast <= 0] 		<- NA;
bugs_working_reporter_comments_mean_length_severity_recast[is.na(bugs_working_reporter_comments_mean_length_severity_recast)] 		<- NA;
																																   
# Merge the bugs_working_reporter_comments_mean_length_severity_recast and profiles_working tables based on reporter & userid to add the severity types comment mean length columns
setkey(bugs_working_reporter_comments_mean_length_severity_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_comments_mean_length_severity_recast, by.x="userid", by.y="reporter", all.x=TRUE);



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
															  bugs_assigned_to_enhancement_comments_mean_length	= if (exists('enhancement',	where = bugs_working_assigned_to_comments_mean_length_severity_recast)) enhancement	 else 0,
															  bugs_assigned_to_trivial_comments_mean_length		= if (exists('trivial',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) trivial 	 else 0,
															  bugs_assigned_to_minor_comments_mean_length			= if (exists('minor',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) minor 		 else 0,
															  bugs_assigned_to_normal_comments_mean_length			= if (exists('normal',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) normal 		 else 0,
															  bugs_assigned_to_major_comments_mean_length			= if (exists('major',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) major 		 else 0,
															  bugs_assigned_to_critical_comments_mean_length		= if (exists('critical',	where = bugs_working_assigned_to_comments_mean_length_severity_recast)) critical 	 else 0,
															  bugs_assigned_to_blocker_comments_mean_length		= if (exists('blocker',		where = bugs_working_assigned_to_comments_mean_length_severity_recast)) blocker 	 else 0);
																		
# Mutate to add the overall mean comment length for bugs for which each user was assigned_to
bugs_working_assigned_to_comments_mean_length_severity_recast <- mutate(bugs_working_assigned_to_comments_mean_length_severity_recast,
																	    bugs_assigned_to_all_types_comments_mean_length = (bugs_assigned_to_enhancement_comments_mean_length 	+
																																bugs_assigned_to_trivial_comments_mean_length 		+
																																bugs_assigned_to_minor_comments_mean_length 		+	
																																bugs_assigned_to_normal_comments_mean_length 		+
																																bugs_assigned_to_major_comments_mean_length 		+	
																																bugs_assigned_to_critical_comments_mean_length 	+
																																bugs_assigned_to_blocker_comments_mean_length) 	/ 7);

# NA values mean that the user was not set as assigned_to for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
bugs_working_assigned_to_comments_mean_length_severity_recast[bugs_working_assigned_to_comments_mean_length_severity_recast <= 0] 		  <- NA;
bugs_working_assigned_to_comments_mean_length_severity_recast[is.na(bugs_working_assigned_to_comments_mean_length_severity_recast)] 	  <- NA;
																																
# Merge the bugs_working_assigned_to_comments_mean_length_severity_recast and profiles_working tables based on assigned_to & userid to add the severity types comment mean length columns
setkey(bugs_working_assigned_to_comments_mean_length_severity_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_comments_mean_length_severity_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);


											 
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
														     bugs_qa_contact_enhancement_comments_mean_length	= if (exists('enhancement',	where = bugs_working_qa_contact_comments_mean_length_severity_recast)) enhancement 		else 0,
														     bugs_qa_contact_trivial_comments_mean_length		= if (exists('trivial',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) trivial 			else 0,
														     bugs_qa_contact_minor_comments_mean_length		= if (exists('minor',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) minor 			else 0,
														     bugs_qa_contact_normal_comments_mean_length		= if (exists('normal',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) normal 			else 0,
														     bugs_qa_contact_major_comments_mean_length		= if (exists('major',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) major 			else 0,
														     bugs_qa_contact_critical_comments_mean_length		= if (exists('critical',	where = bugs_working_qa_contact_comments_mean_length_severity_recast)) critical 		else 0,
														     bugs_qa_contact_blocker_comments_mean_length		= if (exists('blocker',		where = bugs_working_qa_contact_comments_mean_length_severity_recast)) blocker 			else 0);

# Mutate to add the overall mean comment length for bugs for which each user was qa_contact
bugs_working_qa_contact_comments_mean_length_severity_recast <- mutate(bugs_working_qa_contact_comments_mean_length_severity_recast,
																	   bugs_qa_contact_all_types_comments_mean_length = (bugs_qa_contact_enhancement_comments_mean_length +
																	                                                          bugs_qa_contact_trivial_comments_mean_length 	+
																	                                                          bugs_qa_contact_minor_comments_mean_length 		+	
																	                                                          bugs_qa_contact_normal_comments_mean_length 		+
																	                                                          bugs_qa_contact_major_comments_mean_length 		+	
																	                                                          bugs_qa_contact_critical_comments_mean_length 	+
																	                                                          bugs_qa_contact_blocker_comments_mean_length) 	/ 7);

# NA values mean that the user was not set as qa_contact for any bugs, so the mean() value has no definition
# It should be correctly left as NA. Further any 0 values indicate the result of exists() check above, so set them to NA which is more correct
# Here we use NA to distinguish between cases where user is not a involved at all from cases where 0 comments exist for those bugs.  It's not ideal, but it's 
# the imputation least likely to bias
bugs_working_qa_contact_comments_mean_length_severity_recast[bugs_working_qa_contact_comments_mean_length_severity_recast <= 0] 		<- NA;
bugs_working_qa_contact_comments_mean_length_severity_recast[is.na(bugs_working_qa_contact_comments_mean_length_severity_recast)] 		<- NA;
																															  
# Merge the bugs_working_qa_contact_comments_mean_length_severity_recast and profiles_working tables based on qa_contact & userid to add the severity types comment mean length columns
setkey(bugs_working_qa_contact_comments_mean_length_severity_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_comments_mean_length_severity_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);
	
	
	
# PROFILES-LONGDESCS_BUGS_REPORTED_AND_ASSIGNED_TO_AND_QA_CONTACT_PRIORITY_DESCRIPTION_AND_COMMENTS_MEAN_LENGTHS
# (Calculate the mean description and comment lengths for each priority level for which each user was reporter, assigned_to, or qa_contact)

# Select the columns that we need; we also rename description_length to description_mean_length because that's what it will be after the dcast below
bugs_working_roles_priority_comment_description_length <- select(bugs_working, reporter, assigned_to, qa_contact, comments_mean_length, description_mean_length = description_length, priority);	
	
# Add a prefix to the priority values to make them easier to understand after the dcast
bugs_working_roles_priority_comment_description_length <- mutate(bugs_working_roles_priority_comment_description_length, 
																 reported_priority	  	= paste0("bugs_reported_priority_", 	priority),
																 assigned_to_priority   = paste0("bugs_assigned_to_priority_", priority),
																 qa_contact_priority    = paste0("bugs_qa_contact_priority_",  priority));


# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with mean comment_length & mean description_length for each of the 6 priority types and 3 user roles of reporter/assigned_to/qa_contact
# We'll use dcast()'s new (package:data.table >1.9.6) multiple value vars to create description and comment means all at once
bugs_working_reporter_priority_comment_description_length_recast <- dcast(bugs_working_roles_priority_comment_description_length, reporter ~ reported_priority, 
																		  drop=FALSE, value.var=c("description_mean_length", "comments_mean_length"), fun=mean, fill=0, na.rm=TRUE);
bugs_working_assigned_to_priority_comment_description_length_recast <- dcast(bugs_working_roles_priority_comment_description_length, assigned_to ~ assigned_to_priority, 
																		  drop=FALSE, value.var=c("description_mean_length", "comments_mean_length"), fun=mean, fill=0, na.rm=TRUE);
bugs_working_qa_contact_priority_comment_description_length_recast <- dcast(bugs_working_roles_priority_comment_description_length, qa_contact ~ qa_contact_priority, 
																		  drop=FALSE, value.var=c("description_mean_length", "comments_mean_length"), fun=mean, fill=0, na.rm=TRUE);

# The column names aren't quite exactly what we want, so clean them up
colnames(bugs_working_reporter_priority_comment_description_length_recast) 	  <- sub("^description_mean_length_mean_(.+)$", "\\1_description_mean_length", colnames(bugs_working_reporter_priority_comment_description_length_recast),    perl=TRUE);
colnames(bugs_working_reporter_priority_comment_description_length_recast)    <- sub("^comments_mean_length_mean_(.+)$", 	"\\1_comments_mean_length",    colnames(bugs_working_reporter_priority_comment_description_length_recast),    perl=TRUE);	
colnames(bugs_working_assigned_to_priority_comment_description_length_recast) <- sub("^description_mean_length_mean_(.+)$", "\\1_description_mean_length", colnames(bugs_working_assigned_to_priority_comment_description_length_recast), perl=TRUE);
colnames(bugs_working_assigned_to_priority_comment_description_length_recast) <- sub("^comments_mean_length_mean_(.+)$", 	"\\1_comments_mean_length",    colnames(bugs_working_assigned_to_priority_comment_description_length_recast), perl=TRUE);	
colnames(bugs_working_qa_contact_priority_comment_description_length_recast)  <- sub("^description_mean_length_mean_(.+)$", "\\1_description_mean_length", colnames(bugs_working_qa_contact_priority_comment_description_length_recast),  perl=TRUE);
colnames(bugs_working_qa_contact_priority_comment_description_length_recast)  <- sub("^comments_mean_length_mean_(.+)$", 	"\\1_comments_mean_length",    colnames(bugs_working_qa_contact_priority_comment_description_length_recast),  perl=TRUE);	

	
# Merge the newly recast tables and profiles_working tables based on reporter/assigned_to/qa_contact userids & profiles_working userid to add the priority types mean description & comment length columns
setkey(bugs_working_reporter_priority_comment_description_length_recast, 	reporter);
setkey(bugs_working_assigned_to_priority_comment_description_length_recast, assigned_to);
setkey(bugs_working_qa_contact_priority_comment_description_length_recast,  qa_contact);

# Because there are so many new columns being added, instead of creating a long list of ifelse looking NA values to set to zero, we'll do the merge in three stages
# The first stage merges against the whole profiles_working$userid column alone, creating a table with just the new columns and userid
# Second, we replace all the NA values with 0
# Third, we merge the NA-free table with the profiles_working table

# Step 1
profiles_working_userids <- select(profiles_working, userid);
setkey(profiles_working_userids, userid);

profiles_working_new_priority_mean_columns <- merge(profiles_working_userids, 			  		bugs_working_reporter_priority_comment_description_length_recast, 	 by.x="userid", by.y="reporter",    all.x=TRUE);
profiles_working_new_priority_mean_columns <- merge(profiles_working_new_priority_mean_columns, bugs_working_assigned_to_priority_comment_description_length_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);
profiles_working_new_priority_mean_columns <- merge(profiles_working_new_priority_mean_columns, bugs_working_qa_contact_priority_comment_description_length_recast,	 by.x="userid", by.y="qa_contact",  all.x=TRUE);

# Step 2 - Using data.table's convenient format
profiles_working_new_priority_mean_columns[is.na(profiles_working_new_priority_mean_columns)] <- 0;

# Step 3
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, profiles_working_new_priority_mean_columns, by="userid", all.x=TRUE);

	
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
															bugs_reported_enhancement_mean_days_to_last_resolved	= if (exists('enhancement',	where = bugs_working_reporter_severity_days_to_last_resolved_recast)) enhancement 	else 0,
															bugs_reported_trivial_mean_days_to_last_resolved		= if (exists('trivial',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) trivial 		else 0,
															bugs_reported_minor_mean_days_to_last_resolved			= if (exists('minor',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) minor 		else 0,
															bugs_reported_normal_mean_days_to_last_resolved		= if (exists('normal',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) normal 		else 0,
															bugs_reported_major_mean_days_to_last_resolved			= if (exists('major',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) major 		else 0,
															bugs_reported_critical_mean_days_to_last_resolved		= if (exists('critical',	where = bugs_working_reporter_severity_days_to_last_resolved_recast)) critical 		else 0,
															bugs_reported_blocker_mean_days_to_last_resolved		= if (exists('blocker',		where = bugs_working_reporter_severity_days_to_last_resolved_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs each user reported
bugs_working_reporter_severity_days_to_last_resolved_recast <- mutate(bugs_working_reporter_severity_days_to_last_resolved_recast,
																	 bugs_reported_all_types_mean_days_to_last_resolved = (bugs_reported_enhancement_mean_days_to_last_resolved 	+
																																bugs_reported_trivial_mean_days_to_last_resolved 		+
																																bugs_reported_minor_mean_days_to_last_resolved 		+	
																																bugs_reported_normal_mean_days_to_last_resolved 		+
																																bugs_reported_major_mean_days_to_last_resolved 		+	
																																bugs_reported_critical_mean_days_to_last_resolved 		+
																																bugs_reported_blocker_mean_days_to_last_resolved) 		/ 7);

# NA values mean that the user was not set as reporter for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
bugs_working_reporter_severity_days_to_last_resolved_recast[bugs_working_reporter_severity_days_to_last_resolved_recast <= 0]		  <- NA;
bugs_working_reporter_severity_days_to_last_resolved_recast[is.na(bugs_working_reporter_severity_days_to_last_resolved_recast)]		  <- NA;	  
																																
																																   
# Merge the bugs_working_reporter_severity_days_to_last_resolved_recast and profiles_working tables based on reporter & userid to add the severity types description mean times columns
setkey(bugs_working_reporter_severity_days_to_last_resolved_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_severity_days_to_last_resolved_recast, by.x="userid", by.y="reporter", all.x=TRUE);

	
# PROFILES-BUG_SEVERITY_USER_REPORTED_MEAN_DAYS_TO_RESOLUTION
# (Calculate the mean days_to_resolution for bugs reported by each user for each severity level)

# Isolate the reporter, bug_severity, and days_to_resolution columns of bugs_working
bugs_working_reporter_severity_days_to_resolution <- select(bugs_working, reporter, bug_severity, days_to_resolution);

# Use data.table's dcast() function to recast the table such that each row is a single "reporter" and there
# is a column with the mean	days_to_resolution for all the bugs each user reported for each severity level, defaulting to NA if the user did not report any bugs of that severity level
bugs_working_reporter_severity_days_to_resolution_recast <- dcast(bugs_working_reporter_severity_days_to_resolution, reporter ~ bug_severity, drop=FALSE, value.var="days_to_resolution", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_reporter_severity_days_to_resolution_recast <- transmute(bugs_working_reporter_severity_days_to_resolution_recast,  	
															reporter 												= reporter,
															bugs_reported_enhancement_mean_days_to_resolution	= if (exists('enhancement',	where = bugs_working_reporter_severity_days_to_resolution_recast)) enhancement 	else 0,
															bugs_reported_trivial_mean_days_to_resolution		= if (exists('trivial',		where = bugs_working_reporter_severity_days_to_resolution_recast)) trivial 		else 0,
															bugs_reported_minor_mean_days_to_resolution		= if (exists('minor',		where = bugs_working_reporter_severity_days_to_resolution_recast)) minor 		else 0,
															bugs_reported_normal_mean_days_to_resolution		= if (exists('normal',		where = bugs_working_reporter_severity_days_to_resolution_recast)) normal 		else 0,
															bugs_reported_major_mean_days_to_resolution		= if (exists('major',		where = bugs_working_reporter_severity_days_to_resolution_recast)) major 		else 0,
															bugs_reported_critical_mean_days_to_resolution		= if (exists('critical',	where = bugs_working_reporter_severity_days_to_resolution_recast)) critical 	else 0,
															bugs_reported_blocker_mean_days_to_resolution		= if (exists('blocker',		where = bugs_working_reporter_severity_days_to_resolution_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs each user reported
bugs_working_reporter_severity_days_to_resolution_recast <- mutate(bugs_working_reporter_severity_days_to_resolution_recast,
																	 bugs_reported_all_types_mean_days_to_resolution = (bugs_reported_enhancement_mean_days_to_resolution 	+
																															 bugs_reported_trivial_mean_days_to_resolution 		+
																															 bugs_reported_minor_mean_days_to_resolution 			+	
																															 bugs_reported_normal_mean_days_to_resolution 			+
																															 bugs_reported_major_mean_days_to_resolution 			+	
																															 bugs_reported_critical_mean_days_to_resolution 		+
																															 bugs_reported_blocker_mean_days_to_resolution) 		/ 7);


# NA values mean that the user was not set as reporter for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
bugs_working_reporter_severity_days_to_resolution_recast[bugs_working_reporter_severity_days_to_resolution_recast <= 0]		    <- NA;
bugs_working_reporter_severity_days_to_resolution_recast[is.na(bugs_working_reporter_severity_days_to_resolution_recast)]		<- NA;

																																   
# Merge the bugs_working_reporter_severity_days_to_resolution_recast and profiles_working tables based on reporter & userid to add the severity types description mean times columns
setkey(bugs_working_reporter_severity_days_to_resolution_recast, reporter);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_reporter_severity_days_to_resolution_recast, by.x="userid", by.y="reporter", all.x=TRUE);

		
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
															bugs_assigned_to_enhancement_mean_days_to_last_resolved	= if (exists('enhancement',	where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) enhancement 	else 0,
															bugs_assigned_to_trivial_mean_days_to_last_resolved		= if (exists('trivial',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) trivial 		else 0,
															bugs_assigned_to_minor_mean_days_to_last_resolved			= if (exists('minor',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) minor 			else 0,
															bugs_assigned_to_normal_mean_days_to_last_resolved			= if (exists('normal',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) normal 		else 0,
															bugs_assigned_to_major_mean_days_to_last_resolved			= if (exists('major',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) major 			else 0,
															bugs_assigned_to_critical_mean_days_to_last_resolved		= if (exists('critical',	where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) critical 		else 0,
															bugs_assigned_to_blocker_mean_days_to_last_resolved		= if (exists('blocker',		where = bugs_working_assigned_to_severity_days_to_last_resolved_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs to which each user was assigned
bugs_working_assigned_to_severity_days_to_last_resolved_recast <- mutate(bugs_working_assigned_to_severity_days_to_last_resolved_recast,
																	     bugs_assigned_to_all_types_mean_days_to_last_resolved = (bugs_assigned_to_enhancement_mean_days_to_last_resolved +
																																	   bugs_assigned_to_trivial_mean_days_to_last_resolved 	+
																																	   bugs_assigned_to_minor_mean_days_to_last_resolved 		+	
																																	   bugs_assigned_to_normal_mean_days_to_last_resolved 		+
																																	   bugs_assigned_to_major_mean_days_to_last_resolved 		+	
																																	   bugs_assigned_to_critical_mean_days_to_last_resolved 	+
																																	   bugs_assigned_to_blocker_mean_days_to_last_resolved) 	/ 7);
																																   

# NA values mean that the user was not set as assigned_to for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
bugs_working_assigned_to_severity_days_to_last_resolved_recast[bugs_working_assigned_to_severity_days_to_last_resolved_recast <= 0]		    <- NA;
bugs_working_assigned_to_severity_days_to_last_resolved_recast[is.na(bugs_working_assigned_to_severity_days_to_last_resolved_recast)]		<- NA;	  
																																   
# Merge the bugs_working_assigned_to_severity_days_to_last_resolved_recast and profiles_working tables based on assigned_to & userid to add the severity types description mean times columns
setkey(bugs_working_assigned_to_severity_days_to_last_resolved_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_severity_days_to_last_resolved_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);

	
# PROFILES-BUG_SEVERITY_USER_ASSIGNED_TO_MEAN_DAYS_TO_RESOLUTION
# (Calculate the mean days_to_resolution for bugs assigned_to by each user for each severity level)

# Isolate the assigned_to, bug_severity, and days_to_resolution columns of bugs_working
bugs_working_assigned_to_severity_days_to_resolution <- select(bugs_working, assigned_to, bug_severity, days_to_resolution);

# Use data.table's dcast() function to recast the table such that each row is a single "assigned_to" and there
# is a column with the mean	days_to_resolution for all the bugs to which each user each user was assigned for each severity level, defaulting to NA if the user did not get assigned_to any bugs of that severity level
bugs_working_assigned_to_severity_days_to_resolution_recast <- dcast(bugs_working_assigned_to_severity_days_to_resolution, assigned_to ~ bug_severity, drop=FALSE, value.var="days_to_resolution", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_assigned_to_severity_days_to_resolution_recast <- transmute(bugs_working_assigned_to_severity_days_to_resolution_recast,  	
															assigned_to 												= assigned_to,
															bugs_assigned_to_enhancement_mean_days_to_resolution	= if (exists('enhancement',	where = bugs_working_assigned_to_severity_days_to_resolution_recast)) enhancement 	else 0,
															bugs_assigned_to_trivial_mean_days_to_resolution		= if (exists('trivial',		where = bugs_working_assigned_to_severity_days_to_resolution_recast)) trivial 		else 0,
															bugs_assigned_to_minor_mean_days_to_resolution			= if (exists('minor',		where = bugs_working_assigned_to_severity_days_to_resolution_recast)) minor 		else 0,
															bugs_assigned_to_normal_mean_days_to_resolution		= if (exists('normal',		where = bugs_working_assigned_to_severity_days_to_resolution_recast)) normal 		else 0,
															bugs_assigned_to_major_mean_days_to_resolution			= if (exists('major',		where = bugs_working_assigned_to_severity_days_to_resolution_recast)) major 		else 0,
															bugs_assigned_to_critical_mean_days_to_resolution		= if (exists('critical',	where = bugs_working_assigned_to_severity_days_to_resolution_recast)) critical 		else 0,
															bugs_assigned_to_blocker_mean_days_to_resolution		= if (exists('blocker',		where = bugs_working_assigned_to_severity_days_to_resolution_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs to which each user was assigned
bugs_working_assigned_to_severity_days_to_resolution_recast <- mutate(bugs_working_assigned_to_severity_days_to_resolution_recast,
																	 bugs_assigned_to_all_types_mean_days_to_resolution = (bugs_assigned_to_enhancement_mean_days_to_resolution 	+
																																bugs_assigned_to_trivial_mean_days_to_resolution 		+
																																bugs_assigned_to_minor_mean_days_to_resolution 		+	
																																bugs_assigned_to_normal_mean_days_to_resolution 		+
																																bugs_assigned_to_major_mean_days_to_resolution 		+	
																																bugs_assigned_to_critical_mean_days_to_resolution 		+
																																bugs_assigned_to_blocker_mean_days_to_resolution) 		/ 7);
																																   
# NA values mean that the user was not set as assigned_to for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
bugs_working_assigned_to_severity_days_to_resolution_recast[bugs_working_assigned_to_severity_days_to_resolution_recast <= 0]		  <- NA;
bugs_working_assigned_to_severity_days_to_resolution_recast[is.na(bugs_working_assigned_to_severity_days_to_resolution_recast)]		  <- NA;	  
																																   
# Merge the bugs_working_assigned_to_severity_days_to_resolution_recast and profiles_working tables based on assigned_to & userid to add the severity types description mean times columns
setkey(bugs_working_assigned_to_severity_days_to_resolution_recast, assigned_to);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_assigned_to_severity_days_to_resolution_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);



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
															bugs_qa_contact_enhancement_mean_days_to_last_resolved	= if (exists('enhancement',	where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) enhancement 	else 0,
															bugs_qa_contact_trivial_mean_days_to_last_resolved		= if (exists('trivial',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) trivial 		else 0,
															bugs_qa_contact_minor_mean_days_to_last_resolved		= if (exists('minor',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) minor 			else 0,
															bugs_qa_contact_normal_mean_days_to_last_resolved		= if (exists('normal',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) normal 			else 0,
															bugs_qa_contact_major_mean_days_to_last_resolved		= if (exists('major',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) major 			else 0,
															bugs_qa_contact_critical_mean_days_to_last_resolved	= if (exists('critical',	where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) critical 		else 0,
															bugs_qa_contact_blocker_mean_days_to_last_resolved		= if (exists('blocker',		where = bugs_working_qa_contact_severity_days_to_last_resolved_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs for which each user was set as qa_contact
bugs_working_qa_contact_severity_days_to_last_resolved_recast <- mutate(bugs_working_qa_contact_severity_days_to_last_resolved_recast,
																	     bugs_qa_contact_all_types_mean_days_to_last_resolved = (bugs_qa_contact_enhancement_mean_days_to_last_resolved 	+
																																	  bugs_qa_contact_trivial_mean_days_to_last_resolved 		+
																																	  bugs_qa_contact_minor_mean_days_to_last_resolved 		+	
																																	  bugs_qa_contact_normal_mean_days_to_last_resolved 		+
																																	  bugs_qa_contact_major_mean_days_to_last_resolved 		+	
																																	  bugs_qa_contact_critical_mean_days_to_last_resolved 		+
																																	  bugs_qa_contact_blocker_mean_days_to_last_resolved) 		/ 7);

# NA values mean that the user was not set as qa_contact for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
bugs_working_qa_contact_severity_days_to_last_resolved_recast[bugs_working_qa_contact_severity_days_to_last_resolved_recast <= 0]		    <- NA;
bugs_working_qa_contact_severity_days_to_last_resolved_recast[is.na(bugs_working_qa_contact_severity_days_to_last_resolved_recast)]		<- NA;
																																	  
																																   
# Merge the bugs_working_qa_contact_severity_days_to_last_resolved_recast and profiles_working tables based on qa_contact & userid to add the severity types description mean times columns
setkey(bugs_working_qa_contact_severity_days_to_last_resolved_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_severity_days_to_last_resolved_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

	
# PROFILES-BUG_SEVERITY_USER_QA_CONTACT_MEAN_DAYS_TO_RESOLUTION
# (Calculate the mean days_to_resolution for bugs for which each user was set as qa_contact for each severity level)

# Isolate the qa_contact, bug_severity, and days_to_resolution columns of bugs_working
bugs_working_qa_contact_severity_days_to_resolution <- select(bugs_working, qa_contact, bug_severity, days_to_resolution);

# Use data.table's dcast() function to recast the table such that each row is a single "qa_contact" and there
# is a column with the mean	days_to_resolution for all the bugs to which each user each user was set as qa_contact for each severity level, defaulting to NA if the user did not get set as qa_contact for any bugs of that severity level
bugs_working_qa_contact_severity_days_to_resolution_recast <- dcast(bugs_working_qa_contact_severity_days_to_resolution, qa_contact ~ bug_severity, drop=FALSE, value.var="days_to_resolution", fun=mean, fill=0, na.rm=TRUE);

# Transmute all of the columns to the desired colnames values, checking to ensure we have the full range of severity levels for the given dataset
bugs_working_qa_contact_severity_days_to_resolution_recast <- transmute(bugs_working_qa_contact_severity_days_to_resolution_recast,  	
															qa_contact 													= qa_contact,
															bugs_qa_contact_enhancement_mean_days_to_resolution	= if (exists('enhancement',	where = bugs_working_qa_contact_severity_days_to_resolution_recast)) enhancement 	else 0,
															bugs_qa_contact_trivial_mean_days_to_resolution		= if (exists('trivial',		where = bugs_working_qa_contact_severity_days_to_resolution_recast)) trivial 		else 0,
															bugs_qa_contact_minor_mean_days_to_resolution			= if (exists('minor',		where = bugs_working_qa_contact_severity_days_to_resolution_recast)) minor 			else 0,
															bugs_qa_contact_normal_mean_days_to_resolution			= if (exists('normal',		where = bugs_working_qa_contact_severity_days_to_resolution_recast)) normal 		else 0,
															bugs_qa_contact_major_mean_days_to_resolution			= if (exists('major',		where = bugs_working_qa_contact_severity_days_to_resolution_recast)) major 			else 0,
															bugs_qa_contact_critical_mean_days_to_resolution		= if (exists('critical',	where = bugs_working_qa_contact_severity_days_to_resolution_recast)) critical 		else 0,
															bugs_qa_contact_blocker_mean_days_to_resolution		= if (exists('blocker',		where = bugs_working_qa_contact_severity_days_to_resolution_recast)) blocker 		else 0);
																						
# Mutate to add the overall mean description length for bugs for which each user was set as qa_contact
bugs_working_qa_contact_severity_days_to_resolution_recast <- mutate(bugs_working_qa_contact_severity_days_to_resolution_recast,
																	 bugs_qa_contact_all_types_mean_days_to_resolution = (bugs_qa_contact_enhancement_mean_days_to_resolution 	+
																															   bugs_qa_contact_trivial_mean_days_to_resolution 		+
																															   bugs_qa_contact_minor_mean_days_to_resolution 			+	
																															   bugs_qa_contact_normal_mean_days_to_resolution 			+
																															   bugs_qa_contact_major_mean_days_to_resolution 			+	
																															   bugs_qa_contact_critical_mean_days_to_resolution 		+
																															   bugs_qa_contact_blocker_mean_days_to_resolution) 		/ 7);
																																   
# NA values mean that the user was not set as qa_contact for any bugs, so the mean() has no definition.
# Further, any "0" entries are the result of the earlier "exists" check, and should be NA, so switch them to NA
bugs_working_qa_contact_severity_days_to_resolution_recast[bugs_working_qa_contact_severity_days_to_resolution_recast <= 0]		    <- NA;
bugs_working_qa_contact_severity_days_to_resolution_recast[is.na(bugs_working_qa_contact_severity_days_to_resolution_recast)]		<- NA;

																																   
# Merge the bugs_working_qa_contact_severity_days_to_resolution_recast and profiles_working tables based on qa_contact & userid to add the severity types description mean times columns
setkey(bugs_working_qa_contact_severity_days_to_resolution_recast, qa_contact);
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, bugs_working_qa_contact_severity_days_to_resolution_recast, by.x="userid", by.y="qa_contact", all.x=TRUE);

	
# PROFILES-BUG_PRIORITY_USER_REPORTED_&_ASSIGNED_TO_&_QA_CONTACT_MEAN_DAYS_TO_RESOLVED_&_MEAN_DAYS_TO_RESOLUTION
# (Calculate the mean days_to_last_resolved & days_to_resolution for bugs for which each user was set as reporter, assigned_to, or qua_contact for each priority level)
	
# Select just the columns that we need for this calculation
bugs_working_roles_priority_days_to_resolved_resolution <- select(bugs_working, reporter, assigned_to, qa_contact, priority, days_to_last_resolved, days_to_resolution);	

# Add a prefix to the priority values to make them easier to understand after the dcast
bugs_working_roles_priority_days_to_resolved_resolution <- mutate(bugs_working_roles_priority_days_to_resolved_resolution, 
																 reported_priority	  	= paste0("bugs_reported_priority_", 	priority),
																 assigned_to_priority   = paste0("bugs_assigned_to_priority_", priority),
																 qa_contact_priority    = paste0("bugs_qa_contact_priority_",  priority));


# Use data.table's dcast() function to recast the table such that each row is a single userid and there
# is a column with mean days_to_last_resolved & mean days_to_resolution for each of the 6 priority types and 3 user roles of reporter/assigned_to/qa_contact
# We'll use dcast()'s new (package:data.table >1.9.6) multiple value vars to create days_to_last_resolved and days_to_resolution means all at once
bugs_working_reporter_priority_days_to_resolved_resolution_recast 	 <- dcast(bugs_working_roles_priority_days_to_resolved_resolution, reporter    ~ reported_priority, 
																			  drop=FALSE, value.var=c("days_to_last_resolved", "days_to_resolution"), fun=mean, fill=0, na.rm=TRUE);
bugs_working_assigned_to_priority_days_to_resolved_resolution_recast <- dcast(bugs_working_roles_priority_days_to_resolved_resolution, assigned_to ~ assigned_to_priority, 
																			  drop=FALSE, value.var=c("days_to_last_resolved", "days_to_resolution"), fun=mean, fill=0, na.rm=TRUE);
bugs_working_qa_contact_priority_days_to_resolved_resolution_recast  <- dcast(bugs_working_roles_priority_days_to_resolved_resolution, qa_contact  ~ qa_contact_priority, 
																			  drop=FALSE, value.var=c("days_to_last_resolved", "days_to_resolution"), fun=mean, fill=0, na.rm=TRUE);

																		  
# The column names aren't quite exactly what we want, so clean them up
colnames(bugs_working_reporter_priority_days_to_resolved_resolution_recast)    <- sub("^days_to_last_resolved_mean_(.+)$", "\\1_mean_days_to_last_resolved", colnames(bugs_working_reporter_priority_days_to_resolved_resolution_recast),    perl=TRUE);
colnames(bugs_working_reporter_priority_days_to_resolved_resolution_recast)    <- sub("^days_to_resolution_mean_(.+)$",    "\\1_mean_days_to_resolution",    colnames(bugs_working_reporter_priority_days_to_resolved_resolution_recast),    perl=TRUE);	
colnames(bugs_working_assigned_to_priority_days_to_resolved_resolution_recast) <- sub("^days_to_last_resolved_mean_(.+)$", "\\1_mean_days_to_last_resolved", colnames(bugs_working_assigned_to_priority_days_to_resolved_resolution_recast), perl=TRUE);
colnames(bugs_working_assigned_to_priority_days_to_resolved_resolution_recast) <- sub("^days_to_resolution_mean_(.+)$",    "\\1_mean_days_to_resolution",    colnames(bugs_working_assigned_to_priority_days_to_resolved_resolution_recast), perl=TRUE);	
colnames(bugs_working_qa_contact_priority_days_to_resolved_resolution_recast)  <- sub("^days_to_last_resolved_mean_(.+)$", "\\1_mean_days_to_last_resolved", colnames(bugs_working_qa_contact_priority_days_to_resolved_resolution_recast),  perl=TRUE);
colnames(bugs_working_qa_contact_priority_days_to_resolved_resolution_recast)  <- sub("^days_to_resolution_mean_(.+)$",    "\\1_mean_days_to_resolution",    colnames(bugs_working_qa_contact_priority_days_to_resolved_resolution_recast),  perl=TRUE);	


# Merge the newly recast tables and profiles_working tables based on reporter/assigned_to/qa_contact userids & profiles_working userid to add the priority types mean days_to_last_resolved & days_to_resolution columns
setkey(bugs_working_reporter_priority_days_to_resolved_resolution_recast, 	 reporter);
setkey(bugs_working_assigned_to_priority_days_to_resolved_resolution_recast, assigned_to);
setkey(bugs_working_qa_contact_priority_days_to_resolved_resolution_recast,  qa_contact);

# Because there are so many new columns being added, instead of creating a long list of ifelse looking NA values to set to zero, we'll do the merge in three stages
# The first stage merges against the whole profiles_working$userid column alone, creating a table with just the new columns and userid
# Second, we replace all the NA values with 0
# Third, we merge the NA-free table with the profiles_working table

# Step 1
profiles_working_userids <- select(profiles_working, userid);
setkey(profiles_working_userids, userid);

profiles_working_new_priority_mean_days_columns <- merge(profiles_working_userids, 			  			  bugs_working_reporter_priority_days_to_resolved_resolution_recast, 	by.x="userid", by.y="reporter",    all.x=TRUE);
profiles_working_new_priority_mean_days_columns <- merge(profiles_working_new_priority_mean_days_columns, bugs_working_assigned_to_priority_days_to_resolved_resolution_recast, by.x="userid", by.y="assigned_to", all.x=TRUE);
profiles_working_new_priority_mean_days_columns <- merge(profiles_working_new_priority_mean_days_columns, bugs_working_qa_contact_priority_days_to_resolved_resolution_recast,	by.x="userid", by.y="qa_contact",  all.x=TRUE);

# Step 2 - Using data.table's convenient format
profiles_working_new_priority_mean_days_columns[is.na(profiles_working_new_priority_mean_days_columns)] 	  <- 0;

# Step 3
setkey(profiles_working, userid);
profiles_working <- merge(profiles_working, profiles_working_new_priority_mean_days_columns, by="userid", all.x=TRUE);



# PROFILES-BUGS_OUTCOME_PERCENTS
# (Calculate the various percents of outcomes in terms of fixed, not-fixed, pending)
profiles_working <- mutate(profiles_working, 
					percent_bugs_reported_all_outcomes_fixed         	 = safe_ifelse((bugs_reported_fixed_count 	  	+ 
																			 		   bugs_reported_not_fixed_count 		+ 
																			 		   bugs_reported_pending_count) 		<= 0, NA, bugs_reported_fixed_count 		/ (bugs_reported_fixed_count    + bugs_reported_not_fixed_count    + bugs_reported_pending_count)),
					percent_bugs_reported_defined_outcomes_fixed     	 = safe_ifelse((bugs_reported_fixed_count 		+ 
																			 		   bugs_reported_not_fixed_count) 		<= 0, NA, bugs_reported_fixed_count 		/ (bugs_reported_fixed_count    + bugs_reported_not_fixed_count)),
					percent_bugs_reported_all_outcomes_not_fixed     	 = safe_ifelse((bugs_reported_fixed_count 		+
																			 		   bugs_reported_not_fixed_count 		+ 
																			 		   bugs_reported_pending_count) 		<= 0, NA, bugs_reported_not_fixed_count 	/ (bugs_reported_fixed_count    + bugs_reported_not_fixed_count    + bugs_reported_pending_count)),
					percent_bugs_reported_defined_outcomes_not_fixed 	 = safe_ifelse((bugs_reported_fixed_count 		+
																			 		   bugs_reported_not_fixed_count) 		<= 0, NA, bugs_reported_not_fixed_count 	/ (bugs_reported_fixed_count    + bugs_reported_not_fixed_count)),
					percent_bugs_reported_all_outcomes_pending       	 = safe_ifelse((bugs_reported_fixed_count 		+
																					   bugs_reported_not_fixed_count 		+ 
																					   bugs_reported_pending_count) 		<= 0, NA, bugs_reported_pending_count 		/ (bugs_reported_fixed_count    + bugs_reported_not_fixed_count    + bugs_reported_pending_count)),
					percent_bugs_assigned_to_all_outcomes_fixed         = safe_ifelse((bugs_assigned_to_fixed_count 	+ 
																					   bugs_assigned_to_not_fixed_count 	+ 
																					   bugs_assigned_to_pending_count) 	<= 0, NA, bugs_assigned_to_fixed_count 	/ (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count + bugs_assigned_to_pending_count)),
					percent_bugs_assigned_to_defined_outcomes_fixed     = safe_ifelse((bugs_assigned_to_fixed_count 	+ 
																					   bugs_assigned_to_not_fixed_count) 	<= 0, NA, bugs_assigned_to_fixed_count 	/ (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count)),
					percent_bugs_assigned_to_all_outcomes_not_fixed     = safe_ifelse((bugs_assigned_to_fixed_count 	+
																					   bugs_assigned_to_not_fixed_count 	+ 
																					   bugs_assigned_to_pending_count) 	<= 0, NA, bugs_assigned_to_not_fixed_count / (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count + bugs_assigned_to_pending_count)),
					percent_bugs_assigned_to_defined_outcomes_not_fixed = safe_ifelse((bugs_assigned_to_fixed_count 	+
																					   bugs_assigned_to_not_fixed_count) 	<= 0, NA, bugs_assigned_to_not_fixed_count / (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count)),
					percent_bugs_assigned_to_all_outcomes_pending       = safe_ifelse((bugs_assigned_to_fixed_count 	+
																					   bugs_assigned_to_not_fixed_count 	+ 
																					   bugs_assigned_to_pending_count) 	<= 0, NA, bugs_assigned_to_pending_count 	/ (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count + bugs_assigned_to_pending_count)),
					percent_bugs_qa_contact_all_outcomes_fixed          = safe_ifelse((bugs_qa_contact_fixed_count 	+ 
																			 	   bugs_qa_contact_not_fixed_count 		+ 
																			 	   bugs_qa_contact_pending_count) 			<= 0, NA, bugs_qa_contact_fixed_count 		/ (bugs_qa_contact_fixed_count  + bugs_qa_contact_not_fixed_count  + bugs_qa_contact_pending_count)),
					percent_bugs_qa_contact_defined_outcomes_fixed      = safe_ifelse((bugs_qa_contact_fixed_count 	+ 
																			 	   bugs_qa_contact_not_fixed_count) 		<= 0, NA, bugs_qa_contact_fixed_count 		/ (bugs_qa_contact_fixed_count  + bugs_qa_contact_not_fixed_count)),
					percent_bugs_qa_contact_all_outcomes_not_fixed      = safe_ifelse((bugs_qa_contact_fixed_count 	+
																			 	   bugs_qa_contact_not_fixed_count 		+ 
																			 	   bugs_qa_contact_pending_count) 			<= 0, NA, bugs_qa_contact_not_fixed_count 	/ (bugs_qa_contact_fixed_count  + bugs_qa_contact_not_fixed_count  + bugs_qa_contact_pending_count)),
					percent_bugs_qa_contact_defined_outcomes_not_fixed  = safe_ifelse((bugs_qa_contact_fixed_count 	+
																			 	   bugs_qa_contact_not_fixed_count) 		<= 0, NA, bugs_qa_contact_not_fixed_count 	/ (bugs_qa_contact_fixed_count  + bugs_qa_contact_not_fixed_count)),
					percent_bugs_qa_contact_all_outcomes_pending        = safe_ifelse((bugs_qa_contact_fixed_count 	+
																					   bugs_qa_contact_not_fixed_count 	+ 
																					   bugs_qa_contact_pending_count) 		<= 0, NA, bugs_qa_contact_pending_count 	/ (bugs_qa_contact_fixed_count + bugs_qa_contact_not_fixed_count   + bugs_qa_contact_pending_count)));
	 
	
	
# PROFILES-BUGS_PERFORMANCE_PERCENTS
# (Calculate the various percents of variables related to user performance)

profiles_working <- mutate(profiles_working, 
					percent_bugs_reported_reopened_at_least_once	    = safe_ifelse(bugs_reported_count	  <= 0, NA, bugs_reported_reopened_at_least_once_count       / bugs_reported_count),
					percent_bugs_reported_reopened_at_least_twice	    = safe_ifelse(bugs_reported_count	  <= 0, NA, bugs_reported_reopened_at_least_twice_count      / bugs_reported_count),
					percent_bugs_reported_reopened_thrice_or_more	    = safe_ifelse(bugs_reported_count	  <= 0, NA, bugs_reported_reopened_thrice_or_more_count      / bugs_reported_count),
					percent_bugs_assigned_to_reopened_at_least_once    = safe_ifelse(bugs_assigned_to_count <= 0, NA, bugs_assigned_to_reopened_at_least_once_count    / bugs_assigned_to_count),
					percent_bugs_assigned_to_reopened_at_least_twice   = safe_ifelse(bugs_assigned_to_count <= 0, NA, bugs_assigned_to_reopened_at_least_twice_count   / bugs_assigned_to_count),
					percent_bugs_assigned_to_reopened_thrice_or_more   = safe_ifelse(bugs_assigned_to_count <= 0, NA, bugs_assigned_to_reopened_thrice_or_more_count   / bugs_assigned_to_count),
					percent_bugs_qa_contact_reopened_at_least_once	    = safe_ifelse(bugs_qa_contact_count  <= 0, NA, bugs_qa_contact_reopened_at_least_once_count     / bugs_qa_contact_count),
					percent_bugs_qa_contact_reopened_at_least_twice    = safe_ifelse(bugs_qa_contact_count  <= 0, NA, bugs_qa_contact_reopened_at_least_twice_count    / bugs_qa_contact_count),
					percent_bugs_qa_contact_reopened_thrice_or_more    = safe_ifelse(bugs_qa_contact_count  <= 0, NA, bugs_qa_contact_reopened_thrice_or_more_count    / bugs_qa_contact_count),
					percent_bugs_reported_reassigned_at_least_once	    = safe_ifelse(bugs_reported_count	  <= 0, NA, bugs_reported_reassigned_at_least_once_count     / bugs_reported_count),
					percent_bugs_reported_reassigned_at_least_twice	= safe_ifelse(bugs_reported_count	  <= 0, NA, bugs_reported_reassigned_at_least_twice_count    / bugs_reported_count),
					percent_bugs_reported_reassigned_thrice_or_more	= safe_ifelse(bugs_reported_count	  <= 0, NA, bugs_reported_reassigned_thrice_or_more_count    / bugs_reported_count),
					percent_bugs_assigned_to_reassigned_at_least_once  = safe_ifelse(bugs_assigned_to_count <= 0, NA, bugs_assigned_to_reassigned_at_least_once_count  / bugs_assigned_to_count),
					percent_bugs_assigned_to_reassigned_at_least_twice = safe_ifelse(bugs_assigned_to_count <= 0, NA, bugs_assigned_to_reassigned_at_least_twice_count / bugs_assigned_to_count),
					percent_bugs_assigned_to_reassigned_thrice_or_more = safe_ifelse(bugs_assigned_to_count <= 0, NA, bugs_assigned_to_reassigned_thrice_or_more_count / bugs_assigned_to_count),
					percent_bugs_qa_contact_reassigned_at_least_once	= safe_ifelse(bugs_qa_contact_count  <= 0, NA, bugs_qa_contact_reassigned_at_least_once_count   / bugs_qa_contact_count),
					percent_bugs_qa_contact_reassigned_at_least_twice  = safe_ifelse(bugs_qa_contact_count  <= 0, NA, bugs_qa_contact_reassigned_at_least_twice_count  / bugs_qa_contact_count),
					percent_bugs_qa_contact_reassigned_thrice_or_more  = safe_ifelse(bugs_qa_contact_count  <= 0, NA, bugs_qa_contact_reassigned_thrice_or_more_count  / bugs_qa_contact_count), 
					percent_bugs_reported_fixed_at_least_one_patch		= safe_ifelse(bugs_reported_count	  <= 0, NA, bugs_reported_fixed_at_least_one_patch_count	  / bugs_reported_count),
					percent_bugs_assigned_to_fixed_at_least_one_patch	= safe_ifelse(bugs_assigned_to_count <= 0, NA, bugs_assigned_to_fixed_at_least_one_patch_count  / bugs_assigned_to_count),
					percent_bugs_qa_contact_fixed_at_least_one_patch	= safe_ifelse(bugs_qa_contact_count  <= 0, NA, bugs_qa_contact_fixed_at_least_one_patch_count	  / bugs_qa_contact_count));


	
	
	
# CLEAN UP

# Set global variables for other functions
profiles_calculated <<- profiles_working;
bugs_calculated 	<<- bugs_working;

} # End operationalize_calculated_variables function


# OPERATIONALIZE SLOW CALCULATIONS


operationalize_slow_calculations <- function() {
# (This function separates slow calculations so that they don't need to be run every time)

# Import variables to work on
bugs_working <- bugs_calculated;

# BUGS_VARIABLES_AT_CREATION_TS
# (Calculate the number of bugs of various types and states at the creation time of each bug)

# To determine the number of bugs "open" at the creation_ts of each bug, we'll use the censor_ts value
# since it tends to be a better representation of "open" than cf_last_resolved and has no NA values

# We'll sort it so that our created & censored columns are easier to rank
bugs_created_censored_all <- arrange(bugs_working, creation_ts, censor_ts);

# For simplicity, rename the columns to created and censored
bugs_created_censored_all <- dplyr::rename(bugs_created_censored_all, created=creation_ts, censored=censor_ts);

# We'll use a trick suggested by @danas.zuokas (http://stackoverflow.com/users/1249481/danas-zuokas)
# Full discussion here: http://stackoverflow.com/questions/34245295/efficient-method-for-counting-open-cases-at-time-of-each-cases-submission-in-la
# If we rank the created & created and created & censored dateTimes, we can
# subtract the second rank from the first, leaving what is effectively an "overlap" count
# The result is a count for each bug of how many other bugs were created before but censored after it
# Neat trick which drastically reduces the computation time that would otherwise be in the order of n^2!
# There are many different libraries that have their own versions of rank, including base
# bit64::rank is the most efficient (base::rank can't handle time rankings properly)
# But, don't load the bit64 library because it masks a lot of other things that change our expected behaviour
# We'll just invoke the bit64::rank function directly

# We'll wrap this lovely process into a function so that we can feed it differently filtered data sets
# to calculate different values

count_open_bugs_function <- function (bugs_created_censored) {
	created_created_ranks  <- bit64::rank(c(bugs_created_censored[, created], bugs_created_censored[, created]),  ties.method = 'first')[1:nrow(bugs_created_censored)];

	created_censored_ranks <- bit64::rank(c(bugs_created_censored[, created], bugs_created_censored[, censored]), ties.method = 'first')[1:nrow(bugs_created_censored)];

	ranks_comparison_table <- data.table(bug_id 					 = bugs_created_censored$bug_id,
										 open_bugs_at_creation_count = created_created_ranks - created_censored_ranks);
	return(ranks_comparison_table);
} # End count_open_bugs_function

# Start with all bugs open at time each bug was created
ranks_comparison_table_all <- count_open_bugs_function(bugs_created_censored_all);

# Rename generic column name to avoid later confusion
ranks_comparison_table_all <- dplyr::rename(ranks_comparison_table_all, open_bugs_at_creation_all_count = open_bugs_at_creation_count);
										 
# Merge the ranks_comparison_table_all and bugs_working table to add our new column
setkey(bugs_working, bug_id);
setkey(ranks_comparison_table_all, bug_id);
bugs_working <- merge(bugs_working, ranks_comparison_table_all, by="bug_id", all.x=TRUE);

# All bugs should have a creation_ts and censor_ts value.  As a result, any NA values are correctly NA.


# Next we'll do count of bugs open with same op_sys at time bug was created.
# There are 50 distinct op_sys types (and that can grow) so we'll need to do a loop
# subsetting to each of the types each time and joining the rows with rbind and then resorting on bug_id
# Thankfully, each bug_id can only have one op_sys type or this would be even nastier!
for(i in 1: data.table::uniqueN(bugs_created_censored_all$op_sys)) {
	# Determine the name of the current operating system
	current_op_sys		<- sort(unique(bugs_created_censored_all$op_sys))[i];
	
	# Filter to just bugs with current operating system
	bugs_current_op_sys <- filter(bugs_created_censored_all, op_sys == `current_op_sys`);
	
	# Not all operating_system values may have bugs associated with them, so check if there are zaroo boogs
	if (nrow(bugs_current_op_sys) > 0) {
	
		# Use the count_open_bugs_function to generate the ranks_comparison_table for the current operating system
		ranks_comparison_table_current_op_sys <- count_open_bugs_function(bugs_current_op_sys);
	
		# The first time we have results, create the variable
		if (!exists("ranks_comparison_table_cummulative_op_sys")) {
			ranks_comparison_table_cummulative_op_sys <- ranks_comparison_table_current_op_sys;
		} 
	
		# Otherwise, bind the subsequent tables to the cummulative table
		else {
			ranks_comparison_table_cummulative_op_sys <- rbindlist(list(ranks_comparison_table_cummulative_op_sys, ranks_comparison_table_current_op_sys), use.names=TRUE);
		}
	} # End check if there are bugs
} # End for-loop


# Rename the generic column to avoid confusion
ranks_comparison_table_cummulative_op_sys <- dplyr::rename(ranks_comparison_table_cummulative_op_sys, open_bugs_at_creation_same_op_sys_count = open_bugs_at_creation_count);


# Merge the ranks_comparison_table_cummulative_op_sys and bugs_working table to add our new column
setkey(bugs_working, bug_id);
setkey(ranks_comparison_table_cummulative_op_sys, bug_id);
bugs_working <- merge(bugs_working, ranks_comparison_table_cummulative_op_sys, by="bug_id", all.x=TRUE);

# All bugs should have a creation_ts and censor_ts value.  As a result, any NA values are correctly NA.


# Repeat as above with rep_platform as we did with op_sys
for(i in 1: data.table::uniqueN(bugs_created_censored_all$rep_platform)) {
	# Determine the name of the current rep_platform
	current_rep_platform	  <- sort(unique(bugs_created_censored_all$rep_platform))[i];
	
	# Filter to just bugs with current rep_platform
	bugs_current_rep_platform <- filter(bugs_created_censored_all, rep_platform == `current_rep_platform`);
	
	# Not all rep_platform values may have bugs associated with them, so check if there are zaroo boogs
	if (nrow(bugs_current_rep_platform) > 0) {
	
		# Use the count_open_bugs_function to generate the ranks_comparison_table for the current rep_platform
		ranks_comparison_table_current_rep_platform <- count_open_bugs_function(bugs_current_rep_platform);
	
		# The first time we have results, create the variable
		if (!exists("ranks_comparison_table_cummulative_rep_platform")) {
			ranks_comparison_table_cummulative_rep_platform <- ranks_comparison_table_current_rep_platform;
		} 
	
		# Otherwise, bind the subsequent tables to the cummulative table
		else {
			ranks_comparison_table_cummulative_rep_platform <- rbindlist(list(ranks_comparison_table_cummulative_rep_platform, ranks_comparison_table_current_rep_platform), use.names=TRUE);
		}
	} # End check if there are bugs
} # End for-loop

# Rename the generic column to avoid confusion
ranks_comparison_table_cummulative_rep_platform <- dplyr::rename(ranks_comparison_table_cummulative_rep_platform, open_bugs_at_creation_same_rep_platform_count = open_bugs_at_creation_count);


# Merge the ranks_comparison_table_cummulative_rep_platform and bugs_working table to add our new column
setkey(bugs_working, bug_id);
setkey(ranks_comparison_table_cummulative_rep_platform, bug_id);
bugs_working <- merge(bugs_working, ranks_comparison_table_cummulative_rep_platform, by="bug_id", all.x=TRUE);

# All bugs should have a creation_ts and censor_ts value.  As a result, any NA values are correctly NA.


# Repeat as above with classification_id
for(i in 1: data.table::uniqueN(bugs_created_censored_all$classification_id)) {
	# Determine the name of the current classification_id
	current_classification_id	  <- sort(unique(bugs_created_censored_all$classification_id))[i];
	
	# Filter to just bugs with current classification_id
	bugs_current_classification_id <- filter(bugs_created_censored_all, classification_id == `current_classification_id`);
	
	# Not all classification_id values may have bugs associated with them, so check if there are zaroo boogs
	if (nrow(bugs_current_classification_id) > 0) {
	
		# Use the count_open_bugs_function to generate the ranks_comparison_table for the current classification_id
		ranks_comparison_table_current_classification_id <- count_open_bugs_function(bugs_current_classification_id);
	
		# The first time we have results, create the variable
		if (!exists("ranks_comparison_table_cummulative_classification_id")) {
			ranks_comparison_table_cummulative_classification_id <- ranks_comparison_table_current_classification_id;
		} 
	
		# Otherwise, bind the subsequent tables to the cummulative table
		else {
			ranks_comparison_table_cummulative_classification_id <- rbindlist(list(ranks_comparison_table_cummulative_classification_id, ranks_comparison_table_current_classification_id), use.names=TRUE);
		}
	} # End check if there are bugs
} # End for-loop

# Rename the generic column to avoid confusion
ranks_comparison_table_cummulative_classification_id <- dplyr::rename(ranks_comparison_table_cummulative_classification_id, open_bugs_at_creation_same_classification_id_count = open_bugs_at_creation_count);


# Merge the ranks_comparison_table_cummulative_classification_id and bugs_working table to add our new column
setkey(bugs_working, bug_id);
setkey(ranks_comparison_table_cummulative_classification_id, bug_id);
bugs_working <- merge(bugs_working, ranks_comparison_table_cummulative_classification_id, by="bug_id", all.x=TRUE);

# All bugs should have a creation_ts and censor_ts value.  As a result, any NA values are correctly NA.


# Repeat as above with product_id
for(i in 1: data.table::uniqueN(bugs_created_censored_all$product_id)) {
	# Determine the name of the current product_id
	current_product_id	  <- sort(unique(bugs_created_censored_all$product_id))[i];
	
	# Filter to just bugs with current product_id
	bugs_current_product_id <- filter(bugs_created_censored_all, product_id == `current_product_id`);
	
	# Not all product_id values may have bugs associated with them, so check if there are zaroo boogs
	if (nrow(bugs_current_product_id) > 0) {
	
		# Use the count_open_bugs_function to generate the ranks_comparison_table for the current product_id
		ranks_comparison_table_current_product_id <- count_open_bugs_function(bugs_current_product_id);
	
		# The first time we have results, create the variable
		if (!exists("ranks_comparison_table_cummulative_product_id")) {
			ranks_comparison_table_cummulative_product_id <- ranks_comparison_table_current_product_id;
		} 
	
		# Otherwise, bind the subsequent tables to the cummulative table
		else {
			ranks_comparison_table_cummulative_product_id <- rbindlist(list(ranks_comparison_table_cummulative_product_id, ranks_comparison_table_current_product_id), use.names=TRUE);
		}
	} # End check if there are bugs
} # End for-loop

# Rename the generic column to avoid confusion
ranks_comparison_table_cummulative_product_id <- dplyr::rename(ranks_comparison_table_cummulative_product_id, open_bugs_at_creation_same_product_id_count = open_bugs_at_creation_count);


# Merge the ranks_comparison_table_cummulative_product_id and bugs_working table to add our new column
setkey(bugs_working, bug_id);
setkey(ranks_comparison_table_cummulative_product_id, bug_id);
bugs_working <- merge(bugs_working, ranks_comparison_table_cummulative_product_id, by="bug_id", all.x=TRUE);

# All bugs should have a creation_ts and censor_ts value.  As a result, any NA values are correctly NA.


# Repeat as above with component_id
for(i in 1: data.table::uniqueN(bugs_created_censored_all$component_id)) {
	# Determine the name of the current component_id
	current_component_id	  <- sort(unique(bugs_created_censored_all$component_id))[i];
	
	# Filter to just bugs with current component_id
	bugs_current_component_id <- filter(bugs_created_censored_all, component_id == `current_component_id`);
	
	# Not all component_id values may have bugs associated with them, so check if there are zaroo boogs
	if (nrow(bugs_current_component_id) > 0) {
	
		# Use the count_open_bugs_function to generate the ranks_comparison_table for the current component_id
		ranks_comparison_table_current_component_id <- count_open_bugs_function(bugs_current_component_id);
	
		# The first time we have results, create the variable
		if (!exists("ranks_comparison_table_cummulative_component_id")) {
			ranks_comparison_table_cummulative_component_id <- ranks_comparison_table_current_component_id;
		} 
	
		# Otherwise, bind the subsequent tables to the cummulative table
		else {
			ranks_comparison_table_cummulative_component_id <- rbindlist(list(ranks_comparison_table_cummulative_component_id, ranks_comparison_table_current_component_id), use.names=TRUE);
		}
	} # End check if there are bugs
} # End for-loop

# Rename the generic column to avoid confusion
ranks_comparison_table_cummulative_component_id <- dplyr::rename(ranks_comparison_table_cummulative_component_id, open_bugs_at_creation_same_component_id_count = open_bugs_at_creation_count);


# Merge the ranks_comparison_table_cummulative_component_id and bugs_working table to add our new column
setkey(bugs_working, bug_id);
setkey(ranks_comparison_table_cummulative_component_id, bug_id);
bugs_working <- merge(bugs_working, ranks_comparison_table_cummulative_component_id, by="bug_id", all.x=TRUE);

# All bugs should have a creation_ts and censor_ts value.  As a result, any NA values are correctly NA.


# Repeat as above with target_milestone
for(i in 1: data.table::uniqueN(bugs_created_censored_all$target_milestone)) {
	# Determine the name of the current target_milestone
	current_target_milestone	  <- sort(unique(bugs_created_censored_all$target_milestone))[i];
	
	# Filter to just bugs with current target_milestone
	bugs_current_target_milestone <- filter(bugs_created_censored_all, target_milestone == `current_target_milestone`);
	
	# Not all target_milestone values may have bugs associated with them, so check if there are zaroo boogs
	if (nrow(bugs_current_target_milestone) > 0) {
	
		# Use the count_open_bugs_function to generate the ranks_comparison_table for the current target_milestone
		ranks_comparison_table_current_target_milestone <- count_open_bugs_function(bugs_current_target_milestone);
	
		# The first time we have results, create the variable
		if (!exists("ranks_comparison_table_cummulative_target_milestone")) {
			ranks_comparison_table_cummulative_target_milestone <- ranks_comparison_table_current_target_milestone;
		} 
	
		# Otherwise, bind the subsequent tables to the cummulative table
		else {
			ranks_comparison_table_cummulative_target_milestone <- rbindlist(list(ranks_comparison_table_cummulative_target_milestone, ranks_comparison_table_current_target_milestone), use.names=TRUE);
		}
	} # End check if there are bugs
} # End for-loop

# Rename the generic column to avoid confusion
ranks_comparison_table_cummulative_target_milestone <- dplyr::rename(ranks_comparison_table_cummulative_target_milestone, open_bugs_at_creation_same_target_milestone_count = open_bugs_at_creation_count);


# Merge the ranks_comparison_table_cummulative_target_milestone and bugs_working table to add our new column
setkey(bugs_working, bug_id);
setkey(ranks_comparison_table_cummulative_target_milestone, bug_id);
bugs_working <- merge(bugs_working, ranks_comparison_table_cummulative_target_milestone, by="bug_id", all.x=TRUE);

# All bugs should have a creation_ts and censor_ts value.  As a result, any NA values are correctly NA.


# BUGS_CREATED_RECENTLY
#(Count the number of bugs created in the past day, week, month, 3 months, 6 months, year)

# We can use the rank trick again.  This time, our "censored" time is the creation time of each bug
# and the "creation" is the beginning of the time range desired


# This function counts the number of bugs that were created within the period of 
# each bug's "creation_ts minus" "days_range"
# It should be passed the desired bugs table presorted by creation_ts and the number of days of the desired range
count_bugs_recently_created <- function (bugs_working_arranged, days_range) {
	
	# Select just the desired columns
	bugs_working_created <- select(bugs_working_arranged, bug_id, created=creation_ts);
	
	# Add a column to the bugs_working_created table that has the time stamp for the created minus days_range
	bugs_working_created_days_range <- mutate(bugs_working_created, date_cutoff = created - (days_range * 86400));
	
	created_date_cutoff_ranks  		<- bit64::rank(c(bugs_working_created_days_range[, date_cutoff], bugs_working_created_days_range[, created]),  	ties.method = 'first')[1:nrow(bugs_working_created_days_range)];
	
	created_created_ranks 			<- bit64::rank(c(bugs_working_created_days_range[, created], bugs_working_created_days_range[, created]), 		ties.method = 'first')[1:nrow(bugs_working_created_days_range)];
	
	ranks_comparison_table 			<- data.table(bug_id 					 = bugs_working_created_days_range$bug_id,
											bugs_created_in_range		 = created_created_ranks - created_date_cutoff_ranks);
	return(ranks_comparison_table);
} # End count_bugs_recently_created

# Sort the bugs_working function just once to speed things up
bugs_working_arranged <- arrange(bugs_working, creation_ts);

# Start with 1 day
bugs_created_past_1_day <- count_bugs_recently_created(bugs_working_arranged, 1);

# Rename the variable to be clear what it is
bugs_created_past_1_day <- dplyr::rename(bugs_created_past_1_day, bugs_created_past_1_day_count = bugs_created_in_range);

# Merge the bugs_created_past_1_day and bugs_working table to add our new column
setkey(bugs_created_past_1_day, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_created_past_1_day, by="bug_id", all.x=TRUE);


# Repeat with 3 days
bugs_created_past_3_days <- count_bugs_recently_created(bugs_working_arranged, 3);

# Rename the variable to be clear what it is
bugs_created_past_3_days <- dplyr::rename(bugs_created_past_3_days, bugs_created_past_3_days_count = bugs_created_in_range);

# Merge the bugs_created_past_3_days and bugs_working table to add our new column
setkey(bugs_created_past_3_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_created_past_3_days, by="bug_id", all.x=TRUE);


# Repeat with 7 days
bugs_created_past_7_days <- count_bugs_recently_created(bugs_working_arranged, 7);

# Rename the variable to be clear what it is
bugs_created_past_7_days <- dplyr::rename(bugs_created_past_7_days, bugs_created_past_7_days_count = bugs_created_in_range);

# Merge the bugs_created_past_7_days and bugs_working table to add our new column
setkey(bugs_created_past_7_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_created_past_7_days, by="bug_id", all.x=TRUE);


# Repeat with 30 days
bugs_created_past_30_days <- count_bugs_recently_created(bugs_working_arranged, 30);

# Rename the variable to be clear what it is
bugs_created_past_30_days <- dplyr::rename(bugs_created_past_30_days, bugs_created_past_30_days_count = bugs_created_in_range);

# Merge the bugs_created_past_30_days and bugs_working table to add our new column
setkey(bugs_created_past_30_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_created_past_30_days, by="bug_id", all.x=TRUE);


# Repeat with 90 days
bugs_created_past_90_days <- count_bugs_recently_created(bugs_working_arranged, 90);

# Rename the variable to be clear what it is
bugs_created_past_90_days <- dplyr::rename(bugs_created_past_90_days, bugs_created_past_90_days_count = bugs_created_in_range);

# Merge the bugs_created_past_90_days and bugs_working table to add our new column
setkey(bugs_created_past_90_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_created_past_90_days, by="bug_id", all.x=TRUE);


# Repeat with 180 days
bugs_created_past_180_days <- count_bugs_recently_created(bugs_working_arranged, 180);

# Rename the variable to be clear what it is
bugs_created_past_180_days <- dplyr::rename(bugs_created_past_180_days, bugs_created_past_180_days_count = bugs_created_in_range);

# Merge the bugs_created_past_180_days and bugs_working table to add our new column
setkey(bugs_created_past_180_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_created_past_180_days, by="bug_id", all.x=TRUE);


# Repeat with 1 year
bugs_created_past_1_year <- count_bugs_recently_created(bugs_working_arranged, 365);

# Rename the variable to be clear what it is
bugs_created_past_1_year <- dplyr::rename(bugs_created_past_1_year, bugs_created_past_1_year_count = bugs_created_in_range);

# Merge the bugs_created_past_1_year and bugs_working table to add our new column
setkey(bugs_created_past_1_year, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_created_past_1_year, by="bug_id", all.x=TRUE);


# Repeat with 2 years
bugs_created_past_2_years <- count_bugs_recently_created(bugs_working_arranged, 730);

# Rename the variable to be clear what it is
bugs_created_past_2_years <- dplyr::rename(bugs_created_past_2_years, bugs_created_past_2_years_count = bugs_created_in_range);

# Merge the bugs_created_past_2_years and bugs_working table to add our new column
setkey(bugs_created_past_2_years, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_created_past_2_years, by="bug_id", all.x=TRUE);



# BUGS_CENSORED_RECENTLY
#(Count the number of bugs censored in the past day, week, month, 3 months, 6 months, year, 2 years)


# This function counts the number of bugs that were censored within the period of 
# each bug's "creation_ts minus" "days_range"
# It should be passed the desired bugs table presorted by creation_ts and the number of days of the desired range
count_bugs_recently_censored <- function (bugs_working_arranged, days_range) {
	
	# Select just the desired columns
	bugs_working_created_censored <- select(bugs_working_arranged, bug_id, created = creation_ts, censored = censor_ts);
	
	# Add a column to the bugs_working_created_censored table that has the time stamp for the created minus days_range
	bugs_working_created_censored_days_range <- mutate(bugs_working_created_censored, date_cutoff = created - (days_range * 86400));
	
	created_date_cutoff_ranks  	<- bit64::rank(c(bugs_working_created_censored_days_range[, date_cutoff], bugs_working_created_censored_days_range[, censored]), ties.method = 'first')[1:nrow(bugs_working_created_censored_days_range)];

	censored_censored_ranks		<- bit64::rank(c(bugs_working_created_censored_days_range[, created ], 	bugs_working_created_censored_days_range[, censored]), 	ties.method = 'first')[1:nrow(bugs_working_created_censored_days_range)];

	ranks_comparison_table 		<- data.table(bug_id 				= bugs_working_created_censored_days_range$bug_id,
										 bugs_censored_in_range		= censored_censored_ranks - created_date_cutoff_ranks);

	return(ranks_comparison_table);
 
} # End count_bugs_recently_censored


# Sort the bugs_working function just once to speed things up
bugs_working_arranged <- arrange(bugs_working, censor_ts);

# Start with 1 day
bugs_censored_past_1_day <- count_bugs_recently_censored(bugs_working_arranged, 1);

# Rename the variable to be clear what it is
bugs_censored_past_1_day <- dplyr::rename(bugs_censored_past_1_day, bugs_censored_past_1_day_count = bugs_censored_in_range);

# Merge the bugs_censored_past_1_day and bugs_working table to add our new column
setkey(bugs_censored_past_1_day, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_censored_past_1_day, by="bug_id", all.x=TRUE);


# Repeat with 3 days
bugs_censored_past_3_days <- count_bugs_recently_censored(bugs_working_arranged, 3);

# Rename the variable to be clear what it is
bugs_censored_past_3_days <- dplyr::rename(bugs_censored_past_3_days, bugs_censored_past_3_days_count = bugs_censored_in_range);

# Merge the bugs_censored_past_3_days and bugs_working table to add our new column
setkey(bugs_censored_past_3_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_censored_past_3_days, by="bug_id", all.x=TRUE);


# Repeat with 7 days
bugs_censored_past_7_days <- count_bugs_recently_censored(bugs_working_arranged, 7);

# Rename the variable to be clear what it is
bugs_censored_past_7_days <- dplyr::rename(bugs_censored_past_7_days, bugs_censored_past_7_days_count = bugs_censored_in_range);

# Merge the bugs_censored_past_7_days and bugs_working table to add our new column
setkey(bugs_censored_past_7_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_censored_past_7_days, by="bug_id", all.x=TRUE);


# Repeat with 30 days
bugs_censored_past_30_days <- count_bugs_recently_censored(bugs_working_arranged, 30);

# Rename the variable to be clear what it is
bugs_censored_past_30_days <- dplyr::rename(bugs_censored_past_30_days, bugs_censored_past_30_days_count = bugs_censored_in_range);

# Merge the bugs_censored_past_30_days and bugs_working table to add our new column
setkey(bugs_censored_past_30_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_censored_past_30_days, by="bug_id", all.x=TRUE);


# Repeat with 90 days
bugs_censored_past_90_days <- count_bugs_recently_censored(bugs_working_arranged, 90);

# Rename the variable to be clear what it is
bugs_censored_past_90_days <- dplyr::rename(bugs_censored_past_90_days, bugs_censored_past_90_days_count = bugs_censored_in_range);

# Merge the bugs_censored_past_90_days and bugs_working table to add our new column
setkey(bugs_censored_past_90_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_censored_past_90_days, by="bug_id", all.x=TRUE);


# Repeat with 180 days
bugs_censored_past_180_days <- count_bugs_recently_censored(bugs_working_arranged, 180);

# Rename the variable to be clear what it is
bugs_censored_past_180_days <- dplyr::rename(bugs_censored_past_180_days, bugs_censored_past_180_days_count = bugs_censored_in_range);

# Merge the bugs_censored_past_180_days and bugs_working table to add our new column
setkey(bugs_censored_past_180_days, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_censored_past_180_days, by="bug_id", all.x=TRUE);


# Repeat with 1 year
bugs_censored_past_1_year <- count_bugs_recently_censored(bugs_working_arranged, 365);

# Rename the variable to be clear what it is
bugs_censored_past_1_year <- dplyr::rename(bugs_censored_past_1_year, bugs_censored_past_1_year_count = bugs_censored_in_range);

# Merge the bugs_censored_past_1_year and bugs_working table to add our new column
setkey(bugs_censored_past_1_year, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_censored_past_1_year, by="bug_id", all.x=TRUE);


# Repeat with 2 years
bugs_censored_past_2_years <- count_bugs_recently_censored(bugs_working_arranged, 730);

# Rename the variable to be clear what it is
bugs_censored_past_2_years <- dplyr::rename(bugs_censored_past_2_years, bugs_censored_past_2_years_count = bugs_censored_in_range);

# Merge the bugs_censored_past_2_years and bugs_working table to add our new column
setkey(bugs_censored_past_2_years, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, bugs_censored_past_2_years, by="bug_id", all.x=TRUE);


# BUGS_TITLE_&_DESCRIPTION_&_TITLE_DESCRIPTION_MERGED_NGRAM_DISTANCES

# In order to get n-gram_distances, we first need create n-gram databases that will be the reference 
# comparison for n-gram distances of titles and descriptions of each bug
# There will be 12 n-gram databases to start: title & description & title_description_merged for bugs of type all, fixed, not_fixed, and pending

# Take just the columns we need (rename short_desc to title temporarily in bugs_all for simplicity)
bugs_all <- select(bugs_interactions, bug_id, title = short_desc, description, outcome);

# Since the marker used to generate the n-grams DB's is the string "\2", it can't show up in the text being parsed
# So, first, we'll substitute it with something that looks similar in unicode
# We use \UFE68 for the "small form variant" backslash, and the 2 as normal

# Create small replacement gsub functions to use in the sapply function
gsub_function <- function (x) {
	# Two passes are needed because of the strange way gsub handles backslash escaping.  Annoying...
	first_pass 	<- gsub("\\\2",  "\U{FE68}2", 		   x, fixed=FALSE);
	second_pass <- gsub("\\\\2", "\U{FE68}\U{FE68}2",  first_pass, fixed=FALSE);
	return (second_pass);
}

# Use sapply() which returns a vector in the same form applying the gsub function to all the vector values
bugs_all$title 			<- sapply(bugs_all$title, 	  	gsub_function);
bugs_all$description 	<- sapply(bugs_all$description, gsub_function);

# Create new columns that will act as our id values in the textcat profile DB creation
# We want all of the same categories to have the same id because the textcat_profile_db function is bitchy with its combine S3 method
# We also change the bug_id to character instead of factor integer because the textcat_profile_db function needs a character list and factors screw it up
# We also create a title_description_merged variable that puts them together in a single text block
bugs_all	<- mutate(bugs_all, bug_id						 = as.character(bug_id),
								title_id 					 = paste0("title_", 	  outcome),
								description_id				 = paste0("description_", outcome),
								title_description_merged_id	 = paste0("title_description_merged_", outcome),
								title_all					 = paste0("title_all"),
								description_all				 = paste0("description_all"),
								title_description_merged_all = paste0("title_description_merged_all"),
								title_description_merged 	 = paste(title, description, sep=" "));
								
								
# Create textcat DB profiles for each block
# x defines the texts for which to create an n-gram profile
# y defines the ids for each profile to determine how they are aggregated
# Here we want multiple texts to aggregate into a single DB, so we use the same ID
# n defines the number of characters allowed in ngrams
# perl determines the type of regex engine used to determine word boundaries in texts
# size determines the maximu number of n-grams to include in each profile_DB
# reduce determines the algorithm to use. We choose the full CT algorithm

# All
textcat_profiles_title_all 		 			  		<- textcat_profile_db(x = bugs_all$title, 		   	  		 	   id = bugs_all$title_all, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);				  
textcat_profiles_description_all 			  		<- textcat_profile_db(x = bugs_all$description,   	  		 	   id = bugs_all$description_all, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);
textcat_profiles_title_description_merged_all 		<- textcat_profile_db(x = bugs_all$title_description_merged, 	   id = bugs_all$title_description_merged_all, 
																	  n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);																  

# fixed
bugs_fixed 								  		<- filter(bugs_all, outcome == "fixed");
textcat_profiles_title_fixed 				  		<- textcat_profile_db(x = bugs_fixed$title, 	   	  			   id = bugs_fixed$title_id, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);				  
textcat_profiles_description_fixed 			  		<- textcat_profile_db(x = bugs_fixed$description,	  			   id = bugs_fixed$description_id, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);	
textcat_profiles_title_description_merged_fixed 	<- textcat_profile_db(x = bugs_fixed$title_description_merged,	   id = bugs_fixed$title_description_merged_id, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);	
	
# not_fixed
bugs_not_fixed 									<- filter(bugs_all, outcome == "not_fixed");
textcat_profiles_title_not_fixed 					<- textcat_profile_db(x = bugs_not_fixed$title, 	  			   id = bugs_not_fixed$title_id, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);				  
textcat_profiles_description_not_fixed 				<- textcat_profile_db(x = bugs_not_fixed$description, 			   id = bugs_not_fixed$description_id, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);	
textcat_profiles_title_description_merged_not_fixed <- textcat_profile_db(x = bugs_not_fixed$title_description_merged, id = bugs_not_fixed$title_description_merged_id, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);		
	
# pending
bugs_pending 									<- filter(bugs_all, outcome == "pending");
textcat_profiles_title_pending 						<- textcat_profile_db(x = bugs_pending$title, 	   	  			   id = bugs_pending$title_id,
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);				  
textcat_profiles_description_pending			 	<- textcat_profile_db(x = bugs_pending$description,   			   id = bugs_pending$description_id, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);	
textcat_profiles_title_description_merged_pending	<- textcat_profile_db(x = bugs_pending$title_description_merged,   id = bugs_pending$title_description_merged_id, 
																		n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);	
  
															  
# Create a data.table that will hold all the ngram distances values and the bug_ids that
# can later be merged with the bugs_working table
# There are 7 distance methods: CT, ranks, ALPD, KLI, KLJ, JS, & Dice
# Each bug's title & description will be compared to each respective DB profile
# As a result there will be 3 (title & description  & title_description_merged texsts) * 4 (all, fixed, not_fixed, & pending DBs) * 7 (distance methods) = 84 columns + bug_id

# This is a HUGE operation, so we'll do it in parallel on multiple CPU cores
# Instantiate a cluster of R processes on the number of cores defined at the top of the program								  
cluster <- makeCluster(CPU_CORES, outfile="output_from_core_processes.txt");

# Register the DoParallel backend which allows us to use the %dopar% operator with foreach functions
registerDoParallel(cluster);

# We're going to do this in 2 steps.
# Step 1:
# We need to create the textcat_profile_DB for EACH title and EACH description (not aggregated into a single textcat_profile_DB as above) (and title + description merged, added later)
# We'll store them in a single list variable for simplicity (each one with nrow(bugs_interactions) textcat_profile_DBs).
# To do this, each one needs to have a DIFFERENT ID (unlike earlier where we aggregated them with similar IDs).  
# We use bug_id as the unique ID, since it's perfect for that purpose
# The foreach structure works very similar to for() loops, but allows parallel execution
# It starts by taking all the bug titles and bug_ids and splitting them into chunks of 10,000 elements that can be 
# passed to separate CPU cores to process in parallel
# Then, we define the "aggregation" function of the returned values from each core as "c", which will automatically call the
# c.textcat_profile_DB S3 function that does the special aggregating of textcat_profile_dbs with different ids
# We specify that the "c" operator can handle more than 2 values (up to 100 max)
# Finally, we call %dopar% which tells all the CPU cores to execute the following lines in parallel on their respective chunks titles & bug_ids
# textcat_profile_db can automatically create multiple DBs so long as the ids are different, but does so sequentially, which is why we have
# single calls for each CPU core
# The textcat_profile_db call is similar to above, except each id will be a different value, so they will create multiple DBs, not a single DB
# Note that we specify the full path to the package textcat because the cores don't have access to libraries loaded in the main process directly
textcat_profiles_title_each 						<- foreach(current_title = isplitVector(bugs_all$title,  chunkSize=10000), 
															   current_id 	 = isplitVector(bugs_all$bug_id, chunkSize=10000), 
															   .combine="c", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %dopar% {
																	textcat::textcat_profile_db(x = current_title, id = current_id, n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);	
															  }
# Repeat for descriptions
# Note that chunk sizes are modified for more efficient distribution to the CPU cores given that descriptions are larger than titles
textcat_profiles_description_each 					<- foreach(current_description = isplitVector(bugs_all$description, chunkSize=2500), 
															   current_id 		   = isplitVector(bugs_all$bug_id, 	    chunkSize=2500), 
															   .combine="c", .multicombine=TRUE, .maxcombine=400L, .verbose=FALSE) %dopar% {
																	textcat::textcat_profile_db(x = current_description, id = current_id, n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);	
															  }
# Repeat for title & description MERGED
# This third iteration creats a joined set of both title and description
# Allowing an enhanced "a-priori" measure to be used in bug classification prediction
# Then we can simply build the profiles for each bug the same way as above with the new column
textcat_profiles_title_and_description_merged_each 	<- foreach(current_merged = isplitVector(bugs_all$title_description_merged, chunkSize=2500), 
															   current_id 	  = isplitVector(bugs_all$bug_id, chunkSize=2500), 
															   .combine="c", .multicombine=TRUE, .maxcombine=400L, .verbose=FALSE) %dopar% {
																	textcat::textcat_profile_db(x = current_merged, id = current_id, n = 1:10, perl = TRUE, size = 2000L, reduce = FALSE);	
															  }
								  
# Step 2
# Now that we have textcat_profileDBs fir each title and database and title_database_merged, we can
# pass those to the textcat_xdist function to determine n-gram distances
# Once again, we want to do this in parallel because textcat_xdist is serial, although it can handle multiple inputs
# As described earlier, we need to create 7 methods * 4 DB comparison values for each of title and description

# Create list of the different n-gram distance methods that will be used
method_vals				<- c("CT", "ranks", "ALPD", "KLI", "KLJ", "JS", "Dice");
						  
# The comparison DBs will be needed by the CPU cores, but they can't see them by default
# So we'll create a list of them that we'll export to each CPU core during the foreach loop								  
title_export_vals 		<- c("textcat_profiles_title_all", 		
							 "textcat_profiles_title_fixed", 	
							 "textcat_profiles_title_not_fixed",
							 "textcat_profiles_title_pending");

# We use a nexted foreach loop that works a lot like nested for loops
# The nestings are (speudo-code) for(i = 1:4 DB comparisons) for(j = 1:7 distance methods) for (k = 1:nrow(bugs_all) title_profile_DBs) 
# yielding 28 * nrow(bugs_all) values	for each of title, description & title_description_merged
# We use the iter function to walk through the method & compare DB values
# We use column bind (cbind) to attach the results of the first two nested foreaches, since each one will create multiple column vectors						 
# We use a row bind (rbind) to attach the results of the last foreach, as it will produce pairs of bug_id & distance values
# Note the use of .export to pass the required comparison DBs to each CPU core.
# The export takes some time to do and uses a fair amount of I/O and RAM, but there is no alternative on Windows
# On linux, this isn't necessary because forked processes can access values directly
# Finally, the textcat_xdist (full reference to package location) generates a value for the comparison between x= each title and p = each comparison DB using method = each distance method
# We wrap the results in a data.table (again, full reference to data.table package location) for easier handling and to set rownames based on the bug_id
# By tracking the bug_id internally this way, we ensure consistency in the assemblange of results.
# We set the column names of each column in the data table so that we know which comparison DB and which method was used to create the distance value, along with which bug_id
title_output <- 	foreach(compare_db = iter(title_export_vals), .combine="cbind", .export=title_export_vals,  .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
						foreach(current_method = iter(method_vals), .combine="cbind", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
							foreach(current_title = isplitVector(textcat_profiles_title_each, chunkSize=10000), .combine="rbind", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %dopar% {
								title_output_table <-data.table::as.data.table(textcat::textcat_xdist(x = current_title, p = get(compare_db), method=current_method), keep.rownames=TRUE);
								names(title_output_table) <- c(paste0(compare_db, "_", current_method, "_bug_id"), paste0(compare_db, "_", current_method));
								title_output_table;
							}

# Finally, we clean up the output table, renaming the columns and dropping the duplicate bug_id columns
names(title_output) <- gsub("textcat_profiles_title", "title_ngram_distance", names(title_output), perl=TRUE);			
names(title_output) <- sub("title_ngram_distance_all_CT_bug_id", "bug_id", names(title_output), perl=TRUE);

title_ngram_distances <- select(title_output, -ends_with("_bug_id")) %>% mutate(bug_id = as.factor(as.numeric(bug_id))) %>% arrange(bug_id);


# Repeat exactly the same way for descriptions
# We only change the chunksize, as before, for better load-balancing and I/O usage
			   
description_export_vals <- c("textcat_profiles_description_all",
							 "textcat_profiles_description_fixed",
							 "textcat_profiles_description_not_fixed",
							 "textcat_profiles_description_pending");		   
				 
description_output <- 	foreach(compare_db = iter(description_export_vals), .combine="cbind", .export=description_export_vals, .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
							foreach(current_method = iter(method_vals), .combine="cbind", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
								foreach(current_description = isplitVector(textcat_profiles_description_each, chunkSize=3000), .combine="rbind", .multicombine=TRUE, .maxcombine=400L, .verbose=FALSE) %dopar% {
									description_output_table <-data.table::as.data.table(textcat::textcat_xdist(x = current_description , p = get(compare_db), method=current_method), keep.rownames=TRUE);
									names(description_output_table) <- c(paste0(compare_db, "_", current_method, "_bug_id"), paste0(compare_db, "_", current_method));
									description_output_table;
								}

names(description_output) <- gsub("textcat_profiles_description", "description_ngram_distance", names(description_output), perl=TRUE);			
names(description_output) <- sub("description_ngram_distance_all_CT_bug_id", "bug_id", names(description_output), perl=TRUE);

description_ngram_distances <- select(description_output, -ends_with("_bug_id")) %>% mutate(bug_id = as.factor(as.numeric(bug_id))) %>% arrange(bug_id);


# Repeat exactly the same way for title & description merged
			   
title_description_merged_export_vals <- c("textcat_profiles_title_description_merged_all",
										  "textcat_profiles_title_description_merged_fixed",
										  "textcat_profiles_title_description_merged_not_fixed",
										  "textcat_profiles_title_description_merged_pending");		   
				 
title_description_merged_output <- 	foreach(compare_db = iter(title_description_merged_export_vals), .combine="cbind", .export=title_description_merged_export_vals, .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
										foreach(current_method = iter(method_vals), .combine="cbind", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
											foreach(current_merged = isplitVector(textcat_profiles_title_and_description_merged_each, chunkSize=3000), .combine="rbind", .multicombine=TRUE, .maxcombine=400L, .verbose=FALSE) %dopar% {
												title_description_merged_output_table <-data.table::as.data.table(textcat::textcat_xdist(x = current_merged , p = get(compare_db), method=current_method), keep.rownames=TRUE);
												names(title_description_merged_output_table) <- c(paste0(compare_db, "_", current_method, "_bug_id"), paste0(compare_db, "_", current_method));
												title_description_merged_output_table;
											}

names(title_description_merged_output) <- gsub("textcat_profiles_title_description_merged", "title_description_merged_ngram_distance", names(title_description_merged_output), perl=TRUE);			
names(title_description_merged_output) <- sub("title_description_merged_ngram_distance_all_CT_bug_id", "bug_id", names(title_description_merged_output), perl=TRUE);

title_description_merged_ngram_distances <- select(title_description_merged_output, -ends_with("_bug_id")) %>% mutate(bug_id = as.factor(as.numeric(bug_id))) %>% arrange(bug_id);

# Results are merged into bugs_working after next section



# BUGS_TITLE_&_DESCRIPTION_NGRAM_PROFILE_OUTCOME_CATEGORIZATION

# The individual title & description & title_description_merged textcat_profile_dbs can be used as prediction against
# the aggregate category profile databases of "fixed" vs. "not_fixed"

# For each bug we want to create three new columns: title_textcat_outcome_prediction & description_textcat_outcome_prediction & title_description_merged_textcat_outcome_prediction
# Each one will simply have a value of "fixed" or "not_fixed" as "guessed" by the textcat algorithm
# using the individual DBs compared to the aggregate dbs.

# First, we create an aggregate profile_db of fixed & not_fixed for each of title & description & title_description_merged

textcat_profiles_title_fixed_not_fixed 		 				<- c(textcat_profiles_title_fixed, 						textcat_profiles_title_not_fixed);
textcat_profiles_description_fixed_not_fixed 				<- c(textcat_profiles_description_fixed, 				textcat_profiles_description_not_fixed);
textcat_profiles_title_description_merged_fixed_not_fixed 	<- c(textcat_profiles_title_description_merged_fixed, 	textcat_profiles_title_description_merged_not_fixed);

# Change the names to simply be "fixed" or "not_fixed" dropping the title_ or description_ prefix
names(textcat_profiles_title_fixed_not_fixed) 						<- c("fixed", "not_fixed");
names(textcat_profiles_description_fixed_not_fixed) 				<- c("fixed", "not_fixed");
names(textcat_profiles_title_description_merged_fixed_not_fixed) 	<- c("fixed", "not_fixed");


# The textcat prediction function works almost exactly the same as textcat_xdist.
# The prediction can be done by each of 7 methods, so we'll actually add 3 & 7 columns
# As before, we'll do this via multicore.  Options are the same.

title_prediction_output <-	foreach(current_method = iter(method_vals), .combine="cbind", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
								foreach(current_title = isplitVector(textcat_profiles_title_each, chunkSize=10000), .combine="rbind", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %dopar% {
									title_prediction_output_table <-data.table::as.data.table(textcat::textcat(x = current_title, p = textcat_profiles_title_fixed_not_fixed, method=current_method), keep.rownames=TRUE);
									names(title_prediction_output_table) <- c(paste0("title_ngram_outcome_prediction_", current_method, "_bug_id"), paste0("title_ngram_outcome_prediction_", current_method));
									title_prediction_output_table;
								}

# Clean up just as before
names(title_prediction_output) <- sub("title_ngram_outcome_prediction_CT_bug_id", "bug_id", names(title_prediction_output), perl=TRUE);

title_ngram_outcome_predictions <- select(title_prediction_output, -ends_with("_bug_id")) %>% 
								   mutate(bug_id = as.factor(as.numeric(bug_id)),
										  title_ngram_outcome_prediction_CT		= as.factor(title_ngram_outcome_prediction_CT),		
										  title_ngram_outcome_prediction_ranks  = as.factor(title_ngram_outcome_prediction_ranks),   
										  title_ngram_outcome_prediction_ALPD   = as.factor(title_ngram_outcome_prediction_ALPD),    
										  title_ngram_outcome_prediction_KLI    = as.factor(title_ngram_outcome_prediction_KLI),     
										  title_ngram_outcome_prediction_KLJ    = as.factor(title_ngram_outcome_prediction_KLJ),     
										  title_ngram_outcome_prediction_JS     = as.factor(title_ngram_outcome_prediction_JS),      
										  title_ngram_outcome_prediction_Dice	= as.factor(title_ngram_outcome_prediction_Dice)) %>%																 				 
								   arrange(bug_id);

# We'll use the rownames utility function (at top of program) to extract
# the modal prediction from all the different methods into a single column

title_ngram_outcome_prediction_modal 		   <- as.data.table(rowmodes(select(title_ngram_outcome_predictions, -bug_id)));
colnames(title_ngram_outcome_prediction_modal) <- "title_ngram_outcome_prediction_modal";
title_ngram_outcome_predictions 	 	 	   <- cbind(title_ngram_outcome_predictions, title_ngram_outcome_prediction_modal);


# Repeat with description with different chunk sizes.

description_prediction_output <-	foreach(current_method = iter(method_vals), .combine="cbind", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
										foreach(current_description = isplitVector(textcat_profiles_description_each, chunkSize=3000), .combine="rbind", .multicombine=TRUE, .maxcombine=400L, .verbose=FALSE) %dopar% {
											description_prediction_output_table <-data.table::as.data.table(textcat::textcat(x = current_description, p = textcat_profiles_description_fixed_not_fixed, method=current_method), keep.rownames=TRUE);
											names(description_prediction_output_table) <- c(paste0("description_ngram_outcome_prediction_", current_method, "_bug_id"), paste0("description_ngram_outcome_prediction_", current_method));
											description_prediction_output_table;
										}

# Clean up just as before
names(description_prediction_output) <- sub("description_ngram_outcome_prediction_CT_bug_id", "bug_id", names(description_prediction_output), perl=TRUE);

description_ngram_outcome_predictions <- select(description_prediction_output, -ends_with("_bug_id")) %>% 
										 mutate(bug_id = as.factor(as.numeric(bug_id)),
												description_ngram_outcome_prediction_CT		= as.factor(description_ngram_outcome_prediction_CT),		
												description_ngram_outcome_prediction_ranks  = as.factor(description_ngram_outcome_prediction_ranks),   
												description_ngram_outcome_prediction_ALPD   = as.factor(description_ngram_outcome_prediction_ALPD),    
												description_ngram_outcome_prediction_KLI    = as.factor(description_ngram_outcome_prediction_KLI),     
												description_ngram_outcome_prediction_KLJ    = as.factor(description_ngram_outcome_prediction_KLJ),     
												description_ngram_outcome_prediction_JS     = as.factor(description_ngram_outcome_prediction_JS),      
												description_ngram_outcome_prediction_Dice	= as.factor(description_ngram_outcome_prediction_Dice)) %>%																 				 
										 arrange(bug_id);


description_ngram_outcome_prediction_modal 		  	 <- as.data.table(rowmodes(select(description_ngram_outcome_predictions, -bug_id)));
colnames(description_ngram_outcome_prediction_modal) <- "description_ngram_outcome_prediction_modal";
description_ngram_outcome_predictions	 	   		 <- cbind(description_ngram_outcome_predictions, description_ngram_outcome_prediction_modal);
										 

# Repeat with title_description_merged

title_description_merged_prediction_output <-	foreach(current_method = iter(method_vals), .combine="cbind", .multicombine=TRUE, .maxcombine=100L, .verbose=FALSE) %:% 
													foreach(current_merged = isplitVector(textcat_profiles_title_and_description_merged_each, chunkSize=3000), .combine="rbind", .multicombine=TRUE, .maxcombine=400L, .verbose=FALSE) %dopar% {
														title_description_merged_prediction_output_table <-data.table::as.data.table(textcat::textcat(x = current_merged, p = textcat_profiles_title_description_merged_fixed_not_fixed, method=current_method), keep.rownames=TRUE);
														names(title_description_merged_prediction_output_table) <- c(paste0("title_description_merged_ngram_outcome_prediction_", current_method, "_bug_id"), paste0("title_description_merged_ngram_outcome_prediction_", current_method));
														title_description_merged_prediction_output_table;
													}

# Clean up just as before
names(title_description_merged_prediction_output) <- sub("title_description_merged_ngram_outcome_prediction_CT_bug_id", "bug_id", names(title_description_merged_prediction_output), perl=TRUE);

title_description_merged_ngram_outcome_predictions <- select(title_description_merged_prediction_output, -ends_with("_bug_id")) %>% 
										 mutate(bug_id = as.factor(as.numeric(bug_id)),
												title_description_merged_ngram_outcome_prediction_CT	= as.factor(title_description_merged_ngram_outcome_prediction_CT),		
												title_description_merged_ngram_outcome_prediction_ranks = as.factor(title_description_merged_ngram_outcome_prediction_ranks),   
												title_description_merged_ngram_outcome_prediction_ALPD  = as.factor(title_description_merged_ngram_outcome_prediction_ALPD),    
												title_description_merged_ngram_outcome_prediction_KLI   = as.factor(title_description_merged_ngram_outcome_prediction_KLI),     
												title_description_merged_ngram_outcome_prediction_KLJ   = as.factor(title_description_merged_ngram_outcome_prediction_KLJ),     
												title_description_merged_ngram_outcome_prediction_JS    = as.factor(title_description_merged_ngram_outcome_prediction_JS),      
												title_description_merged_ngram_outcome_prediction_Dice	= as.factor(title_description_merged_ngram_outcome_prediction_Dice)) %>%																 				 
										 arrange(bug_id);


title_description_merged_ngram_outcome_prediction_modal  	 		<- as.data.table(rowmodes(select(title_description_merged_ngram_outcome_predictions, -bug_id)));
colnames(title_description_merged_ngram_outcome_prediction_modal) 	<- "title_description_merged_ngram_outcome_prediction_modal";
title_description_merged_ngram_outcome_predictions	 	   		 	<- cbind(title_description_merged_ngram_outcome_predictions, title_description_merged_ngram_outcome_prediction_modal);

# After the multicore operations are done, we should kill the spawned processes 
stopCluster(cluster);


# Merge values from past two sections into bugs_working
# Merge title & description n-gram distance values to the bugs_working table by bug_id
setkey(title_ngram_distances, bug_id);
setkey(description_ngram_distances, bug_id);
setkey(title_description_merged_ngram_distances, bug_id)
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, title_ngram_distances, 		 		   	  by="bug_id", all.x=TRUE);
bugs_working <- merge(bugs_working, description_ngram_distances, 		   	  by="bug_id", all.x=TRUE);
bugs_working <- merge(bugs_working, title_description_merged_ngram_distances, by="bug_id", all.x=TRUE);
		                                                                   
# Merge title & description outcome predictions to the bugs_working table by bug_id
setkey(title_ngram_outcome_predictions, bug_id);
setkey(description_ngram_outcome_predictions, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, title_ngram_outcome_predictions, 	   by="bug_id", all.x=TRUE);
bugs_working <- merge(bugs_working, description_ngram_outcome_predictions, by="bug_id", all.x=TRUE);


# Mutate bugs_working to add columns checking if the outcome predictions were accurate
# It simply compares the prediction to the actual outcome column
# There are 7 + modal predictions for each of title, description, & title_description_merged = 21 summary columns
# In cases that the outcome is "pending", it sets the value to NA
bugs_working <- mutate(bugs_working, is_title_ngram_outcome_prediction_modal_correct 					= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_ngram_outcome_prediction_modal)		  				== as.character(outcome))),
									 is_title_ngram_outcome_prediction_CT_correct 						= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_ngram_outcome_prediction_CT)		  				== as.character(outcome))),
									 is_title_ngram_outcome_prediction_ranks_correct 					= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_ngram_outcome_prediction_ranks)		  				== as.character(outcome))),
									 is_title_ngram_outcome_prediction_ALPD_correct 					= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_ngram_outcome_prediction_ALPD)		  				== as.character(outcome))),
									 is_title_ngram_outcome_prediction_KLI_correct 						= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_ngram_outcome_prediction_KLI)		  				== as.character(outcome))),
									 is_title_ngram_outcome_prediction_KLJ_correct 						= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_ngram_outcome_prediction_KLJ)		  				== as.character(outcome))),
									 is_title_ngram_outcome_prediction_JS_correct 						= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_ngram_outcome_prediction_JS)		  				== as.character(outcome))),
									 is_title_ngram_outcome_prediction_Dice_correct 					= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_ngram_outcome_prediction_Dice)		  				== as.character(outcome))),
									 is_description_ngram_outcome_prediction_modal_correct 				= safe_ifelse(outcome=="pending", NA, as.logical(as.character(description_ngram_outcome_prediction_modal) 				== as.character(outcome))),
									 is_description_ngram_outcome_prediction_CT_correct 				= safe_ifelse(outcome=="pending", NA, as.logical(as.character(description_ngram_outcome_prediction_CT) 	  				== as.character(outcome))),
									 is_description_ngram_outcome_prediction_ranks_correct 				= safe_ifelse(outcome=="pending", NA, as.logical(as.character(description_ngram_outcome_prediction_ranks) 				== as.character(outcome))),
									 is_description_ngram_outcome_prediction_ALPD_correct 				= safe_ifelse(outcome=="pending", NA, as.logical(as.character(description_ngram_outcome_prediction_ALPD)  				== as.character(outcome))),
									 is_description_ngram_outcome_prediction_KLI_correct 				= safe_ifelse(outcome=="pending", NA, as.logical(as.character(description_ngram_outcome_prediction_KLI)   				== as.character(outcome))),
									 is_description_ngram_outcome_prediction_KLJ_correct 				= safe_ifelse(outcome=="pending", NA, as.logical(as.character(description_ngram_outcome_prediction_KLJ)   				== as.character(outcome))),
									 is_description_ngram_outcome_prediction_JS_correct 				= safe_ifelse(outcome=="pending", NA, as.logical(as.character(description_ngram_outcome_prediction_JS)    				== as.character(outcome))),
									 is_description_ngram_outcome_prediction_Dice_correct 				= safe_ifelse(outcome=="pending", NA, as.logical(as.character(description_ngram_outcome_prediction_Dice)  				== as.character(outcome))),
									 is_title_description_merged_ngram_outcome_prediction_modal_correct = safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_description_merged_ngram_outcome_prediction_modal) 	== as.character(outcome))),
									 is_title_description_merged_ngram_outcome_prediction_CT_correct 	= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_description_merged_ngram_outcome_prediction_CT) 	== as.character(outcome))),
									 is_title_description_merged_ngram_outcome_prediction_ranks_correct = safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_description_merged_ngram_outcome_prediction_ranks) 	== as.character(outcome))),
									 is_title_description_merged_ngram_outcome_prediction_ALPD_correct 	= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_description_merged_ngram_outcome_prediction_ALPD)   == as.character(outcome))),
									 is_title_description_merged_ngram_outcome_prediction_KLI_correct 	= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_description_merged_ngram_outcome_prediction_KLI)    == as.character(outcome))),
									 is_title_description_merged_ngram_outcome_prediction_KLJ_correct 	= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_description_merged_ngram_outcome_prediction_KLJ)    == as.character(outcome))),
									 is_title_description_merged_ngram_outcome_prediction_JS_correct 	= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_description_merged_ngram_outcome_prediction_JS)     == as.character(outcome))),
									 is_title_description_merged_ngram_outcome_prediction_Dice_correct 	= safe_ifelse(outcome=="pending", NA, as.logical(as.character(title_description_merged_ngram_outcome_prediction_Dice)   == as.character(outcome))));


# CLEAN UP

# Set global variables for other functions

bugs_calculated <<- bugs_working;
									 
} # End operationalize_slow_calculations function



# OPERATIONALIZE VERY SLOW CALCULATIONS
# By "very slow" I mean at present approx 7 days for each of the following functions running 
# on 7 cores at 4.2GHZ with 64GB RAM.  14+ days total.
# Consider yourself warned

operationalize_very_slow_calculations <- function () {

# Import variables from previous function
bugs_working 	 <- bugs_calculated;
profiles_working <- profiles_calculated;

# BUGS_DESCRIPTION_READABILITY

# How readable a bug's initial description is can affect its likelihood of ever getting fixed
# This section calculates the readability of each bug description using a number of different methods
# We'll use package koRpus to do our redability
# It depends on the installation of TreeTagger described at the top of this script
# It also depends on the TreeTagger location specified in the user options and used below

# Create a function that calls korPus::treetag, passes the results to korPus::readability, and then creates and returns a formatted data table
# The function needs to be passed a description and bug_id

calculate_readability_measures <<- function(the_description, current_bug_id) {
	
	
	# koRpus throws a lot of errors when it doesn't know how to handle text formats.  In such cases, we'll just set the readability
	# values to NA and move on.  Debugging for weeks was not successful...
	# To address this, we wrap the koRpus functions in try() blocks and set a variable to create the readability out put table with NA values if an error is thrown	
	
	# Preset the bad_description value to be sure it is reset each use, though scoping SHOULD handle this...
	bad_description <- FALSE;
	
    # Tag the description, wrapping it in a try() block
    description_tagged <- try(koRpus::treetag(file = the_description, treetagger = "manual", lang="en", TT.options = list(path=TREETAGGER_LOCATION, preset="en"), 
																									stopwords  = tm::stopwords("en"),
																									format	   = "obj", rm.sgml = TRUE, encoding="UTF-8"), 		silent = TRUE);
	
	# Check if result was an error
	if (class(description_tagged) == "try-error") {
		bad_description <- TRUE;
	}
		
		
					
   # Pass the results directly to readability, wrapping it in a try() block again
	readability_output <- try(koRpus::readability(txt.file = description_tagged, force.lang = "en",
																			 index 	    = c("ARI", "Coleman", "Coleman.Liau", "Danielson.Bryan", 
																						  "Dickes.Steiwer", "ELF", "Farr.Jenkins.Paterson",
																						  "Flesch", "Flesch.Kincaid", "FOG", "FORCAST", "Fucks",
																						  "Linsear.Write", "LIX", "RIX", "SMOG", "Strain",
																						  "Traenkle.Bailer", "TRI", "Tuldava", "Wheeler.Smith"),
																			 quiet 	    = TRUE), 																	silent = TRUE);
                                                                                  
	# Check if result was an error
	if (class(readability_output) == "try-error") {
		bad_description <- TRUE;
	}
																				  
	# Deliberately using ifelse() instead of safe_ifelse() because attribute preservation screws up if it's an error and we only want numerical values anyways, no attributes.	
	readability_output_table = data.table::data.table(bug_id													= current_bug_id,
													  description_readability_ARI_grade							= ifelse(bad_description, NA, readability_output@ARI$grade),
													  description_readability_Coleman_1							= ifelse(bad_description, NA, readability_output@Coleman$C1),
													  description_readability_Coleman_2							= ifelse(bad_description, NA, readability_output@Coleman$C2),
													  description_readability_Coleman_3							= ifelse(bad_description, NA, readability_output@Coleman$C3),
													  description_readability_Coleman_4							= ifelse(bad_description, NA, readability_output@Coleman$C4),
													  description_readability_Coleman_Liau_grade				= ifelse(bad_description, NA, readability_output@Coleman.Liau$grade),
													  description_readability_Coleman_Liau_short				= ifelse(bad_description, NA, readability_output@Coleman.Liau$short),
													  description_readability_Danielson_Bryan_1					= ifelse(bad_description, NA, readability_output@Danielson.Bryan$DB1),
													  description_readability_Danielson_Bryan_2					= ifelse(bad_description, NA, readability_output@Danielson.Bryan$DB2),
													  description_readability_Danielson_Bryan_grade_min			= ifelse(bad_description, NA, readability_output@Danielson.Bryan$DB2.grade.min),
													  description_readability_Dickes_Steiwer					= ifelse(bad_description, NA, readability_output@Dickes.Steiwer$Dickes.Steiwer),
													  description_readability_ELF								= ifelse(bad_description, NA, readability_output@ELF$ELF),
													  description_readability_Farr_Jenkins_Paterson				= ifelse(bad_description, NA, readability_output@Farr.Jenkins.Paterson$FJP),
													  description_readability_Farr_Jenkins_Paterson_grade_min	= ifelse(bad_description, NA, readability_output@Farr.Jenkins.Paterson$grade.min),
													  description_readability_Flesch_reading_ease				= ifelse(bad_description, NA, readability_output@Flesch$RE),
													  description_readability_Flesch_grade_min					= ifelse(bad_description, NA, readability_output@Flesch$grade.min),
													  description_readability_Flesch_Kincaid_grade				= ifelse(bad_description, NA, readability_output@Flesch.Kincaid$grade),
													  description_readability_Flesch_Kincaid_age				= ifelse(bad_description, NA, readability_output@Flesch.Kincaid$age),
													  description_readability_FOG								= ifelse(bad_description, NA, readability_output@FOG$FOG),
													  description_readability_FORCAST_grade						= ifelse(bad_description, NA, readability_output@FORCAST$grade),
													  description_readability_FORCAST_age						= ifelse(bad_description, NA, readability_output@FORCAST$age),
													  description_readability_Fucks								= ifelse(bad_description, NA, readability_output@Fucks$Fucks),
													  description_readability_Fucks_grade						= ifelse(bad_description, NA, readability_output@Fucks$grade),
													  description_readability_Linsear_Write_raw					= ifelse(bad_description, NA, readability_output@Linsear.Write$raw),
													  description_readability_Linsear_Write_grade				= ifelse(bad_description, NA, readability_output@Linsear.Write$grade),
													  description_readability_LIX_index							= ifelse(bad_description, NA, readability_output@LIX$index),
													  description_readability_LIX_grade_min						= ifelse(bad_description, NA, readability_output@LIX$grade.min),
													  description_readability_RIX_index							= ifelse(bad_description, NA, readability_output@RIX$index),
													  description_readability_RIX_grade_min						= ifelse(bad_description, NA, readability_output@RIX$grade.min),
													  description_readability_SMOG_grade						= ifelse(bad_description, NA, readability_output@SMOG$grade),
													  description_readability_SMOG_age							= ifelse(bad_description, NA, readability_output@SMOG$age),
													  description_readability_Strain_index						= ifelse(bad_description, NA, readability_output@Strain$index),
													  description_readability_Traenkle_Bailer_1					= ifelse(bad_description, NA, readability_output@Traenkle.Bailer$TB1),
													  description_readability_Traenkle_Bailer_2					= ifelse(bad_description, NA, readability_output@Traenkle.Bailer$TB2),
													  description_readability_TRI								= ifelse(bad_description, NA, readability_output@TRI$TRI),
													  description_readability_Tuldava							= ifelse(bad_description, NA, readability_output@Tuldava$Tuldava),
													  description_readability_Wheeler_Smith_score				= ifelse(bad_description, NA, readability_output@Wheeler.Smith$score),
													  description_readability_Wheeler_Smith_grade_min		 	= ifelse(bad_description, NA, readability_output@Wheeler.Smith$grade.min));
	return (readability_output_table);
}

# As previously, calculating these measures is a HUGE process so we'll distribute it to multiple CPU cores
# Instantiate a cluster of R processes with 11 cores. It's a low memory process so more cores are fine.						  
cluster <- makeCluster(CPU_CORES, outfile="output_from_core_processes.txt");

# Register the DoParallel backend which allows us to use the %dopar% operator with foreach functions
registerDoParallel(cluster);

# For the loop we want to use bug_id's but don't want to pass giant factor objects each time, so set them to numeric for now
# Need to wrap it in as.character first to drop the factors, then as.numeric to get the numeric value. Otherwise you get the factor index value instead.
bugs_all <- mutate(select(bugs_interactions, bug_id, description), bug_id = as.numeric(as.character(bug_id)));

# Set up the foreach call to build a table that has results for each description of each bug
# The results don't need to be in order since they're always indexed by bug_id and will be sorted out when merged with bugs_working
# That should speed it up slightly

# Because the process takes so long to run, every 45,577 bugs processed or so (around 1/2 day of processing), 
# we want the results to be dumped to a csv file with bug_id for indexing later with a fast fread of the whole folder
# We'll set up a basic for loop around the foreach to do that for us

# The "to" & "by" values here will have to change for a different number of bugs
# I'll sort out a cleaner way later.

# Create an empty data table in which to bind the values:
description_readability_measures <- NULL;

for (i in seq(1, 774809, by=45577)) {
	description_readability_measures_current <- foreach(current_description = isplitVector(bugs_all$description[(i):(i+45576)], chunkSize=1), 
												current_id 		    = isplitVector(bugs_all$bug_id[(i):(i+45576)], 	 chunkSize=1), 
												.combine="rbind", .inorder=FALSE, .multicombine=TRUE, .maxcombine=600L, .verbose=TRUE) %dopar% {
													# Provide output to track process
													current_time <- Sys.time();
													current_node <- paste(Sys.info()[['nodename']], Sys.getpid(), sep='-');
													print(cat("At", format(current_time), "node", current_node, "reported: Now calculating readability measures for bug_id", current_id, "\n(ignore trailing NULL ->)"));
													calculate_readability_measures(current_description, current_id);
												}
	# Write to separate files for each for loop after end of foreach
	# That way CPU cores aren't competing for write access
	write.csv(x = description_readability_measures_current, file = paste0("./readability/description_readability_measures_rows_", i, "_to_", i + 45576, ".csv"), row.names = FALSE);
	description_readability_measures <<- rbind(description_readability_measures, description_readability_measures_current);
}												


# Output the final rbind file:
write.csv(x=description_readability_measures, file = "./readability/description_readability_measures_final.csv", row.names=FALSE);

# Ends here	
	
# After the multicore operations are done, we should kill the spawned processes 
stopCluster(cluster);
											
												  
# Convert bug_id back to an integer factor
description_readability_measures <- mutate(description_readability_measures, bug_id = as.factor(as.numeric(bug_id)));												  


# Merge with bugs_working
setkey(description_readability_measures, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, description_readability_measures, by="bug_id", all.x=TRUE);



# BUGS_OUTCOME_PREDICTION_WITH_GZIP

# This section adapts to bug classification the language detection method described in: 
# Benedetto, Caglioti & Loreto, 2002 - Language Trees and Zipping, Physical Review Letters, 88(4)
# From the Methematics & Physics Departments of La Sapienza University in Rome, Italy.
# Direct link to PDF of article: http://samarcanda.phys.uniroma1.it/vittorioloreto/PAPERS/2002/Benedetto_PhysRevLett_2002.pdf
# It also adapts some of the tricks used by M.eik Michalke in package:korPus's guess.lang() function
# which were the inspiration for adapting this method to Bugzilla analysis.  Thanks M.eik!
# See http://reaktanz.de/?c=hacking&s=koRpus & https://github.com/unDocUMeantIt/koRpus for details
# Citation: Michalke, M. (2012, April). koRpus -- ein R-paket zur textanalyse. 
# Paper presented at the Tagung experimentell arbeitender Psychologen (TeaP), Mannheim.

# First, we create a small function that creates gzip archives in memory and
# returns the size of the archive without writing anything to file.
# The function accepts a vector of character strings and returns
# a base object of type object_size that is size in bytes with appropriate S3 methods

compressed_text_size <- function(obj){

  if(is.character(obj) && is.vector(obj)){
    # Verify the passed object is a vector of character strings
    txt <- obj;
  } else {
    stop(simpleError("Object passed to text_compress is not a vector of character strings.\n"));
  }
    # Use function base:memCompress which can take a whole vector of character strings and compress it at once
	# memCompress does the compression only in memory, which is exactly what we want
    compressed_txt 		 <- memCompress(from = txt, type = "gzip");
	
	return(object.size(compressed_txt));
} # End function compressed_text_size

# Calculate the size of the gzip archives of the descriptions of each of fixed & not_fixed bugs
description_fixed_gzip_size 	<- compressed_text_size(bugs_fixed$description);
description_not_fixed_gzip_size <- compressed_text_size(bugs_not_fixed$description);

# Add the description to guess to each of the fixed & not_fixed base compressions and see which one
# it increases less.
# This is really slow as it needs to compress all fixed & non_fixed descriptions for each prediction
# We'll do it in multicore as before using foreach() and %dopar% to build the results in parallel

cluster <- makeCluster(CPU_CORES, outfile="output_from_core_processes.txt");
registerDoParallel(cluster);

description_gzip_outcome_prediction <- foreach (current_description = isplitVector(bugs_all$description, chunkSize = 1),
											    current_id 		    = isplitVector(bugs_all$bug_id, 	  chunkSize = 1),
											    .combine="rbind", .inorder=FALSE, .multicombine=TRUE, .maxcombine=1000L, .verbose=TRUE) %dopar% {
											    
												# Provide output to track process
												current_time <- Sys.time();
												current_node <- paste(Sys.info()[['nodename']], Sys.getpid(), sep='-');
												print(cat("At", format(current_time), "node", current_node, "reported:> Now calculating description_gzip outcome prediction for bug_id", current_id, "(ignore trailing NULL ->)"));
												
											    # Recreate fixed & not_fixed gzip archives with each description
												current_description_fixed_guess_size 	 <- compressed_text_size(c(bugs_fixed$description, current_description));
												current_description_not_fixed_guess_size <- compressed_text_size(c(bugs_not_fixed$description, current_description));
												
												# Subtract the base fixed & not_fixed compressed size from the size of each new archive with the added description
												fixed_size_increase 	<- current_description_fixed_guess_size 	- description_fixed_gzip_size;
												not_fixed_size_increase <- current_description_not_fixed_guess_size - description_not_fixed_gzip_size; 
												
												# Determine which archive increased in size less by adding the current_description.  That one is the prediction.
												# If the increase is the same, prediction is NA
												if (fixed_size_increase == not_fixed_size_increase) {
													outcome_prediction <- NA;
												} else if (fixed_size_increase > not_fixed_size_increase) {
														outcome_prediction <- "not_fixed";
													} else 		
														outcome_prediction <- "fixed";
														
												# Build a data.table with columns bug_id and description_gzip_outcome_prediction to append via rbind in the foreach													
												description_gzip_outcome_prediction_table <- data.table::data.table(bug_id								= current_id,
																													description_gzip_outcome_prediction = outcome_prediction);
																													
												# "Return" (without return() function) the assembled table for foreach to use in the rbind				    
												description_gzip_outcome_prediction_table;
											}
											
# Convert bug_id back to an integer factor
description_gzip_outcome_prediction = mutate(description_gzip_outcome_prediction, bug_id = as.factor(as.numeric(bug_id)));	
											
# Merge bugs_working and description_gzip_outcome_prediction based on bug_id
setkey(description_gzip_outcome_prediction, bug_id);
setkey(bugs_working, bug_id);
bugs_working <- merge(bugs_working, description_gzip_outcome_prediction, by="bug_id", all.x="TRUE");


# PROFILES-BUGS_DESCRIPTION_READABILITY_AVERAGES
#(Calculate the average readability of the description of each bug reported by, assigned_to, or for which each user is qa_contact)

bugs_reporter_grouped <- group_by(select(bugs_working, starts_with("description_readability"), reporter), reporter);
                                                                                                                                                                                           
bugs_reporter_summary <- summarize(bugs_reporter_grouped, bugs_reported_description_readability_ARI_grade_mean						    = mean(description_readability_ARI_grade,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_Coleman_1_mean                         = mean(description_readability_Coleman_1,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_Coleman_2_mean                         = mean(description_readability_Coleman_2,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_Coleman_3_mean                         = mean(description_readability_Coleman_3,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_Coleman_4_mean                         = mean(description_readability_Coleman_4,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_Coleman_Liau_grade_mean                = mean(description_readability_Coleman_Liau_grade,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Coleman_Liau_short_mean                = mean(description_readability_Coleman_Liau_short,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Danielson_Bryan_1_mean                 = mean(description_readability_Danielson_Bryan_1,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Danielson_Bryan_2_mean                 = mean(description_readability_Danielson_Bryan_2,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Danielson_Bryan_grade_min_mean         = mean(description_readability_Danielson_Bryan_grade_min,	    na.rm=TRUE),
                                                          bugs_reported_description_readability_Dickes_Steiwer_mean                    = mean(description_readability_Dickes_Steiwer,	                na.rm=TRUE),
                                                          bugs_reported_description_readability_ELF_mean                               = mean(description_readability_ELF,	                            na.rm=TRUE),
                                                          bugs_reported_description_readability_Farr_Jenkins_Paterson_mean             = mean(description_readability_Farr_Jenkins_Paterson,	        na.rm=TRUE),
                                                          bugs_reported_description_readability_Farr_Jenkins_Paterson_grade_min_mean   = mean(description_readability_Farr_Jenkins_Paterson_grade_min,	na.rm=TRUE),	
                                                          bugs_reported_description_readability_Flesch_reading_ease_mean               = mean(description_readability_Flesch_reading_ease,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Flesch_grade_min_mean                  = mean(description_readability_Flesch_grade_min,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Flesch_Kincaid_grade_mean              = mean(description_readability_Flesch_Kincaid_grade,	        na.rm=TRUE),
                                                          bugs_reported_description_readability_Flesch_Kincaid_age_mean                = mean(description_readability_Flesch_Kincaid_age,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_FOG_mean                               = mean(description_readability_FOG,	                            na.rm=TRUE),
                                                          bugs_reported_description_readability_FORCAST_grade_mean                     = mean(description_readability_FORCAST_grade,	                na.rm=TRUE),
                                                          bugs_reported_description_readability_FORCAST_age_mean                       = mean(description_readability_FORCAST_age,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_Fucks_mean                             = mean(description_readability_Fucks,	                        na.rm=TRUE),
                                                          bugs_reported_description_readability_Fucks_grade_mean                       = mean(description_readability_Fucks_grade,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_Linsear_Write_raw_mean                 = mean(description_readability_Linsear_Write_raw,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Linsear_Write_grade_mean               = mean(description_readability_Linsear_Write_grade,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_LIX_index_mean                         = mean(description_readability_LIX_index,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_LIX_grade_min_mean                     = mean(description_readability_LIX_grade_min,	                na.rm=TRUE),
                                                          bugs_reported_description_readability_RIX_index_mean                         = mean(description_readability_RIX_index,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_RIX_grade_min_mean                     = mean(description_readability_RIX_grade_min,	                na.rm=TRUE),
                                                          bugs_reported_description_readability_SMOG_grade_mean                        = mean(description_readability_SMOG_grade,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_SMOG_age_mean                          = mean(description_readability_SMOG_age,	                    na.rm=TRUE),
                                                          bugs_reported_description_readability_Strain_index_mean                      = mean(description_readability_Strain_index,	                na.rm=TRUE),
                                                          bugs_reported_description_readability_Traenkle_Bailer_1_mean                 = mean(description_readability_Traenkle_Bailer_1,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Traenkle_Bailer_2_mean                 = mean(description_readability_Traenkle_Bailer_2,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_TRI_mean                               = mean(description_readability_TRI,	                            na.rm=TRUE),
                                                          bugs_reported_description_readability_Tuldava_mean                           = mean(description_readability_Tuldava,	                        na.rm=TRUE),
                                                          bugs_reported_description_readability_Wheeler_Smith_score_mean               = mean(description_readability_Wheeler_Smith_score,	            na.rm=TRUE),
                                                          bugs_reported_description_readability_Wheeler_Smith_grade_min_mean           = mean(description_readability_Wheeler_Smith_grade_min,	        na.rm=TRUE));

# If the description readability measures couldn't be calculated, they are reported as NA, leading to the mean() function returning NaN.
# Replace NaN values with NA - We use is.na() instead of is.nan() because there is no s3 method for data.frames for is.nan() and
# NaN values are also NA values (of a different base type - There are multiple underlying NA types)
# Use data.table's convenient method
bugs_reporter_summary[is.na(bugs_reporter_summary)] 	  <- NA;



# Repeat with  assigned_to

bugs_assigned_to_grouped <- group_by(select(bugs_working, starts_with("description_readability"), assigned_to), assigned_to);
                                                                                                                                                                                           
bugs_assigned_to_summary <- summarize(bugs_assigned_to_grouped, bugs_assigned_to_description_readability_ARI_grade_mean						 = mean(description_readability_ARI_grade,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_Coleman_1_mean                         = mean(description_readability_Coleman_1,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_Coleman_2_mean                         = mean(description_readability_Coleman_2,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_Coleman_3_mean                         = mean(description_readability_Coleman_3,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_Coleman_4_mean                         = mean(description_readability_Coleman_4,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_Coleman_Liau_grade_mean                = mean(description_readability_Coleman_Liau_grade,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_Coleman_Liau_short_mean                = mean(description_readability_Coleman_Liau_short,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_Danielson_Bryan_1_mean                 = mean(description_readability_Danielson_Bryan_1,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_Danielson_Bryan_2_mean                 = mean(description_readability_Danielson_Bryan_2,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_Danielson_Bryan_grade_min_mean         = mean(description_readability_Danielson_Bryan_grade_min,	     na.rm=TRUE),
																bugs_assigned_to_description_readability_Dickes_Steiwer_mean                    = mean(description_readability_Dickes_Steiwer,	                 na.rm=TRUE),
																bugs_assigned_to_description_readability_ELF_mean                               = mean(description_readability_ELF,	                         na.rm=TRUE),
																bugs_assigned_to_description_readability_Farr_Jenkins_Paterson_mean             = mean(description_readability_Farr_Jenkins_Paterson,	         na.rm=TRUE),
																bugs_assigned_to_description_readability_Farr_Jenkins_Paterson_grade_min_mean   = mean(description_readability_Farr_Jenkins_Paterson_grade_min, na.rm=TRUE),	
																bugs_assigned_to_description_readability_Flesch_reading_ease_mean               = mean(description_readability_Flesch_reading_ease,	         na.rm=TRUE),
																bugs_assigned_to_description_readability_Flesch_grade_min_mean                  = mean(description_readability_Flesch_grade_min,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_Flesch_Kincaid_grade_mean              = mean(description_readability_Flesch_Kincaid_grade,	         na.rm=TRUE),
																bugs_assigned_to_description_readability_Flesch_Kincaid_age_mean                = mean(description_readability_Flesch_Kincaid_age,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_FOG_mean                               = mean(description_readability_FOG,	                         na.rm=TRUE),
																bugs_assigned_to_description_readability_FORCAST_grade_mean                     = mean(description_readability_FORCAST_grade,	                 na.rm=TRUE),
																bugs_assigned_to_description_readability_FORCAST_age_mean                       = mean(description_readability_FORCAST_age,	                 na.rm=TRUE),
																bugs_assigned_to_description_readability_Fucks_mean                             = mean(description_readability_Fucks,	                         na.rm=TRUE),
																bugs_assigned_to_description_readability_Fucks_grade_mean                       = mean(description_readability_Fucks_grade,	                 na.rm=TRUE),
																bugs_assigned_to_description_readability_Linsear_Write_raw_mean                 = mean(description_readability_Linsear_Write_raw,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_Linsear_Write_grade_mean               = mean(description_readability_Linsear_Write_grade,	         na.rm=TRUE),
																bugs_assigned_to_description_readability_LIX_index_mean                         = mean(description_readability_LIX_index,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_LIX_grade_min_mean                     = mean(description_readability_LIX_grade_min,	                 na.rm=TRUE),
																bugs_assigned_to_description_readability_RIX_index_mean                         = mean(description_readability_RIX_index,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_RIX_grade_min_mean                     = mean(description_readability_RIX_grade_min,	                 na.rm=TRUE),
																bugs_assigned_to_description_readability_SMOG_grade_mean                        = mean(description_readability_SMOG_grade,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_SMOG_age_mean                          = mean(description_readability_SMOG_age,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_Strain_index_mean                      = mean(description_readability_Strain_index,	                 na.rm=TRUE),
																bugs_assigned_to_description_readability_Traenkle_Bailer_1_mean                 = mean(description_readability_Traenkle_Bailer_1,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_Traenkle_Bailer_2_mean                 = mean(description_readability_Traenkle_Bailer_2,	             na.rm=TRUE),
																bugs_assigned_to_description_readability_TRI_mean                               = mean(description_readability_TRI,	                         na.rm=TRUE),
																bugs_assigned_to_description_readability_Tuldava_mean                           = mean(description_readability_Tuldava,	                     na.rm=TRUE),
																bugs_assigned_to_description_readability_Wheeler_Smith_score_mean               = mean(description_readability_Wheeler_Smith_score,	         na.rm=TRUE),
																bugs_assigned_to_description_readability_Wheeler_Smith_grade_min_mean           = mean(description_readability_Wheeler_Smith_grade_min,	     na.rm=TRUE));

# If the description readability measures couldn't be calculated, they are reported as NA, leading to the mean() function returning NaN.
# Replace NaN values with NA - We use is.na() instead of is.nan() because there is no s3 method for data.frames for is.nan() and
# NaN values are also NA values (of a different base type - There are multiple underlying NA types)
# Use data.table's convenient method
bugs_assigned_to_summary[is.na(bugs_assigned_to_summary)] 		<- NA;
 
 
# Repeat with qa_contact
bugs_qa_contact_grouped <- group_by(select(bugs_working, starts_with("description_readability"), qa_contact), qa_contact);
                                                                                                                                                                                           
bugs_qa_contact_summary <- summarize(bugs_qa_contact_grouped, bugs_qa_contact_description_readability_ARI_grade_mean						  = mean(description_readability_ARI_grade,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_Coleman_1_mean                         = mean(description_readability_Coleman_1,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_Coleman_2_mean                         = mean(description_readability_Coleman_2,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_Coleman_3_mean                         = mean(description_readability_Coleman_3,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_Coleman_4_mean                         = mean(description_readability_Coleman_4,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_Coleman_Liau_grade_mean                = mean(description_readability_Coleman_Liau_grade,	          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Coleman_Liau_short_mean                = mean(description_readability_Coleman_Liau_short,	          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Danielson_Bryan_1_mean                 = mean(description_readability_Danielson_Bryan_1,	              na.rm=TRUE),
															  bugs_qa_contact_description_readability_Danielson_Bryan_2_mean                 = mean(description_readability_Danielson_Bryan_2,	              na.rm=TRUE),
															  bugs_qa_contact_description_readability_Danielson_Bryan_grade_min_mean         = mean(description_readability_Danielson_Bryan_grade_min,	      na.rm=TRUE),
															  bugs_qa_contact_description_readability_Dickes_Steiwer_mean                    = mean(description_readability_Dickes_Steiwer,	              na.rm=TRUE),
															  bugs_qa_contact_description_readability_ELF_mean                               = mean(description_readability_ELF,	                          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Farr_Jenkins_Paterson_mean             = mean(description_readability_Farr_Jenkins_Paterson,	          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Farr_Jenkins_Paterson_grade_min_mean   = mean(description_readability_Farr_Jenkins_Paterson_grade_min, na.rm=TRUE),	
															  bugs_qa_contact_description_readability_Flesch_reading_ease_mean               = mean(description_readability_Flesch_reading_ease,	          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Flesch_grade_min_mean                  = mean(description_readability_Flesch_grade_min,	              na.rm=TRUE),
															  bugs_qa_contact_description_readability_Flesch_Kincaid_grade_mean              = mean(description_readability_Flesch_Kincaid_grade,	          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Flesch_Kincaid_age_mean                = mean(description_readability_Flesch_Kincaid_age,	          na.rm=TRUE),
															  bugs_qa_contact_description_readability_FOG_mean                               = mean(description_readability_FOG,	                          na.rm=TRUE),
															  bugs_qa_contact_description_readability_FORCAST_grade_mean                     = mean(description_readability_FORCAST_grade,	                  na.rm=TRUE),
															  bugs_qa_contact_description_readability_FORCAST_age_mean                       = mean(description_readability_FORCAST_age,	                  na.rm=TRUE),
															  bugs_qa_contact_description_readability_Fucks_mean                             = mean(description_readability_Fucks,	                          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Fucks_grade_mean                       = mean(description_readability_Fucks_grade,	                  na.rm=TRUE),
															  bugs_qa_contact_description_readability_Linsear_Write_raw_mean                 = mean(description_readability_Linsear_Write_raw,	              na.rm=TRUE),
															  bugs_qa_contact_description_readability_Linsear_Write_grade_mean               = mean(description_readability_Linsear_Write_grade,	          na.rm=TRUE),
															  bugs_qa_contact_description_readability_LIX_index_mean                         = mean(description_readability_LIX_index,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_LIX_grade_min_mean                     = mean(description_readability_LIX_grade_min,	                  na.rm=TRUE),
															  bugs_qa_contact_description_readability_RIX_index_mean                         = mean(description_readability_RIX_index,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_RIX_grade_min_mean                     = mean(description_readability_RIX_grade_min,	                  na.rm=TRUE),
															  bugs_qa_contact_description_readability_SMOG_grade_mean                        = mean(description_readability_SMOG_grade,	                  na.rm=TRUE),
															  bugs_qa_contact_description_readability_SMOG_age_mean                          = mean(description_readability_SMOG_age,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_Strain_index_mean                      = mean(description_readability_Strain_index,	                  na.rm=TRUE),
															  bugs_qa_contact_description_readability_Traenkle_Bailer_1_mean                 = mean(description_readability_Traenkle_Bailer_1,	              na.rm=TRUE),
															  bugs_qa_contact_description_readability_Traenkle_Bailer_2_mean                 = mean(description_readability_Traenkle_Bailer_2,	              na.rm=TRUE),
															  bugs_qa_contact_description_readability_TRI_mean                               = mean(description_readability_TRI,	                          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Tuldava_mean                           = mean(description_readability_Tuldava,	                      na.rm=TRUE),
															  bugs_qa_contact_description_readability_Wheeler_Smith_score_mean               = mean(description_readability_Wheeler_Smith_score,	          na.rm=TRUE),
															  bugs_qa_contact_description_readability_Wheeler_Smith_grade_min_mean           = mean(description_readability_Wheeler_Smith_grade_min,	      na.rm=TRUE));

# If the description readability measures couldn't be calculated, they are reported as NA, leading to the mean() function returning NaN.
# Replace NaN values with NA - We use is.na() instead of is.nan() because there is no s3 method for data.frames for is.nan() and
# NaN values are also NA values (of a different base type - There are multiple underlying NA types)
# Use data.table's convenient method
bugs_qa_contact_summary[is.na(bugs_qa_contact_summary)] 	  <- NA;

# Merge results with profiles_working table
setkey(bugs_reporter_summary, 	 reporter);
setkey(bugs_assigned_to_summary, assigned_to);
setkey(bugs_qa_contact_summary,  qa_contact);
setkey(profiles_working, 		 userid);

profiles_working <- merge(profiles_working, bugs_reporter_summary,	 	by.x="userid", by.y="reporter", 	all.x=TRUE);
profiles_working <- merge(profiles_working, bugs_assigned_to_summary,	by.x="userid", by.y="assigned_to", 	all.x=TRUE);
profiles_working <- merge(profiles_working, bugs_qa_contact_summary,	by.x="userid", by.y="qa_contact", 	all.x=TRUE);











												  
# CLEAN UP

# Set global variables for other functions
bugs_calculated 	<<- bugs_working;
profiles_calculated <<- profiles_working;

} # End operationalize_very_slow_calculations function


# OPERATIONALIZE BUGS SUMMARY TABLE

operationalize_bugs_summary <- function() {
# This function creates a summary table for various characteristics for all bugs that arent indexed by bug_id
# It's more of a matrix, with the rows reflecting user_actions and the columns reflecting bug classifications

# We create a function that can generate the appropriate column of values from the desired subset
generate_subset_column <- function (subset_bug_ids) {

	# Generate subsets of required tables                               
	bugs_current 			<- filter(bugs_calculated, 			bug_id  %in% subset_bug_ids);
	activity_current		<- filter(activity_base, 			bug_id  %in% subset_bug_ids);
	longdescs_current		<- filter(longdescs_interactions, 	bug_id  %in% subset_bug_ids);
	cc_current				<- filter(cc_base, 					bug_id  %in% subset_bug_ids);
	attachments_current		<- filter(attachments_base,			bug_id  %in% subset_bug_ids);
	votes_current			<- filter(votes_base, 				bug_id  %in% subset_bug_ids);
	keywords_current		<- filter(keywords_base, 			bug_id  %in% subset_bug_ids);
	flags_current			<- filter(flags_base,				bug_id  %in% subset_bug_ids);
	duplicates_current		<- filter(duplicates_base,			dupe    %in% subset_bug_ids   | dupe_of %in% subset_bug_ids);
	dependencies_current	<- filter(dependencies_base,		blocked %in% subset_bug_ids   | dependson %in% subset_bug_ids);
	
	

	# Bugs:
	bugs_count								<- nrow(bugs_current);
	distinct_reporter_count 				<- data.table::uniqueN(bugs_current$reporter);
	distinct_assigned_to_count 				<- data.table::uniqueN(bugs_current$assigned_to);
	distinct_qa_contact_count 				<- data.table::uniqueN(bugs_current$qa_contact);
	distinct_reporter_domain_count 			<- data.table::uniqueN(bugs_current$reporter_domain);
	distinct_assigned_to_domain_count 		<- data.table::uniqueN(bugs_current$assigned_to_domain);
	distinct_qa_contact_domain_count 		<- data.table::uniqueN(bugs_current$qa_contact_domain);
	distinct_reporter_org_domain_count 		<- data.table::uniqueN(filter(bugs_current, is_org_reporter_domain==TRUE)$reporter_domain);
	distinct_assigned_to_org_domain_count 	<- data.table::uniqueN(filter(bugs_current, is_org_assigned_to_domain==TRUE)$assigned_to_domain);
	distinct_qa_contact_org_domain_count 	<- data.table::uniqueN(filter(bugs_current, is_org_qa_contact_domain==TRUE)$qa_contact_domain);

	# Activities:
	activity_count							<- nrow(activity_current);
	distinct_activity_who_count 			<- data.table::uniqueN(activity_current$who);
	distinct_activity_who_domain_count		<- data.table::uniqueN(activity_current$who_domain);
	distinct_activity_who_org_domain_count 	<- data.table::uniqueN(filter(activity_current, is_org_who_domain==TRUE)$who_domain);
	

	# Comments:
	# The description_comment_ids variable allows us to exclude "descriptions" from comments to make our count more accurate
	longdescs_comments_only <- filter(longdescs_current, !(comment_id %in% description_comment_ids));

	# Now count comments without the descriptions
	comments_count							<- nrow(longdescs_comments_only);
	distinct_comments_who_count 			<- data.table::uniqueN(longdescs_comments_only$who);
	distinct_comments_who_domain_count 		<- data.table::uniqueN(longdescs_comments_only$who_domain);
	distinct_comments_who_org_domain_count 	<- data.table::uniqueN(filter(longdescs_comments_only, is_org_who_domain==TRUE)$who_domain);
	

	# CCs:
	cc_count							<- nrow(cc_current);
	distinct_cc_who_count				<- data.table::uniqueN(cc_current$who);
	distinct_cc_who_domain_count		<- data.table::uniqueN(cc_current$who_domain);
	distinct_cc_who_org_domain_count	<- data.table::uniqueN(filter(cc_current, is_org_who_domain==TRUE)$who_domain);


	# Attachments:
	attachments_count									<- nrow(attachments_current);
	distinct_attachments_submitter_id_count				<- data.table::uniqueN(attachments_current$submitter_id);
	distinct_attachments_submitter_id_domain_count		<- data.table::uniqueN(attachments_current$submitter_id_domain);
	distinct_attachments_submitter_id_org_domain_count	<- data.table::uniqueN(filter(attachments_current, is_org_submitter_id_domain==TRUE)$submitter_id_domain);


	# Votes:
	votes_count							<- nrow(votes_current);
	distinct_votes_who_count			<- data.table::uniqueN(votes_current$who);
	distinct_votes_who_domain_count		<- data.table::uniqueN(votes_current$who_domain);
	distinct_votes_who_org_domain_count	<- data.table::uniqueN(filter(votes_current, is_org_who_domain==TRUE)$who_domain);


	# Duplicates:
	# Two variables: Duplicates (dupe), i.e. bugs that duplicate another bug & duplicated (dupe_of), i.e. bugs that have been duplicated by another bug
	duplicates_count							<- data.table::uniqueN(duplicates_current$dupe);
	duplicated_count							<- data.table::uniqueN(duplicates_current$dupe_of);


	# Keywords:
	keywords_count								<- nrow(keywords_current);
	distinct_keywords_count						<- data.table::uniqueN(keywords_current$keywordid);


	# Flags:
	flags_count                                     <- nrow(flags_current);
	distinct_flags_count                       		<- data.table::uniqueN(flags_current$type_id);
	distinct_flags_setter_id_count             		<- data.table::uniqueN(flags_current$setter_id);
	distinct_flags_setter_id_domain_count      		<- data.table::uniqueN(flags_current$setter_id_domain);
	distinct_flags_setter_id_org_domain_count  		<- data.table::uniqueN(filter(flags_current, is_org_setter_id_domain==TRUE)$setter_id_domain);
	distinct_flags_requestee_id_count          		<- data.table::uniqueN(flags_current$requestee_id);
	distinct_flags_requestee_id_domain_count   		<- data.table::uniqueN(flags_current$requestee_id_domain);
	distinct_flags_requestee_id_org_domain_count   	<- data.table::uniqueN(filter(flags_current, is_org_requestee_id_domain==TRUE)$requestee_id_domain);


	# Dependencies:
	# Two variables: Blocked (blocked), i.e. bugs that are blocked BY another bug & blocking (dependson), i.e. bugs that are DOING the blocking of other bugs
	blocked_count								<- data.table::uniqueN(dependencies_current$blocked);
	blocking_count								<- data.table::uniqueN(dependencies_current$dependson);



	# Capture the summary for the most recent calculations
	bugs_current_summary <- data.table(summary_type = c("bugs_count", 				"bugs_distinct_reporter_count",				"bugs_distinct_reporter_domain_count", 				"bugs_distinct_reporter_org_domain_count",		
																					"bugs_distinct_assigned_to_count",			"bugs_distinct_assigned_to_domain_count",			"bugs_distinct_assigned_to_org_domain_count",
																					"bugs_distinct_qa_contact_count",			"bugs_distinct_qa_contact_domain_count",			"bugs_distinct_qa_contact_org_domain_count",
														"activity_count", 			"activity_distinct_who_count",			  	"activity_distinct_who_domain_count", 				"activity_distinct_who_org_domain_count", 	
														"comments_count", 			"comments_distinct_who_count",			  	"comments_distinct_who_domain_count",               "comments_distinct_who_org_domain_count",
														"cc_count",		  			"cc_distinct_who_count", 	  			  	"cc_distinct_who_domain_count",                     "cc_distinct_who_org_domain_count",
														"attachments_count", 		"attachments_distinct_submitter_id_count",	"attachments_distinct_submitter_id_domain_count",   "attachments_distinct_submitter_id_org_domain_count",
														"votes_count",				"votes_distinct_who_count",				  	"votes_distinct_who_domain_count",                  "votes_distinct_who_org_domain_count",
														"duplicates_count", 		"duplicated_count",                                                                              
														"keywords_count",			"keywords_distinct_count",                                                                       
														"flags_count", 				"flags_distinct_count",                                                                          
																					"flags_setter_id_distinct_count", 		  	"flags_distinct_setter_id_domain_count",            "flags_distinct_setter_id_org_domain_count",
																					"flags_requestee_distinct_id_count",	  	"flags_distinct_requestee_id_domain_count",         "flags_distinct_requestee_id_org_domain_count",
														"blocked_count",			"blocking_count"),
				 
																 
																				 
									   bugs_current	= c(bugs_count,			distinct_reporter_count,					distinct_reporter_domain_count,								distinct_reporter_org_domain_count,
																			distinct_assigned_to_count,					distinct_assigned_to_domain_count,                          distinct_assigned_to_org_domain_count,
																			distinct_qa_contact_count,					distinct_qa_contact_domain_count,                           distinct_qa_contact_org_domain_count,
														activity_count, 	distinct_activity_who_count, 				distinct_activity_who_domain_count,			 				distinct_activity_who_org_domain_count,
														comments_count, 	distinct_comments_who_count, 				distinct_comments_who_domain_count,             			distinct_comments_who_org_domain_count,
														cc_count, 			distinct_cc_who_count, 						distinct_cc_who_domain_count,                   			distinct_cc_who_org_domain_count,
														attachments_count, 	distinct_attachments_submitter_id_count, 	distinct_attachments_submitter_id_domain_count, 			distinct_attachments_submitter_id_org_domain_count,
														votes_count, 		distinct_votes_who_count, 					distinct_votes_who_domain_count,                			distinct_votes_who_org_domain_count,
														duplicates_count, 	duplicated_count,                                                                           			                 
														keywords_count, 	distinct_keywords_count,                                                                    			        
														flags_count, 		distinct_flags_count,                                                                       			        
																			distinct_flags_setter_id_count, 			distinct_flags_setter_id_domain_count,          			distinct_flags_setter_id_org_domain_count,
																			distinct_flags_requestee_id_count, 			distinct_flags_requestee_id_domain_count,       			distinct_flags_requestee_id_org_domain_count,
														blocked_count, 		blocking_count));
									   
									   

	return(bugs_current_summary);
} # End generate_subset_column function


# First we create the "bugs_all" column with the full bugs table
# We pass the list of ALL the bug_ids to get the full table
bugs_summary_cummulative <- generate_subset_column(bugs_calculated$bug_id)

# Rename bug column to ensure it's clear what it is
bugs_summary_cummulative <- dplyr::rename(bugs_summary_cummulative, bugs_all=bugs_current);


# Next we need to create for loops to iterate through all the possible types and call the column generation for the subsets of each one
# Start with rep_platform (hardware)

for(i in 1: data.table::uniqueN(bugs_calculated$rep_platform)) {
	# Capture the name of the rep_platform in the current iteration
	current_platform_name <- sort(unique(bugs_calculated$rep_platform))[i];
	
	# Call the generate_subset_column function, passing it the bug_ids of bugs of the current platform
	bugs_summary_current_iteration <- generate_subset_column(filter(bugs_calculated, rep_platform==current_platform_name)$bug_id);
	
	
	# Replace spaces with underscores for simplicity
	current_platform_name <- gsub(" ", "_", current_platform_name, fixed=TRUE);
	
	# Rename bug column to ensure it's clear what it is
	colnames(bugs_summary_current_iteration)[2] <- paste("rep_platform_", tolower(current_platform_name), sep = "");

	# Merge the new column with bugs_summary_cummulative
	setkey(bugs_summary_cummulative, summary_type);
	setkey(bugs_summary_current_iteration, summary_type);
	bugs_summary_cummulative <- merge(bugs_summary_cummulative, bugs_summary_current_iteration, by="summary_type", all.x=TRUE);

} # End for loop for rep_platforms


# Repeat for op_sys

for(i in 1: data.table::uniqueN(bugs_calculated$op_sys)) {
	# Capture the name of the op_sys in the current iteration
	current_op_sys_name <- sort(unique(bugs_calculated$op_sys))[i];
	
	# Call the generate_subset_column function, passing it the bug_ids of bugs of the current platform
	bugs_summary_current_iteration <- generate_subset_column(filter(bugs_calculated, op_sys==current_op_sys_name)$bug_id);
	
	# Replace spaces with underscores for simplicity
	current_op_sys_name <- gsub(" ", "_", current_op_sys_name, fixed=TRUE);
	
	# Rename bug column to ensure it's clear what it is
	colnames(bugs_summary_current_iteration)[2] <- paste("op_sys_", tolower(current_op_sys_name), sep = "");

	# Merge the new column with bugs_summary_cummulative
	setkey(bugs_summary_cummulative, summary_type);
	setkey(bugs_summary_current_iteration, summary_type);
	bugs_summary_cummulative <- merge(bugs_summary_cummulative, bugs_summary_current_iteration, by="summary_type", all.x=TRUE);

} # End for loop for op_sys


# Repeat for (product) classification

for(i in 1: data.table::uniqueN(bugs_calculated$classification_name)) {
	# Capture the classification_name in the current iteration
	current_classification_name <- sort(unique(bugs_calculated$classification_name))[i];
	
	# Call the generate_subset_column function, passing it the bug_ids of bugs of the current platform
	bugs_summary_current_iteration <- generate_subset_column(filter(bugs_calculated, classification_name==current_classification_name)$bug_id);
	
	# Rename bug column to ensure it's clear what it is
	colnames(bugs_summary_current_iteration)[2] <- paste("classification_name_", current_classification_name, sep = "");

	# Merge the new column with bugs_summary_cummulative
	setkey(bugs_summary_cummulative, summary_type);
	setkey(bugs_summary_current_iteration, summary_type);
	bugs_summary_cummulative <- merge(bugs_summary_cummulative, bugs_summary_current_iteration, by="summary_type", all.x=TRUE);

} # End for loop for classification_name


# Repeat for product

for(i in 1: data.table::uniqueN(bugs_calculated$product_name)) {
	# Capture the product_name in the current iteration
	current_product_name <- sort(unique(bugs_calculated$product_name))[i];
	
	# Call the generate_subset_column function, passing it the bug_ids of bugs of the current platform
	bugs_summary_current_iteration <- generate_subset_column(filter(bugs_calculated, product_name==current_product_name)$bug_id);
	
	# Rename bug column to ensure it's clear what it is
	colnames(bugs_summary_current_iteration)[2] <- paste("product_name_", current_product_name, sep = "");

	# Merge the new column with bugs_summary_cummulative
	setkey(bugs_summary_cummulative, summary_type);
	setkey(bugs_summary_current_iteration, summary_type);
	bugs_summary_cummulative <- merge(bugs_summary_cummulative, bugs_summary_current_iteration, by="summary_type", all.x=TRUE);

} # End for loop for product_name


# Repeat for component

for(i in 1: data.table::uniqueN(bugs_calculated$component_id)) {
	# Capture the component_name in the current iteration
	current_component_id   <- i;
	current_component_name <- tolower(distinct(filter(bugs_calculated, component_id == current_component_id), component_id)$component_name);
	
	# Replace spaces with underscores for simplicity
	current_component_name <- gsub(" ", "_", current_component_name, fixed=TRUE);
	
	# Call the generate_subset_column function, passing it the bug_ids of bugs of the current platform
	bugs_summary_current_iteration <- generate_subset_column(filter(bugs_calculated, component_id==current_component_id)$bug_id);
	
	new_column_name <- sprintf("component_id_%s_%s", current_component_id,  if (!is.null(current_component_name) &
																				   !identical(current_component_name, character(0))) {
																							  current_component_name}
																				 else 		 {"UNNAMED"});
	
	# Rename bug column to ensure it's clear what it is
	colnames(bugs_summary_current_iteration)[2] <- new_column_name;

	# Merge the new column with bugs_summary_cummulative
	setkey(bugs_summary_cummulative, summary_type);
	setkey(bugs_summary_current_iteration, summary_type);
	bugs_summary_cummulative <- merge(bugs_summary_cummulative, bugs_summary_current_iteration, by="summary_type", all.x=TRUE);

} # End for loop for component_name


# Repeat for creation_year

for(i in 1: data.table::uniqueN(bugs_calculated$creation_year)) {
	# Capture the creation_year in the current iteration
	current_creation_year <- sort(unique(bugs_calculated$creation_year))[i];
	
	# Call the generate_subset_column function, passing it the bug_ids of bugs of the current platform
	bugs_summary_current_iteration <- generate_subset_column(filter(bugs_calculated, creation_year==current_creation_year)$bug_id);
	
	# Rename bug column to ensure it's clear what it is
	colnames(bugs_summary_current_iteration)[2] <- paste("creation_year_", current_creation_year, sep = "");

	# Merge the new column with bugs_summary_cummulative
	setkey(bugs_summary_cummulative, summary_type);
	setkey(bugs_summary_current_iteration, summary_type);
	bugs_summary_cummulative <- merge(bugs_summary_cummulative, bugs_summary_current_iteration, by="summary_type", all.x=TRUE);

} # End for loop for creation_year


# NA values mean 0 so mutate accordingly
# Using data.table approach to hit all values at once in whole table
bugs_summary_cummulative[is.na(bugs_summary_cummulative)] <- 0;

# Drop columns that have all zeroes since they're not used in the current bugzilla
bugs_summary_cummulative_cleaned <- remove_all_zero_cols(bugs_summary_cummulative);


# The table is easier to read with the y axis being the long direction, so we can just transpose what we did above
# First, we want to set the rownames that will become the colnames after transpose
summary_rownames <- c("bugs_count", 		"bugs_distinct_reporter_count",				"bugs_distinct_reporter_domain_count", 				"bugs_distinct_reporter_org_domain_count",		
				    						"bugs_distinct_assigned_to_count",			"bugs_distinct_assigned_to_domain_count",			"bugs_distinct_assigned_to_org_domain_count",
				    						"bugs_distinct_qa_contact_count",			"bugs_distinct_qa_contact_domain_count",			"bugs_distinct_qa_contact_org_domain_count",
				      "activity_count", 	"activity_distinct_who_count",			  	"activity_distinct_who_domain_count", 				"activity_distinct_who_org_domain_count", 	
				      "comments_count", 	"comments_distinct_who_count",			  	"comments_distinct_who_domain_count",               "comments_distinct_who_org_domain_count",
				      "cc_count",		  	"cc_distinct_who_count", 	  			  	"cc_distinct_who_domain_count",                     "cc_distinct_who_org_domain_count",
				      "attachments_count", 	"attachments_distinct_submitter_id_count",	"attachments_distinct_submitter_id_domain_count",   "attachments_distinct_submitter_id_org_domain_count",
				      "votes_count",		"votes_distinct_who_count",				  	"votes_distinct_who_domain_count",                  "votes_distinct_who_org_domain_count",
				      "duplicates_count", 	"duplicated_count",                                                                              
				      "keywords_count",		"keywords_distinct_count",                                                                       
				      "flags_count", 		"flags_distinct_count",                                                                          
				      						"flags_setter_id_distinct_count", 		  	"flags_distinct_setter_id_domain_count",            "flags_distinct_setter_id_org_domain_count",
				      						"flags_requestee_distinct_id_count",	  	"flags_distinct_requestee_id_domain_count",         "flags_distinct_requestee_id_org_domain_count",
				      "blocked_count",		"blocking_count");

rownames(bugs_summary_cummulative_cleaned) <- summary_rownames;

# Transpose the table so that the long direction is the y axis and preserve the row/column names
bugs_summary_cummulative_transposed <- setnames(bugs_summary_cummulative_cleaned[, data.table(t(.SD), keep.rownames=TRUE), .SDcols=-"summary_type"],
												bugs_summary_cummulative_cleaned[, c('rn', summary_type)])[];


# Change the first column's name to act as an indicator of what the first column and column names are										
colnames(bugs_summary_cummulative_transposed)[1] <- 'bugs_subsets \\ summary_type';

# Rearrange the columns to have the bugs columns first
bugs_summary_cummulative_transposed <- select(bugs_summary_cummulative_transposed, one_of(c('bugs_subsets \\ summary_type', summary_rownames)));


# Output summaries to file if user has option set
if (OUTPUT_SUMMARY_TABLES_TO_FILE) {

	# Output to HTML
	sink("summary_kable.html");
		print(kable(bugs_summary_cummulative_transposed, format="html", caption="Summary of Mozilla's Bugzilla as of end 2012"));
	sink();

	# Alternative output to html approach with xtable library
	html_table <- xtable(bugs_summary_cummulative_transposed, auto=TRUE);
	print.xtable(html_table, type="html", file="summary_xtable.html", NA.string="NA", include.colnames=TRUE, include.rownames=FALSE);

	# Output to Excel
	write.xlsx2(bugs_summary_cummulative_transposed, "summary.xlsx", row.names=FALSE);
} # End if OUTPUT_SUMMARY_TABLES_TO_FILE



# CLEAN UP

# Set global variables for other functions
bugs_summary 	<<- bugs_summary_cummulative_transposed;
								   
} # End operationalize_bugs_summary function



# OPERATIONALIZE ORGANIZATION-LEVEL VARIABLES
# This function creates the organization-level variables based on the appropriate aggregations of the profiles table

operationalize_org_level <- function() {

# PROFILES-ALL_TABLES_ORG_SUMS
# (Summarize all the individual user counts into org-based counts for the various table interactions)
# Using the user-level variables created in previous functions, we can simply sum() by domain

# Import the profiles_interaction table to use in this function
profiles_working <- profiles_calculated;

# Group profiles according to domains
profiles_working_grouped_domain_sums <- group_by(profiles_working, domain);

# Use summarize() function to sum the various user counts for each domain
profiles_working_grouped_domain_sums_summary <- summarize(profiles_working_grouped_domain_sums,  
														  all_actors_count								= n(),
														  bugs_reported_is_duplicate_count 				= sum(bugs_reported_is_duplicate_count, na.rm = TRUE),
														  bugs_reported_was_duplicated_count 			= sum(bugs_reported_was_duplicated_count, na.rm = TRUE),
														  bugs_reported_all_duplications_count			= sum(bugs_reported_all_duplications_count, na.rm = TRUE),
														  flags_set_count 								= sum(flags_set_count, na.rm = TRUE),
														  watching_all_actors_count 					= sum(watching_all_actors_count, na.rm = TRUE),
														  watching_all_orgs_count 						= sum(watching_all_orgs_count, na.rm = TRUE),
														  watching_knowledge_actors_count 				= sum(watching_knowledge_actors_count, na.rm = TRUE),
														  watching_core_actors_count					= sum(watching_core_actors_count, na.rm = TRUE),
														  watching_peripheral_actors_count				= sum(watching_peripheral_actors_count, na.rm = TRUE),
														  watched_by_all_actors_count					= sum(watched_by_all_actors_count, na.rm = TRUE),
														  watched_by_all_orgs_count						= sum(watched_by_all_orgs_count, na.rm = TRUE),
														  watched_by_knowledge_actors_count				= sum(watched_by_knowledge_actors_count, na.rm = TRUE),
														  watched_by_core_actors_count					= sum(watched_by_core_actors_count, na.rm = TRUE),
														  watched_by_peripheral_actors_count			= sum(watched_by_peripheral_actors_count, na.rm = TRUE),
														  activity_all_actors_count 					= sum(activity_count, na.rm = TRUE),
														  bugs_reported_count 							= sum(bugs_reported_count, na.rm = TRUE),
														  bugs_assigned_count 							= sum(bugs_assigned_to_count, na.rm = TRUE),
														  bugs_qa_count 								= sum(bugs_qa_contact_count, na.rm = TRUE),
														  bugs_reported_reopened_count 					= sum(bugs_reported_reopened_count, na.rm = TRUE),
														  bugs_reported_assigned_count 					= sum(bugs_reported_assigned_count, na.rm = TRUE),
														  bugs_reported_reassigned_count 				= sum(bugs_reported_reassigned_count, na.rm = TRUE),
														  bugs_reported_enhancement_count 				= sum(bugs_reported_enhancement_count, na.rm = TRUE), 	
														  bugs_reported_trivial_count 					= sum(bugs_reported_trivial_count, na.rm = TRUE), 		
														  bugs_reported_minor_count						= sum(bugs_reported_minor_count, na.rm = TRUE), 		
														  bugs_reported_normal_count 					= sum(bugs_reported_normal_count, na.rm = TRUE), 		
														  bugs_reported_major_count 					= sum(bugs_reported_major_count, na.rm = TRUE), 		
														  bugs_reported_critical_count 					= sum(bugs_reported_critical_count, na.rm = TRUE), 	
														  bugs_reported_blocker_count 					= sum(bugs_reported_blocker_count, na.rm = TRUE),
														  bugs_assigned_to_enhancement_count 			= sum(bugs_assigned_to_enhancement_count, na.rm = TRUE), 	
														  bugs_assigned_to_trivial_count 				= sum(bugs_assigned_to_trivial_count, na.rm = TRUE), 		
														  bugs_assigned_to_minor_count					= sum(bugs_assigned_to_minor_count, na.rm = TRUE), 		
														  bugs_assigned_to_normal_count 				= sum(bugs_assigned_to_normal_count, na.rm = TRUE), 		
														  bugs_assigned_to_major_count 					= sum(bugs_assigned_to_major_count, na.rm = TRUE), 		
														  bugs_assigned_to_critical_count 				= sum(bugs_assigned_to_critical_count, na.rm = TRUE), 	
														  bugs_assigned_to_blocker_count 				= sum(bugs_assigned_to_blocker_count, na.rm = TRUE),
														  bugs_qa_contact_enhancement_count 			= sum(bugs_qa_contact_enhancement_count, na.rm = TRUE), 	
														  bugs_qa_contact_trivial_count 				= sum(bugs_qa_contact_trivial_count, na.rm = TRUE), 		
														  bugs_qa_contact_minor_count					= sum(bugs_qa_contact_minor_count, na.rm = TRUE), 		
														  bugs_qa_contact_normal_count 					= sum(bugs_qa_contact_normal_count, na.rm = TRUE), 		
														  bugs_qa_contact_major_count 					= sum(bugs_qa_contact_major_count, na.rm = TRUE), 		
														  bugs_qa_contact_critical_count 				= sum(bugs_qa_contact_critical_count, na.rm = TRUE), 	
														  bugs_qa_contact_blocker_count 				= sum(bugs_qa_contact_blocker_count, na.rm = TRUE),
														  bugs_assigned_to_reopened_count 				= sum(bugs_assigned_to_reopened_count, na.rm = TRUE),	
														  bugs_assigned_to_assigned_count				= sum(bugs_assigned_to_assigned_count, na.rm = TRUE), 	
														  bugs_assigned_to_reassigned_count				= sum(bugs_assigned_to_reassigned_count, na.rm = TRUE),
														  bugs_qa_contact_reopened_count 				= sum(bugs_qa_contact_reopened_count, na.rm = TRUE),
														  bugs_qa_contact_assigned_count 				= sum(bugs_qa_contact_assigned_count, na.rm = TRUE), 
														  bugs_qa_contact_reassigned_count 				= sum(bugs_qa_contact_reassigned_count, na.rm = TRUE),
														  activity_assigning_1998_count					= sum(activity_assigning_1998_count, na.rm = TRUE),
														  activity_assigning_1999_count					= sum(activity_assigning_1999_count, na.rm = TRUE),
														  activity_assigning_2000_count					= sum(activity_assigning_2000_count, na.rm = TRUE),
														  activity_assigning_2001_count					= sum(activity_assigning_2001_count, na.rm = TRUE),
														  activity_assigning_2002_count					= sum(activity_assigning_2002_count, na.rm = TRUE),
														  activity_assigning_2003_count					= sum(activity_assigning_2003_count, na.rm = TRUE),
														  activity_assigning_2004_count					= sum(activity_assigning_2004_count, na.rm = TRUE),
														  activity_assigning_2005_count					= sum(activity_assigning_2005_count, na.rm = TRUE),
														  activity_assigning_2006_count					= sum(activity_assigning_2006_count, na.rm = TRUE),
														  activity_assigning_2007_count					= sum(activity_assigning_2007_count, na.rm = TRUE),
														  activity_assigning_2008_count					= sum(activity_assigning_2008_count, na.rm = TRUE),
														  activity_assigning_2009_count					= sum(activity_assigning_2009_count, na.rm = TRUE),
														  activity_assigning_2010_count					= sum(activity_assigning_2010_count, na.rm = TRUE),
														  activity_assigning_2011_count					= sum(activity_assigning_2011_count, na.rm = TRUE),
														  activity_assigning_2012_count					= sum(activity_assigning_2012_count, na.rm = TRUE),
														  activity_assigning_2013_count					= sum(activity_assigning_2013_count, na.rm = TRUE),
														  activity_assigning_all_count					= sum(activity_assigning_all_count, na.rm = TRUE),
														  activity_reassigning_1998_count				= sum(activity_reassigning_1998_count, na.rm = TRUE),
														  activity_reassigning_1999_count				= sum(activity_reassigning_1999_count, na.rm = TRUE),
														  activity_reassigning_2000_count				= sum(activity_reassigning_2000_count, na.rm = TRUE),
														  activity_reassigning_2001_count				= sum(activity_reassigning_2001_count, na.rm = TRUE),
														  activity_reassigning_2002_count				= sum(activity_reassigning_2002_count, na.rm = TRUE),
														  activity_reassigning_2003_count				= sum(activity_reassigning_2003_count, na.rm = TRUE),
														  activity_reassigning_2004_count				= sum(activity_reassigning_2004_count, na.rm = TRUE),
														  activity_reassigning_2005_count				= sum(activity_reassigning_2005_count, na.rm = TRUE),
														  activity_reassigning_2006_count				= sum(activity_reassigning_2006_count, na.rm = TRUE),
														  activity_reassigning_2007_count				= sum(activity_reassigning_2007_count, na.rm = TRUE),
														  activity_reassigning_2008_count				= sum(activity_reassigning_2008_count, na.rm = TRUE),
														  activity_reassigning_2009_count				= sum(activity_reassigning_2009_count, na.rm = TRUE),
														  activity_reassigning_2010_count				= sum(activity_reassigning_2010_count, na.rm = TRUE),
														  activity_reassigning_2011_count				= sum(activity_reassigning_2011_count, na.rm = TRUE),
														  activity_reassigning_2012_count				= sum(activity_reassigning_2012_count, na.rm = TRUE),
														  activity_reassigning_2013_count				= sum(activity_reassigning_2013_count, na.rm = TRUE),
														  activity_reassigning_all_count				= sum(activity_reassigning_all_count, na.rm = TRUE),
														  activity_reopening_1998_count					= sum(activity_reopening_1998_count, na.rm = TRUE),
														  activity_reopening_1999_count					= sum(activity_reopening_1999_count, na.rm = TRUE),
														  activity_reopening_2000_count					= sum(activity_reopening_2000_count, na.rm = TRUE),
														  activity_reopening_2001_count					= sum(activity_reopening_2001_count, na.rm = TRUE),
														  activity_reopening_2002_count					= sum(activity_reopening_2002_count, na.rm = TRUE),
														  activity_reopening_2003_count					= sum(activity_reopening_2003_count, na.rm = TRUE),
														  activity_reopening_2004_count					= sum(activity_reopening_2004_count, na.rm = TRUE),
														  activity_reopening_2005_count					= sum(activity_reopening_2005_count, na.rm = TRUE),
														  activity_reopening_2006_count					= sum(activity_reopening_2006_count, na.rm = TRUE),
														  activity_reopening_2007_count					= sum(activity_reopening_2007_count, na.rm = TRUE),
														  activity_reopening_2008_count					= sum(activity_reopening_2008_count, na.rm = TRUE),
														  activity_reopening_2009_count					= sum(activity_reopening_2009_count, na.rm = TRUE),
														  activity_reopening_2010_count					= sum(activity_reopening_2010_count, na.rm = TRUE),
														  activity_reopening_2011_count					= sum(activity_reopening_2011_count, na.rm = TRUE),
														  activity_reopening_2012_count					= sum(activity_reopening_2012_count, na.rm = TRUE),
														  activity_reopening_2013_count					= sum(activity_reopening_2013_count, na.rm = TRUE),
														  activity_reopening_all_count					= sum(activity_reopening_all_count, na.rm = TRUE),
														  activity_cc_change_1998_count					= sum(activity_cc_change_1998_count, na.rm = TRUE),
														  activity_cc_change_1999_count               	= sum(activity_cc_change_1999_count, na.rm = TRUE),
														  activity_cc_change_2000_count					= sum(activity_cc_change_2000_count, na.rm = TRUE),
														  activity_cc_change_2001_count					= sum(activity_cc_change_2001_count, na.rm = TRUE),
														  activity_cc_change_2002_count					= sum(activity_cc_change_2002_count, na.rm = TRUE),
														  activity_cc_change_2003_count					= sum(activity_cc_change_2003_count, na.rm = TRUE),
														  activity_cc_change_2004_count					= sum(activity_cc_change_2004_count, na.rm = TRUE),
														  activity_cc_change_2005_count               	= sum(activity_cc_change_2005_count, na.rm = TRUE),
														  activity_cc_change_2006_count               	= sum(activity_cc_change_2006_count, na.rm = TRUE),
														  activity_cc_change_2007_count               	= sum(activity_cc_change_2007_count, na.rm = TRUE),
														  activity_cc_change_2008_count               	= sum(activity_cc_change_2008_count, na.rm = TRUE),
														  activity_cc_change_2009_count               	= sum(activity_cc_change_2009_count, na.rm = TRUE),
														  activity_cc_change_2010_count					= sum(activity_cc_change_2010_count, na.rm = TRUE),
														  activity_cc_change_2011_count               	= sum(activity_cc_change_2011_count, na.rm = TRUE),
														  activity_cc_change_2012_count               	= sum(activity_cc_change_2012_count, na.rm = TRUE),
														  activity_cc_change_2013_count               	= sum(activity_cc_change_2013_count, na.rm = TRUE),
														  activity_cc_change_all_count                	= sum(activity_cc_change_all_count, na.rm = TRUE),
														  activity_keywords_change_1998_count         	= sum(activity_keywords_change_1998_count, na.rm = TRUE),
														  activity_keywords_change_1999_count			= sum(activity_keywords_change_1999_count, na.rm = TRUE),
														  activity_keywords_change_2000_count         	= sum(activity_keywords_change_2000_count, na.rm = TRUE),
														  activity_keywords_change_2001_count         	= sum(activity_keywords_change_2001_count, na.rm = TRUE),
														  activity_keywords_change_2002_count         	= sum(activity_keywords_change_2002_count, na.rm = TRUE),
														  activity_keywords_change_2003_count         	= sum(activity_keywords_change_2003_count, na.rm = TRUE),
														  activity_keywords_change_2004_count         	= sum(activity_keywords_change_2004_count, na.rm = TRUE),
														  activity_keywords_change_2005_count			= sum(activity_keywords_change_2005_count, na.rm = TRUE),
														  activity_keywords_change_2006_count         	= sum(activity_keywords_change_2006_count, na.rm = TRUE),
														  activity_keywords_change_2007_count         	= sum(activity_keywords_change_2007_count, na.rm = TRUE),
														  activity_keywords_change_2008_count         	= sum(activity_keywords_change_2008_count, na.rm = TRUE),
														  activity_keywords_change_2009_count         	= sum(activity_keywords_change_2009_count, na.rm = TRUE),
														  activity_keywords_change_2010_count         	= sum(activity_keywords_change_2010_count, na.rm = TRUE),
														  activity_keywords_change_2011_count         	= sum(activity_keywords_change_2011_count, na.rm = TRUE),
														  activity_keywords_change_2012_count         	= sum(activity_keywords_change_2012_count, na.rm = TRUE),
														  activity_keywords_change_2013_count         	= sum(activity_keywords_change_2013_count, na.rm = TRUE),
														  activity_keywords_change_all_count          	= sum(activity_keywords_change_all_count, na.rm = TRUE),
														  activity_product_change_1998_count          	= sum(activity_product_change_1998_count, na.rm = TRUE),
														  activity_product_change_1999_count          	= sum(activity_product_change_1999_count, na.rm = TRUE),
														  activity_product_change_2000_count          	= sum(activity_product_change_2000_count, na.rm = TRUE),
														  activity_product_change_2001_count          	= sum(activity_product_change_2001_count, na.rm = TRUE),
														  activity_product_change_2002_count          	= sum(activity_product_change_2002_count, na.rm = TRUE),
														  activity_product_change_2003_count          	= sum(activity_product_change_2003_count, na.rm = TRUE),
														  activity_product_change_2004_count          	= sum(activity_product_change_2004_count, na.rm = TRUE),
														  activity_product_change_2005_count          	= sum(activity_product_change_2005_count, na.rm = TRUE),
														  activity_product_change_2006_count          	= sum(activity_product_change_2006_count, na.rm = TRUE),
														  activity_product_change_2007_count          	= sum(activity_product_change_2007_count, na.rm = TRUE),
														  activity_product_change_2008_count          	= sum(activity_product_change_2008_count, na.rm = TRUE),
														  activity_product_change_2009_count          	= sum(activity_product_change_2009_count, na.rm = TRUE),
														  activity_product_change_2010_count          	= sum(activity_product_change_2010_count, na.rm = TRUE),
														  activity_product_change_2011_count          	= sum(activity_product_change_2011_count, na.rm = TRUE),
														  activity_product_change_2012_count			= sum(activity_product_change_2012_count, na.rm = TRUE),
														  activity_product_change_2013_count          	= sum(activity_product_change_2013_count, na.rm = TRUE),
														  activity_product_change_all_count           	= sum(activity_product_change_all_count, na.rm = TRUE),
														  activity_component_change_1998_count        	= sum(activity_component_change_1998_count, na.rm = TRUE),
														  activity_component_change_1999_count        	= sum(activity_component_change_1999_count, na.rm = TRUE),
														  activity_component_change_2000_count        	= sum(activity_component_change_2000_count, na.rm = TRUE),
														  activity_component_change_2001_count        	= sum(activity_component_change_2001_count, na.rm = TRUE),
														  activity_component_change_2002_count        	= sum(activity_component_change_2002_count, na.rm = TRUE),
														  activity_component_change_2003_count        	= sum(activity_component_change_2003_count, na.rm = TRUE),
														  activity_component_change_2004_count        	= sum(activity_component_change_2004_count, na.rm = TRUE),
														  activity_component_change_2005_count        	= sum(activity_component_change_2005_count, na.rm = TRUE),
														  activity_component_change_2006_count        	= sum(activity_component_change_2006_count, na.rm = TRUE),
														  activity_component_change_2007_count        	= sum(activity_component_change_2007_count, na.rm = TRUE),
														  activity_component_change_2008_count        	= sum(activity_component_change_2008_count, na.rm = TRUE),
														  activity_component_change_2009_count        	= sum(activity_component_change_2009_count, na.rm = TRUE),
														  activity_component_change_2010_count        	= sum(activity_component_change_2010_count, na.rm = TRUE),
														  activity_component_change_2011_count        	= sum(activity_component_change_2011_count, na.rm = TRUE),
														  activity_component_change_2012_count        	= sum(activity_component_change_2012_count, na.rm = TRUE),
														  activity_component_change_2013_count        	= sum(activity_component_change_2013_count, na.rm = TRUE),
														  activity_component_change_all_count         	= sum(activity_component_change_all_count, na.rm = TRUE),
														  activity_status_change_1998_count           	= sum(activity_status_change_1998_count, na.rm = TRUE),
														  activity_status_change_1999_count           	= sum(activity_status_change_1999_count, na.rm = TRUE),
														  activity_status_change_2000_count           	= sum(activity_status_change_2000_count, na.rm = TRUE),
														  activity_status_change_2001_count           	= sum(activity_status_change_2001_count, na.rm = TRUE),
														  activity_status_change_2002_count				= sum(activity_status_change_2002_count, na.rm = TRUE),
														  activity_status_change_2003_count           	= sum(activity_status_change_2003_count, na.rm = TRUE),
														  activity_status_change_2004_count           	= sum(activity_status_change_2004_count, na.rm = TRUE),
														  activity_status_change_2005_count           	= sum(activity_status_change_2005_count, na.rm = TRUE),
														  activity_status_change_2006_count           	= sum(activity_status_change_2006_count, na.rm = TRUE),
														  activity_status_change_2007_count           	= sum(activity_status_change_2007_count, na.rm = TRUE),
														  activity_status_change_2008_count           	= sum(activity_status_change_2008_count, na.rm = TRUE),
														  activity_status_change_2009_count           	= sum(activity_status_change_2009_count, na.rm = TRUE),
														  activity_status_change_2010_count           	= sum(activity_status_change_2010_count, na.rm = TRUE),
														  activity_status_change_2011_count           	= sum(activity_status_change_2011_count, na.rm = TRUE),
														  activity_status_change_2012_count           	= sum(activity_status_change_2012_count, na.rm = TRUE),
														  activity_status_change_2013_count           	= sum(activity_status_change_2013_count, na.rm = TRUE),
														  activity_status_change_all_count            	= sum(activity_status_change_all_count, na.rm = TRUE),
														  activity_resolution_change_1998_count       	= sum(activity_resolution_change_1998_count, na.rm = TRUE),
														  activity_resolution_change_1999_count       	= sum(activity_resolution_change_1999_count, na.rm = TRUE),
														  activity_resolution_change_2000_count       	= sum(activity_resolution_change_2000_count, na.rm = TRUE),
														  activity_resolution_change_2001_count       	= sum(activity_resolution_change_2001_count, na.rm = TRUE),
														  activity_resolution_change_2002_count       	= sum(activity_resolution_change_2002_count, na.rm = TRUE),
														  activity_resolution_change_2003_count       	= sum(activity_resolution_change_2003_count, na.rm = TRUE),
														  activity_resolution_change_2004_count       	= sum(activity_resolution_change_2004_count, na.rm = TRUE),
														  activity_resolution_change_2005_count       	= sum(activity_resolution_change_2005_count, na.rm = TRUE),
														  activity_resolution_change_2006_count       	= sum(activity_resolution_change_2006_count, na.rm = TRUE),
														  activity_resolution_change_2007_count       	= sum(activity_resolution_change_2007_count, na.rm = TRUE),
														  activity_resolution_change_2008_count       	= sum(activity_resolution_change_2008_count, na.rm = TRUE),
														  activity_resolution_change_2009_count			= sum(activity_resolution_change_2009_count, na.rm = TRUE),
														  activity_resolution_change_2010_count       	= sum(activity_resolution_change_2010_count, na.rm = TRUE),
														  activity_resolution_change_2011_count       	= sum(activity_resolution_change_2011_count, na.rm = TRUE),
														  activity_resolution_change_2012_count       	= sum(activity_resolution_change_2012_count, na.rm = TRUE),
														  activity_resolution_change_2013_count       	= sum(activity_resolution_change_2013_count, na.rm = TRUE),
														  activity_resolution_change_all_count        	= sum(activity_resolution_change_all_count, na.rm = TRUE),
														  activity_flags_change_1998_count            	= sum(activity_flags_change_1998_count, na.rm = TRUE),
														  activity_flags_change_1999_count            	= sum(activity_flags_change_1999_count, na.rm = TRUE),
														  activity_flags_change_2000_count            	= sum(activity_flags_change_2000_count, na.rm = TRUE),
														  activity_flags_change_2001_count            	= sum(activity_flags_change_2001_count, na.rm = TRUE),
														  activity_flags_change_2002_count            	= sum(activity_flags_change_2002_count, na.rm = TRUE),
														  activity_flags_change_2003_count            	= sum(activity_flags_change_2003_count, na.rm = TRUE),
														  activity_flags_change_2004_count            	= sum(activity_flags_change_2004_count, na.rm = TRUE),
														  activity_flags_change_2005_count            	= sum(activity_flags_change_2005_count, na.rm = TRUE),
														  activity_flags_change_2006_count            	= sum(activity_flags_change_2006_count, na.rm = TRUE),
														  activity_flags_change_2007_count            	= sum(activity_flags_change_2007_count, na.rm = TRUE),
														  activity_flags_change_2008_count            	= sum(activity_flags_change_2008_count, na.rm = TRUE),
														  activity_flags_change_2009_count            	= sum(activity_flags_change_2009_count, na.rm = TRUE),
														  activity_flags_change_2010_count            	= sum(activity_flags_change_2010_count, na.rm = TRUE),
														  activity_flags_change_2011_count            	= sum(activity_flags_change_2011_count, na.rm = TRUE),
														  activity_flags_change_2012_count            	= sum(activity_flags_change_2012_count, na.rm = TRUE),
														  activity_flags_change_2013_count            	= sum(activity_flags_change_2013_count, na.rm = TRUE),
														  activity_flags_change_all_count             	= sum(activity_flags_change_all_count, na.rm = TRUE),
														  activity_whiteboard_change_1998_count       	= sum(activity_whiteboard_change_1998_count, na.rm = TRUE),
														  activity_whiteboard_change_1999_count			= sum(activity_whiteboard_change_1999_count, na.rm = TRUE),
														  activity_whiteboard_change_2000_count       	= sum(activity_whiteboard_change_2000_count, na.rm = TRUE),
														  activity_whiteboard_change_2001_count       	= sum(activity_whiteboard_change_2001_count, na.rm = TRUE),
														  activity_whiteboard_change_2002_count       	= sum(activity_whiteboard_change_2002_count, na.rm = TRUE),
														  activity_whiteboard_change_2003_count       	= sum(activity_whiteboard_change_2003_count, na.rm = TRUE),
														  activity_whiteboard_change_2004_count       	= sum(activity_whiteboard_change_2004_count, na.rm = TRUE),
														  activity_whiteboard_change_2005_count       	= sum(activity_whiteboard_change_2005_count, na.rm = TRUE),
														  activity_whiteboard_change_2006_count       	= sum(activity_whiteboard_change_2006_count, na.rm = TRUE),
														  activity_whiteboard_change_2007_count       	= sum(activity_whiteboard_change_2007_count, na.rm = TRUE),
														  activity_whiteboard_change_2008_count       	= sum(activity_whiteboard_change_2008_count, na.rm = TRUE),
														  activity_whiteboard_change_2009_count       	= sum(activity_whiteboard_change_2009_count, na.rm = TRUE),
														  activity_whiteboard_change_2010_count       	= sum(activity_whiteboard_change_2010_count, na.rm = TRUE),
														  activity_whiteboard_change_2011_count       	= sum(activity_whiteboard_change_2011_count, na.rm = TRUE),
														  activity_whiteboard_change_2012_count       	= sum(activity_whiteboard_change_2012_count, na.rm = TRUE),
														  activity_whiteboard_change_2013_count       	= sum(activity_whiteboard_change_2013_count, na.rm = TRUE),
														  activity_whiteboard_change_all_count        	= sum(activity_whiteboard_change_all_count, na.rm = TRUE),
														  activity_target_milestone_change_1998_count 	= sum(activity_target_milestone_change_1998_count, na.rm = TRUE),
														  activity_target_milestone_change_1999_count 	= sum(activity_target_milestone_change_1999_count, na.rm = TRUE),
														  activity_target_milestone_change_2000_count 	= sum(activity_target_milestone_change_2000_count, na.rm = TRUE),
														  activity_target_milestone_change_2001_count 	= sum(activity_target_milestone_change_2001_count, na.rm = TRUE),
														  activity_target_milestone_change_2002_count 	= sum(activity_target_milestone_change_2002_count, na.rm = TRUE),
														  activity_target_milestone_change_2003_count 	= sum(activity_target_milestone_change_2003_count, na.rm = TRUE),
														  activity_target_milestone_change_2004_count 	= sum(activity_target_milestone_change_2004_count, na.rm = TRUE),
														  activity_target_milestone_change_2005_count 	= sum(activity_target_milestone_change_2005_count, na.rm = TRUE),
														  activity_target_milestone_change_2006_count	= sum(activity_target_milestone_change_2006_count, na.rm = TRUE),
														  activity_target_milestone_change_2007_count 	= sum(activity_target_milestone_change_2007_count, na.rm = TRUE),
														  activity_target_milestone_change_2008_count 	= sum(activity_target_milestone_change_2008_count, na.rm = TRUE),
														  activity_target_milestone_change_2009_count 	= sum(activity_target_milestone_change_2009_count, na.rm = TRUE),
														  activity_target_milestone_change_2010_count 	= sum(activity_target_milestone_change_2010_count, na.rm = TRUE),
														  activity_target_milestone_change_2011_count 	= sum(activity_target_milestone_change_2011_count, na.rm = TRUE),
														  activity_target_milestone_change_2012_count 	= sum(activity_target_milestone_change_2012_count, na.rm = TRUE),
														  activity_target_milestone_change_2013_count 	= sum(activity_target_milestone_change_2013_count, na.rm = TRUE),
														  activity_target_milestone_change_all_count  	= sum(activity_target_milestone_change_all_count, na.rm = TRUE),
														  activity_description_change_1998_count      	= sum(activity_description_change_1998_count, na.rm = TRUE),
														  activity_description_change_1999_count      	= sum(activity_description_change_1999_count, na.rm = TRUE),
														  activity_description_change_2000_count      	= sum(activity_description_change_2000_count, na.rm = TRUE),
														  activity_description_change_2001_count      	= sum(activity_description_change_2001_count, na.rm = TRUE),
														  activity_description_change_2002_count      	= sum(activity_description_change_2002_count, na.rm = TRUE),
														  activity_description_change_2003_count      	= sum(activity_description_change_2003_count, na.rm = TRUE),
														  activity_description_change_2004_count      	= sum(activity_description_change_2004_count, na.rm = TRUE),
														  activity_description_change_2005_count      	= sum(activity_description_change_2005_count, na.rm = TRUE),
														  activity_description_change_2006_count      	= sum(activity_description_change_2006_count, na.rm = TRUE),
														  activity_description_change_2007_count      	= sum(activity_description_change_2007_count, na.rm = TRUE),
														  activity_description_change_2008_count      	= sum(activity_description_change_2008_count, na.rm = TRUE),
														  activity_description_change_2009_count      	= sum(activity_description_change_2009_count, na.rm = TRUE),
														  activity_description_change_2010_count      	= sum(activity_description_change_2010_count, na.rm = TRUE),
														  activity_description_change_2011_count      	= sum(activity_description_change_2011_count, na.rm = TRUE),
														  activity_description_change_2012_count      	= sum(activity_description_change_2012_count, na.rm = TRUE),
														  activity_description_change_2013_count		= sum(activity_description_change_2013_count, na.rm = TRUE),
														  activity_description_change_all_count       	= sum(activity_description_change_all_count, na.rm = TRUE),
														  activity_priority_change_1998_count         	= sum(activity_priority_change_1998_count, na.rm = TRUE),
														  activity_priority_change_1999_count         	= sum(activity_priority_change_1999_count, na.rm = TRUE),
														  activity_priority_change_2000_count         	= sum(activity_priority_change_2000_count, na.rm = TRUE),
														  activity_priority_change_2001_count         	= sum(activity_priority_change_2001_count, na.rm = TRUE),
														  activity_priority_change_2002_count         	= sum(activity_priority_change_2002_count, na.rm = TRUE),
														  activity_priority_change_2003_count         	= sum(activity_priority_change_2003_count, na.rm = TRUE),
														  activity_priority_change_2004_count         	= sum(activity_priority_change_2004_count, na.rm = TRUE),
														  activity_priority_change_2005_count         	= sum(activity_priority_change_2005_count, na.rm = TRUE),
														  activity_priority_change_2006_count         	= sum(activity_priority_change_2006_count, na.rm = TRUE),
														  activity_priority_change_2007_count         	= sum(activity_priority_change_2007_count, na.rm = TRUE),
														  activity_priority_change_2008_count         	= sum(activity_priority_change_2008_count, na.rm = TRUE),
														  activity_priority_change_2009_count         	= sum(activity_priority_change_2009_count, na.rm = TRUE),
														  activity_priority_change_2010_count         	= sum(activity_priority_change_2010_count, na.rm = TRUE),
														  activity_priority_change_2011_count         	= sum(activity_priority_change_2011_count, na.rm = TRUE),
														  activity_priority_change_2012_count         	= sum(activity_priority_change_2012_count, na.rm = TRUE),
														  activity_priority_change_2013_count         	= sum(activity_priority_change_2013_count, na.rm = TRUE),
														  activity_priority_change_all_count          	= sum(activity_priority_change_all_count, na.rm = TRUE),
														  activity_severity_change_1998_count         	= sum(activity_severity_change_1998_count, na.rm = TRUE),
														  activity_severity_change_1999_count         	= sum(activity_severity_change_1999_count, na.rm = TRUE),
														  activity_severity_change_2000_count         	= sum(activity_severity_change_2000_count, na.rm = TRUE),
														  activity_severity_change_2001_count         	= sum(activity_severity_change_2001_count, na.rm = TRUE),
														  activity_severity_change_2002_count         	= sum(activity_severity_change_2002_count, na.rm = TRUE),
														  activity_severity_change_2003_count			= sum(activity_severity_change_2003_count, na.rm = TRUE),
														  activity_severity_change_2004_count         	= sum(activity_severity_change_2004_count, na.rm = TRUE),
														  activity_severity_change_2005_count         	= sum(activity_severity_change_2005_count, na.rm = TRUE),
														  activity_severity_change_2006_count         	= sum(activity_severity_change_2006_count, na.rm = TRUE),
														  activity_severity_change_2007_count         	= sum(activity_severity_change_2007_count, na.rm = TRUE),
														  activity_severity_change_2008_count         	= sum(activity_severity_change_2008_count, na.rm = TRUE),
														  activity_severity_change_2009_count         	= sum(activity_severity_change_2009_count, na.rm = TRUE),
														  activity_severity_change_2010_count         	= sum(activity_severity_change_2010_count, na.rm = TRUE),
														  activity_severity_change_2011_count         	= sum(activity_severity_change_2011_count, na.rm = TRUE),
														  activity_severity_change_2012_count         	= sum(activity_severity_change_2012_count, na.rm = TRUE),
														  activity_severity_change_2013_count         	= sum(activity_severity_change_2013_count, na.rm = TRUE),
														  activity_severity_change_all_count          	= sum(activity_severity_change_all_count, na.rm = TRUE),
														  attachments_all_types_count					= sum(attachments_all_types_count, na.rm = TRUE),
														  attachments_patch_count						= sum(attachments_patch_count, na.rm = TRUE),
														  attachments_application_count					= sum(attachments_application_count, na.rm = TRUE),
														  attachments_audio_count						= sum(attachments_audio_count, na.rm = TRUE),
														  attachments_image_count						= sum(attachments_image_count, na.rm = TRUE),
														  attachments_message_count						= sum(attachments_message_count, na.rm = TRUE),
														  attachments_model_count						= sum(attachments_model_count, na.rm = TRUE),
														  attachments_multipart_count					= sum(attachments_multipart_count, na.rm = TRUE),
														  attachments_text_count						= sum(attachments_text_count, na.rm = TRUE),
														  attachments_video_count						= sum(attachments_video_count, na.rm = TRUE),
														  attachments_unknown_count						= sum(attachments_unknown_count, na.rm = TRUE),
														  attachments_all_types_1998_count 				= sum(attachments_all_types_1998_count, na.rm = TRUE),
														  attachments_all_types_1999_count 				= sum(attachments_all_types_1999_count, na.rm = TRUE),
														  attachments_all_types_2000_count 				= sum(attachments_all_types_2000_count, na.rm = TRUE),
														  attachments_all_types_2001_count 				= sum(attachments_all_types_2001_count, na.rm = TRUE),
														  attachments_all_types_2002_count 				= sum(attachments_all_types_2002_count, na.rm = TRUE),
														  attachments_all_types_2003_count 				= sum(attachments_all_types_2003_count, na.rm = TRUE),
														  attachments_all_types_2004_count 				= sum(attachments_all_types_2004_count, na.rm = TRUE),
														  attachments_all_types_2005_count 				= sum(attachments_all_types_2005_count, na.rm = TRUE),
														  attachments_all_types_2006_count 				= sum(attachments_all_types_2006_count, na.rm = TRUE),
														  attachments_all_types_2007_count 				= sum(attachments_all_types_2007_count, na.rm = TRUE),
														  attachments_all_types_2008_count 				= sum(attachments_all_types_2008_count, na.rm = TRUE),
														  attachments_all_types_2009_count 				= sum(attachments_all_types_2009_count, na.rm = TRUE),
														  attachments_all_types_2010_count 				= sum(attachments_all_types_2010_count, na.rm = TRUE),
														  attachments_all_types_2011_count 				= sum(attachments_all_types_2011_count, na.rm = TRUE),
														  attachments_all_types_2012_count 				= sum(attachments_all_types_2012_count, na.rm = TRUE),
														  attachments_all_types_2013_count 				= sum(attachments_all_types_2013_count, na.rm = TRUE),
														  attachments_patches_1998_count 				= sum(attachments_patches_1998_count, na.rm = TRUE),
														  attachments_patches_1999_count 				= sum(attachments_patches_1999_count, na.rm = TRUE),
														  attachments_patches_2000_count 				= sum(attachments_patches_2000_count, na.rm = TRUE),
														  attachments_patches_2001_count 				= sum(attachments_patches_2001_count, na.rm = TRUE),
														  attachments_patches_2002_count 				= sum(attachments_patches_2002_count, na.rm = TRUE),
														  attachments_patches_2003_count 				= sum(attachments_patches_2003_count, na.rm = TRUE),
														  attachments_patches_2004_count 				= sum(attachments_patches_2004_count, na.rm = TRUE),
														  attachments_patches_2005_count 				= sum(attachments_patches_2005_count, na.rm = TRUE),
														  attachments_patches_2006_count 				= sum(attachments_patches_2006_count, na.rm = TRUE),
														  attachments_patches_2007_count 				= sum(attachments_patches_2007_count, na.rm = TRUE),
														  attachments_patches_2008_count 				= sum(attachments_patches_2008_count, na.rm = TRUE),
														  attachments_patches_2009_count 				= sum(attachments_patches_2009_count, na.rm = TRUE),
														  attachments_patches_2010_count 				= sum(attachments_patches_2010_count, na.rm = TRUE),
														  attachments_patches_2011_count 				= sum(attachments_patches_2011_count, na.rm = TRUE),
														  attachments_patches_2012_count 				= sum(attachments_patches_2012_count, na.rm = TRUE),
														  attachments_patches_2013_count 				= sum(attachments_patches_2013_count, na.rm = TRUE),
														  knowledge_actors_count						= sum(knowledge_actor, na.rm = TRUE),
														  core_actors_count								= sum(core_actor, na.rm = TRUE),
														  peripheral_actors_count						= sum(peripheral_actor, na.rm = TRUE),
														  bugs_reported_1994_count 						= sum(bugs_reported_1994_count, na.rm = TRUE),
														  bugs_reported_1995_count 						= sum(bugs_reported_1995_count, na.rm = TRUE),
														  bugs_reported_1996_count 						= sum(bugs_reported_1996_count, na.rm = TRUE),
														  bugs_reported_1997_count 						= sum(bugs_reported_1997_count, na.rm = TRUE),
														  bugs_reported_1998_count 						= sum(bugs_reported_1998_count, na.rm = TRUE),
														  bugs_reported_1999_count 						= sum(bugs_reported_1999_count, na.rm = TRUE),
														  bugs_reported_2000_count 						= sum(bugs_reported_2000_count, na.rm = TRUE),
														  bugs_reported_2001_count 						= sum(bugs_reported_2001_count, na.rm = TRUE),
														  bugs_reported_2002_count 						= sum(bugs_reported_2002_count, na.rm = TRUE),
														  bugs_reported_2003_count 						= sum(bugs_reported_2003_count, na.rm = TRUE),
														  bugs_reported_2004_count 						= sum(bugs_reported_2004_count, na.rm = TRUE),
														  bugs_reported_2005_count 						= sum(bugs_reported_2005_count, na.rm = TRUE),
														  bugs_reported_2006_count 						= sum(bugs_reported_2006_count, na.rm = TRUE),
														  bugs_reported_2007_count 						= sum(bugs_reported_2007_count, na.rm = TRUE),
														  bugs_reported_2008_count 						= sum(bugs_reported_2008_count, na.rm = TRUE),
														  bugs_reported_2009_count 						= sum(bugs_reported_2009_count, na.rm = TRUE),
														  bugs_reported_2010_count 						= sum(bugs_reported_2010_count, na.rm = TRUE),
														  bugs_reported_2011_count 						= sum(bugs_reported_2011_count, na.rm = TRUE),
														  bugs_reported_2012_count 						= sum(bugs_reported_2012_count, na.rm = TRUE),
														  bugs_reported_2013_count 						= sum(bugs_reported_2013_count, na.rm = TRUE),
														  bugs_assigned_to_1994_count 					= sum(bugs_assigned_to_1994_count, na.rm = TRUE),
														  bugs_assigned_to_1995_count 					= sum(bugs_assigned_to_1995_count, na.rm = TRUE),
														  bugs_assigned_to_1996_count 					= sum(bugs_assigned_to_1996_count, na.rm = TRUE),
														  bugs_assigned_to_1997_count 					= sum(bugs_assigned_to_1997_count, na.rm = TRUE),
														  bugs_assigned_to_1998_count 					= sum(bugs_assigned_to_1998_count, na.rm = TRUE),
														  bugs_assigned_to_1999_count 					= sum(bugs_assigned_to_1999_count, na.rm = TRUE),
														  bugs_assigned_to_2000_count 					= sum(bugs_assigned_to_2000_count, na.rm = TRUE),
														  bugs_assigned_to_2001_count 					= sum(bugs_assigned_to_2001_count, na.rm = TRUE),
														  bugs_assigned_to_2002_count 					= sum(bugs_assigned_to_2002_count, na.rm = TRUE),
														  bugs_assigned_to_2003_count 					= sum(bugs_assigned_to_2003_count, na.rm = TRUE),
														  bugs_assigned_to_2004_count 					= sum(bugs_assigned_to_2004_count, na.rm = TRUE),
														  bugs_assigned_to_2005_count 					= sum(bugs_assigned_to_2005_count, na.rm = TRUE),
														  bugs_assigned_to_2006_count 					= sum(bugs_assigned_to_2006_count, na.rm = TRUE),
														  bugs_assigned_to_2007_count 					= sum(bugs_assigned_to_2007_count, na.rm = TRUE),
														  bugs_assigned_to_2008_count 					= sum(bugs_assigned_to_2008_count, na.rm = TRUE),
														  bugs_assigned_to_2009_count 					= sum(bugs_assigned_to_2009_count, na.rm = TRUE),
														  bugs_assigned_to_2010_count 					= sum(bugs_assigned_to_2010_count, na.rm = TRUE),
														  bugs_assigned_to_2011_count 					= sum(bugs_assigned_to_2011_count, na.rm = TRUE),
														  bugs_assigned_to_2012_count 					= sum(bugs_assigned_to_2012_count, na.rm = TRUE),
														  bugs_assigned_to_2013_count 					= sum(bugs_assigned_to_2013_count, na.rm = TRUE),
														  bugs_qa_contact_1994_count 					= sum(bugs_qa_contact_1994_count, na.rm = TRUE),
														  bugs_qa_contact_1995_count 					= sum(bugs_qa_contact_1995_count, na.rm = TRUE),
														  bugs_qa_contact_1996_count 					= sum(bugs_qa_contact_1996_count, na.rm = TRUE),
														  bugs_qa_contact_1997_count 					= sum(bugs_qa_contact_1997_count, na.rm = TRUE),
														  bugs_qa_contact_1998_count 					= sum(bugs_qa_contact_1998_count, na.rm = TRUE),
														  bugs_qa_contact_1999_count 					= sum(bugs_qa_contact_1999_count, na.rm = TRUE),
														  bugs_qa_contact_2000_count 					= sum(bugs_qa_contact_2000_count, na.rm = TRUE),
														  bugs_qa_contact_2001_count 					= sum(bugs_qa_contact_2001_count, na.rm = TRUE),
														  bugs_qa_contact_2002_count 					= sum(bugs_qa_contact_2002_count, na.rm = TRUE),
														  bugs_qa_contact_2003_count 					= sum(bugs_qa_contact_2003_count, na.rm = TRUE),
														  bugs_qa_contact_2004_count 					= sum(bugs_qa_contact_2004_count, na.rm = TRUE),
														  bugs_qa_contact_2005_count 					= sum(bugs_qa_contact_2005_count, na.rm = TRUE),
														  bugs_qa_contact_2006_count 					= sum(bugs_qa_contact_2006_count, na.rm = TRUE),
														  bugs_qa_contact_2007_count 					= sum(bugs_qa_contact_2007_count, na.rm = TRUE),
														  bugs_qa_contact_2008_count 					= sum(bugs_qa_contact_2008_count, na.rm = TRUE),
														  bugs_qa_contact_2009_count 					= sum(bugs_qa_contact_2009_count, na.rm = TRUE),
														  bugs_qa_contact_2010_count 					= sum(bugs_qa_contact_2010_count, na.rm = TRUE),
														  bugs_qa_contact_2011_count 					= sum(bugs_qa_contact_2011_count, na.rm = TRUE),
														  bugs_qa_contact_2012_count 					= sum(bugs_qa_contact_2012_count, na.rm = TRUE),
														  bugs_qa_contact_2013_count 					= sum(bugs_qa_contact_2013_count, na.rm = TRUE),
														  comments_all_bugs_1995_count 					= sum(comments_all_bugs_1995_count, na.rm = TRUE),
														  comments_all_bugs_1996_count 					= sum(comments_all_bugs_1996_count, na.rm = TRUE),
														  comments_all_bugs_1997_count 					= sum(comments_all_bugs_1997_count, na.rm = TRUE),
														  comments_all_bugs_1998_count 					= sum(comments_all_bugs_1998_count, na.rm = TRUE),
														  comments_all_bugs_1999_count 					= sum(comments_all_bugs_1999_count, na.rm = TRUE),
														  comments_all_bugs_2000_count 					= sum(comments_all_bugs_2000_count, na.rm = TRUE),
														  comments_all_bugs_2001_count 					= sum(comments_all_bugs_2001_count, na.rm = TRUE),
														  comments_all_bugs_2002_count 					= sum(comments_all_bugs_2002_count, na.rm = TRUE),
														  comments_all_bugs_2003_count 					= sum(comments_all_bugs_2003_count, na.rm = TRUE),
														  comments_all_bugs_2004_count 					= sum(comments_all_bugs_2004_count, na.rm = TRUE),
														  comments_all_bugs_2005_count 					= sum(comments_all_bugs_2005_count, na.rm = TRUE),
														  comments_all_bugs_2006_count 					= sum(comments_all_bugs_2006_count, na.rm = TRUE),
														  comments_all_bugs_2007_count 					= sum(comments_all_bugs_2007_count, na.rm = TRUE),
														  comments_all_bugs_2008_count 					= sum(comments_all_bugs_2008_count, na.rm = TRUE),
														  comments_all_bugs_2009_count 					= sum(comments_all_bugs_2009_count, na.rm = TRUE),
														  comments_all_bugs_2010_count 					= sum(comments_all_bugs_2010_count, na.rm = TRUE),
														  comments_all_bugs_2011_count 					= sum(comments_all_bugs_2011_count, na.rm = TRUE),
														  comments_all_bugs_2012_count 					= sum(comments_all_bugs_2012_count, na.rm = TRUE),
														  comments_all_bugs_2013_count 					= sum(comments_all_bugs_2013_count, na.rm = TRUE),
														  comments_all_bugs_all_count  					= sum(comments_all_bugs_all_count, na.rm = TRUE),
														  comments_bugs_enhancement_count 				= sum(comments_bugs_enhancement_count, na.rm = TRUE),
														  comments_bugs_trivial_count					= sum(comments_bugs_trivial_count, na.rm = TRUE),
														  comments_bugs_minor_count						= sum(comments_bugs_minor_count, na.rm = TRUE),	
														  comments_bugs_normal_count					= sum(comments_bugs_normal_count, na.rm = TRUE),	
														  comments_bugs_major_count						= sum(comments_bugs_major_count, na.rm = TRUE),
														  comments_bugs_critical_count					= sum(comments_bugs_critical_count, na.rm = TRUE),	
														  comments_bugs_blocker_count					= sum(comments_bugs_blocker_count, na.rm = TRUE),
														  votes_bugs_enhancement_count 					= sum(votes_bugs_enhancement_count, na.rm = TRUE),
														  votes_bugs_trivial_count						= sum(votes_bugs_trivial_count, na.rm = TRUE),
														  votes_bugs_minor_count						= sum(votes_bugs_minor_count, na.rm = TRUE),
														  votes_bugs_normal_count						= sum(votes_bugs_normal_count, na.rm = TRUE),
														  votes_bugs_major_count						= sum(votes_bugs_major_count, na.rm = TRUE),
														  votes_bugs_critical_count						= sum(votes_bugs_critical_count, na.rm = TRUE),
														  votes_bugs_blocker_count						= sum(votes_bugs_blocker_count, na.rm = TRUE),
														  votes_all_bugs_count							= sum(votes_all_bugs_count, na.rm = TRUE),
														  cc_bugs_enhancement_count 					= sum(cc_bugs_enhancement_count, na.rm = TRUE),
														  cc_bugs_trivial_count							= sum(cc_bugs_trivial_count, na.rm = TRUE),	
														  cc_bugs_minor_count							= sum(cc_bugs_minor_count, na.rm = TRUE), 		
														  cc_bugs_normal_count							= sum(cc_bugs_normal_count, na.rm = TRUE),		
														  cc_bugs_major_count							= sum(cc_bugs_major_count, na.rm = TRUE),		
														  cc_bugs_critical_count						= sum(cc_bugs_critical_count, na.rm = TRUE),	
														  cc_bugs_blocker_count							= sum(cc_bugs_blocker_count, na.rm = TRUE),	
														  cc_all_bugs_count								= sum(cc_all_bugs_count, na.rm = TRUE),
														  bugs_reported_fixed_count						= sum(bugs_reported_fixed_count, na.rm = TRUE),	
														  bugs_reported_not_fixed_count					= sum(bugs_reported_not_fixed_count, na.rm = TRUE),
														  bugs_reported_pending_count					= sum(bugs_reported_pending_count, na.rm = TRUE),  
														  bugs_assigned_to_fixed_count					= sum(bugs_assigned_to_fixed_count, na.rm = TRUE),		
														  bugs_assigned_to_not_fixed_count				= sum(bugs_assigned_to_not_fixed_count, na.rm = TRUE),
														  bugs_assigned_to_pending_count				= sum(bugs_assigned_to_pending_count, na.rm = TRUE),
														  bugs_qa_contact_fixed_count					= sum(bugs_qa_contact_fixed_count, na.rm = TRUE),		
														  bugs_qa_contact_not_fixed_count				= sum(bugs_qa_contact_not_fixed_count, na.rm = TRUE),	
														  bugs_qa_contact_pending_count					= sum(bugs_qa_contact_pending_count, na.rm = TRUE));
 																					
# Somehow, the domain gets set as an integer, not a character string, so fix it:
profiles_working_grouped_domain_sums_summary$domain <- as.factor(as.character(profiles_working_grouped_domain_sums_summary$domain));
																						

# Create the new org table with "domain" as key, & original_domain and is_org_domain columns
orgs_working <- select(distinct(profiles_working, domain), domain, original_domain, is_org_domain);


# Merge	profiles_working_grouped_domain_sums_summary and orgs_working tables based on domain to add the aggregate columns
setkey(profiles_working_grouped_domain_sums_summary, domain);
setkey(orgs_working, domain);
orgs_working <- merge(orgs_working, profiles_working_grouped_domain_sums_summary, by="domain", all.x=TRUE);



# PROFILES_ORG_LOGICAL

# Create logical variables that depend on the org-level count variables created above
orgs_working <- mutate(orgs_working, knowledge_actor		= safe_ifelse(knowledge_actors_count	> 0, 					 		TRUE, FALSE),
									 core_actor				= safe_ifelse(core_actors_count			> 0, 					 		TRUE, FALSE));
orgs_working <- mutate(orgs_working, peripheral_actor		= safe_ifelse(knowledge_actor 			== FALSE & core_actor == FALSE, TRUE, FALSE));
											 
# Any NA values are for correctly NA domains, so should be left as is.



# PROFILES_ORG_CALCULATED

orgs_working <- mutate(orgs_working, 
					percent_bugs_reported_all_outcomes_fixed         	= safe_ifelse((bugs_reported_fixed_count 	  	+ 
																					   bugs_reported_not_fixed_count 		+ 
																					   bugs_reported_pending_count) 		<= 0, NA, bugs_reported_fixed_count 		/ (bugs_reported_fixed_count + bugs_reported_not_fixed_count + bugs_reported_pending_count)),
					percent_bugs_reported_defined_outcomes_fixed     	= safe_ifelse((bugs_reported_fixed_count 		+ 
																					   bugs_reported_not_fixed_count) 		<= 0, NA, bugs_reported_fixed_count 		/ (bugs_reported_fixed_count + bugs_reported_not_fixed_count)),
					percent_bugs_reported_all_outcomes_not_fixed     	= safe_ifelse((bugs_reported_fixed_count 		+
																					   bugs_reported_not_fixed_count 		+ 
																					   bugs_reported_pending_count) 		<= 0, NA, bugs_reported_not_fixed_count 	/ (bugs_reported_fixed_count + bugs_reported_not_fixed_count + bugs_reported_pending_count)),
					percent_bugs_reported_defined_outcomes_not_fixed 	= safe_ifelse((bugs_reported_fixed_count 		+
																					   bugs_reported_not_fixed_count) 		<= 0, NA, bugs_reported_not_fixed_count 	/ (bugs_reported_fixed_count + bugs_reported_not_fixed_count)),
					percent_bugs_reported_all_outcomes_pending       	= safe_ifelse((bugs_reported_fixed_count 		+
																					   bugs_reported_not_fixed_count 		+ 
																					   bugs_reported_pending_count) 		<= 0, NA, bugs_reported_pending_count 		/ (bugs_reported_fixed_count + bugs_reported_not_fixed_count + bugs_reported_pending_count)),
					percent_bugs_assigned_to_all_outcomes_fixed         = safe_ifelse((bugs_assigned_to_fixed_count 	+ 
																					   bugs_assigned_to_not_fixed_count 	+ 
																					   bugs_assigned_to_pending_count) 		<= 0, NA, bugs_assigned_to_fixed_count 		/ (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count + bugs_assigned_to_pending_count)),
					percent_bugs_assigned_to_defined_outcomes_fixed     = safe_ifelse((bugs_assigned_to_fixed_count 	+ 
																					   bugs_assigned_to_not_fixed_count) 	<= 0, NA, bugs_assigned_to_fixed_count 		/ (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count)),
					percent_bugs_assigned_to_all_outcomes_not_fixed     = safe_ifelse((bugs_assigned_to_fixed_count 	+
																					   bugs_assigned_to_not_fixed_count 	+ 
																					   bugs_assigned_to_pending_count) 		<= 0, NA, bugs_assigned_to_not_fixed_count 	/ (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count + bugs_assigned_to_pending_count)),
					percent_bugs_assigned_to_defined_outcomes_not_fixed = safe_ifelse((bugs_assigned_to_fixed_count 	+
																					   bugs_assigned_to_not_fixed_count) 	<= 0, NA, bugs_assigned_to_not_fixed_count 	/ (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count)),
					percent_bugs_assigned_to_all_outcomes_pending       = safe_ifelse((bugs_assigned_to_fixed_count 	+
																					   bugs_assigned_to_not_fixed_count 	+ 
																					   bugs_assigned_to_pending_count) 		<= 0, NA, bugs_assigned_to_pending_count 	/ (bugs_assigned_to_fixed_count + bugs_assigned_to_not_fixed_count + bugs_assigned_to_pending_count)),
					percent_bugs_qa_contact_all_outcomes_fixed         	= safe_ifelse((bugs_qa_contact_fixed_count 		+ 
																					   bugs_qa_contact_not_fixed_count 		+ 
																					   bugs_qa_contact_pending_count) 		<= 0, NA, bugs_qa_contact_fixed_count 		/ (bugs_qa_contact_fixed_count + bugs_qa_contact_not_fixed_count + bugs_qa_contact_pending_count)),
					percent_bugs_qa_contact_defined_outcomes_fixed     	= safe_ifelse((bugs_qa_contact_fixed_count 		+ 
																					   bugs_qa_contact_not_fixed_count) 	<= 0, NA, bugs_qa_contact_fixed_count 		/ (bugs_qa_contact_fixed_count + bugs_qa_contact_not_fixed_count)),
					percent_bugs_qa_contact_all_outcomes_not_fixed     	= safe_ifelse((bugs_qa_contact_fixed_count 		+
																					   bugs_qa_contact_not_fixed_count 		+ 
																					   bugs_qa_contact_pending_count) 		<= 0, NA, bugs_qa_contact_not_fixed_count 	/ (bugs_qa_contact_fixed_count + bugs_qa_contact_not_fixed_count + bugs_qa_contact_pending_count)),
					percent_bugs_qa_contact_defined_outcomes_not_fixed 	= safe_ifelse((bugs_qa_contact_fixed_count 		+
																					   bugs_qa_contact_not_fixed_count) 	<= 0, NA, bugs_qa_contact_not_fixed_count 	/ (bugs_qa_contact_fixed_count + bugs_qa_contact_not_fixed_count)),
					percent_bugs_qa_contact_all_outcomes_pending       	= safe_ifelse((bugs_qa_contact_fixed_count 		+
																					   bugs_qa_contact_not_fixed_count 		+ 
																					   bugs_qa_contact_pending_count) 		<= 0, NA, bugs_qa_contact_pending_count 	/ (bugs_qa_contact_fixed_count + bugs_qa_contact_not_fixed_count + bugs_qa_contact_pending_count)));

																					   
# PROFILES-ALL_TABLES_ORG_MEANS
# (Summarize all the individual user counts into org-level counts for the various table interactions)
# Using the user-level variables created in previous functions, we can simply mean() by domain for relevant variables

# Group profiles according to domains
profiles_working_grouped_domain_means <- group_by(profiles_working, domain);

# Use summarize() function to sum the various user counts for each domain
profiles_working_grouped_domain_means_summary <- summarize(profiles_working_grouped_domain_means ,  bugs_reported_enhancement_mean_days_to_last_resolved		= mean(bugs_reported_enhancement_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_reported_trivial_mean_days_to_last_resolved			= mean(bugs_reported_trivial_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_reported_minor_mean_days_to_last_resolved				= mean(bugs_reported_minor_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_reported_normal_mean_days_to_last_resolved				= mean(bugs_reported_normal_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_reported_major_mean_days_to_last_resolved				= mean(bugs_reported_major_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_reported_critical_mean_days_to_last_resolved			= mean(bugs_reported_critical_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_reported_blocker_mean_days_to_last_resolved			= mean(bugs_reported_blocker_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_reported_all_types_mean_days_to_last_resolved			= mean(bugs_reported_all_types_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_reported_enhancement_mean_days_to_resolution			= mean(bugs_reported_enhancement_mean_days_to_resolution, na.rm = TRUE),
																									bugs_reported_trivial_mean_days_to_resolution				= mean(bugs_reported_trivial_mean_days_to_resolution, na.rm = TRUE),
																									bugs_reported_minor_mean_days_to_resolution					= mean(bugs_reported_minor_mean_days_to_resolution, na.rm = TRUE),
																									bugs_reported_normal_mean_days_to_resolution				= mean(bugs_reported_normal_mean_days_to_resolution, na.rm = TRUE),
																									bugs_reported_major_mean_days_to_resolution					= mean(bugs_reported_major_mean_days_to_resolution, na.rm = TRUE),
																									bugs_reported_critical_mean_days_to_resolution				= mean(bugs_reported_critical_mean_days_to_resolution, na.rm = TRUE),
																									bugs_reported_blocker_mean_days_to_resolution				= mean(bugs_reported_blocker_mean_days_to_resolution, na.rm = TRUE),
																									bugs_reported_all_types_mean_days_to_resolution				= mean(bugs_reported_all_types_mean_days_to_resolution, na.rm = TRUE),
																									bugs_assigned_to_enhancement_mean_days_to_last_resolved		= mean(bugs_assigned_to_enhancement_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_assigned_to_trivial_mean_days_to_last_resolved			= mean(bugs_assigned_to_trivial_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_assigned_to_minor_mean_days_to_last_resolved			= mean(bugs_assigned_to_minor_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_assigned_to_normal_mean_days_to_last_resolved			= mean(bugs_assigned_to_normal_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_assigned_to_major_mean_days_to_last_resolved			= mean(bugs_assigned_to_major_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_assigned_to_critical_mean_days_to_last_resolved		= mean(bugs_assigned_to_critical_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_assigned_to_blocker_mean_days_to_last_resolved			= mean(bugs_assigned_to_blocker_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_assigned_to_all_types_mean_days_to_last_resolved		= mean(bugs_assigned_to_all_types_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_assigned_to_enhancement_mean_days_to_resolution		= mean(bugs_assigned_to_enhancement_mean_days_to_resolution, na.rm = TRUE),
																									bugs_assigned_to_trivial_mean_days_to_resolution			= mean(bugs_assigned_to_trivial_mean_days_to_resolution, na.rm = TRUE),
																									bugs_assigned_to_minor_mean_days_to_resolution				= mean(bugs_assigned_to_minor_mean_days_to_resolution, na.rm = TRUE),
																									bugs_assigned_to_normal_mean_days_to_resolution				= mean(bugs_assigned_to_normal_mean_days_to_resolution, na.rm = TRUE),
																									bugs_assigned_to_major_mean_days_to_resolution				= mean(bugs_assigned_to_major_mean_days_to_resolution, na.rm = TRUE),
																									bugs_assigned_to_critical_mean_days_to_resolution			= mean(bugs_assigned_to_critical_mean_days_to_resolution, na.rm = TRUE),
																									bugs_assigned_to_blocker_mean_days_to_resolution			= mean(bugs_assigned_to_blocker_mean_days_to_resolution, na.rm = TRUE),
																									bugs_assigned_to_all_types_mean_days_to_resolution			= mean(bugs_assigned_to_all_types_mean_days_to_resolution, na.rm = TRUE),
																									bugs_qa_contact_enhancement_mean_days_to_last_resolved		= mean(bugs_qa_contact_enhancement_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_qa_contact_trivial_mean_days_to_last_resolved			= mean(bugs_qa_contact_trivial_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_qa_contact_minor_mean_days_to_last_resolved			= mean(bugs_qa_contact_minor_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_qa_contact_normal_mean_days_to_last_resolved			= mean(bugs_qa_contact_normal_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_qa_contact_major_mean_days_to_last_resolved			= mean(bugs_qa_contact_major_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_qa_contact_critical_mean_days_to_last_resolved			= mean(bugs_qa_contact_critical_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_qa_contact_blocker_mean_days_to_last_resolved			= mean(bugs_qa_contact_blocker_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_qa_contact_all_types_mean_days_to_last_resolved		= mean(bugs_qa_contact_all_types_mean_days_to_last_resolved, na.rm = TRUE),
																									bugs_qa_contact_enhancement_mean_days_to_resolution			= mean(bugs_qa_contact_enhancement_mean_days_to_resolution, na.rm = TRUE),
																									bugs_qa_contact_trivial_mean_days_to_resolution				= mean(bugs_qa_contact_trivial_mean_days_to_resolution, na.rm = TRUE),
																									bugs_qa_contact_minor_mean_days_to_resolution				= mean(bugs_qa_contact_minor_mean_days_to_resolution, na.rm = TRUE),
																									bugs_qa_contact_normal_mean_days_to_resolution				= mean(bugs_qa_contact_normal_mean_days_to_resolution, na.rm = TRUE),
																									bugs_qa_contact_major_mean_days_to_resolution				= mean(bugs_qa_contact_major_mean_days_to_resolution, na.rm = TRUE),
																									bugs_qa_contact_critical_mean_days_to_resolution			= mean(bugs_qa_contact_critical_mean_days_to_resolution, na.rm = TRUE),
																									bugs_qa_contact_blocker_mean_days_to_resolution				= mean(bugs_qa_contact_blocker_mean_days_to_resolution, na.rm = TRUE),
																									bugs_qa_contact_all_types_mean_days_to_resolution			= mean(bugs_qa_contact_all_types_mean_days_to_resolution, na.rm = TRUE),
																									bugs_reported_enhancement_description_mean_length			= mean(bugs_reported_enhancement_description_mean_length, na.rm = TRUE),
																									bugs_reported_trivial_description_mean_length				= mean(bugs_reported_trivial_description_mean_length, na.rm = TRUE),	
																									bugs_reported_minor_description_mean_length					= mean(bugs_reported_minor_description_mean_length, na.rm = TRUE),		
																									bugs_reported_normal_description_mean_length				= mean(bugs_reported_normal_description_mean_length, na.rm = TRUE),		
																									bugs_reported_major_description_mean_length					= mean(bugs_reported_major_description_mean_length, na.rm = TRUE),		
																									bugs_reported_critical_description_mean_length				= mean(bugs_reported_critical_description_mean_length, na.rm = TRUE),	
																									bugs_reported_blocker_description_mean_length				= mean(bugs_reported_blocker_description_mean_length, na.rm = TRUE),
																									bugs_assigned_to_enhancement_description_mean_length		= mean(bugs_assigned_to_enhancement_description_mean_length, na.rm = TRUE),
																									bugs_assigned_to_trivial_description_mean_length			= mean(bugs_assigned_to_trivial_description_mean_length, na.rm = TRUE),	
																									bugs_assigned_to_minor_description_mean_length				= mean(bugs_assigned_to_minor_description_mean_length, na.rm = TRUE),		
																									bugs_assigned_to_normal_description_mean_length				= mean(bugs_assigned_to_normal_description_mean_length, na.rm = TRUE),		
																									bugs_assigned_to_major_description_mean_length				= mean(bugs_assigned_to_major_description_mean_length, na.rm = TRUE),		
																									bugs_assigned_to_critical_description_mean_length			= mean(bugs_assigned_to_critical_description_mean_length, na.rm = TRUE),	
																									bugs_assigned_to_blocker_description_mean_length			= mean(bugs_assigned_to_blocker_description_mean_length, na.rm = TRUE),
																									bugs_qa_contact_enhancement_description_mean_length			= mean(bugs_qa_contact_enhancement_description_mean_length, na.rm = TRUE),
																									bugs_qa_contact_trivial_description_mean_length				= mean(bugs_qa_contact_trivial_description_mean_length, na.rm = TRUE),	
																									bugs_qa_contact_minor_description_mean_length				= mean(bugs_qa_contact_minor_description_mean_length, na.rm = TRUE),		
																									bugs_qa_contact_normal_description_mean_length				= mean(bugs_qa_contact_normal_description_mean_length, na.rm = TRUE),		
																									bugs_qa_contact_major_description_mean_length				= mean(bugs_qa_contact_major_description_mean_length, na.rm = TRUE),		
																									bugs_qa_contact_critical_description_mean_length			= mean(bugs_qa_contact_critical_description_mean_length, na.rm = TRUE),	
																									bugs_qa_contact_blocker_description_mean_length				= mean(bugs_qa_contact_blocker_description_mean_length, na.rm = TRUE),
																									bugs_reported_all_types_description_mean_length				= mean(bugs_reported_all_types_description_mean_length, na.rm = TRUE),
																									bugs_assigned_to_all_types_description_mean_length			= mean(bugs_assigned_to_all_types_description_mean_length, na.rm = TRUE),
																									bugs_qa_contact_all_types_description_mean_length			= mean(bugs_qa_contact_all_types_description_mean_length, na.rm = TRUE),
																									bugs_reported_enhancement_comments_mean_length				= mean(bugs_reported_enhancement_comments_mean_length, na.rm = TRUE),
																									bugs_reported_trivial_comments_mean_length					= mean(bugs_reported_trivial_comments_mean_length, na.rm = TRUE),	
																									bugs_reported_minor_comments_mean_length					= mean(bugs_reported_minor_comments_mean_length, na.rm = TRUE),		
																									bugs_reported_normal_comments_mean_length					= mean(bugs_reported_normal_comments_mean_length, na.rm = TRUE),		
																									bugs_reported_major_comments_mean_length					= mean(bugs_reported_major_comments_mean_length, na.rm = TRUE),		
																									bugs_reported_critical_comments_mean_length					= mean(bugs_reported_critical_comments_mean_length, na.rm = TRUE),	
																									bugs_reported_blocker_comments_mean_length					= mean(bugs_reported_blocker_comments_mean_length, na.rm = TRUE),
																									bugs_assigned_to_enhancement_comments_mean_length			= mean(bugs_assigned_to_enhancement_comments_mean_length, na.rm = TRUE),
																									bugs_assigned_to_trivial_comments_mean_length				= mean(bugs_assigned_to_trivial_comments_mean_length, na.rm = TRUE),	
																									bugs_assigned_to_minor_comments_mean_length					= mean(bugs_assigned_to_minor_comments_mean_length, na.rm = TRUE),		
																									bugs_assigned_to_normal_comments_mean_length				= mean(bugs_assigned_to_normal_comments_mean_length, na.rm = TRUE),		
																									bugs_assigned_to_major_comments_mean_length					= mean(bugs_assigned_to_major_comments_mean_length, na.rm = TRUE),		
																									bugs_assigned_to_critical_comments_mean_length				= mean(bugs_assigned_to_critical_comments_mean_length, na.rm = TRUE),	
																									bugs_assigned_to_blocker_comments_mean_length				= mean(bugs_assigned_to_blocker_comments_mean_length, na.rm = TRUE),
																									bugs_qa_contact_enhancement_comments_mean_length			= mean(bugs_qa_contact_enhancement_comments_mean_length, na.rm = TRUE),
																									bugs_qa_contact_trivial_comments_mean_length				= mean(bugs_qa_contact_trivial_comments_mean_length, na.rm = TRUE),	
																									bugs_qa_contact_minor_comments_mean_length					= mean(bugs_qa_contact_minor_comments_mean_length, na.rm = TRUE),		
																									bugs_qa_contact_normal_comments_mean_length					= mean(bugs_qa_contact_normal_comments_mean_length, na.rm = TRUE),		
																									bugs_qa_contact_major_comments_mean_length					= mean(bugs_qa_contact_major_comments_mean_length, na.rm = TRUE),		
																									bugs_qa_contact_critical_comments_mean_length				= mean(bugs_qa_contact_critical_comments_mean_length, na.rm = TRUE),	
																									bugs_qa_contact_blocker_comments_mean_length				= mean(bugs_qa_contact_blocker_comments_mean_length, na.rm = TRUE),
																									bugs_reported_all_types_comments_mean_length				= mean(bugs_reported_all_types_comments_mean_length, na.rm = TRUE),
																									bugs_assigned_to_all_types_comments_mean_length				= mean(bugs_assigned_to_all_types_comments_mean_length, na.rm = TRUE),
																									bugs_qa_contact_all_types_comments_mean_length				= mean(bugs_qa_contact_all_types_comments_mean_length, na.rm = TRUE));
	
# Somehow, the domain gets set as an integer, not a character string, so fix it:
profiles_working_grouped_domain_means_summary$domain <- as.factor(as.character(profiles_working_grouped_domain_means_summary$domain));

# NaN values mean there are no relevant cases to assess the mean(), so replace with NA
# Luckily, NaN entries match is.na(), so can easily be replaced even though the statement seems redundant
# We don't use is.NaN() because there is no s3 method for data.frames, so it errors as of recent versions of R
profiles_working_grouped_domain_means_summary[is.na(profiles_working_grouped_domain_means_summary)] 	  <- NA;

																						
# Merge	profiles_working_grouped_domain_means_summary and orgs_working tables based on domain to add new mean columns
setkey(profiles_working_grouped_domain_means_summary, domain);
setkey(orgs_working, domain);
orgs_working <- merge(orgs_working, profiles_working_grouped_domain_means_summary, by="domain", all.x=TRUE);

											 
											 									
		
# CLEAN UP

# Set global variables for other functions
orgs_final	<<- orgs_working;
	
} # End operationalize_org_level function



# Run our desired functions
# And time them.
start <- Sys.time();
	
	set_options();
	set_parameters();
	load_libraries();
	
	load_bugzilla_data_from_DB();
#	load_mimetypes_from_remote_DB();
	load_mimetypes_from_CSV();
#	write_mimetypes();
	clean_bugzilla_data();
	add_domains();
	operationalize_base();
	
# Remove global variables that we no longer need to free up memory
	# Original input variables
	rm(bugs, profiles, longdescs, activity, cc, attachments, votes, watch, duplicates, group_members, keywords, flags, products, dependencies, group_list, components, components_cc, components_watch);

	# Cleaned variables
	rm(bugs_clean, profiles_clean, longdescs_clean, activity_clean, cc_clean, attachments_clean, votes_clean, watch_clean, duplicates_clean, group_members_clean, 
	   keywords_clean, flags_clean, products_clean, dependencies_clean, group_list_clean, components_clean, components_cc_clean, components_watch_clean);
	
	# Variables with appended domains
	rm(bugs_domains, profiles_domains, longdescs_domains, activity_domains, cc_domains, attachments_domains, votes_domains, watch_domains, duplicates_domains, group_members_domains, 
	   keywords_domains, flags_domains, dependencies_domains, components_domains, components_cc_domains, components_watch_domains);

	# That leaves us with just the "_base" variables taking up memory!	
	
	# Run garbage collection to free up memory
	gc();
	
	operationalize_interactions_partial();
	gc();
	operationalize_interactions();
    gc();
	operationalize_calculated_variables();

	if(RUN_SLOW_FUNCTIONS) {
		gc();
		operationalize_slow_calculations();
	}
	
	if(RUN_VERY_SLOW_FUNCTIONS) {
	    gc();
		operationalize_very_slow_calculations();
	}
	
	if(RUN_BUGS_SUMMARY_FUNCTION) {
		gc();
		operationalize_bugs_summary();
	}
	gc();
	operationalize_org_level();

end <- Sys.time();

total_time <- end - start;
print(paste0(cat("\n\n"), "Total time was: ", format(total_time, units="auto"), cat("\n\n")));
	

# Perform garbage collection to free memory in interactive session

gc();

#
# EOF


