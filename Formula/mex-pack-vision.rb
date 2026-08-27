class MexPackVision < Formula
  desc "Person-segmentation capability pack for mex, over Apple's Vision framework"
  homepage "https://github.com/taivop/homebrew-mex"

  # Prebuilt, so installing needs no Swift toolchain. See Formula/mex.rb.
  url "https://github.com/taivop/homebrew-mex/releases/download/v0.2.0/mex-pack-vision-0.2.0-darwin-arm64.tar.gz"
  sha256 "422b348d7286424b251213fc4f88b2c7513be26c64b1203cb71412723bb4f899"

  depends_on arch: :arm64
  # macOS 15 is the floor for the Vision APIs this pack uses, and it is compiled
  # with that deployment target. On anything older dyld refuses to load it, so
  # the requirement is declared rather than discovered at run time.
  depends_on macos: :sequoia

  # A pack is useless on its own: it speaks a protocol mex drives, and nothing
  # else runs it. Depending on mex means installing this produces a working
  # capability rather than an orphaned executable.
  depends_on "taivop/mex/mex"

  def install
    # The filename is the interface. mex discovers a pack by looking for an
    # executable named mex-pack-NAME on PATH or under MEX_PACK_PATH, so renaming
    # it here would make it invisible rather than broken — a worse failure,
    # because `mex pack list` would simply report nothing.
    bin.install "mex-pack-vision"
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
    # from the pack not being installed at all. docs/failure-modes.md in the mex
    # repository records that under pack_unusable. Asserting the signature turns
    # it into an install-time error with a name.
    system "codesign", "--verify", "--strict", bin/"mex-pack-vision"

    # Exercised through mex rather than directly, because discovery, the
    # handshake and the health report are what a user is installing. A pack that
    # exists but does not answer is the failure worth catching.
    mex = Formula["taivop/mex/mex"].bin/"mex"
    assert_match "vision", shell_output("#{mex} pack list --json")
    system mex, "pack", "doctor"
  end
end
