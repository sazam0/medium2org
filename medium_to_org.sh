#!/usr/bin/env bash

function urlencode {
    python -c "
from __future__ import print_function
try:
    from urllib import quote  # Python 2
except ImportError:
    from urllib.parse import quote  # Python 3
import sys

print(quote(sys.stdin.read()[:-1], safe=''))"
}

if [ "$#" = "2" ]; then
    url=$1
    protocol="$2"
else
    url=$1
    protocol="x"
fi

md="$(med2md $1)"

body="$(pandoc -f markdown -t org <<< "$md")"

IFS='/'
read -ra ADDR <<< "$1"

title="${ADDR[$"${#ADDR[@]}"-1]}"
title="$(echo $title | sed "s/-[^-]*$//" | tr '-' ' ')"

title=$(urlencode <<<"$title") || die "Unable to urlencode heading."
url=$(urlencode <<<"$url") || die "Unable to urlencode URL."
body=$(urlencode <<<"$body") || die "Unable to urlencode HTML."
# protocol=$(urlencode <<<"$protocol") || die "Unable to urlencode HTML."

emacsclient "org-protocol://capture?template=$protocol&url=$url&title=$title&body=$body"