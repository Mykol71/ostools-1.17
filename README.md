updateos
--------

purpose
-------
This script/repo hopefully address a few issues.
  - Convert from perl to a much simpler to mainting bash env for config management.
  - Handle the repetative coding, like logging, allowing the supporting scripts to just make changes.
  - Keep a central repo of methods to make changes that will promote everyone using the same method.
  - Provide a method to track one-off customers for customers that have them. (So we don't get caught with misconfigured systems for days after a major upgrade of some kind.)
  - Allow for a much faster start-to-end time developing OS changes for customers. (From the time the script is checked into the repo, it is available on all customers servers.)
  - Hopefully this core script will not change much after it gets to a certain point.
  - Allow for anyone to contribute to the scripts supporting the systems if they wish.
  - Staging media doesnt have to change to make changes to the staging process.
  - Speed up the total time it takes to convert from major os version to version.


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
? major feature ideas
  - patches available
  - malware
  - scada compliance
  - backup status
  - sonarcube?
o documentation
  - help for supporting scripts
o logfile rotation and retention
```

updateos-1.9.2
--------------
```
+ enable/disable script for prod use? (if not prod-ready prompt for exec.) (replace nopub)
+ add indicator to help dialog if script is not prod ready
+ wknoll group with his customs
~ group desc. (displays readme DESC for group.) $updateos help group
+ group script calling another group? (nested groups)
o psdss4 group for pci rule related changes
```

= updateos-1.8.3
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




script contrib info 
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

script example
--------------
```
#!/bin/bash

#DESC Script that serves this purpose
#PRDno To prompt before execing the script warning of non-prod use.
#HELP usage: $updateos testscript

  echo "This will show in stout and the logfile."

exit 0
```

group example for customs
-------------------------
```
bash-4.2$ ls -ltr ./rh8/wknoll | grep -v md5
total 20
-rw-rw-rw-. 1 mgreen rti  28 Oct 29 17:41 README.md
-rwxrwxrwx. 1 mgreen rti 144 Oct 29 17:45 20_email_setup
-rwxrwxrwx. 1 mgreen rti 201 Oct 29 17:48 30_printing
```

- The above example uses a group to track differences from the standard setup for a specific customer.
- Right now, they do nothing but echo information. But that could be enough. Just check the log file after you run for instructions.
- The person that stages the system would check $updateos help to see if a group for the customer exists, and if so, run that group. ($updateos wknoll). Then check the logs.

```
[tfsupport@RTIQA25 tmp]$ sudo updateos wknoll
[sudo] password for tfsupport: 
Sorry, try again.
[sudo] password for tfsupport: 
----> Wed Oct 30 10:59:06 CDT 2024 - Running rh8 wknoll 20_email_setup...
No match for argument: sendmail
No packages marked for removal.
Dependencies resolved.
Nothing to do.
Complete!
Last metadata expiration check: 2:39:06 ago on Wed 30 Oct 2024 08:20:04 AM CDT.
Package postfix-2:3.5.8-7.el8.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
----> Wed Oct 30 10:59:14 CDT 2024 - Success.
----> Wed Oct 30 10:59:14 CDT 2024 - Running rh8 wknoll 30_printing...
Walter uses unform to route printing through. Make sure the unform product is installed and started.
----> Wed Oct 30 10:59:14 CDT 2024 - Success.
```

group example for staging
-------------------------
```
bash-4.2$ ls -ltr ./rh8/stage
total 4
lrwxrwxrwx. 1 mgreen rti  16 Apr 23  2024 zz_email_results -> ../email_results
lrwxrwxrwx. 1 mgreen rti  15 Apr 23  2024 yz_post_install -> ../post_install
lrwxrwxrwx. 1 mgreen rti  14 Apr 23  2024 70_conf_chrony -> ../conf_chrony
lrwxrwxrwx. 1 mgreen rti  17 Apr 23  2024 65_install_kaseya -> ../install_kaseya
lrwxrwxrwx. 1 mgreen rti  20 Apr 23  2024 60_rti_service_sleep -> ../rti_service_sleep
lrwxrwxrwx. 1 mgreen rti  14 Apr 23  2024 50_change_nics -> ../change_nics
lrwxrwxrwx. 1 mgreen rti  14 Apr 23  2024 46_system_auth -> ../system_auth
lrwxrwxrwx. 1 mgreen rti  16 Apr 23  2024 45_harden_system -> ../harden_system
lrwxrwxrwx. 1 mgreen rti  14 Apr 23  2024 43_install_ups -> ../install_ups
lrwxrwxrwx. 1 mgreen rti  14 Apr 23  2024 20_install_tcc -> ../install_tcc
lrwxrwxrwx. 1 mgreen rti  16 Apr 23  2024 17_smb_passwords -> ../smb_passwords
lrwxrwxrwx. 1 mgreen rti  14 Apr 23  2024 15_install_rti -> ../install_rti
lrwxrwxrwx. 1 mgreen rti  23 Apr 23  2024 14_install_ostools-1.16 -> ../install_ostools-1.16
-rwxrwxrwx. 1 mgreen rti 278 Apr 23  2024 13_sethostname
lrwxrwxrwx. 1 mgreen rti  13 Apr 23  2024 10_conf_users -> ../conf_users
lrwxrwxrwx. 1 mgreen rti  16 Apr 23  2024 04_conf_platform -> ../conf_platform
lrwxrwxrwx. 1 mgreen rti  18 Apr 23  2024 01_rh8repo_install -> ../rh8repo_install
lrwxrwxrwx. 1 mgreen rti  16 Jun 17 16:02 75_rti_email_fix -> ../rti_email_fix
lrwxrwxrwx. 1 mgreen rti  16 Aug 29 13:35 85_install_idrac -> ../install_idrac
lrwxrwxrwx. 1 mgreen rti  14 Oct 15 10:11 77_uuid_switch -> ../uuid_switch
```
- Only make copies of scripts if you plan to alter the one in the parent folder. Otherwise use a symlink.
- Use numbering at the front of the file or link name to force ordering of script exec.
- Do not use any scripts that are flagged "PRDno". Staging should be a totally silent install.


repo locations
--------------
```
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.16/
http://rhel8repo.centralus.cloudapp.azure.com/support/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-appstream-rpms/
```


install media / staging
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


installation and information
----------------------------
- This ostools repo should be copied to a location accessible (and indexable) by httpd listing on port 80 to the outside world.
- Then, update the BACKEND= variable in updateos, as well as the url to the location of the updateos script, in the kickstart file(s).
- If a script fails during a "group" run, updateos exits non-zero immediately.
- Logging for updateos is in /tmp/updateos.log.


maintainer
----------
mgreen@teleflora.com
