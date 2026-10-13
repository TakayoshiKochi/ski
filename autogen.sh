#!/bin/sh
# 
# Copyright (C) 1995-2007, Hewlett-Packard Development Company, L.P.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
# 
#
# Run this to generate all the initial makefiles, etc.
#

srcdir=`dirname "$0"`
test -z "${srcdir}" && srcdir=.

(test -f "${srcdir}/configure.ac") || {
    echo "**Error**: Directory \"${srcdir}\" does not look like the"\
         "top-level ski directory"
    exit 1
}

for tool in autoreconf libtoolize; do
    command -v $tool > /dev/null 2>&1 || {
        echo "**Error**: You must have \`$tool' installed to build ski."
        echo "See the file INSTALL for the list of required packages."
        exit 1
    }
done

autoreconf --force --install --verbose "${srcdir}" || exit 1

echo
echo "Now run \`${srcdir}/configure' and then \`make'."
