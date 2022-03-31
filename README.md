# ostools-1.17

Functionality -

- This ostools repo should be copied to a location accessible (and indexable) by httpd listing on port 80 to the outside world.
- updateos.sh will download the scripts and exec them on every execution.
- Syntax for updateos.sh is:
	updateos.sh [OS] [scriptname or "stage"] (cmdlineopt1 opt2 opt3 opt4 opt5)
- OS = rh7, rh8, etc.
- scriptname is used if running a single task. EX: adduser
- If the script requires user input, add options for opt1,2,3,4,5.
- If "stage" is specified, all scripts in the [OS]/stage/ folder will be executed. (intended to not require user input.)
- If a script fails during a "stage" run, updateos.sh exits 1 immediately.
- Logging for updateos.sh is in /tmp/updateos.sh.log.
- 

Contrib Info -

- Scripts should exit 0 if success and non-0 if fail. (Do not echo that it failed, but exit 0.)
- If options are required, check for command line, and if not present, prompt the user.
- No need to add any logging.
- No need to use sudo to elevate priv.
- Assume all dependent commands or programs are installed and available. (If they aren't then add missing packages to the KS file prior to this.)
- If a new script is added, it is automatically available to all installations of ostools-1.17.
- If a script is updated, the changes are automatically available on the next run of the script, everywhere.
- If a change is checked in is related to a PCI/PA-DSS rule, note the PA-DSS rule in the commit info.
-  
