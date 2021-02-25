#!/bin/sh

#################################################################################
#	Filename:		~/Documents/GitHub/dot_files/kill.sh						#
#	Purpose:		file that manage kill and killall							#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>	#
#	License:		This file is licensed under the LGPLv3.						#
#################################################################################

function kill-kill {
	killall -s KILL -v -I $1
}

function kills {
	path=$(find $HOME -regex ".*processes_to_kill\.txt")		# retrieve the path of the file that contains the PIDs of the processes that must be killed

	if [ -e $path ] && [ -f $path ]								# if that checks if the file exists
	then
		buffer=''

		for i in $(cat $path)									# create a list with the PIDs into the file
		do
			buffer="${buffer}${i} "
		done

		rm -rf $path											# delete permanently the PIDs

		let i=${#buffer} - 1
		buffer=${buffer: $i}

		kill -s KILL $buffer > /dev/null						# kill the processes
	else
		echo -e "There aren\'t process in background."
	fi
}
