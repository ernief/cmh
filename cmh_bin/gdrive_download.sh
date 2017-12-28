#!/bin/bash
# gdrive_download.sh     CMHv1.1

# Here is the Google ID to the shared directory .../cmh_homeseer/cmh_gdrive_down
CLOUD_DWNLOADS_ID="1JQ6QkCnSbc-vg4bUkFTxwTGtdnrE7BNi"

# here is the link to cmh_homeseer/cmh_logs
# this is where the logfile will be sent
CLOUD_LOGS_ID="18J3iA6N8CJeo_B--A2s8xZK3VpkaYpFd"

LOG_FILE=/home/homeseer/cmh_logs/gdrive_download.log

# set PATH so gdrive is found as this gets run by HS by root
PATH=/home/homeseer/cmh_bin:$PATH

# The files downloaded will be stored in $LOCAL_DEST_DIR/cmh_gdrive_down

LOCAL_DEST_DIR=/home/homeseer

date > $LOG_FILE
uname -a >> $LOG_FILE

# --f is used to overwrite files with the same name that may already have been downloaded
# -r is used to get all files in the remote directory
# --path is the parent directory of the directory and its contents that are being downloaded
gdrive download -r -f --path $LOCAL_DEST_DIR $CLOUD_DWNLOADS_ID 2>&1 >> $LOG_FILE

# upload the logfile so the results of this command are visible
gdrive upload -p $CLOUD_LOGS_ID $LOG_FILE
