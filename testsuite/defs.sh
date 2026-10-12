# Common definitions for the ski test scripts.  Sourced by each test;
# the variables below are exported by testsuite/Makefile.am.

: "${BSKI:?}" "${SKI:?}" "${HELLO:?}"

# Each test gets its own scratch directory in the build tree.
tmpdir=`basename "$0" .sh`.dir
rm -rf "$tmpdir" && mkdir "$tmpdir" || exit 99
out=$tmpdir/stdout
err=$tmpdir/stderr

fail ()
{
    echo "FAIL: $*"
    for f in "$out" "$err"; do
	test -s "$f" && { echo "--- $f:"; cat "$f"; }
    done
    exit 1
}

# run CMD...: run CMD with stdout/stderr captured, set $status
run ()
{
    "$@" > "$out" 2> "$err" < /dev/null
    status=$?
}

expect_status ()
{
    test "$status" -eq "$1" || fail "exit status $status, expected $1"
}

# expect_line FILE TEXT: FILE has a line that is exactly TEXT
expect_line ()
{
    grep -qxF -e "$2" "$1" || fail "$1 lacks line '$2'"
}

# expect_text FILE TEXT: FILE contains TEXT
expect_text ()
{
    grep -qF -e "$2" "$1" || fail "$1 lacks '$2'"
}

expect_empty ()
{
    test ! -s "$1" || fail "$1 is not empty"
}

pass ()
{
    rm -rf "$tmpdir"
    exit 0
}
