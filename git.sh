#!/bin/sh

#################################################################################
#	Filename:		~/Documents/GitHub/dot_files/git.sh							#
#	Purpose:		file that manage github										#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>	#
#	License:		This file is licensed under the LGPLv3.						#
#################################################################################

# Update a single local repository
function update_repository {
	if [ $# -eq 0 ]																	# check if the program must update all the branches
	then
		for i in $(git branch --list | sed -e 's/^\(.*\)\*\s*\(.*\)$/\1\2/')		# cycle through the list of local branches
		do
			i=`echo "${i}" | sed -e 's/^\s*//' -e 's/\s*$//'`						# trim the name of the branch

			git checkout $i &> /dev/null

			git pull
		done

		unset i
	elif [ $# -eq 1 ]																# check if the program must update only one branch
	then
																					# the parameter $1 is the name of the branch

		git checkout $1 &> /dev/null

		if [ $? -eq 0 ]																# check if the branch exists
		then
			git pull
		fi
	else
		echo "${red_background}${white}ERROR: Too much parameters for the function update_repository()." > /dev/stderr
		return 3
	fi

	git checkout master &> /dev/null
}

# Update the local repositories
# update --all-repo --branch ""
# update --all-repo --branch=""
function update {
	branch=''																		# set the default value for the branch

	saved_IFS=$IFS																	# save the IFS
	IFS=$'\n'																		# set the IFS to the new-line character

	for parameter in $*																# parse the options with parameters
	do
		if echo $parameter | grep -q '\-\-branch'									# check if the parameter is the option --branch
		then
			if echo $parameter | grep -q '='										# check if the parameter contain, also, the value of the option
			then
				i=$(expr $parameter : '.*=')
				branch=${parameter:$i}
			else
				branch_is_next_parameter='true'
			fi

			continue
		elif [ ! -z $branch_is_next_parameter ]										# check if the parameter is the value of the option --branch
		then
			branch=$parameter

			unset branch_is_next_parameter
			continue
		fi
	done


	IFS=$saved_IFS																	# restore the IFS
	unset saved_IFS

	options=$(getopt -n $0 -o '' -l 'all-repo,branch::'  -- $@)						# check the presence of the options

	if [ $? -ne 0 ]																	# check if getopt has failed
	then
		echo "${red_background}${white}ERROR: getopt command has failed." > /dev/stderr
		return 1
	fi

	eval set -- $options															# set the options

	while true																		# parse the options without parameters
	do
		case $1 in
			--all-repo)																# check if the program must update all the repositories
				all_repo='true'
				;;
			--)
				shift
				break
				;;
		esac
		shift
	done

	if [ ! -z $all_repo ]															# check if the program must update all the repositories
	then
		for i in $(ls -d $HOME/downloads/*/)										# cycle through the list of local repositories
		do
			cd $i

			if [ -n $branch ]														# check if the program must update all the branches of all the repositories
			then
				update_repository
			else
				update_repository $branch
			fi

			cd ..
		done

		cd $HOME
	else
		if [ -n $branch ]															# check if the program must update all the branches
		then
			update_repository
		else
			update_repository $branch
		fi
	fi
}

# Commit a single local repository
function commit_repository {
	if [ $# -eq 0 ]																	# check if there are some problems
	then
		echo "${red_background}${white}ERROR: Too less parameters for the function commit_repository()." > /dev/stderr
		return 3
	elif [ $# -eq 1 ]																# check if the program must commit all the branches
	then
																					# the parameter $1 is the message of the commit

		for i in $(git branch --list | sed -e 's/^\(.*\)\*\s*\(.*\)$/\1\2/')		# cycle through the list of local branches
		do
			i=`echo "${i}" | sed -e 's/^\s*//' -e 's/\s*$//'`						# trim the name of the branch

			git checkout $i &> /dev/null

			git add .
			git commit -S -m "${1}"
			git push
		done

		unset i
	elif [ $# -eq 2 ]																# check if the program must commit only one branch
	then
																					# the parameter $1 is the name of the branch
																					# the parameter $2 is the message of the commit

		git checkout $1 &> /dev/null

		if [ $? -eq 0 ]																# check if the branch exists
		then
			git add .
			git commit -S -m "${2}"
			git push
		fi
	else
		echo "${red_background}${white}ERROR: Too much parameters for the function commit_repository()." > /dev/stderr
		return 4
	fi

	git checkout master &> /dev/null
}

# Commit the local repositories
# commit --all-repo --branch "" --message ""
# commit --all-repo --branch="" --message=""
function commit {
	branch=''																		# set the default value for the branch
	message='Automatic commit of the repository'									# set the default value for the message

	saved_IFS=$IFS																	# save the IFS
	IFS=$'\n'																		# set the IFS to the new-line character

	for parameter in $*																# parse the parameter with parameters
	do
		if echo $parameter | grep -q '\-\-branch'										# check if the parameter is the option --branch
		then
			if echo $parameter | grep -q '='											# check if the parameter contain, also, the value of the option
			then
				i=$(expr $parameter : '.*=')
				branch=${parameter:$i}
			else
				branch_is_next_parameter='true'
			fi

			continue
		elif echo $parameter | grep -q '\-\-message'									# check if the parameter is the option --message
		then
			if echo $parameter | grep -q '='											# check if the parameter contain, also, the value of the option
			then
				i=$(expr $parameter : '.*=')
				message=${parameter:$i}
			else
				message_is_next_parameter='true'
			fi

			continue
		elif [ ! -z $branch_is_next_parameter ]										# check if the parameter is the value of the option --branch
		then
			branch=$parameter

			unset branch_is_next_parameter
			continue
		elif [ ! -z $message_is_next_parameter ]									# check if the parameter is the value of the option --message
		then
			message=$parameter

			unset message_is_next_parameter
			continue
		fi
	done

	IFS=$saved_IFS																	# restore the IFS
	unset saved_IFS

	options=$(getopt -n $0 -o '' -l 'all-repo,branch::,message::'  -- $@)			# check the presence of the options

	if [ $? -ne 0 ]																	# check if getopt has failed
	then
		echo "${red_background}${white}ERROR: getopt command has failed." > /dev/stderr
		return 1
	fi

	eval set -- $options															# set the options

	while true																		# parse the options without parameters
	do
		case $1 in
			--all-repo)																# check if the program must commit all the repositories
				all_repo='true'
				;;
			--)
				shift
				break
				;;
		esac
		shift
	done

	if [ ! -z $all_repo ]															# check if the program must commit all the repositories
	then
		for i in $(ls -d $HOME/downloads/*/)										# cycle through the list of local repositories
		do
			cd $i

			if [ -n $branch ]														# check if the program must commit all the branches of all the repositories
			then
				commit_repository "$message"
			else
				commit_repository $branch "$message"
			fi

			cd ..
		done

		cd $HOME
	else
		if [ -n $branch ]															# check if the program must commit all the branches
		then
			commit_repository "$message"
		else
			commit_repository $branch "$message"
		fi
	fi
}
