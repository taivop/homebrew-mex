class Mex < Formula
  desc "Composable media primitives for coding agents"
  homepage "https://github.com/taivop/mex"
  # Cloned over the user's existing GitHub SSH access, which is what makes a
  # private repository installable with no token plumbing. A release asset would
  # need HOMEBREW_GITHUB_API_TOKEN and a homebrew_curl download strategy; the git
  # URL needs nothing that a person who can read the repo does not already have.
  url "git@github.com:taivop/mex.git", using: :git, tag: "v0.1.0", revision: "f73c1bb4cccf3dbb93769aef45861a0dca92d8ef"
  version "0.1.0"
  # No license line: one has not been chosen yet (PLAN.md section 13), and a
  # formula asserting one would be a claim the repository does not make.
  head "git@github.com:taivop/mex.git", using: :git, branch: "main"

  depends_on "go" => :build

  # ffmpeg-full rather than ffmpeg: core's ffmpeg formula has no libass, so
  # captions, cards and overlays cannot be rendered against it, and the version
  # string gives no hint of that. ffmpeg-full is bottled, so this costs a download
  # rather than a source build.
  #
  # It is keg-only and Homebrew will not link it onto PATH. mex searches the keg
  # directories itself, so nothing here needs to force a link — forcing one would
  # break the next `brew install ffmpeg`.
  depends_on "ffmpeg-full"

  def install
    # The commit and build date are not passed: Homebrew clones with git, so the Go
    # toolchain stamps vcs.revision and vcs.time into the binary by itself and
    # buildinfo reads them. Only the version needs injecting, because a tag is not
    # something the toolchain can infer.
    ldflags = %W[
      -s -w
      -X github.com/taivop/mex/internal/buildinfo.version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/mex"
  end

  def caveats
    <<~EOS
      The agent instruction files ship inside the binary. Install them with:

        mex skills install

      That writes them to ~/.claude/skills/. Re-run with --overwrite after
      upgrading mex, so the guidance never describes an older command surface than
      the CLI beside it.

      Then confirm this machine can do the work:

        mex doctor
    EOS
  end

  test do
    # The version has to come from the build, not from the formula: an unstamped
    # binary reports 0.0.0-dev and is indistinguishable from a local build.
    assert_match version.to_s, shell_output("#{bin}/mex version")

    # The embedded skills have to be there, or `mex skills install` installs
    # nothing and says it succeeded.
    listing = shell_output("#{bin}/mex skills install --list --target #{testpath}/skills")
    assert_match "mex-media-production", listing
    refute_predicate testpath/"skills", :exist?, "--list must not write anything"

    # And the install must actually produce the file an agent loads.
    system bin/"mex", "skills", "install", "--target", testpath/"skills"
    assert_predicate testpath/"skills/mex-media-production/SKILL.md", :exist?

    # doctor reaches the FFmpeg this formula depends on. It exits non-zero when a
    # required capability is missing, which is a real result worth asserting: the
    # dependency is only useful if mex can find it.
    system bin/"mex", "doctor"
  end
end
