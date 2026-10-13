#!/bin/sh
# Without -noconsole, ski tries to open an xterm for the program's I/O.
# When that is impossible it must warn and use stdin/stdout instead of
# silently producing no output.
. "$srcdir/defs.sh"

run env PATH=/nonexistent DISPLAY= "$BSKI" "$HELLO"
expect_status 0
expect_line "$out" "hello, world"
expect_text "$err" "unable to open a console window (xterm)"
pass
