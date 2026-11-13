# Bash completion for pa.
# shellcheck disable=SC2312 # a failing `pa list` should just yield no matches

_pa_otp_entries() {
  pa list | grep -- '-otp$'
}

_pa_categories() {
  pa list | sed 's/[^/]\+$//' | grep '/$' | sort -u
}

_pa_reply() {
  mapfile -t COMPREPLY < <(compgen -W "$1" -- "${COMP_WORDS[COMP_CWORD]}")
}

_pa() {
  local cmd="${COMP_WORDS[1]}"
  local commands="add del edit git insert list move me meta show rand qr"
  commands+=" otp oi oc ou ov"

  if ((COMP_CWORD == 1)); then
    _pa_reply "${commands}"
    return
  fi

  case "${cmd}" in
  oi | oc | ou)
    ((COMP_CWORD == 2)) && _pa_reply "$(_pa_otp_entries)"
    ;;
  o | otp)
    if ((COMP_CWORD == 2)); then
      _pa_reply "insert code uri validate"
      return
    fi
    ((COMP_CWORD == 3)) || return
    case "${COMP_WORDS[2]}" in
    i | insert | c | code | u | uri) _pa_reply "$(_pa_otp_entries)" ;;
    *) ;;
    esac
    ;;
  m | move)
    ((COMP_CWORD <= 3)) && _pa_reply "$(pa list)"
    ;;
  me | meta | l | list)
    ((COMP_CWORD == 2)) && _pa_reply "$(_pa_categories)"
    ;;
  d | del | e | edit | s | show | q | qr)
    ((COMP_CWORD == 2)) && _pa_reply "$(pa list)"
    ;;
  *) ;;
  esac
}

complete -o filenames -F _pa pa
