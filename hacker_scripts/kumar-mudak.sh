#!/bin/bash

#Version for exim and MySQL

kumar="kumar@mudak.com"
eximhost="exim.example.com"
newmail=$(ssh $LOGNAME@$eximhost 'cd /var/log/exim/$(date +%Y%m%d) && grep '$kumar' ./*.log | egrep "sorry|wrong|help" | tail -n1')

if [ ! -z $newmail ]; then
	message_id=$(echo $newmail | awk '{ print $3 }')
	message_tm=$(echo $newmail | grep -oE "T=\"[[:alpha:]]{1,50}\"" | sed -e "s/T=\"//" | sed "s/\"//")
	if [ $(grep $message_id ./answered_kumar_mail) -eq 0 ]; then
		echo "$message_id" >> ./answered_kumar_mail.txt
		mysql -u <root_user> -p<root_pass> <kumar_db> < $( ll -tr /opt/backup/mysql/ | grep "kumar_db" | tail -n1)
		sendEmail -f $mymail -t $kumar -u "RE: $message_tm" -m  "Ok, i fixed it. Please be careful next time" -s smtp.example.ru
	fi
fi
