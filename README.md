# homebrew-mex

Homebrew tap for [mex](https://github.com/taivop/mex), a toolbox of composable
media primitives for coding agents.

```sh
brew install taivop/mex/mex
mex skills install
mex doctor
```

Both this tap and mex itself are private repositories. Homebrew clones them over
your existing GitHub SSH access, so there is no token to configure — if you can
`git clone git@github.com:taivop/mex.git`, you can install.

## How the formula is put together, and why

**It builds from source.** mex has no dependencies outside the Go standard
library, so this is a few seconds. It also means no release asset to download,
which matters more than the build time: fetching an asset from a private
repository needs a GitHub token in the request, and cloning needs nothing that a
person who can read the repo does not already have. Building locally also skips
codesigning and notarisation entirely — the binary is never downloaded, so
Gatekeeper never quarantines it, and Go's linker writes the ad-hoc signature that
Apple Silicon requires.

**It depends on `ffmpeg-full`, not `ffmpeg`.** homebrew/core's `ffmpeg` formula
has no `libass`, so it cannot render captions, cards or overlays — while
reporting an entirely normal version number. `ffmpeg-full` does depend on libass
and ships as a bottle, so it costs a download rather than the source build the
`homebrew-ffmpeg` tap requires.

`ffmpeg-full` is keg-only: it collides with `ffmpeg`, so Homebrew installs it and
deliberately leaves it off `PATH`. mex searches the keg directories itself, so
nothing here forces a link — forcing one would break the next
`brew install ffmpeg`. `mex doctor` reports which FFmpeg answered and how it was
found.

**No FFmpeg version constraint.** Homebrew formula dependencies cannot express a
version range, and mex does not want one: it judges a build by running the
operations it needs. The effective minimum is FFmpeg 6.0, and that is a
consequence of which options `mex doctor`'s required checks use rather than a
rule anyone wrote down. See the mex README.

## Releasing a new version

1. Tag mex: `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`
2. Update `url`'s `tag:` and `revision:` in `Formula/mex.rb`, and `version`.
3. `brew upgrade mex` — or `brew install --build-from-source mex` to check first.

`revision:` is required alongside `tag:` for a git URL, and pinning it means the
formula installs one exact commit rather than whatever the tag points at today.
