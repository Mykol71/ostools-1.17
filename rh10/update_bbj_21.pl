#!/usr/bin/perl
#
# $Revision: 1.1 $
# Copyright 2022 Teleflora.
#
# Update BBj to our accepted Revision
#
#DESC Installs/Upgrades BBj and java.

use strict;
use warnings;
use English;
use Getopt::Long;
use POSIX;

my $HELP = 0;
my $VERSION = 0;
my $BBJ15 = 0;
my $BBJ16 = 0;
my $BBJ17 = 0;
my $BBJ18 = 0;
my $BBJ19 = 0;
my $BBJ21 = 1;
my $BBJDV = 0;
my $BBJRV = 0;
my $SKIPBACKUP = 0;

my $OS = "";
my $ARCH = "";
my $POSDIR = "";
my $MEM = 0;
my $XMEM = 0;
my $chgXmx_Xms = 0;
my $pid = 0;
my $foundulimit = "";
my $console_rmi = "";
my $basis_ide = "";

my $authnumtest = "";
my $serialnumtest = "";
my $hostnametest = "";
my $hostidtest = "";
my $Auth_Number = "";
my $Serial_Number = "";
my $Host_Name = "";
my $Host_ID = "";
my $Host_IP = "";
my $bbjinstallsettingsRV = "";
my $config_ini = "";
my $returnval = 0;
my $BBJ = "";
my $JDK_X64 = "";
my $JDK_X86 = "";
my $java_ver_latest_15 = "1.8.0_65";
my $java_rel_latest_15 = "8u65";
my $java_ver_latest_16_17 = "1.8.0_162";
my $java_rel_latest_16_17 = "8u162";
my $java_ver_latest_18_19 = "1.8.0_202";
my $java_rel_latest_18_19 = "8u202";
my $java_ver_latest_19 = "11.0.7_10"; #Moving to OpenJDK
my $java_rel_latest_19 = "11u10";
my $java_ver_latest_21 = "11.0.16.1+1"; #Moving to OpenJDK
my $java_rel_latest_21 = "11U";
#  If updating windows jre, change windows version in Enterprise Manager
#   replace in basis/cfg   BBj.properties and put copy in jetty/.../jvm/windows
#   if java_win set will put copy in and add to BBj.prop line if blank
#   if java_win and java_win_old set, will replace the old refs with new
my $java_win_19 = "OpenJDK11U-jre_x64_windows_hotspot_11.0.7_10.zip";
my $java_win_21 = "OpenJDK11U-jre_x64_windows_hotspot_11.0.16.1_1.zip";
my $java_win = $java_win_21;
my $java_win_old = $java_win_19;
my $windeployline = "";
my $url = "http://tposlinux.blob.core.windows.net/rtibbjupdate";

#
my $bbj15_tar = "bbj15update.tar";
my $bbj15_jar = "BBj1511_09-28-2015_1801.jar";
my $bbj16_tar = "bbj16update.tar";
my $bbj16_jar = "BBj1624_03-24-2017_0426.jar";
my $bbj17_tar = "bbj17update.tar";
my $bbj17_jar = "BBj1713_03-15-2018_1548.jar";
my $bbj18_tar = "bbj18update.tar";
my $bbj18_jar = "BBj1821_03-19-2019_1712.jar";
my $bbj19_tar = "bbj19update.tar";
my $bbj19_jar = "BBj1923_04-10-2020_0711.jar";
my $bbj21_tar = "bbj21update.tar";
my $bbj21_jar = "BBj2115_06-15-2022_0911.jar";
my $bbjdv_tar = "bbjdvupdate.tar";
my $bbjdv_jar = "BBjDev_RTI_Latest_DevBld.jar";
my $java_ver = "";
my $java_rel = "";
my $jdir_link = "";
my $BBJ_INSTALL_FILE = "";
my $tmp_MBs_needed = "1450";
my $tmpDir = "/tmp/";
my $created_tmpDir = "false";
my $df_java = "";
my $du_java = "";
my $df = "";
my $availfs = "";
my $DemoTrueFalse = "false";
my $License_Type = "register";
my $BLM_Address = "";
my $BLM_Remote = "false";
my $BLM_Start_Type = "init";

#  change to wanted version for java/bbj/rti version installed
#  use to check for jars in /usr2/bbx/jars and /usr2/basis/lib
my $MSSQL_JAR_OLD = "mssql-jdbc-7.2.1.jre8.jar";
my $MSSQL_JAR = "mssql-jdbc-11.2.0.jre11.jar";
my $MSSQL_JAR_NEEDED = "";
my $RTITWS_JAR = "rtitws.jar"; 
my $RTITWS_JAR_NEEDED = ""; 
my $BBJ21PROGS = ""; # "bbj21specProgs.tgz";


# Create a timestamp   
my $timestamp = POSIX::strftime("%Y%m%d%H%M%S", localtime(time));

#
# "0" means "do not install"
# "1" means "do install"
# "-1" means "default", which is dictated later on by other factors
# Barring any other factors, "-1" means "do".
#

my %installflags = (
	java => -1,
);

GetOptions(
	"help" => \$HELP,
	"version" => \$VERSION,
	"bbj15" => \$BBJ15,
	"bbj16" => \$BBJ16,
	"bbj17" => \$BBJ17,
	"bbj18" => \$BBJ18,
	"bbj19" => \$BBJ19,
	"bbj21" => \$BBJ21,
	"bbjdv" => \$BBJDV,
   "skipbackup" => \$SKIPBACKUP,
	"java!" => \$installflags{'java'},
);



# --version
if($VERSION != 0)
{
	print("$0 " . '$Revision: 1.1 $' . "\n");
	exit(0);
}

# --help
if($HELP != 0)
{
	usage();
	exit(0);
}

if($BBJ15 == 0 and $BBJ16 == 0 and $BBJ17 == 0 and $BBJ18 == 0 and $BBJ19 == 0 and $BBJ21 == 0 and $BBJDV == 0)
{
	print("$0 " . "No BBj Version Selected, Exiting \n");
	exit(0);
}
#

# Which Processor are we using?
open(PIPE, "uname -i |");
while(<PIPE>)
{
	if(/i.86/)
	{
		$ARCH = "x86";
	}
	if(/x86_64/)
	{
		$ARCH = "x64";
	}
}
close(PIPE);

# What IP to check blm
open(PIPE, "hostname -i |");
while(<PIPE>)
{
	$Host_IP = $_;
	chomp $Host_IP;
}
close(PIPE);

# How much RAM for setting -Xmx and -Xms
open(PIPE, "free -h |");
while(<PIPE>)
{
	if ($_ =~ /^Mem:/)
	{
		$MEM = index ($_, 'G');
		$MEM = substr $_, 6, $MEM-6;
		$MEM = $MEM + 0;
		$XMEM = int ($MEM * 1024 / 2);
	}
}
close(PIPE);

$POSDIR = "/usr2/bbx";

loginfo("Begin $0 ");
loginfo("System has $MEM GB of memory, Architecture: $ARCH ");
loginfo("Checking for available disk space");

