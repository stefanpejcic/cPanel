#!/bin/bash

OUTFILE="/root/domain_check_failures.txt"
TMPDIR="/tmp/domain_check"
LOCKFILE="/tmp/domain_check.lock"
PARALLEL=$(( $(nproc --all 2>/dev/null || echo 4) > 20 ? 20 : $(nproc --all 2>/dev/null || echo 4) ))
MAX_TIME=5
CONNECT_TIMEOUT=3
SLOW_THRESHOLD=2

SKIP_PREFIXES=("cpanel." "webmail." "whm." "mail." "ftp." "smtp." "pop." "imap." "ns1." "ns2." "autodiscover.")

mkdir -p "$TMPDIR"
> "$OUTFILE"
trap 'rm -rf "$TMPDIR" "$LOCKFILE"' EXIT

log_result() {
    flock "$LOCKFILE" bash -c "echo \"$1\" >> \"$OUTFILE\""
}

check_domain() {
    local domain="$1"
    local tmpfile="$TMPDIR/$(echo "$domain" | tr '/: ' '___').tmp"

    for prefix in "${SKIP_PREFIXES[@]}"; do
        if [[ "$domain" == "$prefix"* ]]; then
            return
        fi
    done

    local url="http://$domain/?nocache=$RANDOM$RANDOM"

    local curl_output
    curl_output=$(curl -skL --max-time "$MAX_TIME" --connect-timeout "$CONNECT_TIMEOUT" --retry 1 --retry-delay 1 -w "%{http_code} %{time_total}" -o "$tmpfile" "$url" 2>/dev/null)
    local curl_exit=$?

    if [[ $curl_exit -ne 0 ]]; then
        case $curl_exit in
            6)  log_result "[DNS FAIL]     $domain" ;;
            7)  log_result "[CONN REFUSED] $domain" ;;
            28) log_result "[TIMEOUT]      $domain" ;;
            *)  log_result "[CURL ERROR $curl_exit] $domain" ;;
        esac
        return
    fi

    local http_code time_total
    read -r http_code time_total <<< "$curl_output"

    if ! [[ "$http_code" =~ ^[0-9]+$ ]]; then
        log_result "[PARSE ERROR]  $domain (bad http_code: $http_code)"
        return
    fi

    local body
    body=$(cat "$tmpfile" 2>/dev/null)

    if (( $(echo "$time_total > $SLOW_THRESHOLD" | bc -l 2>/dev/null) )); then
        log_result "[SLOW ${time_total}s]   $domain"
    fi

    if [[ "$http_code" -ge 200 && "$http_code" -lt 400 ]]; then
        if [[ -z "$(echo "$body" | tr -d '[:space:]')" ]]; then
            log_result "[EMPTY BODY]   $domain (HTTP $http_code)"
            return
        fi

        if echo "$body" | grep -qiE \
            "database error|db error|mysql error|sql syntax|connection refused|\
error establishing a database connection|too many connections|\
table .* doesn.t exist|access denied for user|\
fatal error|internal server error|wordpress.*error|wp-login"; then
            log_result "[DB/APP ERROR] $domain (HTTP $http_code)"
        fi
    elif [[ "$http_code" -ge 500 ]]; then
        log_result "[SERVER ERROR $http_code] $domain"
    elif [[ "$http_code" -ge 400 ]]; then
        if [[ "$http_code" -eq 404 ]]; then
            log_result "[NOT FOUND 404] $domain"
        else
            log_result "[CLIENT ERROR $http_code] $domain"
        fi
    else
        log_result "[UNEXPECTED $http_code] $domain"
    fi

    rm -f "$tmpfile"
}

export -f check_domain log_result
export OUTFILE TMPDIR LOCKFILE MAX_TIME CONNECT_TIMEOUT SLOW_THRESHOLD
export -a SKIP_PREFIXES

DOMAIN_LIST=$(cat /etc/localdomains /etc/remotedomains 2>/dev/null | grep -vE '^\s*$|^#' | sort -u)

TOTAL=$(echo "$DOMAIN_LIST" | wc -l)
echo "Checking $TOTAL unique domains with $PARALLEL parallel workers..."
START_TIME=$(date +%s)

echo "$DOMAIN_LIST" | xargs -P "$PARALLEL" -I {} bash -c 'check_domain "$@"' _ {}

END_TIME=$(date +%s)
ELAPSED=$(( END_TIME - START_TIME ))
FAILURE_COUNT=$(wc -l < "$OUTFILE")

echo ""
echo "======================================="
echo " Domain Check Complete"
echo "======================================="
echo " Total domains checked : $TOTAL"
echo " Issues found          : $FAILURE_COUNT"
echo " Time elapsed          : ${ELAPSED}s"
echo " Results written to    : $OUTFILE"
echo "======================================="

if [[ $FAILURE_COUNT -gt 0 ]]; then
    echo ""
    echo "--- Failure Breakdown ---"
    grep -oP '^\[\K[^\]]+' "$OUTFILE" | sort | uniq -c | sort -rn | awk '{printf "  %-5s %s\n", $1, $2}'
fi
