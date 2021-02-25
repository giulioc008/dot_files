#!/bin/sh

#################################################################################
#	Filename:		~/Documents/GitHub/dot_files/dnf.sh							#
#	Purpose:		file that manage the package manager dnf					#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>	#
#	License:		This file is licensed under the LGPLv3.						#
#################################################################################

function dnf-clear {
	sudo dnf autoremove; sudo dnf clean all
}

function dnf-remove {
	# the parameter $* is the list of package that you want remove
	sudo dnf remove $* && dnf-clear
}

function dnf-upgrade {
	# this function requires that you have installed the package "dnf-plugin-system-upgrade"; if you haven't installed it, do so now
	# the parameter $1 is the release the you want install
	# if the OS have KDE as DE (desktop enviroment), I suggest you to add, previous "sudo dnf distro-sync" the string "sudo pkcon refresh; sudo pkcon update; "

	sudo dnf distro-sync; sudo dnf upgrade; dnf-clear; sudo dnf system-upgrade download --best --allowerasing --refresh --releasever=$1 && sudo dnf system-upgrade reboot
}
