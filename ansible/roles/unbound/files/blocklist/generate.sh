#!/bin/sh

#
# Parsing args
#

while [ "$#" -gt 0 ]; do
    case $1 in
        -b|--blocklist) blocklist="$2"; shift;;
        -o|--output)    output="$2"; shift;;
        *) echo "$0: illegal option -- $1"; exit 1;;
    esac; shift
done

#
# Sanity check
#

if [ ! -f "$blocklist" ]; then
    echo "$0: expected --blocklist to be a path to a file."
    exit 1
fi

if [ ! "$output" ]; then
    echo "$0: expected --output to be present."
    exit 1
fi

if [ -x "$(command -v curl)" ]; then
    fetch_cmd="curl -sL"
elif [ -x "$(command -v fetch)" ]; then
    fetch_cmd="fetch -qo -"
else
    echo "$0: expected either fetch or curl to be installed."
    exit 1
fi

#
# Blocklist parsing
#

parse_blocklist() {
    awk -F \# '$1 != "" { print $1 }' "$1" | while read -r line; do
        # pass line as argument to parse function
        # shellcheck disable=SC2086
        eval parse_blocklist_line $line
    done | sort -u
}

parse_blocklist_line() {
    case "$1" in
        hostfile)   parse_hostfile "$2" "$3";;
        domainonly) parse_domainonly "$2";;
    esac
}

parse_hostfile() {
    eval "$fetch_cmd" "$2" | awk "\$1 == \"$1\" { print tolower(\$2) }" | tr -d "\\r"
}

parse_domainonly() {
    eval "$fetch_cmd" "$1" | awk -F \# '$1 != "" { print tolower($1) }' | tr -d "\\r"
}

#
# Main
#

parse_blocklist "$blocklist" | awk '{
    print "local-zone: \""$1"\" static"
}' | tee "$output" > /dev/null
