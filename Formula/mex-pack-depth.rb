class MexPackDepth < Formula
  desc "Temporally consistent Video Depth Anything capability for mex"
  homepage "https://github.com/taivop/homebrew-mex"

  # The archive contains the checksum-verified model, vendored model code, and
  # pinned Python wheels. Inference is offline after installation.
  url "https://github.com/taivop/homebrew-mex/releases/download/v0.3.0/mex-pack-depth-0.3.0-darwin-arm64.tar.gz"
  sha256 "1af6ca1897b6d4ed147d8c0c6eee8d4d32815820cfe8145ec57500391ae2cbbf"

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
