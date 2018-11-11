#!/bin/bash

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


time=`date +%s`
date=`date '+%Y-%m-%d' -d "1970-01-01 00:00:00 GMT $time seconds"`
week=`date '+%A' -d "1970-01-01 00:00:00 GMT $time seconds"`
date_s=`date '+%s' -d $date`
offset=`expr $time - $date_s`
datetime=`date '+%Y-%m-%d %H:%M:%S %A' -d "1970-01-01 00:00:00 GMT $time seconds"`

weekconf="./conf/$week.conf"
dateconf="./conf/$date.conf"
allconf="./conf/All.conf"

conf=""
if [ -f $allconf ] ; then
    conf=$allconf
    conf_type='All conf'
elif [ -f $dateconf ] ; then
    conf=$dateconf
    conf_type='date conf'
elif [ -f $weekconf ] ; then
    conf=$weekconf
    conf_type='week conf'
else
    echo "$datetime no conf now, exit"
    exit 1
fi
current_level='off'
level_during='default'
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
done <$conf

if [ $level_during = 'default' ] ; then
    level_during=900
fi

if [ $current_level = 'off' ] ; then
    echo '$datetime unconfigured, heater controlled by timer'
    ./stop.sh no
    exit 1
else
    echo "$datetime $conf_type level $current_level"
fi

offset_value=`expr $offset / $level_during % $current_level`

if [ $offset_value -ne 0 ] ; then
    result=`./stop.sh yes`
    echo "set heater stop by offset $offset_value $result"
else
    result=`./stop.sh no`
    echo "set heater run $result"
fi
