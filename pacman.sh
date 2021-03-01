#!/bin/sh

#################################################################################################
#	Filename:		~/Documents/GitHub/dot_files/pacman.sh										#
#	Purpose:		file that manage the package manager pacman									#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>, Christian Mondo	#
#	License:		This file is licensed under the LGPLv3.										#
#################################################################################################

# Remove all the cached packages that are not currently installed and the unused sync database
function pacman-clear {
	sudo pacman -Sc
}

# Remove all cached file
function pacman-clear-all {
	sudo pacman -Scc
}

# Remove packages, their dependencies not required and configurations
function pacman-remove {
	# the parameter $* is the list of package that you want remove
	sudo pacman -Rns $* && pacman-clear
}

# Upgrade all packages
function pacman-upgrade {
	# if the OS have KDE as DE (desktop enviroment), I suggest you to add, previous "sudo pacman -Syu" the string "sudo pkcon refresh; sudo pkcon update; "
	sudo pacman -Syu; pacman-clear
}

# Install list of packages without reinstall the already installed ones
function pacman-install {
	# the parameter $* is the list of package that you want remove
	sudo pacman -S --needed $*
}
