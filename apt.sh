#!/bin/sh

#################################################################################
#	Filename:		~/Documents/GitHub/dot_files/apt.sh							#
#	Purpose:		file that manage the package manager apt					#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>	#
#	License:		This file is licensed under the LGPLv3.						#
#################################################################################

# Clear unneeded dipendecies
function apt-clear {
	sudo apt autoclean; sudo apt autoremove; sudo apt clean all
}

# Remove packages, their dependencies not required and configurations
function apt-remove {
	# the parameter $* is the list of package that you want remove
	sudo apt purge $* && apt-clear
}

# Upgrade all packages
function apt-upgrade {
	# if the OS have KDE as DE (desktop enviroment), I suggest you to add, previous "sudo apt dist-upgrade" the string "sudo pkcon refresh; sudo pkcon update; "
	# if the configuration files are for the Termux's app, you must erease the keyword "sudo "

	sudo apt dist-upgrade; sudo apt full-upgrade; sudo apt update; sudo apt upgrade; apt-clear
}
