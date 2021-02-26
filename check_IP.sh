#! /bin/sh

#################################################################################
#	Filename:		~/Documents/GitHub/dot_files/check_IP.sh					#
#	Purpose:		script that checks the public IP of the router				#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>	#
#	License:		This file is licensed under the LGPLv3.						#
#################################################################################

# ~/Documents/GitHub/dot_files/check_IP.sh --post <true|false>

red_background='\[\e[41m\]'
white='\[\e[0;37m\]'

saved_IFS=$IFS																	# save the IFS
IFS=$'\n'																		# set the IFS to the new-line character

for parameter in $*																# parse the options with parameters
do
	if echo $parameter | grep -q '\-\-post'										# check if the parameter is the option --post
	then
		if echo $parameter | grep -q '='										# check if the parameter contain, also, the value of the option
		then
			i=$(expr $parameter : '.*=')
			have_to_post=${parameter:$i}
		else
			post_is_next_parameter='true'
		fi

		continue
	elif [ ! -z $post_is_next_parameter ]										# check if the parameter is the value of the option --post
	then
		have_to_post=$parameter

		unset post_is_next_parameter
		continue
	fi
done

IFS=$saved_IFS																	# restore the IFS

path_ip="${HOME}/ip.txt"														# set the path of the output file
path_ftp="${HOME}/ftp.txt"														# set the path of the ftp file

if [ ! -n $have_to_post ] && [ $have_to_post = 'true' ]							# check if the have_to_post is true
then
	echo 'ascii' > $path_ftp
	echo 'bell' >> $path_ftp
	echo 'case' >> $path_ftp
	echo 'trace' >> $path_ftp
	echo 'user MY_USER MY_PASSWORD' >> $path_ftp
fi

wget  --output-file=/dev/null -O $path_ip 'ip4.me'								# download the file

saved_IFS=$IFS																	# save the IFS
IFS=$'\n'																		# set the IFS to the new-line character

for word in $(cat $path_ip)														# extract the IP
do
	word=`expr "${word}" : '\(.*[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*.*\)'`

	if [ -n $word ]																# check if the word  contains the IP
	then
		word=`expr "${word}" : '\(.*[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)'`
		i=$(expr $word : '.*>')
		word=${word:$i}
		break
	fi
done

IFS=$saved_IFS																	# restore the IFS
unset saved_IFS

echo $word > $path_ip
date >> $path_ip

if [ ! -n $have_to_post ] && [ $have_to_post = 'true' ]							# check if the have_to_post is true
then
	echo "send ${path_ip} MY_PATH" >> $path_ftp
	echo 'bye' >> $path_ftp

	ftp -ginv my_site < $path_ftp

	rm -rf $path_ftp															# remove the ftp file
else
	cat $path_ip
fi

rm -rf $path_ip																	# remove the output file

exit 0
