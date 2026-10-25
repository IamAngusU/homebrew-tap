class PhpFpmAudit < Formula
  desc "Audit PHP-FPM with previewed, reversible configuration fixes"
  homepage "https://github.com/IamAngusU/php-fpm-audit"
  url "https://github.com/IamAngusU/php-fpm-audit/releases/download/v2.2.2/p2s-harden-v2.2.2.zip"
  sha256 "151930178a1a9f0ef0eb7290bdce0cc2086b50738aec9003161aa0b399ecfab0"
  license "MIT"

  on_linux do
    depends_on "python@3.14"
  end

  def install
    libexec.install "p2s-harden.sh"
    doc.install "README.md", "README.de.md"

    runtime_path = OS.linux? ? "#{formula_opt_libexec("python@3.14")}/bin:$PATH" : "$PATH"
    (bin/"php-fpm-audit").write <<~SH
      #!/bin/sh
      export PATH="#{runtime_path}"
      exec /bin/bash "#{libexec}/p2s-harden.sh" "$@"
    SH
    bin.install_symlink "php-fpm-audit" => "p2s-harden.sh"
  end

  def caveats
    <<~EOS
      Audits require a Linux target with Python 3.8+ and readable /proc.
      On macOS, use: php-fpm-audit --ssh user@SERVER
    EOS
  end

  test do
    require "digest"
    require "json"
    require "shellwords"

    assert_equal "a3a5786a93cb7cdd34912a9ef9f313781186b756b99d2c1c17899476e548a227",
                 Digest::SHA256.file(libexec/"p2s-harden.sh").hexdigest
    assert_equal "p2s-harden #{version}", shell_output("#{bin}/php-fpm-audit --version").strip
    assert_equal "p2s-harden #{version}", shell_output("#{bin}/p2s-harden.sh --version").strip

    # Exercise the actual engine on Linux and its platform diagnostic on macOS.
    # Homebrew tests are unprivileged, so doctor reports incomplete privileges.
    report = JSON.parse(shell_output("#{bin}/php-fpm-audit --doctor --json", 2))
    assert_equal version.to_s, report.fetch("version")
    assert report.fetch("has_unknown")
    assert report.fetch("discovery").fetch(OS.mac? ? "bootstrap" : "doctor")

    # Test installed-path payload extraction, quoting and SSH exit propagation
    # without contacting a server or changing host configuration.
    ssh = testpath/"ssh-fixture"
    ssh.write <<~SH
      #!/bin/sh
      cat > "#{testpath}/payload.py"
      printf '%s\\n' "$@" > "#{testpath}/ssh-arguments"
      printf '%s\\n' '{"transport":"fixture"}'
      exit 1
    SH
    ssh.chmod 0755
    ENV["SSH_BIN"] = ssh.to_s
    output = shell_output("#{bin}/php-fpm-audit --ssh brew-fixture --json --lang de " \
                          "--root '#{testpath}/site with spaces'", 1)
    assert_equal({ "transport" => "fixture" }, JSON.parse(output))
    assert_match "VERSION = \"#{version}\"", (testpath/"payload.py").read
    arguments = (testpath/"ssh-arguments").read
    assert_match "bootstrap 1 de || exit 2", arguments
    remote_arguments = Shellwords.split(arguments.split("exec python3 -B - ", 2).last)
    assert_equal ["--json", "--lang", "de", "--root", "#{testpath}/site with spaces"],
                 remote_arguments.reject { |argument| argument == "--progress" }
  end
end
