# Makefile - cmh_downloads

HSDIR=/usr/local/HomeSeer
SBIN=/usr/local/sbin
CMH_DL=/home/homeseer/cmh_downloads
CMH_BIN=/home/homeseer/cmh_bin

all: install

install:zwbkup sbin-rpi-clone gdrive

update: zwbkup sbin-rpi-clone

zwbkup:  $(HSDIR)/scripts/zwbkup.pl

sbin-rpi-clone: rpi-clone $(SBIN)/rpi-clone  $(SBIN)/rpi-clone-setup

$(HSDIR)/scripts/zwbkup.pl: $(CMH_DL)/zwbkup/zwbkup.pl
	cp -p $(CMH_DL)/zwbkup/zwbkup.pl $(HSDIR)/scripts/zwbkup.pl

$(SBIN)/rpi-clone: $(CMH_DL)/rpi-clone/rpi-clone
	sudo cp -p $(CMH_DL)/rpi-clone/rpi-clone $(SBIN)/rpi-clone
$(SBIN)/rpi-clone-setup: $(CMH_DL)/rpi-clone/rpi-clone-setup
	sudo cp -p $(CMH_DL)/rpi-clone/rpi-clone-setup $(SBIN)/rpi-clone-setup
rpi-clone:
	git clone https://github.com/billw2/rpi-clone.git


gdrive:  $(CMH_BIN)/gdrive

$(CMH_BIN)/gdrive: $(CMH_DL)/gdrive/gdrive-linux-rpi
	chmod +x $(CMH_DL)/gdrive/gdrive-linux-rpi
	cp -p $(CMH_DL)/gdrive/gdrive-linux-rpi $(CMH_BIN)/gdrive

uninstall: un-zwbkup un-rpi-clone un-gdrive

un-gdrive:
	rm -f $(CMH_BIN)/gdrive
un-zwbkup:
	rm -f $(HSDIR)/scripts/zwbkup.pl
un-rpi-clone: 
	sudo rm -f /usr/local/sbin/rpi-clone
	sudo rm -f /usr/local/sbin/rpi-clone-setup
