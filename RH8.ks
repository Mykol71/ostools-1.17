#version=RHEL8
# Use graphical install
text

#repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream
repo --name="AppStream" --baseurl=http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-appstream-rpms

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

%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s20f0u3 --ipv6=auto --activate
network  --bootproto=dhcp --device=enp0s31f6 --onboot=off --ipv6=auto
network  --hostname=rhel8-rti

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=nvme0n1
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /usr2 --fstype="xfs" --ondisk=nvme0n1 --size=102400
part /usr2_mir --fstype="xfs" --ondisk=nvme0n1 --size=102400
part /home --fstype="xfs" --ondisk=nvme0n1 --size=51630
part swap --fstype="swap" --ondisk=nvme0n1 --size=12039
part /boot --fstype="xfs" --ondisk=nvme0n1 --size=1024
part /boot/efi --fstype="efi" --ondisk=nvme0n1 --size=600 --fsoptions="umask=0077,shortname=winnt"
part / --fstype="xfs" --ondisk=nvme0n1 --size=71680

# System timezone
timezone America/Winnipeg --isUtc --nontp

# Root password
rootpw --iscrypted $6$AVmkgYT45RqfKjna$SEKy20dsIglzxXwyDs1vV.IfEvRtSNxJhWu5aqtKIhgJi2J/Mw9fqczbkVKiKjlJRx8pBdPYTGEyPwVPCJLbs.
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