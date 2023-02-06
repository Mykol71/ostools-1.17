---
updateos-1.17.2

```
Usage :
sudo updateos (groupname) (subgroupname|scriptname)

rh7/
 blcheck             Check common blacklists for public IP.
 config_sendgrid     Configures system to relay email through sendgrid. Need A
 install_cortex      Installs Cortex for IT managed malware protection.
 install_flordir     Install the POS Electronic Directory.
 install_kaseya      Install TF's kaseya agent.
 install_ostools-1.16Install legacy ostools.
 install_rti         Installs RTI 16.3.8 and all deps.
 realtime_disable    Disable RTI realtime.
 realtime_enable     Enable RTI Real time. (Must have been disabled by updateos
 register_insights   Register system with TF's Redhat insights account.
 rtirepo_install     
 speedtest           Check network speed.
 trendmicro_prod     Install Trendmicro and register with TF's account - produc
 trendmicro_qa       Install Trendmicro and register to TF's account - qa folde
 update_bbj_19.pl    Install and/or upgrade BBJ and Java.

rh8/
 blcheck             Check common blacklists for public IP.
 check_compliance    Must have already assigned this server to a compliance pro
 conf_firewall       Configures iptables for use with linux POS systems.
 conf_platform       Creates folders need by the POS installation.
 conf_users          Add POS system accounts.
 config_sendgrid     Configures system to relay email through sendgrid. Need A
 harden_system       Harden the system per PCI/PADSS guidelines.
 install_cortex      Installs Cortex for IT managed malware protection.
 install_flordir     Install the POS Electronic Directory.
 install_kaseya      Install TF's kaseya agent.
 install_ostools-1.16Install legacy ostools.
 install_rti         Installs RTI 16.3.8 and all deps.
 install_tcc         Install TF's CC processing program. (Used by POS software)
 install_ups         Install the APC UPS Daemon.
 osupgrade           Inplace OS upgrade from RH7 to RH8 - RTI.
 post_install        Creates a systemd service that will run after first reboot
 realtime_disable    Disable RTI realtime.
 realtime_enable     Enable RTI Real time. (Must have been disabled by updateos
 register_insights   Register system with TF's Redhat insights account.
 rh8repo_install     Configure system to receive patches from TF's repo server.
 sethostname         Set the server's hostname.
 setnet              Set/Change IP, DNS, and Gateway.
 smb_passwords       Creates initial samba passwords for POS system accounts.
 speedtest           Check network speed.
 system_auth         System authentication configuration.
 trendmicro_prod     Install Trendmicro and register with TF's account - produc
 trendmicro_qa       Install Trendmicro and register to TF's account - qa folde
 update_bbj_19.pl    Install and/or upgrade BBJ and Java.
 zz_email_results    Email staging results.
 stage/
```

_Staging_

1. Download the RH8.x install media iso.  

http://rhel8repo.centralus.cloudapp.azure.com/support/rh8-rti.iso

2. Use rufus or other utility to burn the iso to a blank usb stick.  
3. Boot from usb stick.  
4. At the grub boot menu, select "Install RTI on RHEL8".  
5. After the OS installs, the system will reboot. Then login as tfsupport - (normal daisy tfsupport password). You will be forced to change the tfsupport password on first login.  
6. if networking permits, kpugh and mgreen will get an email of the log file from the staging process.  
7. run RTI.

** You will need to install a basis license, as well as run the EM_PWD script to set the enterprise manager password.**

_OS Upgrade_

_RH7-RH8_

1. From the rh7 server to be upgraded download updateos, make it executable, and place it in /bin

http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/updateos

2. Run   

```
sudo updateos rh8 change_nics
```

3. Run

```
   sudo updateos rh8 osupgrade
```

** Only 1 kernel named NIC (ethX) allowed. **
** Process will take a bit of time. 2 hours or more. **

_Information_

- This ostools repo should be copied to a location accessible (and indexable) by httpd listing on port 80 to the outside world.
- Then, update the BACKEND= variable in updateos, as well as the url to the location of the updateos script, in the kickstart file(s).
- After the system has been kickstarted using the ks file, updateos will be availible  in the /bin folder.
- updateos will download the scripts and exec them on every execution.
- Prompting for user input is ok.
- If a script fails during a "group" run, updateos.sh exits non-zero immediately.
- Logging for updateos is in /tmp/updateos.log.

_How to build custom boot install media_

1. Download boot.iso from redhat, and mount it with
```
 mount -o loop ./boot.iso /mnt .
```
2. Copy the structure to a new folder.  Also make sure to get /mnt/.discinfo
```
cp -rp /mnt/. ./newiso/.
```
3. Edit ./newiso/EFI/boot/grub.cfg and add the following to the first linux boot line
```
inst.ks=http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/RH8-RTI-silent.ks inst.stage2=http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms net.ifnames=0
```
(Make any other edits you wish as well.)
4. Run
```
cd ./newiso/.
```
5. Run
```
sudo mkisofs -o /home/tfsupport/rh8-rti.iso -b isolinux/isolinux.bin -c isolinux/boot.cat --no-emul-boot --boot-load-size 4 --boot-info-table -J -R -V "Teleflora Linux POS" .
```
The resulting 900ish meg iso file can be then burned to a usb stick with any utility. i.e. rufus.

_Contrib Info_

- programs should exit 0 if success and non-0 if fail.
- already installed treat as success.
- programs in staging folders should not require user input. Staging should be a silent install.
- No need to add any logging.
- No need to use sudo to elevate priv.
- it's ok to install dependent rpms, but hopefully not necessary.
- if a new script is added, it is automatically available to all installations of ostools-1.17.
- if a change is checked in is related to a PCI/PA-DSS rule, note the PA-DSS rule in the commit info.
- if a change needs to be made, create a ticket in azure devops, and explain the details including the related pci rule etc.

_Repos_

http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.17/
http://rhel8repo.centralus.cloudapp.azure.com/ostools-1.16/
http://rhel8repo.centralus.cloudapp.azure.com/support/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-baseos-rpms/
http://rhel8repo.centralus.cloudapp.azure.com/rhel-8-for-x86_64-appstream-rpms/

mgreen@teleflora.com

---
