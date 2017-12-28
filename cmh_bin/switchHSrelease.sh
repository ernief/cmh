#! /bin/sh
# switchHSrelease.sh - v1.1
set -x

# switch to a different installed release

REL_DIR=/usr/local/HomeSeer_shipped
REL_DIR=/usr/local/HomeSeer_368
REL_DIR=/usr/local/HomeSeer_388
REL_DIR=/usr/local/HomeSeer_${1}
SYMLINK_HS=HomeSeer

# check that the target release directory exists. If not, then create it.
if [ ! -d $RESTORE_DIR ]
then
	echo "Error: release directory not found (${RESTOR_DIR})"
	exit 1
fi

# create a symbolic link from HomeSeer -> $RESTORE_DIR
# but only do this if there already was a symbolic link.
# otherwise, the HomeSeer may still be the HS directory
REL_DIRNAME=`basename $REL_DIR`
REL_PARENTDIR=`dirname $REL_DIR`
cd $REL_PARENTDIR
if [ -L "$SYMLINK_HS" ] && [ -d "$SYMLINK_HS" ]
then
	sudo rm $SYMLINK_HS
	sudo ln -s $REL_DIRNAME $SYMLINK_HS
fi
