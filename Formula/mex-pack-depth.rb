class MexPackDepth < Formula
  desc "Temporally consistent Video Depth Anything capability for mex"
  homepage "https://github.com/taivop/homebrew-mex"

  # The archive contains the checksum-verified model, vendored model code, and
  # pinned Python wheels. Inference is offline after installation.
  url "https://github.com/taivop/homebrew-mex/releases/download/v0.4.0/mex-pack-depth-0.4.0-darwin-arm64.tar.gz"
  sha256 "6a09733f1837979949a3d24adde1b2b571d4e3f2c7c2605bb1b18eedb3cbf1a6"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "python@3.14"
  depends_on "taivop/mex/mex"

  def install
    prefix.install "LICENSE"
    bin.install "bin/mex-pack-depth"
    share.install "share/mex-pack-depth"
    inreplace bin/"mex-pack-depth", "@PYTHON@", Formula["python@3.14"].opt_bin/"python3.14"
  end

  def caveats
    <<~EOS
      This is a large optional pack: it includes Video Depth Anything Small,
      PyTorch, and their pinned runtime dependencies. Confirm Metal and model
      availability after installation:

        mex pack doctor

      Balanced quality supports Macs with at least 8 GiB. Accurate quality is
      intended for Macs with at least 16 GiB.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mex-pack-depth --version")
    capabilities = shell_output("#{bin}/mex-pack-depth capabilities --json")
    assert_match "monocular-depth", capabilities
    assert_match "accurate", capabilities

    mex = Formula["taivop/mex/mex"].bin/"mex"
    assert_match "monocular-depth", shell_output("#{mex} pack list --json")
    system mex, "pack", "doctor"
  end
end
