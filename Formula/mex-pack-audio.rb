class MexPackAudio < Formula
  desc "Local MossFormer2-SE enhancement and generative Sidon restoration for mex"
  homepage "https://github.com/taivop/homebrew-mex"

  # Prebuilt with the exact local model weights under share/mex-pack-audio.
  url "https://github.com/taivop/homebrew-mex/releases/download/v0.3.0/mex-pack-audio-0.3.0-darwin-arm64.tar.gz"
  sha256 "67114715438c137c81d43a56afaafc476967c3437d1b4a69eb9e96f58977fe04"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "taivop/mex/mex"

  def install
    prefix.install "LICENSE"
    libexec.install "bin/mex-pack-audio", "bin/mlx.metallib"
    bin.install_symlink libexec/"mex-pack-audio"
    share.install "share/mex-pack-audio"
  end

  def caveats
    <<~EOS
      `mex audio enhance` performs non-vocoder speech enhancement.
      `mex audio studio` is generative: Sidon reconstructs speech through a
      neural vocoder and may change words, identity, prosody, or background.

      Verify the bundled models after installation with `mex pack doctor`.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mex-pack-audio --version")
    assert_match "arm64", shell_output("lipo -archs #{bin}/mex-pack-audio")
    assert_predicate libexec/"mlx.metallib", :exist?
    system "codesign", "--verify", "--strict", bin/"mex-pack-audio"

    mex = Formula["taivop/mex/mex"].bin/"mex"
    assert_match "speech-enhancement", shell_output("#{mex} pack list --json")
    system mex, "pack", "doctor"
  end
end
