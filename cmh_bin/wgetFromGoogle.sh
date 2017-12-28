#!/bin/sh
# wgetFromGoogle.sh -- v1.1
# Usage:  wgetFromGoogle.sh <fileID> <outputfile>
#
# For example:
#	wgetFromGoogle.sh  0B5i7XtkYqpRXeFNVbzBaTFZCdk0 /home/homeseer/junk/example.tar
#
# This script uses wget to copy a file from google drive.
# the wget command is of the form:
#    wget --no-check-certificate 'https://drive.google.com/uc?export=download&id=<ID>' -O <output_file>
# this may also work ...
#    https://docs.google.com/feeds/download/documents/export/Export?id=<fileID>&exportFormat=<pdf|odt|doc|rtf|html|txt>
# On google drive, the sharing settings should be "share with anyone with link".
#
# For example, if the sharing link is:
#    https://drive.google.com/file/d/0B5i7XtkYqpRXNVpsZ0dpUVNndE0/view?usp=sharing
# then the wget command is:
#    wget --no-check-certificate 'https://drive.google.com/uc?export=download&id=0B5i7XtkYqpRXNVpsZ0dpUVNndE0' -O ./testget.txt

if [ "$#" -ne 2 ]
then
   echo "Usage:  $0 <fileID> <outputfile>"
   exit 1
fi

#set this flay to "y" to run a test
TEST_FLG="n"
if [ $TEST_FLG = "y" ]
then 
# test to download a tar file; use tar xvf to extract
   GDRIVE_FILE_ID=0B5i7XtkYqpRXeFNVbzBaTFZCdk0
   OUTPUT_FILE=/home/homeseer/junk/example.tar
else
   GDRIVE_FILE_ID=$1
   OUTPUT_FILE=$2
fi

GFILE_URL="https://drive.google.com/uc?export=download&id=$GDRIVE_FILE_ID"

wget --no-check-certificate "$GFILE_URL" -O $OUTPUT_FILE
