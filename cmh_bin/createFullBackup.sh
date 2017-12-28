#!/bin/sh
#createFullBackup.sh - create a tar.gz file of an entire HomeSeer directory
#--------------------------------------------------------------------------
# set defaults
VERSION="1.2"
CMD_NAME="$0"
SRC_DIR="/usr/local/HomeSeer"
DEST_DIR="/home/homeseer/cmh_backups"
CREATE_DEST_DIR="no"
OVERWRITE_SNAP_FILE="no"
PARENT_IN_NAME="no"
NOW=$(date +"%Y_%m_%d_%H_%M")
SNAP_FILENAME="$NOW.tar.gz"
DESCRIPTION_FILENAME="$NOW.txt"
TARCONTENTS_FILENAME="$NOW.list"
LOGFILE=/home/homeseer/cmh_logs/HSbackup.log


USAGE="Usage: $CMD_NAME [-hvco][-s srcDir][-d snapShotDir][-f basesnapShotFileName] \"one-line description in quotes\" \n\
           -h help\n\
           -v print script version number\n\
           -c create snapShotDir if it does not exist\n\
           -o overwrite snapshot file -- otherwise stop\n\
           -p store files with parent name (parent/file vs. ./file)\n\
           default srcDir is $SRC_DIR\n\
           default snapShotDir is $DEST_DIR\n\
           default snamShotFileName is date-time.tar.gz (e.g. $SNAP_FILENAME)\n\
Example usage\n\
    $CMD_NAME -d /home/homeseer/cmh_backups -f 318before357 \"3.0.0.318 before upgrade to 3.0.0.357\" \n\
    $CMD_NAME -d /home/homeseer/cmh_backups -f 357initial \"initial snapshot after upgrade to 3.0.0.357\" \n\
    $CMD_NAME -d /mnt/usb1/cmh_backups  -f 357beforeImperihome \"snapshot before after upgrade to 3.0.0.357\" \n"

# Parse command line options.
while getopts "hvcops:d:f:" OPT; do
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
        o)
	    OVERWRITE_SNAP_FILE="yes"
            ;;
        p)
	    PARENT_IN_NAME="yes"
            ;;
        s)
	    SRC_DIR=$OPTARG
            ;;
        d)
            DEST_DIR=$OPTARG
            ;;
        f)
            SNAP_FILENAME="$OPTARG.tar.gz"
	    DESCRIPTION_FILENAME="$OPTARG.txt"
	    TARCONTENTS_FILENAME="$OPTARG.list"
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

# Check for the non-option argument. 
if [ $# -ne 1 ]; then
    echo $USAGE >&2
    exit 1
fi

SNAP_DESCRIPTION="$1"

# check to ensure the destination directory exists
if [ ! -d $DEST_DIR ]
then
    if [ "$CREATE_DEST_DIR" = "yes" ]
    then
        mkdir $CREATE_DEST_DIR
    else
        echo "$CMD_NAME: destination directory does not exist. Use -f option to create it"
        echo $USAGE
        exit 1
    fi
fi

# see if snapshot file exists
# if it does, the -o is needed to overwrite

if [ -f "$DEST_DIR/$SNAP_FILENAME" ]
then
    if [ "$OVERWRITE_SNAP_FILE" = "no" ]
    then
        echo "$CMD_NAME: snapshot file $DEST_DIR/$SNAP_FILENAME already exists. Use -o option to overwrite it"
        echo $USAGE
        exit 1
    fi
fi

if [ ! -d $SRC_DIR ]
then
        echo "$CMD_NAME: The directory to backup does not exist."
        echo $USAGE
        exit 1
fi
# write description file
echo "$SNAP_DESCRIPTION" > $DEST_DIR/$DESCRIPTION_FILENAME

# do the backup and make directory contents relative to SRC_DIR

if [ "$PARENT_IN_NAME" = "yes" ]
then
	SRC_DIR_PARENT=`dirname $SRC_DIR`
	SRC_DIR_NAME="./`basename $SRC_DIR`"
	cd $SRC_DIR_PARENT
else
	SRC_DIR_NAME="."
	cd $SRC_DIR
fi

# since the HomeSeer directory may be symlink to a particular expanded version of HomeSeer
# use the -h option on tar to archive the file to which a symlink points

CURR_DATE=`date`
echo "$CURR_DATE: tar -cvzhf $DEST_DIR/$SNAP_FILENAME $SRC_DIR_NAME > $DEST_DIR/$TARCONTENTS_FILENAME" >> $LOGFILE
echo "$CURR_DATE: tar -cvzhf $DEST_DIR/$SNAP_FILENAME $SRC_DIR_NAME > $DEST_DIR/$TARCONTENTS_FILENAME"

tar -cvzhf $DEST_DIR/$SNAP_FILENAME $SRC_DIR_NAME > $DEST_DIR/$TARCONTENTS_FILENAME
tar -tvzf $DEST_DIR/$SNAP_FILENAME | head
