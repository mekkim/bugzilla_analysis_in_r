# Analyzing Mozilla's Bugzilla Database Using R	

---
© 2015-2016 by Mekki MacAulay, [mekki@mekki.ca](mailto:mekki@mekki.ca)  
LinkedIn: [http://mekki.ca](http://mekki.ca)   
Twitter: [@mekki](http://twitter.com/mekki)			
Some rights reserved.																			

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
	                                
---
## To execute the script file in R, use the following commands:
```R
setwd('<FULL PATH TO THIS SCRIPT FILE>');
source('<NAME OF THIS FILE>.r', echo=TRUE, max.deparse.length=100000, keep.source=TRUE, verbose=TRUE);
```
These source() parameters ensure that the R shell outputs the script commands and responses. Otherwise, they're hidden by default.


Or, from the command prompt directly as follows (assuming R binary is in the PATH environment variable):
```Batchfile
cd <FULL PATH TO THIS SCRIPT FILE>
R CMD BATCH <NAME OF THIS FILE>.r
CAT <NAME OF THIS FILE>.Rout
```
The CAT is necessary because by default R output writes to file, not command prompt

---
## This script depends on:

1. An updated (>3.2.0) R installation with the appropriate packages
2. A MySQL (tested on 5.5.xx) installation containing the Mozilla Bugzilla database to analyze
3. A PHP installation (tested on 5.6.14)
4. A PHP utility script for domain name parsing
5. A PERL installation (tested on ActivePerl 5.22.1.2201)
6. A Tree-Tagger installation

The following sections describe the process for installing these necesities.

---
## INSTALL MYSQL SERVER

Visit: https://dev.mysql.com/downloads/windows/installer/5.5.html

Download the MySQL MSI installer for Windows 
(Version 5.5.xx will do just fine - Later versions have the annoying Oracle installer that makes things more complicated)

Run the installer as administrator and complete the MySQL install with default settings (or minor tweaks if you wish)
During install, set the  default username to "root" and password to "password" in the configuration
Default host will be "localhost" and default port will be "3306"

Reboot.

Test connection to ensure it is working with the MySQL Workbench client that is also installed with the package
Once connected with the MySQL Workbench client, under the menu "Server", select "Options File"
Click on the "Networking" tab
Check the box for "max_allowed_packet" and set its value to "1G" or a suitable large number
Click "Apply" and then restart the server 
(In the Navigator pane, click on "Startup / Shutdown" then click "Stop Server" in the main window, followed by "Start Server)

Add the mysql/bin folder to the PATH system environment
Its default location is C:\Program Files\MySQL\MySQL Server 5.5\bin, but could
vary depending on your install parameters

---
## RESTORE BUGZILLA DATABASE (Current version includes data until end of 2012)

Decompress/untar the Bugzilla database.  The result is a MySQL-formatted dumpfile with a .sql extension
I'll assume that the file name is "bugzilla.sql". If it's not, change the name in the commands below.
This dumpfile only works with MySQl databases.  It cannot be restored to other databases such as SQLite, PostGRESQL, MSSQL, etc.
It is also sufficiently complex that scripts cannot readily be used to convert it to a dumpfile of a different format

Open the standard command prompt as administrator and type the following 3 commands, hitting enter after each one:
```Batchfile
mysql -uroot -ppassword --execute="DROP DATABASE `bugs`;"
mysql -uroot -ppassword --execute="CREATE DATABASE `bugs`;"
mysql -uroot -ppassword bugs < bugzilla.sql
```
The last command will execute for several minutes as it populates the database with the dumpfile data 
The result will be a database named "bugs" on the MySQL server, filled with the Bugzilla data

---
## INSTALL AND CONFIGURE R (Statistical package) or Microsoft R Open (MRO - From Revolution Analytics)

Visit: http://cran.utstat.utoronto.ca/bin/windows/base/ or another mirror

Download the installer for the latest version for Windows (32/64 bit)

Alternatively, visit: http://mran.revolutionanalytics.com/download/#download

Download the installer for the latest version of Microsoft R Open, MRO, an alternative R distribution 
primarily developed by Revolution Analytics (now owned by Microsoft) (http://revolutionanalytics.com/), which is also open source
Revolution Analytics maintains a Managed R Archive Network (MRAN) that mirrors the base CRAN with optimizations

This script might execute slightly faster with MRO vs base R, especially when using multiple cores

You are encouraged to use an R or MRO version of at least 3.2.x as versions 3.1.3 and earlier execute this script significantly
slower (~45% speed decrease), likely due to different memory heap management discussed here: 
http://cran.r-project.org/src/base/NEWS

Run the installer (either one) as administrator and complete the R install with default settings (or minor tweaks if you wish)

Create a shortcut to R x64 X.X.X on the desktop (or suitable place - the installers offer to create one for you)
Right-click on the shortcut and choose "Properties"
Change the "Start in:" field to the location of this script file 
That will ensure that R can find this script when executed from within the R shell

Install additional packages from the package manager including at least the following:

- bit64 
- chron
- curl
- data.table
- DBI
- devtools
- dplyr
- DT
- FactoMineR
- ggplot2
- graphics
- gWidgets
- gWidgetsRGtk2
- highr
- itertools
- iterators
- koRpus (With caps: "koRpus") -> Development is moving quickly, so might be best to use Dev version: install.packages("koRpus", repo="http://R.reaktanz.de") which depends on package:devtools, so install that first
- longitudinalData
- lubridate
- doParallel (And its many Windows dependencies including "foreach", "snow", and "parallel"
- plyr
- Rcmdr (and its many plugins)
- RCurl
- rggobi
- RGraphics
- RGtk2
- RGtk2Extras
- RJDBC
- RMySQL
- RODBC
- RODBCext
- sqldf
- sqlutils
- stargazer
- textcat
- tidyr
- timeDate
- tm (for text mining)
- utils
- xkcd
- xlsx
- zipcode

and all of the recursive dependencies of these listed packages (should do it automatically for you)
This might take a while...

Example:
```R
install.packages(c("bit64", "curl", "data.table", "devtools", "dplyr", "ggplot2", "RGtk2", "RMySQL", "stargazer", "textcat", "tidyr", "utils", "xlsx", "doParallel", "itertools", "iterators", "RCurl", "sqlutils", "timeDate", "tm"));
```

---
## INSTALL AND CONFIGURE PHP

Download the latest zip installer package from http://windows.php.net/download/
This version uses PHP 5.6.14, which was current release version at the time
I chose x64 Thread Safe, but the other ones should work too

Extract the contents of the zip file to whatever directory you want to keep PHP in
I chose "C:\php"

Create a new file called "php.ini" in the PHP directory
Edit the php.ini file to include the following lines:
```
extension=php_curl.dll
extension=php_openssl.dll
extension=php_intl.dll
extension=php_mbstring.dll
memory_limit = 2048M
```
Open the ext director in the PHP directory
Copy php_curl.dll, php_openssl.dll, php_intl.dll, and php_mbstring.dll to the root PHP directory

Change the system PATH environment variable to include "C:\php" or whatever directory you chose for the PHP install

Download the latest version of PHP Composer from: https://getcomposer.org/Composer-Setup.exe
Run the installer with default settings

Follow the instructions here to install "PHP Domain Parser" using Composer: https://github.com/jeremykendall/php-domain-parser/blob/develop/README.md

The small php program "domainparser.php" is provided and uses the installed domain parser library

---
## INSTALL AND CONFIGURE TREE TAGER

Download the latest Tree Tager version from http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/
If using Windows, see the specific details for Windows further down the page
Download the english parameter file from here: http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/english-par-linux-3.2-utf8.bin.gz (or as listed elsewhere on the page above)
If desired, download other language parameter files (not described in this script)
Unzip the downloaded package, and VERY CAREFULLY follow ALL the instructions in the INSTALL.txt file contained within.
This script assumes you install Tree Tagger to its default of c:/TreeTagger.  If not, adjust accordingly in the user-defined parameters below
Pay particular attention to the PATH environment variable setting so that the R script can find the Tree Tagger script files

After you're all done, to to the treetagger/lib directory and copy the english-utf8.par file to english.par because
koRpus has the name hardcoded.

---
## INSTALL AND CONFIGURE PERL

Tree Tagger depends on PERL, so we need to intall it.
We assume Windows, so use download the latest version of Active Perl 64-bit here: http://www.activestate.com/activeperl/downloads
Run the installer as administrator.  Default values should be fine.
Reboot the system
Verify that the PERL executable shows up in the system PATH