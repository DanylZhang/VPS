# VPS
Virtual private server related

Setup Simple PPTP VPN server for CentOS and Ubuntu
==================================================

> NOTE: PPTP VPN is considered insecure. Do not rely for this vpn
> if you need security. However, PPTP works out of the box on many
> operating systems, including many Linux distributions, Windows, 
> Mac OS and Android and it's easily good enough for evading country
> level IP blocks.

CentOS-pptp-setup.sh has been tested on **Vultr: CentOS 6 x86**

Ubuntu-pptp-setup.sh has been tested on **Vultr: Ubuntu14.04 x86**

INSTALLATION INSTRUCTIONS
=========================

**CentOS**

------

    wget https://raw.github.com/DanylZhang/VPS/master/CentOS-pptp-setup.sh
    chmod +x ./CentOS-pptp-setup.sh
    ./CentOS-pptp-setup.sh –u your_username –p your_password

*or*

**Ubuntu**
------

    wget https://raw.github.com/DanylZhang/VPS/master/Ubuntu-pptp-setup.sh
    sudo sh setup.sh
    sudo bash setup.sh –u your_username –p your_password
    service pptpd restart

Some notes
==========

To add more accounts, see the file /etc/ppp/chap-secrets

If you keep the vpn server generated with this script on the internet for a
long time (days or more), consider either restricting access to the ssh port on
the server by ip addresses to the networks you use, if you know the addresses
you are most likely to use or at least change ssh from port 22 to a random
port.

You can also specify you own username and password, run `sh CentOS-pptp-setup.sh -h` for help.
