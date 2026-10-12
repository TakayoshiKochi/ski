#!/bin/sh
# An unknown option prints usage and the option list.
. "$srcdir/defs.sh"

run "$SKI" --help
expect_status 1
expect_empty "$out"
expect_line "$err" "unrecognized option --help"
expect_line "$err" "Usage: ski [options] [file [args]]"
expect_line "$err" "Options:"
pass
