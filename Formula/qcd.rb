class Qcd < Formula
  desc "Quick directory bookmarks for zsh"
  homepage "https://github.com/adamzafir/qcd"
  url "https://github.com/adamzafir/qcd/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "017d1ab56bfbc8fba7546ffa8292820de2b29d0c9c0f105dba1e93e3da93c884"
  license "MIT"

  def install
    pkgshare.install "qcd.zsh"
    (pkgshare/"install.zsh").write <<~EOS
      #!/usr/bin/env zsh
      _qcd_install_main() {
        emulate -L zsh
        setopt errexit nounset pipefail

        local zshrc source_line is_first_install
        zshrc="${ZDOTDIR:-$HOME}/.zshrc"
        touch "$zshrc"

        source_line='source "#{opt_pkgshare}/qcd.zsh"'
        is_first_install=0
        if ! grep -qxF "$source_line" "$zshrc"; then
          printf '\\n%s\\n' "$source_line" >> "$zshrc"
          is_first_install=1
        fi

        if [[ "${ZSH_EVAL_CONTEXT-}" == *:file* ]]; then
          source "#{opt_pkgshare}/qcd.zsh"
          print -- "qcd: installed and loaded in this shell"
          if (( is_first_install )); then
            print -- ""
            qcd help
          fi
        else
          print -- "qcd: installed in $zshrc"
          print -- "qcd: run this once to load now:"
          print -- 'source "#{opt_pkgshare}/qcd.zsh"'
        fi
      }

      _qcd_install_main "$@"
    EOS
    chmod 0755, pkgshare/"install.zsh"
  end

  def caveats
    <<~EOS
      qcd must be sourced to change directories in your current shell.

      Run setup once (adds qcd to ~/.zshrc and loads it now):
        source "#{opt_pkgshare}/install.zsh"
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
