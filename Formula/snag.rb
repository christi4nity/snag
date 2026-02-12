class Snag < Formula
  desc "Copy on select for macOS — automatically copies selected text to clipboard"
  homepage "https://github.com/christi4nity/snag"
  url "https://github.com/christi4nity/snag/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "a0e2a82e6e33550cd09b873c9e36a559840572f5e9d68b112a0c4e98e87140ed"
  license "MIT"

  depends_on xcode: ["14.0", :build]
  depends_on :macos => :ventura

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    mkdir_p "Snag.app/Contents/MacOS"
    cp ".build/release/Snag", "Snag.app/Contents/MacOS/Snag"
    cp "Sources/Snag/Info.plist", "Snag.app/Contents/Info.plist"
    prefix.install "Snag.app"
  end

  def caveats
    <<~EOS
      Snag has been installed to:
        #{prefix}/Snag.app

      To use it:
        open #{prefix}/Snag.app

      You can also drag it to /Applications or add it to Login Items.
      Snag requires Accessibility permission — grant it when prompted.
    EOS
  end

  test do
    assert_predicate prefix/"Snag.app/Contents/MacOS/Snag", :executable?
  end
end
