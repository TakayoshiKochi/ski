/* Test hook library for hook.sh, loaded through SKIHOOK_PATH. */
#include <stdio.h>

static unsigned long calls;

void ski_hook_init(void)
{
    fprintf(stderr, "testhook: init\n");
}

void ski_hook(void)
{
    calls++;
}

void ski_hook_fini(void)
{
    fprintf(stderr, "testhook: fini, %lu calls\n", calls);
}
