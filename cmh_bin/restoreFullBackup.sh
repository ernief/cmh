#!/bin/bash
set -x
# restoreFullBackup.sh v1.2
# restoreFullBackup.sh - restore an entire HomeSeer directory from a tar.gz file
#
# Assumes this is called from an HS event.
# Given the case where we are restoring the current HS directory, HS must be shutdown before doing the restore
# This is used as part of an HS event that calls this shell script and then proceeds immediately with a HS.shutdown
#
# The HS event is of the form:
#	 if THis Event is MANUALLY triggered
#	 THEN Run Another Program or Process
#		Currently: /home/homeseer/bin/CMHexecReboot.sh
#	 THEN Execute the command: &hs.shutdown
#
# Note 1: When a HS event "runs another program or process", it spawns that program and immediately proceeds to the next action
# Note 2: when the hs.shutdown is called, all child prcoesses are killed.
#	So, we can simply call a shell script that sleeps for a few seconds while HS shuts down.
# Note 3: "exec-ing" a process replaces the current process with a new one.
#	So, it is no longer a child of HS and will keep running.
# This allows Linux level work to continue after HS has shutdown. This Linux level work should always end with a reboot.
#
# Records the restart in a log file

VERSION="1.2"
CMD_NAME="$0"
CMD_ARGS="$*"

MY_LOG_FILE=/home/homeseer/cmh_logs/HSrestore.log

THIS_SCRIPT=$( readlink -m $( type -p $0 ))	# get full path to this script

#--------------------------------------------------------------------------------------
# this fcn does the work after HS should have shutdown.
#--------------------------------------------------------------------------------------
function Fcn_check_usage
{
	# set defaults
	DEST_DIR="/usr/local/HomeSeer"
	SRC_DIR="/home/homeseer/cmh_backups"
	SRC_DIR="/mnt/usb1/cmh_backups"
	TAR_FILENAME=""
	CREATE_DEST_DIR="no"

USAGE="Usage: $CMD_NAME [-hvc][-s srcDir][-d destDir][-f baseTarFileName]\" \n\
           -h help\n\
           -v print script version number\n\
           -c create destination directory if it does not exist\n\
           -s dir where the tar file is found (default: $SRC_DIR)\n\
           -d dir in which tar file is extracted (default: $DEST_DIR)\n\
           -f baseTarFileName (no default - the .tar.gz is added)\n\
Example usage\n\
    $CMD_NAME -s /mnt/usb/cmh_backups -f 357initial\n\
    $CMD_NAME -f 318before357\n\
    $CMD_NAME -d /usr/local/homeseer_357 -f 357beforeImperihome\n"

# Parse command line options.
	while getopts "hvcs:d:f:" OPT; do
	    case "$OPT" in
	        h)
	            echo $USAGE
	            exit 0
	            ;;
	        v)
	            echo "$CMD_NAME version $VERSION"
	            exit 0
	            ;;
	        c)
		    CREATE_DEST_DIR="yes"
	            ;;
	        s)
		    SRC_DIR=$OPTARG
	            ;;
	        d)
	            DEST_DIR=$OPTARG
	            ;;
	        f)
	            TAR_FILENAME="$OPTARG.tar.gz"
	            ;;
	        \?)
	            # getopts issues an error message
	            echo $USAGE >&2
	            exit 1
	            ;;
	    esac
	done

# Remove the switches we parsed above.
	shift `expr $OPTIND - 1`

# Check that there were no non-option argument. 
	if [ $# -ne 0 ]; then
	    echo $USAGE >&2
	    exit 1
	fi

# check to ensure the destination directory exists
	if [ ! -d $DEST_DIR ]
	then
	    if [ "$CREATE_DEST_DIR" = "yes" ]
	    then
	        mkdir $CREATE_DEST_DIR
	    else
	        echo "$CMD_NAME: destination directory does not exist. Use -c option to create it"
	        echo $USAGE
	        exit 1
	    fi
	fi

# see if tar file exists
echo TAR_FILENAME = $TAR_FILENAME
	if [ "$TAR_FILENAME" = "" ]
	then
	    echo "$CMD_NAME: missing -f argument. must specify tar file name."
	    echo $USAGE
	    exit 1
	fi
	if [ ! -f "$SRC_DIR/$TAR_FILENAME" ]
	then
	    echo "$CMD_NAME: tar file $SRC_DIR/$TAR_FILENAME not found."
	    echo $USAGE
	    exit 1
	fi
}
function Fcn_execed_work
{

# do the restore and make directory contents relative to SRC_DIR
	CURR_DATE=`date`
	echo "$CURR_DATE: cd $DEST_DIR; tar -xvzf $SRC_DIR/$TAR_FILENAME" >> $LOGFILE
	echo "$CURR_DATE: cd $DEST_DIR; tar -xvzf $SRC_DIR/$TAR_FILENAME"

	cd $DEST_DIR
	tar -xvzf $SRC_DIR/$TAR_FILENAME
} #end function Fcn_execed_work
#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# The first time through this script, we exec it with a special flag so the second time
# it is called, it does the real work.


if [ $# -ge 1 -a "$1" == "ReCURSion___" ]
then
	# wait for HS to shutdown before doing any work that could conflict with a running HS
	echo "$0: Rebooting system in 20 sec"
	sleep 20s
			# now do work that may have conflicted with a running HS and its children
	shift		# pass any args on for processing

	Fcn_check_usage

	Fcn_execed_work $*
			# always end in a reboot. Otherwise, HS won't restart.
	echo "$0: Rebooting now"
	date
#EJF	reboot
else
	Fcn_check_usage

echo	exec $THIS_SCRIPT ReCURSion___ $CMD_ARGS > ${MY_LOG_FILE}
fi
