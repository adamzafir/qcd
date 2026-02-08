# qcd: quick directory bookmarks with persistent storage.
# Source this file from ~/.zshrc:
#   source "/Users/adam/Downloads/zshrc editor/qcd.zsh"

export QCD_STORE="${QCD_STORE:-$HOME/.qcd_bookmarks.zsh}"
typeset -gA QCD_MAP

_qcd_strip_quotes() {
  emulate -L zsh
  local value="${1-}"
  value="${value#\"}"
  value="${value%\"}"
  value="${value#\'}"
  value="${value%\'}"
  print -r -- "$value"
}

_qcd_normalize_alias() {
  emulate -L zsh
  local value="${1-}"

  # Trim outer whitespace.
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  # Undo legacy escaped-quote artifacts from buggy serializers.
  value="${value//\\\"/\"}"
  value="${value//\\\'/\'}"

  # Remove wrapping quotes/backslashes repeatedly.
  while :; do
    local prev="$value"

    if [[ $value == \"*\" ]]; then
      value="${value#\"}"
      value="${value%\"}"
    fi
    if [[ $value == \'*\' ]]; then
      value="${value#\'}"
      value="${value%\'}"
    fi
    if [[ $value == \\* ]]; then
      value="${value#\\}"
    fi
    if [[ $value == *\\ ]]; then
      value="${value%\\}"
    fi

    [[ "$value" == "$prev" ]] && break
  done

  # If a legacy key ended with only one quote side, strip leftovers.
  while [[ $value == \"* ]]; do value="${value#\"}"; done
  while [[ $value == *\" ]]; do value="${value%\"}"; done
  while [[ $value == \'* ]]; do value="${value#\'}"; done
  while [[ $value == *\' ]]; do value="${value%\'}"; done
  while [[ $value == \\* ]]; do value="${value#\\}"; done
  while [[ $value == *\\ ]]; do value="${value%\\}"; done

  print -r -- "$value"
}

_qcd_load() {
  emulate -L zsh
  setopt localoptions no_aliases

  typeset -gA QCD_MAP
  QCD_MAP=()

  if [[ -f "$QCD_STORE" ]]; then
    source "$QCD_STORE" 2>/dev/null || {
      print -u2 -- "qcd: failed to read store: $QCD_STORE"
      return 1
    }
  fi

  # Backward-compatibility: older versions could persist keys with
  # literal wrapping quotes and/or stray backslashes.
  # Normalize keys on load and rewrite the store once if needed.
  local key normalized
  local changed=0
  local -A normalized_map
  normalized_map=()

  for key in ${(k)QCD_MAP}; do
    normalized="$(_qcd_normalize_alias "$key")"
    normalized_map[$normalized]="${QCD_MAP[$key]}"
    [[ "$normalized" != "$key" ]] && changed=1
  done

  QCD_MAP=()
  for key in ${(k)normalized_map}; do
    QCD_MAP[$key]="${normalized_map[$key]}"
  done

  (( changed )) && _qcd_save
  return 0
}

_qcd_save() {
  emulate -L zsh
  setopt localoptions no_aliases

  : >| "$QCD_STORE" || {
    print -u2 -- "qcd: failed to write store: $QCD_STORE"
    return 1
  }

  print -r -- 'typeset -gA QCD_MAP' >> "$QCD_STORE"

  local key
  for key in ${(ok)QCD_MAP}; do
    print -r -- "QCD_MAP[${(q)key}]=${(qq)QCD_MAP[$key]}" >> "$QCD_STORE"
  done
}

_qcd_help() {
  cat <<'EOF'
qcd - quick cd bookmarks

Usage:
  qcd add
  qcd add .
  qcd remove <alias>
  qcd list
  qcd <alias>
  qcd help
EOF
}

qcd() {
  emulate -L zsh
  setopt localoptions no_aliases

  _qcd_load || return 1

  local cmd
  if (( $# > 0 )); then
    cmd="$1"
    shift
  else
    cmd="help"
  fi

  case "$cmd" in
    help|-h|--help)
      _qcd_help
      ;;

    list|ls)
      if (( ${#QCD_MAP} == 0 )); then
        print -- "qcd: no bookmarks yet. run: qcd add"
        return 0
      fi

      print -r -- $'alias\tpath'
      print -r -- $'-----\t----'

      local key
      for key in ${(ok)QCD_MAP}; do
        printf "%s\t%s\n" "$key" "${QCD_MAP[$key]}"
      done | column -t -s $'\t'
      ;;

    add)
      local input_path input_alias path q_alias

      if [[ "${1-}" == "." ]]; then
        path="${PWD:A}"
      else
        printf "add the path: "
        IFS= read -r input_path
        [[ -n "$input_path" ]] || {
          print -- "qcd: no path provided"
          return 1
        }

        input_path="$(_qcd_strip_quotes "$input_path")"
        input_path="${~input_path}"
        [[ "$input_path" = /* ]] || input_path="$PWD/$input_path"
        path="${input_path:A}"

        if [[ ! -d "$path" ]]; then
          print -- "qcd: not a directory: $path"
          return 1
        fi
      fi

      printf "add the alias: "
      IFS= read -r input_alias
      q_alias="$(_qcd_normalize_alias "$input_alias")"

      [[ -n "$q_alias" ]] || {
        print -- "qcd: no alias provided"
        return 1
      }

      if [[ ! "$q_alias" =~ ^[A-Za-z0-9._-]+$ ]]; then
        print -- "qcd: alias can only contain letters, numbers, dot, underscore, dash"
        return 1
      fi

      QCD_MAP[$q_alias]="$path"
      _qcd_save || return 1
      print -- "qcd: saved '$q_alias' -> $path"
      ;;

    remove|rm|del|delete)
      local q_alias
      q_alias="$(_qcd_normalize_alias "${1-}")"

      [[ -n "$q_alias" ]] || {
        print -- "qcd: provide an alias to remove"
        return 1
      }

      if [[ -z "${QCD_MAP[$q_alias]+x}" ]]; then
        print -- "qcd: no such alias: $q_alias"
        return 1
      fi

      unset "QCD_MAP[$q_alias]"
      _qcd_save || return 1
      print -- "qcd: removed '$q_alias'"
      ;;

    *)
      local q_alias dest
      q_alias="$(_qcd_normalize_alias "$cmd")"
      dest="${QCD_MAP[$q_alias]-}"

      if [[ -z "$dest" ]]; then
        print -- "qcd: unknown alias '$q_alias'"
        print -- "try: qcd list"
        return 1
      fi

      builtin cd -- "$dest"
      ;;
  esac
}
