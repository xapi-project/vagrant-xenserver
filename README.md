# Vagrant XenServer Provider

This is a Vagrant plugin that adds a XenServer provider, allowing Vagrant to
control and provision machines on a XenServer host.

## Dependencies
* Vagrant >= 1.5.2 (http://www.vagrantup.com/downloads.html)

## Installation
```shell
vagrant plugin install vagrant-xenserver
# Make your linux box look like a Mac :) (maybe)
sudo ln -s /bin/tar /bin/bsdtar
```

## XenServer host setup
N.B. Currently this will only work on a trunk build of XenServer:
```shell
# Install netcat
yum install --enablerepo=base,extras --disablerepo=citrix -y nc
# Setup NAT
echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -t nat -A POSTROUTING -o xenbr0 -j MASQUERADE
/sbin/iptables -A INPUT -i xenbr0 -p tcp -m tcp --dport 53 -j ACCEPT
/sbin/iptables -A INPUT -i xenbr0 -p udp -m udp --dport 53 -j ACCEPT
/sbin/iptables -A FORWARD -i xenbr0 -o xenapi -m state --state
RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i xenapi -o xenbr0 -j ACCEPT
```

## Usage
* Get a XenServer .box file (currently from Dr. Ludlam space on drall)
* Get a `Vagrantfile` from the same
```shell
vagrant box add centos centos-6.5.box`
vagrant up --provider=xenserver
```
