#!/bin/bash
# cmh_initial_setup.sh  CMHv1.1
# this script automates the steps describe in the HTZEES2-initial-setup document

#-------------- base helper functions -----------------
# Fget_keyword -- looks for a string that contains "...CMH...line..." and returns "CMH...line"
# Fmake_backup_file -- creates a backup and then appends some lines to the file
# Fsudo_make_backup_file -- same as Fmake_backup_file, but runs commands using sudo
#------------------------------------------------------

#------------------------------------------------------------------------------
# Fget_keyword -- looks for a string that contains "...CMH...line..." and returns "CMH...line"
function Fget_keyword()
{
	head -1 | sed -n 's/^\(.*\)\(CMH\)\(.*\)\(line\)\(.*\)$/\2\3\4/p'
}

#------------------------------------------------------------------------------
# Fmake_backup_file -- creates a backup and then appends some lines to the file
function Fmake_backup_file()
{
	FILE_TO_BACKUP=$1

	# check that the original file exists
	if [ ! -f ${FILE_TO_BACKUP} ]
	then
		touch $FILE_TO_BACKUP
		echo "# initially, this file ${FILE_TO_BACKUP} did not exist." >> ${FILE_TO_BACKUP}_orig
		chmod a-w ${FILE_TO_BACKUP}_orig
	fi
	# if the backup doesn't exist, then create it
	if [ ! -f ${FILE_TO_BACKUP}_orig ]
	then
		cp $FILE_TO_BACKUP ${FILE_TO_BACKUP}_orig
		chmod a-w ${FILE_TO_BACKUP}_orig
	fi
}
#------------------------------------------------------------------------------
# Fsudo_make_backup_file -- sudo execued cmds. Creates a backup and then appends some lines to the file
function Fsudo_make_backup_file()
{
	FILE_TO_BACKUP=$1

	# check that the original file exists
	if [ ! -f ${FILE_TO_BACKUP} ]
	then
		sudo touch $FILE_TO_BACKUP
		sudo echo "# initially, this file ${FILE_TO_BACKUP} did not exist." >> ${FILE_TO_BACKUP}_orig
		sudo chmod a-w ${FILE_TO_BACKUP}_orig
	fi
	# if the backup doesn't exist, then create it
	if [ ! -f ${FILE_TO_BACKUP}_orig ]
	then
		sudo cp $FILE_TO_BACKUP ${FILE_TO_BACKUP}_orig
		sudo chmod a-w ${FILE_TO_BACKUP}_orig
	fi
}

