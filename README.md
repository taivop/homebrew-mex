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

`mex setup` installs version-matched documentation, checks what this machine can
do, and offers one optional mex skill for Claude Code and Codex. It never installs
a new skill without confirmation. Re-run setup after every upgrade to refresh
documentation and any mex-managed personal skill.

Capability packs are optional add-ons to the main `mex` CLI. Each is a separate
Homebrew formula that depends on `mex`, so installing a pack on a clean machine
also installs the core CLI.

For fully local transcription, install the speech pack:

```sh
brew install taivop/mex/mex-pack-speech
mex pack doctor
```

The core CLI contains the transcription workflow, while `mex-pack-speech`
supplies the recognition engines. One pack provides both Apple SpeechAnalyzer
and Argmax OSS; automatic selection chooses between them based on the machine,
language and requested features. It includes the pinned recognition, tokenizer
and speaker-diarization assets, so there is no first-run model download and no
recording or transcript is sent to a recognition service.

For background blur and person masks, install the vision pack:

```sh
brew install taivop/mex/mex-pack-vision
mex pack doctor
```

## Requirements and compatibility

A Mac with Apple Silicon, and Homebrew. Everything is a prebuilt binary, so
nothing is compiled and no toolchain is needed. FFmpeg is installed as a
dependency.

The speech pack supports macOS 14 or newer. Argmax provides transcription on
all supported versions; Apple SpeechAnalyzer is additionally available on
macOS 26 or newer for its supported locales. The vision pack needs macOS 15 or
newer.

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
