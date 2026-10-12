#!/bin/sh
# A system call made with break.b must see the syscall number and
# arguments, like one made with break.i or break.m.
. "$srcdir/defs.sh"

run "$BSKI" -noconsole -stats -i "$srcdir/break-b.ini" "$HELLO"
expect_status 42
expect_line "$err" "program exited with status 42"
pass
