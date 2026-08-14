class MexPackVision < Formula
  desc "Person-segmentation capability pack for mex, over Apple's Vision framework"
  homepage "https://github.com/taivop/mex/tree/main/packs/vision"

  # Prebuilt, so installing needs no Swift toolchain. See Formula/mex.rb for why
  # the artifacts come from a git repository rather than release assets.
  url "git@github.com:taivop/mex-dist.git",
      using:    :git,
      tag:      "v0.1.1",
      revision: "7b65308ac9d1bb233b49c6ee011689009165c63c"
  version "0.1.1"

  depends_on arch: :arm64
  # macOS 15 is the floor for the Vision APIs this pack uses, and it is compiled
  # with that deployment target. On anything older dyld refuses to load it, so
  # the requirement is declared rather than discovered at run time.
  depends_on macos: :sequoia

  # A pack is useless on its own: it speaks a protocol mex drives, and nothing
  # else runs it. Depending on mex means `brew install mex-pack-vision` produces
  # a working capability rather than an orphaned executable.
  depends_on "taivop/mex/mex"

  def install
    # The filename is the interface. mex discovers a pack by looking for an
    # executable named mex-pack-NAME on PATH or under MEX_PACK_PATH, so renaming
    # this on install would make it invisible rather than broken — which is a
    # far worse failure, because `mex pack list` would simply report nothing.
    bin.install "darwin-arm64/mex-pack-vision"
  end

  def caveats
    <<~EOS
      The pack is on PATH, so mex finds it with no configuration. Confirm it:

        mex pack doctor

      It reports what this machine can actually do — Neural Engine, GPU and
      hardware encoder — rather than only that the file exists.
    EOS
  end

  test do
    assert_match "arm64", shell_output("lipo -archs #{bin}/mex-pack-vision")

    # macOS refuses to execute an unsigned binary on Apple Silicon, and refuses
    # by SIGKILL on exec: no output, no useful exit status, indistinguishable
    # from the pack not being installed. docs/failure-modes.md in the mex
    # repository records that failure under pack_unusable. Asserting the
    # signature here turns it into an install-time error with a name.
    system "codesign", "--verify", "--strict", bin/"mex-pack-vision"

    # Exercised through mex rather than directly, because discovery, the
    # handshake and the health report are what a user is actually installing.
    # A pack that exists but does not answer is the failure worth catching.
    listing = shell_output("#{Formula["taivop/mex/mex"].bin}/mex pack list --json")
    assert_match "vision", listing
    system Formula["taivop/mex/mex"].bin/"mex", "pack", "doctor"
  end
end
