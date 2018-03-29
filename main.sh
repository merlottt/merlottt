#!/bin/bash
if [ -z "$1" ]; then
        echo "SNMP find port and shich by MAC"
        echo "HOWTO:"
        echo "./searchmac.sh 01-02-03-04-05-06"
        echo "./searchmac.sh 01:02:03:04:05:06"
        echo "./searchmac.sh 010203040506"
        echo "Debug Mod:"
        echo "./searchmac.sh 01-02-03-04-05-06 d"
        echo "./searchmac.sh 01:02:03:04:05:06 d"
        echo "./searchmac.sh 010203040506 d"
        exit 1 fi if [ "$2" == "d" ]; then
        echo "[Debug=on]" fi
#========================================[VARS]
swichs=(
        'SW1'
        'SW1'
        ) snmpcommunity="public" snmpoidmacs=".1.3.6.1.2.1.17.7.1.2.2.1.2" snmpoidports=".1.3.6.1.2.1.2.2.1.2."
#========================================[/VARS]
mac=$1 mac=`echo $mac| sed -e 's/\-/:/g'` len=`echo $mac| wc -c` if [ "$len" = "13" ]; then
        mac=`echo $mac | sed -e :a -e 's/\(.*[a-zA-Z0-9]\)\([a-zA-Z0-9]\{2\}\)/\1:\2/;ta'` fi mac10=`printf "%1d.%1d.%1d.%1d.%1d.%1d" 0x${mac//:/ 0x}` #convert hex2dec mac10=`echo ${mac10// /}` #remove space 
max_index=${#swichs[@]} if [ "$2" == "d" ]; then #==========================debug
        echo "count swich address" $max_index
        echo "mac convert to dec" $mac10 fi if [ "$2" == "h" ]; then
    echo "<table border=0 id=findmac>" fi for ((i=0;i<max_index;i++)); do
        ip=`echo "${swichs[i]}"`
        result=`snmpwalk -c $snmpcommunity -v 2c $ip $snmpoidmacs | grep $mac10`
        count=`echo $result | grep : -o | wc -l`
        if [ "$2" == "d" ]; then #==========================debug
                echo "on swich" $ip "try to find" $mac10 "return" $count "lines."
        fi
        if [ $count != "0" ]; then
                for ((j=0;j<count;j++)); do
                        l=$(($j + 2))
                        line=`echo ${result// /} | cut -d"=" -f$l | cut -c 9-10 | sed s/[^0-9]//g`
                         if [ "$2" == "d" ]; then #==========================debug
                                echo "LINE---------------------------: "$line
                                echo "l------------------------------: "$l
                                echo "Result-------------------------: "$result
                        fi
                        #if [ "$line" = "3" -o "$line" = "23" ]; then
                        #       continue #clear UPLINK ports fi
                        if [ -n "$line" ]; then
                                result2=`snmpwalk -c $snmpcommunity -v 2c $ip $snmpoidports$line`
                                port=`echo "${result2//*:/}"`
                                if [ "$2" == "h" ]; then
                                  if [ "$line" = "3" -o "$line" = "23" ]; then
                                    echo "<tr style=\"Background-color:#CCCCCC;\"><td><div id=\"uplinkport\">Swich Name: " $ip "</td><td> Port Number: "$line"</td><td> Description Port: " $port "</div></td></tr>"
                                continue
                                fi
                                    echo "<tr style=\"Background-color:#ffffff;\"><td><div id=\"macport\" >Swich Name: " $ip "</td><td> Port Number: "$line"</td><td> Description Port: " $port "</div></td></tr>"
                                continue
                                fi
                                if [ "$line" = "3" -o "$line" = "23" ]; then
                                    echo -en "[RESULT: " $ip "\033[37;1;41m " $line " \033[0m" $port "\n"
                                continue
                                fi
                                echo -en "[RESULT: " $ip "\033[37;1;42m " $line " \033[0m" $port "\n"
                        fi
                done
        fi done if [ "$2" == "h" ]; then
    echo "</table>" fi

