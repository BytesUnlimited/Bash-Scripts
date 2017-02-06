#!/bin/bash
# --------------------------------------------------------------------------------
# Bytes Unlimited Text File to IPtables Format for Bulk IP Import Script
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


# An IPtables IP Format script in BASH.
#
# Bulk import of IPs stored in a TXT File.
# Formats it to an IPtables friendly import.
#
# The script is intended to be run by a cron job.
# It echos messages to STDOUT which can be redirected to a
# file for simple logging.
#

# Variables

IP_LIST_FORMATTED=/path/to/formatted/txt/file.txt

#### Start Script ####

# Create/Truncate IP TXT File
if [ -f $IP_LIST_FORMATTED ]
then
    rm -f $IP_LIST_FORMATTED
    touch $IP_LIST_FORMATTED
else
    touch $IP_LIST_FORMATTED
fi

# Loop thru GH IP List
for ip in $(cat /path/to/txt/file/ips.txt)
do
    echo "-A INPUT -s $ip -p tcp -m tcp --dport 22 -m comment --comment \"Some Comment\" -j ACCEPT" >> $IP_LIST_FORMATTED
done

# Exit
exit 0
