class Qcd < Formula
  desc "Quick directory bookmarks for zsh"
  homepage "https://github.com/adamzafir/qcd"
  url "https://github.com/adamzafir/qcd/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "017d1ab56bfbc8fba7546ffa8292820de2b29d0c9c0f105dba1e93e3da93c884"
  license "MIT"

  def install
    pkgshare.install "qcd.zsh"
  end

  def caveats
    <<~EOS
      qcd must be sourced to change directories in your current shell.

      Add this to your ~/.zshrc:
        source "#{opt_pkgshare}/qcd.zsh"
    EOS
  end

  test do
    target = testpath/"target"
    target.mkpath

    output = shell_output(
      "zsh -lc 'source \"#{opt_pkgshare}/qcd.zsh\"; " \
      "export QCD_STORE=\"#{testpath}/bookmarks.zsh\"; " \
      "printf \"#{target}\\nt\\n\" | qcd add >/dev/null; " \
      "qcd t; pwd'"
    ).strip

    assert_equal target.to_s, output
  end
end
