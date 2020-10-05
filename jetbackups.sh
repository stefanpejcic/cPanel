# Check last time backups ran, status and time

echo -e "\\n~~~~JB accounts backup last job stats~~~\\n" && tail -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print "Job date:"$1"-"$2" "$3", status: "$7" "$8}' | tr '[' ' ' && echo "Start time:" && head -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print $4}' | cut -d ':' -f 1,2 | awk '{print $0" AM"}' && echo "End time:" && tail -1 $(find /usr/local/jetapps/var/log/jetbackup/backup/ -type f -size +2k | xargs ls -dt | head -n 1) | awk '{print $4}' | cut -d ':' -f 1,2 && echo ""


