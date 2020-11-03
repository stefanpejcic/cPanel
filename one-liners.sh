# WHO accessed to a certain acc
grep USERNAME /usr/local/cpanel/logs/session_log | grep "NEW .*app=cpaneld" | awk "{print $6}" | sort -u | uniq

# WHO suspended email acc
grep suspend_incoming /usr/local/cpanel/logs/access_log

# ALL logins/msgs for an email address
grep dovecot_login:user@domain.com /var/log/exim_mainlog

# CWD mail scripts among files
tail -n2000 /var/log/exim_mainlog|grep /home/USERNAME/


# EMAILS sort emails by login no
head -1 /var/log/exim_mainlog | awk '{print $1}' ; egrep -o 'dovecot_login[^ ]+|dovecot_plain[^ ]+' /var/log/exim_mainlog | cut -f2 -d":" | sort|uniq -c|sort -nk 1 ; tail -1 /var/log/exim_mainlog | awk '{print From $1}'2020-10-25


# POST requests for cpanel acc
grep POST /home/USERNAME/access-logs/* | awk '{print $7}' | sort | uniq -c | sort -n
 
# FAILED Logins
grep DOMAIN.com /var/log/maillog | grep failed

# WORDPRESS ATTACKS
egrep -c '(wp-comments-post.php|wp-login.php|xmlrpc.php)' /usr/local/apache/domlogs/* |grep -v "_log" |sort -t: -nr -k 2 |head -5 |tee /tmp/delete_check |cut -d'/' -f6; for domlog in $(cut -d':' -f1 /tmp/delete_check); do echo; echo $domlog; echo; echo wp-login.php :: $(grep -c wp-login.php $domlog); echo; grep wp-login.php $domlog | cut -d' ' -f1|egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; echo xmlrpc.php :: $(grep -c xmlrpc.php $domlog); echo; grep xmlrpc.php $domlog |cut -d' ' -f1 |egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; echo wp-comments-post.php :: $(grep -c wp-comments-post.php $domlog); echo; grep wp-comments-post.php $domlog |cut -d' ' -f1 |egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort |uniq -c |sort -nr | head; echo; done


https://sysally.com/mail-sync/

#SCAN files for malware

grep -R "base64_" /home/USERNAME/
grep -lr --include=*.php "eval(base64_decode" .
grep -lr --include=*.php "eval" .
grep -lr --include=*.php "base64" .
