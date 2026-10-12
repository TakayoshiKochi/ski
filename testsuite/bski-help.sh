#!/bin/sh
# -help lists the command-line options (and exits with status 1).
. "$srcdir/defs.sh"

run "$BSKI" -help
expect_status 1
expect_empty "$out"
expect_line "$err" "Options:"
expect_text "$err" "-help        Display command-line options"
pass
