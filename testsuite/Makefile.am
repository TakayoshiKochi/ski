## Process this file with automake to produce Makefile.in

TESTS = \
	hello.sh \
	hello-stats.sh \
	console-fallback.sh \
	conslog.sh \
	hook.sh \
	bski-help.sh \
	bski-badopt.sh \
	ski-help.sh \
	ski-badopt.sh

AM_TESTS_ENVIRONMENT = \
	srcdir='$(srcdir)'; export srcdir; \
	BSKI='$(abs_top_builddir)/src/bski'; export BSKI; \
	SKI='$(abs_top_builddir)/src/ski'; export SKI; \
	HELLO='$(abs_srcdir)/hello'; export HELLO; \
	FAKE_XTERM_DIR='$(abs_top_builddir)/src/fake-xterm'; export FAKE_XTERM_DIR; \
	TESTHOOK='$(abs_builddir)/testhook.so'; export TESTHOOK;

# The hook is dlopen()ed by ski, so it must be a shared object even
# though libtool is configured with shared libraries disabled.
check_DATA = testhook.so
testhook.so: testhook.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -shared $(LDFLAGS) \
		-o $@ $(srcdir)/testhook.c

EXTRA_DIST = $(TESTS) defs.sh testhook.c hello hello.c

CLEANFILES = testhook.so
clean-local:
	-rm -rf *.dir
