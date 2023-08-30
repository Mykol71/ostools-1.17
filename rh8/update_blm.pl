#!/usr/bin/perl
#
# $Revision: 1.1 $
# Copyright 2023 Teleflora.
#
# update_blm.pl
#
# Update Basis BLM for correct license address
#

use strict;
use warnings;
use English;
use Getopt::Long;
use POSIX;


my $tmpDir = "/tmp/";
my $licType = "install";

my $BLM_Address = "";
my $BLM_Remote = "false";
my $BLM_StartType = "init";

my $url = "http://tposlinux.blob.core.windows.net/rtibbjupdate";
my $blm19File = "BLM19_06-16-2022_0858.jar";
my $blmFile = "BLM21_06-15-2022_0933.jar";
my $urlChk = "/usr2/basis/blm/basis";
my $HostIP = "";
my $returnval = "";
my $POSDIR = "/usr2/bbx";
my $chkLic = "";
my $blmVer = "";
my $blmChk = "";

loginfo("");
loginfo("Starting update_blm.pl " . '$Revision: 1.0 $' . "\n");

# What IP to check blm
open(PIPE, "hostname -i |");
while(<PIPE>) {
    $HostIP = $_;
}
close(PIPE);


# conditions to skip install 
# if $chkLic contains poweredbybbj and $blmVer contains blm21
# if using remote blm
# ?? if no license file  - skip installing 

$chkLic=`strings $urlChk 2>/dev/null | grep 'license\.[bp]'`;
chomp $chkLic;
$blmVer=`strings $urlChk 2>/dev/null | grep 'blm[0-9][0-9]'`;
chomp $blmVer;

$blmChk=`ps -ef|grep usr2.basis.blm|grep -v grep`;
chomp $blmChk;

if ( $chkLic =~ /poweredbybbj/i && $blmVer =~ /blm21/i )
{
    loginfo("Already has poweredbybbj address and version 21 blm, exiting \n");
    exit 0;
}

if (-f "/usr2/basis/basis.lic")
{
        open BBJLIC, "</usr2/basis/basis.lic";
        while (<BBJLIC>) {
                if ($BLM_Address eq "")
                {
                        if ($_ =~ /^server[ ]{1,}.{1,}/i )
                        {
                                my @blm_lic = split(' ', $_);
                                $BLM_Address = $blm_lic[1];
                                if ($BLM_Address =~ /localhost/i || $BLM_Address =~ /127.0.0.1/i || $BLM_Address =~ /$HostIP/i )
                                {
                                        $BLM_Address = "";
                                }
                        }
                }
        }
        close BBJLIC;
        if ("$BLM_Address" ne "")
        {
                $BLM_Remote = "true";
                $licType = "blm";
                #loginfo("Using remote blm server at $BLM_Address, exiting \n");
                loginfo("Using remote blm server at $BLM_Address \n");
                #exit 0;
        }
}

my $licFile=`ls -1 /usr2/basis/blm/[0-9]*[OB][SB][HJ]*.lic 2>/dev/null|tail -1`;

if ("$licFile" eq "" && "$blmChk" ne "")
{
    loginfo("Current license file not found, exiting");
    exit 0;
}
  
unless (-f "$tmpDir/$blmFile" ) {
    mysystem("wget --proxy=off --cache=off --progress=dot:mega -O $tmpDir/$blmFile $url/$blmFile");
}

my $blmvars="#blm only install
INSTALL_WIZARD=silent
UAC_WIZARD=off
LICENSE_SELECTION_WIZARD=silent
LICENSE_REGISTER_WIZARD=off
LICENSE_INSTALL_WIZARD=off
BLM_CFG_STARTUP_WIZARD=off
BLM_START_STOP_WIZARD=off
FINISH_WIZARD=silent
LANGUAGE=en
SPLASH_IMAGE=
INSTALL_LICENSE_AGREE=true
INSTALL_TARGET_DIRECTORY_WIN=
INSTALL_TARGET_DIRECTORY_NON_WIN=/usr2/basis/blm
INSTALL_JAVA_DIRECTORY_WIN=
INSTALL_JAVA_DIRECTORY_NON_WIN=/usr/java/latest
INSTALL_CUSTOM_FEATURES=BASIS License Manager
UAC_ELEVATE=
# The following value can be [register] [install]. Default is [register]
LICENSE_SELECTION_OPTION=$licType
LICENSE_INSTALL_ENTERLICINFO=false
LICENSE_INSTALL_LICENSEFILE=$licFile
LICENSE_INSTALL_FEATURE=
LICENSE_INSTALL_ENCRYPTCODE=
LICENSE_INSTALL_LICREV=
LICENSE_INSTALL_HOSTID=
LICENSE_INSTALL_EXPDATE=
LICENSE_INSTALL_CHECKSUM=
LICENSE_INSTALL_NUMUSERS=
LICENSE_INSTALL_SERIALNUM=
#
LICENSE_REGISTER_DEMOLIC=
LICENSE_REGISTER_COMPANYNAME=
LICENSE_REGISTER_FIRSTNAME=
LICENSE_REGISTER_LASTNAME=
LICENSE_REGISTER_EMAIL=
LICENSE_REGISTER_FAX=
LICENSE_REGISTER_PHONE=
LICENSE_REGISTER_HOSTNAME=
LICENSE_REGISTER_HOSTID=
LICENSE_REGISTER_SERIALNUM=
LICENSE_REGISTER_AUTHNUM=
LICENSE_REGISTER_DEMOUSERCOUNT=
LICENSE_REGISTER_DEMOSERIALNUM=
LICENSE_REGISTER_DEMOAUTHNUM=
LICENSE_REGISTER_REGMETHOD=
LICENSE_REGISTER_DELMETHOD=
LICENSE_REGISTER_COUNTRYUSACANADA=
LICENSE_REGISTER_WANTINFO=
LICENSE_REGISTER_NOTEBOOK=
LICENSE_REGISTER_PHONEFILE=
LICENSE_REGISTER_OTHERFILE=
#
BLM_CFG_STARTUP_TYPE_WIN=
BLM_CFG_STARTUP_SERVICESTARTUPTYPE_WIN=
BLM_CFG_STARTUP_TYPE_NON_WIN=
BLM_START_STOP_STARTUP=";

