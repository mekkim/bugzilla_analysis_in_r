#################################################################################
#                                                                               
#       HOWTO Replicate the Database Creation and Analysis in My Research 		
#
#		Canadian Organizations and Contributions to Firefox			
#																				
#		© 2015 by Mekki MacAulay, mekki@mekki.ca, http://mekki.ca				
#		Some rights reserved.													
#										
#		Current version created on July 16, 2015								
#																				
#		This program is free and open source software. The author licenses it	 
#		to you under the terms of the GNU General Public License (GPL), as 		
#		published by the Free Software Foundation, either version 3, or			
#		(at your option) any later version (GPLv3+).							
#																				
#		There is NO WARRANTY for this software, express or implied, including 	
#		the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR 	
#		PURPOSE. See the GNU General Public License for more details.			
#																				
#		For the full text of the GNU General Public License, please visit		
#		http://gnu.org/licenses/																					
#                                            									
#		Should you require an alternative licensing arrangement for this 		
#		software, please contact the author.	                                
#################################################################################
#
# NOTE: The instructions in this file are intended for a Windows 64-bit environment
# Many of the operations are CPU and RAM intensive
# This script was tested on Windows 7 Ultimate SP1 64bit running on a system with
# an i7-5930K 6-core CPU clocked at 3.50GHz per CPU with 32GB of DDR4 RAM and SSD hard drive
# Your mileage may vary for alternative operating systems and/or hardware
#
# This file is deliberately a commented R script file
# That means you can execute it directly either within R:
# setwd('<FULL PATH TO THIS SCRIPT FILE>');
# source('<NAME OF THIS FILE>.r', echo=TRUE, max.deparse.length=10000, keep.source=TRUE);
# (These source() parameters ensure that the R shell outputs the script commands and responses. Otherwise, they're hidden by default.) 
#
# For example (while timing the execution):
# setwd('c:/Users/atriou/Dropbox/Classes and York Stuff/Dissertation and brainstorming/Scripts/R');
# system.time(source('bugzillascript.r', echo=TRUE, max.deparse.length=10000, keep.source=TRUE));
#
#
# Or, from the command prompt directly as follows (assuming R binary is in the PATH environment variable):
# cd <FULL PATH TO THIS SCRIPT FILE>
# R CMD BATCH <NAME OF THIS FILE>.r
# CAT <NAME OF THIS FILE>.Rout
# (The CAT is necessary because by default R output writes to file, not command prompt)
#
#
#################################################################################
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
# curl
# data.table
# DBI
# dplyr
# DT
# FactoMineR
# FSA: https://www.rforge.net/FSA/Installation.html
# ggplot2
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
# CONNECT R to DATABASE SERVER
#
# Launch R (64bit)  and load the RMySQL library with the following command:

library(RMySQL);

# Also load the data.table library, which we'll use throughout:

library(data.table);

# Also load the FSA library which helps us with Subset() instead of subset() which drops unused factors 

library(FSA);

# And package:scales in order to ensure that graphs resize properly near boundaries

library(scales);

# R should automatically load any dependencies for you
#
# Create a convenient variable in R that will contain the database connection details:

bugzilla = dbConnect(MySQL(), user='root', password='password', dbname='working', host='localhost');

# Test the functionality of the connection by listing all the tables:

#dbListTables(bugzilla);

#
# CREATE DATA FRAMES IN R FROM DATABASE 
#
# Create a data frame variable for all the bugs table from the bugzilla MySQL database

bugs <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM bugs;');

# Create a data frame variable for all the products table that contains the list of Mozilla products tracked in bugzilla from MySQL database

#products <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM products;');

# Create a data frame variable for all the bugs that are related only to Firefox (for CIRA grant paper)
# The products table shows us that the indexes for Firefox-related bugs have a product_id of either 
# 21: Firefox
# 44: Extend Firefox
# 46: Fennec, i.e., Firefox mobile
# 74: Firefox for Android
# 94: Firefox Graveyard
# 95: Firefox for Metro

firefox_bugs <- as.data.table(subset(bugs, product_id %in% c(21, 44, 46, 74, 94, 95)));

# We find that there are 136811 Firefox-related bugs out of 774809 bugs total.
#
# Isolate the "bug_id"s of bugs related to Firefox into a single vector for later filtering simplicity

firefox_bugids <- firefox_bugs$bug_id;

# Create a data frame variable with all the users who have an email address that ends in .ca

can_users <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM profiles WHERE profiles.login_name LIKE "%.ca";');

# We find that there are 5926 users with logins ending in .CA
#
# Isolate just the login names (emails) in a 1-column vector

can_logins <- can_users[,"login_name"];

# Use the list of logins to create a 1-column vector of just the domains

can_domains <- sub("^[a-z0-9_%+-.]+@((?:[a-z0-9-]+\\.)+[a-z]{2,4})$", "\\1", can_logins, ignore.case = TRUE, perl = TRUE);

# Count the number of times each domain name shows up in the vector, sorted from most to least for simplicity.
# We'll use the arrange() function from the "dplyr" library, so let's load it first

library(plyr);
library(dplyr);
can_domain_count <- arrange(as.data.frame(table(can_domains)), -Freq);

# 1744 unique .ca domains are found.  These include webmail and other spurious domains that aren't "Canadian organizations"
# They also count multiple formats as separate domains, so don't translate to number of orgs yet

#
# GROUP INTO ORGANIZATIONS
#
# We want to exclude all "personal" email address domains.  This will create a conservative set of
# "Canadian organizations" 
#
# By manual inspection, the following domains are known to be personal webmail/email domains or typos thereof

exclude_domains <- c('yahoo.ca',
'shaw.ca',
'sympatico.ca',
'videotron.ca',
'cogeco.ca',
'live.ca',
'ns.sympatico.ca',
'magma.ca',
'eastlink.ca',
'nbnet.nb.ca',
'sprint.ca',
'primus.ca',
'nb.sympatico.ca',
'ncf.ca',
'accesscomm.ca',
'aei.ca',
'cgocable.ca',
'nf.sympatico.ca',
'bellnet.ca',
'cyberus.ca',
'vianet.ca',
'chebucto.ns.ca',
'hfx.eastlink.ca',
'look.ca',
'fastmail.ca',
'hotmail.ca',
'sk.sympatico,ca',
'storm.ca',
'accesswave.ca',
'attcanada.ca',
'oricom.ca',
'b2b2c.ca',
'cooptel.qc.ca',
'direct.ca',
'intergate.ca',
'istar.ca',
'netscape.ca',
'aci.on.ca',
'freenet.carleton.ca',
'mb.sympatico.ca',
'netcom.ca',
'tlb.sympatico.ca',
'yaho.ca',
'escape.ca',
'ody.ca',
'spots.ab.ca',
'vl.videotron.ca',
'compusmart.ab.ca',
'ecn.ab.ca',
'gosympatico.ca',
'isys.ca',
'pei.sympatico.ca',
'portal.ca',
'videon.wave.ca',
'videotron.ca',
'wightman.ca',
'295.ca',
'aol.ca',
'bwr.eastlink.ca',
'compusmart.bc.ca',
'connect.ab.ca',
'hy.cgocable.ca',
'supernet.ab.ca',
'supernet.ca',
'syd.eastlink.ca',
'symaptico.ca',
'symptico.ca',
'tfnet.ca',
'vdn.ca',
'videotron.ca',
'videotron.qc.ca' ); 

# Turn these domains into a large "OR" pattern to match using a grep() statement with each value separated by a "|"
# To do that, we use the paste() and collapse() functions

exclude_domains_pattern <- paste(exclude_domains, collapse="|");

# We can now use this pattern (inverted) to select just rows with domains that are "Canadian organizations"

can_org_domains <- can_domain_count[grep(exclude_domains_pattern, can_domain_count$can_domains, ignore.case=TRUE, perl=TRUE, invert=TRUE) , ];

# We find 1651 .ca domains after filtering out known webmail domains. Still doesn't account for format similarities for orgs
# But, "can_org_domains" IS THE VARIABLE WE NEED TO USE TO SELECT USERS BECAUSE IT ISN't COLLAPSED so has ALL FORMS OF EMAIL DOMAINS IN IT!!!
# We'll match users later on.  First, let's identify organizations.
#
#
# IDENTIFY AND GROUP ORGANIZATIONS
#
# We want to have a clearer picture of different domain names that the same organizations use
# Sometimes the same organization uses different email formats in order to separate inner departments via sub-domains, etc.
# We don't want to accidentally treat those cases as separate organizations
# We need to collapse some of the organizations with varied domain formats that are the same organization
#
# Most organizations can be identified by the last word before ".ca".  However, some organizations
# use provincial or other .ca subdomains such as ".on.ca" or ".gc.ca"
#
# We can identify the organization name either in the last position before .ca or in the second last position before .ca, i.e., "(2ndlast).(last).ca"
# In rare cases the names that appear in (2ndlast) and (last) could be the same for different orgs (i.e., concordia.ca vs concordia.ab.ca)
# So for the case of (2ndlast) orgs, we'll preserve the (last) as well to distinguish
#
# To distinguish between the two cases, we need to check the (last).ca value
#
# The possible options are:

prov_list <- c('\\.ab\\.ca', '\\.bc\\.ca', '\\.mb\\.ca', '\\.nb\\.ca', '\\.nf\\.ca', '\\.nl\\.ca', '\\.ns\\.ca', '\\.nt\\.ca', '\\.nu\\.ca', '\\.on\\.ca', '\\.pe\\.ca', '\\.qc\\.ca', '\\.sk\\.ca', '\\.yk\\.ca', '\\.gc\\.ca');

prov_pattern <- paste(prov_list, collapse ='|');

# Split the can_org_domains into two parts: provincial sub-domain and no sub-domain

can_org_domains_prov <- can_org_domains[grep(prov_pattern, can_org_domains$can_domains, ignore.case=TRUE, perl=TRUE) , ];

# There are 1395 with no sub-domains

can_org_domains_nosub <- can_org_domains[grep(prov_pattern, can_org_domains$can_domains, ignore.case=TRUE, perl=TRUE, invert=TRUE) , ];

# And 256 with sub-domains

#
# For the provincial/gov case, the org names will be in the form "org.[prov|gov].ca":

can_org_domains_prov_orgs <- sub("^([a-z0-9-]+\\.)*([a-z0-9-]+\\.ab|bc|mb|nb|nf|nl|ns|nt|nu|on|pe|qc|sk|yk|gc\\.ca$)", "\\1\\2\\3\\4", can_org_domains_prov$can_domains, ignore.case = TRUE, perl = TRUE);

# For the no sub-domain case, the org names will be in the form "org.ca":

can_org_domains_nosub_orgs <- sub("^([a-z0-9-]+\\.)*([a-z0-9-]+\\.ca$)", "\\2", can_org_domains_nosub$can_domains, ignore.case = TRUE, perl = TRUE);

#
# Re-join the two into orgs lists now that we've reduced them to the org-salient part of the domain name

can_orgs <- c(can_org_domains_prov_orgs, can_org_domains_nosub_orgs);

# We'll also set all the org names to lower-case for easier matching

can_orgs <- tolower(can_orgs);

# We can now remove duplicates that resulted from the different formatting of the domains:

