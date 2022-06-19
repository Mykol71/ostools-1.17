#version=RHEL8
text
authselect --passalgo=sha512 --useshadow
selinux --permissive
reboot
bootloader --append="video=640x480 net.ifnames=0"
repo --name="AppStream" --baseurl=http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-appstream-rpms
repo --name="BaseOS" --baseurl=http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms

%packages
@^minimal-environment
@system-tools
aide
audispd-plugins
libreswan
opensc
openscap
openscap-scanner
pcsc-lite
scap-security-guide
net-tools
java
perl
wget
mailx
procmail
bind-utils
ksh
expect
-firewalld
iptables
iptables-services
samba
cups
chrony
ntpstat
telnet
fetchmail
rsyslog
python2
rear
java
sed
lrzsz
ncurses-term
rsync
grub2-efi-x64-modules
grub2-tools-efi
sendmail
%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s20f0u3 --ipv6=no --activate
network  --hostname=rhel8-rti.teleflora.com

url --url=http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms/BaseOS

# Run the Setup Agent on first boot
firstboot --disable

ignoredisk --only-use=sda
# Partition clearing information
zerombr
clearpart --all --initlabel
# Disk partitioning information
part /usr2 --fstype="xfs" --onpart=sda3 --noformat
part swap --fstype="swap" --ondisk=sda --recommended
part /boot/efi --fstype="efi" --ondisk=sda --size=600 --fsoptions="umask=0077,shortname=tflinux"
part / --fstype="xfs" --ondisk=sda --size=30000

# System timezone
timezone America/Winnipeg --isUtc

# Root password
#rootpw --iscrypted $2b$10$jBk4hLcfILSSTDA5m7EjduMFKYKjBLfCppM4QUsWZF/JbXVmxpqbi
rootpw --iscrypted $6$G/P1TGIsGMWZ9aak$Sm/HZ1fcdfdmTdy4k2BTMv9Sw.mQOhrgtvMD5e8oo7t3uCtX2T005e/afw46a6TkODKkP8b9SrUgSAnjKxxfi1
user --groups=wheel --name=tfsupport --password=$6$G/P1TGIsGMWZ9aak$Sm/HZ1fcdfdmTdy4k2BTMv9Sw.mQOhrgtvMD5e8oo7t3uCtX2T005e/afw46a6TkODKkP8b9SrUgSAnjKxxfi1 --iscrypted --gecos="tfsupport"

%addon com_redhat_kdump --disable --reserve-mb='auto'
%end

%addon org_fedora_oscap
    content-type = scap-security-guide
    datastream-id = scap_org.open-scap_datastream_from_xccdf_ssg-rhel8-xccdf-1.2.xml
    xccdf-id = scap_org.open-scap_cref_ssg-rhel8-xccdf-1.2.xml
    profile = xccdf_org.ssgproject.content_profile_pci-dss
%end


%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

%post
cd /usr/bin
curl -O http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/updateos updateos
chmod +x /usr/bin/updateos
systemctl start sendmail
systemctl start smb
systemctl start cups
systemctl start iptables
systemctl enable sendmail
systemctl enable smb
systemctl enable cups
systemctl enable iptables
ln -s /usr/bin/python2.7 /usr/bin/python
openvt -s -w -- /usr/bin/updateos rh8 osup rh8-rti 2>&1
%end
