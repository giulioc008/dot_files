#!/bin/sh

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

function commit_repository {
	if [ $# -eq 0 ]																	# check if there are some problems
	then
		echo "${red_background}${white}ERROR: Too less parameters for the function commit_repository()." > /dev/stderr
		return 3
	elif [ $# -eq 1 ]																# check if the program must commit all the branches
	then
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

function commit {
	branch=''																		# set the default value for the branch
	message='Automatic commit of the repository'									# set the default value for the message

	saved_IFS=$IFS																	# save the IFS
	IFS=$'\n'																		# set the IFS to the new-line character

	for options in $*																# parse the options with parameters
	do
		if echo $options | grep -q '\-\-branch'										# check if the parameter is the option --branch
		then
			if echo $options | grep -q '='											# check if the parameter contain, also, the value of the option
			then
				i=$(expr $options : '.*=')
				branch=${options:$i}
			else
				branch_is_next_parameter='true'
			fi

			continue
		elif echo $options | grep -q '\-\-message'									# check if the parameter is the option --message
		then
			if echo $options | grep -q '='											# check if the parameter contain, also, the value of the option
			then
				i=$(expr $options : '.*=')
				message=${options:$i}
			else
				message_is_next_parameter='true'
			fi

			continue
		elif [ ! -z $branch_is_next_parameter ]										# check if the parameter is the value of the option --branch
		then
			branch=$options

			unset branch_is_next_parameter
			continue
		elif [ ! -z $message_is_next_parameter ]									# check if the parameter is the value of the option --message
		then
			message=$options

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