can_orgs <- unique(can_orgs);

# We've reduced the number of orgs from 1651 to 1424 by removing alternative format duplicates
# Sort them alphabetically to facilitate manual inspection

can_orgs <- sort(can_orgs);

# We now need further manual imputation to remove the alternate formats for special cases of certain org names
# Special cases in the can_orgs[index]:
# 
# 17: "admin.gmcc.ab.ca" should just be "gmcc.ab.ca"
# 886, 887: nrc: includes "nrc.ca", "nrc.gc.ca", and "nrc-cnrc.gc.ca" formats.  We'll use "nrc.gc.ca" for all of them.
# 1049: "rotman-baycrest.on.ca" is U of T "utoronto.ca"
# 818: Mohawk College uses both "mohawkc.on.ca" and "mohawkcollege.ca": we'll keep "mohawkc.on.ca"
# 187: "cdot.ca" and "senecacollege.ca" are Seneca College "senecac.on.ca"
# 268: "crc.ca" is Industry Canada "ic.gc.ca"
# 526: Hamilton city uses both "hamilton.on.ca" and "hamilton.ca"
# 562: Humber College uses both "humber.ca" and "humberc.on.ca"
# 865: "nfy.ca" and "nfy.bc.ca" are the same org
# 906: "ocad.ca" and "ocadu.ca" are the same
# 1173: "stclaircollege.ca" is "stclairc.on.ca"
# 1266: "toronto.on.ca" is "toronto.ca"
# 1303: "unitz.on.ca" and "unitz.ca" are the same
# 1321: "usherb.ca" and "usherbrooke.ca" are the same
# 1355: "waterloo.on.ca" should be "ajlc.waterloo.on.ca" -> rare exception.
# 1405: "yknet.yk.ca" and "yknet.ca" are the same


can_orgs[17] <- "gmcc.ab.ca";
can_orgs[187] <- "senecac.on.ca";
can_orgs[268] <- "ic.gc.ca";
can_orgs[526] <- "hamilton.ca";
can_orgs[562] <- "humberc.on.ca";
can_orgs[818] <- "mohawkc.on.ca";
can_orgs[865] <- "nfy.ca";
can_orgs[886] <- "nrc.gc.ca";
can_orgs[887] <- "nrc.gc.ca";
can_orgs[906] <- "ocadu.ca";
can_orgs[1049] <- "utoronto.ca";
can_orgs[1101] <- "senecac.on.ca";
can_orgs[1173] <- "stclairc.on.ca";
can_orgs[1266] <- "toronto.ca";
can_orgs[1303] <- "unitz.ca";
can_orgs[1321] <- "usherbrooke.ca";
can_orgs[1355] <- "ajlc.waterloo.on.ca";
can_orgs[1405] <- "yknet.ca";

# With the imputations, we will once again have duplicates
# Remove duplicates and re-sort:

can_orgs <- sort(unique(can_orgs));

# We find 1408 unique Canadian organizations in our sample, represented by 1651 different formats total.
#
#
# MATCH USERS TO CANADIAN ORGANIZATIONS
#
# We need to match on all 1651 can_org_"domains" since it preserves the multiple formats that the users might be using,
# even though they only make up 1408 unique organizations - We'll then have to regroup them into orgs
#
# Canadian organization users are any of the 5962 .CA users total whose email matches one of the 1651 patterns after removing webmail

can_org_domains_pattern <- paste(can_org_domains$can_domains, collapse="|");

can_org_users <- can_users[grep(can_org_domains_pattern, can_users$login_name, ignore.case=TRUE, perl=TRUE) , ];


# We find that there are 2689 users working for the 1408 Canadian organizations out of 5962 .CA users total
#
# For each user, we want to add which of the 1408 orgs they are working for in a new column
# The for loop() solution isn't awesome.  Instead we could do two operations:
# 1) Create a lookup table with matches of login_name in can_orgs (what the grepl()) does
# 2) Use that lookup table with the match syntax used later on.  Probably faster that way.
# Not done currently due to lack of time.  Will improve in next version
# 

# Old original version that is very, very slow
#
#for (i in 1:2689) {
#	for (j in 1:1408) {
#		if (grepl(can_orgs[j], can_org_users$login_name[i], ignore.case=TRUE, perl=TRUE)) {
#			can_org_users$org[i] <- can_orgs[j];
#			break;
#		}
#		can_org_users$org[i] <- "SPECIALCASE";
#	}
#}	
#
#
# New single for() loop version provided by @Nickk at Stack Overflow: http://stackoverflow.com/users/4998761/nick-k
#
# Additional thanks to:
# @DeanMacGregor (http://stackoverflow.com/users/1818713/dean-macgregor)
# @PierreLafortune (http://stackoverflow.com/users/4564247/pierre-lafortune)
# @RomanTsegelskyi (http://stackoverflow.com/users/1900537/roman-tsegelskyi)
# @BrodieG (http://stackoverflow.com/users/2725969/brodieg)
#
# for teaching me useful things and alternative methods for this operation

# New version
# 

can_org_users$org <- NA;

for (orgs in can_orgs) {
	found <- grepl(orgs, can_org_users$login_name, ignore.case=TRUE, perl=TRUE);
	can_org_users[which(found & is.na(can_org_users$org)), "org"] <- orgs;
}
can_org_users[which(is.na(can_org_users$org)), "org"] <- "SPECIALCASE";

# End new version


# Move the org column over, drop the useless columns, and sort by org:

can_org_users_by_org <- can_org_users[c('userid', 'login_name', 'org', 'creation_ts', 'realname', 
										'comment_count', 'first_patch_bug_id', 'first_patch_approved_id', 'is_enabled')];

can_org_users_by_org <- can_org_users_by_org[order(can_org_users_by_org$org, as.Date(can_org_users_by_org$creation_ts), 
												   can_org_users_by_org$userid, can_org_users_by_org$comment_count) , ]; 
												   
#
# Handle the SPECIALCASEs:
# Yes, the direct data frame index substitutions are ugly and break if the numbers change.
# Will fix in next refactoring

can_org_users_by_org[1744,3] <- "usherbrooke.ca";
can_org_users_by_org[1745,3] <- "hamilton.ca";
can_org_users_by_org[1746,3] <- "nfy.ca";
can_org_users_by_org[1747,3] <- "nrc.gc.ca";
can_org_users_by_org[1748,3] <- "usherbrooke.ca";
can_org_users_by_org[1749,3] <- "ic.gc.ca";
can_org_users_by_org[1750,3] <- "stclairc.on.ca";
can_org_users_by_org[1751,3] <- "nrc.gc.ca";
can_org_users_by_org[1752,3] <- "senecac.on.ca";
can_org_users_by_org[1753,3] <- "nrc.gc.ca";
can_org_users_by_org[1754,3] <- "humberc.on.ca";
can_org_users_by_org[1755,3] <- "utoronto.ca";
can_org_users_by_org[1756,3] <- "nrc.gc.ca";
can_org_users_by_org[1757,3] <- "toronto.ca";
can_org_users_by_org[1758,3] <- "usherbrooke.ca";
can_org_users_by_org[1759,3] <- "usherbrooke.ca";
can_org_users_by_org[1760,3] <- "nrc.gc.ca";
can_org_users_by_org[1761,3] <- "usherbrooke.ca";
can_org_users_by_org[1762,3] <- "nrc.gc.ca";
can_org_users_by_org[1763,3] <- "mohawkc.on.ca";
can_org_users_by_org[1764,3] <- "nrc.gc.ca";
can_org_users_by_org[1765,3] <- "mohawkc.on.ca";
can_org_users_by_org[1766,3] <- "unitz.ca";
can_org_users_by_org[1767,3] <- "humberc.on.ca";
can_org_users_by_org[1768,3] <- "yknet.ca";
can_org_users_by_org[1769,3] <- "stclairc.on.ca";
can_org_users_by_org[1770,3] <- "senecac.on.ca";
can_org_users_by_org[1771,3] <- "ocadu.ca";

# And a few other suffix matching errors noticed via manual inspection:
# Yes, the direct data frame index substitutions are ugly and break if the numbers change.
# Will fix in next refactoring

can_org_users_by_org[11,3] <- "trlabs.ca";
can_org_users_by_org[289,3] <- "sencia.ca";
can_org_users_by_org[290,3] <- "cresencia.ca";
can_org_users_by_org[317,3] <- "jovaco.ca";
can_org_users_by_org[318,3] <- "diamco.ca";
can_org_users_by_org[319,3] <- "derrico.ca";
can_org_users_by_org[320,3] <- "karico.ca";
can_org_users_by_org[321,3] <- "keeganco.ca";
can_org_users_by_org[322,3] <- "startco.ca";
can_org_users_by_org[323,3] <- "gco.ca";
can_org_users_by_org[337,3] <- "metacon.ca";
can_org_users_by_org[549,3] <- "girlgeek.ca";
can_org_users_by_org[550,3] <- "egeek.ca";
can_org_users_by_org[812,3] <- "musis.ca";
can_org_users_by_org[813,3] <- "tecnopolis.ca";
can_org_users_by_org[814,3] <- "mharris.ca";
can_org_users_by_org[816,3] <- "jenhuis.ca";
can_org_users_by_org[817,3] <- "olidis.ca";
can_org_users_by_org[819,3] <- "lewis.ca";
can_org_users_by_org[820,3] <- "uveais.ca";
can_org_users_by_org[821,3] <- "lukaitis.ca";
can_org_users_by_org[824,3] <- "tetris.ca";
can_org_users_by_org[825,3] <- "versluis.ca";
can_org_users_by_org[980,3] <- "mostlylinux.ca";
can_org_users_by_org[1017,3] <- "muskokamagic.ca";
can_org_users_by_org[1440,3] <- "skytrac.ca";
can_org_users_by_org[1441,3] <- "skytrac.ca";
can_org_users_by_org[1484,3] <- "tech-tosterone.ca";

# All the utoronto.ca are mangled with the toronto.ca - So hard to account for strings in other strings.  Bleh.

can_org_users_by_org$org[1884:1988] <- "utoronto.ca";
can_org_users_by_org$org[c(1963, 1976, 1979)] <- "toronto.ca";

#
# Delete the following rows because they were included due to bad regex matches and are actually webmail accounts.

can_org_users_by_org <- can_org_users_by_org[-c(811, 822, 823, 920:940, 942:945, 947:948, 951:952, 954:968, 970:975), ];

# Sort once more with the imputed entries

can_org_users_by_org <- can_org_users_by_org[order(can_org_users_by_org$org, as.Date(can_org_users_by_org$creation_ts), 
												   can_org_users_by_org$userid, can_org_users_by_org$comment_count) , ]; 

# After manual imputation, we have 2636 users grouped into their 1401 Canadian organizations.  (It's now 1401 instead of 1408 due to the manual imputation) Woo!
#
# "can_org_users_by_org" is our FINAL VARIABLE FOR WHICH USERS WE CARE ABOUT 
#
# Now the manipulations on "can_org_users_by_org" only add columns for grouping and use subsets for comparison
#
#
# GROUP ORGANIZATION TYPES
#
#
# Let's create a variable that contains all the org names that are:
# 1) universities (n=48)
# 2) colleges (n=15)
# 3) higher_ed = universities + colleges (n=63)
# 4) Federal government (ends in .gc.ca) (n=29);
# 5) Other (not in above) (n=1308)

