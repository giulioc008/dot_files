#!/bin/sh

#################################################################################
#	Filename:		~/Documents/GitHub/dot_files/pacman.sh						#
#	Purpose:		file that manage the package manager pacman					#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>	#
#	License:		This file is licensed under the LGPLv3.						#
#################################################################################

function pacman-clear {
	#sudo pacman autoclean; sudo pacman autoremove; sudo pacman clean all
}

function pacman-remove {
	# the parameter $* is the list of package that you want remove
	#sudo pacman purge $* && pacman-clear
}

function pacman-upgrade {
	# if the OS have KDE as DE (desktop enviroment), I suggest you to add, previous "sudo pacman dist-upgrade" the string "sudo pkcon refresh; sudo pkcon update; "

	#sudo pacman dist-upgrade; sudo pacman full-upgrade; sudo pacman update; sudo pacman upgrade; pacman-clear
}
