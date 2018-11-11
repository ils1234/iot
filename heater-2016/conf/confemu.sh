#!/bin/bash

if [ $# -ne 1 ] ; then
    echo "usage: $0 <conf file>"
    exit 1
fi

function time_off() {
    if [ $# -ne 1 ] ; then
        echo 0
        return 0
    fi
    timestr=$1
    len=${#timestr}
    if [ $len -ne 8 ] ; then
        echo  0
        return 0
    fi
    result=0
    hour=`expr ${timestr:0:2} \* 3600`
    result=`expr $hour + $result`
    minute=`expr ${timestr:3:2} \* 60`
    result=`expr $minute + $result`
    result=`expr ${timestr:6:2} + $result`
    echo $result
}

conf=$1

offset=1
while [ $offset -le 86400 ] ; do
    hour=`expr $offset / 3600`
    minute=`expr $offset % 3600 / 60`
    second=`expr $offset % 3600 % 60`
    while read line ; do
        start=`echo $line|awk '{print $1}'`
        end=`echo $line|awk '{print $2}'`
        level=`echo $line|awk '{print $3}'`
        if [ $start = 'level' -a $end = 'during' ] ; then
            level_during=$level
        fi
        start_offset=`time_off $start`
        end_offset=`time_off $end`
        if [ $offset -ge $start_offset -a $offset -le $end_offset ] ; then
            current_level=$level
            break
        fi
    done < $conf
    if [ $current_level = 'off' ] ; then
        echo '$hour:$minute:$second not defined'
        continue
    else
        echo "$hour:$minute:$second , level $current_level"
    fi
    
    offset_value=`expr $offset / $level_during % $current_level`
    
    if [ $offset_value -ne 0 ] ; then
        echo "heater stop by offset $offset_value"
    else
        echo "heater run"
    fi
    offset=`expr $offset + $level_during`
done
