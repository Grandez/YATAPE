#! /bin/bash
# Find the name of icon file
# Use: $0 slug
#
# Author: Grandez

[[ $#  -eq 1 ]] && return  1 
curl --silent https://coinmarketcap.com/currencies/$1/ -o page.txt
[[ $rc -ne 0 ]] && return 16
grep -o -E "200x200/.+\.png" page.txt
rc=$?
rm -f page.txt
return $rc

