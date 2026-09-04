class Mex < Formula
  desc "Composable media primitives for coding agents"
  homepage "https://github.com/taivop/homebrew-mex"

  # A prebuilt binary: installing needs no Go toolchain, and no GitHub account.
  # The url and sha256 are rewritten by scripts/release.sh in the mex
  # repository, which is what keeps a published checksum from ever describing a
  # different tarball than the URL beside it.
  url "https://github.com/taivop/homebrew-mex/releases/download/v0.4.0/mex-0.4.0-darwin-arm64.tar.gz"
  sha256 "bca54387cdc1ca988ad335c2e63612f7dd973d233679e0e80d6e5fc351ec3241"
  # Custom MEX license; see the LICENSE file in this tap and release archive.

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
    prefix.install "LICENSE"
    bin.install "mex"
  end

  def caveats
    <<~EOS
      Finish the installation with:

        mex setup

      That installs version-matched documentation, reports what this machine can
      do, and offers one optional mex skill for Claude Code and Codex. It never
      installs a new skill without confirmation. Re-run setup after every
      upgrade to refresh documentation and any mex-managed personal skill.

      Person segmentation and tracking are built into mex on supported Macs.

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

    # The one optional skill has to be inside the binary, and listing it must
    # remain read-only.
    listing = shell_output("#{bin}/mex skills list")
    assert_match(/^mex\s+mex\s+Use mex /, listing)
    refute_path_exists testpath/".agents", "skills list must not write anything"

    system bin/"mex", "skills", "install", "mex",
           "--agent", "codex", "--scope", "project", "--root", testpath
    assert_path_exists testpath/".agents/skills/mex/SKILL.md"

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
