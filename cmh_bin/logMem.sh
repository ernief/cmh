#!/bin/bash
LOGFILE=/home/homeseer/cmh_logs/MemUsage.log
export LOGDATE=`date '+%d%H%M'`
ps -aux | grep mono | grep -v grep | awk '{printf("%s %s %d %d\n", $12, ENVIRON["LOGDATE"], $5, $6)}' >> $LOGFILE
