#!/bin/bash
# Create the directory structure used by the CMH administrative commands
for i in `env | grep CMH | grep -v HomeSeer | sed 's/^[^=]*=//'`
do
	if [ ! -d "$i" ]
	then
		echo mkdir $i
		mkdir $i
	fi
done
