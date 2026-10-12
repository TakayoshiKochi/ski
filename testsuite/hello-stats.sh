#!/bin/sh
# -stats reports the exit status and the instruction count.
. "$srcdir/defs.sh"

run "$BSKI" -noconsole -stats "$HELLO"
expect_status 0
expect_line "$out" "hello, world"
expect_line "$err" "program exited with status 0"
expect_text "$err" " insts, "
pass
