#!/bin/sh
# A debug-event break must not overwrite r8 and r10 the way a system
# call returns its results.
. "$srcdir/defs.sh"

run "$BSKI" -noconsole -i "$srcdir/break-debug-event.ini" "$HELLO"
expect_status 0
expect_line "$err" "r8 = 4d2"
expect_line "$err" "r10 = 162e"
pass
