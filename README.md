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

## Requirements

A Mac with Apple Silicon, and Homebrew. Everything is a prebuilt binary, so
nothing is compiled and no toolchain is needed. FFmpeg is installed as a
dependency.

The capability pack additionally needs macOS 15 or newer.

## Then what

```sh
mex capabilities        # every command, grouped by the job it does
mex <command> --help    # flags, defaults and what it warns about
```

---

Releases are cut from [taivop/mex](https://github.com/taivop/mex); the formulas
here are updated by its `scripts/release.sh`.