open(PIPE, "df -Pm /|");
while(<PIPE>)
{
	if ($_ !~ /^Filesystem/)
	{
		my @df = split(' ', $_ );
		$availfs = $df[3];
	}
}
close(PIPE);
loginfo("Need $tmp_MBs_needed and have $availfs ");
if ( $availfs >= $tmp_MBs_needed )
{
	$tmpDir = "/tmp/";
	loginfo("Ok to load on root partition in $tmpDir ");
}
else
{
	loginfo("Not enough space on root partition, checking /usr2 \n");
	$availfs = "";

	open(PIPE, "df -Pm /usr2|");
	while(<PIPE>)
	{
		if ($_ !~ /^Filesystem/)
		{
			my @df = split(' ', $_ );
			$availfs = $df[3];
		}
	}
	close(PIPE);

	loginfo("Need $tmp_MBs_needed and have $availfs ");

	if ( $availfs >= $tmp_MBs_needed )
	{
		$tmpDir = "/usr2/tmp/";
		loginfo("Ok to load on /usr2 partition in $tmpDir ");
		if ( -d "/usr2/tmp/")
		{
			loginfo("$tmpDir exists, continuing ");
		}
		else
		{
			loginfo("$tmpDir does not exists, creating ");
			mysystem ("mkdir /usr2/tmp");
			$created_tmpDir = "true";
		}
	}
	else
	{
		loginfo("Not enough space on /usr2 partition, exiting ");
		exit 22
	}
}


# We must be root to do these things.
if($EUID == 0)
{

	if($BBJ15 != 0)
	{
		$BBJ = $bbj15_tar;
		$BBJ_INSTALL_FILE = $bbj15_jar;

		$java_rel = $java_rel_latest_15;
		$java_ver = $java_ver_latest_15;
	}

	if($BBJ16 != 0)
	{
$BBJ = $bbj16_tar;
$BBJ_INSTALL_FILE = $bbj16_jar;

$java_rel = $java_rel_latest_16_17;
$java_ver = $java_ver_latest_16_17;
	}

	if($BBJ17 != 0)
	{
		$BBJ = $bbj17_tar;
		$BBJ_INSTALL_FILE = $bbj17_jar;

		$java_rel = $java_rel_latest_16_17;
		$java_ver = $java_ver_latest_16_17;
	}

	if($BBJ18 != 0)
	{
		$BBJ = $bbj18_tar;
		$BBJ_INSTALL_FILE = $bbj18_jar;

		$java_rel = $java_rel_latest_18_19;
		$java_ver = $java_ver_latest_18_19;
	}

	if($BBJ19 != 0)
	{
		$BBJ = $bbj19_tar;
		$BBJ_INSTALL_FILE = $bbj19_jar;

		$java_rel = $java_rel_latest_19;
		$java_ver = $java_ver_latest_19;
	}

	if($BBJ21 != 0)
	{
		$BBJ = $bbj21_tar;
		$BBJ_INSTALL_FILE = $bbj21_jar;

		$java_rel = $java_rel_latest_21;
		$java_ver = $java_ver_latest_21;
	}

	if($BBJDV != 0)
	{
		$BBJ = $bbjdv_tar;
		$BBJ_INSTALL_FILE = $bbjdv_jar;

		$java_rel = $java_rel_latest_18_19;
		$java_ver = $java_ver_latest_18_19;
	}

	$BBJRV = substr $BBJ_INSTALL_FILE, 3, 2;
	$BBJRV .= "." . substr $BBJ_INSTALL_FILE, 5, 2;
	loginfo("Installing BBj Rev $BBJRV Software Dependencies...");

	loginfo("Starting update_bbj_ver.pl " . '$Revision: 1.1 $' . "\n");
	# --bbj15, --bbj16, --bbj17, --bbj18, --bbj19, --bbj21, or --bbjdv (daily dev)
	if($BBJ19 != 0)
	{
		$jdir_link="jdk-11.0.7+10";
		$JDK_X64 = "OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz";
		$JDK_X86 = "OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz";
		install_java();
		install_bbj_packages();
	}
			
	if($BBJ21 != 0)
	{
		$jdir_link="jdk-11.0.16.1+1";
		$JDK_X64 = "OpenJDK11U-jdk_x64_linux_hotspot_11.0.16.1_1.tar.gz";
		$JDK_X86 = "OpenJDK11U-jdk_x64_linux_hotspot_11.0.16.1_1.tar.gz";
		install_java();
		if("$BBJ21PROGS" ne "")
		{
			install_spec_progs();
		}
		install_bbj_packages();
	}
			
	if($BBJ15 != 0 or $BBJ16 != 0 or $BBJ17 != 0 or $BBJ18 != 0 or $BBJDV != 0)
	{
		$jdir_link = "jdk" . $java_ver;

		$JDK_X64 = "jdk-" . $java_rel . "-linux-x64.tar.gz";
		$JDK_X86 = "jdk-" . $java_rel . "-linux-i586.tar.gz";

		# Install Java
		if ($installflags{'java'} != 0)
		{

			if (is_java_already_installed($java_ver))
			{
				loginfo("Java $java_ver is installed, skipping Java update");
			}
			else
			{
				loginfo("Removing old Java rpm packages...");
				mysystem("rm $tmpDir/jre-$java_rel-linux*.rpm");
				mysystem("rpm -e jre-$java_ver");
				mysystem("rpm -e jdk-$java_ver");

				loginfo("Java $java_ver is NOT installed, beginning Java update");
				install_java();
			}
		}
		else
		{
			loginfo("--nojava specified. Skipping Java Update.");
		}

		install_bbj_packages();
	}
}



exit(0);
###################################################
###################################################
###################################################


sub usage
{
	print(<< "EOF");
$0 Usage:

$0 --version
$0 --help
$0 --bbj15            Installs BBj 15
$0 --bbj16            Installs BBj 16
$0 --bbj17            Installs BBj 17
$0 --bbj18            Installs BBj 18
$0 --bbj19            Installs BBj 19
$0 --bbj21            Installs BBj 21
$0 --bbjdv            Installs BBj, Latest Development build we have 
$0 --skipbackup       Skip removing basis.old and coping current to basis.old (for restart to save time)
$0 --java / --nojava  Do / Do not install Java (latest for BBj). Defaults to --java.

EOF

}


