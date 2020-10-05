#WHO accessed to a certain acc
grep USERNAME /usr/local/cpanel/logs/session_log | grep "NEW .*app=cpaneld" | awk "{print $6}" | sort -u | uniq

#WHO suspended email acc
grep suspend_incoming /usr/local/cpanel/logs/access_log




https://sysally.com/mail-sync/
