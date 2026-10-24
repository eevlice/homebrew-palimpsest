class Palimpsest < Formula
  desc "Local, self-contained AI-assisted book translation tool"
  homepage "https://github.com/eevlice/Palimpsest"
  url "https://github.com/eevlice/Palimpsest/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "7c805697d7795507ad90d7caaa703325b375f321692f29543961d31d8b751adc"
  # no license field - the repo has no LICENSE file yet, so nothing to
  # declare truthfully. Add one (and this line) if that changes.

  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]
    venv = libexec/"venv"
    system formula_opt_bin("python@3.12")/"python3.12", "-m", "venv", venv
    system venv/"bin/pip", "install", "--quiet", "-r", libexec/"requirements.txt"

    (bin/"palimpsest").write <<~SH
      #!/bin/bash
      cd "#{libexec}"
      exec "#{venv}/bin/python3" server.py
    SH
  end

  service do
    # opt_libexec (the version-independent opt/ symlink), not libexec (the
    # version-pinned Cellar path) - a service file baking in the versioned
    # path would need re-registering by hand on every `brew upgrade`.
    run [opt_libexec/"venv/bin/python3", opt_libexec/"server.py"]
    working_dir opt_libexec
    keep_alive true
    log_path var/"log/palimpsest.log"
    error_log_path var/"log/palimpsest.log"
  end

  def caveats
    <<~EOS
      Books, API keys, and preferences all live in ~/.palimpsest/ - never
      inside this Homebrew install - so `brew upgrade palimpsest` never
      touches your work.

      Run it in the foreground:
        palimpsest
      ...or as a background service that starts on login:
        brew services start palimpsest

      Either way, open http://localhost:5001 and add your API key from
      the Settings screen the first time.
    EOS
  end

  test do
    system libexec/"venv/bin/python3", "-c",
           "import flask, anthropic, openai, google.genai, docx, cryptography, pypdfium2, pdfminer"
  end
end
