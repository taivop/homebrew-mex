class MexPackSpeech < Formula
  desc "Local Apple Speech and Argmax OSS transcription capability for mex"
  homepage "https://github.com/taivop/homebrew-mex"

  # Prebuilt, so installing needs no Swift toolchain. The archive also contains
  # every model asset Argmax would otherwise download on first use.
  url "https://github.com/taivop/homebrew-mex/releases/download/v0.2.1/mex-pack-speech-0.2.1-darwin-arm64.tar.gz"
  sha256 "4b0ce7db37cf1bf441c1406bcf119b0c903a4c121c449231082f5dacf6818559"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "taivop/mex/mex"
  depends_on "whisperkit-cli"

  def install
    prefix.install "LICENSE"
    bin.install "bin/mex-pack-speech"
    share.install "share/mex-pack-speech"
  end

  def caveats
    <<~EOS
      This pack includes Apple Speech plus the pinned local Argmax recognition,
      tokenizer, and diarization models. Confirm both engines after installation:

        mex pack doctor
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mex-pack-speech --version")
    assert_match "arm64", shell_output("lipo -archs #{bin}/mex-pack-speech")
    system "codesign", "--verify", "--strict", bin/"mex-pack-speech"

    mex = Formula["taivop/mex/mex"].bin/"mex"
    assert_match "speech", shell_output("#{mex} pack list --json")
    system mex, "pack", "doctor"
  end
end