universities <- c('utoronto.ca',
'uwaterloo.ca',
'ubc.ca', 
'sfu.ca',
'ualberta.ca',
'mcgill.ca',
'ucalgary.ca',
'uvic.ca',
'uoguelph.ca',
'usask.ca',
'yorku.ca',
'dal.ca',
'queensu.ca',
'carleton.ca',
'uwo.ca',
'umontreal.ca',
'mun.ca',
'unb.ca',
'polymtl.ca',
'ulaval.ca',
'umanitoba.ca',
'usherbrooke.ca',
'concordia.ca',
'uottawa.ca',
'uqam.ca',
'mcmaster.ca',
'ryerson.ca',
'uleth.ca',
'athabascau.ca',
'brocku.ca',
'unbc.ca',
'etsmtl.ca',
'uwindsor.ca',
'acadiau.ca',
'concordia.ab.ca',
'nipissingu.ca',
'ocadu.ca',
'trentu.ca',
'uqac.ca',
'uqtr.ca',
'uquebec.ca',
'uregina.ca',
'lakeheadu.ca',
'ubishops.ca',
'usainteanne.ca',
'uwinnipeg.ca',
'wlu.ca',
'yorkvilleu.ca',
'laurentian.ca');

colleges <- c('senecac.on.ca',
'sheridanc.on.ca',
'mohawkc.on.ca',
'humberc.on.ca',
'stclairc.on.ca',
'brentwood.bc.ca',
'conestogac.on.ca',
'niagarac.on.ca',
'yukoncollege.yk.ca',
'clg.qc.ca',
'coll-outao.qc.ca',
'college-em.qc.ca',
'dawsoncollege.qc.ca',
'rmc.ca',
'loyalistc.on.ca');

higher_ed <- c(universities, colleges);

# Preserve this variable for simplicity
can_org_users_frequency <- dplyr::rename(arrange(as.data.frame(table(can_org_users_by_org$org)), -Freq), org = Var1);

fed_gov <- grep(".*\\.gc\\.ca$", can_org_users_frequency$org, ignore.case=TRUE, perl=TRUE, value=TRUE);

fed_gov <- append(fed_gov, 'army.ca');

other <- setdiff(can_org_users_frequency$org, c(higher_ed, fed_gov));


#
# Now let's check the n of each grouping of users and create a new group column for each sorting (higher group will show either university or college as appropriate)
#
# n=946 university users:

can_org_users_by_university <- subset(can_org_users_by_org, org %in% universities);
can_org_users_by_university$group <- "university";

# n=94 college users

can_org_users_by_college <- subset(can_org_users_by_org, org %in% colleges);
can_org_users_by_college$group <- "college";

# n=1040 higher-ed users

can_org_users_by_higher_ed <- as.data.frame(NA);
can_org_users_by_higher_ed$group <- NA;
can_org_users_by_higher_ed <- rbind(can_org_users_by_university, can_org_users_by_college);

# n=74 federal government users:

can_org_users_by_fed_gov <- subset(can_org_users_by_org, org %in% fed_gov);
can_org_users_by_fed_gov$group <- "fed_gov";

# n=1515 other users (link.ca was a bad match that slipped through the above corrections, so drop it)

can_org_users_by_other <- subset(can_org_users_by_org, org %in% other & org != 'link.ca');
can_org_users_by_other$group <- "other";

# Now recreate can_org_users_by_org so that it has the extra column and has dropped the link.ca entries

can_org_users_by_org <- rbind(can_org_users_by_higher_ed, can_org_users_by_fed_gov, can_org_users_by_other);

# Set the columns of can_org_users_by_org that are factors

can_org_users_by_org$group <- factor(as.character(can_org_users_by_org$group), levels=c("university", "college", "fed_gov", "other")); 

can_org_users_by_org$org <- factor(as.character(can_org_users_by_org$org), levels = c(higher_ed, fed_gov, other));

# And re-sort:

can_org_users_by_org <- can_org_users_by_org[order(can_org_users_by_org$group, can_org_users_by_org$org, can_org_users_by_org$creation_ts), ];


#
# To see which Canadian organizations have the most users, we can check the frequencies (renaming the default column name):

can_org_users_by_university_frequency <- dplyr::rename(arrange(as.data.frame(table(can_org_users_by_university$org)), -Freq), org = Var1);

can_org_users_by_college_frequency <- dplyr::rename(arrange(as.data.frame(table(can_org_users_by_college$org)), -Freq), org = Var1);

can_org_users_by_higher_ed_frequency <- dplyr::rename(arrange(as.data.frame(table(can_org_users_by_higher_ed$org)), -Freq), org = Var1);

can_org_users_by_fed_gov_frequency <- dplyr::rename(arrange(as.data.frame(table(can_org_users_by_fed_gov$org)), -Freq), org = Var1);

can_org_users_by_other_frequency <- dplyr::rename(arrange(as.data.frame(table(can_org_users_by_other$org)), -Freq), org = Var1);

#
# We can now generate all kinds of datasets and variables using the above subsets of orgs
#
# EXAMPLE WITH ALL CANDIAN ORGANIZATION USERS
#
# In this example, we show all the various things we can now report on using all the Canadian organization users
# The same principle can be used for any subset of Canadian organization users above
#
#
# Isolate the userid's of users in Canadian organizations into a single vector

can_org_userids <- can_org_users_by_org$userid;

# Create a data frame variable with all the Firefox bugs reported by can_org_userids

can_reported_firefox_bugs <- subset(firefox_bugs, reporter %in% can_org_userids);

# We find that 559 Firefox-related bugs were reported by users in Canadian organizations
#
# Isolate "bug_id"s related to Firefox reported by Canadian organization usersinto a single vector for later filtering simplicity

can_reported_firefox_bugids <- can_reported_firefox_bugs$bug_id;

# Let's take a look at how many of these bugs ended up fixed
# That means their "bug_status" is either "RESOLVED" OR "VERIFIED" AND resolution is "FIXED"

can_reported_firefox_bugs_fixed <- subset(can_reported_firefox_bugs, (bug_status == 'RESOLVED' & resolution == 'FIXED') |
																	 (bug_status == 'VERIFIED' & resolution == 'FIXED') );
# We find that only 49 of the 559 bugs ended up fixed
#
# Let's take a look at how many of the bugs are still pending
# That means their "bug_status" is either "NEW", "ASSIGNED", "REOPENED", OR "UNCONFIRMED"

can_reported_firefox_bugs_pending <- subset(can_reported_firefox_bugs, bug_status %in% c('NEW', 'ASSIGNED', 'REOPENED', 'UNCONFIRMED'));
																	 
# We find that 85 of the 559 bugs are still pending
#
#																	 
# Let's take a look at Firefox bugs that directly involve Canadian organization users beyond "reporter" status
#
# Ways that users can be directly involved in bugs in the "bugs" table include:
# Reporter, field id "reporter"
# Assigned to, field id "assigned_to"
# Responsible for quality assurance, field id "qa_contact"
# 
# Create a data frame variable with all the Firefox bugs with Canadian organization users directly involved in the "bugs" table:

can_involved_firefox_bugs <- subset(firefox_bugs, reporter %in% can_org_userids |
												  assigned_to %in% can_org_userids |
												  qa_contact %in% can_org_userids);

# We find 591 Firefox-related bugs with direct involvement by Canadian organization users. Small increase from the 559 reported.
#
# Isolate "bug_id"s related to Firefox with direct Canadian organization user involvement into a single vector for later filtering simplicity

can_involved_firefox_bugids <- can_involved_firefox_bugs$bug_id;

#
# We can also take a look at Firefox bugs that are touched in ANY way by Canadian organization users
#
# Ways that users can touch bugs in any way involve other tables, such as:
# The activity of bugs over time, table name "bugs_activity"

bugs_activity <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM bugs_activity;');

# The activity of just Firefox bugs:

firefox_activity <- subset(bugs_activity, bug_id %in% firefox_bugs$bug_id);

# Reducing only to activities of Canadian organization-involved Firefox bugs, we get:

can_involved_firefox_bugs_activity <- subset(bugs_activity, bug_id %in% can_involved_firefox_bugids);

# We find 5421 activities over time on the 591 Firefox-related bugs with direct involvement by Canadian organization users
# Note that these 5421 activities were done by any users, not just Canadian organization users
#
# Reducing to activities on the 591 Firefox-related bugs done by Canadian organization users, we get

can_involved_firefox_bugs_activity_by_can_org_users <- subset(bugs_activity, bug_id %in% can_involved_firefox_bugids & who %in% can_org_userids);

# We find 644 activities over time on the 591 Firefox-related bugs with direct Canadian organization user involvement done BY Canadian organization users
#
# Reducing to activities for Firefox bugs where the activity was done by a Canadian organization user (whether or not directly involved), we get:

can_any_firefox_bugs_activity <- subset(bugs_activity, bug_id %in% firefox_bugids & who %in% can_org_userids);

# We find 2638 activities over time on the 136811 Firefox-related bugs done by Canadian organization users (which include the 184 above)
# 
# The list of "bug_id"s people, "who", want to receive change notifications about, table name "cc"

cc <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM cc;');

# The CC's of just Firefox bugs:

firefox_cc <- subset(cc, bug_id %in% firefox_bugs$bug_id);

# Reducing to only Firefox bugs watched by Canadian organization users, we get

firefox_bugs_can_org_users_cc <- subset(cc, bug_id %in% firefox_bugids & who %in% can_org_userids);

# We find 1242 Firefox-related bugs watched by Canadian organization users
#
# Attachment submission for a given "bug_id" from a given "submitter_id", table name "attachments"

attachments <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM attachments;');

# The attachments of just Firefox bugs:

firefox_attachments <- subset(attachments, bug_id %in% firefox_bugs$bug_id);

# Reducing to only Firefox bugs with attachments submitted by Canadian organization users, we get

firefox_bugs_can_org_users_attachments <- subset(attachments, bug_id %in% firefox_bugids & submitter_id %in% can_org_userids);

# We find 198 attachments  to 136811 Firefox-related bugs done by Canadian organization users
#
# Comments, "thetext",  on a given "bug_id" from a given user, "who", at time, "bug_when", table name "longdescs"

longdescs <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM longdescs;');

firefox_longdescs <- subset(longdescs, bug_id %in% firefox_bugs$bug_id);

# Reducing to only Firefox bugs with comments by Canadian organization users, we get

firefox_bugs_can_org_users_comments <- subset(longdescs, bug_id %in% firefox_bugids & who %in% can_org_userids);

# We find 2198 comments on 136811 Firefox-related bugs done by Canadian organization users
#
# Vote for a given "bug_id" from a given user, "who", table name "votes"

votes <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM votes;');

# Reducing to only Firefox bugs with votes

firefox_votes <- subset(votes, bug_id %in% firefox_bugs$bug_id);

# Reducing to only Firefox bugs with votes by Canadian organization users, we get

firefox_bugs_can_org_users_votes <- subset(votes, bug_id %in% firefox_bugids & who %in% can_org_userids);

# We find 134 votes on 136811 Firefox-related bugs done by Canadian organization users
#
# To get notified whenever a "watched" user, the "watcher" can follow them, table name "watch"

