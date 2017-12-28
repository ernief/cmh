#!/bin/bash
#-----------------------------------------------------
# cmh_ls_cmhfiles.sh -- v1.0
#-----------------------------------------------------
LOG_DIR=/home/homeseer/cmh_logs
LOG_FILE=${LOG_DIR}/ls_cmh_files.txt

date > $LOG_FILE
echo "-------- /usr/local --------" >> $LOG_FILE
ls -lt /usr/local/ >> $LOG_FILE

echo "-------- /mnt/usb1/cmh_backups --------" >> $LOG_FILE
ls -lt /mnt/usb1/cmh_backups >> $LOG_FILE

echo "--------  /home/homeseer/cmh_ ----------" >> $LOG_FILE
ls -lt /home/homeseer/cmh_* >> $LOG_FILE