#-----------------------------------------------------------------------
#-------------- functions to edit .bash_aliases files  -----------------
# function Fmy_bashrc_text()
# function Fupdate_bash_aliases()
#-----------------------------------------------------------------------
function Fmy_bashrc_text()
{
       #--------------------------------------------------------------------
       # IMPORTANT: do not change the first line
       #--------------------------------------------------------------------
  cat <<`EOF`
#---------- CMH edits below this line ----------------------------------
# .bash_aliases -- CMH version 1.0
# This file is assumed to be sourced by the .bashrc file

# set any bash options here:
#       set command line editing to use vi
set -o vi


# define the some command aliases:
alias r='fc -s'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias updateAliases="/bin/vi ~/.bash_aliases; source ./.bash_aliases"
`EOF`
}
#------------------------------------------------------------------------------
function Fupdate_bash_aliases()
{
	FILE_TO_UPDATE=$1
	echo "INFO: updating $FILE_TO_UPDATE"
	Fmake_backup_file $FILE_TO_UPDATE

	# if update already happened, then replace old update with new
	# use first part of first line as the KEYWORD
	# if KEWORD exists, then replace it and all lines that follow with the new bashrc_text
	KEYWORD=`Fmy_bashrc_text | Fget_keyword`
	sed -i "/${KEYWORD}/,\$d" $FILE_TO_UPDATE
	Fmy_bashrc_text >> $FILE_TO_UPDATE
}
#-----------------------------------------------------------------------
#------ functions to edit /home/homeseer/.profile
# function Fmy_dot_profile_text()
# function Fupdate_my_dot_profile()
#-----------------------------------------------------------------------
function Fmy_dot_profile_text()
{
       #--------------------------------------------------------------------
       # IMPORTANT: do not change the first line
       #--------------------------------------------------------------------
  cat <<`EOF`
#---------- CMH edits below this line ----------------------------------
# CMH .profile additions:  version 1.0
#-----------------------------------------------------------------------
CMH_PROFILE=~homeseer/cmh_config/cmh_profile
if [ -f  "$CMH_PROFILE" ]
then
	.  $CMH_PROFILE
fi
`EOF`
}
function Fupdate_my_dot_profile()
{
	FILE_TO_UPDATE=$1
	echo "INFO: updating $FILE_TO_UPDATE"
	Fmake_backup_file $FILE_TO_UPDATE

	# if update already happened, then replace old update with new
	# use first part of first line as the KEYWORD
	# if KEWORD exists, then replace it and all lines that follow with the new text
	KEYWORD=`Fmy_dot_profile_text | Fget_keyword`
	sed -i "/${KEYWORD}/,\$d" $FILE_TO_UPDATE
	Fmy_dot_profile_text >> $FILE_TO_UPDATE
}
#-----------------------------------------------------------------------
#------ functions to edit /home/homeseer/cmh_config/cmh_profile
# function Fmy_cmh_profile_text()
# function Fupdate_cmh_profile()
#-----------------------------------------------------------------------
function Fmy_cmh_profile_text()
{
       #--------------------------------------------------------------------
       # IMPORTANT: do not change the first line
       #--------------------------------------------------------------------
  cat <<`EOF`
#---------- CMH edits below this line ----------------------------------
# cmh_profile - version 1.0
#-----------------------------------------------------------------------
# specify locations for HS3 installation and the CMH administrative directories
#-----------------------------------------------------------------------
export CMH_HS3_DIR=/usr/local/HomeSeer

# Define backup directories: primary and secondary locations
export CMH_BACKUP_DIR1=/mnt/usb1/cmh_backups
export CMH_BACKUP_DIR2=/home/homeseer/cmh_backups

export CMH_BIN_DIR=/home/homeseer/cmh_bin
export CMH_CONFIG_DIR=/home/homeseer/cmh_config
export CMH_DOWNLOAD_DIR=/home/homeseer/cmh_downloads
export CMH_GDRIVE_DOWN_DIR=/home/homeseer/cmh_gdrive_down
export CMH_GDRIVE_UP_DIR=/home/homeseer/cmh_gdrive_up
export CMH_HSEVENT_DIR=/home/homeseer/cmh_hsevents
export CMH_HSSCRIPTS_DIR=/home/homeseer/cmh_hsscripts
export CMH_LOG_DIR=/home/homeseer/cmh_logs
export CMH_RELEASE_DIR=/home/homeseer/cmh_releases
export CMH_TMP_DIR=/home/homeseer/cmh_tmp
export CMH_WORKSPACE_DIR=/home/homeseer/cmh_workspace

#-----------------------------------------------------------------------
# look in the ~/cmh_bin directory for commands
#-----------------------------------------------------------------------
export PATH=.:$CMH_BIN_DIR:$PATH
`EOF`
}
function Fupdate_cmh_profile()
{
	FILE_TO_UPDATE=$1
	echo "INFO: updating $FILE_TO_UPDATE"
	Fmake_backup_file $FILE_TO_UPDATE

	# if update already happened, then replace old update with new
	# use first part of first line as the KEYWORD
	# if KEWORD exists, then replace it and all lines that follow with the new text
	KEYWORD=`Fmy_cmh_profile_text | Fget_keyword`
	sed -i "/${KEYWORD}/,\$d" $FILE_TO_UPDATE
	Fmy_cmh_profile_text >> $FILE_TO_UPDATE
}