watch <- dbGetQuery(conn = bugzilla, statement = 'SELECT * FROM watch;');

# Reducing to watchers or watched being a Canadian org user

all_watch <- subset(watch, watcher %in% can_org_userids | watched %in% can_org_userids);

# Reducing to only Canadian organization users who are watched by other users, we get

can_org_users_watched <- subset(watch, watched %in% can_org_userids);

# We find 13 instances of Canadian organization users (non-unique: multiple people can watch the same person) being watched by other users
#
# END of example for all Canadian organization users.  
# Along the way in this example, we created many useful data frames from the database, so no more DB queries should be required
# Disconnect the DB connection and unload RMySQL so that it doesn't mask other packages:

dbDisconnect(bugzilla);
detach("package:RMySQL", unload = TRUE);

#
# Making some name aliases at this point for simplicity:
# We know it's only Canadian subsets at this point, so we can drop the can/ can_org notation

all_users <- as.data.table(can_org_users_by_org);

# Set the data type for each field for later operations

transform(all_users, userid=as.factor(userid), org=as.factor(org), creation_ts=as.Date(creation_ts), comment_count=as.numeric(comment_count), group=as.factor(group));

all_users_freq <- can_org_users_frequency;

university_users <- subset(all_users, org %in% universities);
university_users_freq <- can_org_users_by_university_frequency;

college_users <- subset(all_users, org %in% colleges);
college_users_freq <- can_org_users_by_college_frequency;

higher_ed_users <- rbind(university_users, college_users);
higher_ed_users_freq <- can_org_users_by_higher_ed_frequency;

fed_gov_users <- subset(all_users, org %in% fed_gov);
fed_gov_users_freq <- can_org_users_by_fed_gov_frequency;

other_users <- subset(all_users, org %in% other);
other_users_freq <- can_org_users_by_other_frequency;

#
# Create a lookup table from the all_users table for later lookup of org and group by matching the userid to other tables

user_lookup <- select(all_users, userid, org, group);

#
# Set the column types and drop the useless columns in our tables (change from data.frame to data.table if not already done earlier)
# Also add org and group columns to each with lookups
#
#	FIREFOX BUGS
#

firefox_bugs$reporter_org <- user_lookup[match(firefox_bugs$reporter, user_lookup$userid), org];
firefox_bugs$reporter_group <- user_lookup[match(firefox_bugs$reporter, user_lookup$userid), group];
firefox_bugs$assigned_to_org <- user_lookup[match(firefox_bugs$assigned_to, user_lookup$userid), org];
firefox_bugs$assigned_to_group <- user_lookup[match(firefox_bugs$assigned_to, user_lookup$userid), group];

firefox_bugs <- transform(firefox_bugs, bug_id=as.factor(bug_id), assigned_to=as.factor(assigned_to), bug_severity=as.factor(bug_severity), bug_status=as.factor(bug_status), 
						reporter=as.factor(reporter), resolution=as.factor(resolution), qa_contact=as.factor(qa_contact), votes=as.numeric(votes), 
						everconfirmed=as.logical(everconfirmed), component_id=as.factor(component_id), 
						reporter_org=as.factor(reporter_org), reporter_group=as.factor(reporter_group), assigned_to_org=as.factor(assigned_to_org),
						assigned_to_group=as.factor(assigned_to_group));

firefox_bugs <- firefox_bugs[order(reporter_org, reporter_group, creation_ts),c("bug_id", "creation_ts", "reporter", "reporter_org", "reporter_group", "bug_status", "resolution", 
							   "bug_severity", "votes", "assigned_to", "assigned_to_org", "assigned_to_group", "delta_ts", "short_desc",
							   "priority", "qa_contact", "everconfirmed", "component_id"), with=F];

#
#	FIREFOX activity
#

firefox_activity <- as.data.table(firefox_activity);		

firefox_activity$org <- user_lookup[match(firefox_activity$who, user_lookup$userid), org];
firefox_activity$group <- user_lookup[match(firefox_activity$who, user_lookup$userid), group];
					   
firefox_activity <- transform(firefox_activity, bug_id=as.factor(bug_id), bug_when=as.Date(bug_when), fieldid=as.factor(fieldid), attach_id=as.factor(attach_id),
												who=as.factor(who), org=as.factor(org), group=as.factor(group));							   
firefox_activity <- firefox_activity[order(org, group, bug_when), c('bug_id', 'bug_when', 'who', 'org', 'group', 'fieldid', 'removed', 'added', 'attach_id'), with=F];

#
#	FIREFOX CC
#

firefox_cc <- as.data.table(firefox_cc);

firefox_cc$org <- user_lookup[match(firefox_cc$who, user_lookup$userid), org];
firefox_cc$group <- user_lookup[match(firefox_cc$who, user_lookup$userid), group];

firefox_cc <- transform(firefox_cc, bug_id=as.factor(bug_id), who=as.factor(who), org=as.factor(org), group=as.factor(group));
firefox_cc <- firefox_cc[order(org, group), c('bug_id', 'who', 'org', 'group'), with=F];

#
#	FIREFOX ATTACHMENTS
#

firefox_attachments <- as.data.table(firefox_attachments);

firefox_attachments$org <- user_lookup[match(firefox_attachments$submitter_id, user_lookup$userid), org];
firefox_attachments$group <- user_lookup[match(firefox_attachments$submitter_id, user_lookup$userid), group];

firefox_attachments <- transform(firefox_attachments, bug_id=as.factor(bug_id), creation_ts=as.Date(creation_ts), submitter_id=as.factor(submitter_id), ispatch=as.logical(ispatch),
						  attach_id=as.factor(attach_id), mimetype=as.factor(mimetype), modification_time=as.Date(modification_time),
						  org=as.factor(org), group=as.factor(group));
firefox_attachments <- firefox_attachments[order(org, group, creation_ts), c('bug_id', 'creation_ts', 'submitter_id', 'org', 'group', 'ispatch', 'attach_id', 'mimetype', 'modification_time'), with=F];

#
#	FIREFOX LONGDESCS
#

firefox_longdescs <- as.data.table(firefox_longdescs);

firefox_longdescs$org <- user_lookup[match(firefox_longdescs$who, user_lookup$userid), org];
firefox_longdescs$group <- user_lookup[match(firefox_longdescs$who, user_lookup$userid), group];

firefox_longdescs <- transform(firefox_longdescs, bug_id=as.factor(bug_id), bug_when=as.Date(bug_when), who=as.factor(who), comment_id=as.factor(comment_id), type=as.factor(type), 
												  extra_data=as.factor(extra_data), org=as.factor(org), group=as.factor(group));
firefox_longdescs <- firefox_longdescs[order(org, group), c('bug_id', 'bug_when', 'who', 'org', 'group', 'comment_id', 'type', 'extra_data', 'thetext'), with=F]; 

#
#	FIREFOX VOTES
#

firefox_votes <- as.data.table(firefox_votes);

firefox_votes$org <- user_lookup[match(firefox_votes$who, user_lookup$userid), org];
firefox_votes$group <- user_lookup[match(firefox_votes$who, user_lookup$userid), group];

firefox_votes <- transform(firefox_votes, bug_id=as.factor(bug_id), who=as.factor(who), org=as.factor(org), group=as.factor(group));
firefox_votes <- firefox_votes[order(org, group), c('bug_id', 'who', 'org', 'group'), with=F];

#
#	USER WATCHING
#

all_watch <- as.data.table(all_watch);

all_watch$watcher_org <- user_lookup[match(all_watch$watcher, user_lookup$userid), org];
all_watch$watcher_group <- user_lookup[match(all_watch$watcher, user_lookup$userid), group];
all_watch$watched_org <- user_lookup[match(all_watch$watched, user_lookup$userid), org];
all_watch$watched_group <- user_lookup[match(all_watch$watched, user_lookup$userid), group];

all_watch <- transform(all_watch, watcher=as.factor(watcher), watched=as.factor(watched), 
					   watcher_org=as.factor(watcher_org), watcher_group=as.factor(watcher_group),
					   watched_org=as.factor(watched_org), watched_group=as.factor(watched_group));
					   
all_watch <- all_watch[, c('watcher', 'watcher_org', 'watcher_group', 'watched', 'watched_org', 'watched_group'), with=F];


#
# SUMMARY OF USEFUL VARIABLES
#
# Now that we've created all the variables and subsets that we need, before we go on to interpreting and 
# graphing the data, here's a list of the useful variables that we'll use:
#
#    USERS:
# 
# all_users: This data.frame contains all the fields of the 2636 users who are part of the 1401 identified Canadian Organizations 
# Important columns: userid, org, group, creation_ts, comment_count
# 
# university_users: University subset of all with same columns
#
# college_users: College subset of all with same columns
#
# higher_ed_users: Higher education = Universities+Colleges subset of all with same columns
#
# fed_gov_users: Federal government subset of all with same columns
#
# other_users: Other (none of the above) subset of all with same columns
#
# [all|university|college|higher_ed|fed_gov|other]_users_freq: The table with name of org and count of users for each org in each of those groupings
# Sorted by most frequent
# Columns: org: name of org in grouping; Freq: count for that org
#
# all_watch: List of Canadian organization users who are either watching or watched by another Bugzilla user (whether or not Canadian org user)
# Important columns: watcher, watcher_org, watcher_group, watched, watched_org, watched_group
#
#    TABLES:
#
# firefox_bugs : All the Firefox-related bugs in Bugzilla
# Important columns: reporter, gbug_id, assigned_to, bug_severity, bug_status, creation_ts, delta_ts,
#					 priority, short_desc, reporter, resolution, qa_contact, votes, everconfirmed, component_id
#				     reporter_org, reporter_group, assigned_to_org, assigned_to_group
#
# firefox_activity: All the activities related to Firefox bugs in Bugzilla
# Important columns: bug_id, who, bug_when, fieldid, removed, added, attach_id
#					 org, group
#
# firefox_cc: List of Firefox-related bugs for which people want to receive change notifications
# Important columns: bug_id, who, org, group
#
# firefox_attachments: Attachments to Firefox-related bugs
# Important columns: attach_id, bug_id, creation_ts, mimetype, ispatch, submitter_id, modification_time
#					 org, group
#
# firefox_longdescs: List of each of the comments for Firefox-related bugs, often multiple comments per bug
# Important columns: bug_id, who, bug_when, thetext, comment_id, type, extra_data
#				     org, group
#
# firefox_votes:  Tracking of votes cast for Firefox-related bugs
# Important columns: who, bug_id, org, group
#						
#
# GRAPH VIEWS OF PROCESSED DATA
#
# We'll need library (ggplot2).  It does a lot of the details for us, whereas library(gplots) and its functions require a lot more effort:

library(ggplot2);

# We'll set it as a function for now to not constantly run it
plot <- function (){

# Bar plot of the frequencies of all Canadian organization users:
#
# Since there are so many users, we're going to limit to the first 150 just to be able to see

ncol <- 150;

# Set pretty colors:

colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];		

all_users_freq_plot <-qplot(factor(all_users_freq$org, levels = all_users_freq$org[order(-all_users_freq$Freq)]), all_users_freq$Freq, geom="bar", stat="identity", fill=all_users_freq$org,
				xlab = "Canadian Organizations", ylab = "Number of Users", main  = "Frequencies of Mozilla Bugzilla Users Amongst Canadian Organizations");

