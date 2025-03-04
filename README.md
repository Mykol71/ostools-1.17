updateos
--------

about
-----
updateos is a core script that polls a configured repository backend for its supporting available commands (other scripts).
This core script handles logging, keeping the commands updated, etc. leaving the supporting scripts only needing the commands to do that task.

This script/repo hopefully improve a few areas.
  - Convert to a much simpler to maintain bash env for config management.
  - Handle the repetative coding, like logging, allowing the supporting scripts to just make changes.
  - Keep a central repo of scripts to make changes that will promote everyone using the same methods.
  - Provide a method to track one-offs for customers that have them.
  - Allow for a much faster start-to-end time developing OS changes for customers. (From the time the script is checked into the repo, it is available on all customers servers.)
  - This core script should not change much after it gets to a certain point.
  - Allow for anyone to contribute to the scripts supporting the systems if they wish.
  - Staging media doesnt have to change to make changes to the staging process.
  - Speed up the total time it takes to convert from major os version to version.
  - Simplify customer recovery in a DR situation.

```
Key
---
~ In progress
o Incomplete
+ Completed
? Unsure
= Current
^ Prod ready
```

install
-------
```
wget http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/updateos
chmod +x ./updateos 
cp ./updateos /usr/bin/updateos
updateos help
```

help
----
```
@  updateos - 2.1.3
)~ usage: sudo updateos (groupname|scriptname|help) [dry]
rh8                       p desc
---                       - ----
 blcheck                  ^ Check common blacklists for public IP.
 change_nics              ^ change nic namings from ethX to tfethX.
 conf_chrony              ^ Configures, starts, and enables chrony time sync.
 conf_firewall            ^ Configures iptables for use with linux POS systems.
 conf_platform            ^ Creates folders need by the POS installation.
 conf_users               ^ Add POS system accounts.
 config_sendgrid          ^ Configures Sendgrid. Need API Key and email from add.
 dss4_harden              - Makes security related system changes based on openscap rules for PCI-
 email_results            ^ Email log file.
 gfree_rules              - Firewall rules added for gravity free.
 harden_system            ^ Harden the system per PCI/PADSS guidelines.
 inc_format               ^ Formats sdb with 7 partitions for nightly backups.
 insights_scan            ^ Run a full insights scan. Includes compliance and malware scans.
 install_cortex           ^ Installs Cortex for IT managed malware protection.
 install_flordir          - Install the POS Electronic Directory.
 install_kaseya           ^ Install TF's kaseya agent.
 install_ostools-1.16     ^ Install legacy ostools.
 install_pbe              - Installs RTI Backup solution.
 install_racadm           ^ Install Dell's racadm software.
 install_rti              ^ Installs RTI 16.3.8 and all deps.
 install_tcc              ^ Install TF's CC processing program. (Used by POS software)
 install_ups              ^ Install the APC UPS Daemon.
 machine_specific         - This script checks the system serial number then sees if there is a cu
 osupgrade                - Inplace OS upgrade from RH8 to RH9 - RTI.
 passport_check           ^ Checks external device name and updates backups.config if needed.
 perceptions_install      - Collect "perceptive" data about the system.
 post_install             ^ Creates a systemd service that will run after first reboot only. (Afte
 post_install_rh9         ^ Creates a systemd service that will run after first reboot only. (Afte
 realtime_disable         - Disable RTI realtime.
 realtime_enable          - Enable RTI Real time. (had to be disabled by realtime_disable)
 register_insights        ^ Register system with TF's Redhat insights account.
 rh8repo_install          ^ Configure system to receive patches from TF's repo server.
 rti_email_fix            ^ add email fix for rh8 rti.
 rti_service_sleep        ^ add a 30sec sleep to the start portion of rti service file.
 sethostname              ^ Set the server's hostname.
 setnet                   ^ Set/Change IP, DNS, and Gateway.
 smb_passwords            ^ Set samba passwords for app users.
 speedtest                ^ Check network speed.
 sysinfo                  ^ Reports information about the server.
 system_auth              ^ System authentication configuration.
 tsr_install              ^ Adds a cron job to run the Dell TSR report and export it to the /usr2/
 update_bbj_19.pl         ^ Install and/or upgrade BBJ and Java.
 update_bbj_21.pl         ^ Installs/Upgrades BBj and java.
 update_blm.pl            ^ Update Basis BLM for correct license address
 uuid_switch              ^ Changes drive references in /etc/fstab to uuids instead of device name
group                     p desc
-----                     - ----
 CZW7RV1                  - Configs specific to this machine.
 padss4                   - Group for making pci-dss4.0 changes.
 stage                    ^ RTI rhel8 staging.
 wknoll                   ^ Walter Knoll customs
```
- only supporting scripts for the os version running are shown from the repo.
- this help checks all local copies of scripts and updates them if they have changed.
- the identifier before the description is the prod ready flag. ^=prod ready -=not.
- by default logging is in /tmp/updateos.log
- if no network, no group installs
- command line prompts given to updateos get passed on to a script exec
- the "dry" command line option after script cats the script to stdout, after a group shows the #HELP info and supporting scripts.

