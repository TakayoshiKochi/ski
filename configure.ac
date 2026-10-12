## Process this file with autoconf to produce a configure script.
##
##
## Copyright (C) 1995-2007, Hewlett-Packard Development Company, L.P.
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or 
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, 
## but WITHOUT ANY WARRANTY; without even the implied warranty of 
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program; if not, write to the Free Software Foundation, Inc.,
## 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
##
##

# Requires autoconf 2.70 (for AC_PROG_LEX([noyywrap]))
AC_PREREQ([2.70])

m4_define([ski_major_version], [1])
m4_define([ski_minor_version], [3])
m4_define([ski_micro_version], [2])

AC_INIT([ski], [ski_major_version.ski_minor_version.ski_micro_version])
AC_CONFIG_SRCDIR([src/ski.h])
AC_CONFIG_MACRO_DIRS([macros])

dnl Canonical host
AC_CANONICAL_HOST
host_alias=$host dnl For dejagnu

case $host_os in
    linux*)	HOST_OS=linux;;
    hpux*)	HOST_OS=hpux;;
    freebsd*)	HOST_OS=freebsd;;
    *)		HOST_OS=unknown;;
esac
AC_SUBST(HOST_OS)
AM_CONDITIONAL(LINUX, test "$HOST_OS" = linux)
AM_CONDITIONAL(HPUX,  test "$HOST_OS" = hpux)
AM_CONDITIONAL(FREEBSD, test "$HOST_OS" = freebsd)

# Version number definitions
#
SKI_MAJOR_VERSION=ski_major_version
SKI_MINOR_VERSION=ski_minor_version
SKI_MICRO_VERSION=ski_micro_version
SKI_INTERFACE_AGE=0
SKI_BINARY_AGE=0
SKI_RELEASE=gplv2

SKI_VERSION=$SKI_MAJOR_VERSION.$SKI_MINOR_VERSION.$SKI_MICRO_VERSION
AC_SUBST(SKI_MAJOR_VERSION)
AC_SUBST(SKI_MINOR_VERSION)
AC_SUBST(SKI_MICRO_VERSION)
AC_SUBST(SKI_VERSION)
AC_SUBST(SKI_INTERFACE_AGE)
AC_SUBST(SKI_BINARY_AGE)
AC_SUBST(SKI_RELEASE)
AC_DEFINE_UNQUOTED([SKI_RELEASE], ["$SKI_RELEASE"], [Ski release string.])

# libtool versioning
LT_RELEASE=$SKI_MAJOR_VERSION.$SKI_MINOR_VERSION
LT_CURRENT=`expr $SKI_MICRO_VERSION - $SKI_INTERFACE_AGE`
LT_REVISION=$SKI_INTERFACE_AGE
LT_AGE=`expr $SKI_BINARY_AGE - $SKI_INTERFACE_AGE`
AC_SUBST(LT_RELEASE)
AC_SUBST(LT_CURRENT)
AC_SUBST(LT_REVISION)
AC_SUBST(LT_AGE)

# Specify the default install prefix
AC_PREFIX_DEFAULT(/usr/local)

# Initialize automake
AM_INIT_AUTOMAKE([foreign subdir-objects])

# Specify a configuration file
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_AWK
AC_PROG_SED
AC_PROG_YACC
AC_PROG_LEX([noyywrap])
if test "x$LEX" = "x:"; then
  AC_MSG_ERROR([flex (or lex) is required to build ski.])
fi

AC_C_INLINE

dnl Check for compiler kind (HP cc or Intel icc)
AC_LANG_COMPILER_CHECK

dnl Check for required build tools
AC_CHECK_PROG(GPERF, gperf, gperf)
if test -z "$GPERF"; then
  AC_MSG_ERROR([gperf is required to build ski.])
fi

dnl Check for the pager program
AC_CHECK_PROGS(PAGER, [less])
AC_DEFINE_UNQUOTED([PAGER], ["$PAGER"], [Define to the pager program.])

dnl Set yacc flags
YFLAGS=-d
AC_SUBST(YFLAGS)

dnl Initialize libtool (shared library disabled by default,
dnl enable with --enable-shared)
LT_INIT([disable-shared])

dnl dlopen() is used to load the optional SKIHOOK_PATH hook library
AC_SEARCH_LIBS([dlopen], [dl], [],
    [AC_MSG_ERROR([Required function dlopen not found.])])

dnl Initialize maintainer mode (rebuild rules enabled by default)
AM_MAINTAINER_MODE([enable])

dnl See if we build X11
AC_ARG_WITH(x11,
AS_HELP_STRING([--with-x11],
    [Enable the Motif based X11 interface default=no]),
    [with_x11=$withval],[with_x11=no])
  
if test "x$with_x11" = "xyes"; then
  dnl Check for motif, error out if not found
  AC_WITH_MOTIF
fi
# either way we need to set these
AM_CONDITIONAL(WITH_X_INTERFACE, test "x$with_x11" = "xyes")
AC_SUBST(X_INTERFACE_LIBS)
  