all_users_freq_plot + theme(axis.text.x = element_text(angle=90, hjust = 1, vjust=0.5), legend.position="none") +
					  scale_fill_manual(values=colors) +
					  scale_x_discrete(limits=head(all_users_freq$org, ncol));

#
# Bar plot of the frequencies of university users:
#

university_users_freq_plot <- qplot(factor(university_users_freq$org, levels = university_users_freq$org[order(-university_users_freq$Freq)]), university_users_freq$Freq, geom="bar", fill=university_users_freq$org, stat="identity", 
				xlab = "Universities", ylab = "Number of Users", main  = "Frequencies of Mozilla Bugzilla Users mongst Canadian Universities");

university_users_freq_plot + theme(axis.text.x = element_text(angle=90, hjust = 1)) + scale_fill_discrete(name="Universities") + guides(fill=guide_legend(ncol=2));

#
# Bar plot of the frequencies of college users:
#

college_users_freq_plot <- qplot(factor(college_users_freq$org, levels = college_users_freq$org[order(-college_users_freq$Freq)]), college_users_freq$Freq, geom="bar", fill=college_users_freq$org, stat="identity", 
				xlab = "Colleges", ylab = "Number of Users", main  = "Frequencies of Mozilla Bugzilla Users Amongst Canadian Colleges");

college_users_freq_plot + theme(axis.text.x = element_text(angle=90, hjust = 1)) + scale_fill_discrete(name="Colleges");

#
# Bar plot of the frequencies of higher_ed users:
#

higher_ed_users_freq_plot <- qplot(factor(higher_ed_users_freq$org, levels = higher_ed_users_freq$org[order(-higher_ed_users_freq$Freq)]), higher_ed_users_freq$Freq, geom="bar", fill=higher_ed_users_freq$org, stat="identity", 
				xlab = "Higher Education Institutions", ylab = "Number of Users", main  = "Frequencies of Mozilla Bugzilla  Users Amongst Canadian Higher Education Institutions");

higher_ed_users_freq_plot + theme(axis.text.x = element_text(angle=90, hjust = 1))  + scale_fill_discrete(name="Higher Education Institutions") + guides(fill=guide_legend(ncol=2));

#
# Bar plot of the frequencies of federal government users:
#

fed_gov_users_freq_plot <- qplot(factor(fed_gov_users_freq$org, levels = fed_gov_users_freq$org[order(-fed_gov_users_freq$Freq)]), fed_gov_users_freq$Freq, 
								geom="bar", fill=fed_gov_users_freq$org, stat="identity", 
								xlab = "Federal Government Departments", ylab = "Number of Users", main  = "Frequencies of Mozilla Bugzilla  Users Amongst Canadian Federal Government Departments");

fed_gov_users_freq_plot + theme(axis.text.x = element_text(angle=90, hjust = 1))  + scale_fill_discrete(name="Federal Government Departments");


#
# Bar plot of the frequencies of users in the top 50 orgs grouped as "other"
#

# Choose which users we want to include: In this case, the 50 with the most users each (out of 1401, most of whom have 1 or 2)

x <- subset(other_users, org %in% head(other_users_freq$org, n=50)) 

# create the qplot variable, using organization for x axis, automatically counting the orgs and putting them in "bins", in a "bar" graph, and creating colours based on the different "orgs"

other_users_freq_plot <- qplot(x$org, stat="bin", geom="bar", fill=x$org, 
							   main  = "Frequencies of Mozilla Bugzilla Users Amongst Other Canadian Organizations"); 

# Now we execute the variable to do the plot, and use the "+" notation to add layers:

other_users_freq_plot + theme(axis.text.x = element_text(angle=90, hjust = 1)) + # St the x-axis organization names to be vertical for better spacing
					    guides(fill=guide_legend(ncol=2)) + # Make the legend have 2 columns instead of one
						scale_fill_discrete(name="Groupings") + # Set the title of the legend
					    scale_y_continuous("Number of Users", limits=c(0, 9), breaks=seq(0, 10, 1)) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
						scale_x_discrete("Other Organizations") + # Set the x-axis title
					    stat_bin(geom="text", aes(label=..count.., vjust=-1, ymax=max(..count..)+0.5)); # Put the count labels at the top of the bars for better visibility
#
# 	END Bar plot of frequency of users in the top 50 orgs grouped as "other"
#
						

#
# Bar plot of the frequencies of groupings of users:
#
# Create the frequency table first (naming the first column "group"):

grouped_users_freq <- dplyr::rename(arrange(as.data.frame(table(all_users$group)), -Freq), group = Var1);

grouped_users_freq_plot <- qplot(factor(grouped_users_freq$group, levels=c("university", "college", "fed_gov", "other")), grouped_users_freq$Freq,
								geom="bar", fill=grouped_users_freq$group, stat="identity",
								xlab="Groupings of users", ylab="Number of Users", main="Frequencies of Mozilla Bugzilla Users for Each Group");

grouped_users_freq_plot + scale_fill_discrete(name="Groupings");								
								
								
#
# Let's plot all the bug reports by the orgs in each grouping
#
# Set the values we need in all our tables			

plot_table <- subset(firefox_bugs, firefox_bugs$reporter_group %in% c("university", "college", "fed_gov")); 

firefox_bugs_groups_plot <- ggplot(data=plot_table, aes(x=reporter_group, fill=factor(reporter_org)), color=reporter_org,
									main="Distribution of Firefox Bug Submissions Amongst Higher Education Institutions and Canadian Federal Government Departments");

# Create some pretty colors:

col.par = function(n) sample(seq(0.3, 1, length.out=50),n); 
#colors = rainbow(41, s=col.par(41), v=col.par(41))[sample(1:41,41)]

colors = rainbow(41, s=.6, v=.9)[sample(1:41, 41)];								
									
firefox_bugs_groups_plot + 	#scale_fill_discrete(name="Canadian Organizations") + # Set the title of the legend
							scale_fill_manual(name="Canadian organizations", values=colors) +
							scale_y_continuous("Number of Firefox Bugs Submitted", limits=c(0, 140), breaks=seq(0, 150, 5)) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
							scale_x_discrete("Groups of Canadian Organizations") + # Set the x-axis title
							geom_bar(stat="bin", position="stack", label=plot_table$reporter_org) +
							ggtitle("Distribution of Firefox Bug Submissions Amongst Higher Education Institutions and Canadian Federal Government Departments");
							

# Let's see if we can add OTHER without breaking stuff

# Set the values we need in all our table: orgs, groups, frequencies, and vertical location for overlay
# Exclude orgs who submitted no bugs

plot_table <- subset(firefox_bugs, firefox_bugs$reporter_group %in% c("university", "college", "fed_gov", "other")); 
org_frequencies <- dplyr::count(plot_table, reporter_org);
org_frequencies <- subset(org_frequencies, n>0);
org_frequencies$reporter_group <- user_lookup[match(org_frequencies$reporter_org, user_lookup$org), group];
org_frequencies <- plyr::ddply(org_frequencies, .(reporter_group), transform, position = cumsum(n) - (0.5 * n));

# Create some pretty colors:

colors = rainbow(240, s=.6, v=.9)[sample(1:240, 240)];		

# Create the base ggplot

firefox_bugs_groups_plot <- ggplot(data=org_frequencies, aes(x=reporter_group, y=n));
									
						
# Plot and add layers		
				
firefox_bugs_groups_plot + 	scale_fill_manual(guide=FALSE, values=colors) +
							scale_y_continuous("Number of Firefox Bugs Submitted", limits=c(0, 400), breaks=seq(0, 400, 5), oob=rescale_none) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
							scale_x_discrete("Groups of Canadian Organizations") + # Set the x-axis title
							geom_bar(stat="identity", guide=FALSE, fill=colors, width=0.99) +
							geom_text(data=org_frequencies, aes(label=org_frequencies$reporter_org, y=org_frequencies$n, ymax=max(org_frequencies$n)+1), size = 2, position="stack") +
							ggtitle("Distribution of Firefox Bug Submissions Amongst Groups of Canadian Organizations");
#
# END plot of bug reports by orgs in each grouping
#							
#	
#
#	BUG PLOTS OVER TIME
#
# Number of BUGS reported by each UNIVERSITY per year
#
# Prepare our able with the data we want to graph
# Create a blank table

org_year_bugs <- data.table();

