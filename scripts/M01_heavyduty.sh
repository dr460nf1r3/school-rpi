#!/usr/bin/env bash
# OHMega.IT - Lastskript (Primzahlenberechnung)
if [ $# -eq 0 ]; then
    read -rp "Enter begin of range: " i
    read -rp "Enter end of range: " limit
elif [ $# -eq 2 ]; then
    i=$1
    limit=$2
    echo "begin of range: \"$i\" end of range:" "$limit"
else
    echo "check range definition"
    exit
fi

if [ "$i" -lt 2 ]; then i=2; fi

while [ "$i" -le "$limit" ]; do
    flag=1
    j=2
    while [ $j -lt "$i" ]; do
        check=$(("$i" % "$j"))
        if [ "$check" -eq 0 ]; then
            flag=0
            break
        fi
        j=$(("$j" + 1))
    done
    if [ $flag -eq 1 ]; then
        echo "$i"
    fi
    i=$(("$i" + 1))
done
