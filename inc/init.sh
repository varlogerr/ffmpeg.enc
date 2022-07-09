declare -a INIT_PREREQ_CHECK_CMDS="
  ffmpeg -version
  file --version
  find --version
  grep --version
  head --version
  realpath --version
  rev --version
  sed --version
  sort --version
  tail --version
  tr --version
"

_init_prereq() {
  # prerequisites check
  while read -r cmd; do
    [[ -z "${cmd}" ]] && continue
    ${cmd} 2> /dev/null >&2 || ERRBAG+=("Unavailable or corrupted util: ${cmd%% *}")
  done <<< "${INIT_PREREQ_CHECK_CMDS}"

  if [[ ${#ERRBAG[@]} -gt 0 ]]; then
    for e in "${ERRBAG[@]}"; do
      printf -- '%s\n' "${e}"
    done

    exit 1
  fi
}

__init_run() {
  unset __init_run
  _init_prereq
} && __init_run