# Select just Firefox bugs for group "university" and lop over the years, using dplyr::count to return reporter, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in 2002:2012) {
	org_year_bugs <- rbind(org_year_bugs, dplyr::count(Subset(firefox_bugs, reporter_group=="university" & year(creation_ts) == years), reporter_org, year(creation_ts)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_bugs, "year(creation_ts)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_bugs) + 1;

col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent

colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_bugs_plot  <- ggplot(data=org_year_bugs, aes(x=year, y=n, fill=reporter_org), color=reporter_org);
									 								 
# Plot and add layers

org_year_bugs_plot +  scale_fill_manual(name="Universities", values=colors) +
					  scale_y_continuous("Number of Firefox Bugs Submitted", limits=c(0, max(org_year_bugs$n)+0.5), breaks=seq(0, max(org_year_bugs$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(2002-0.5, 2012+0.5), breaks=seq(2002, 2012, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=1) +
					  geom_text(data=org_year_bugs, aes(x=org_year_bugs$year, y=org_year_bugs$n, ymax=max(org_year_bugs$n), label=org_year_bugs$reporter_org), position=position_dodge(width=0.9), angle=90) +
					  ggtitle("Number of Firefox Bugs Reported per University from 2002 to 2012");

# END Number of BUGS reported by each UNIVERSITY per year
#
# Number of BUGS reported by each COLLEGE per year
#
# Prepare our able with the data we want to graph
# Create a blank table

org_year_bugs <- data.table();

# Subset to allow us to find the year range:

year_range <- Subset(firefox_bugs, reporter_group=="college");
year_min <- year(min(year_range$creation_ts));
year_max <- year(max(year_range$creation_ts));

# Select just Firefox bugs for group "college" and lop over the years, using dplyr::count to return reporter, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_bugs <- rbind(org_year_bugs, dplyr::count(Subset(firefox_bugs, reporter_group=="college" & year(creation_ts) == years), reporter_org, year(creation_ts)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_bugs, "year(creation_ts)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_bugs) + 1;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_bugs_plot  <- ggplot(data=org_year_bugs, aes(x=year, y=n, fill=reporter_org), color=reporter_org);
									 
# Plot and add layers

org_year_bugs_plot +  scale_fill_manual(name="Colleges", values=colors) +
					  scale_y_continuous("Number of Firefox Bugs Submitted", limits=c(0, max(org_year_bugs$n)+0.5), breaks=seq(0, max(org_year_bugs$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.9) +
					  geom_text(data=org_year_bugs, aes(x=org_year_bugs$year, y=org_year_bugs$n, ymax=max(org_year_bugs$n), label=org_year_bugs$reporter_org), position=position_dodge(width=0.9), angle=90) +
					  ggtitle(label=paste("Number of Firefox Bugs Reported per Colleges from ", year_min, " to ", year_max));

# END Number of BUGS reported by each COLLEGE per year
#
#			
# Number of BUGS reported by each HIGHER_ED institution per year
#
# Prepare our able with the data we want to graph
# Create/reset a blank table

org_year_bugs <- data.table();

# Subset to allow us to find the year range:

year_range <- Subset(firefox_bugs, reporter_group=="college" | reporter_group=="university");
year_min <- year(min(year_range$creation_ts));
year_max <- year(max(year_range$creation_ts));

# Select just Firefox bugs for groups "college" or "university" and lop over the years, using dplyr::count to return reporter, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_bugs <- rbind(org_year_bugs, dplyr::count(Subset(firefox_bugs, reporter_group=="college" | reporter_group=="university" & year(creation_ts) == years), reporter_org, year(creation_ts)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_bugs, "year(creation_ts)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_bugs) + 1;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_bugs_plot  <- ggplot(data=org_year_bugs, aes(x=year, y=n, fill=reporter_org), color=reporter_org);
									 
# Plot and add layers

org_year_bugs_plot +  scale_fill_manual(name="Higher Education Institutions", values=colors) +
					  scale_y_continuous("Number of Firefox Bugs Submitted", limits=c(0, max(org_year_bugs$n)+0.5), breaks=seq(0, max(org_year_bugs$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.9) +
					  geom_text(data=org_year_bugs, aes(x=org_year_bugs$year, y=org_year_bugs$n, ymax=max(org_year_bugs$n), label=org_year_bugs$reporter_org), position=position_dodge(width=0.9), angle=90) +
					  ggtitle(label=paste("Number of Firefox Bugs Reported per Canadian Higher Education Institution from ", year_min, " to ", year_max));

# END Number of BUGS reported by each HIGHER_ED institution per year
#
#
# Number of BUGS reported by each OTHER organizations per year
#
# Prepare our able with the data we want to graph
# Create a blank table

org_year_bugs <- data.table();

# Subset to allow us to find the year range:

year_range <- Subset(firefox_bugs, reporter_group=="other");
year_min <- year(min(year_range$creation_ts));
year_max <- year(max(year_range$creation_ts));

# Select just Firefox bugs for group "other" and lop over the years, using dplyr::count to return reporter, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_bugs <- rbind(org_year_bugs, dplyr::count(Subset(firefox_bugs, reporter_group=="other" & year(creation_ts) == years), reporter_org, year(creation_ts)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_bugs, "year(creation_ts)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_bugs) + 1;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)]; 			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_bugs_plot  <- ggplot(data=org_year_bugs, aes(x=year, y=n, fill=reporter_org), color=reporter_org);
									 
# Plot and add layers

org_year_bugs_plot +  scale_fill_manual(guide=FALSE, values=colors) +
					  scale_y_continuous("Number of Firefox Bugs Submitted", limits=c(0, max(org_year_bugs$n)+0.5), breaks=seq(0, max(org_year_bugs$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.9) +
					  geom_text(data=org_year_bugs, aes(x=org_year_bugs$year, y=org_year_bugs$n, ymax=max(org_year_bugs$n), label=org_year_bugs$reporter_org), position=position_dodge(width=0.9), angle=90, size=3) +
					  ggtitle(label=paste("Number of Firefox Bugs Reported per Other Organizations from ", year_min, " to ", year_max));

# END Number of BUGS reported by each OTHER per year
#
#
# Number of BUGS reported by each FEDERAL GOVERNMENT per year
#
# Prepare our able with the data we want to graph
# Create a blank table

org_year_bugs <- data.table();

# Subset to allow us to find the year range:

year_range <- Subset(firefox_bugs, reporter_group=="fed_gov");
year_min <- year(min(year_range$creation_ts));
year_max <- year(max(year_range$creation_ts));

# Select just Firefox bugs for group "other" and lop over the years, using dplyr::count to return reporter, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_bugs <- rbind(org_year_bugs, dplyr::count(Subset(firefox_bugs, reporter_group=="fed_gov" & year(creation_ts) == years), reporter_org, year(creation_ts)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_bugs, "year(creation_ts)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_bugs) + 1;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_bugs_plot  <- ggplot(data=org_year_bugs, aes(x=year, y=n, fill=reporter_org), color=reporter_org);
									 
# Plot and add layers

org_year_bugs_plot +  scale_fill_manual(name="Federal Government Department", values=colors) +
					  scale_y_continuous("Number of Firefox Bugs Submitted", limits=c(0, max(org_year_bugs$n)+0.5), breaks=seq(0, max(org_year_bugs$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.9) +
					  geom_text(data=org_year_bugs, aes(x=org_year_bugs$year, y=org_year_bugs$n, ymax=max(org_year_bugs$n), label=org_year_bugs$reporter_org), position=position_dodge(width=0.9), angle=90) +
					  ggtitle(label=paste("Number of Firefox Bugs Reported per Canadian Federal Government Department from ", year_min, " to ", year_max));

# END Number of bugs reported by each Federal Government Department per year
#
#	CC PLOT (NO TIME)
#
# Number of CC of firefox_bugs by ALL orgs organized into group:
#
# Set the values we need in all our table: orgs, groups, frequencies, and vertical location for overlay
# Exclude orgs who have no CCs

plot_table <- NA;

plot_table <- Subset(firefox_cc, firefox_cc$group %in% c("university", "college", "fed_gov", "other")); 
cc_frequencies <- dplyr::count(plot_table, org);
cc_frequencies <- Subset(cc_frequencies, n>0);
cc_frequencies$group <- user_lookup[match(cc_frequencies$org, user_lookup$org), group];
cc_frequencies <- plyr::ddply(cc_frequencies, .(group), transform, position = cumsum(n) - (0.5 * n));

# Create some pretty colors:

ncolors <- nrow(cc_frequencies);
colors = rainbow(ncolors, s=.6, v=.9)[sample(1:ncolors, ncolors)];		

# Create the base ggplot;

firefox_ccs_groups_plot <- ggplot(data=cc_frequencies, aes(x=group, y=n, fill=org), color=org);
								

# Plot and add layers		
				
firefox_ccs_groups_plot + 	scale_fill_manual(guide=FALSE, values=colors) +
							scale_y_continuous("Number of Firefox Bug Follows (CCs)", limits=c(0, 100), breaks=seq(0, 100, 10), oob=rescale_none) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
							scale_x_discrete("Groups of Canadian Organizations") + # Set the x-axis title
							geom_bar(stat="identity", position="dodge", width=0.99) +
							geom_text(data=cc_frequencies, aes(label=cc_frequencies$org, y=cc_frequencies$n, ymax=max(cc_frequencies$n)), size = 3, position=position_dodge(width=0.99), angle=90) +
							ggtitle(label="Number of Firefox Bugs Followed by Canadian Organizations per Group");
							
#
# END number of CC of firefox_bugs by ALL ogs organized into groups
#
# Number of CC of firefox_bugs by HIGHER_ED organizations:
#

plot_table <- NA;

plot_table <- Subset(firefox_cc, firefox_cc$group %in% c("university", "college")); 
cc_frequencies <- dplyr::count(plot_table, org);
cc_frequencies$group <- user_lookup[match(cc_frequencies$org, user_lookup$org), group];

# Create some pretty colors:

ncolors <- nrow(cc_frequencies);
colors = rainbow(ncolors, s=.6, v=.9)[sample(1:ncolors, ncolors)];		

# Create the base ggplot;

firefox_ccs_higher_ed_plot <- ggplot(data=cc_frequencies, aes(x=org, y=n, fill=org), color=org);
								

# Plot and add layers		
				
firefox_ccs_higher_ed_plot + 	scale_fill_manual(name="Canadian Organizations", values=colors) +
								scale_y_continuous("Number of Firefox Bug Follows (CCs)", limits=c(0, max(cc_frequencies$n)+0.5), breaks=seq(0, max(cc_frequencies$n)+0.5, 10), oob=rescale_none) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
								scale_x_discrete("Higher Education Organizations", labels="") + # Set the x-axis title
								geom_bar(stat="identity", position="dodge", width=0.9) +
								geom_text(data=cc_frequencies, aes(label=cc_frequencies$org, y=cc_frequencies$n, ymax=max(cc_frequencies$n)), size = 4, position=position_dodge(width=0.9), angle=90) +
								ggtitle(label="Number of Firefox Bugs Followed by Canadian Higher Education Organizations");
							
#
# END number of CC of firefox_bugs by HIGHER_ED organizations
#
#
# Number of CC of firefox_bugs by OTHER organizations:
#

plot_table <- NA;

plot_table <- Subset(firefox_cc, firefox_cc$group == "other"); 
cc_frequencies <- dplyr::count(plot_table, org);
cc_frequencies$group <- user_lookup[match(cc_frequencies$org, user_lookup$org), group];

# Create some pretty colors:

ncolors <- nrow(cc_frequencies);
colors = rainbow(ncolors, s=.6, v=.9)[sample(1:ncolors, ncolors)];		

# Create the base ggplot;

firefox_ccs_other_plot <- ggplot(data=cc_frequencies, aes(x=org, y=n, fill=org), color=org);
								

# Plot and add layers		
				
firefox_ccs_other_plot + 	scale_fill_manual(name="Canadian Organizations", values=colors) +
								scale_y_continuous("Number of Firefox Bug Follows (CCs)", limits=c(0, max(cc_frequencies$n)+1), breaks=seq(0, max(cc_frequencies$n), 10), oob=rescale_none) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
								scale_x_discrete("Other Organizations", labels="") + # Set the x-axis title
								geom_bar(stat="identity", position="dodge", width=0.99) +
								geom_text(data=cc_frequencies, aes(label=cc_frequencies$org, y=cc_frequencies$n, ymax=max(cc_frequencies$n)), size = 4, position=position_dodge(width=0.99), angle=90) +
								ggtitle(label="Number of Firefox Bugs Followed by Other Organizations") +
								guides(fill=guide_legend(ncol=2, size=1));
							
#
# END number of CC of firefox_bugs by OTHER organizations
#
#

#	VOTES PLOT (NO TIME)
#
# Number of VOTES for firefox_bugs by ALL orgs organized into group:
#
# Set the values we need in all our table: orgs, groups, frequencies, and vertical location for overlay
# Exclude orgs who have no VOTESs

plot_table <- NA;

plot_table <- Subset(firefox_votes, firefox_votes$group %in% c("university", "college", "fed_gov", "other")); 
votes_frequencies <- dplyr::count(plot_table, org);
votes_frequencies <- Subset(votes_frequencies, n>0);
votes_frequencies$group <- user_lookup[match(votes_frequencies$org, user_lookup$org), group];
votes_frequencies <- plyr::ddply(votes_frequencies, .(group), transform, position = cumsum(n) - (0.5 * n));

# Create some pretty colors:

ncolors <- nrow(votes_frequencies);
colors = rainbow(ncolors, s=.6, v=.9)[sample(1:ncolors, ncolors)];		

# Create the base ggplot;

firefox_votes_groups_plot <- ggplot(data=votes_frequencies, aes(x=group, y=n, fill=org), color=org);
								
# Plot and add layers		
				
firefox_votes_groups_plot + scale_fill_manual(guide=FALSE, values=colors) +
							scale_y_continuous("Number of Firefox Bug Votes", limits=c(0, max(votes_frequencies$n)+0.5), breaks=seq(0, max(votes_frequencies$n)+0.5, 1), oob=rescale_none) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
							scale_x_discrete("Groups of Canadian Organizations") + # Set the x-axis title
							geom_bar(stat="identity", position="dodge", width=0.99) +
							geom_text(data=votes_frequencies, aes(label=votes_frequencies$org, y=votes_frequencies$n, ymax=max(votes_frequencies$n)), size = 3, position=position_dodge(width=0.99), angle=90) +
							ggtitle(label="Number of Firefox Bugs Voted for by Canadian Organizations per Group");
							
#
# END number of VOTES for firefox_bugs by ALL ogs organized into groups
#
# Number of VOTES for firefox_bugs by HIGHER_ED organizations into groups
#

plot_table <- NA;

plot_table <- Subset(firefox_votes, firefox_votes$group %in% c("university", "college")); 
votes_frequencies <- dplyr::count(plot_table, org);
votes_frequencies$group <- user_lookup[match(votes_frequencies$org, user_lookup$org), group];

# Create some pretty colors:

ncolors <- nrow(votes_frequencies);
colors = rainbow(ncolors, s=.6, v=.9)[sample(1:ncolors, ncolors)];		

# Create the base ggplot;

firefox_votess_higher_ed_plot <- ggplot(data=votes_frequencies, aes(x=org, y=n, fill=org), color=org);
								

# Plot and add layers		
				
firefox_votess_higher_ed_plot + 	scale_fill_manual(name="Higher Education Organizations", values=colors) +
								scale_y_continuous("Number of Votes for Firefox Bug", limits=c(0, max(votes_frequencies$n)+0.5), breaks=seq(0, max(votes_frequencies$n)+0.5, 1), oob=rescale_none) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
								scale_x_discrete("Higher Education Organizations", labels="") + # Set the x-axis title
								geom_bar(stat="identity", position="dodge", width=0.99) +
								geom_text(data=votes_frequencies, aes(label=votes_frequencies$org, y=votes_frequencies$n, ymax=max(votes_frequencies$n)), size = 6, position=position_dodge(width=0.99), angle=90) +
								ggtitle(label="Number of Votes for Firefox Bugs by Higher Education Organizations");
							
#
# END number of VOTES for firefox_bugs by HIGHER_ED organizations
#
# Number of VOTES for firefox_bugs by FED_GOV departments:
#

plot_table <- NA;

plot_table <- Subset(firefox_votes, firefox_votes$group == "fed_gov"); 
votes_frequencies <- dplyr::count(plot_table, org);
votes_frequencies$group <- user_lookup[match(votes_frequencies$org, user_lookup$org), group];

# Create some pretty colors:

ncolors <- nrow(votes_frequencies)*10;
colors = rainbow(ncolors, s=.6, v=.9)[sample(1:ncolors, ncolors)];		

# Create the base ggplot;

firefox_votess_other_plot <- ggplot(data=votes_frequencies, aes(x=org, y=n, fill=org), color=org);
								

# Plot and add layers		
				
firefox_votess_other_plot + 	scale_fill_manual(name="Federal Government Departments", values=colors) +
								scale_y_continuous("Number of Votes for Firefox Bug", limits=c(0, max(votes_frequencies$n)+0.5), breaks=seq(0, max(votes_frequencies$n)+0.5, 1), oob=rescale_none) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
								scale_x_discrete("Federal Government Departments", labels="") + # Set the x-axis title
								geom_bar(stat="identity", position="dodge", width=0.95) +
								geom_text(data=votes_frequencies, aes(label=votes_frequencies$org, y=votes_frequencies$n, ymax=max(votes_frequencies$n)), size = 4, position=position_dodge(width=0.95), vjust=3) +
								ggtitle(label="Number of Votes for Firefox Bugs by Federal Government Departments");
							
#
# END number of VOTES for firefox_bugs by FED_GOV departments:
#
#
# Number of VOTES for firefox_bugs by OTHER organizations:
#

plot_table <- NA;

plot_table <- Subset(firefox_votes, firefox_votes$group == "other"); 
votes_frequencies <- dplyr::count(plot_table, org);
votes_frequencies$group <- user_lookup[match(votes_frequencies$org, user_lookup$org), group];

# Create some pretty colors:

ncolors <- nrow(votes_frequencies)*10;
colors = rainbow(ncolors, s=.6, v=.9)[sample(1:ncolors, ncolors)];		

# Create the base ggplot;

firefox_votess_other_plot <- ggplot(data=votes_frequencies, aes(x=org, y=n, fill=org), color=org);
								

# Plot and add layers		
				
firefox_votess_other_plot + 	scale_fill_manual(name="Canadian Organizations", values=colors) +
								scale_y_continuous("Number of Votes for Firefox Bug", limits=c(0, 10), breaks=seq(0,10, 1), oob=rescale_none) + # Set the y-axis title, range (limits) of the y axis and the number and spacing of intervals
								scale_x_discrete("Other Organizations", labels="") + # Set the x-axis title
								geom_bar(stat="identity", position="dodge", width=0.99) +
								geom_text(data=votes_frequencies, aes(label=votes_frequencies$org, y=votes_frequencies$n, ymax=max(votes_frequencies$n)), size = 4, position=position_dodge(width=0.99), angle=90) +
								ggtitle(label="Number of Votes for Firefox Bugs by Other Canadian Organizations") +
								guides(fill=guide_legend(ncol=2, size=1));
							
#
# END number of VOTES for firefox_bugs by OTHER organizations
#
#
# 	ACTIVITIES PER YEAR
#
# Number of ACTIVITIES done by each UNIVERSITY per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group <- "university";
plot_table <- firefox_activity
grouping_name <- "Universities";
y_axis_label <- "Number of Activities on Firefox-related Bugs";
main_label <- "Number of Activities Done on Firefox-related Bugs by Universities from ";

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group==target_group);
year_min <- year(min(year_range$bug_when));
year_max <- year(max(year_range$bug_when));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group & year(bug_when) == years), org, year(bug_when)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(bug_when)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 1;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot +  scale_fill_manual(name=grouping_name, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.9) +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=0.9), angle=90) +
					  ggtitle(label=paste(main_label, year_min, " to ", year_max));

# END Number of ACTIVITIES done by each UNIVERSITY per year
#
#
# Number of ACTIVITIES done by each COLLEGE per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group <- "college";
plot_table <- firefox_activity
grouping_name <- "Colleges";
y_axis_label <- "Number of Activities on Firefox-related Bugs";
main_label <- "Number of Activities Done on Firefox-related Bugs by Colleges from ";

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group==target_group);
year_min <- year(min(year_range$bug_when));
year_max <- year(max(year_range$bug_when));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group & year(bug_when) == years), org, year(bug_when)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(bug_when)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 1;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot +  scale_fill_manual(name=grouping_name, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.9) +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=0.9), angle=90) +
					  ggtitle(label=paste(main_label, year_min, " to ", year_max));

# END Number of ACTIVITIES done by each COLLEGES per year
#
#
# Number of ACTIVITIES done by each HIGHER_ED institution per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group1 <- "college";
target_group2 <- "university"
plot_table <- firefox_activity
grouping_name <- "Higher Education Institutions";
y_axis_label <- "Number of Activities on Firefox-related Bugs";
main_label <- "Number of Activities Done on Firefox-related Bugs by Higher Education Institutions from ";

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group==target_group1 | group==target_group2);
year_min <- year(min(year_range$bug_when));
year_max <- year(max(year_range$bug_when));

# Select just Firefox "plot_table" for group "target_group1" or group "target_group2" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group1 | group==target_group2 & year(bug_when) == years), org, year(bug_when)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(bug_when)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 1;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot +  scale_fill_manual(name=grouping_name, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.9) +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=0.9), angle=90) +
					  ggtitle(label=paste(main_label, year_min, " to ", year_max));

# END Number of ACTIVITIES done by each HIGHER_ED institution per year
#
#
# Number of ACTIVITIES done by each FED_GOV department per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group <- "fed_gov";
plot_table <- firefox_activity
grouping_name <- "Canadian Federal Government Departments";
y_axis_label <- "Number of Activities Done on Firefox-related Bugs";
main_label <- paste(y_axis_label, "by", grouping_name, "from");

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group==target_group);
year_min <- year(min(year_range$bug_when));
year_max <- year(max(year_range$bug_when));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group & year(bug_when) == years), org, year(bug_when)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(bug_when)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 10;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot + scale_fill_manual(name=grouping_name, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-1, year_max+1), breaks=seq(year_min-1, year_max+1, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.9) +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=0.9), angle=90) +
					  ggtitle(label=paste(main_label, year_min,  "to", year_max));

