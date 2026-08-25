class MexPackSpeech < Formula
  desc "Local Apple Speech and Argmax OSS transcription capability for mex"
  homepage "https://github.com/taivop/homebrew-mex"

  # Prebuilt, so installing needs no Swift toolchain. The archive also contains
  # every model asset Argmax would otherwise download on first use.
  url "https://github.com/taivop/homebrew-mex/releases/download/v0.1.9/mex-pack-speech-0.1.9-darwin-arm64.tar.gz"
  sha256 "e811b12b276a5f341043324ba2a1293ac305abda027990fddf8bbd1b2255e2f9"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "taivop/mex/mex"
  depends_on "whisperkit-cli"

  def install
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
