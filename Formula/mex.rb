class Mex < Formula
  desc "Composable media primitives for coding agents"
  homepage "https://github.com/taivop/mex"

  # A prebuilt binary: installing needs no Go toolchain, and no GitHub account.
  # The url, version and sha256 are rewritten by scripts/release.sh in the mex
  # repository, which is what keeps a published checksum from ever describing a
  # different tarball than the URL beside it.
  url "https://github.com/taivop/homebrew-mex/releases/download/v0.1.7/mex-0.1.7-darwin-arm64.tar.gz"
  version "0.1.7"
  sha256 "198676c5734989164e4f38cc4d1417140b5411afc400e27ee69cd5b6397a33c5"
  # No license line: one has not been chosen yet (PLAN.md section 13), and a
  # formula asserting one would be a claim the repository does not make.

  # Apple Silicon only, which is what mex targets and what the artifact is built
  # for. Stated rather than discovered, so somebody on an Intel Mac is told why
  # instead of installing something that cannot run.
  depends_on arch: :arm64

  # ffmpeg-full rather than ffmpeg: homebrew/core's ffmpeg formula has no libass,
  # so it cannot render captions, cards or overlays — while reporting an entirely
  # normal version number. ffmpeg-full does depend on libass and ships as a
  # bottle, so it costs a download rather than a source build.
  #
  # It is keg-only and Homebrew will not link it onto PATH. mex searches the keg
  # directories itself, so nothing here forces a link — forcing one would break
  # the next `brew install ffmpeg`.
  depends_on "ffmpeg-full"
  depends_on :macos

  def install
    bin.install "mex"
  end

  def caveats
    <<~EOS
      Finish the installation with:

        mex setup

      That writes the agent instruction files into ~/.claude/skills/ and reports
      what this machine can do. Re-run it after every upgrade: the guidance
      describes a command surface, so a copy from an older mex describes an
      older one.

      For background blur and person masks:

        brew install taivop/mex/mex-pack-vision

      For fully local Apple Speech and Argmax transcription:

        brew install taivop/mex/mex-pack-speech
    EOS
  end

  test do
    # The version must come from the build, not from this formula. An unstamped
    # binary reports 0.0.0-dev and is indistinguishable from somebody's local
    # working copy, which is how a bug report arrives with no way to tell which
    # build produced it.
    assert_match version.to_s, shell_output("#{bin}/mex version")

    # The binary must be for this machine. A wrong-architecture artifact installs
    # perfectly and fails only when something runs it.
    assert_match "arm64", shell_output("lipo -archs #{bin}/mex")

    # The skills have to be inside the binary, or `mex setup` installs nothing
    # and reports success.
    listing = shell_output("#{bin}/mex skills list")
    assert_match "mex-media-production", listing
    refute_path_exists testpath/".agents", "skills list must not write anything"

    system bin/"mex", "skills", "install", "media-production",
           "--agent", "codex", "--scope", "project", "--root", testpath
    assert_path_exists testpath/".agents/skills/mex-media-production/SKILL.md"

    # setup is the command the caveat tells people to run, so it is the one worth
    # proving works. It refreshes managed skills and interrogates FFmpeg — including
    # the keg-only ffmpeg-full this formula depends on, which is deliberately off
    # PATH, so this is also the assertion that mex's own keg search works on a
    # machine nobody configured by hand.
    system bin/"mex", "setup"
    docs = Pathname(shell_output("#{bin}/mex docs path").strip)
    assert_path_exists docs/"INDEX.md"
  end
end
