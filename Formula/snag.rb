class Snag < Formula
  desc "Copy on select for macOS — automatically copies selected text to clipboard"
  homepage "https://github.com/cv087/snag"
  url "https://github.com/cv087/snag/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "a0e2a82e6e33550cd09b873c9e36a559840572f5e9d68b112a0c4e98e87140ed"
  license "MIT"

  depends_on xcode: ["14.0", :build]
  depends_on :macos => :ventura

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/Snag" => "snag"
  end

  def caveats
    <<~EOS
      Snag requires Accessibility permission to work.
      On first launch, go to:
        System Settings > Privacy & Security > Accessibility
      and enable Snag.
    EOS
  end

  test do
    assert_predicate bin/"snag", :executable?
  end
end
