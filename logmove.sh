#!/bin/bash

logpath=/var/log
regexp='(?<!\d)\d{8}(?!\d)'
apps=('nginx' 'httpd')
this_log=$logpath/logmove/$(date +%Y%m%d).log
duty='test@example.com'
yd=$(date +%Y%m%d --date="1 day ago")

for app in ${apps[@]}; do
  rotate_app="0"
  if [ -d $logpath/$app ]; then
    rotate_app="1"
    rotate=$logpath/$app
    for j in $rotate/*.log; do
      if [ ! -f $j-$yd ]; then
        mv $j $j-$yd
      else
        cat $j >> $j-$yd
        cat /dev/null > $j
      fi
    done
    files=(${files[@]} $(find $rotate -maxdepth 1 -type f | grep -P $regexp))
  fi

  if [ $rotate_app == '1' ]; then
    [ $app == "httpd" ] && /usr/bin/sudo systemctl reload httpd || /usr/bin/sudo systemctl reload nginx
    [ $? == "0"  ] || echo -ne "$app status $? after logrotate\nPlease restart manualy\n" | mail -s "$app is down on $(hostname)" $duty
  fi
done

if [ ! -z "$files" ]; then
  for i in  ${files[@]}; do
    eval $(echo $i | awk -F'-' '{ print "dstf="substr($NF,1,4)"/"substr($NF,5,2)"/"substr($NF,7,2)}')
    appname=$(dirname "$i")
    dstfold="$logpath${appname#$logpath}/$dstf"
    shortname=$(basename $i | sed "s/.\{,9\}$//")
    [ ! -d $dstfold ] && mkdir -p $dstfold
    if [ -f $dstfold/$shortname ]; then
      if [ $(find $dstfold -name "${shortname}_*" | wc -l) -gt 0 ]; then
        max_file=$(find $dstfold -name "${shortname}_*" | awk '{print length, $0}' | sort -nr | head -n1)
        shortname=${shortname}_$[${max_file:(-2)}+1]
      else
        shortname=${shortname}_01
      fi
    fi
    mv $i $dstfold/$shortname
    echo -ne "$i\t -> $dstfold/$shortname\n" >> $this_log
  done
  echo "$(basename $0) started at $(date) and worked $SECONDS sec." >> $this_log
fi
