#!/bin/bash

HWADDR=$(cat /sys/class/net/e*/address)
echo "MAC: $HWADDR"
IFENV=$(ls -l /etc/sysconfig/network-scripts | grep ifcfg- | grep -vE 'lo|eth' | awk -F"ifcfg-" '{ print $NF }')
echo "interface name: $IFENV"
sed -i "s/rhgb quiet/rhgb quiet net.ifnames=0/" /etc/default/grub
echo "adding \"net.ifnames=0\" to grub"
grub2-mkconfig -o /boot/grub2/grub.cfg
echo "SUBSYSTEM==\"net\", ACTION=\"add\", DRIVERS==\"?*\", ATTR{address}==\"$HWADDR\", ATTR{type}==\"1\", KERNEL==\"eth*\", NAME=\"eth0\"" > /etc/udev/rules.d/70-persistent-net.rules
echo "creating /etc/udev/rules.d/70-persistent-net.rules"
cd /etc/sysconfig/network-scripts
mv ./ifcfg-$IFENV ./ifcfg-eth0
sed -i "s/$IFENV/eth0/g" ./ifcfg-eth0
echo "renaming $IFENV to eth0"
echo -ne "\nReboot now\t [y/n]?\n"
read answer
case "$answer" in
  y|Y) shutdown -r now
      ;;
  n|N) echo "You must reboot system to apply changes"
      exit 0
      ;;
  *) echo -ne "Wrong type of answer\nPlease restart your system manualy"
      ;;
esac
