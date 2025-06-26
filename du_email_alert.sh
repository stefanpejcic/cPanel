#!/bin/bash

EMAIL=""
THRESHOLD=95
HOSTNAME=$(hostname)
OVERLIMIT=$(df -h --output=pcent,target | awk -v threshold=$THRESHOLD 'NR>1 {gsub(/%/,"",$1); if ($1+0 > threshold) print $0}')
SUBJECT="URGENT!!! du over ${THRESHOLD}% on $HOSTNAME\n\n$OVERLIMIT"

if [[ -n "$OVERLIMIT" ]]; then
    echo -e "Subject: $SUBJECT" | /sbin/sendmail -v "$EMAIL"
fi
