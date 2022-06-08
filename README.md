# ostools-1.17


Functionality -
---------------
- This ostools repo should be copied to a location accessible (and indexable) by httpd listing on port 80 to the outside world.
- Then, update the BACKEND= variable in updateos, as well as the url to the location of the updateos script, in the kickstart file(s).
- After the system has been kickstarted using the ks file, updateos will be availible to all users. (in the /usr/bin folder).
- updateos will download the scripts and exec them on every execution.
- Syntax for updateos is:
	updateos.sh [OS] [scriptname or "stage"] (cmdlineopt1 opt2 opt3 opt4 opt5)
- OS = rh7, rh8, etc.
- scriptname is used if running a single task. EX: adduser
- If the script requires user input, add command line alternatives.
- If "stage" is specified, all scripts in the [OS]/stage/ folder will be executed. (intended to not require user input.)
- If a script fails during a "stage" run, updateos.sh exits non-zero immediately.
- Logging for updateos.sh is in /tmp/updateos.sh.log.


How to build custom boot install media -
----------------------------------------


Contrib Info -
--------------
- programs should exit 0 if success and non-0 if fail.
- already installed treat as success.
- programs in staging folders should not require user input. Staging should be a silent install.
- No need to add any logging.
- No need to use sudo to elevate priv.
- it's ok to install dependent rpms, but hopefully not necessary.
- if a new script is added, it is automatically available to all installations of ostools-1.17.
- if a change is checked in is related to a PCI/PA-DSS rule, note the PA-DSS rule in the commit info.



Staging Instructions -
----------------------

Repos -
-------
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.16/
http://rhel8repo.centralus.cloudapp.azure.com/support/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-appstream-rpms/

Steps -
-------
1. Download the RH8.x install media iso from the support repo (link above).

2. Use rufus or other utility to burn the iso to a blank usb stick.

3. Boot from usb stick.

4. At the grub boot menu, select "Install RTI on RHEL8".

5. After the OS installs, the system will reboot. Then login as tfsupport - (normal daisy tfsupport password). You will be forced to change the tfsupport password on first login.

6. if networking permits, kpugh and mgreen will get an email of the log file from the staging process.

7. run RTI:
$linuxbbx

Information -
-------------
- tcc is installed.
- bbj 19 is installed.
- kaseya is installed.
- system is registered with redhat insights.
- system is registered to the TF RH8 repo for patches.
- ostools 1.16 is installed.
- ostools 1.16 is ostools 1.15 with RH8 support.
- ostools 1.17 is this.
- there is also an -nvm.ks version of the kickstart file for nvm ssd support.
** take note that $updateos and $updateos.pl are both on the system and do different things. 
     Make sure, on step 6 above, you execute $updateos **

/usr/bin/updateos syntax -
--------------------------
- $updateos {os version} {script name or "stage"}
- $updateos only will display a list of possible os versions.
- $updateos {os version} only will display a list of possible scripts.



TO DO -
-------
- add help access for each script.
+ add logging function to updateos.
? add a cacheing situation for making the commands available without network.
+ add ostools 1.16 to git.
+ move ostools 1.16 download package to repo server.
- 


mgreen@teleflora.com
