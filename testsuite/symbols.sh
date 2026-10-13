#!/bin/sh
# Read and write internal symbols with the "=" and "eval" commands:
# single registers, register sets and bit fields.  In batch mode the
# command output goes to stderr.
. "$srcdir/defs.sh"

run "$BSKI" -noconsole -i "$srcdir/symbols.ini" "$HELLO"
expect_status 0
expect_line "$out" "hello, world"
for line in '$insts$ = 100' 'r9 = 1234' 'r9.nat = 1' 'p5 = 0' \
	    'f10.e = 1003e' 'psr.up = 1' '$exited$ = 0'; do
    expect_line "$err" "$line"
done
expect_line "$err" "p5 = 1"
pass
