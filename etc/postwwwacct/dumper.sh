#! /bin/sh
#
#   Dump arguments, anvironment, uid and pwd to logfile so we can tell
#    what's happening ...
#

log=/var/log/postwwwacct
umask 027

echo "Dumping postwwwacct status to $log"

echo ==== `date` ===== >> $log


n=1
for arg
do
    echo arg $n: "$arg"
    (( n++ ))
done >> $log
env | sed -e 's/^/	env: /' >> $log
id >> $log
pwd >> $log
ls -ld /home/$2 >> $log
ls -F /home/$2/* >> $log
echo >> $log

chmod o= $log

exit 0
