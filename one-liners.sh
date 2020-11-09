------------------------ BACKUPS ------------------------

# Check cPbackup for errors
tail -100 $(ls -dt /usr/local/cpanel/logs/cpbackup/* | head -n1) | grep 'error\|warn'

# Check when backup finished
tail -3 $(ls -dt /usr/local/cpanel/logs/cpbackup/* | head -n1)

# Number of accounts that were backed up
echo "Total Accounts to backup: $(grep -Li "suspended" $(grep -l "^BACKUP=1" /var/cpanel/users/*) | wc -l)" && echo "Backed up accounts: $(cd "$(grep "BACKUPDIR" /var/cpanel/backups/config | awk '{print $2}')"/"$(date -dlast-sunday +%Y-%m-%d)"/accounts && ls | wc -l)"

#  When was the last Jetbackup and is it done
echo -e "\\n~~~~JB accounts backup last job stats~~~\\n" && tail -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print "Job date:"$1"-"$2" "$3", status: "$7" "$8}' | tr '[' ' ' && echo "Start time:" && head -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print $4}' | cut -d ':' -f 1,2 | awk '{print $0" AM"}' && echo "End time:" && tail -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print $4}' | cut -d ':' -f 1,2 && echo ""


# WHO accessed to a certain acc
grep USERNAME /usr/local/cpanel/logs/session_log | grep "NEW .*app=cpaneld" | awk "{print $6}" | sort -u | uniq

# WHO accessed from an IP address
grep IP-GOES-HERE /usr/local/cpanel/logs/session_log | grep cpanel-user

# WHO suspended email acc
grep suspend_incoming /usr/local/cpanel/logs/access_log

# ALL logins/msgs for an email address
grep dovecot_login:user@domain.com /var/log/exim_mainlog

# CWD mail scripts among files
tail -n2000 /var/log/exim_mainlog|grep /home/USERNAME/

------------------------ EMAILS ------------------------


# EMAILS sort emails by login no
head -1 /var/log/exim_mainlog | awk '{print $1}' ; egrep -o 'dovecot_login[^ ]+|dovecot_plain[^ ]+' /var/log/exim_mainlog | cut -f2 -d":" | sort|uniq -c|sort -nk 1 ; tail -1 /var/log/exim_mainlog | awk '{print From $1}'2020-10-25

# REJECTED EMAILS FOR A SINGLE E-ADDRESS
exigrep user@domain.com /var/log/exim_rejectlog*
 
------------------------ ACCOUNTS ------------------------
 
# FAILED Logins
grep DOMAIN.com /var/log/maillog | grep failed

# POST requests for cpanel acc
grep POST /home/USERNAME/access-logs/* | awk '{print $7}' | sort | uniq -c | sort -n


# WORDPRESS ATTACKS
egrep -c '(wp-comments-post.php|wp-login.php|xmlrpc.php)' /usr/local/apache/domlogs/* |grep -v "_log" |sort -t: -nr -k 2 |head -5 |tee /tmp/delete_check |cut -d'/' -f6; for domlog in $(cut -d':' -f1 /tmp/delete_check); do echo; echo $domlog; echo; echo wp-login.php :: $(grep -c wp-login.php $domlog); echo; grep wp-login.php $domlog | cut -d' ' -f1|egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; echo xmlrpc.php :: $(grep -c xmlrpc.php $domlog); echo; grep xmlrpc.php $domlog |cut -d' ' -f1 |egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; echo wp-comments-post.php :: $(grep -c wp-comments-post.php $domlog); echo; grep wp-comments-post.php $domlog |cut -d' ' -f1 |egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; done


------------------------ MALWARE FINDING ------------------------




# SCAN files for malware

grep -R "base64_" /home/USERNAME/
grep -lr --include=*.php "eval(base64_decode" .
grep -lr --include=*.php "eval" .
grep -lr --include=*.php "base64" .
