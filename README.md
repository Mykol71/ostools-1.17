---
ostools-1.17

Functionality -
---------------
- This ostools repo should be copied to a location accessible (and indexable) by httpd listing on port 80 to the outside world.
- Then, update the BACKEND= variable in updateos, as well as the url to the location of the updateos script, in the kickstart file(s).
- After the system has been kickstarted using the ks file, updateos will be availible to all users. (in the /usr/bin folder).
- updateos will download the scripts and exec them on every execution.
- Syntax for updateos is:
	updateos [OS] [scriptname or "stage"] (cmdlineopt1 opt2 opt3 opt4 opt5)
- OS = rh7, rh8, etc.
- scriptname is used if running a single task. EX: adduser
- If the script requires user input, add command line alternatives.
- If "stage" is specified, all scripts in the [OS]/stage/ folder will be executed. (intended to not require user input.)
- If a script fails during a "stage" run, updateos.sh exits non-zero immediately.
- Logging for updateos is in /tmp/updateos.log.

How to build custom boot install media -
----------------------------------------
1. Download boot.iso from redhat, and mount it with $mount -o loop ./boot.iso /mnt .
2. Copy the structure to a new folder. i.e. cp -rp /mnt/. ./newiso/.
3. Edit ./newiso/EFI/boot/grub.cfg and add the following to the first linux boot line:

	inst.ks=http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/RH8-RTI-silent.ks in	st.stage2=http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms

(Make any other edits you wish as well.)
4. cd ./newiso/.
5. sudo mkisofs -o /home/tfsupport/rh8-rti.iso -b isolinux/isolinux.bin -c isolinux/boot.cat --no-emul-boot --boot-load-size 4 --boot-info-table -J -R -V "Teleflora Linux POS" .

The resulting 900ish meg iso file can be then burned to a usb stick with any utility. i.e. rufus.

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

** Note: you will need to install a basis license, as well as run the EM_PWD script to set the enterprise manager password.**

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
? add help access for each script.
+ add ostools 1.16 to git.
+ move ostools 1.16 download package to repo server.
+ full path to commands in /usr/bin in case ran from cron. 

Key -
-----
- to do.
+ done.
~ in progress.
? consider.

mgreen@teleflora.com

---
