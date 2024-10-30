updateos
--------
```
Key
---
~ In progress
o Incomplete
+ Completed
? Unsure
= Current
```

updateos future
---------------
```
? consider an agent
  - run now trigger
  - on-demand remote ssh access
o training
  - general use
  - contrib
? server status
  - patches available
  - malware
  - scada compliance
  - last backup status
```

updateos 1.9.2
--------------
```
+ enable/disable script for prod use? (if not prod-ready prompt for exec.) (replace nopub)
+ add indicator to help dialog if script is not prod ready
+ wknoll group with his customs
~ group desc. (displays readme DESC for group.) $updateos help group
+ group script calling another group? (nested groups)
```

= updateos 1.8.3
----------------
```
+ pass command line vars through to sub script
+ added "help" for sub scripts. (searches for HELP in script.)
+ only download if md5 sums are different
+ work if no network. (via the scripts stored in /usr/bin/.updateos)
+ streamline/cleanup code a bit 
```

updateos-1.17.2
---------------
```
+ initial release
```




Script Contrib Info 
-------------------
```
- Exit 0 if success, non-0 is fail
- if test for already done and is, exit 0 success
- command line args 2-* are passed to sub script command line args
- #DESC in the script shows as the desc in $updateos help
- #HELP in the script shows those lines in $updateos script help
- Script must be able to run many times but only make changes once
- group scripts with no user interaction
- #PRDno in script triggers a warning before exec
```

Script Example
--------------
```
#!/bin/bash

#DESC Script that serves this purpose
#PRDno 
#HELP usage: $updateos testscript

echo "This will show in stout and the logfile."

exit 0
```

Repo Locations
--------------
```
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.16/
http://rhel8repo.centralus.cloudapp.azure.com/support/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-appstream-rpms/
```


Install Media / Staging
-----------------------
- Download the RTI RH8.x install media iso  

http://rhel8repo.centralus.cloudapp.azure.com/support/rh8-rti.iso

- Use rufus or other utility to burn the iso to a blank usb stick 
- Boot from usb stick  
- At the grub boot menu, select "Install RTI on RHEL8"  
- After the OS installs, the system will reboot. Then login as tfsupport - (normal daisy tfsupport password). You will be forced to change the tfsupport password on first login  
- If networking permits, kpugh and mgreen will get an email of the log file from the staging process  
- Run RTI

** You will need to install a basis license, as well as run the EM_PWD script to set the enterprise manager password.**


Installation and Information
----------------------------
- This ostools repo should be copied to a location accessible (and indexable) by httpd listing on port 80 to the outside world.
- Then, update the BACKEND= variable in updateos, as well as the url to the location of the updateos script, in the kickstart file(s).
- If a script fails during a "group" run, updateos exits non-zero immediately.
- Logging for updateos is in /tmp/updateos.log.


Custom Install Media
--------------------
- Download boot.iso from redhat, and mount it with
```
 mount -o loop ./boot.iso /mnt .
```
- Copy the structure to a new folder.  Also make sure to get /mnt/.discinfo
```
cp -rp /mnt/. ./newiso/.
```
- Edit ./newiso/EFI/boot/grub.cfg and add the following to the first linux boot line
```
inst.ks=http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/RH8-RTI-silent.ks inst.stage2=http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms net.ifnames=0
```
(Make any other edits you wish as well.)
- Run
```
cd ./newiso/.
sudo mkisofs -o /home/tfsupport/rh8-rti.iso -b isolinux/isolinux.bin -c isolinux/boot.cat --no-emul-boot --boot-load-size 4 --boot-info-table -J -R -V "Teleflora Linux POS" .
```
- The resulting 900ish meg iso file can be then burned to a usb stick with any utility. i.e. rufus.


Maintainer
----------
mgreen@teleflora.com
