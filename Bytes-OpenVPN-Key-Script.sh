#!/bin/bash

# --------------------------------------------------------------------------------
# Bytes Unlimited OpenVPN Auto Generate Keys Script
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


# An OpenVPN script in BASH.
#
# Works with Easy-RSA and OpenVPN 2.3
# Formats it with custom parameters for client .ovpn file.
#
# The script is intended to be run manually.
# It echos messages to STDOUT which can be redirected to a
# file for simple logging.
#

# Variables
TIME=`date +"%b-%d-%y"`
OPENVPN_DIRECTORY=/etc/openvpn/easy-rsa
OPENVPN_KEYS_DIRECTORY=/etc/openvpn/easy-rsa/keys
REMOTE_EXTERNAL_IP=xxx.xxx.xxx.xxx
BASE_DIRECTORY=home

#### Start Script ####

# Script --help for Usage
# While Loop to give help parameters and add username
while [[ $1 = -* ]]; do
	arg=$1; shift
	case $arg in
  # Help Flag for usage
	 --help)
		echo "client_distribute.sh --clientname <anyname> --adminuser <admin-name> ";exit
		;;
  # Client Name Flag
	 --clientname)
		USERNAME=$1
		shift
		;;
  # Admin User Flag
   --adminuser)
    ADMIN_USER=$1
    shift
    ;;
	esac
done

# Adding Admin user accountability to logs
echo ""
echo "NOTICE - Admin User, $ADMIN_USER, is generating VPN keys for the Client, $USERNAME. - $TIME"
echo ""

# Traverse to directory
echo "Building files with name client_$USERNAME"
cd $OPENVPN_DIRECTORY

# Source Vars
source ./vars

# Call Script to build keys
sh ./build-key client_$USERNAME

# Echo in parameters 
# Set below for your environment
echo "client" > keys/client_$USERNAME.ovpn
echo "tls-client" >> keys/client_$USERNAME.ovpn
echo "dev tun" >> keys/client_$USERNAME.ovpn
echo "proto udp" >> keys/client_$USERNAME.ovpn
echo "remote $REMOTE_EXTERNAL_IP" >> keys/client_$USERNAME.ovpn
echo "resolv-retry infinite" >> keys/client_$USERNAME.ovpn
echo "nobind" >> keys/client_$USERNAME.ovpn
echo "persist-key" >> keys/client_$USERNAME.ovpn
echo "persist-tun" >> keys/client_$USERNAME.ovpn
echo "ca ca.crt" >> keys/client_$USERNAME.ovpn
echo "cert client_$USERNAME.crt" >> keys/client_$USERNAME.ovpn
echo "key client_$USERNAME.key" >> keys/client_$USERNAME.ovpn
echo "ns-cert-type server" >> keys/client_$USERNAME.ovpn
echo "comp-lzo" >> keys/client_$USERNAME.ovpn
echo "verb 3 script-security 2 system" >> keys/client_$USERNAME.ovpn
echo "tls-auth ta.key 1" >> keys/client_$USERNAME.ovpn
echo "cipher aes-256-cbc" >> keys/client_$USERNAME.ovpn
echo "Attached are four files to use for OpenVPN.  Please download them into a dedicated folder."

# Add files to a tar.gz for shipping
echo ""
echo "Compressing files..."
cd $OPENVPN_KEYS_DIRECTORY
tar -cvzf $USERNAME.tgz client_$USERNAME.* ca.crt ta.key

# Remove any case sensitivity to Admin User variable for Linux Directory
declare -l ADMIN_USER
ADMIN_USER=$ADMIN_USER

# Copy files to Admin user directory (Example - /home/user/)
echo ""
echo "Copying compressed files to $ADMIN_USER home directory..."
cp $USERNAME.tgz /$BASE_DIRECTORY/$ADMIN_USER/

# Exit with Status Code
exit 0
