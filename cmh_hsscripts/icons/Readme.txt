This stores the custom graphics icons that have been created for use in CMH Homeseer customizations.
These files should be copied to:  /usr/local/HomeSeer/html/images/HomeSeer/status

As long as you don't copy over some file that is already there, they should remain and be carried
forward to any future HS release update (since we copy and overwrite when moving to a new release).

This is how these files are used:
spacer.gif	- this is a single pixel file that can be used to make a status icon "disappear".
		This is useful to momentarily change a virtual device to "off" (for example), 
		and then reset to "on" after a couple of seconds in an event.