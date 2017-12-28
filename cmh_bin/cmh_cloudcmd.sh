#!/bin/bash
# cmh_cloudcmd.sh  -- version 1.0
# stops the nginx web server and then starts the cloud commander application that allows file transfer and editing

echo "Stopping the nginx server and starting cloud commander"
echo "  -->  press <ctl>C to exit from the cloudcmd process when done as no autorization is enabled."

set -x
sudo service nginx stop
sudo cloudcmd --port 80
sudo service nginx start
