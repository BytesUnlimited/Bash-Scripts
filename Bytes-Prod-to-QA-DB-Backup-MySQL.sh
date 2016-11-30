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


# A complex MySQL backup script in BASH.
#
# The complex script performs a MySQL Dump on the prod
# Database with username and then sends it to the QA
# DB. Then it restores the full DB or Schema. Removes 
# SQL file after successfull completion. 
#
# The script is intended to be run by a cron job or command 
# line. It echos messages to STDOUT which can be redirected to a 
# file for simple logging. 
#
# Script requires a file created for the password to be 
# securely stored and used. Example of file below:
# [client]
# password="somepassword"
#
# [mysqldump]
# password="somepassword"
#
# Sample Crontab used:
# MySQL Dump and Backup Site Database
# 0 2 * * * /bin/bash /backup/backup-scripts/Bytes-Prod-to-QA-DB-Backup-MySQL.sh {DB Schema or All}
#
# --------------------------------------------------------------------------------

# Variables

PROD_DB_USER="sysadmin"
PROD_DB_PASS="--defaults-extra-file=/root/.my.cnf"
PROD_DB_HOST="10.108.139.12"

QA_DB_USER="sysadmin"
QA_DB_PASS="--defaults-extra-file=/root/.my.cnf"
QA_DB_HOST="localhost"

DB_SCHEMA=''
BACKUP_DIR="/root"
BACKUP_FILE_NAME="-prod-db-backup.sql"

#### Start Script ####

# Ask for DB Schema to backup if no Argument
# is inputted on the command line
DB_SCHEMA=$1
if [ "$1" == "" ]
then
  read -p "Enter the Database Schema you wish to backup: " USER_INPUT_DB_SCHEMA
  DB_SCHEMA=$USER_INPUT_DB_SCHEMA
elif [ "$1" == "All Databases" ] | [ "$1" == "All" ]
then
  DB_SCHEMA="ALL"
fi

# Educate User on Options for Script

echo -e "\n *Note* \n  If you want to backup the full database, \n run command with the argument \"All\" or \"All Databases\" \n"

read -p "Would you like to proceed: Yes or No? " USER_ANSWER

if [ $USER_ANSWER == 'Yes' ] | [ $USER_ANSWER == 'y' ]
then
  echo "Let's start the backup on $DB_SCHEMA DB Schema(s)"
elif [ $USER_ANSWER == 'No' ] | [ $USER_ANSWER == 'n' ]
then
  echo "Please Rerun Script with your correct choice"
  exit 2
else
  echo "Input Error: Please Rerun Script with correct parameters"
  exit 1
fi

# Backup MySQL Database Schema(s) according to the user input
if [ $DB_SCHEMA != 'ALL' ]
then
  echo -e "\nDumping $DB_SCHEMA Database Schema..."
  mysqldump $PROD_DB_PASS --user="$PROD_DB_USER" --host="$PROD_DB_HOST" --add-drop-database --databases $DB_SCHEMA > $BACKUP_DIR/$DB_SCHEMA$BACKUP_FILE_NAME
elif [ $DB_SCHEMA == 'ALL' ]
then
  echo -e "\nDumping ALL MySQL Databases..."
  mysqldump $PROD_DB_PASS --user="$PROD_DB_USER" --host="$PROD_DB_HOST" --add-drop-database --all-databases  > /$BACKUP_DIR/$DB_SCHEMA$BACKUP_FILE_NAME
else
  echo "Could not issue mysqldump command"
  exit 1
fi

# Import the database into QA DB

if [ $DB_SCHEMA != 'ALL' ]
then
  echo -e "\nImporting $DB_SCHEMA Database Schema..."
  mysql $QA_DB_PASS --user="$QA_DB_USER" --host="$QA_DB_HOST" $DB_SCHEMA < $BACKUP_DIR/$DB_SCHEMA$BACKUP_FILE_NAME
elif [ $DB_SCHEMA == 'ALL' ]
then
  echo -e "\nImporting ALL MySQL Databases..."
  mysql $QA_DB_PASS --user="$QA_DB_USER" --host="$QA_DB_HOST" < /$BACKUP_DIR/$DB_SCHEMA$BACKUP_FILE_NAME
else
  echo "Could not issue mysql command to import the Schema(s)"
  exit 1
fi

# Clean Up old backup file
if [ -f $BACKUP_DIR/$DB_SCHEMA$BACKUP_FILE_NAME ]
then
  echo -e "\nRemoving backup file..."
  rm -f $BACKUP_DIR/$DB_SCHEMA$BACKUP_FILE_NAME
else
  echo -e "\nCould not remove backup file"
  exit 1
fi

# Confirm all is done
echo -e "\nBackup and Restore is complete!"
exit 0

#### End ####