# END Number of ACTIVITIES done by each FED_GOV department per year
#
#
# Number of ACTIVITIES done by each OTHER organization per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group <- "other";
plot_table <- firefox_activity
grouping_name <- "Other Canadian Organizations";
y_axis_label <- "Number of Activities Done on Firefox-related Bugs";
main_label <- paste(y_axis_label, "by", grouping_name, "from");

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group==target_group);
year_min <- year(min(year_range$bug_when));
year_max <- year(max(year_range$bug_when));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group & year(bug_when) == years), org, year(bug_when)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(bug_when)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 10;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot + scale_fill_manual(guide=FALSE, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, 200), breaks=seq(0, 200, 10), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge") +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=1), angle=90, size=3) +
					  ggtitle(label=paste(main_label, year_min, "to", year_max));

# END Number of ACTIVITIES done by each OTHER organizations per year
#
#   ATTACHMENTS over TIME
#
# Number of ATTACHMENTS submitted by each all HIGHER_ED organizations per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group1 <- "university";
target_group2 <- "college";
plot_table <- firefox_attachments;
grouping_name <- "Higher Education Organizations";
y_axis_label <- "Number of Attachments Submitted for Firefox-related Bugs";
main_label <- paste(y_axis_label, "by", grouping_name, "from");

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group %in% c(target_group1, target_group2));
year_min <- year(min(year_range$creation_ts));
year_max <- year(max(year_range$creation_ts));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group1 | group==target_group2  & year(creation_ts) == years), org, year(creation_ts)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(creation_ts)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 10;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot + scale_fill_manual(guide=FALSE, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge") +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=1), angle=90, size=3) +
					  ggtitle(label=paste(main_label, year_min, "to", year_max));

# END Number of ATTACHMENTS submitted by by each HIGHER_ED organizations per year


# Number of ATTACHMENTS submitted by each all FED_GOV departments per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group <- "fed_gov";
plot_table <- firefox_attachments;
grouping_name <- "Federal Government Departments";
y_axis_label <- "Number of Attachments Submitted for Firefox-related Bugs";
main_label <- paste(y_axis_label, "by", grouping_name, "from");

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group == target_group);
year_min <- year(min(year_range$creation_ts));
year_max <- year(max(year_range$creation_ts));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group & year(creation_ts) == years), org, year(creation_ts)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(creation_ts)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 10;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot + scale_fill_manual(guide=FALSE, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=1) +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=1), angle=90, size=3) +
					  ggtitle(label=paste(main_label, year_min, "to", year_max));

