#!/bin/sh
# -conslog runs ski-fake-xterm, which logs the console output to a file.
. "$srcdir/defs.sh"

: "${FAKE_XTERM_DIR:?}"
log=$tmpdir/console.log
run env PATH="$FAKE_XTERM_DIR:$PATH" DISPLAY= "$BSKI" -conslog "$log" "$HELLO"
expect_status 0
expect_empty "$out"
expect_empty "$err"
test -f "$log" || fail "no console log written"
# The console is a pty, so newlines arrive as CR LF.
tr -d '\r' < "$log" > "$tmpdir/console.txt"
expect_line "$tmpdir/console.txt" "hello, world"
pass