dnl See if we build GTK
AC_ARG_WITH(gtk,
AS_HELP_STRING([--with-gtk],
    [Enable building the GTK Ski interface default=no]),
    [with_gtk=$withval],[with_gtk=no]
)

if test "x$with_gtk" = "xyes"; then
 PKG_CHECK_MODULES([GSKI], [libglade-2.0 libgnomeui-2.0 >= 1.110.0])
 AC_DEFINE(HAVE_GTK, 1, [define if you have GTK support])
fi
AC_SUBST(GSKI_CFLAGS)
AC_SUBST(GSKI_LIBS)
AM_CONDITIONAL(WITH_GTK_INTERFACE, test "x$with_gtk" = "xyes")

dnl Target endianness
AC_ARG_ENABLE(bigendian,
AS_HELP_STRING([--enable-bigendian],
    [the target is big endian default=no]),
ski_cv_c_target_bigendian=${enableval}, ski_cv_c_target_bigendian=no)

dnl Check for host endianness
AC_CACHE_CHECK([whether host byte ordering is defined in sys/param.h],
ski_cv_c_bigendian_compile,
[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
#include <sys/types.h>
#include <sys/param.h>
]],[[
#if !BYTE_ORDER || !BIG_ENDIAN || !LITTLE_ENDIAN
#error bogus endian macros
#endif
]])],
ski_cv_c_bigendian_compile=yes, ski_cv_c_bigendian_compile=no)])

if test "x$ski_cv_c_bigendian_compile" = xyes; then
AC_DEFINE(ENDIANESS_IN_SYS_PARAM_H, 1,
    [define if sys/param.h defines the endiness])
else
AC_CACHE_CHECK([whether host byte ordering is big endian],
ski_cv_c_bigendian,
[AC_RUN_IFELSE([AC_LANG_SOURCE([[int main () {
    union {
        long l;
        char c[sizeof (long)];
    } u;
    u.l = 1;
    return (u.c[sizeof (long) - 1] == 1);
}]])],
ski_cv_c_bigendian=no, ski_cv_c_bigendian=yes,
AC_MSG_ERROR([cannot detect host endianness]))])

AC_DEFINE(BIG_ENDIAN,    4321, [define to 4321 if missing from sys/param.h])
AC_DEFINE(LITTLE_ENDIAN, 1234, [define to 4321 if missing from sys/param.h])
if test "x$ski_cv_c_bigendian" = xyes; then
    AC_DEFINE(BYTE_ORDER, 4321,
        [define to 4321 if host is big endian, 1234 if little endian])
else
    AC_DEFINE(BYTE_ORDER, 1234,
        [define to 4321 if host is big endian, 1234 if little endian])
fi
fi

dnl Check for variables & functions

AC_FUNC_ALLOCA

AC_CHECK_FUNCS([strtoull __strtoull])

dnl Find libelf.h
AC_CHECK_HEADER(libelf.h,,
    [AC_CHECK_HEADER(libelf/libelf.h, have_libelf_libelf_h=yes,
        [AC_MSG_ERROR([Required libelf.h header not found (install libelf-dev).])])])
if test "x$have_libelf_libelf_h" = xyes; then
    AC_DEFINE(HAVE_LIBELF_LIBELF_H, 1, [define if you have libelf/libelf.h])
fi

dnl Check for netdev support
if test "$HOST_OS" = linux; then
AC_ARG_ENABLE(netdev,
    AS_HELP_STRING([--disable-netdev], [disable netdev support]))
if test "x$enable_netdev" != xno; then
    AC_DEFINE(SKINET_ENABLE, 1, [define if you want netdev support])
    with_netdev=yes
fi
fi

AM_CONDITIONAL(WITH_NETDEV, test "x$with_netdev" = xyes)

if test "$HOST_OS" = freebsd; then
	LDFLAGS="$LDFLAGS -lutil"
fi

dnl Check for optional libs
AC_CHECK_LIB(unwind-ia64, _Uia64_get_proc_name, )

# Test for IA-64 libbfd

AC_ARG_WITH(bfd-includes,
AS_HELP_STRING([--with-bfd-includes],[specify location of bfd headers]),[
    BFD_CFLAGS="-I$withval"
])

AC_ARG_WITH(bfd-libs,
AS_HELP_STRING([--with-bfd-libs],[specify location of bfd libraries]),[
    BFD_LDFLAGS="-L$withval"
])

AC_MSG_CHECKING([for bfd support])
AC_ARG_WITH(bfd, AS_HELP_STRING([--with-bfd],[use the bfd library]))

if test "x$with_bfd" = xno; then
    have_bfd=disabled
else
    save_CFLAGS=$CFLAGS
    save_LDFLAGS=$LDFLAGS
    save_LIBS=$LIBS
    CFLAGS="$CFLAGS $BFD_CFLAGS"
    LDFLAGS="$LDFLAGS $BFD_LDFLAGS"
    LIBS="$LIBS -lbfd -liberty"
    AC_RUN_IFELSE([AC_LANG_SOURCE([[
        #include <bfd.h>
        int main() {
            bfd_init ();
            return bfd_set_default_target ("elf64-ia64-little") == 0;
        }]])],
        have_bfd=yes, have_bfd=no, have_bfd=no)
    CFLAGS=$save_CFLAGS
    LDFLAGS=$save_LDFLAGS
    LIBS=$save_LIBS
