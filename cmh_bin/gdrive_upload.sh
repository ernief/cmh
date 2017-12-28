#!/bin/bash
# gdrive_upload.sh   CMHv1.1
# Uses the gdrive command to upload all files in the cmh_gdrive_up directory to the same named directory on Google Drive
# a log file is also uploaded to this same directory

# Here is the Google ID to the shared directory .../cmh_homeseer/cmh_gdrive_up
# Here is the Google ID to the shared directory .../cmh_homeseer/cmh_logs
CLOUD_UPLOADS_ID="17LWsJBai_CenLltnamPNqHlmjnLo0Xrf"
CLOUD_LOGS_ID="18J3iA6N8CJeo_B--A2s8xZK3VpkaYpFd"

# THis gets run by root, so set PATH so gdrive is found
PATH=/home/homeseer/cmh_bin:$PATH

# Here is the source local directory.
# All files in this directory will be uploaded to Google Drive
# The log file will also be transferred into this directory

LOCAL_SRC_DIR=/home/homeseer/cmh_gdrive_up
LOG_FILE=/home/homeseer/cmh_logs/gdrive_upload.log

date > $LOG_FILE
uname -a >> $LOG_FILE

for i in $LOCAL_SRC_DIR/*
do
# --delete is used to delete the files once they are uploaded
	gdrive upload --delete -p $CLOUD_UPLOADS_ID $i 2>&1 >> $LOG_FILE
done

# upload the logfile so the results of this command are visible
gdrive upload -p $CLOUD_LOGS_ID $LOG_FILE
