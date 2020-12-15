#!/bin/bash
#Changes every cPanel password on the server and stores the credentials in ~/newCredentials
#$newPassword is a randomly generated password with 10 characters
export ALLOW_PASSWORD_CHANGE=1
ls -la /home | awk '{print $3}' | grep -v root | grep -v wheel | grep -v cpanel | grep -v apache | grep -v csf | grep -v '^$' > /tmp/usersforchpass
for i in `more /tmp/usersforchpass `
do
newPassword='Ahley@'$(</dev/urandom tr -dc 'A-Za-z0-9' | head -c6)'#74'
echo "Host/IP|$i|$newPassword" >> ~/cpanel.txt
echo "" >> ~/newCredentials
/scripts/chpass $i $newPassword
/scripts/mysqlpasswd $i $newPassword
done
