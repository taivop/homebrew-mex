class Mex < Formula
  desc "Composable media primitives for coding agents"
  homepage "https://github.com/taivop/mex"

  # A prebuilt binary, so installing needs no Go toolchain.
  #
  # The artifacts live in a separate private repository rather than in GitHub
  # Release assets because Homebrew 6 has no download strategy for private
  # release assets — GitHubPrivateRepositoryReleaseDownloadStrategy and its
  # sibling were removed. What remains would need every user to set
  # HOMEBREW_GITHUB_API_TOKEN, and the formula to carry a numeric asset id that
  # changes every release. A git URL costs neither: Homebrew clones it with the
  # same SSH access that installing this tap already requires.
  #
  # revision: is pinned alongside tag: so a published version cannot change under
  # a machine that already has it.
  url "git@github.com:taivop/mex-dist.git",
      using:    :git,
      tag:      "v0.1.1",
      revision: "7b65308ac9d1bb233b49c6ee011689009165c63c"
  version "0.1.1"
  # No license line: one has not been chosen yet (PLAN.md section 13), and a
  # formula asserting one would be a claim the repository does not make.

  # Apple Silicon only, which is what mex targets and what the artifact is built
  # for. Stated rather than discovered, so somebody on an Intel Mac is told why
  # instead of installing something that cannot run.
  depends_on arch: :arm64
  depends_on :macos

  # ffmpeg-full rather than ffmpeg: homebrew/core's ffmpeg formula has no libass,
  # so it cannot render captions, cards or overlays — while reporting an entirely
  # normal version number. ffmpeg-full does depend on libass and ships as a
  # bottle, so it costs a download rather than a source build.
  #
  # It is keg-only and Homebrew will not link it onto PATH. mex searches the keg
  # directories itself, so nothing here forces a link — forcing one would break
  # the next `brew install ffmpeg`.
  depends_on "ffmpeg-full"

  def install
    bin.install "darwin-arm64/mex"
  end

  def caveats
    <<~EOS
      The agent instruction files ship inside the binary. Install them with:

        mex skills install

      That writes them to ~/.claude/skills/. Re-run with --overwrite after
      upgrading mex, so the guidance never describes an older command surface
      than the CLI beside it.

      Then confirm this machine can do the work:

        mex doctor

      For background blur and person masks, add the capability pack:

        brew install taivop/mex/mex-pack-vision
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

    # The embedded skills have to be there, or `mex skills install` installs
    # nothing and reports success.
    listing = shell_output("#{bin}/mex skills install --list --target #{testpath}/skills")
    assert_match "mex-media-production", listing
    refute_predicate testpath/"skills", :exist?, "--list must not write anything"

    system bin/"mex", "skills", "install", "--target", testpath/"skills"
    assert_predicate testpath/"skills/mex-media-production/SKILL.md", :exist?

    # doctor reaches the FFmpeg this formula depends on. That dependency is
    # keg-only and deliberately off PATH, so this is the assertion that mex's own
    # keg search works on a machine nobody configured by hand.
    system bin/"mex", "doctor"
  end
end
