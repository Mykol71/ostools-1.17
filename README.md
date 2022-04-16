# ostools-1.17

Functionality -

- This ostools repo should be copied to a location accessible (and indexable) by httpd listing on port 80 to the outside world.
- Then, update the BACKEND= variable in updateos, as well as the url to the location of the updateos script, in the kickstart file(s).
- After the system has been kickstarted using the ks file, updateos will be availible to all users. (in the /usr/bin folder).
- updateos will download the scripts and exec them on every execution.
- there is a "cached" version of the programs for use when the internet connection is not available.
- Syntax for updateos is:
	updateos.sh [OS] [scriptname or "stage"] (cmdlineopt1 opt2 opt3 opt4 opt5)
- OS = rh7, rh8, etc.
- scriptname is used if running a single task. EX: adduser
- If the script requires user input, add command line alternatives.
- If "stage" is specified, all scripts in the [OS]/stage/ folder will be executed. (intended to not require user input.)
- If a script fails during a "stage" run, updateos.sh exits non-zero immediately.
- Logging for updateos.sh is in /tmp/updateos.sh.log.
- 

Contrib Info -

- programs should exit 0 if success and non-0 if fail.
- already installed treat as success.
- programs in staging folders should not require user input. Staging should be a silent install.
- No need to add any logging.
- No need to use sudo to elevate priv.
- it's ok to install dependent rpms, but hopefully not necessary.
- if a new script is added, it is automatically available to all installations of ostools-1.17.
- if a change is checked in is related to a PCI/PA-DSS rule, note the PA-DSS rule in the commit info.

To Do -

- add ostools legacy deps.
- documentation.
- genericize OS to folder name.
- genericize stage to any subfolder name.
- add logging function to updateos.
- genericize ks file for use on all POS systems. Then, add fs remount to platform program.
- 

# mgreen@teleflora.com
