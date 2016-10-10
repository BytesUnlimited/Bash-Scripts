#!/bin/bash
# --------------------------------------------------------------------------------
# Bytes Unlimited MySQL Backup Script
# (c) 2016 Anthony Affee
# https://bytesunlimited.com
# anthony@bytesunlimited.com
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


# A simple MySQL backup script in BASH.
#
# The simple script just performs a MySQL Dump on the full
# Database with username and compresses it with a Linux
# Timestamp with the desired name and backup location.
#
# The Script uses gzip compression on each backup file and
# labels the backup files by date. 
#
# The script is intended to be run by a cron job.  It echos
# messages to STDOUT which can be redirected to a file for
# simple logging. 
#
# Sample Crontab used:
# MySQL Dump and Backup Site Database
# 0 2 * * * /bin/bash /backup/backup-scripts/Bytes-MySQL-Backup.sh
#
# --------------------------------------------------------------------------------

# Variables:

TIME=`date +"%b-%d-%y"`               # This Command will add date in Backup File Name.
LINUXTIME=$(date +%Y%m%d%H%M%S)       # Standard Linux TimeStamp
SQLUSER=sysadmin                      # MySQL User that can perform Backups
FILENAME="sql-bytes-unl.sql.gz"		    # Here I define Backup file name format.
DESDIR="/backup/bytes-unlimited-sql"	# Destination of backup file.

# Start Script

echo "Starting MySQL Backup - $TIME"

echo "Creating MySQL Backup Directory $DESDIR/$LINUXTIME/"
mkdir -p $DESDIR/$LINUXTIME/

echo Dumping and Compressing MySQL Backup...
mysqldump -u $SQLUSER | gzip > $DESDIR/$LINUXTIME/$FILENAME
echo file-compressed

echo "MySQL Backup Complete! - $TIME"; echo

#END
