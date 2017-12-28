#! /bin/sh
# restoreFullbackup.sh - v1.2
#set -x

# restore a tar'ed file of an HomeSeer directory, and restore it so HS will use it on a reboot
BACKUP_DIR=/mnt/usb1/cmh_backups

#BACKUP_TARNAME=2017_12_07_15_26
#RESTORE_DIR=/usr/local/HomeSeer_shipped

#BACKUP_TARNAME=2017_12_07_17_39
#RESTORE_DIR=/usr/local/HomeSeer_368

BACKUP_TARNAME=2017_12_10_16_27
RESTORE_DIR=/usr/local/HomeSeer_388

SYMLINK_HS=HomeSeer

# check that the tar file exists before we go farther
if [ ! -f $BACKUP_DIR/$BACKUP_TARNAME.tar.gz ]
then
	echo "Error: backup file not found ($BACKUP_DIR/$BACKUP_TARNAME.tar.gz)"
	exit 1
fi

# check that the target restore location exists. If not, then create it.
if [ ! -d $RESTORE_DIR ]
then
	sudo mkdir $RESTORE_DIR
	sudo chown homeseer:root $RESTORE_DIR
fi

# this assumes the files are stored in a form "./file" (and not "./HomeSeer/file")
cd $RESTORE_DIR
tar -xvzf $BACKUP_DIR/$BACKUP_TARNAME.tar.gz

# create a symbolic link from HomeSeer -> $RESTORE_DIR
# but only do this if there already was a symbolic link.
# otherwise, the HomeSeer may still be the HS directory
RESTORE_DIRNAME=`basename $RESTORE_DIR`
RESTORE_PARENTDIR=`dirname $RESTORE_DIR`
cd $RESTORE_PARENTDIR
if [ -L "$SYMLINK_HS" ] && [ -d "$SYMLINK_HS" ]
then
	sudo rm $SYMLINK_HS
	sudo ln -s $RESTORE_DIRNAME $SYMLINK_HS
fi
