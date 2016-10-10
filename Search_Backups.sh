#!/bin/bash
# --------------------------------------------------------------------------------
# Bytes Unlimited WordPress and MySQL Backup Verification Script
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


# A simple script in BASH to verify backups.
#
# The simple script looks for the backup directories for
# WordPress and MySQL inside of the /backup/ Directory. It
# Uses the Linux TimeStamp to verify and track in order.
#
# The Script confirms it can write to /tmp to create the 
# temporary list of backups before emailing. 
#
# The script is intended to be run by a cron job.  It echos
# messages a file for simple logging and formats for email
#
# Sample Crontab used:
# Daily Backup Report
# 0 7 * * * /bin/bash /backup/backup-scripts/search_backups.sh
#
# --------------------------------------------------------------------------------

# Variables

TMP_DIR=/tmp/search_backups
TMP_FILE="list_files.txt"
BACKUP_DIR="/backup"
WP_BACKUP_DIR="bytes-unlimited-wp"
SQL_BACKUP_DIR="bytes-unlimited-sql"
EMAIL_SUBJECT_LINE="Raspberry Pi Local Backup Reports"
EMAIL=anthony@bytesunlimited.com

# Fuctions

# FINSH Function used to clean up the tmp file
function finish {
	rm -fr "$TMP_DIR/$TMP_FILE"
}

# Start Script

# Setup tmp directory structure and file used in the script
if [ ! -d $TMP_DIR/ ]; then
        mkdir $TMP_DIR/
fi

if [ ! -f $TMP_DIR/TMP_FILE ]; then
        touch $TMP_DIR/TMP_FILE
fi

# WP Data Backups
printf "Raspberry Pi - Bytes Unlimited WP Data Backups: \n \n" >> $TMP_DIR/TMP_FILE
files=($(find $BACKUP_DIR/$WP_BACKUP_DIR/ -maxdepth 1 -mindepth 1 -type d -regex "^.*$"))
for item in ${files[*]}
do
  printf $item >> $TMP_DIR/TMP_FILE
  echo -e "\n" >> $TMP_DIR/TMP_FILE
done
printf "\n" >> $TMP_DIR/TMP_FILE
echo "----------------------------------------------------" >> $TMP_DIR/TMP_FILE

# MySQL Backups
printf "\n Raspberry Pi - Bytes Unlimited MySQL Backups: \n \n" >> $TMP_DIR/TMP_FILE
files=($(find $BACKUP_DIR/$SQL_BACKUP_DIR/ -maxdepth 1 -mindepth 1 -type d -regex "^.*$"))
for item in ${files[*]}
do
  printf $item >> $TMP_DIR/TMP_FILE
  echo -e "\n" >> $TMP_DIR/TMP_FILE
done
printf "\n" >> $TMP_DIR/TMP_FILE
echo "----------------------------------------------------" >> $TMP_DIR/TMP_FILE

# Send the contents of the daily tmp file to your email
mail -s $EMAIL_SUBJECT_LINE $EMAIL < $TMP_DIR/TMP_FILE

# Delete tmp file when done
trap finish EXIT

# End
