#!/bin/sh

coffee -bc bin
coffee -c lib

SHEBANG="#!/usr/bin/env node"
for JS in $(ls bin/*.js)
do
    printf "%s\n\n" "$SHEBANG" | cat - $JS > /tmp/junla && mv /tmp/junla $JS
done
