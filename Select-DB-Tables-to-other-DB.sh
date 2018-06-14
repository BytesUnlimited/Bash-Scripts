#!/bin/bash


# --------------------------------------------------------------------------------
# Bytes Unlimited DB Table(s) with Data Transfer Script
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
# --------------------------------------------------------------------------------

# A complex MySQL backup script in BASH.
#
# The complex script performs a MySQL Dump on the source
# Database with username and then sends it to the destination
# DB. Then it restores the full DB or Schema.
# Removes SQL file after successfull completion.
#
# The script is intended to be run by a cron job or command
# line. It echos messages to STDOUT which can be redirected to a
# file for simple logging.
# --------------------------------------------------------------------------------

# Example Usage:
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
# # MySQL Dump and Backup Site Database
# # Sending all STDOUT and STDERR to /dev/null since this is an automated script
# 0 2 * * * /bin/bash /backup/backup-scripts/Select-DB-Tables-to-other-DB.sh > /dev/null 2>&1
#
# --------------------------------------------------------------------------------
#
# User Privileges
# GRANT USAGE ON *.* TO 'dumpuser'@'%' IDENTIFIED BY 'some-strong-password';
# GRANT SELECT, LOCK TABLES ON `mysql`.* TO 'dumpuser'@'%';
# GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON `myschema`.* TO 'dumpuser'@'%';
# FLUSH PRIVILEGES;

#### Variables ####

# DB Credentials:
DB_USER="{Username}"
DB_PASS="--defaults-extra-file={/path/to/private/.my.cnf}"
SOURCE_DB_HOST="{IP or Hostname}"
DESTINATION_DB_HOST="{IP or Hostname}"

# DB Related Data:
DB_SCHEMA='{DB Schema}'
DB_TABLES=('{Table1}' '{Table2}' '{Table3}' '{Table4}')
BACKUP_DIR="/tmp/{Custom Directory in /tmp}"
BACKUP_FILE_NAME="-db-table.sql"

# Slack Integration:
SLACK_CHANNEL="#{Slack Channel Name}"
SLACK_BOTNAME="Script Alerts"
ICON_GIF=":bangbang:"
SCRIPT_NAME="Select-DB-Tables-to-other-DB.sh"
STATUS="Failure"
WEBHOOKS_INTEGRATION_URL="{WebHooks URL}"

#### Functions ####

# slackNotification is custom to notify a channel via WebHooks Integration
slackNotification () {
    DATA='Script: \"'${SCRIPT_NAME}'\" Status: \"'${STATUS}'\" MESSAGE: \"'${MESSAGE}'\"'
    PAYLOAD='payload={"channel": "'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"${DATA}"'", "icon_emoji": "'"${ICON_GIF}"'"}'
    curl \
        -X POST \
        --data "${PAYLOAD}" \
        "$WEBHOOKS_INTEGRATION_URL"
}

# runTry is a BASH custom hack at a real Try/Catch setup
runTry () {
  cmd_output=$(eval $1)
  return_value=$?
  if [ $return_value != 0 ]; then
    MESSAGE="MySQL Command failed, either MySQLDump or MySQL for restore"
    echo $MESSAGE
    slackNotification $MESSAGE
    exit $?
  fi
}

# Make sure tmp directory structure is in place
tmp_create () {
  if [ ! -d $BACKUP_DIR ]
  then
    echo -e "\nCreating tmp directory for backups"
    mkdir -p $BACKUP_DIR
  fi
}

# Backup Function for Source Database
backup () {
  echo -e "\nDumping $DB_SCHEMA Database Schema Tables for Destination DB..."
  for tables in ${DB_TABLES[@]}; do
    echo -e "\nDumping $tables..."
    runTry 'mysqldump $DB_PASS --user="$DB_USER" --host="$SOURCE_DB_HOST" --triggers --routines --events --single-transaction --verbose $DB_SCHEMA $tables -r $BACKUP_DIR/$tables$BACKUP_FILE_NAME'
  done
}

# Restore Function for pushing mysqldump file data to Destination DB
restore () {
  echo -e "\nRestoring $DB_SCHEMA Database Schema Tables to Destination DB..."
  for tables in ${DB_TABLES[@]}; do
    echo -e "\nRestoring $tables..."
    runTry 'mysql $DB_PASS --user="$DB_USER" --host="$DESTINATION_DB_HOST" "$DB_SCHEMA" < "$BACKUP_DIR/$tables$BACKUP_FILE_NAME"'
  done
}

# Cleanup Function to remove DB mysqldump files from Script Server
cleanup () {
  echo -e "\nCleaning up the files"
  rm -rf $BACKUP_DIR
}

main () {
  tmp_create
  backup
  restore
  cleanup
}

#### Start Script ####

main

#### Exit ####

echo -e "\n Completed successfully!"
exit 0