#
# Install BBj version
#
sub install_bbj_packages
{
	my $line = "";

	# Install BBj
	if(-d "/usr2/basis")
	{
		if($SKIPBACKUP == 0)
		{
			loginfo("Removing current /usr2/basis-old ");
			mysystem("rm -rf /usr2/basis-old");
			loginfo("Copying current /usr2/basis/ to /usr2/basis-old/...");
			mysystem("cp -pr /usr2/basis /usr2/basis-old");
			if($returnval != 0)
			{
				logerror("Terminating update_bbj with return code $returnval.");
				exit($returnval);
			}
		}
		else
		{
			loginfo("Skip remove of and backup to /usr2/basis-old ")
		}
	}
	else
	{
		loginfo("/usr2/basis/ did not previously exist...");
	}


	
	loginfo("Installing BBj v" . $BBJRV . "...");
	if(! -f "$tmpDir/$BBJ.gz" && ! -f "$tmpDir/$BBJ")
	{
		loginfo("Retrieving $BBJ.gz to $tmpDir/$BBJ.gz ");
		mysystem("wget --proxy=off --cache=off --progress=dot:mega -O $tmpDir/$BBJ.gz $url/$BBJ.gz");
		if(! -f "$tmpDir/$BBJ.gz")
		{
			logerror("Could not download file $url/$BBJ.gz");
			exit(1);
		}
	}
#####
#Basis license Info
####
	loginfo("Checking for License Manager Local or Remote.....");
	if (-f "/usr2/basis/basis.lic")
	{
		loginfo("Checking basis.lic file");
		open BBJLIC, "</usr2/basis/basis.lic";
		while (<BBJLIC>)
		{
			if ($BLM_Address eq "")
			{
				loginfo("line being checked: $_ ");
				if ($_ =~ /^server[ ]{1,}.{1,}/i )
				{
					loginfo("found server line: $_ ");
					my @blm_lic = split(' ', $_);
					$BLM_Address = $blm_lic[1];
					if ($BLM_Address =~ /localhost/i || $BLM_Address =~ /127.0.0.1/i || $BLM_Address =~ /$Host_IP/i || $BLM_Address =~ /$Host_ID/i )
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
			$License_Type = "blm";
			$BLM_Start_Type = "manual";
			loginfo("Remote blm server at $BLM_Address ");
		}
	}

	loginfo("Getting AuthNumber for Basis License......");
	if (! -f "//usr2/basis/blm/Register.properties")
	{
		loginfo("No Register.properties file exists...");
	}
	else
	{
		$authnumtest = `grep AuthNum\= /usr2/basis/blm/Register.properties 2>/dev/null`;
		chomp $authnumtest;
		if ($authnumtest ne "")
		{
			my @authnum=split(/\=/, $authnumtest);
			$Auth_Number=$authnum[$#authnum];
		}
		if ( "$Auth_Number" eq "" )
		{ 
			loginfo("Auth_Number is blank, set DEMOLIC to true ");
			$DemoTrueFalse = "true";
		}
		loginfo("Auth_Number = $Auth_Number");

		loginfo("Getting Serial Number..... ");	
		$serialnumtest = `grep SerialNum\= /usr2/basis/blm/Register.properties 2>/dev/null`;
		chomp $serialnumtest;
		if ($serialnumtest ne "")
		{
			my @serialnum=split(/\=/, $serialnumtest);
			$Serial_Number=$serialnum[$#serialnum];
		}
		loginfo("Serial Number = $Serial_Number");
		
		loginfo("Getting HostName .....");
		$hostnametest = `grep HostName /usr2/basis/blm/Register.properties 2>/dev/null`;
		chomp $hostnametest;
		my @hostname=split(/\=/, $hostnametest);
		$Host_Name=$hostname[$#hostname];
		loginfo("Host Name = $Host_Name");
		
		loginfo("Getting Composite.....");
		$hostidtest = `grep HostID /usr2/basis/blm/Register.properties 2>/dev/null`;
		chomp $hostidtest;
		my @hostid=split(/ID\=/, $hostidtest);
		$Host_ID=$hostid[$#hostid];
		loginfo("Host ID = $Host_ID");
	}
	
		my $bbjinstallsettings = "
################################################################################
# BASIS Installation and Configuration Wizard options
# 
# 
# A forward slash or two back slashes should be used when specifying directories or files
# Passwords will be encrypted when recorded.
# 
# 
################################################################################
# Wizard Settings
# 
# The following variables set whether or not to run various BASIS
# installation and configuration wizards after the installation of the software.
# Setting a value to [interactive] will cause the specified wizard to be run
# interactively. Setting a value to [silent] will cause the specified wizard to
# be run silently. Setting a value to [progress] will cause the specified wizard to
# be run with a progress bar. Setting a value to [off] will prevent that wizard from being run.
# The UAC wizard will only be run on Windows machines in which UAC is enabled. The
# license selection and finish wizards can not be run silently.
# 
# The following value can be [interactive] [silent] [progress]. The default is [interactive].
INSTALL_WIZARD=silent
# The following values can be [off] [interactive] [silent] [progress]. The default is [off].

UAC_WIZARD=off
LICENSE_SELECTION_WIZARD=silent
LICENSE_REGISTER_WIZARD=silent
LICENSE_INSTALL_WIZARD=silent
BBJ_BRAND_WIZARD=silent
BLM_CFG_STARTUP_WIZARD=silent
BLM_START_STOP_WIZARD=silent
BBJ_CFG_STARTUP_WIZARD=silent
BBJ_START_STOP_WIZARD=silent
EM_WIZARD=off
FINISH_WIZARD=silent
# 
################################################################################
# Global Wizard Detail Settings
# 
# The following value can be [en] [nl] [fr] [de] [it] [es] [sv].
# The default is the current locale language.
LANGUAGE=en
# The splash image can be a png or jpg and can be found in the installable jar or on disk. By default the BASIS splash image will be used.
# The following value can be [none] which will skip the splash window. A GUI environment is needed to display the splash window.
SPLASH_IMAGE=
# 
################################################################################
# Install Wizard Detail Settings
# 
# The following value can be [true] [false]. Default is [false].
INSTALL_LICENSE_AGREE=true
# Specifies the installation target directory on Window OS. If not specified the default c:/Program Files/basis directory will be used.
INSTALL_TARGET_DIRECTORY_WIN=C:/bbj/
# Specifies the installation target directory on non-Window OS. If not specified the /opt/basis directory will be used on Mac, on all other OS the /usr/local/basis directory will be used.
INSTALL_TARGET_DIRECTORY_NON_WIN=/usr2/basis/
# Specifies the java directory on Windows OS. If not specified or the specified directory does not exist the java directory will be set via hints.
INSTALL_JAVA_DIRECTORY_WIN=<REPLACEMEREPLACEME>
# Specifies the java directory on non-Windows OS. If not specified or the specified directory does not exist the java directory will be set via hints.
INSTALL_JAVA_DIRECTORY_NON_WIN=/usr/java/latest/
# The following value can be [true] [false]. Default is [false].
INSTALL_CUSTOM=false
# Specifies the comma separated custom features to install. The default is to install all available features.
# Specifies the comma separated custom features to install. The default is to install all available features.
INSTALL_CUSTOM_FEATURES=
# for Windows  INSTALL_CUSTOM=true
# The following value can be [true] [false]. Default is [false].
INSTALL_WEB_START_INSTALLATION=false
# for Windows  INSTALL_CUSTOM_FEATURES=ThinClient,ODBC,JDBC
# The following properties are used to configure Web Start
# Specifies if a certificate should be generated in order to sign Web Start jars. This value can be [true] [false]. Default is [true].
INSTALL_GENERATE_CERTIFICATE=true
# Specifies the company name to use when generating a Web Start certificate
INSTALL_YOUR_COMPANY_NAME=Teleflora
# Specifies the Jetty host to use when generating a Web Start certificate. By default the web server host in BBj.properties will be used if it exists, otherwise the external IP address of the machine will be used.
INSTALL_JETTY_HOST=
# Specifies the Jetty port to use when generating a Web Start certificate. By default the web server port in BBj.properties will be used if it exists, otherwise 8888 will be used.
INSTALL_JETTY_PORT=
# Specifies if a CA certificate should be used to sign Web Start jars. This value can be [true] [false]. Default is [false].
INSTALL_USE_CA_CERTIFICATE=false
# Specifies the keystore to use when using a CA certificate to sign Web Start jars.
INSTALL_KEYSTORE=
# Specifies the keystore password to use when using a CA certificate to sign Web Start jars.
INSTALL_KEYSTORE_PASSWORD=
# Specifies the private key to use when using a CA certificate to sign Web Start jars.
INSTALL_PRIVATE_KEY=
# Specifies the private key password to use when using a CA certificate to sign Web Start jars.
INSTALL_PRIVATE_KEY_PASSWORD=
# The following properties can be specified to run a BBj program at the installation finish. The variable {dollarsign}InstallDir can be used in values that contain a path to be relative to the BBj installation directory.
INSTALL_BBEXEC_PROGRAM=
INSTALL_BBEXEC_CONFIG=
INSTALL_BBEXEC_WORKING_DIR=
INSTALL_BBEXEC_TERMINAL=
INSTALL_BBEXEC_USER=
# The following value can be [true] [false]. Default is [false].
INSTALL_BBEXEC_QUIET=
INSTALL_BBEXEC_APP_NAME=
INSTALL_BBEXEC_APP_USER_NAME=
INSTALL_BBEXEC_CLASSPATH_NAME=
# The following value can be [true] [false]. Default is [false].
INSTALL_BBEXEC_SECURE=
INSTALL_BBEXEC_LOCAL_PORT=
INSTALL_BBEXEC_REMOTE_PORT=
INSTALL_BBEXEC_ARGS=
# The following value can be [true] [false]. Default is [false].
INSTALL_BBEXEC_SYNC=
# The following value default is 6, a wait of 30 seconds will be performed between retries, for a total default retry time of 3 minutes.
INSTALL_BBEXEC_NUM_RETRIES=
# The following value can be [true] [false]. Default is [false].
INSTALL_BBEXEC_SHOW_PROGRESS=
# The following value can be [true] [false]. Default is [false].
INSTALL_BBEXEC_ALLOW_CANCEL=
INSTALL_BBEXEC_PROGRESS_TITLE=
INSTALL_BBEXEC_PROGRESS_TEXT=
INSTALL_BBEXEC_FAILURE_TITLE=
INSTALL_BBEXEC_FAILURE_TEXT=
# 
################################################################################
# UAC Wizard Detail Settings
# 
# The following value can be [true] [false]. Default is [false].
UAC_ELEVATE=
# 
################################################################################
# License Selection Wizard Detail Settings
# 
# The license regsistration, install, and brand wizards will
# be automatically added, depending on the user selection.
# The following value can be [register] [install] [blm]. Default is [register]
LICENSE_SELECTION_OPTION=$License_Type
# 
################################################################################
# License Registration Wizard Detail Settings
# 
# The following value can be [true] [false]
LICENSE_REGISTER_DEMOLIC=$DemoTrueFalse
LICENSE_REGISTER_COMPANYNAME=Teleflora
LICENSE_REGISTER_FIRSTNAME=JJ
LICENSE_REGISTER_LASTNAME=Blankenship
LICENSE_REGISTER_EMAIL=jblankenship\@teleflora.com
LICENSE_REGISTER_FAX=
LICENSE_REGISTER_PHONE=800.621.8324
# The following values can be left empty, so that they will be dynamically populated
LICENSE_REGISTER_HOSTNAME=$Host_Name
LICENSE_REGISTER_HOSTID=$Host_ID
# The following are only used when LICENSE_REGISTER_DEMOLIC=[false]
LICENSE_REGISTER_SERIALNUM=$Serial_Number 
LICENSE_REGISTER_AUTHNUM=$Auth_Number
# The following are only used when LICENSE_REGISTER_DEMOLIC=[true]
LICENSE_REGISTER_DEMOUSERCOUNT=2
LICENSE_REGISTER_DEMOSERIALNUM=BBX000001
LICENSE_REGISTER_DEMOAUTHNUM=9999999999
# The following value can be [auto] [web] [email] [phone] [other]. Default is [auto]
LICENSE_REGISTER_REGMETHOD=auto
# The following value can be [web] [email]. Default is [web]. This setting is not
# used if LICENSE_REGISTER_REGMETHOD=[auto]
LICENSE_REGISTER_DELMETHOD=web
# The following value can be [true] [false]. Default is [true].
LICENSE_REGISTER_COUNTRYUSACANADA=true
# The following value can be [true] [false]. Default is [false].
LICENSE_REGISTER_WANTINFO=false
# The following value can be [true] [false]. Default is [false].
LICENSE_REGISTER_NOTEBOOK=false
# The following value is only used when LICENSE_REGMETHOD=[phone].
# Specify path and file name, a ASCII text file will be generated by the wizard.
LICENSE_REGISTER_PHONEFILE=
# The following value is only used when LICENSE_REGMETHOD=[other].
# Specify path and file name, a ASCII text file will be generated by the wizard.
LICENSE_REGISTER_OTHERFILE=
# 
################################################################################
# License Install Wizard Detail Settings
# 
# The following value can be [true] [false]. Default is [false].
LICENSE_INSTALL_ENTERLICINFO=false
# The following is only used when LICENSE_INSTALL_ENTERLICINFO=[false].
# Specify the location of an existing license file.
LICENSE_INSTALL_LICENSEFILE=/usr2/basis/blm/
# The following are only used when LICENSE_INSTALL_ENTERLICINFO=[true].
LICENSE_INSTALL_FEATURE=
LICENSE_INSTALL_ENCRYPTCODE=
LICENSE_INSTALL_LICREV=
LICENSE_INSTALL_HOSTID=
LICENSE_INSTALL_EXPDATE=
LICENSE_INSTALL_CHECKSUM=
LICENSE_INSTALL_NUMUSERS=
LICENSE_INSTALL_SERIALNUM=
# 
################################################################################
# BBj Brand Wizard Detail Settings
# 
# The following value can be [true] [false]. Default is [false].
BBJ_BRAND_REMOTE=$BLM_Remote
BBJ_BRAND_SERVERNAME=$BLM_Address
# 
################################################################################
# BLM Configuration Startup Wizard Detail Settings
# 
# The following properties are for Windows OS
# The following value can be [service] [login] [manual]. Default is [service].
BLM_CFG_STARTUP_TYPE_WIN=
# The following value can be [auto] [manual] [disabled]
BLM_CFG_STARTUP_SERVICESTARTUPTYPE_WIN=
# The following property is for non-Windows OS
# The following value can be [init] [manual]. Default is [init].
BLM_CFG_STARTUP_TYPE_NON_WIN=$BLM_Start_Type
# 
################################################################################
# BLM Services Wizard Detail Settings
# 
# The following value can be [start] [stop] [restart]
BLM_START_STOP_STARTUP=
# 
################################################################################
# BBj Configuration Startup Wizard Detail Settings
# 
# The following properties are for Windows OS
# The following value can be [service] [login] [manual]. Default is [login].
BBJ_CFG_STARTUP_TYPE_WIN=
BBJ_CFG_STARTUP_USERACCOUNT_WIN=
BBJ_CFG_STARTUP_PASSWORD_WIN=
# The following value is only used when run as a service and can be [auto] [manual] [disabled]
BBJ_CFG_STARTUP_SERVICESTARTUPTYPE_WIN=
# The following properties are for non-Windows OS
# The following value can be [init] [manual]. Default is [init].
BBJ_CFG_STARTUP_TYPE_NON_WIN=init
BBJ_CFG_STARTUP_USERACCOUNT_NON_WIN=root
BBJ_CFG_STARTUP_PASSWORD_NON_WIN=
# 
################################################################################
# BBj Services Wizard Detail Settings
# 
# The following value can be [start] [stop] [restart]
BBJ_START_STOP_STARTUP=start
# The following values are only used if BBJ_START_STOP_STARTUP=[stop].
# The following default value is [localhost]
BBJ_START_STOP_SERVERNAME=localhost
# The following default value is [2002]
BBJ_START_STOP_ADMINPORT=2002
# The following default value is [admin]
BBJ_START_STOP_USERNAME=
# The following default value is [admin123] only in silent mode
BBJ_START_STOP_USERPASSWORD=
# The following default value is [false]
BBJ_START_STOP_WAITFORCLIENTS=false
# 
################################################################################
# EM Wizard Detail Settings
# 
EM_CURADMINPASSWORD=
EM_NEWADMINPASSWORD=
EM_SERVERNAME=
EM_ADMINPORT=
";
##EOF
		open(BBJINST, "> $tmpDir/bbjinstallsettings.txt");
		print BBJINST $bbjinstallsettings;
		close(BBJINST);


loginfo("Removing existing /usr2/bbx/config/config.ini.....");
	mysystem("rm -r /usr2/bbx/config/config.ini");
loginfo("Creating new /usr2/bbx/config/config.ini.....");
$config_ini = "
[RTI14]
DATEFORMAT.1=
DATEFORMAT.2=
RWUSERS=
DATESUFFIX.2=
CREATETABLETYPE=6
DATESUFFIX.1=
DICTIONARY=/usr2/bbx/dict/
DATABASE=RTI14
ROUSERS=
TRUNCATEIFTOOLONG=Y
ADVISORYLOCKING=Y
ADMINUSERS=
DATECOLUMNSSORTED=false
ACCESSPOLICY=ALL
Y2KWINDOW.1=0
DATESUFFIX=
Y2KWINDOW.2=0
CHARSET=
READONLY=N
Y2KWINDOW=0
DATA=/usr2/bbx/bbxd/
DATEFORMAT=
AUTO_ANALYZE_TABLES=false

[RTI]
DATEFORMAT.1=
DATEFORMAT.2=
RWUSERS=
DATESUFFIX.2=
CREATETABLETYPE=6
DATESUFFIX.1=
DICTIONARY=/usr2/bbx/odbc_dict/
DATABASE=RTI
ROUSERS=
TRUNCATEIFTOOLONG=Y
ADVISORYLOCKING=Y
ADMINUSERS=
DATECOLUMNSSORTED=false
ACCESSPOLICY=ALL
Y2KWINDOW.1=0
DATESUFFIX=
Y2KWINDOW.2=0
CHARSET=
READONLY=N
Y2KWINDOW=0
DATA=/usr2/bbx/bbxd/
DATEFORMAT=
AUTO_ANALYZE_TABLES=false";
open(BBJCFG, "> /usr2/bbx/config/config.ini");
	print BBJCFG $config_ini;
	close(BBJCFG);
	mysystem("chmod 775 /usr2/bbx/config/config.ini"); 
	mysystem("chown tfsupport:rtiadmins /usr2/bbx/config/config.ini"); 
	if( (-f "$tmpDir/$BBJ.gz" || -f "$tmpDir/$BBJ")
	&&  (-f "$tmpDir/bbjinstallsettings.txt"))
	{
		loginfo("Stopping RTI Programs.....");
		mysystem("/sbin/service rti stop");
		loginfo("Stopping BBj Services.....");
		mysystem ("$POSDIR/bin/bbjservice.pl --stop");
		loginfo("Stopping Basis License Manager.....");
		mysystem ("/sbin/service blm stop");
		if (-d "/usr2/install_bbj")
		{
			loginfo("Directory /usr2/install_bbj exists.....");
		}
		else
		{
			loginfo("Creating /usr2/install_bbj directory.....");
			mysystem ("mkdir /usr2/install_bbj");
		}
		if (-f "$tmpDir/$BBJ")
		{
			loginfo("Moving $BBJ to /usr2/install_bbj directory.....");
			mysystem ("mv $tmpDir/$BBJ /usr2/install_bbj/");
		}
		else
		{
			loginfo("Moving $BBJ.gz to /usr2/install_bbj directory.....");
			mysystem ("mv $tmpDir/$BBJ.gz /usr2/install_bbj/");
		}
		mysystem ("mv $tmpDir/bbjinstallsettings.txt /usr2/install_bbj/"); 
		if (-f "/usr2/install_bbj/$BBJ.gz" && ! -f "/usr2/install_bbj/$BBJ")
		{
			loginfo("Gunziping and untar $BBJ......");
			mysystem("gunzip /usr2/install_bbj/$BBJ.gz");
			if($returnval != 0)
			{
				logerror("Terminating update_bbj with return code $returnval.");
				exit($returnval);
			}
		}
		mysystem ("tar xvf /usr2/install_bbj/$BBJ -C /usr2/install_bbj/");
		if($returnval != 0)
		{
			logerror("Terminating update_bbj with return code $returnval.");
			exit($returnval);
		}
#v19 Do not need to to remove lib files anymore TODO:
#		loginfo("Removing existing jar files....");
#			mysystem("rm -r /usr2/basis/lib/*");
		loginfo("Untaring $BBJ.......");
		loginfo("Installing $BBJ......");
		mysystem("/usr/java/latest/bin/java -jar /usr2/install_bbj/$BBJ_INSTALL_FILE -p /usr2/install_bbj/bbjinstallsettings.txt");
		if($returnval != 0)
		{
			logerror("Terminating update_bbj with return code $returnval.");
			exit($returnval);
		}
	loginfo("Completed $BBJ Installation......");
	loginfo("Removing /var/www/lib/ files.....");
	loginfo("Webstart access is no longer accepted. Removing all files in /var/www/ relating to BBj.");
		mysystem("rm -r /var/www/lib/*");
	loginfo("removing /var/www/jnlp/ files.....");
		mysystem("rm -r /var/www/jnlp/*");
	loginfo("removing /var/www/cgi-bin/ files.....");
		mysystem("rm -r /var/www/cgi-bin/*");
	#loginfo("Copy new unsigned jars to /usr2/basis/lib/ .....");
	#	mysystem("cp -pr /usr2/install_bbj/jars/unsigned/* /usr2/basis/lib/");
	# not putting new jars in place with v16 as we no longer allow webstart access
	# loginfo("Copy new signed jars to /var/www/lib/ .....");
	#	mysystem("cp -pr /usr2/install_bbj/jars/signed/* /var/www/lib/");
	 loginfo("Copy new librxtxSerial.so to /usr2/basis/lib/ .....");
		mysystem("cp -pr /usr2/install_bbj/librxtxSerial.so /usr2/basis/lib/");
	# If BBjBootstrap_RTI_latest.jar included, rename and replace the one in  /usr2/basis/lib 
	if ( -f "/usr2/install_bbj/BBjBootstrap_RTI_latest.jar" )
	{
	        loginfo("Replacing BBjBootstrap ...");
		mysystem("cp -pr /usr2/basis/lib/BBjBootstrap.jar /usr2/basis/lib/BBjBootstrap_from_install.jar");
		mysystem("cp /usr2/install_bbj/BBjBootstrap_RTI_latest.jar /usr2/basis/lib/BBjBootstrap.jar"); 
	}
	# if not already present, get latest (mssql-jdbc-11.2.0.jre11.jar) from cloud storage (RTI_MONITOR needs it to write to outside database
	if ( -f "/usr2/bbx/jars/$MSSQL_JAR" )
	{
		loginfo("The $MSSQL_JAR file already in /usr2/bbx/jars, skipping");
	}
	else
	{
	  	loginfo("Downloading $MSSQL_JAR from cloud storage...");
	  	mysystem("wget --proxy=off --cache=off --progress=dot:mega -O /usr2/install_bbj/$MSSQL_JAR $url/$MSSQL_JAR");	
	  	loginfo("Done downloading $MSSQL_JAR ...");
		mysystem("cp /usr2/install_bbj/$MSSQL_JAR /usr2/bbx/jars/$MSSQL_JAR");
		loginfo("Copied $MSSQL_JAR /usr2/bbx/jars/ ");
	}

	if ( $java_win ne "" )
	{
		if ( -f "/usr2/bbx/config/$java_win" )
		{
			loginfo("Windows JRE present, skipping download");
		}
		else
		{
	    		loginfo("Downloading Windows JRE needed for App Deployment....");
	    		mysystem("wget --proxy=off --cache=off --progress=dot:mega -O /usr2/bbx/config/$java_win $url/$java_win");
		}
	}

	# If rtitws.jar included, rename and replace the one in /usr2/bbx/jars 
	if ( -f "/usr2/install_bbj/rtitws.jar" )
	{
	        loginfo("Copying rtitws.jar to backups and replacing ...");
		mysystem("cp -pr /usr2/bbx/jars/rtitws.jar /usr2/bbx/backups/rtitws.jar." . $timestamp);
		mysystem("cp /usr2/install_bbj/rtitws.jar /usr2/bbx/jars/rtitws.jar"); 
	}
	#
	# loginfo("Copy new jnlp.pl to /var/www/cgi-bin/ .....");
#		mysystem("cp -pr /usr2/install_bbj/bin/jnlp.pl /var/www/cgi-bin/");
#		mysystem("chmod 775 /var/www/cgi-bin/jnlp.pl");

	open BBJPROP, "</usr2/basis/cfg/BBj.properties";
	open BBJPROPOUT, ">/usr2/basis/cfg/BBj.properties.tmp"; 	
	while (<BBJPROP>)
	{
		if ($_ =~ /com.basis.appdeployment.jre.defaultWindows/ && $java_win ne "" )
		{
			if ( $java_win_old ne "" )
			{
				$_ =~ s/$java_win_old/$java_win/;
			}
			if ($_ !~ m/$java_win/)
			{
				$_ =~ s/com.basis.appdeployment.jre.defaultWindows\=\s+$/com.basis.appdeployment.jre.defaultWindows\=${java_win}\n/;
			}
		}

		if ($_ =~ /^com.basis.appdeployment.jre.defaultWindows/)
		{
			$windeployline = "true";
		}
		if ($_ =~ /^basis.java.args.BBjServices/)
		{
			if ($_ !~ m/\-server/)
			{
				$_ =~ s/$/ \-server/;
			}
			my $countCheck = 0;
			$countCheck = () = $_ =~ /\-Dfile.encoding\\=ISO\-8859\-1/g;
			if ($countCheck gt 1 )
			{
				$_ =~ s/\-Dfile.encoding\\=ISO\-8859\-1//g;
			}
			$countCheck = 0;
			if ($_ !~ m/\-Dfile.encoding\\=ISO\-8859\-1/)
			{
				$_ =~ s/$/ \-Dfile.encoding\\=ISO\-8859\-1 /g;
			}
			$_ =~ s/\-XX\\:\+PrintGCTimeStamps//g;
			$_ =~ s/\-XX\\:\+PrintGCDateStamps//g;
			$_ =~ s/\-XX\\:\+PrintGCApplicationConcurrentTime//g;
			$_ =~ s/\-XX\\:\+PrintGCApplicationStoppedTime//g;
			$_ =~ s/\-XX\\:\+PrintGCDetails//g;
			$_ =~ s/\-XX\\:\+UseConcMarkSweepGC//g;
			$_ =~ s/\-XX\\:\+CMSIncrementalMode//g;
			$_ =~ s/\-XX\\:CMSIncrementalSafetyFactor\\=20//g;
			$_ =~ s/\-XX\\:CMSInitiatingOccupancyFraction\\=70//g;
			$_ =~ s/\-Xloggc\\:\/usr2\/basis\/log\/gc.log//g;
			$_ =~ s/\-verbose\\\:gc//g;
			if ($chgXmx_Xms != 0)
			{
				$_ =~ s/\-Xms\d*m/\-Xms${XMEM}m/g;
				$_ =~ s/\-Xmx\d*m/\-Xmx${XMEM}m/g;
			}
			if ($_ !~ m/\-XX\\:\+UseG1GC/)
			{
				$_ =~ s/$/ \-XX\\:\+UseG1GC/;
			}
			if ($_ !~ m/\-XX\\:MaxGCPauseMillis\\=500/)
			{
				$_ =~ s/$/ \-XX\\:MaxGCPauseMillis\\=500/;
			}
			if ($_ !~ m/\-Djxbrowser.ipc.external\\=true/)
			{
				$_ =~ s/$/ \-Djxbrowser.ipc.external\\=true/;
			}
			if ($_ !~ m/\-Djxbrowser.browser.type\\=LIGHTWEIGHT/)
			{
				$_ =~ s/$/ \-Djxbrowser.browser.type\\=LIGHTWEIGHT/;
			}
			#if ($_ !~ m/\-\-illegal_access\\=warn/)
			#{
				#$_ =~ s/$/ \-\-illegal_access\\=warn/;
			#}
			#if ($_ !~ m/\-XX\:IgnoreUnrecognizedVMOptions/)
			#{
				#$_ =~ s/$/ \-XX\:IgnoreUnrecognizedVMOptions/;
			#}
			#if ($_ !~ m/\-XX\\:\+UseStringDeduplication/)
			#{
			#	$_ =~ s/$/ \-XX\\:\+UseStringDeduplication/;
			#}
			if ($_ !~ m/\-Xlog\\:gc\*\:file\=\/usr2\/basis\/log\/BBjServices_gc.log\\:tags,uptime,level\\:filecount\\=10,filesize\\=25m/)
			{
				$_ =~ s/$/ \-Xlog\\:gc\*\:file\=\/usr2\/basis\/log\/BBjServices_gc.log\\:tags,uptime,level\\:filecount\\=10,filesize\\=25m/;
			}
			$_ =~ s/  */ /g;
		}

		$_ =~ s/com.basis.user.useFork\=true/com.basis.user.useFork\=false/g;

		if ($_ =~ m/^basis.java.jvm.BBjServices/)
		{
			if ($_ !~ m/\/usr\/java\/latest\/bin\/java/)
			{
				$_ =~ s/usr\/java\/..*\/bin\/java/usr\/java\/latest\/bin\/java/;
			}
		}

		if ($_ =~ m/^basis.java.jvm.Default/)
		{
			if ($_ !~ m/\/usr\/java\/latest\/bin\/java/)
			{
				$_ =~ s/usr\/java\/..*\/bin\/java/usr\/java\/latest\/bin\/java/g;
			}
		}

		if ($_ =~ m/^com.basis.jetty.host\=[A-Za-z]/)
		{
			$_ =~ s/com.basis.jetty.host\=..*/com.basis.jetty.host\=${Host_IP}/;
		}

		$_ =~ s/com.basis.server.admin.1.useSSL\=false/com.basis.server.admin.1.useSSL\=true/g;
		$_ =~ s/com.basis.bbj.comm.ProxyManagerServer.start\=false/com.basis.bbj.comm.ProxyManagerServer.start\=true/g;
		$_ =~ s/com.basis.bbj.comm.ThinClientProxyServer.start\=false/com.basis.bbj.comm.ThinClientProxyServer.start\=true/g;
		$_ =~ s/com.basis.bbj.comm.ThinClientServer.start\=false/com.basis.bbj.comm.ThinClientServer.start\=true/g;
		$_ =~ s/basis.java.args.Default\=\-client/basis.java.args.Default\=\-XX\\:MaxPermSize\\=128m \-client/g;
		$_ =~ s/basis.java.args.ProxyMgrServer\=\-client \-XX\\:CompileCommandFile/basis.java.args.ProxyMgrServer\=\-XX\\:MaxPermSize\\=128m \-client \-XX\\:CompileCommandFile/g;

		if ($_ =~ /basis.java.classpath/)
		{
			if ($_ =~ /\/usr2\/basis\/lib\/$MSSQL_JAR_OLD/)
			{
				$_ =~ s/:\/usr2\/basis\/lib\/$MSSQL_JAR_OLD//;
			}
			if ($_ =~ /\/usr2\/basis\/lib\/$MSSQL_JAR/)
			{
				$_ =~ s/:\/usr2\/basis\/lib\/$MSSQL_JAR//;
			}
			if ($_ !~ /\/usr2\/bbx\/jars\/$MSSQL_JAR/)
			{
				$_ =~ s/$/:\/usr2\/bbx\/jars\/$MSSQL_JAR/;
			}
			if ($_ !~ /\/usr2\/bbx\/jars\/rtitws.jar/)
			{
				$_ =~ s/$/:\/usr2\/bbx\/jars\/rtitws.jar/;
			}
			if (-e "/usr2/OSAS/progRM/update.jar" || -d "/usr2/OSAS/progRM/" )
			{
				if ($_ !~ /\/usr2\/OSAS\/progRM\/update.jar/)
				{
					$_ =~ s/$/:\/usr2\/OSAS\/progRM\/update.jar/;
				}
			}

			if (-e "/usr2/OSAS/progRM/barcode4j.jar" || -d "/usr2/OSAS/progRM" )
			{
				if ($_ !~ /\/usr2\/OSAS\/progRM\/barcode4j.jar/)
				{
					$_ =~ s/$/:\/usr2\/OSAS\/progRM\/barcode4j.jar/;
				}
			}
#print the existing line, then change it to basis.classpath.bbj_default. Both classpath lines need to be the same with the bbj_default having the prepended (bbj_internal) piece.
			print BBJPROPOUT $_;
			$_ =~ s/basis.java.classpath\=/basis.classpath.bbj_default=(bbj_internal)\\\:/g;
		}

		print BBJPROPOUT $_;
		
		if ($_ =~ m/bbjservices.ulimit.filedescriptors/)
		{
			$foundulimit = "true";
		}
		if ($_ =~ m/com.basis.bbj.console.rmi/)
		{
			$console_rmi = "true";
		}
		if ($_ =~ m/basis.java.args.BasisIDE/)
		{
			$basis_ide = "true";
		}
		if ($foundulimit ne "true")
		{
			print BBJPROPOUT "bbjservices.ulimit.filedescriptors=16384\n";
		}
		if ($console_rmi ne "true")
		{
			print BBJPROPOUT "com.basis.bbj.console.rmi=false\n";
		}
		if ($basis_ide ne "true")
		{
			print BBJPROPOUT "basis.java.args.BasisIDE\\=\-XX\\:CompileCommandFile\\=/usr2/basis/cfg/.hotspot_compiler \-XX\\:MaxPermSize\\=160m\n";
		}
		if ($windeployline ne "true")
		{
			print BBJPROPOUT "com.basis.appdeployment.jre.defaultWindows\=$java_win\n";
		}
	}
		
	close BBJPROP;
	close BBJPROPOUT;
		
	mysystem("mv /usr2/basis/cfg/BBj.properties /usr2/basis/cfg/BBj.properties.bak");
	mysystem("mv /usr2/basis/cfg/BBj.properties.tmp /usr2/basis/cfg/BBj.properties");
	mysystem("chmod 644 /usr2/basis/cfg/BBj.properties");
		
	loginfo("Checking GC Logrotate setting in bbjservices ...");
	$returnval=mysystem("grep doRotateGCLog\=0 /usr2/basis/bin/bbjservices >/dev/null 2>/dev/null");
	if($returnval != 0)
	{
		open BBJPROP, "</usr2/basis/bin/bbjservices";
		open BBJPROPOUT, ">/usr2/basis/bin/bbjservices.tmp";
		while (<BBJPROP>)
		{
			print BBJPROPOUT $_;
			if ($_ =~ / Start Custom Definitions \(DO NOT REMOVE THIS LINE\) /)
			{
				print BBJPROPOUT "doRotateGCLog=0\n";
			}
		}
		close BBJPROP;
		close BBJPROPOUT;
	
		loginfo("Disabled doRotateGCLog for bbj, java now does it ");
		mysystem("mv /usr2/basis/bin/bbjservices /usr2/basis/bin/bbjservices.bak");
		mysystem("mv /usr2/basis/bin/bbjservices.tmp /usr2/basis/bin/bbjservices");
		mysystem("chmod 644 /usr2/basis/bin/bbjservices");

	}

# Adding /usr2/bbx/bin to the /usr2/basis/cfg/.envsetup file 
	$returnval=mysystem ("grep \"/usr2/bbx/bin\"/ /usr2/basis/bin/.envsetup > /dev/null 2> /dev/null");
	if($returnval != 0)
	{
		loginfo("Add /usr2/bbx/bin to the Basis env setup PATH.");
		mysystem("cp -p /usr2/basis/bin/.envsetup /usr2/basis/bin/.envsetup.bak");
		open ENVOLD, "< /usr2/basis/bin/.envsetup.bak";
		open ENVNEW, "> /usr2/basis/bin/.envsetup";
		while(<ENVOLD>)
		{
			my $line = $_;
			if ($line =~ m/PATH=/)
			{
				print ENVNEW $line;
				$line = "PATH=\"\$PATH:\${bbjHome}/bin:\${bbjHome}/lib:/usr2/bbx/bin/\"\n";
			}
		print ENVNEW $line;
		}
		close ENVNEW;
		close ENVOLD;
		mysystem("chmod 775 /usr2/basis/bin/.envsetup");
		mysystem("rm -f /usr2/basis/bin/.envsetup.bak");
	}
	if ( "$BLM_Remote" eq "true")
	{
		loginfo("Restoring basis.lic for remote license...");
		mysystem("cp -p /usr2/basis/basis.lic /usr2/basis/basis_lic_install");
		mysystem("cp -p /usr2/basis-old/basis.lic /usr2/basis/basis.lic");
	}
	loginfo("Removing Installation Files........");
		mysystem("rm -fr /usr2/install_bbj");
		if (-d "/usr2/tmp/" && "$tmpDir" eq "/usr2/tmp/" && "$created_tmpDir" eq "true")
		{
			mysystem("rm -fr /usr2/tmp/");
		}
	loginfo("Done with update BBj version.....");
	loginfo("Restarting Basis License Manager.....");
		mysystem("/sbin/service blm stop");
		sleep (2);
		mysystem("/sbin/service blm start");
	loginfo("Restarting BBj Services.....");
		mysystem("$POSDIR/bin/bbjservice.pl --stop");
		sleep (2);
		mysystem("$POSDIR/bin/bbjservice.pl --start");
		sleep (2);
	loginfo("Starting RTI Programs.....");
		mysystem("/sbin/service rti start");
	loginfo("Restart Complete......Finished!");
	}
}

#
# Verify that Java is already (correctly) installed.
#
# Returns
#   1 if installed
#   0 if not
#

sub is_java_already_installed
{
	my ($java_chk) = @_;

	my $java_root = '/usr/java';
	my $java_jre_dir = "$java_root/jre" . $java_chk;
	my $java_jdk_dir = "$java_root/jdk" . $java_chk;

	if (-d $java_root)
	{
		if (-d $java_jre_dir || -d $java_jdk_dir)
		{
	    		my $link = readlink "$java_root/latest";
	    		if (index($link, $java_root) != 0)
			{
				$link = $java_root . "/" . $link;
	    		}
	    		if ($link eq $java_jre_dir || $link eq $java_jdk_dir)
			{
				return(1);
	    		}
		}
	}

	return(0);
}


#
#
#### Install Java
#
#

sub get_and_load_java
{
	my ($java_file) = @_;

	my $java_no_gz_test = $java_file;
	chomp $java_no_gz_test;
	my @java_no_gz=split('.gz', $java_no_gz_test);
	my $java_no_gz=$java_no_gz[$#java_no_gz];

	unless (-f "$tmpDir/$java_file" || -f "$tmpDir/$java_no_gz")
	{
		mysystem("wget --proxy=off --cache=off --progress=dot:mega -O $tmpDir/$java_file $url/$java_file");
	}
	unless (-f "$tmpDir/$java_file" || -f "$tmpDir/$java_no_gz")
	{
		logerror("Could not download file $url/$java_file");
		exit(1);
	}

	loginfo("Installing Java...");
	if (-f "$tmpDir/$java_file")
	{
		mysystem("chmod a+rx $tmpDir/$java_file");
		##mysystem("mv $tmpDir/$java_file /usr/java/");
		mysystem("cd /usr/java/ && gunzip $tmpDir/$java_file");
		if($returnval != 0)
		{
			logerror("Terminating update_bbj with return code $returnval.");
			exit($returnval);
		}

	} 
	mysystem("cd /usr/java/ && tar xvf $tmpDir/$java_no_gz");
	if($returnval != 0)
	{
		logerror("Terminating update_bbj with return code $returnval.");
		exit($returnval);
	}

	mysystem("rm -rf $tmpDir/$java_no_gz");
	mysystem("cd /usr/java/ && rm -r latest");
	mysystem("cd /usr/java/ && ln -s " . $jdir_link . " latest");
	#mysystem("if [ ! -h /usr/bin/java ]; then ln -s /usr/java/latest/bin/java /usr/bin/java; fi");
	if ($returnval != 0)
	{
		logerror("Java install returned non-zero exitstatus: $returnval.");
		exit($returnval);
	}

	# Normally, clean up is a "good thing", but looks like the convention
	# for this script is to leave the Java download file.
	#loginfo("Cleaning Up...");
	#mysystem("rm -f $tmpDir/$java_file 2>/dev/null");

	if (-d "/usr2/tmp/" && "$tmpDir" eq "/usr2/tmp/")
	{
		open(PIPE, "df -Pm /usr/java|");
		while(<PIPE>)
		{
			if ($_ !~ /^Filesystem/)
			{
				my @df = split(' ', $_ );
				$availfs = $df[3];
			}
		}
		close(PIPE);

		open(PIPE,"du -m $tmpDir/$java_no_gz|");
		while(<PIPE>)
		{
				my @df = split(' ', $_ );
				$du_java = $df[0];
		}

		if ( $availfs >= $du_java )
		{
			mysystem("mv $tmpDir/$java_no_gz /usr/java");
			loginfo("Moved $java_no_gz to /usr/java ");
		}
		else
		{
			loginfo("Not enough space in /usr/java for $java_no_gz, leaving in $tmpDir\n");
			$created_tmpDir = "false";
		}
	}

}

sub install_java
{
	loginfo("Installing Java JDK...");

	if("$ARCH" eq "x86")
	{
	    get_and_load_java($JDK_X86);
	}
	else
	{
	    get_and_load_java($JDK_X64);
	}
}

sub install_spec_progs
{ 
	mysystem("wget --proxy=off --cache=off --progress=dot:mega -O $tmpDir/$BBJ21PROGS $url/$BBJ21PROGS");

	my $file = "";
	my $filename = "";
	my @filenm = ();

	if (-f "$tmpDir/$BBJ21PROGS")
	{
		open(PIPE, "tar -tzf $tmpDir/$BBJ21PROGS |");
		while(<PIPE>)
		{
			$file = $_;
			chomp $file;
			@filenm = split('\/', $file);
			$filename = $filenm[1];
			if ( -f "$POSDIR/$file" )
			{
				loginfo("Copying $filename to backups");
				mysystem("cp -pr $POSDIR/$file $POSDIR/backups/$filename" . "." . $timestamp);
			}
			loginfo("Placing $file ");
			mysystem("tar -C $POSDIR -xzf $tmpDir/$BBJ21PROGS $file");
			mysystem("chown tfsupport:rtiadmins $POSDIR/$file 2>/dev/null");
			mysystem("chmod 555 $POSDIR/$file 2>/dev/null");
		}
		
		mysystem("rm -rf $tmpDir/$BBJ21PROGS");
	}
	loginfo("Done with special programs install ");

}

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

