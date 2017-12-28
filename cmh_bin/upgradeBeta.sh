#!/bin/bash
# upgradeBeta.sh -- v1.2
# Does a manual upgrade of current release to a new release
# generally this is done for beta release installs
# run while logged in as homeseer
#
VERSION="1.3"
CMD_NAME="$0"
CURR_REL_NUM=""
UPGRADE_REL_NUM=""

USAGE="Usage: $CMD_NAME [-hv] -c currentReleaseNumber -n newReleaseNumber \n \
           -h help\n\
           -v print script version number\n\
           -c current Release Number (basis for upgrade)\n\
           -n new Release Number\n\
Example usage\n\
    $CMD_NAME -c 366 -n 388\n"
# Log the stderr and stdout of this script
#
CMD_FILE=`basename $CMD_NAME`
CMH_LOG_FILE=/home/homeseer/cmh_logs/${CMD_FILE}.log
if [ ! -d `dirname $CMH_LOG_FILE` ]
then
	mkdir `dirname $CMH_LOG_FILE`
fi
exec > $CMH_LOG_FILE 2>&1
echo "Running $0 at `date`"

# Parse command line options.
while getopts "hvc:n:" OPT; do
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
	    CURR_REL_NUM=${OPTARG}
            ;;
        n)
	    UPGRADE_REL_NUM=${OPTARG}
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

# Check for the required arguments.
if [ "${CURR_REL_NUM}" = "" ]; then
    echo $USAGE >&2
    exit 1
fi
if [ "${UPGRADE_REL_NUM}" = "" ]; then
    echo $USAGE >&2
    exit 1
fi

#-------------------------------------------------------

TARFILE="hslinux_zees2_3_0_0_${UPGRADE_REL_NUM}.tar.gz"

DIR_OLDREL="HomeSeer_${CURR_REL_NUM}"
DIR_NEWREL="HomeSeer_${UPGRADE_REL_NUM}"
PARENT_DIR=/usr/local
DIR_ARCHIVE=/home/homeseer/HSrelArchives

# use to wget updated_release_from_homeseer
if [ ! -f "$DIR_ARCHIVE/$TARFILE" ]
then
	cd $DIR_ARCHIVE
	wget https://homeseer.com/updates3/${TARFILE}
fi
if [ ! -f "$DIR_ARCHIVE/$TARFILE" ]
then
	echo "Error: could not get ${TARFILE} from HomeSeer"
	exit 1
fi

# Now upgrade the old release with the new release.
# - copy OldReleaseDir to NewReleaseDir
# - make sure Homeseer is not running
# - expand the tar file in the NewReleaseDir
# - update the symbolic link for the startup directory to the NewReleaseDir
CREATED_DIR_NEWREL="no"
cd $PARENT_DIR
if [ -d $DIR_NEWREL ]
then
	echo "Error: ${PARENT_DIR}/${DIR_NEWREL} already exists" ]
	exit 2
else
	sudo mkdir ${DIR_NEWREL}
	CREATED_DIR_NEWREL="yes"
fi
#-------- Not sure why I need to shutdown HomeSeer .... I am copying to a new dir and then rebooting
## make sure HS is shut down
## check if  process is running, mono should be the HomeSeer process
#check_process() {
## echo "$ts:  checking $1"
# [ "$1" = "" ] && return 0
# [ `pgrep -nf $1` ] && return 1 || return 0
#}
## wait for the mono process to exit, HomeSeer will then be shut down
#mono_stopped="no"
##counter=20
#until [ $counter -le 0 ]; do
#	check_process "mono"
# 	if [ $? == 0 ]; then
#	    mono_stopped="yes"
#  	    break
# 	fi
#	((counter--))
#
## Try shutting down Homeseer using JSON
#	cd /usr/local/HomeSeer
#	exec /usr/bin/curl http://127.0.0.1:8080/JSON?request=runevent&group=Admin&name=CMHHSshutdown
#       cd -
#	sleep 2
#done
# if mono is still running then undo what we've done so far
#if [ "$mono_stopped" == "no" ]
#then
#	sudo rm -f ${TARFILE}
#	if [ "$CREATED_DIR_NEWREL" == "yes" ]
#	then
#		sudo rmdir ${DIR_NEWREL}
#	fi
#	exit 2
#fi

#-------------------------
# now copy the current release into the new directory
# then overwrite with what was distributed in the new beta release
sudo cp -r ${DIR_OLDREL}/* ${DIR_NEWREL} 
cd ${PARENT_DIR}/${DIR_NEWREL}
sudo tar xavf $DIR_ARCHIVE/$TARFILE

#-------------------------
# now set up the directories
cd $PARENT_DIR
sudo rm HomeSeer
sudo ln -s $DIR_NEWREL HomeSeer 

#--------------------------
# Reboot the sytem
echo "$0: update complete. Rebooting in 6 seconds"
sleep 6
sudo shutdown --reboot
# sudo sysemctl start homeseer
# sudo /usr/local/HomeSeer/autostart_hs &
#

#-------------------------
# ALERNATIVE - instead of rebooting would be to run as a service
## now restart HS3 (assumes this is running as a service)
## sudo systemctl stop homeseer