#-----------------------------------------------------------------------
#------ functions to edit /root/.profile
# function Froot_dot_profile_text()
# function Fedit_root_dot_profile()
# function Fupdate_root_dot_profile()
#-----------------------------------------------------------------------
function Froot_dot_profile_text()
{
       #--------------------------------------------------------------------
       # IMPORTANT: do not change the first line
       #--------------------------------------------------------------------
  cat <<`EOF`
#---------- CMH edits below this line ----------------------------------
# CMH .profile additions:  version 1.0
#-----------------------------------------------------------------------
CMH_PROFILE=~homeseer/cmh_config/cmh_profile
if [ -f  "$CMH_PROFILE" ]
then
	.  $CMH_PROFILE
fi
`EOF`
}
#-----------------------------------------------------------------------
function Fedit_root_dot_profile()
{
	FILE_TO_EDIT=$1
	echo "INFO: updating $FILE_TO_EDIT"
	Fmake_backup_file $FILE_TO_EDIT

	# if update already happened, then replace old update with new
	# use first part of first line as the KEYWORD
	# if KEWORD exists, then replace it and all lines that follow with the new text
	KEYWORD=`Froot_dot_profile_text | Fget_keyword`
	sed -i "/${KEYWORD}/,\$d" $FILE_TO_EDIT
	Froot_dot_profile_text >> $FILE_TO_EDIT
}
#-----------------------------------------------------------------------
function Fupdate_root_dot_profile()
{
	FILE_TO_UPDATE=$1
	# For /root/.profile, we need to deal with permissions and owneships
	TMP_ROOT_PROFILE=/home/homeseer/cmh_tmp/root_dot_profile
	sudo cp $FILE_TO_UPDATE $TMP_ROOT_PROFILE
	sudo chmod 666  $TMP_ROOT_PROFILE
	Fedit_root_dot_profile  $TMP_ROOT_PROFILE
	sudo chmod 644 $TMP_ROOT_PROFILE
	sudo chown root:root $TMP_ROOT_PROFILE ${TMP_ROOT_PROFILE}_orig
	sudo mv -f $TMP_ROOT_PROFILE $FILE_TO_UPDATE 
	sudo mv -f ${TMP_ROOT_PROFILE}_orig ${FILE_TO_UPDATE}_orig
}

