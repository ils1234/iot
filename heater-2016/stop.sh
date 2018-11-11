#!/bin/bash

#check arg count
if [ $# -gt 1 ] ; then
    echo "usage: $0 [yes|no]"
    exit 1
fi

#check arg value
if [ $# -eq 1 ] ; then
    if [ $1 = 'yes' ] ; then
	setvalue=0
    elif [ $1 = 'no' ] ; then
	setvalue=1
    else
	echo "usage: $0 [yes|no]"
	exit 1
    fi
else
    setvalue=2
fi

#set hardware io port
#port 17 is GPIO_GEN0
port=17

cd /sys/class/gpio
portdir="gpio${port}"
#init port
if [ ! -h $portdir ] ; then
    echo $port > export
    sleep 1
fi
#set port direction
if [ -h $portdir ] ; then
    cd $portdir
    direction=`cat direction`
    if [ $direction = 'in' ] ; then
	echo "out" > direction
	echo 1 > value
    fi
else
    echo "can not open port $port"
    exit 1
fi

#operate
getvalue=`cat value`
if [ $setvalue -eq 2 ] ; then
    if [ $getvalue -eq 0 ] ; then
	echo 'yes'
    elif [ $getvalue -eq 1 ] ; then
	echo 'no'
    else
	echo 'unknown'
    fi
elif [ $setvalue -ne $getvalue ] ; then
    echo $setvalue > value
    echo 'done'
else
    echo 'unchanged'
fi
