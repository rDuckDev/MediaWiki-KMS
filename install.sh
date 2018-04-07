#!/bin/bash

echo "Installing MediaWiki"
read -p "Enter the name of your wiki: " WIKI_NAME
cd /var/www/html/
wget https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.4.tar.gz
tar -xvzf mediawiki-1.27.4.tar.gz
rm mediawiki-1.27.4.tar.gz
mv mediawiki-1.27.4 $WIKI_NAME
chown -R www-data:www-data $WIKI_NAME
cd $WIKI_NAME

echo "Installing MediaWiki extensions"
cd extensions
# VisualEditor https://www.mediawiki.org/wiki/Extension:VisualEditor
wget https://extdist.wmflabs.org/dist/extensions/VisualEditor-REL1_27-9da5996.tar.gz
tar -xvzf VisualEditor-REL1_27-9da5996.tar.gz
rm VisualEditor-REL1_27-9da5996.tar.gz
# RevisionSlider https://www.mediawiki.org/wiki/Extension:RevisionSlider
wget https://extdist.wmflabs.org/dist/extensions/RevisionSlider-REL1_27-c980a0c.tar.gz
tar -xvzf RevisionSlider-REL1_27-c980a0c.tar.gz
rm RevisionSlider-REL1_27-c980a0c.tar.gz

echo "Creating MySQL database for MediaWiki"
SYSOPPASS=`pwgen -cnyB1 12`
USERPASS=`pwgen -cnyB1 8`
while true
do
	read -p "MySQL password for user root: " MySQL_ROOT
	read -p "Confirm password for user root: " CONFIRM

	if [ "$CONFIRM" = "$MySQL_ROOT" ]
	then
		mysql -u root -p$MySQL_ROOT -e "CREATE DATABASE $WIKI_NAME;"
		mysql -u root -p$MySQL_ROOT -e "GRANT ALL PRIVILEGES ON $WIKI_NAME.* TO 'wiki-sysop'@localhost IDENTIFIED BY '$SYSOPPASS';"
		mysql -u root -p$MySQL_ROOT -e "GRANT SELECT, INSERT, UPDATE, DELETE ON $WIKI_NAME.* TO 'wiki'@localhost IDENTIFIED BY '$USERPASS';"

		break
	else
		echo "Passwords did not match"
	fi
done

echo "Installing Parsoid"
cd /usr/lib/
# Parsoid 0.5.1 was the last version to work with MW 1.27 branch
git clone https://github.com/wikimedia/parsoid.git -b v0.5.1
cd parsoid
npm install
cp localsettings.js.example localsettings.js

echo "Registering the Parsoid service"
cd /etc/systemd/system
wget https://github.com/rDuckDev/MediaWiki-on-Ubuntu/raw/master/parsoid.service
chmod 740 parsoid.service
chown root:root parsoid.service
systemctl daemon-reload
systemctl enable parsoid
systemctl start parsoid

# print config options
LOGFILE="/var/www/html/README"
IP_ADDR=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

echo `date` > $LOGFILE
echo " " >> $LOGFILE
echo "Parsoid configuration: /usr/lib/parsoid/localsettings.js" >> $LOGFILE
echo "MediaWiki API: http://$IP_ADDR/$WIKI_NAME/api.php" >> $LOGFILE
echo " " >> $LOGFILE
echo "Open your browser to http://$IP_ADDR/$WIKI_NAME to configure MediaWiki" >> $LOGFILE
echo " " >> $LOGFILE
echo "Database host: localhost" >> $LOGFILE
echo "Database name: $WIKI_NAME" >> $LOGFILE
echo "Database user: wiki-sysop" >> $LOGFILE
echo "Database pass: $SYSOPPASS" >> $LOGFILE
echo "Wiki name: $WIKI_NAME" >> $LOGFILE
echo " " >> $LOGFILE
echo "Add the following settings to LocalSettings.php" >> $LOGFILE
echo "wgDBuser: wiki" >> $LOGFILE
echo "wgDBpassword: $USERPASS" >> $LOGFILE
echo "wgDBadminuser: wiki-sysop" >> $LOGFILE
echo "wgDBadminpassword: $SYSOPPASS" >> $LOGFILE

echo "Check $LOGFILE for installation details."
echo "Finished!"

read -p "Press enter to continue..." BURN
