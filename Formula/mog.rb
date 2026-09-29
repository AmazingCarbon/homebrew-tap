class Mog < Formula
  desc "Locks your Mac when someone else looks at it"
  homepage "https://github.com/c4rb0nx1/mog"
  url "https://github.com/c4rb0nx1/mog/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "e24813312f0d7c7f351561f8136b863f8ef34b40dede04ab6268a8857b33bc9a"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  # ArcFace face-recognition model (Apache-2.0), Core ML conversion. Pinned to a commit and checksum.
  resource "face-model" do
    url "https://huggingface.co/RuiSumida/ArcFace-R100-CoreML/resolve/b51b655da6b4acc72bfdbfdcd316b3cf4f698e4e/FaceEmbedding.mlpackage.tar.gz"
    sha256 "3644ff110ba03a082515d3a9fa22dbc8c1eb66054bb6bbbc0e84eb62b4771f2b"
  end

  def install
    system "swift", "build", *std_swift_args, "-c", "release", "--product", "mog"
    system "swift", "build", *std_swift_args, "-c", "release", "--product", "MogBar"
    bin.install ".build/release/mog", ".build/release/MogBar"
    pkgshare.install "Assets/AppIcon.icns"

    resource("face-model").stage do
      package = Pathname.pwd/"FaceEmbedding.mlpackage"
      package = Pathname.glob("**/FaceEmbedding.mlpackage").first unless package.exist?
      system bin/"mog", "compile-model", package, libexec/"FaceEmbedding.mlmodelc"
    end
  end

  def caveats
    <<~EOS
      Menu-bar app:
        mog install-app      # puts Mog.app in ~/Applications
                             # (run it again after each `brew upgrade mog`)
      Command line:
        mog enroll && mog test && mog watch

      Camera permission belongs to the app you run mog from (Terminal, iTerm, ...).
      Mog.app asks for its own the first time you turn it on.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mog version")
    assert_match "embedding size 512", shell_output("#{bin}/mog selftest")
    system bin/"mog", "install-app", "--dir", testpath
    assert_path_exists testpath/"Mog.app/Contents/MacOS/Mog"
    assert_path_exists testpath/"Mog.app/Contents/Resources/AppIcon.icns"
  end
end
