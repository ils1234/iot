#!/bin/bash

cd /home/pi/heater
date=`date '+%Y%m%d'`
./heater.sh >> log/heater_${date}.log
