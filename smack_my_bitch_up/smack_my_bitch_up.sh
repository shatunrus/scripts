#!/bin/bash

source ./config.cfg

count=$($reasons | wc -l)
rint=$(shuf -i 0-$count -n1)
readarray reason < $reasons
msg=$(${otamzka[$rint]})

function print_help {
	echo "Usage:"
	echo " "
	echo "-s for send SMS"
	echo "-m for send e-mail"
	echo "-a for send SMS and e-mail"
}

function send_mail {
	sendEmail -f $mymail -t $wifemail -u "Sorry, i'm late" -m $$msg -s smtp.example.ru
}

function send_sms {
	sms_response=$(curl "http://service.sms.ru/sms/send?api_id=[API_KEY]&to=$wifephone&text=$msg")
		if [ $? -ne 100 ]; then
  		echo "Failed to send SMS: $sms_response" >> /var/log/sms.log
  		exit 1
	fi
}

if [ w | grep -c "$mylogin" -gt 0 ]; then
	while getops ":s:m:a" opt; do
		case $opt in
			m ) send_mail
				;;
			s ) send_sms
				;;
			a ) send_sms && send_mail
				;;
			h ) print_help
				;;
			*)  echo -ne "No args or args is invalid. Default is -a\n for help use $(basename $0) -h\n"
			    echo -n "do you want to continue (Y/n)?"
			    read answer
			    case "$answer" in
			    	y|Y ) send_sms && send_mail
					;;
			    	n|N ) exit 0
					;;
			    esac
			  	;;
		esac
	done
fi
