#!/bin/sh
# Run hand-assembled floating-point instructions:
# fma 2.0 * 3.0 + 1.0 = 7.0, fmax(2.0, 3.0) = 3.0, fmin(2.0, 3.0) = 2.0.
. "$srcdir/defs.sh"

run "$BSKI" -noconsole -i "$srcdir/fp.ini" "$HELLO"
expect_status 0
for line in 'f8.e = 10001' 'f8.m = e000000000000000' \
	    'f9.e = 10000' 'f9.m = c000000000000000' \
	    'f10.e = 10000' 'f10.m = 8000000000000000'; do
    expect_line "$err" "$line"
done
pass
