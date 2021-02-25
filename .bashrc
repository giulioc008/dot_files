# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
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

reset='\[\e[0m\]'														# reset the color to the default value

## Aliases
alias cd..='cd ..'
alias hystory='history'
alias ls='ls -A --color=auto'

## Code that must be execute when the shell is opened
export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 					# This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"	# This loads nvm bash_completion

if [[ $USER = 'root' ]]													# if that manage the colour of the username into the prompt
then
	PS1="${red}"
else
	PS1="${blue}"
fi

PS1="${PS1}\u\[${reset}\]@\h \W"										# creating the prompt

if [[ $USER = 'root' ]]													# if that manage the last character of the prompt
then
	PS1="${PS1} # "
else
	PS1="${PS1} % "
fi

source ~/Documents/GitHub/dot_files/apt.sh								# include the Shell Script that manage apt
source ~/Documents/GitHub/dot_files/git.sh								# include the Shell Script that manage git
source ~/Documents/GitHub/dot_files/kill.sh								# include the Shell Script that manage the background processes

rm -rf ~/.bash_history													# erasing the history of the shell
clear																	# clearing the shell
