#! /bin/sh
#
#  Make it easier to fulfil soholaunch accounts through fantastico.
#  Without this you have to rename the skeleton index.php 
#
PATH=/usr/local/sbin:/usr/local/bin:$PATH
export PATH

#arg 16: resellername
#arg 17: planname
#arg 21: contact@email.com

ME=${0##*/}
fatal() { echo " - error: $ME: $*"; exit 1; }

case ${17} in
*fido*) ;;
*)	exit 0
	;;
esac

wwhome=/home/$2/public_html
cd $wwhome || fatal could not cd to $wwhome

if [ -f index.php ]
then
    if mv index.php index.php_wdgf
    then
	echo " - renamed index.php to index.php_wdgf to make it" \
	   "easy to install Fido"
    else
	fatal could not rename $wwhome/index.php
    fi
fi

touch /home/$2/.need_fido

# a cron script checks for these .need_fido files and renames index.php back
# if sohoadmin exists and index.php doesn't exist
# it also emails out a warning that soholaunch/fido hasn't been installed

exit 0


# -End-
