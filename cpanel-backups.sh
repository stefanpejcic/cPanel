# Check cPanel backup log for errors
tail -100 $(ls -dt /usr/local/cpanel/logs/cpbackup/* | head -n1) | grep 'error\|warn'

# Check the time when the backups finished
tail -3 $(ls -dt /usr/local/cpanel/logs/cpbackup/* | head -n1)

# Check how many accounts got backup
echo "Total Accounts to backup: $(grep -Li "suspended" $(grep -l "^BACKUP=1" /var/cpanel/users/*) | wc -l)" && echo "Backed up accounts: $(cd "$(grep "BACKUPDIR" /var/cpanel/backups/config | awk '{print $2}')"/"$(date -dlast-sunday +%Y-%m-%d)"/accounts && ls | wc -l)"

# Same, but different folder structure
echo "Total Accounts to backup: $(grep -Li "suspended" $(grep -l "^BACKUP=1" /var/cpanel/users/*) | wc -l)" && echo "Backed up accounts: $(cd "$(grep "BACKUPDIR" /var/cpanel/backups/config | awk '{print $2}')"/"$(date -dlast-sunday +%Y-%m-%d)"/accounts && ls | wc -l)"
