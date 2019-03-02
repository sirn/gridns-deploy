#!/bin/sh

## Parsing args
##

while [ "$#" -gt 0 ]; do
    case $1 in
        -b|--blocklist) blocklist="$2"; shift;;
        -w|--workdir)   workdir="$2";   shift;;
        *)
            printf "%s: illegal option -- %s\\n" "$0" "$1" >&2
            exit 1
            ;;
    esac
    shift
done


## Sanity check
##

if [ ! -f "$blocklist" ]; then
    printf "%s: expected --blocklist to be a path to a file.\\n" "$0" >&2
    exit 1
fi

if [ ! "$workdir" ]; then
    printf "%s: expected --workdir to be present.\\n" "$0" >&2
    exit 1
fi

if [ -x "$(command -v curl)" ]; then
    fetch_url() {
        curl -sfL -o "$1" "$2"
    }
elif [ -x "$(command -v fetch)" ]; then
    fetch_url() {
        fetch -qo "$1" "$2"
    }
else
    printf "%s: expected either fetch or curl to be installed.\\n" "$0" >&2
    exit 1
fi


## Main
##

current_time=$(date +%s)
cache_age=259200
cache_dir="$workdir/cache"
tmpfile=$(mktemp)

trap 'rm -f $tmpfile' 0 1 2 3 6 14 15
mkdir -p "$cache_dir"

awk -F \# '$1 != "" { print $1 }' "$blocklist" | while read -r line; do
    eval set -- "$line"
    case "$1" in
        hostfile)   _url="$3"; _prefix="$2";;
        domainonly) _url="$2";;
    esac

    # Cache the host file for at least $cache_age so we can fallback to older
    # data when fetching fails rather than all hosts from that blocklist
    # gone missing.
    _cache_name=$(printf "%s" "$_url" | tr -C "[a-zA-Z0-9]" "_")
    _cache_file="$cache_dir/$_cache_name"
    _fetch=1

    if [ -f "$_cache_file" ]; then
        _delta=$((current_time - $(date -r "$_cache_file" +%s)))
        if [ $_delta -lt $cache_age ]; then
            printf "%s: skipping %s (age %s < %s)\\n" "$0" "$_url" "$_delta" "$cache_age" >&2
            _fetch=0
        fi
    fi

    if [ "$_fetch" != "0" ] && ! fetch_url "$_cache_file" "$_url"; then
        printf "%s: could not fetch %s, skipping\\n" "$0" "$_url" >&2
    fi

    # Normalize the data
    if [ -f "$_cache_file" ]; then
        case "$1" in
            hostfile)   awk "\$1 == \"$_prefix\" { print tolower(\$2) }" < "$_cache_file";;
            domainonly) awk -F \# '$1 != "" { print tolower($1) }' < "$_cache_file";;
        esac | tr -d "\\r"
    fi
done | sort -u | awk '{ print "local-zone: \""$1"\" static" }' > "$tmpfile"

mv "$tmpfile" "$workdir/blocklist.conf"
chmod 644 "$workdir/blocklist.conf"
