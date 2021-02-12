#! /bin/sh
#
#    Display a little link at the end of the account creation
#    to allow admin to jump straight into cpanel on the domain
#
#    Can be called from /etc/postwwwacct.dir or as /scripts/postwwwacct
#
#    This doesn't always work and I have no idea why!
#
#    Brian Coogan, March 2005
#

# @@INVISIBLE@@

domain=$1
username=$2

: ${HTTP_HOST:=`hostname`} # simulate cpanel if run from commandline
url="http://${HTTP_HOST}:2086/xfercpanel/$username"

echo -n "<br><table border=2><tr><td>"
echo -n "<b><a href=\"${url}\" target=\"_blank\">"
#echo -n "<font size=\"+2\">"
echo -n "Click here to jump to $domain in cpanel"
#echo -n "</font>"
echo -n "</a></b>"
echo -n "</td></tr></table>"
echo

exit 0
