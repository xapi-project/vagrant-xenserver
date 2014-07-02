# Vagrant XenServer Provider

This is a Vagrant plugin that adds a XenServer provider, allowing Vagrant to
control and provision machines on a XenServer host.

## Dependencies
* Vagrant >= 1.6(?) (http://www.vagrantup.com/downloads.html)

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
# Setup NAT - NB, this _disable the firewall_ - be careful!
echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -F INPUT

/sbin/iptables -t nat -A POSTROUTING -o xenbr0 -j MASQUERADE
/sbin/iptables -A INPUT -i xenbr0 -p tcp -m tcp --dport 53 -j ACCEPT
/sbin/iptables -A INPUT -i xenbr0 -p udp -m udp --dport 53 -j ACCEPT
/sbin/iptables -A FORWARD -i xenbr0 -o xenapi -m state --state
RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i xenapi -o xenbr0 -j ACCEPT
```

# Usage

## Converting a VirtualBox box file

* Download the box file (e.g. https://vagrantcloud.com/ubuntu/trusty64/version/1/provider/virtualbox.box)
* Unpack it:
```shell
mkdir tmp
cd tmp
tar xvf ../virtualbox.box
```
* Convert the disk image using qemu-img
```shell
qemu-img convert *.vmdk -O vpc box.vhd
```
* Remove the other files
```shell
rm -f Vagrantfile box.ovf metadata.json 
```
* Make a new metadata file
```shell
echo "{\"provider\": \"xenserver\"}" > metadata.json
```
* Create the box:
```shell
tar cf ../xenserver.box .
```
* Add the box:
```shell
vagrant box add ubuntu xenserver.box
```

## Create a Vagrantfile

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu"

  config.vm.provider :xenserver do |xs|
  xs.xs_host = "st29.uk.xensource.com"
  xs.xs_username = "root"
  xs.xs_password = "xenroot"
  xs.pv = true
  xs.memory = 2048
  end
end

```

and then you can do

```shell
vagrant up --provider=xenserver
```
