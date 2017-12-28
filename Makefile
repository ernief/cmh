# Create a new tar file of all the cmh_dirs and this Makefile
#

CMH_SRC_LIST= ./cmh_backups ./cmh_bin ./cmh_config ./cmh_downloads ./cmh_gdrive_down ./cmh_gdrive_up \
	 ./cmh_hsevents ./cmh_hsscripts ./cmh_logs ./cmh_releases ./cmh_tmp ./cmh_workspace ./HSrelArchives ./Makefile

cmh_dirs.tar.gz:
	tar -czvf ./cmh_dirs.tar.gz $(CMH_SRC_LIST)

#--------------------------------------------------------
# Do the initial customization of the OS and apps
#--------------------------------------------------------
customizemyzee: initial_setup downloads_install updateperl otherapps

initial_setup:
	/home/homeseer/cmh_bin/cmh_initial_setup.sh | tee /home/homeseer/cmh_logs/cmh_initial_setup.log

downloads_install:
	cd /home/homeseer/cmh_downloads; make install

updateperl:
	sudo apt-get update
	sudo apt-get -y install libwww-perl

otherapps:
	sudo apt-get install bc
	sudo apt-get install htop
