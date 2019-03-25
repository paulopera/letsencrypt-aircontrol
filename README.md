# letsencrypt-unifi-aircontrol

Script to import a letsencrypt certificate to airControl from Ubiquiti. This script is only to make the deploy to AirControl and not getting the certificate. I expect that you already has the desired certificate created.

All the Credits to https://help.ubnt.com/hc/en-us/articles/115005593008-airControl-How-to-Install-SSL-Certificate-for-the-airControl-Server and https://util.wifi.gl/unifi-import-cert.sh

Be free to modify and optimize this script as your needs. 


After downloading the script to the desirable folder, modify certbot cron to also execute it.
It will look something like this:

30 0 5 */2 * root /usr/bin/certbot renew --deploy-hook /PATH-YOUR-CHOICE/letsencrypt-aircontrol/aircontrol-import-cert.sh

After certificate is renewed it will be also deployed to the AirControl.
