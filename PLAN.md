# Ski modernization plan — Phase 1: make it build and run

Goal: get ski 1.3.2 (2008, last SourceForge release) to build cleanly with a
current Linux toolchain and run IA-64 Linux user-mode binaries, while keeping
the changes small and easy to review.

## 1. What's in the tree

| Area | Contents |
|---|---|
| Build | autoconf/automake/libtool (`configure.ac`, `Makefile.am`, `macros/*.m4`, `autogen.sh` → `macros/autogen.sh`). Written for autoconf 2.61 / automake 1.9–1.10 / libtool 1.x. |
| Code generation | `src/encodings/encoding.*` are the ISA tables. awk/sed scripts (`*.awk`, `*.sed`, `make_asm`) generate the decoder, encoder, predecode, combined exec functions (`combfns.c`), the disassembler and the `asm_hash.c` assembler hash (via **gperf**). `eparse.y`/`escan.l` need **yacc/lex**. |
| Core | `sim.c`, `state.c`, `simmem.c`, `tlb.c`, `interruption.c`, `float.c`, `*_exec.c`, and others, built into `libski.la`. `main.c` is the only file in the `ski` binary. |
| OS layer | `src/linux/` (syscall emulation, ELF loader, dwarf), plus `hpux/` and `freebsd/` variants that configure picks between. |
| UIs | `bski` (batch), `ski` (curses), `xski` (Motif, `--with-x11`, bit-rotted), `gski` (GTK2/libglade, `--with-gtk`). The UI is chosen by the first letter of `argv[0]`. |
| Console | User-mode stdout goes to a separate **xterm** spawned on a pty (`linux/syscall-linux.c:~1218–1330`), or to `ski-fake-xterm`. `-noconsole` or `bskinc` writes to stdout instead. |
| Tests | `testsuite/` has QMTest `.qmt` files (QMTest is dead) and a prebuilt static **IA-64 `hello`** binary, which is our smoke test. |
| Docs | `doc/ski.1` (man page), `doc/manual/*.odt` with a prebuilt PDF, `ski-notes.html`. Nothing in the docs is built from source. |

## 2. Findings from a trial build

I ran a throwaway build in a scratch copy (not this repo) on Ubuntu 24.04,
x86_64: gcc 13.3, autoconf 2.71, automake 1.16.5. The missing dev packages
were unpacked locally.

### 2.1 Host dependencies (not installed on this machine)

* `libtool-bin`: `autogen.sh` checks for the `libtool` binary and aborts without it.
* `libelf-dev`: configure fails with "Required libelf.h header not found".
* `gperf`, `bison` (or byacc), `flex`.
* Already present: `libncurses-dev`, gawk, pkg-config.
* Optional: `binutils-dev` (`--with-bfd`) for DWARF support. Not needed for Phase 1.

Install command:
`sudo apt install build-essential autoconf automake libtool libtool-bin libelf-dev gperf bison flex libncurses-dev`

### 2.2 Autotools

* `./autogen.sh` refuses to run without `libtool`. `autoreconf -fi -I macros`
  works with modern autotools, but prints many obsolescence warnings:
  `AM_INIT_AUTOMAKE(pkg,ver)`, `AM_CONFIG_HEADER`, `AM_PROG_CC_STDC`,
  `AM_DISABLE_SHARED`, `AC_LIBTOOL_DLOPEN`, `AM_PROG_LIBTOOL`,
  `AC_HELP_STRING`, `AC_TRY_*`, and `AC_PROG_LEX` without `noyywrap`.
* `macros/autogen.sh` has Debian-specific `aclocal-X.Y` logic and old
  libltdl-subdir handling.
* `AC_LIB_LTDL` (from `macros/ltdl.m4`) makes libtoolize copy a full
  `libltdl/` tree, but the code uses its own bundled `src/ltdl.c`.
* `AC_PROG_CC( icc ecc gcc3 cc gcc )` prefers ancient compiler names.

### 2.3 Compile and link errors (gcc 13, default flags)

All four are glibc or kernel-header removals or GCC default changes:

