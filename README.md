# DOMAINS

### Which user owns the domain (addon/allias)
/scripts/whoowns domain.com

***

# BACKUPS

### Check cPbackup for errors
tail -100 $(ls -dt /usr/local/cpanel/logs/cpbackup/* | head -n1) | grep 'error\|warn'

### Check when backup finished
tail -3 $(ls -dt /usr/local/cpanel/logs/cpbackup/* | head -n1)

### Number of accounts that were backed up
echo "Total Accounts to backup: $(grep -Li "suspended" $(grep -l "^BACKUP=1" /var/cpanel/users/*) | wc -l)" && echo "Backed up accounts: $(cd "$(grep "BACKUPDIR" /var/cpanel/backups/config | awk '{print $2}')"/"$(date -dlast-sunday +%Y-%m-%d)"/accounts && ls | wc -l)"

###  When was the last Jetbackup and is it done
echo -e "\\n~~~~JB accounts backup last job stats~~~\\n" && tail -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print "Job date:"$1"-"$2" "$3", status: "$7" "$8}' | tr '[' ' ' && echo "Start time:" && head -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print $4}' | cut -d ':' -f 1,2 | awk '{print $0" AM"}' && echo "End time:" && tail -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print $4}' | cut -d ':' -f 1,2 && echo ""

***

# EMAILS


### EMAILS sort emails by login no
head -1 /var/log/exim_mainlog | awk '{print $1}' ; egrep -o 'dovecot_login[^ ]+|dovecot_plain[^ ]+' /var/log/exim_mainlog | cut -f2 -d":" | sort|uniq -c|sort -nk 1 ; tail -1 /var/log/exim_mainlog | awk '{print From $1}'2020-10-25

### REJECTED EMAILS FOR A SINGLE E-ADDRESS
exigrep user@domain.com /var/log/exim_rejectlog*

### FAILED Logins on email address
grep DOMAIN.com /var/log/maillog | grep failed

### ALL logins/msgs for an email address
grep dovecot_login:user@domain.com /var/log/exim_mainlog

### Regenerate mailbox size for a user
/scripts/generate_maildirsize --confirm --allaccounts --verbose USERNAME

***

# ACCOUNTS
 
 
### Suspend an account 
/scripts/suspendacct USERNAME

### Unsuspend an account:
/scripts/unsuspendacct USERNAME

## List of suspended accounts
ll /var/cpanel/suspended
or
cat /usr/local/apache/conf/includes/account_suspensions.conf

***

# MALWARE FINDING

### POST requests for cpanel acc
grep POST /home/USERNAME/access-logs/* | awk '{print $7}' | sort | uniq -c | sort -n

### WORDPRESS ATTACKS
egrep -c '(wp-comments-post.php|wp-login.php|xmlrpc.php)' /usr/local/apache/domlogs/* |grep -v "_log" |sort -t: -nr -k 2 |head -5 |tee /tmp/delete_check |cut -d'/' -f6; for domlog in $(cut -d':' -f1 /tmp/delete_check); do echo; echo $domlog; echo; echo wp-login.php :: $(grep -c wp-login.php $domlog); echo; grep wp-login.php $domlog | cut -d' ' -f1|egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; echo xmlrpc.php :: $(grep -c xmlrpc.php $domlog); echo; grep xmlrpc.php $domlog |cut -d' ' -f1 |egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; echo wp-comments-post.php :: $(grep -c wp-comments-post.php $domlog); echo; grep wp-comments-post.php $domlog |cut -d' ' -f1 |egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; done


### CWD mail scripts among files
tail -n2000 /var/log/exim_mainlog|grep /home/USERNAME/


### SCAN files for malware

grep -R "base64_" /home/USERNAME/
grep -lr --include=*.php "eval(base64_decode" .
grep -lr --include=*.php "eval" .
grep -lr --include=*.php "base64" .

### Maldet scanner
maldet -a /path/to/directory

***

# SSL

### Check AutoSSL status for user

/usr/local/cpanel/bin/autossl_check --user=USERNAME

### Clear AutoSSL Pending Queue

cd /var/cpanel
mv autossl_queue_cpanel.sqlite autossl_queue_cpanel.sqlite.old
/usr/local/cpanel/bin/autossl_check_cpstore_queue

***

# LOGS

### GREP IP ACCESS LOG status 503
grep IP-GOES-HERE addon-domain.main-domain-name.extension-ssl_log | grep 503

### WHICH USERNAME IP USED FOR MAILLOGIN
grep IP-GOES-HERE /var/log/maillog

### GREP WHICH DOMAINS IS IP ACCESSING
grep -rle 'IP-GOES-HERE' /usr/local/apache/domlogs/. | uniq

### GREP username or IP address in the error log
grep "USERNAME" /usr/local/cpanel/logs/error_log

### WHO accessed to a certain acc
grep USERNAME /usr/local/cpanel/logs/session_log | grep "NEW .*app=cpaneld" | awk "{print $6}" | sort -u | uniq

### WHO accessed from an IP address
grep IP-GOES-HERE /usr/local/cpanel/logs/session_log | grep cpanel-user

### WHO suspended email acc
grep suspend_incoming /usr/local/cpanel/logs/access_log

### Where IP tried to login (cpanel, webdisk, webmail..)
grep IP-GOES-HERE /usr/local/cpanel/logs/login_log


***

# Configuration

### No of SMTP connections
cat /etc/exim.conf |grep smtp_accept_max
