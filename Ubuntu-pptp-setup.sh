#!/bin/sh
#    Setup Simple PPTP VPN server for Ubuntu and Debian
#    Copyright (C) 2015-2016 Danyl Zhang <1475811550@qq.com> and contributors
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

printhelp() {

echo "

Usage: sh setup.sh [OPTION]

If you are using custom password , Make sure its more than 8 characters. Otherwise it will generate random password for you. 

If you trying set password only. It will generate Default user with Random password. 

example: sudo bash setup.sh -u vpn -p mypass

Use without parameter [ sudo bash setup.sh ] to use default username and Random password


  -u,    --username             Enter the Username
  -p,    --password             Enter the Password
"
}

while [ "$1" != "" ]; do
  case "$1" in
    -u    | --username )             NAME=$2; shift 2 ;;
    -p    | --password )             PASS=$2; shift 2 ;;
    -h    | --help )            echo "$(printhelp)"; exit; shift; break ;;
  esac
done

if [ `id -u` -ne 0 ] 
then
  echo "Need root, try with sudo"
  exit 0
fi

apt-get update
apt-get -y install net-tools
apt-get -y install pptpd || {
  echo "Could not install pptpd"
  exit 1
}

echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sed -i 's@net.ipv4.tcp_syncookies.*@#net.ipv4.tcp_syncookies = 1@g' /etc/sysctl.conf
sysctl -p

ETH=`route | grep default | awk '{print $NF}'`
iptables -I INPUT -p tcp --dport 1723 -j ACCEPT
iptables -I INPUT  --protocol 47 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -d 0.0.0.0/0 -o $ETH -j MASQUERADE
iptables -I FORWARD -s 192.168.2.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
service iptables save
service iptables restart

#no liI10oO chars in password

LEN=$(echo ${#PASS})

if [ -z "$PASS" ] || [ $LEN -lt 8 ] || [ -z "$NAME"]
then
   P1=`cat /dev/urandom | tr -cd abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789 | head -c 3`
   P2=`cat /dev/urandom | tr -cd abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789 | head -c 3`
   P3=`cat /dev/urandom | tr -cd abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789 | head -c 3`
   PASS="$P1-$P2-$P3"
fi

if [ -z "$NAME" ]
then
   NAME="vpn"
fi

cat >> /etc/ppp/chap-secrets <<END
$NAME pptpd $PASS *
END

cat >/etc/pptpd.conf <<END
option /etc/ppp/options.pptpd
#logwtmp
localip 192.168.2.1
remoteip 192.168.2.10-100
END

cat >/etc/ppp/options.pptpd <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 209.244.0.3
proxyarp
lock
nobsdcomp
novj
novjccomp
nologfd
END

apt-get -y install wget || {
  echo "Could not install wget, required to retrieve your IP address." 
  exit 1
}

#find out external ip 
IP=`wget -q -O - http://api.ipify.org`

if [ "x$IP" = "x" ]
then
  echo "============================================================"
  echo "  !!!  COULD NOT DETECT SERVER EXTERNAL IP ADDRESS  !!!"
else
  echo "============================================================"
  echo -e "You can now connect to your VPN via your external IP \033[32m${IP}\033[0m"
fi
  echo -e "Username: \033[32m${NAME}\033[0m"
  echo -e "Password: \033[32m${PASS}\033[0m"
sleep 2

service pptpd restart

exit 0
