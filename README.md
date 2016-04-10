# Vagrant XenServer Provider

This is a Vagrant plugin that adds a XenServer provider, allowing Vagrant to
control and provision machines on a XenServer host.

## Dependencies
* Vagrant >= 1.5(?) (http://www.vagrantup.com/downloads.html)
* qemu-img

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

Make sure the default_SR is set, and that a VHD-based SR is in use. Currently the NFS SR is the recommended storage type.

# Usage

## Converting a VirtualBox box file

* Download the box file (e.g. https://vagrantcloud.com/ubuntu/trusty64/version/v20160323.1.0/provider/virtualbox.box)
* Unpack it:
```shell
mkdir tmp
cd tmp
tar xvf ../virtualbox.box
```
* Convert the disk image using qemu-img
```shell
qemu-img convert -O vpc *.vmdk box.vhd
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

## Converting a from an .xva file

* Download and compile [`xva-img`](https://github.com/eriklax/xva-img) tools
* Follow the instruction there on how to extract the `.xva` to get the `raw` image
* convert the `raw` image to be `vhd` file just like above instructions and follow the rest

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

Note that by default there will be no connection to the external network, so most configurations will require a `public_network` defined as in the above Vagrantfile

Another consideration is that if there is already DHCP service on `xenbr0` network (outside the XenServer), or you prefer to set static IP there, you should prevent the HIMN (Host Intermal Management Network) to be the default gateway. It can be done by running these commands in the Xenserver Host (as root):

```shell
himn=`xe network-list other-config:is_host_internal_management_network=true --minimal`
xe network-param-set uuid=$himn other-config:ip_disable_gw=true
```

To bring the VM up, it should then be as simple as

```shell
vagrant up --provider=xenserver
```

# NFS Synced Folder
To use NFS, please specify something like this in your `Vagrantfile`. See the [documentation](https://www.vagrantup.com/docs/synced-folders/nfs.html) for a complete reference

```
machine.vm.synced_folder ".", "/vagrant",
  id: "vagrant-root",
  disabled: false,
  type: "nfs",
  :nfs => true,
  :mount_options => ['nolock,vers=3,udp,noatime']
```

## Notes for Windows OS

* You must install `vagrant-winnfsd` plugin

```
vagrant plugin install vagrant-winnfsd
```

* You need to install the original [`winnfsd`](https://github.com/winnfsd/winnfsd/releases) or a [patched version](https://github.com/Yasushi/winnfsd/releases), and put the binary `winnfsd.exe` in `C:\HashiCorp\Vagrant\bin`

