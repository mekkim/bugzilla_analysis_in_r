Analyzing Mozilla's Bugzilla Database Using R	

© 2015 by Mekki MacAulay, mekki@mekki.ca http://mekki.ca http://twitter.com/mekki			
Some rights reserved.													

Current version created on November 5, 2015								

This program is free and open source software. The author licenses it	
to you under the terms of the GNU General Public License (GPL), as 		
published by the Free Software Foundation, either version 3, or			
(at your option) any later version (GPLv3+).							

There is NO WARRANTY for this software, express or implied, including 	
the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR 	
PURPOSE. See the GNU General Public License for more details.			

For the full text of the GNU General Public License, please visit		
http://gnu.org/licenses/													
Should you require an alternative licensing arrangement for this 		
software, please contact the author.	                                


To execute the script file in R, use the following commands:

setwd('<FULL PATH TO THIS SCRIPT FILE>');
source('<NAME OF THIS FILE>.r', echo=TRUE, max.deparse.length=100000, keep.source=TRUE, verbose=TRUE);
(These source() parameters ensure that the R shell outputs the script commands and responses. Otherwise, they're hidden by default.)

Or, from the command prompt directly as follows (assuming R binary is in the PATH environment variable):
cd <FULL PATH TO THIS SCRIPT FILE>
R CMD BATCH <NAME OF THIS FILE>.r
CAT <NAME OF THIS FILE>.Rout
(The CAT is necessary because by default R output writes to file, not command prompt)


This script depends on the presence of an updated R installation along with a
MySQL installation containing the Mozilla Bugzilla database and a
PHP utility script for domain name parsing

The following sections describe the process for installing these necesities

INSTALL MYSQL SERVER

Visit: https://dev.mysql.com/downloads/windows/installer/5.5.html

Download the MySQL MSI installer for Windows
(Version 5.5.44 will do just fine - Later versions have the annoying Oracle installer that makes things more complicated)

Run the installer as administrator and complete the MySQL install with default settings (or minor tweaks if you wish)
During install, set the  default username to "root" and password to "password" in the configuration
Default host will be "localhost" and default port will be "3306"

Test connection to ensure it is working with the MySQL Workbench client that is also installed with the package
Once connected with the MySQL Workbench client, under the menu "Server", select "Options File"
Click on the "Networking" tab
Check the box for "max_allowed_packet" and set its value to "1G" or a suitable large number
Click "Apply" and then restart the server
(In the Navigator pane, click on "Startup / Shutdown" then click "Stop Server" in the main window, followed by "Start Server)


RESTORE BUGZILLA DATABASE (Current version includes data until end of 2012)

Decompress/untar the Bugzilla database.  The result is a MySQL-formatted dumpfile with a .sql extension
I'll assume that the file name is "2013_01_sanitized_bugzilla.sql". If it's not, change the name in the commands below.
This dumpfile only works with MySQl databases.  It cannot be restored to other databases such as SQLite, PostGRESQL, MSSQL, etc.
It is also sufficiently complex that scripts cannot readily be used to convert it to a dumpfile of a different format

From the command prompt, issue the following 3 commands one by one:

mysql -uroot -ppassword -e 'DROP DATABASE bugs;'
mysql -uroot -ppassword -e 'CREATE DATABASE bugs;'
mysql -uroot -ppassword bugs < 2013_01_sanitized_bugzilla.sql

The result will be a database named "bugs" on the MySQL server, filled with the Bugzilla data

The "bugs" database will be kept as our "pristine" copy of the data so that we don't have to restore it from
the dumpfile if something goes wrong. This step isn't strictly necessary, but it never hurts to be safe.
We'll only work on a duplicate of the "bugs" database that we can always recreate from the pristine copy if something breaks

To create a duplicate of the "bugs" database, which we will call "working",
from the command prompt, issue the following command:

mysqldbcopy --source=root:password@localhost --destination=root:password@localhost bugs:working


INSTALL AND CONFIGURE R (Statistical package) or RRO (Revolution R Open enhanced R distribution)

Visit: http://cran.utstat.utoronto.ca/bin/windows/base/

Download the installer for the latest version for Windows (32/64 bit)

Alternatively, visit: http://mran.revolutionanalytics.com/download/download

Download the installer for the latest version of Revolution R Open, RRO, an alternative R distribution
primarily developed by Revolution Analytics (http://revolutionanalytics.com/), which is also open source
Revolution Analytics maintains a Managed R Archive Network (MRAN) that mirrors the base CRAN with optimizations

This script might execute slightly faster with RRO vs base R, but no large changes have been noted yet.

You are encouraged to use an R or RRO version of at least 3.2.x as versions 3.1.3 and earlier execute this script significantly
slower (~45% speed decrease), likely due to different memory heap management discussed here:
http://cran.r-project.org/src/base/NEWS

Run the installer (either one) as administrator and complete the R install with default settings (or minor tweaks if you wish)

Create a shortcut to R x64 X.X.X on the desktop (or suitable place - the installers offer to create one for you)
Right-click on the shortcut and choose "Properties"
Change the "Start in:" field to the location of this script file
(Currently: "C:\Users\atriou\Dropbox\Classes and York Stuff\Dissertation and brainstorming\Scripts\R")
That will ensure that R can find this script when executed from within the R shell

Install additional packages from the package manager including at least the following:

chron
curl
data.table
DBI
dplyr
DT
FactoMineR
FSA: https://www.rforge.net/FSA/Installation.html -> Not needed with dplyr::filter, which is much faster
ggplot2
googleVis https://cran.r-project.org/web/packages/googleVis/index.html
graphics
gWidgets
gWidgetsRGtk2
highr
longitudinalData
lubridate
Paneldata
panelaggregation
panelAR
plyr
Rcmdr (and its many plugins)
RCurl
rggobi
RGraphics
RGtk2
RGtk2Extras
RJDBC
RMySQL
RODBC
RODBCext
RQDA
sqldf
sqlutils
stargazer
timeDate
utils
xkcd
xlsx
zipcode
...
and all of the recursive dependencies of these listed packages (should do it automatically for you)
This might take a while...


INSTALL AND CONFIGURE PHP

Download the latest zip installer package from http://windows.php.net/download/
This version uses PHP 5.6.14, which was current release version at the time

Extract the contents of the zip file to whatever directory you want to keep PHP in
I chose "C:\php"

Create a new file called "php.ini" in the PHP directory
Edit the php.ini file to include the following lines:

extension=php_curl.dll
extension=php_openssl.dll
extension=php_intl.dll
extension=php_mbstring.dll
memory_limit = 2048M

Open the ext director in the PHP directory
Copy php_curl.dll, php_openssl.dll, php_intl.dll, and php_mbstring.dll to the root PHP directory

Change the system PATH environment variable to include "C:\php" or whatever directory you chose for the PHP install

Download the latest version of PHP Composer from: https://getcomposer.org/Composer-Setup.exe
Run the installer with default settings

Follow the instructions here to install "PHP Domain Parser" using Composer: https://github.com/jeremykendall/php-domain-parser/blob/develop/README.md

The small php program "domainparser.php" is provided and uses in the installed library

