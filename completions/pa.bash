_pa() {
  local cmd="${COMP_WORDS[1]}"

  if [[ $COMP_CWORD -eq 1 ]]; then
    mapfile -t COMPREPLY < <(compgen -W "add del edit git list move show rand qr otp oi oc ou ov" -- "${COMP_WORDS[1]}")
    return
  fi

  case "$cmd" in
  oi | oc | ou)
    [[ $COMP_CWORD -eq 2 ]] || return
    mapfile -t COMPREPLY < <(compgen -W "$(pa l | grep -- '-otp$')" -- "${COMP_WORDS[2]}")
    ;;
  otp | o*)
    if [[ $COMP_CWORD -eq 2 ]]; then
      mapfile -t COMPREPLY < <(compgen -W "insert code uri validate" -- "${COMP_WORDS[2]}")
      return
    fi
    [[ $COMP_CWORD -eq 3 ]] || return
    case "${COMP_WORDS[2]}" in
    i* | c* | u*)
      mapfile -t COMPREPLY < <(compgen -W "$(pa l | grep -- '-otp$')" -- "${COMP_WORDS[3]}")
      ;;
    esac
    ;;
  m*)
    [[ $COMP_CWORD -le 3 ]] || return
    mapfile -t COMPREPLY < <(compgen -W "$(pa l)" -- "${COMP_WORDS[$COMP_CWORD]}")
    ;;
  [desq]*)
    [[ $COMP_CWORD -eq 2 ]] || return
    mapfile -t COMPREPLY < <(compgen -W "$(pa l)" -- "${COMP_WORDS[2]}")
    ;;
  l*)
    [[ $COMP_CWORD -eq 2 ]] || return
    mapfile -t COMPREPLY < <(compgen -W "$(pa l | sed 's/[^/]\+$//' | grep '/$' | sort -u)" -- "${COMP_WORDS[2]}")
    ;;
  esac
}

complete -o filenames -F _pa pa
