class Gryphon < Formula
  desc "The Swift to Kotlin translator"
  homepage "https://vinivendra.github.io/Gryphon/"
  url "https://github.com/vinivendra/Gryphon/archive/v0.9.0.tar.gz"
  sha256 "989ba1ed182f57f779c2e27a0609e22a4e462426aee05b971e28ee01d0ae4a52"

  head "https://github.com/vinivendra/Gryphon.git", :branch => "development"

  depends_on "ruby"
  depends_on "kotlin" => :recommended

  resource "xcodeproj" do
    url "https://rubygems.org/downloads/xcodeproj-1.16.0.gem"
    sha256 "7109069ba1f73f524add89c6b1812b73ba41a30d0d8ad37de206b54f8d4773ae"
  end

  def install
    # Check if Swift's installed
    if `which swift`.empty?
      odie "Swift not found. Download version 5.1 or 5.2 from "\
        "https://swift.org/download/ (or bundled with Xcode 11 or higher)."
    end

    # Build the project
    system "swift", "build"

    # Copy the built executable to the appropriate location
    bin.install ".build/debug/gryphon"
  end

  test do
    # Create a swift file
    File.write("test.swift", "print(\"Swift\") // gryphon value: println(\"Kotlin\")\n")

    # Translate the swift file and check the output
    assert_equal "println(\"Kotlin\")",
      shell_output("#{bin}/gryphon test.swift --no-main-file").strip
  end
end
