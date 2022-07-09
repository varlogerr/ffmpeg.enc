[[ "$(type -t "${OPTS[func]}")" != 'function' ]] && {
  echo "System error" >&2
  exit 1
}

"${OPTS[func]}"
