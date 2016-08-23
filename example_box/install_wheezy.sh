#!/bin/bash

set -e
set -x

SERVER=$1 
USERNAME=$2
PASSWORD=$3
VMNAME=wheezy
DOMAINNAME=local

SERVERIP=`dig +search +short $SERVER`

if [ "x$SERVERIP" == "x" ]; then
	SERVERIP=$SERVER
fi

template=`ssh root@$SERVER "xe template-list name-label='Debian Wheezy 7.0 (64-bit)' --minimal"`
vm=`ssh root@$SERVER xe vm-install template=$template new-name-label=$VMNAME`
network=`ssh root@$SERVER xe network-list bridge=xenbr0 --minimal`
vif=`ssh root@$SERVER xe vif-create vm-uuid=$vm network-uuid=$network device=0`
ssh root@$SERVER xe vm-cd-add uuid=$vm cd-name=guest-tools.iso device=3 || ssh root@$SERVER xe vm-cd-add uuid=$vm cd-name=xs-tools.iso device=3

preseed_blob=`ssh root@$SERVER xe blob-create vm-uuid=$vm name=preseed public=true`
preseed_file=/tmp/preseed

postinstall_blob=`ssh root@$SERVER xe blob-create vm-uuid=$vm name=postinstall public=true`
postinstall_file=/tmp/postinstall

cat > $preseed_file <<EOF
d-i	debian-installer/locale	 	string en_GB
d-i	keyboard-configuration/layoutcode string en_GB
d-i	keyboard-configuration/xkb-keymap string en_GB
d-i	mirror/country			string manual
d-i	mirror/http/hostname		string ftp.uk.debian.org
d-i	mirror/http/directory		string /debian/
d-i	mirror/http/proxy		string 
#d-i	debian-installer/allow_unauthenticated	string true
#d-i	anna/no_kernel_modules		boolean true
d-i	time/zone string		string Europe/London
d-i	partman-auto/method		string regular
d-i	partman-auto/choose_recipe \
		select All files in one partition (recommended for new users)
d-i	partman/confirm_write_new_label	boolean true
d-i	partman/choose_partition \
		select Finish partitioning and write changes to disk
d-i	partman/confirm			boolean true
d-i	partman/confirm_nooverwrite	boolean true

d-i	passwd/make-user		boolean true

d-i passwd/user-fullname string vagrant
d-i passwd/user-password password vagrant
d-i passwd/user-password-again password vagrant
d-i passwd/username string vagrant

d-i passwd/root-password-again password vagrant
d-i passwd/root-password password vagrant

d-i apt-setup/local0/repository string http://www.uk.xensource.com/deb-guest lenny main
d-i debian-installer/allow_unauthenticated boolean true

popularity-contest	popularity-contest/participate	boolean	false
tasksel	tasksel/first			multiselect standard
d-i pkgsel/include string openssh-server vim ntp ethtool tpcdump bridge-util rsync ssmtp strace gdb build-essential xe-guest-utilities wget sudo
#d-i	mirror/udeb/suite		string squeeze
#d-i	mirror/suite			string squeeze
#d-i	mirror/udeb/suite		string sid
#d-i	mirror/suite			string sid
d-i	grub-installer/only_debian	boolean true
d-i grub-installer/with_other_os boolean true
d-i preseed/late_command string \
wget http://$SERVERIP/blob?uuid=$postinstall_blob -O /target/post_install.sh;\
chmod 755 /target/post_install.sh; \
chroot /target /post_install.sh

d-i	finish-install/reboot_in_progress	note
#d-i	debian-installer/exit/poweroff	boolean true
#d-i	debian-installer/exit/always_halt boolean true
#d-i debian-installer/exit/poweroff boolean true

EOF

cat > $postinstall_file <<EOF
#!/bin/bash

mount /dev/xvdd /mnt
cd /mnt/Linux
./install.sh -n

mkdir ~vagrant/.ssh
wget --no-check-certificate \
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O ~vagrant/.ssh/authorized_keys
chown -R vagrant ~vagrant/.ssh
chmod -R go-rwsx ~vagrant/.ssh

echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99_vagrant
chmod 440 /etc/sudoers.d/99_vagrant

EOF

scp $preseed_file root@$SERVER:$preseed_file
scp $postinstall_file root@$SERVER:$postinstall_file

ssh root@$SERVER xe blob-put uuid=$preseed_blob filename=$preseed_file
rm $preseed_file
ssh root@$SERVER rm $preseed_file

ssh root@$SERVER xe blob-put uuid=$postinstall_blob filename=$postinstall_file
rm $postinstall_file
ssh root@$SERVER rm $postinstall_file

ssh root@$SERVER xe vm-param-set uuid=$vm other-config:install-repository=http://ftp.uk.debian.org/debian other-config:debian-release=wheezy
ssh root@$SERVER "xe vm-param-set uuid=$vm PV-args=\"auto-install/enable=true url=http://$SERVERIP/blob?uuid=$preseed_blob interface=auto netcfg/dhcp_timeout=600 hostname=$VMNAME domain=$DOMAINNAME\""
ssh root@$SERVER xe vm-start uuid=$vm

sleep 30

starttime=`ssh root@$SERVER xe vm-param-get uuid=$vm param-name=start-time`
ssh root@$SERVER xe event-wait class=vm uuid=$vm start-time=/=$starttime
echo "rebooted..."
ssh root@$SERVER xe event-wait class=vm uuid=$vm networks=/=
echo "networks detected"
ssh root@$SERVER xe vm-shutdown uuid=$vm
echo $vm


