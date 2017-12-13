#!/bin/bash

start=$(date)
logpath=/var/log
regexp='(?<!\d)\d{8}(?!\d)'
apps=('nginx' 'httpd')
this_log=$logpath/logmove/$(date +%Y%m%d).log

for app in ${apps[@]}; do
  if [ -d $logpath/$app ]; then
    rotate=$logpath/$app
    for j in $rotate/*.log; do
      if [ ! -f $j-$(date +%Y%m%d) ]; then
        mv $j $j-$(date +%Y%m%d)
      else
        cat $j >> j-$(date +%Y%m%d)
        cat /dev/null > $j
      fi
       [ $app == "httpd" ] && /usr/bin/sudo systemctl reload httpd || /usr/bin/sudo systemctl reload nginx
    done
    files=(${files[@]} $(find $rotate -maxdepth 1 -type f | grep -P $regexp))
  fi
done

if [ ! -z "$files" ]; then
  for i in  ${files[@]}; do
    datefile=$(echo $i | awk -F'-' '{ print $NF }')
    fyear=$(echo $datefile | cut -b 1-4)
    fmonth=$(echo $datefile | cut -b 5-6)
    fday=$(echo $datefile | cut -b 7-8)
    appname=$(dirname "$i")
    dstpath=$logpath${appname#$logpath}
    dstfold="$dstpath/$fyear/$fmonth/$fday"
    shortname=$(basename $i | sed "s/.\{,9\}$//")
    [ ! -d $dstfold ] && mkdir -p $dstfold
    if [ -f $dstfold/$shortname ]; then
      if [ $(find $dstfold -name "${shortname}_*" | wc -l) -gt 0 ]; then
        max_file=$(find $dstfold -name "${shortname}_*" | awk '{print length, $0}' | sort -nr | head -n1)
        log_ver=${max_file: -1}
        let log_ver_up=$log_ver+1
        shortname=${shortname}_${log_ver_up}
      else
        shortname=${shortname}_1
      fi
    fi
    mv $i $dstfold/$shortname
    echo -ne "$i\t -> $dstfold/$shortname\n" >> $this_log
  done
  echo "$(basename $0) started at $start and worked $SECONDS sec." >> $this_log
fi
