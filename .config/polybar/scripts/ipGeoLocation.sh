#!/bin/bash
sleep 15

IP=`curl -w "\n" -s https://api.ipify.org`
if [[ ! $IP == "" ]] ;then
    country=`geoiplookup "$IP" | awk 'BEGIN{FS=":"}; {print $2}' | awk 'BEGIN{FS=","}; {gsub(/[[:blank:]]/,""); print $1}'`
    # flag=`jq '.[] | select(.iso=='"$country"') .flag' ~/country.json 2> /dev/null` 
    # clean_flag=`echo "$flag" | awk '{gsub(/"/, "", $0) ; print $0}'`
    echo "$country"
else
    echo "Offline"
fi
