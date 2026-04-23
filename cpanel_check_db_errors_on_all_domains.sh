#!/bin/bash

OUTFILE="/root/domain_check_failures.txt"
TMPDIR="/tmp/domain_check"
mkdir -p "$TMPDIR"

> "$OUTFILE"

check_domain () {
    domain=$1

    if [[ "$domain" == cpanel.* || "$domain" == webmail.* ]]; then
        return
    fi

    RAND=$RANDOM
    tmpfile="$TMPDIR/$(echo "$domain" | tr '/' '_').tmp"

    url="http://$domain/?random=$RAND"

    response=$(curl -skL --max-time 5 -w "%{http_code}" "$url" -o "$tmpfile")
    curl_exit=$?

    if [ $curl_exit -ne 0 ]; then
        echo "[CURL ERROR] $domain ($url)" >> "$OUTFILE"
        return
    fi

    http_code=$(tail -n1 <<< "$response")
    body=$(cat "$tmpfile")

    if [[ "$http_code" -ge 200 && "$http_code" -lt 400 ]]; then
        if echo "$body" | grep -qiE \
            "database error|db error|mysql|sql syntax|connection refused|error establishing a database connection"; then
            echo "[DB ERROR SUSPECTED] $domain ($url)" >> "$OUTFILE"
        fi

    else
        echo "[FAILED] $domain" >> "$OUTFILE"
    fi
}


export -f check_domain
export OUTFILE TMPDIR

cat /etc/localdomains /etc/remotedomains | grep -v '^$' | xargs -P 10 -I {} bash -c 'check_domain "$@"' _ {}
