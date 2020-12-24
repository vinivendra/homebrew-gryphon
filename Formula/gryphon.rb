class Gryphon < Formula
  desc "The Swift to Kotlin translator"
  homepage "https://vinivendra.github.io/Gryphon/"
  url "https://github.com/vinivendra/Gryphon/archive/v0.12.tar.gz"
  sha256 "fc1733c0f25fa5c71d881b39462175e80e97c614d65d46d1a2e66d7ebcf88498"

  head "https://github.com/vinivendra/Gryphon.git", :branch => "development"

  depends_on "ruby"
  depends_on "kotlin" => :recommended

  resource "xcodeproj" do
    url "https://rubygems.org/downloads/xcodeproj-1.16.0.gem"
    sha256 "7109069ba1f73f524add89c6b1812b73ba41a30d0d8ad37de206b54f8d4773ae"
  end

  def install
    # Install gems to libexec/vendor
    resources.each do |r|
      r.verify_download_integrity(r.fetch)
      system("gem", "install", "--install-dir", "#{libexec}/vendor", r.cached_download, "--no-document")
    end

    # Change the contents of the RubyScriptContents.swift file to
    # include the correct path
    contents = %Q(
      internal let rubyScriptFileContents = """
      #!/bin/bash
      export GEM_HOME="#{libexec}/vendor"
      exec ruby "$@"
      """
    )

    File.write("Sources/GryphonLib/RubyScriptContents.swift", contents)

    # Check if Swift's installed
    if `which swift`.empty?
      odie "Swift not found. Download Swift from "\
        "https://swift.org/download/ (or bundled with Xcode 11 or higher)."
    end

    # Build the project
    system "swift", "build", "--disable-sandbox"

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
