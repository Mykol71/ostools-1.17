---
RHEL8

TO DO -
-------
+ tfremote access issue. (ssh to 15022 timesout. no errors in logs.)
+ update RTI iso.
+ console screen reso. remove irroneous nomodeset.
+ build custom iso. boot options for localboot, install, and upgrade.
+ smb users default passwords.
+ auditd fixes.
- rh8 tcc. upgrade ron's test VM so Moth can use to compile tcc.
+ download rti iso bug.
+ find a upsd rpm for rh8 and publish in our repo.
+ 640x480 reso.
+ rti background program start up issue. (installing bbj18, bbj19, then java, fixes but adds wasted time.)
+ backspace issues from ssh connection. (scoansi term type not found.)
+ test rtibackup.pl.
+ test tfrsync.pl --cloud.
+ test tfrsync.pl --server.
+ logging to anaconda console during %post section of kickstart. 
+ update ostools version info in 1.16. (for logging etc.)
+ errors logged to console.
- rear support/integration. (Relax and Recover)
+ build qa vms.
- update tfrsync.pl with bug fixes from kevin and joe to 1.16 repo.
- update tfrsync.pl with fixes for cloud backup warnings 23,24 to 1.16 repo.
- merge in server-to-server tfrsync.pl fixes to ostools-1.16 repo.
+ document how to create usb media.
+ test kaseya processes.
- make backups and os migrations "sendgrid aware".
+ add os media isos to repo server.
+ display issue for silent install when registering with insights.  
+ iptables issue because of perl local ip issue.
- in-place os upgrade process from rh7 to rh8.
+ users custom .bash_profile creation.
+ term backspace issue. (needed ncurses-term.)
+ iptables config issue when in %post of ks. Works after login.
+ no pam_tally2. Need to be sure to test password management. And let support know.
+ no post install updateos works. cannot find the temp download of the script.     
~ check pa-dss insights data for corrections.
+ qa rh8 vms.
~ devel rh8 vm.
+ configure compliance portion of redhat insights.
+ add compliance check script.
~ switch back to eth0,1 naming conventions. (need to reproduce .iso)
+ switch to symlinks for groups.   
+ add #DESC comments.
+ sethostname script.
+ reversed /etc/hosts syntax for hostnames in ostools-1.16.
+ net info change script.
-  

Key:
----
+ Done.
- To Do.
~ In progress.
? Consider.

mgreen@teleflora.com

---
