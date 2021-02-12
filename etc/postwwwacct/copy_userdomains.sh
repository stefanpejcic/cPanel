#! /bin/sh
#
#  Copy userdomains to readable version so holdingpage works
#  straight away (this is also done from crontab every 15 mins)
#


# on a busy system with lots of creations this might be better done
# as a mv operation ... also need to consider locking ....

cat /etc/userdomains > /etc/userdomains.readable;
chmod 644 /etc/userdomains.readable

exit 0
