#!/bin/bash
#-----------------------------------------------------
# makeBackupIndex.sh -- v1.1
#-----------------------------------------------------
BACKUP_DIR1=/home/homeseer/cmh_backups
BACKUP_DIR2=/mnt/usb1/cmh_backups
INDEX_FILE=/home/homeseer/cmh_backups/HSbackup.index

rm -f $INDEX_FILE

for i in ${BACKUP_DIR1}/*.txt ${BACKUP_DIR2}/*.txt
do
	if [ -f "$i" ]
	then
		echo -n "${i}:  "
		cat $i
	fi
done >> $INDEX_FILE
