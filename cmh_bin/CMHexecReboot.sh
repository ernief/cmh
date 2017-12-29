#!/bin/bash
# CMHexecReboot.sh v1.2
#
# Allows HS to gracefully terminate itself, and then do a system reboot
# This is used as part of an HS event that calls this shell script and then proceeds immediately with a HS.shutdown
#
# The HS event is of the form:
#	 if THis Event is MANUALLY triggered
#	 THEN Run Another Program or Process
#		Currently: /home/homeseer/cmh_bin/CMHexecReboot.sh
#	 THEN Execute the command: &hs.shutdown
#
# Note 1: When a HS event "runs another program or process", it spawns that program and immediately proceeds to the next action
# Note 2: when the hs.shutdown is called, all child prcoesses are killed.
#	So, we can simply call a shell script that sleeps for a few seconds while HS shuts down.
# Note 3: "exec-ing" a process replaces the current process with a new one.
#	So, it is no longer a child of HS and will keep running.
# This allows Linux level work to continue after HS has shutdown. This Linux level work should always end with a reboot.
#
# Records the restart in a log file

REBOOT_LOC=/home/homeseer/cmh_bin
MY_LOG_FILE=/home/homeseer/cmh_logs/CMH_reboot.log

THIS_SCRIPT=$( readlink -m $( type -p $0 ))	# get full path to this script

#--------------------------------------------------------------------------------------
# this is where we do the work after HS should have shutdown. e.g. restore a backup
function Fcn_execed_work
{
	echo "$0: Rebooting system in 20 sec"
	date
} #end function Fcn_execed_work
#--------------------------------------------------------------------------------------
# The first time through this script, we exec it with a special flag so the second time
# it is called, it does the real work.
if [ $# -ge 1 -a "$1" = "ReCURSion___" ]
then
	# wait for HS to shutdown before doing any work that could conflict with a running HS
	echo "$0: Rebooting system in 20 sec"
	sleep 20s
			# now do work that may have conflicted with a running HS and its children
	shift		# pass any args on for processing
	Fcn_execed_work $*
			# always end in a reboot. Otherwise, HS won't restart.
	echo "$0: Rebooting now"
	date
	sudo reboot
else
	exec $THIS_SCRIPT ReCURSion___ $* > ${MY_LOG_FILE}
fi
