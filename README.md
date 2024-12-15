# Network_Monitor
This script and config file will monitor your network and send an automated email with the IP, MAC, and Hostname of new devices that have connected. If no hostname, the IP gets used in its place. Upon first successful launch your inbox will be hit hard since it has to build a known devices file to check against and every time a new mac is added to the list an email is sent.
###Install

1: `sudo apt install namp`

2: `sudo apt install msmtp msmtp-mta`

3: move the `network_tool.sh` file over to your home folder

4: edit `network_tool.sh`

5: fill out the applicable info that I have left blank

6: edit the `msmtprc` with your information

7: move the msmtprc to `/etc/msmtprc` 

8: `sudo chmod +x network_tool.sh`

9: crontab -e

10: select option 1

11: */5 * * * *  ~/network_tool.sh #this will run the script every 5 minutes, adjust the timings to your desire
