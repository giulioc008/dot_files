path=$(find $HOME -type d -regex ".*check_IP" 2> /dev/null)								# retrieve the path of the file

ln -s "${path}/check_IP.service" /lib/systemd/system/check_IP.service					# create the links into /lib/...
ln -s "${path}/check_IP.timer" /lib/systemd/system/check_IP.timer

ln -s "${path}/check_IP.service" /etc/systemd/system/check_IP.service					# create the links into /etc/...
ln -s "${path}/check_IP.timer" /etc/systemd/system/check_IP.timer

exit 0
