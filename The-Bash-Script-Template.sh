#!/bin/bash

# --------------------------------------------------------------------------------
# Bytes Unlimited - Author Information
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


# Brief Description or Use case

# --------------------------------------------------------------------------------

#### Variables ####


#### Functions ####

# Cleanup Function allows a clean exit of the script when no errors
cleanup () {
  echo -e "\n$(date +\%Y-\%m-\%d-\%l:\%M) -  No Errors found on Run!"
  exit 0
}

# Main Function to load all other Functions above it
main () {

}

#### Start Script ####

main

#### Exit Script ####

cleanup
