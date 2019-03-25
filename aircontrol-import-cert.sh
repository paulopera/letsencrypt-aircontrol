#!/bin/bash
# Author: https://github.com/peraun 09-17-2018 - Revised: 03/24/2019
# Credits https://help.ubnt.com/hc/en-us/articles/115005593008-airControl-How-to-Install-SSL-Certificate-for-the-airControl-Server
# Credits https://util.wifi.gl/unifi-import-cert.sh
# Script location: /opt/xxxx (your choice)
# Check where is located your file aircontrol.keystore to set it in: -destkeystore /opt/Ubiquiti/AirControl2/web/etc/aircontrol.keystore
# Tested with Ubuntu 18.04.2 LTS and airControl v2.1.1-RC-190221-1137 - should work with any recent Unifi and Ubuntu/Debian releases


#************************************************
#********************Script**********************
#************************************************

# Set the Domain name, valid DNS entry must exist
DOMAIN="domain.com"
# Set the folder path of your choice. Preferably after /opt and without "/" in the end
FOLDER="/opt/FOLDER_OF_CHOICE"
# Set password for the PKCS12 
PASSWORD="PASSWORD"

# Backup previous keystore
cp /opt/Ubiquiti/AirControl2/web/etc/aircontrol.keystore /opt/Ubiquiti/AirControl2/web/etc/keystore.backup.$(date +%F_%R)

#Remove after backup to renew the file above
rm /opt/Ubiquiti/AirControl2/web/etc/aircontrol.keystore

# Convert cert to PKCS12 format
openssl pkcs12 -export -inkey /etc/letsencrypt/live/${DOMAIN}/privkey.pem -in /etc/letsencrypt/live/${DOMAIN}/fullchain.pem -out /etc/letsencrypt/live/${DOMAIN}/fullchain.p12 -name aircontrol -password pass:${PASSWORD}

# Import certificate and override existing keystore file from the one you just converted.
keytool -importkeystore -deststorepass '${PASSWORD}' -destkeypass '${PASSWORD}' -destkeystore /opt/Ubiquiti/AirControl2/web/etc/aircontrol.keystore -srckeystore /etc/letsencrypt/live/${DOMAIN}/fullchain.p12 -srcstoretype PKCS12 -srcstorepass '${PASSWORD}' -alias aircontrol 

# Obfuscate keystore_password using the following command, but keep in mind that 
# the jetty version's can change so if a renew is broke check the path if it matches the actual version:
OBF1="`java -cp /opt/Ubiquiti/AirControl2/lib/jetty-all-9.4.10.v20180503.jar org.eclipse.jetty.util.security.Password '${PASSWORD}' &> ${FOLDER}/letsencrypt-unifi-aircontrol/aircontrol.keystore`" 
OBF2=`sed -n 3p ${FOLDER}/letsencrypt-unifi-aircontrol/aircontrol.keystore | awk '{print $1}' | cut -f2 -d:`

#Set the file to replace OBF string:
file=/opt/Ubiquiti/AirControl2/web/etc/jetty-ssl.xml

#Replace OBF:xxxxxxxx with newly obfuscated in the following
new_value_keystore='<Set name="KeyStorePassword"><Property name="jetty.keystore.password" default="'OBF:${OBF2}'"/></Set>'
new_value_truststore='<Set name="TrustStorePassword"><Property name="jetty.truststore.password" default="'OBF:${OBF2}'"/></Set>'

#Set the keystore value
sed -i '11s|.*|'"${new_value_keystore}"'|' ${file};
#Set the truststore value
sed -i '12s|.*|'"${new_value_truststore}"'|' ${file};

# Restart the UniFi controller
echo "Restarting the AirConrol Server"
service airControl2Server restart


