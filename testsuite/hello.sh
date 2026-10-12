#!/bin/sh
# Run the prebuilt IA-64 "hello, world" in batch mode.
. "$srcdir/defs.sh"

run "$BSKI" -forceuser -noconsole "$HELLO"
expect_status 0
expect_line "$out" "hello, world"
expect_empty "$err"
pass