fi

if test "x$have_bfd" = xyes; then
    DWARF_CFLAGS="$BFD_CFLAGS"
    DWARF_LIBS="$BFD_LDFLAGS -lbfd -liberty"
fi
AC_MSG_RESULT([$have_bfd])

if test "x$have_bfd" = xyes; then
    AC_DEFINE(HAVE_DWARF_SUPPORT, 1, [define if you have dwarf support])
fi


AC_SUBST(DWARF_CFLAGS)
AC_SUBST(DWARF_LIBS)

dnl Check if ski_elf.h is missing
AC_CHECK_HEADER(ski_elf.h,,ske_elf_h_is_missing=yes)
if test "x$ske_elf_h_is_missing" = xyes; then
    AC_CONFIG_LINKS([src/ski_elf.h:src/missing/ski_elf.h])
fi

dnl Check for required libs

AC_CHECK_LIB(m, ldexp, [],
    [AC_MSG_ERROR(Required library libm not found.)])

if test "$HOST_OS" = hpux; then
    # HPUX prefers libHcurses.
    AC_CHECK_LIB(Hcurses, tgetent,[
        AC_DEFINE(__HP_CURSES, 1, [define if you want to use HP curses])
        LIBS="-lHcurses $LIBS"
        check_curses=no], [])
fi    

if test "x$check_curses" != xno; then
AC_CHECK_LIB(curses, tgetent, [],
    [AC_CHECK_LIB(ncurses, tgetent, ,
            [AC_MSG_ERROR(Required curses library not found.)])])
fi

AC_CHECK_LIB(elf, elf_begin, [],
    [AC_MSG_ERROR([Required library libelf not found (install libelf-dev).])])

dnl Add extra flags to CFLAGS depending on os
case $host_os in
    linux*)	CPPFLAGS="$CPPFLAGS -DLINUX -D_GNU_SOURCE";;
    hpux9*)	CPPFLAGS="$CPPFLAGS -DHPUX9";;
    hpux10*)	CPPFLAGS="$CPPFLAGS -DHPUX1020";;
    hpux11*)	CPPFLAGS="$CPPFLAGS -DHPUX1100";;
    freebsd*)	CPPFLAGS="$CPPFLAGS -DFREEBSD -D__linux__";;
esac

dnl Add extra flags to CFLAGS depending on compiler
echo "$CFLAGS" | grep "\-g" > /dev/null && cc_dash_g=yes
if test "x$HPCC" = xyes; then
    # if -g is specified add +ESdbgasm for _asm inlined assembly
    test "x$cc_dash_g" = xyes && CFLAGS="$CFLAGS +ESdbgasm"
    # Add architecture flags
    case $host_cpu in
        hppa2.0*) CFLAGS="$CFLAGS +DA20 +DS20"; 
                  LDFLAGS="-Wl,+vnocompatwarnings";;
        hppa1.1*) CFLAGS="$CFLAGS +DA11 +DS11";;
    esac
elif test "x$GCC" = xyes; then
    CPPFLAGS="$CPPFLAGS -D__norcsid"
    CFLAGS="$CFLAGS -fno-strict-aliasing"
fi

AC_ARG_ENABLE(compile-warnings,
    AS_HELP_STRING([--enable-compile-warnings=@<:@no/minimum/yes@:>@],
        [Turn on compiler warnings.]),,enable_compile_warnings=minimum)

dnl Add warnings flags on Compiler kind
if test "x$enable_compile_warnings" != xno; then
    if test "x$GCC" = xyes; then
        # CC is GNU cc
        CFLAGS="$CFLAGS -Wall -Wunused"
        if test "x$enable_compile_warnings" = xnot_ready_for_yes; then
            CFLAGS="$CFLAGS -Wmissing-prototypes -Wmissing-declarations"
        fi
    elif test "x$ICC" = xyes; then
        # CC is Intel icc 
       CFLAGS="$CFLAGS -w1"
    elif test "x$HPCC" = xyes; then
        # CC is HP ansic
        CFLAGS="$CFLAGS +w3"
    fi
fi

encdir='$(top_srcdir)'/src/encodings
AC_SUBST(encdir)

dnl Links
#AC_CONFIG_LINKS([src/syscall-hpux.c:src/syscall.c])
#AC_CONFIG_LINKS([src/dwarf-hpux.c:src/dwarf.c])

dnl Configuration files
AC_CONFIG_FILES([ski.spec])
AC_CONFIG_FILES([ski-config], [chmod +x ski-config])
AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([macros/Makefile])
AC_CONFIG_FILES([src/Makefile src/decoder/Makefile src/encoder/Makefile])
AC_CONFIG_FILES([src/fake-xterm/Makefile])
AC_CONFIG_FILES([doc/Makefile])

dnl Output the files
AC_OUTPUT
