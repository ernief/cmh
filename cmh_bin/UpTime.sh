#!/bin/sh
#Display Uptime
uptime=$(uptime | \
sed s/^.*up// | \
awk -F, '{ if ( $3 ~ /user/ ) { print $1 $2 } else { print $1 }}' | \
sed -e 's/:/\ hours\ /' -e 's/ min//' -e 's/$/\ minutes/' | \
sed 's/^ *//')
echo Uptime: $uptime

#Display Current CPU Speed
mhz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq | sed s/...$//)
cores=$(grep -c processor /proc/cpuinfo)
min1=$(cat /proc/loadavg | awk '{ print $1 }')
min1math=$(echo "$min1 * 100 / $cores" | bc)
min5=$(cat /proc/loadavg | awk '{ print $2 }')
min5math=$(echo "$min5 * 100 / $cores" | bc)
min15=$(cat /proc/loadavg | awk '{ print $3 }')
min15math=$(echo "$min15 * 100 / $cores" | bc)
echo CPU Speed: $mhz Mhz - Load Average: 1min "$min1math"% 5min "$min5math"% 15$
