#!/bin/bash
# CMHReboot.sh
#
# Part of a graceful HS3 shutdown and HS3 restart (via a system reboot)
# Called from CMHexecReboot.sh
# The echo and dates are issued to record action in a file
# the sleep allows for the HS3 and plugins to stop before the reboot.
# Assumed to be triggered by &hs.shutdown action in the triggering event
# We could monitor that the mono processes go away, but waiting 20 sec is simpler and works.

echo "$0: Rebooting system in 20 sec"
date
sleep 20s
echo "$0: Rebooting now"
date
reboot
