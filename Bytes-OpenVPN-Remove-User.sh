#!/bin/bash

# --------------------------------------------------------------------------------
# Bytes Unlimited OpenVPN Remove User and Keys Script
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
# Works with Easy-RSA and OpenVPN 2.4
# Formats it with custom parameters for user.
#
# The script is intended to be run manually.
# It echos messages to STDOUT
#

#### Variables ####

EASYRSA_PATH="/etc/openvpn/easy-rsa"
OPENVPNSSL_PATH="/etc/openvpn"
username=$1

#### Functions ####

# Test if the User Argument is supplied
userArgTest () {
  if [ -z "$username" ]; then
    echo "You must provide the name for the client"
    exit 1
  fi
}

# Remove the user if the correct path is supplied
removeUser () {
  if [ -s ./easyrsa ]
  then
    echo "Revoking cert for user ${username}"
    ./easyrsa revoke "$username"
    ./easyrsa gen-crl
    rm -f "$OPENVPNSSL_PATH"/crl.pem
    cp -s "$EASYRSA_PATH"/pki/crl.pem "$OPENVPNSSL_PATH"/crl.pem
    echo "Done"
    exit 0
  else
    abort "easyrsa script not found in path"
    exit 1
  fi
}

main () {
  userArgTest
  removeUser
}

#### Start Script ####

main