| # | Location | Error | Fix |
|---|---|---|---|
| 1 | `src/dos.c:53` | `ustat.h: No such file` (removed in glibc 2.28) | Drop the include. The file does not use it. |
| 2 | `src/linux/syscall-linux.c:75` | `asm/page.h: No such file` (no longer exported to userspace) | Drop the include, and use `getpagesize()` or a local define if `PAGE_*` is needed. |
| 3 | `src/linux/syscall-linux.c:2255-6` | `TIOCGHAYESESP`/`TIOCSHAYESESP` undeclared (removed from the kernel UAPI) | Wrap them in `#ifdef`. |
| 4 | `src/linux/syscall-linux.c:2679` | undefined reference to `uselib` (glibc removed the wrapper) | Return `-ENOSYS`, or call `syscall(SYS_uselib, …)` under `#ifdef SYS_uselib`. |
| 5 | link | `multiple definition of 'autoAlloc'` (GCC 10+ defaults to `-fno-common`) | Only one real collision: `platform.c:32` and `simmem.c:114`. Make one of them `extern`. Do **not** add `-fcommon`. |

With these fixed, the build completes and produces `ski`, `bski` and `libski`.

### 2.4 Runtime smoke test, after the fixes

* `bski -noconsole testsuite/hello` prints `hello, world` and exits 0
  (15,950 instructions).
* `bski testsuite/hello`, without `-noconsole`, prints **nothing** and exits 0.
  Output goes to an xterm that cannot be spawned, and nothing reports the
  failure. This is a usability bug that will look like "it's broken".
* The curses `ski` UI starts and draws its register and program windows
  under a pty.
* `-strace` still shows the known `unimplemented system call 1236`
  (`exit_group`), which is listed in `BUGS`.

### 2.5 Forward-compatibility checks

* **GCC 14 defaults** (`-Werror=implicit-function-declaration, implicit-int,
  int-conversion, incompatible-pointer-types`): builds clean.
* **GCC 15 / C23** (`-std=gnu2x`): 10 errors where calls go through
  function-pointer fields declared with `()` and no parameters.
  `ssDDM.c` calls `sym.getFn`/`sym.setFn`, and `escan.l` calls
  `psym->getFn`. The fix is to give these fields real prototypes, probably
  in `libsym.h` or `ssDCmd.h`.
* **Warnings**: about 20.5k, mostly `-Wunused-but-set-variable` in generated
  code. These are worth fixing because they may be real bugs:
  * `float.c`/`float.h` define their own `round`, `fma`, `fmax` and `fmin`,
    which conflict with C99 builtins. GCC may apply builtin semantics to
    them, so they should be renamed (e.g. `ski_fma`).
  * `ui.c:812`: `%llx` is given an `unsigned int`, which reads garbage from
    the varargs.
  * `cur.c:361,522`: `%*s` is given a `size_t` width.
  * `ssDSym.c:94`, `ui.c:1409`, `ia_das.c:225`: possible sprintf overflows.
  * `ssDCmd.c:515`: overlapping `strcpy`/`sprintf` arguments (`-Wrestrict`).
  * `ltdl.c`: `-Waddress` warnings in the bundled 2007 libltdl.

## 3. Plan

Each step is a separate, reviewable commit. "Done" means the build works
from a clean checkout.

### Step 0: Baseline and hygiene
- Add a `.gitignore` for autotools output (`configure`, `Makefile.in`,
  `config.*`, `aclocal.m4`, `autom4te.cache/`, `libltdl/`, `*.lo`, `.libs/`,
  generated sources, and `src/ski_elf.h`).
- Write down the required packages (§2.1) in `README`/`INSTALL` and update
  the stale version text ("1.1.1").

### Step 1: Make the autotools bootstrap work on modern systems
- Replace `autogen.sh` with a plain `autoreconf -fiv` wrapper. Drop the
  Debian `aclocal-X.Y` hack and the libltdl-subdir code.
- Modernize `configure.ac` with minimal edits:
  `AC_INIT([ski],[1.3.2])` + `AC_CONFIG_SRCDIR`, `AM_INIT_AUTOMAKE([foreign subdir-objects])`,
  `AC_CONFIG_HEADERS`, `LT_INIT([dlopen disable-shared])`,
  `AC_CONFIG_MACRO_DIRS([macros])`, `AS_HELP_STRING`, `AC_COMPILE_IFELSE`/`AC_RUN_IFELSE`,
  `AC_PROG_LEX([noyywrap])` (or `%option noyywrap` in `escan.l`), `AC_PROG_CC`
  without the compiler list. Remove `AM_PROG_CC_STDC`.
