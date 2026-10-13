#!/bin/sh
# SKIHOOK_PATH loads a shared library whose ski_hook() is called before
# each instruction, with optional ski_hook_init() and ski_hook_fini().
. "$srcdir/defs.sh"

: "${TESTHOOK:?}"
run env SKIHOOK_PATH="$TESTHOOK" "$BSKI" -noconsole "$HELLO"
expect_status 0
expect_line "$out" "hello, world"
expect_line "$err" "testhook: init"
grep -qx 'testhook: fini, [1-9][0-9]* calls' "$err" ||
    fail "hook was not called"

run env SKIHOOK_PATH="$tmpdir/nonexistent.so" "$BSKI" -noconsole "$HELLO"
expect_status 1
expect_text "$err" "Could not load hook"
pass