script exec
-----------
```
[tfsupport@RTIQA25 tmp]$ sudo updateos blcheck
[sudo] password for tfsupport: 
----> Wed Oct 30 13:35:01 CDT 2024 -  Running blcheck ...
IP 50.115.255.202 NAME ---
2024-10-30_18:35:02_UTC 202.255.115.50.cbl.abuseat.org.        ---
2024-10-30_18:35:02_UTC 202.255.115.50.dnsbl.sorbs.net.        ---
2024-10-30_18:35:03_UTC 202.255.115.50.bl.spamcop.net.         ---
2024-10-30_18:35:03_UTC 202.255.115.50.zen.spamhaus.org.       ---
2024-10-30_18:35:03_UTC 202.255.115.50.b.barracudacentral.org. ---
2024-10-30_18:35:03_UTC 202.255.115.50.bl.mailspike.net.       ---
----> Wed Oct 30 13:35:03 CDT 2024 - Success.
[tfsupport@RTIQA25 tmp]$
```

group exec 
----------
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

script help
-----------
- Pulled from the #HELP lines in the script (blcheck).
```
sudo updateos blcheck help
blcheck -
--------- 
Takes public IP command line arg.
If none, uses current public IP.
Example: $sudo updateos blcheck 42.43.44.45
```
- Pulled from the #HELP lines in the script (blcheck).

group dry
---------
- Displays #HELP info in readme.md, and a list of the supporting script names.

```
sudo updateos wknoll dry
Walter Knoll custom information
-------------------------------
uses unform for printing.
uses postfix instead of sendmail. And relays through an smtp relay he configured in AWS.

20_email_setup
30_printing
```

script dry
----------
- Displays script.

```
sudo updateos sethostname dry
#!/bin/bash

#DESC Set the server's hostname.
[ -f /usr2/upgrade/hostname ] && NAME="`cat /usr2/upgrade/hostname`"
[ "$NAME" == "" ] && echo -n "Enter Hostname: " && read NAME

hostnamectl set-hostname "$NAME"

IP="`hostname -I | cut -d" " -f1`"
sed -i "/$IP/d" /etc/hosts
echo "$IP       $NAME    $NAME.teleflora.com" >>/etc/hosts
```

```
sudo updateos wknoll
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

updateos-2.2.6
--------------
```
-

```

= updateos-2.1.3
----------------
```
+ group desc. (displays README.md #DESC for group.)
+ group #PRDno flag support
+ $updateos (groupname) dry shows #HELP from the group README.md file as well as a list of the scripts in that group.
+ $updateos (scriptname) dry echos the script to stdout instead of execing.
+ cosmetic changes
+ pa-dss report via openscap
+ check for customs via service tag
```

updateos-1.9.7
--------------
```
+ enable/disable script for prod use? (if not prod-ready prompt for exec.) (replace nopub)
+ add indicator to help dialog if script is not prod ready
+ wknoll group with his customs
+ group script calling another group? (nested groups)
```

updateos-1.8.3
--------------
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

future
------
```
o training
  - general use
  - contrib
o logfile location, rotation, and retention
```

-------
contrib 
-------
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

special strings
---------------
updateos looks for the following key strings in the supporting scripts, and if there, uses the lines per the table.

```
#DESC	- populates the "desc" field on the help outputs.
#HELP   - populates the output when '$updateos command' help is ran.
#PRDno  - if in script, will be warned that the script has not been tested before running. Also used to populate the "p" field on the help output.
```

script example
--------------
```
#!/bin/bash
set -e

#DESC Script that serves this purpose
#PRDno To prompt before execing the script warning of non-prod use.
#HELP usage: $updateos testscript

  echo "This will show in stout and the logfile."

exit $?
```

group example
-------------
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
- There is a hash hash_files script in the root dir of this repo to rebuild the md5 sums for the scripts. Do this prior to checkin. 

staging
-------
- Download the RTI RH8.x install media iso  
```
http://rhel8repo.centralus.cloudapp.azure.com/support/rh8-rti.iso
```
- Use rufus or other utility to burn the iso to a blank usb stick 
- Boot from usb stick  
- At the grub boot menu, select "Install RTI on RHEL8"  
- After the OS installs, the system will reboot. Then login as tfsupport with the default password. You will be forced to change the tfsupport password on first login  
- Install a basis license
- Run EM_PWD script to set the enterprise manager password.
- machine_specific; the last script ran during the stage folder exec, is a machine_specific script. That script, checks to see if there is a group name matching the current system serial number, and if it exists, execs the group.

hosting
-------
- This updateos repo should be copied to a location accessible (and indexable) by httpd listing on port 80 to the outside world.
- Then, update the BACKEND= variable in updateos, as well as the url to the location in the kickstart file(s).
- After that, use your altered updateos script to install on supported systems.

repos
-----
```
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.16/
http://rhel8repo.centralus.cloudapp.azure.com/support/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-appstream-rpms/
```

maintainer
----------
```
mgreen@teleflora.com
```
