#!/bin/bash
# --------------------------------------------------------------------------------
# Bytes Unlimited MySQL Backup and FTP Upload Script
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


# A MySQL backup to FTP Upload script in BASH.
#
# The script performs a MySQL Dump on the prod
# Database with username and then sends it to the FTP
# Server. It compresses the SQL File. Removes
# SQL file after successfull completion.
#
# The script is intended to be run by a cron job.
# It echos messages to STDOUT which can be redirected to a
# file for simple logging.
#
# Script requires a file created for the DB password to be
# securely stored and used. Example of file below:
# [client]
# password="somepassword"
#
# [mysqldump]
# password="somepassword"
#
# Sample Crontab used:
# # MySQL Dump and FTP
# 0 2 * * * /bin/bash /backup/backup-scripts/Follett-MySQL-DB-Dump-And-Transfer.sh
#
# --------------------------------------------------------------------------------

# Variables

TIME=`date +"%b-%d-%y"`

DB_USER=""
DB_PASS="--defaults-extra-file=/root/.my.cnf"
DB_HOST="localhost"

DB_SCHEMA='somedb'
DB_TABLES='table1 table2 table3'
BACKUP_DIR="root"
BACKUP_FILE_NAME="somedb-tables-$TIME.sql.gz"

FTP_URL="ftp.example.com"
FTP_PORT=21
FTP_USER=""
FTP_USER_PASSWORD=""
FTP_BACKUP_DIR="sql"

#### Start Script ####

# Start Script
echo -e "\nStarting MySQL Dump - $TIME"

# Dump DB and Tables
echo -e "\nDumping and Compressing MySQL Backup for Follett..."
mysqldump $DB_PASS --user="$DB_USER" --host="$DB_HOST" $DB_SCHEMA $DB_TABLES | gzip > /$BACKUP_DIR/$BACKUP_FILE_NAME
echo -e "\nBackup Complete"

# Upload to FTP
echo -e "\nPushing Backup to FTP..."
ftp -n $FTP_URL <<END_SCRIPT
quote user $FTP_USER
quote pass $FTP_USER_PASSWORD
cd $FTP_BACKUP_DIR
put $BACKUP_FILE_NAME
quit
END_SCRIPT
echo -e "\nFTP Upload Complete"

# Clean up
echo -e "\nCleaning up MySQL Backup File"
if [ -f /$BACKUP_DIR/$BACKUP_FILE_NAME ]
then
  rm -f /$BACKUP_DIR/$BACKUP_FILE_NAME
fi

# Exit
echo -e "\nBackup Completed - $TIME"
exit 0
