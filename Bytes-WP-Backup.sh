#!/bin/bash
# --------------------------------------------------------------------------------
# Bytes Unlimited WordPress Backup Script
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


# A simple WordPress Files and Directory backup script in BASH.
#
# The simple script Tarballs the the full WordPress Data
# Directory and compresses it with a Linux Timestamp with
# the desired name and backup location.
#
# The Script uses gzip compression on each backup file and
# labels the backup files by date. 
#
# The script is intended to be run by a cron job.  It echos
# messages to STDOUT which can be redirected to a file for
# simple logging. 
#
# Sample Crontab used:
# Backup of WordPress Directory for Bytes Unlimited - Daily
# 0 2 * * * /bin/bash /backup/backup-scripts/Bytes-WP-Backup.sh
#
# --------------------------------------------------------------------------------

# Variables:

TIME=`date +"%b-%d-%y"`                 # This Command will add date in Backup File Name.
LINUXTIME=$(date +%Y%m%d%H%M%S)         # Standard Linux TimeStamp
FILENAME="wp-folder-bytes-unl.tar.gz"   # Here I define Backup file name format.
SRCDIR="/var/www/html/bytesunlimited"	  # Location of Important Data Directory (Source of backup).
DESDIR="/backup/bytes-unlimited-wp"     # Destination of backup file.
BCKSERVER="localhost"                   # Backup server/ Raspberry Pi

# Start Script

echo "Starting WordPress Data Backup - $TIME"

echo "Creating WordPress Backup Directory $DESDIR/$LINUXTIME/"
mkdir -p $DESDIR/$LINUXTIME/

echo Copying and Compressing WordPress Backup...
tar -cvpzf $DESDIR/$LINUXTIME/$FILENAME $SRCDIR
echo file-compressed

echo "WordPress Data Backup Complete! - $TIME"; echo

#END