open(BBJINST, "> $tmpDir/blmvars.txt");
print BBJINST $blmvars;
close(BBJINST);

#
if (-f "$tmpDir/blmvars.txt" && -f "$tmpDir/$blmFile" )
    {
      if ("$blmChk" ne "")
       {
        # only stop/start blm if it was running to start
        loginfo("Stopping Basis License Manager.....");
        mysystem ("/sbin/service blm stop");
       }

        loginfo("Installing new License Manager...");
        mysystem("/usr/java/latest/bin/java -jar $tmpDir/$blmFile -p $tmpDir/blmvars.txt");

        if($returnval != 0) {
            logerror("Terminating update_blm with return code $returnval.");
            exit($returnval);
        }
}

loginfo("Checking blank blm file for service command ...");
if (-f "/etc/rc.d/init.d/blm" && ! -s "/etc/rc.d/init.d/blm" )
    {
        loginfo("Removing blank blm file from /etc/rc.d/init.d ");
        mysystem("rm -f /etc/rc.d/init.d/blm");
        if (-f "/etc/rc.d/init.d/bbj" && ! -s "/etc/rc.d/init.d/bbj" )
            {
                loginfo("Removing blank bbj file from /etc/rc.d/init.d ");
                mysystem("rm -f /etc/rc.d/init.d/bbj");
        }
}

if ("$blmChk" ne "")
{
  loginfo("Starting Basis License Manager.....");
  mysystem ("/sbin/service blm start");
}

loginfo("Removing files...");
mysystem("rm -f $tmpDir/$blmFile 2>/dev/null");
mysystem("rm -f $tmpDir/blmvars.txt 2>/dev/null");
mysystem("rm -f $tmpDir/update_blm.pl 2>/dev/null");

$chkLic=`strings $urlChk 2>/dev/null | grep 'license\.[bp]'`;
chomp $chkLic;
$blmVer=`strings $urlChk 2>/dev/null | grep 'blm[0-9][0-9]'`;
chomp $blmVer;

if ( $chkLic =~ /poweredbybbj/i )
{
    loginfo("Success, has poweredbybbj address, blm: $blmVer \n");
}


loginfo("update_blm.pl complete ");

exit(0);



#
#
#### Loginfo  & logerror routines
#
#
sub loginfo
{
	my $message = $_[0];
	my $logtime = strftime("%Y-%m-%d %H:%M:%S", localtime());

	chomp($message);
	open LOGFILE, ">> $POSDIR/log/RTI-Patches.log";
		print LOGFILE "$logtime ($0-$$) <I> $message\r\n";
	close LOGFILE;

	return "";
}


sub logerror
{
	my $message = $_[0];
	my $logtime = strftime("%Y-%m-%d %H:%M:%S", localtime());

	chomp($message);
	open LOGFILE, ">> $POSDIR/log/RTI-Patches.log";
		print LOGFILE "$logtime ($0-$$) <E> $message\r\n";
	close LOGFILE;

	return "";
}

#
# Subroutine to run system commands.  This logs an entry.
#
sub mysystem
{
        my $command = $_[0];
	my $LOG_FILE = "$POSDIR/log/RTI-Patches.log";

        system($command . ">> $LOG_FILE 2>> $LOG_FILE");
        $returnval = WEXITSTATUS($?);
        loginfo($command . " Returned $returnval");

        return ($returnval)
}

# logvars for debug
sub logvars
{
    loginfo("vars set ");
    loginfo("HostIP: " . $HostIP);
    loginfo("chkLic: " . $chkLic);
    loginfo("licType: " . $licType);
    loginfo("licFile: " . $licFile);
    my $junk = `ls -o $tmpDir/blmvars.txt $tmpDir/$blmFile 2>/dev/null`;
    loginfo($junk);

}
