#################################################################################
#	Filename:		~/.bashrc													#
#	Purpose:		config file for bash (bourne again shell)					#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>	#
#	License:		This file is licensed under the LGPLv3.						#
#################################################################################

# Source global definitions
if [ -f /etc/bashrc ]
then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
	PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
## Colors
blue='\[\e[0;34m\]'
red='\[\e[0;31m\]'
red_background='\[\e[41m\]'
white='\[\e[0;37m\]'

reset='\[\e[0m\]'															# reset the color to the default value

## Aliases
alias cd..='cd ..'
alias hystory='history'
alias ls='ls -A --color=auto'

## Code that must be execute when the shell is opened
export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 						# This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"		# This loads nvm bash_completion

if [ $USER = 'root' ]														# if that manage the colour of the username into the prompt
then
	PS1="${red}"
else
	PS1="${blue}"
fi

PS1="${PS1}\u\[${reset}\]@\h \W"											# creating the prompt

if [ $USER = 'root' ]														# if that manage the last character of the prompt
then
	PS1="${PS1} # "
else
	PS1="${PS1} % "
fi

if [ $USER = 'root' ]														# if that manage the include of the Shell Script
then
	path=$(find / -type d -regex ".*Documents/GitHub/dot_files")			# retrieve the path of the directory that contains the configuration files

	# Uncomment the line that load the script that manage yout package manager
	source "${path}/apt.sh"													# include the Shell Script that manage apt
	#source "${path}/dnf.sh"												# include the Shell Script that manage dnf
	#source "${path}/pacman.sh"												# include the Shell Script that manage pacman

	source "${path}/git.sh"													# include the Shell Script that manage git
	source "${path}/kill.sh"												# include the Shell Script that manage the background processes
else
	# Uncomment the line that load the script that manage yout package manager
	source ~/Documents/GitHub/dot_files/apt.sh								# include the Shell Script that manage apt
	#source ~/Documents/GitHub/dot_files/dnf.sh								# include the Shell Script that manage dnf
	#source ~/Documents/GitHub/dot_files/pacman.sh							# include the Shell Script that manage pacman

	source ~/Documents/GitHub/dot_files/git.sh								# include the Shell Script that manage git
	source ~/Documents/GitHub/dot_files/kill.sh								# include the Shell Script that manage the background processes
fi

rm -rf ~/.bash_history														# erasing the history of the shell
clear																		# clearing the shell
