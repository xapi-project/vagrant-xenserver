# Vagrant XenServer Provider

This is a Vagrant plugin that adds a XenServer provider, allowing Vagrant to
control and provision machines on a XenServer host.

## Dependencies
* Vagrant >= 1.5(?) (http://www.vagrantup.com/downloads.html)

## Installation
```shell
vagrant plugin install vagrant-xenserver
```

## XenServer host setup
N.B. Currently this will only work on XenServer 6.5 and later:
```shell
# Install netcat
yum install --enablerepo=base,extras --disablerepo=citrix -y nc
```

You will also need to copy your ssh key to the Xenserver host:

    ssh-copy-id root@xenserver


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
  config.vm.network "public_network", bridge: "xenbr0"
end

```
Note that by default there will be no connection to the external network, so most configurations will require a 'public_network' defined as in the above Vagrantfile.
To bring the VM up, it should then be as simple as

```shell
vagrant up --provider=xenserver
```