# END Number of ATTACHMENTS submitted by by each FED_GOV departments per year
#
#
# Number of ATTACHMENTS submitted by each OTHER organization per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group <- "other";
plot_table <- firefox_attachments;
grouping_name <- "Other Canadian Organizations";
y_axis_label <- "Number of Attachments Submitted for Firefox-related Bugs";
main_label <- paste(y_axis_label, "by", grouping_name, "from");

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group == target_group);
year_min <- year(min(year_range$creation_ts));
year_max <- year(max(year_range$creation_ts));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group & year(creation_ts) == years), org, year(creation_ts)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(creation_ts)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 10;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot + scale_fill_manual(guide=FALSE, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=1) +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=1), angle=90, size=5) +
					  ggtitle(label=paste(main_label, year_min, "to", year_max));

# END Number of ATTACHMENTS submitted by by each OTHER organizations per year
#

#   LONGDESCS (COMMENTS) over TIME
#
# Number of LONGDESCS made by each HIGHER_ED organization per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group1 <- "university";
target_group2 <- "college";
plot_table <- firefox_longdescs;
grouping_name <- "Higher Education Organizations";
y_axis_label <- "Number of Comments Made on Firefox-related Bugs";
main_label <- paste(y_axis_label, "by", grouping_name, "from");

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group %in% c(target_group1, target_group2));
year_min <- year(min(year_range$bug_when));
year_max <- year(max(year_range$bug_when));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group1 | group==target_group2  & year(bug_when) == years), org, year(bug_when)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(bug_when)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 10;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot + scale_fill_manual(guide=FALSE, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge") +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=1), angle=90, size=3) +
					  ggtitle(label=paste(main_label, year_min, "to", year_max));

# END Number of LONGDESCS (COMMENTS) made by each HIGHER_ED organization per year


# Number of LONGDESCS (COMMENTS) made by  all FED_GOV departments per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group <- "fed_gov";
plot_table <- firefox_longdescs;
grouping_name <- "Federal Government Departments";
y_axis_label <- "Number of Comments Made on Firefox-related Bugs";
main_label <- paste(y_axis_label, "by", grouping_name, "from");

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group == target_group);
year_min <- year(min(year_range$bug_when));
year_max <- year(max(year_range$bug_when));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group & year(bug_when) == years), org, year(bug_when)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(bug_when)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 10;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot + scale_fill_manual(guide=FALSE, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+0.5), breaks=seq(0, max(org_year_table$n)+0.5, 1), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=1) +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=1), angle=90, size=6) +
					  ggtitle(label=paste(main_label, year_min, "to", year_max));

# END Number of LONGDESCS (COMMENTS) made by each HIGHER_ED organization per year
#
#
# Number of LONGDESCS (COMMENTS) made by each OTHER organization per year
#
# Prepare our able with the data we want to graph
# Create a blank table and set our target group for this section and the table to use:

org_year_table <- data.table();
target_group <- "other";
plot_table <- firefox_longdescs;
grouping_name <- "Other Canadian Organizations";
y_axis_label <- "Number of Comments Made on Firefox-related Bugs";
main_label <- paste(y_axis_label, "by", grouping_name, "from");

# Subset to allow us to find the year range:

year_range <- Subset(plot_table, group == target_group);
year_min <- year(min(year_range$bug_when));
year_max <- year(max(year_range$bug_when));

# Select just Firefox "plot_table" for group "target_group" and loop over the years, using dplyr::count to return org, year, and n beautifully
# Each loop adds the new rows to our variables until the max year
			
for (years in year_min:year_max) {
	org_year_table <- rbind(org_year_table, dplyr::count(Subset(plot_table, group==target_group & year(bug_when) == years), org, year(bug_when)));
}
			
# Change the name of the second column to "year" for simplicity

setnames(org_year_table, "year(bug_when)", "year");						

# Create pretty colors with number required determined by how many data rows we have to display as a result of the above operation

ncol <- nrow(org_year_table) + 10;
col.par <- function(n) sample(seq(0.3, 1, length.out=ncol),n); 
#colors <- rainbow(ncol, s=col.par(ncol), v=col.par(ncol))[sample(1:ncol,ncol)]; # Ensures no two similar colors are adjascent
colors <- rainbow(ncol, s=.6, v=.9)[sample(1:ncol, ncol)];			# Nicer but doesn't deal with adjacent colors as well

# Create base ggplot;

org_year_table_plot  <- ggplot(data=org_year_table, aes(x=year, y=n, fill=org), color=org);
									 
# Plot and add layers

org_year_table_plot + scale_fill_manual(guide=FALSE, values=colors) +
					  scale_y_continuous(y_axis_label, limits=c(0, max(org_year_table$n)+1), breaks=seq(0, max(org_year_table$n), 10), oob=rescale_none) +
					  scale_x_continuous("Year", limits=c(year_min-0.5, year_max+0.5), breaks=seq(year_min, year_max, 1), oob=rescale_none) +
					  geom_bar(stat="identity", position="dodge", width=0.99) +
					  geom_text(data=org_year_table, aes(x=org_year_table$year, y=org_year_table$n, ymax=max(org_year_table$n), label=org_year_table$org), position=position_dodge(width=0.99), angle=90, size=3) +
					  ggtitle(label=paste(main_label, year_min, "to", year_max));

# END Number of LONGDESCS (COMMENTS) made by each OTHER organization per year
#
#

} # End of plot function convenience
#
#
# Looking at who watches who, we see an interesting pattern amongst Canadian users:
#

seneca_to_Mozilla_employee <- as.data.table(all_watch[watcher %in% c("241497", "250232", "393339", "422271") | watched %in% c("241497", "250232", "393339", "422271"), ]);

library(xtable);

seneca_to_Mozilla_employee_xtable <- xtable(seneca_to_Mozilla_employee);
#print.xtable(seneca_to_Mozilla_employee_xtable, type="html", file="seneca_to_Mozilla_employee.html");

# See anotated PDF of HTML output for exlanation of findings
#
#
#
# REGRESSIONS
#
# In order to play with regressions, we need to first add a new variable to our firefox_bugs table
# which has the "outcome" factors with three levels: "fixed", "not_fixed", "pending".
# This new variable will depend on a lookup table of combinations of "bug_status" and "resolution"
# I created the lookup table in a csv file for simplicity in the root folder of the working directory


cleanum <-function () {		#Commented out to not run right now

outcome_lookup <- read.table("outcome_lookup.txt", sep=",", header=TRUE);
outcome_lookup <- as.data.table(outcome_lookup);

# Now we want to use the lookup table to add the "outcome" column to firefox_bugs

setkey(outcome_lookup, bug_status, resolution);
setkey(firefox_bugs, bug_status, resolution);

firefox_bugs <- merge(firefox_bugs, outcome_lookup, by=c('bug_status', 'resolution'), all.x=TRUE);

# Create an additional logical (TRUE/FALSE) variable for "fixed" and [not_fixed|pending] to test logistic regression with a binary dependent variable

logical_outcome_lookup <- read.table("logical_outcome_lookup.txt", sep=",", header=TRUE);
logical_outcome_lookup <- as.data.table(logical_outcome_lookup);

# Now we want to use the lookup table to add the "logical_outcome" column to firefox_bugs

setkey(logical_outcome_lookup, bug_status, resolution);
setkey(firefox_bugs, bug_status, resolution);

firefox_bugs <- merge(firefox_bugs, logical_outcome_lookup, by=c('bug_status', 'resolution'), all.x=TRUE);

# Next let's calculate the amount of time it takes to get a bug fixed from creation_ts and add that to
# our firefox_bugs data table

firefox_bugs <- read.csv("firefox_bugs_with_logical_outcome.csv");
firefox_bugs <- as.data.table(firefox_bugs);

firefox_activity <- read.csv("firefox_activity.csv");
firefox_activity <- as.data.table(firefox_activity);

firefox_bugs_activity <- firefox_bugs;
firefox_activity_fixed <- Subset(firefox_activity, added=="FIXED");

setnames(firefox_activity_fixed, "added", "resolution");

setkey(firefox_bugs_activity, bug_id);
setkey(firefox_activity_fixed, bug_id);



firefox_bugs_activity$fixed_ts <- firefox_activity_fixed[match(firefox_bugs_activity$bug_id, firefox_activity_fixed$bug_id), bug_when];


firefox_bugs_fixed_with_ts <- Subset(firefox_bugs_activity, resolution=="FIXED");

write.csv(firefox_bugs_fixed_with_ts, "firefox_bugs_fixed_with_ts.csv");

firefox_bugs_fixed <- read.csv("firefox_bugs_fixed_with_ts.csv");
firefox_bugs_fixed <- as.data.table(firefox_bugs_fixed);

}


linreg <- function () {

#
# Regular linear regression on continuous value days_to_fix

library(data.table);
library(FSA);

firefox_bugs_fixed <- read.csv("firefox_bugs_fixed_with_day_count.csv");
firefox_bugs_fixed <- as.data.table(firefox_bugs_fixed);

firefox_bugs_fixed_defined_group <- Subset(firefox_bugs_fixed, reporter_group != "NA");



reg1 <- lm(days_to_fix ~ votes + bug_severity,  data=firefox_bugs_fixed_defined_group);
reg2 <- lm(days_to_fix ~ votes + bug_severity + factor(reporter_org), data=firefox_bugs_fixed_defined_group);
anova(reg2, reg1);

reg1 <- lm(days_to_fix ~ reporter_group ,  data=firefox_bugs_fixed_defined_group);
reg2 <- lm(days_to_fix ~ votes + bug_severity + factor(reporter), data=firefox_bugs_fixed_defined_group);
anova(reg2, reg1);

#
#
}

multinom <- function () {


# Multinom regression on factor "outcome"

# setwd('c:/Users/atriou/Dropbox/Classes and York Stuff/Dissertation and brainstorming/Scripts/R');
f_bugs <- read.csv("firefox_bugs_with_logical_outcome_defined_group.csv");
f_bugs <- as.table(f_bugs);

reg <- multinom(outcome ~ votes + factor(reporter_group), data = f_bugs);

summary(reg);


z <- summary(reg)$coefficients/summary(reg)$standard.errors;

p <- (1-pnorm(abs(z), 0, 1)) *2;

 head(pp <- fitted(reg));


dses <- data.frame(reporter_group = c("university", "fed_gov", "other"), votes = mean (f_bugs$votes));

predict(reg, newdata = dses, "probs");

dvotes <- data.frame(reporter_group = rep(c("university", "fed_gov", "other"), each = 41), votes = rep(c(30:70), 3));

pp.votes <- cbind(dvotes, predict(reg, newdata=dvotes, type="probs", se=TRUE));

 by(pp.votes[, 3:5], pp.votes$reporter_group, colMeans);


 lpp <- melt(pp.votes, id.vars= c("reporter_group", "votes"), value.name = "probability");
 
lpp_plot <- ggplot(lpp, aes(x = votes, y = probability, color = reporter_group))
 
lpp_plot + geom_line() +
		   facet_grid(variable ~ ., scales = "free");
 
#
#
}

#
# Now let's try a basic factor regression with the 3-factor outcome predicted by the 4-factor "reporter_group"
# Since the dependent variable is a factor, we need to use multinomial logistic regrestion, not linear regression











# Perform garbage collection to free memory

gc();

#
# EOF






