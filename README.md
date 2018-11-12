# Vagrant XenServer Provider

This is a Vagrant plugin that adds a XenServer provider, allowing Vagrant to
control and provision machines on a XenServer host.

## Dependencies
* Vagrant >= 1.5 (http://www.vagrantup.com/downloads.html)
* qemu-img

## Installation
```shell
vagrant plugin install vagrant-xenserver
```

# XenServer setup

Make sure the default_SR is set, and that a VHD-based SR is in
use. Currently the NFS SR is the recommended storage type.

# Usage

## Boxes

Vagrant-xenserver supports 3 types of boxes today. These are:

1. XVA URL - the box simply contains a URL that points to an XVA
   (XenServer export) file.
2. XVA - the box contains an XVA (XenServer export).
3. VHD - the box contains a VHD file.

The recommended format is either 1 or 2, and it is suggested that
Packer is used to create the XVA files, which is available from
https://github.com/xenserver/packer-builder-xenserver . If this is not
available, there is an example script in the `example_box` directory
that automatically installs a Debian Wheezy guest and exports it. Once
an XVA file has been built, this can be turned into a box by archiving
it with `tar` with an included `metadata.json` and optionally a
`Vagrantfile`. For example, assuming an XVA has been created called
`ubuntu-15.10-amd64.xva`, to create an XVA URL box, upload the XVA to
your webserver and execute the following:

```shell
echo "{\"provider\": \"xenserver\"}" > metadata.json
cat > Vagrantfile <<EOF
Vagrant.configure(2) do |config|
  config.vm.provider :xenserver do |xs|
    xs.xva_url = "http://my.web.server/ubuntu-15.10-amd64.xva"
  end
end
EOF
tar cf ubuntu.box metadata.json Vagrantfile
```

Or to create an XVA box:

```shell
echo "{\"provider\": \"xenserver\"}" > metadata.json
cp /path/to/ubuntu-15.10-amd64.xva box.xva
tar cf ubuntu.box metadata.json box.xva
```

VHD based boxes are useful if you are converting from a box from
another provider. For example, to convert a VirtualBox box file:

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
tar cf ../ubuntu.box .
```

Note that since v0.0.12, vagrant-xenserver will assume by default that
boxes have the XenServer tools installed, which may not be the case
for converted boxes.

## Add the box

Once you've created your box, this can simply be added to vagrant with
the following:

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
    xs.use_himn = false
  end

  config.vm.network "public_network", bridge: "xenbr0"
end
```

Note that by default there will be no connection to the external
network, so most configurations will require a 'public_network'
defined as in the above Vagrantfile.  To bring the VM up, it should
then be as simple as

```shell
vagrant up --provider=xenserver
```

## XenServer host setup for HIMN forwarding

Since v0.0.12, boxes are assumed to have XenServer tools installed to
report the IP address. If the tools are not installed in the box, the
plugin supports using the 'host internal management network' (HIMN),
which is an internal-only network on which a DHCP server runs. Use of
this requires additional setup of dom0:

N.B. Currently this will only work on XenServer 6.5 and later.
You will need to copy your ssh key to the Xenserver host:

    ssh-copy-id root@xenserver

# Changes since 0.0.11
Note that since v0.0.11 the use of the host internal management network is now
not default. For backwards compatibility, add `use_himn = true` to the provider
specific settings in the Vagrantfile. For example:

```ruby
  config.vm.provider :xenserver do |xs|
    xs.use_himn = true
  end
```


