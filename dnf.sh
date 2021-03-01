#!/bin/sh

#########################################################################################################################
#	Filename:		~/Documents/GitHub/dot_files/dnf.sh																	#
#	Purpose:		file that manage the package manager dnf															#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>											#
#	License:		This file is licensed under the LGPLv3.																#
#	Dependencies:	dnf-plugin-system-upgrade (https://github.com/rpm-software-management/dnf-plugin-system-upgrade)	#
########################################################################################################àà###############

# Clear unneeded dipendecies
function dnf-clear {
	sudo dnf autoremove; sudo dnf clean all
}

# Remove packages, their dependencies not required and configurations
function dnf-remove {
	# the parameter $* is the list of package that you want remove
	sudo dnf remove $* && dnf-clear
}

# Upgrade all packages
# commit --release 0
# commit --release=0
function dnf-upgrade {
	saved_IFS=$IFS																	# save the IFS
	IFS=$'\n'																		# set the IFS to the new-line character

	for parameter in $*																# parse the options with parameters
	do
		if echo $parameter | grep -q '\-\-release'									# check if the parameter is the option --release
		then
			if echo $parameter | grep -q '='										# check if the parameter contain, also, the value of the option
			then
				i=$(expr $parameter : '.*=')
				release=${parameter:$i}
			else
				release_is_next_parameter='true'
			fi

			continue
		elif [ ! -z $release_is_next_parameter ]									# check if the parameter is the value of the option --release
		then
			release=$parameter

			unset release_is_next_parameter
			continue
		fi
	done

	IFS=$saved_IFS																	# restore the IFS
	unset saved_IFS

	# if the OS have KDE as DE (desktop enviroment), I suggest you to add, previous "sudo dnf distro-sync" the string "sudo pkcon refresh; sudo pkcon update; "

	sudo dnf distro-sync; sudo dnf upgrade; dnf-clear

	if [ -n $release ]																# check if you want update the system
	then
		sudo dnf system-upgrade download --best --allowerasing --refresh --releasever=$release && sudo dnf system-upgrade reboot
	fi
}
