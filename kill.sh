#!/bin/sh

#################################################################################
#	Filename:		~/Documents/GitHub/dot_files/kill.sh						#
#	Purpose:		file that manage kill and killall							#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>	#
#	License:		This file is licensed under the LGPLv3.						#
#################################################################################

# Kill all the instance of a program
function kill-kill {
	# the parameter $1 is the name of the program that you want kill
	killall -s KILL -v -I $1
}

# Kill all the PID's into the file processes_to_kill.txt
function kills {
	path=$(find $HOME -type f -regex ".*processes_to_kill\.txt" 2> /dev/null)	# retrieve the path of the file that contains the PIDs of the processes that must be killed

	if [ $? -eq 0 ] && [ -e $path ] && [ -f $path ]								# if that checks if the file exists
	then
		buffer=''

		for i in $(cat $path)													# create a list with the PIDs into the file
		do
			buffer="${buffer}${i} "
		done

		rm -rf $path															# delete permanently the PIDs

		let i=${#buffer} - 1
		buffer=${buffer:$i}

		kill -s KILL $buffer > /dev/null										# kill the processes
	else
		echo -e "There aren\'t process in background."
	fi
}