#-----------------------------------------------------------------------
#------ functions to edit /root/.bashrc
# function Froot_bashrc_text()
# function Fedit_root_bashrc()
# function Fupdate_root_bashrc()
#-----------------------------------------------------------------------
function Froot_bashrc_text()
{
       #--------------------------------------------------------------------
       # IMPORTANT: do not change the first line
       #--------------------------------------------------------------------
  cat <<`EOF`
#---------- CMH edits below this line ----------------------------------
# .bashrc for root -- CMH version 1.0

# set command line editing to use vi
set -o vi


# define the some command aliases:
alias r='fc -s'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
`EOF`
}
#-----------------------------------------------------------------------
function Fedit_root_bashrc()
{
	FILE_TO_EDIT=$1
	echo "INFO: updating $FILE_TO_EDIT"
	Fmake_backup_file $FILE_TO_EDIT

	# if update already happened, then replace old update with new
	# use first part of first line as the KEYWORD
	# if KEWORD exists, then replace it and all lines that follow with the new bashrc_text
	KEYWORD=`Froot_bashrc_text | Fget_keyword`
	sed -i "/${KEYWORD}/,\$d" $FILE_TO_EDIT
	Froot_bashrc_text >> $FILE_TO_EDIT
}
#-----------------------------------------------------------------------
function Fupdate_root_bashrc()
{
	FILE_TO_UPDATE=$1
	# For /root/.bashrc, we need to deal with permissions and owneships
	TMP_ROOT_BASHRC=/home/homeseer/cmh_tmp/root_bashrc
	sudo cp $FILE_TO_UPDATE $TMP_ROOT_BASHRC
	sudo chmod 666  $TMP_ROOT_BASHRC
	Fedit_root_bashrc  $TMP_ROOT_BASHRC
	sudo chmod 644 $TMP_ROOT_BASHRC
	sudo chown root:root $TMP_ROOT_BASHRC ${TMP_ROOT_BASHRC}_orig
	sudo mv -f $TMP_ROOT_BASHRC $FILE_TO_UPDATE 
	sudo mv -f ${TMP_ROOT_BASHRC}_orig ${FILE_TO_UPDATE}_orig
}
#-----------------------------------------------------------------------
#------ functions set up SSH
# function Fsetup_ssh()
#-----------------------------------------------------------------------
function Fsetup_ssh()
{
	SSH_CONFIG_FILE=$1
	echo "INFO: updating $SSH_CONFIG_FILE"
	Fsudo_make_backup_file $SSH_CONFIG_FILE
	sudo sed -i '/^StrictModes yes/s/.*/#&\nGatewayPorts yes/' $SSH_CONFIG_FILE
}
#-----------------------------------------------------------------------
#------ functions set up backup directories
# function Fsetup_symlinks()
#-----------------------------------------------------------------------
function Fsetup_symlinks()
{
	HS_SHIPPED_VERSION="HomeSeer_shipped"
echo "INFO: setting up symbolic like to /usr/local/${HS_SHIPPED_VERSION}"
	# check if it is a symbolic link
	if [ ! -L /usr/local/HomeSeer ]
	then
		sudo mv /usr/local/HomeSeer /usr/local/${HS_SHIPPED_VERSION}
		sudo ln -s /usr/local/${HS_SHIPPED_VERSION} /usr/local/HomeSeer
	fi
	# creae the archives directory that is later used by cmh_bin/upgradeBeta.sh
	DIR_ARCHIVE=/home/homeseer/HSrelArchives
	if [ ! -d $DIR_ARCHIVE ]
	then
		mkdir $DIR_ARCHIVE
		chmod 777 $DIR_ARCHIVE
	fi
}
#-----------------------------------------------------------------------
#-------------- clean up some Linux items
#-----------------------------------------------------------------------
function FLinuxCleanup()
{
	# known bug in most Linux releases - Incorrect permissions
	sudo chmod u+s /bin/ping
}
#-----------------------------------------------------------------------
#-------------- now to put it all together -----------------------------
#-----------------------------------------------------------------------
function mymain()
{
  echo "$0: beginning CMH env edits"

  # TEST_MODE="yes"
  TEST_MODE="no"

  if [ "$TEST_MODE" = "no" ]
  then
	# Update the .bash and shell local environment for user=homeseer
	Fupdate_bash_aliases   /home/homeseer/.bash_aliases
	Fupdate_my_dot_profile /home/homeseer/.profile
	Fupdate_cmh_profile    /home/homeseer/cmh_config/cmh_profile

	# Update the .bash and shell local environment for user=root
	Fupdate_root_dot_profile  /root/.profile
	Fupdate_root_bashrc      /root/.bashrc

	# Update some system config files
	Fsetup_ssh /etc/ssh/sshd_config

	# set up /usr/local/HomeSeer as symbolic link to a HS root directory
	Fsetup_symlinks

	# some Linux system updates
	FLinuxCleanup
	
  else
  	echo "$0: TEST_MODE enabled -- see test files in /home/homeseer/cmh_workspace/testdir"

	Fupdate_bash_aliases     /home/homeseer/cmh_workspace/testdir/no_junk_alias
	Fupdate_my_dot_profile   /home/homeseer/cmh_workspace/testdir/my_dot_profile
	Fupdate_cmh_profile      /home/homeseer/cmh_workspace/testdir/cmh_profile
	Fupdate_root_dot_profile /home/homeseer/cmh_workspace/testdir/root_profile
	Fupdate_root_bashrc      /home/homeseer/cmh_workspace/testdir/root_bashrc
	Fsetup_ssh               /home/homeseer/cmh_workspace/testdir/sshd_config
  fi
  echo "$0: done with CMH env edits"
}

#----------- Call the main entry point into all these scriptes --------
mymain
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------

