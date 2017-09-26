#!/bin/bash

#############################################
# This is a simple battery warning script.  #
# It uses i3's nagbar to display warnings.  #
#                                           #
# @original-author agribu                   #
# @forked-by Hritik14
#############################################

# lock file location
export LOCK_FILE=/tmp/battery_state.lock

# check if another copy is running
if [[ -a $LOCK_FILE ]]; then

    pid=$(cat $LOCK_FILE | awk '{print $1}')
	ppid=$(cat $LOCK_FILE | awk '{print $2}')
	# validate contents of previous lock file
	vpid=${pid:-"0"}
	vppid=${ppid:-"0"}

    if (( $vpid < 2 || $vppid < 2 )); then
		# corrupt lock file $LOCK_FILE ... Exiting
		cp -f $LOCK_FILE ${LOCK_FILE}.`date +%Y%m%d%H%M%S`
		exit
	fi

    # check if ppid matches pid
	ps -f -p $pid --no-headers | grep $ppid >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
		# another copy of script running with process id $pid
		exit
	else
		# bogus lock file found, removing
		rm -f $LOCK_FILE >/dev/null
	fi

fi

pid=$$
ps -f -p $pid --no-headers | awk '{print $2,$3}' > $LOCK_FILE
# starting with process id $pid

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
		DISPLAY=:0.0 /usr/bin/i3-nagbar -f "pango:Cantarall 12" -m "$(echo $CRITICAL_MESSAGE)"
		sleep $HIBERNATE_TIME
		systemctl hibernate
	fi

	# show warning if energy limit in percent is less than user set limit and
	# greater than LIMIT-3 (so that it doesn't keep bugging for a long time and
	# if battery is discharging
	if [ $PERCENT -le $LIMIT ] && [ $PERCENT -ge $((LIMIT-3)) ] && [ "$STAT" == "discharging" ]; then
		DISPLAY=:0.0 /usr/bin/i3-nagbar -t warning -f "pango:Cantarall 12" -m "$(echo $MESSAGE)"
	fi
	sleep $CHECK_INTERVAL
done



