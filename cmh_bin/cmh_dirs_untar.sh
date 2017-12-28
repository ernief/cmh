#!/bin/bash
# create a tar file of the CMH custom files

CMH_TAR_FILE="$1"
CMH_ROOT_DIR=/home/homeseer

if [ ! -f "$CMH_TAR_FILE" ]
then
	echo "$0: unable to open file $CMH_TAR_FILE"
else
	tar -xvzf $CMH_TAR_FILE -C $CMH_ROOT_DIR
fi
