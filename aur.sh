#!/bin/sh

#################################################################################################
#	Filename:		~/Documents/GitHub/dot_files/aur.sh											#
#	Purpose:		file that manage the package manager AUR									#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>, Christian Mondo	#
#	License:		This file is licensed under the LGPLv3.										#
#	Dependencies:	yay (https://github.com/Jguer/yay)											#
#################################################################################################

# List installed AUR packages
function aur-list-installed {
	sudo pacman -Qm
}

# Clear unneeded dipendecies
function aur-clear {
	yay -Yc
}

# Remove packages, their dependencies not required and configurations
function aur-remove {
	# the parameter $* is the list of package that you want remove
	sudo pacman -Rns $* && aur-clear
}

# Upgrade all AUR packages
function aur-upgrade {
	# if the OS have KDE as DE (desktop enviroment), I suggest you to add, previous "yay -Sua" the string "sudo pkcon refresh; sudo pkcon update; "
	yay -Sua; aur-clear
}

# Install from AUR or repository
function aur-install {
	# the parameter $* is the list of package that you want remove
	yay -S $*
}
