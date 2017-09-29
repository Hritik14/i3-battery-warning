#!/bin/bash

#############################################
# This is a simple battery warning script.  #
# It uses i3's nagbar to display warnings.  #
#                                           #
# @original-author agribu                   #
# @forked-by Hritik14
#############################################


# Set hibernate time (in seconds) after critical level
HIBERNATE_TIME=60
# set energy limit in percent, where warning should be displayed
LIMIT=15
# Set critical limit in percent, where the system should hibernate
CRITICAL=5
# Interval to check battery on (sec)
CHECK_INTERVAL=60

# set error message
MESSAGE="AWW SNAP! I am running out of juice ...  Please, charge me or I'll have to power down."
CRITICAL_MESSAGE="Hibernating in 60 seconds. Finish your work, if you can."

while true; do
	# Get battery details
	BATTERY=`upower -i $(upower -e | grep BAT)`
	# get battery status
	STAT=`echo "$BATTERY" | grep --color=never -E state|awk '{print $2}'`
	# get remaining energy value (%)
	PERCENT=`echo "$BATTERY" | grep --color=never -E percentage|xargs|cut -d' ' -f2|sed s/%//`


	# Show warning if critcal level reached and hibernate after HIBERNATE_TIME
	if [ $PERCENT -le $CRITICAL ] && [ "$STAT" == "discharging" ]; then
		notify-send -t 8000 "$CRITICAL_MESSAGE"
		sleep $HIBERNATE_TIME
		systemctl hibernate
	fi

	# show warning if energy limit in percent is less than user set limit and
	# if battery is discharging
	if [ $PERCENT -le $LIMIT ] && [ "$STAT" == "discharging" ]; then
		notify-send -t 10000 "$MESSAGE"

		#Do not notify again and again
		while [ $PERCENT -ge $CRITICAL ]; do
			#TODO: REplace these lines with a function as they appear earlier once.
			# Get battery details
			BATTERY=`upower -i $(upower -e | grep BAT)`
			# get battery status
			STAT=`echo "$BATTERY" | grep --color=never -E state|awk '{print $2}'`
			# get remaining energy value (%)
			PERCENT=`echo "$BATTERY" | grep --color=never -E percentage|xargs|cut -d' ' -f2|sed s/%//`
			sleep 60
			#Just hope that in dropping battery level from $LIMIT to $CRITICAL it takes more than a minute. 
		done


	fi
	sleep $CHECK_INTERVAL
done



