#!/bin/bash
# CMHexecReboot.sh v1.2
#
# Allows HS to gracefully terminate itself, and then do a system reboot
# This is used as part of an HS event that calls this shell script and then proceeds immediately with a HS.shutdown
#
# This script is called from HS event
# the event is of the form:
#	 if THis Event is MANUALLY triggered
#	 THEN Run Another Program or Process
#		Currently: /home/homeseer/bin/CMHexecReboot.sh
#	 THEN Execute the command: &hs.shutdown
# Note that HS runs another program or process and then immediately proceeds to the next action.
# It does not wait for the program or process to end, before proceeding.

# Note: the "exec" of the CMHReboot.sh replaces the current process with a new one.
#	Hence, when HS shutdown, the CMHReboot.sh is its own Linux process (vs a child process) and keeps running.
# This allows Linux level work to continue after HS has shutdown. This Linux level work should always end with a reboot.
#
# Records the restart in a log file

REBOOT_LOC=/home/homeseer/cmh_bin
LOG_DIR=/home/homeseer/cmh_logs
exec ${REBOOT_LOC}/CMHReboot.sh > ${LOG_DIR}/CMHReboot.log
