#!/usr/bin/env zsh

_qcd_install_main() {
  emulate -L zsh
  setopt errexit nounset pipefail

  local script_path script_dir qcd_script zshrc source_line is_sourced is_first_install

  script_path="${(%):-%N}"
  script_dir="${script_path:A:h}"
  qcd_script="${1:-$script_dir/qcd.zsh}"
  qcd_script="${qcd_script:A}"

  if [[ ! -f "$qcd_script" ]]; then
    print -u2 -- "qcd: missing script: $qcd_script"
    return 1
  fi

  zshrc="${ZDOTDIR:-$HOME}/.zshrc"
  touch "$zshrc"

  source_line="source \"$qcd_script\""
  is_first_install=0
  if ! grep -qxF "$source_line" "$zshrc"; then
    printf '\n%s\n' "$source_line" >> "$zshrc"
    is_first_install=1
  fi

  is_sourced=0
  if [[ "${ZSH_EVAL_CONTEXT-}" == *:file* ]]; then
    is_sourced=1
  fi

  if (( is_sourced )); then
    source "$qcd_script"
    print -- "qcd: installed and loaded in this shell"
    if (( is_first_install )); then
      print -- ""
      qcd help
    fi
  else
    print -- "qcd: installed in $zshrc"
    print -- "qcd: run this once to load now:"
    print -- "source \"$qcd_script\""
  fi
}

_qcd_install_main "$@"
