#!/bin/sh

command -v coffee >/dev/null 2>&1
if [ $? -ne 0 ]
then
    echo >&2 "CoffeeScript must be installed first."
    exit 1
fi

coffee -bc bin
coffee -c lib

SHEBANG="#!/usr/bin/env node"
for JS in $(ls bin/*.js)
do
    printf "%s\n\n" "$SHEBANG" | cat - $JS > /tmp/junla && mv /tmp/junla $JS
done
