#!/bin/bash

source ./config.cfg

if [ w | grep -c "$mylogin" -eq 0 ]; then
	sendEmail -f $mymail -t $wifemail -u "today a need to work at home" -m "I'm sorry, but im illing today. Work at home" -s smtp.example.ru
fi

