# mex

Composable media primitives for coding agents — understand, edit, render and
inspect video and audio from the command line.

## Install

```sh
brew tap taivop/mex && brew trust taivop/mex && brew install taivop/mex/mex
```

```sh
mex setup
```

`mex setup` installs the agent instruction files and reports what this machine
can do. Re-run it after every upgrade.

For background blur and person masks, add the capability pack:

```sh
brew install taivop/mex/mex-pack-vision
```

## Requirements and compatibility

A Mac with Apple Silicon, and Homebrew. Everything is a prebuilt binary, so
nothing is compiled and no toolchain is needed. FFmpeg is installed as a
dependency.

The capability pack additionally needs macOS 15 or newer.

MEX supports the current and previous FFmpeg major lines: **9.x and 8.x**. The
exact regression-tested releases are 9.0.1 and 8.1.2. The formula installs the
current `ffmpeg-full`, including libass for captions and cards. FFmpeg 6.x and
7.x may work when `mex doctor` passes, but they are not regression-supported.

## Then what

```sh
mex capabilities        # every command, grouped by the job it does
mex <command> --help    # flags, defaults and what it warns about
```

## Releases and trust

Homebrew verifies each downloaded archive against the SHA-256 hash in its
formula. Releases after v0.1.5 also include a `SHA256SUMS` asset covering every
archive, for manual verification with:

```sh
shasum -a 256 -c SHA256SUMS
```

The binaries are ad-hoc signed, not Developer ID signed or notarised. The
supported Homebrew installation does not set macOS quarantine; direct browser
downloads are not currently supported. Developer ID signing and notarisation
will be added before direct distribution is offered.

MEX is proprietary software: © 2026 Taivo Pungas. All rights reserved.

## Security

Report vulnerabilities privately according to [SECURITY.md](SECURITY.md). Do
not open a public issue for a suspected vulnerability.

---

Releases are cut from a private source repository; the formulas here are updated
by its verified release script.
