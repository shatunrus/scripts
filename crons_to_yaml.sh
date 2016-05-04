#!/bin/bash
echo -ne "crons:\n"
crontab -l -u user | grep -v "^#" | sed "s/\*//g" | while read line; do
echo -ne "  '$(echo $line | awk -F'/' '{ print $NF }' | awk '{ print $1}' | sed 's/\.php//g')':\n"
if [ $(echo $line | awk '{ print $2 }' | grep -c ',') -gt 0 ]; then
	echo -ne "     hour:\n"
	echo -ne "$(echo $line | awk '{ print $2 }' | tr ',' '\n' | sed -e 's/^/       - /g')\n"
else 
	echo -ne "     hour: $(echo $line | awk '{ print $2 }')\n"
fi
echo -ne "     minute: $(echo $line | awk '{ print $1 }')\n"
echo -ne "     command: \"$(echo $line | cut -d' ' -f 3- )\"\n "
echo -ne "    user: 'check'\n"
done


