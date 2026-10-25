# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project overview

Ski is an IA-64 (Itanium) instruction set simulator, imported from the last
SourceForge release (1.3.2, 2008). It runs IA-64 Linux user-mode programs
and can boot IA-64 kernels in system mode.

The current effort is to keep it building and running on modern Linux
toolchains. See `PLAN.md` for the plan, what has been done, and what is out
of scope.

## Repository layout

| Path | Contents |
|---|---|
| `configure.ac`, `Makefile.am`, `macros/` | autoconf / automake / libtool build |
| `src/` | Simulator core (`libski.la`) and the `ski` / `bski` front ends |
| `src/encodings/` | ISA tables that drive the code generators |
| `src/*.awk`, `src/*.sed`, `src/decoder/`, `src/encoder/` | Generators for the decoder, encoder, disassembler, `combfns.c`, `asm_hash.c` |
| `src/linux/` | Linux syscall emulation and ELF loader (`hpux/`, `freebsd/` are unmaintained) |
| `src/fake-xterm/` | `ski-fake-xterm` console helper |
| `testsuite/` | `make check` shell tests and the prebuilt IA-64 `hello` binary |
| `doc/` | Man page and manual (not built from source) |

## Setup

Required packages (Debian/Ubuntu):

```sh
sudo apt-get install build-essential autoconf automake libtool libtool-bin \
  libelf-dev gperf bison flex libncurses-dev gawk pkg-config
```

## Build and test

```sh
autoreconf -fi
./configure
make -j"$(nproc)"
make check            # runs testsuite/*.sh
make distcheck        # before changing build files or EXTRA_DIST
```

Quick smoke test:

```sh
src/bski -forceuser -noconsole testsuite/hello   # prints "hello, world"
```

CI (`.github/workflows/ci.yml`) builds and tests with gcc (default std),
gcc `-std=gnu2x` and clang `-std=gnu2x`, plus `make distcheck`. Before
proposing a change, make sure it passes at least:

```sh
CC=gcc   CFLAGS="-O2 -g -std=gnu2x" ./configure && make && make check
CC=clang CFLAGS="-O2 -g -std=gnu2x" ./configure && make && make check
```

## Coding conventions

- C, in the style of the surrounding file (K&R-ish, tabs). Do not reformat
  code you are not changing.
- Keep changes small and reviewable; guard platform-dependent symbols with
  `#ifdef` instead of removing functionality.
- Do not add `-fcommon` or similar flags to hide real problems.
- Generated files (`combfns.c`, `asm_hash.c`, `das_instr.c`, ... — see
  `.gitignore`) are never edited directly. Fix the generator (`*.awk`,
  `*.sed`, `src/encodings/*`) instead.
- Do not introduce new compiler warnings with gcc or clang.
- <!-- TODO: any naming / header / license-banner rules -->

## Tests

- Tests are POSIX `sh` scripts in `testsuite/` that source `defs.sh` and
  use its helpers (`run`, `expect_status`, `expect_line`, `expect_text`,
  `expect_empty`, `pass`).
- A new test must be added to `TESTS` in `testsuite/Makefile.am`, and any
  data files it needs to `EXTRA_DIST`.
- Bug fixes should come with a test when one can be written with the
  existing IA-64 binaries.
- Building new IA-64 test binaries needs an ia64 cross-toolchain.
  <!-- TODO: document how to obtain one, if available -->

## Commits and pull requests

- One logical change per commit. Subject line in the imperative mood,
  no prefix (e.g. "Fix build failures with current glibc").
- The body explains *why*, and names the compiler warning or test that
  exposed the problem when relevant.
- Update `PLAN.md` when a step's status changes.
- <!-- TODO: branch naming, review requirements, ChangeLog/NEWS policy -->

## Out of scope unless asked

- xski (Motif) and gski (GTK2) front ends
- HP-UX and FreeBSD ports
- `--with-bfd` / DWARF support
- Replacing autotools with another build system

## Gotchas

- The UI is selected by the first letter of `argv[0]` (`bski`, `ski`, ...).
- Without `-noconsole`, user-mode output goes to a separate xterm; it falls
  back to stdout when no xterm can be opened.
- `testsuite/testhook.so` is built as a shared object even though libtool
  is configured with shared libraries disabled, because ski `dlopen`s it.