- Remove `AC_LIB_LTDL` / `macros/ltdl.m4`, which stops libtoolize from
  copying a `libltdl/` tree. Keep the bundled `src/ltdl.c` for now. Plain
  `dlopen` could replace it later (see §4).
- Make missing `gperf` or libelf fail at configure time with a clear
  message.
- Done when `autoreconf -fi && ./configure` runs with no errors and no
  `obsolete` warnings from `configure.ac`.

### Step 2: Fix the compile and link errors (§2.3, items 1–5)
- Keep the edits minimal and guard them with `#ifdef` where a symbol
  may or may not exist.
- Done when `make` succeeds with gcc 13 and default flags (no `-fcommon`),
  and `ski`, `bski` and `ski-fake-xterm` are produced.

### Step 3: Make it run usefully out of the box
- Console: when xterm is unavailable (exec fails) or `DISPLAY` is unset,
  fall back to stdout (the `noConsole` path) with a warning instead of
  failing silently.
- Optionally implement or ignore `exit_group` (syscall 1236) so the `BUGS`
  entry stops appearing.
- Done when `bski testsuite/hello` prints `hello, world` with no extra flags.

### Step 4: Restore a minimal automated test
- Replace the QMTest files with a small `make check` (automake `TESTS`)
  script. It runs `bski -forceuser -noconsole testsuite/hello` and checks
  for `hello, world` and exit status 0, and checks that `bski -help` exits
  as expected. These correspond to the existing `hello.qmt` and
  `bski-help.qmt`.
- Hook up `testsuite/` in `SUBDIRS` or call it from `src/Makefile.am`.

### Step 5: Forward compatibility and warning cleanup
- Add real prototypes to the `getFn`/`setFn` function-pointer fields, so
  the build passes with `-std=gnu23` (GCC 15 default).
- Rename `float.c`'s `round`/`fma`/`fmax`/`fmin`, and fix the
  format-string, overflow and `-Wrestrict` warnings listed in §2.5.
- Check with clang 18 as well.
- Silence the warnings that come from generated code (unused-but-set),
  either by fixing the awk generators or with per-target flags, so that
  real warnings stand out.
- Done when the build is clean under gcc 13 and clang 18 with
  `-std=gnu2x`, and `make check` passes.

### Step 6 (optional): CI
- Add a GitHub Actions workflow on ubuntu-latest that installs §2.1, then
  runs `autoreconf -fi && ./configure && make && make check`. This keeps
  the build from rotting again.

## 4. Out of scope for Phase 1 (candidates for later)

- xski (Motif) and gski (GTK2 + libglade are both deprecated). Leave them
  disabled. A port to GTK3/4 or a removal is a separate decision.
- The HP-UX and FreeBSD ports. Keep the code, but don't spend effort on it.
- Replacing the bundled `ltdl.c` (2007) with `dlopen`/system libltdl.
- `--with-bfd` / DWARF support, whose libbfd API has changed a lot.
- Updating the syscall emulation for newer IA-64 glibc binaries (new
  syscalls such as `openat`, `exit_group`, `set_tid_address`), and running
  a kernel in system mode.
- Build-system replacement (CMake/Meson). Not needed, since autotools works
  after Step 1.
- Big-endian and non-x86_64 hosts (e.g. aarch64). These are worth a
  build-and-run check once Steps 1–5 are done.

## 5. Risks and open questions

- **64-bit host correctness.** "hello" runs, but larger binaries may expose
  `long`/pointer-size assumptions from the HP-UX/IA-32 era. Step 4's test
  should grow as IA-64 test binaries become available. Building new ones
  needs an ia64 cross-toolchain, which is no longer in mainstream distros.
- **Generated code.** Many warnings come from the awk generators. Fixing
  them at the generator is cleaner than patching the output.
- **Test binaries.** The only test program is the one prebuilt static
  `hello`. More IA-64 binaries are needed (e.g. from an old Debian ia64
  archive or a crosstool build) to cover more than the basics.
