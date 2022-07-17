__opts_preproc() {
  unset __opts_preproc

  # validate source file is provided, exists and of the correct mime
  if [[ -z "${OPTS[src]}" ]]; then
    ERRBAG+=("SOURCE is required")
  else
    OPTS[src]="$(realpath -q -m -- "${OPTS[src]}")"
    if [[ ! -e "${OPTS[src]}" ]]; then
      ERRBAG+=("Unreachable SOURCE: ${OPTS[src]}")
    else
      if [[ -f "${OPTS[src]}" ]]; then
        local mime="$(file -b --mime-type -- "${OPTS[src]}")"
        [[ "${mime}" =~ ^video\/.* ]] \
          || ERRBAG+=("Unsupported '${mime}' mime for SOURCE: ${OPTS[src]}")
      elif [[ -d "${OPTS[src]}" ]]; then
        OPTS[src_basedir]="${OPTS[src]}"
        srcdir_to_files "${OPTS[src]}" > /dev/null
        OPTS[src]="${RETVAL}"
      else
        ERRBAG+=("Unsupported SOURCE: ${OPTS[src]}")
      fi
    fi
  fi

  if [[ -z "${OPTS[dest]}" ]]; then
    ERRBAG+=("DEST is required")
  else
    OPTS[dest]="$(realpath -q -m -- "${OPTS[dest]}")"

    if [[ -n "${OPTS[src_basedir]}" ]]; then
      if [[ -f "${OPTS[dest]}" ]]; then
        ERRBAG+=("Can't encode SOURCE directory to DEST file: ${OPTS[src_basedir]} -> ${OPTS[dest]}")
      elif [[ (-e "${OPTS[dest]}" && ! -d "${OPTS[dest]}") ]]; then
        ERRBAG+=("Unsupported DEST: ${OPTS[dest]}")
      else
        OPTS[dest_basedir]="${OPTS[dest]}"
        srcdir_to_destfiles "${OPTS[src_basedir]}" \
          "${OPTS[src]}" "${OPTS[dest]}" > /dev/null
        OPTS[dest]="${RETVAL}"
        while read -r f; do
          # validate destination file don't exist
          [[ -z "${f}" ]] && continue
          [[ -e "${f}" ]] && ERRBAG+=("DEST file already exists: ${f}")
        done <<< "${OPTS[dest]}"
      fi
    elif [[ -e "${OPTS[dest]}" ]]; then
      # validate destination file doesn't exist
      ERRBAG+=("DEST file already exists: ${OPTS[dest]}")
    fi
  fi

  [[ ${#ERRBAG[@]} -gt 0 ]] && return 1

  OPTS[src]="$( while read -r f; do
    [[ -z "${f}" ]] && continue
    realpath -q -m -- "${f}"
  done <<< "${OPTS[src]}" )"
  OPTS[dest]="$( while read -r f; do
    [[ -z "${f}" ]] && continue
    realpath -q -m -- "${f}"
  done <<< "${OPTS[dest]}")"
} && __opts_preproc

__opts_preproc_confs() {
  unset __opts_preproc_confs

  # validate preset value
  [[ -n "${OPTS[preset]}" ]] && {
    if grep -qFx "${OPTS[preset]}" <<< "${KEEPER[presets]}"; then
      OPTS[conffiles]="${KEEPER[presdir]}/${OPTS[preset]}.conf${OPTS[conffiles]:+$'\n'}${OPTS[conffiles]}"
    else
      ERRBAG+=("Invalid PRESET: ${OPTS[preset]}")
    fi
  }
} && __opts_preproc_confs

__opts_preproc_hooks() {
  unset __opts_preproc_hooks

  local before
  local after

  [[ -n "${OPTS[before]}" ]] && while read -r b; do
    b="$(realpath -m -q -- "${b}")"
    [[ ! -f "${b}" ]] && {
      ERRBAG+=("Unreachable BEFORE hook: ${b}")
      continue
    }
    before+="${before:+$'\n'}${b}"
  done <<< "${OPTS[before]}"

  [[ -n "${OPTS[after]}" ]] && while read -r a; do
    a="$(realpath -m -q -- "${a}")"
    [[ ! -f "${a}" ]] && {
      ERRBAG+=("Unreachable AFTER hook: ${a}")
      continue
    }
    after+="${after:+$'\n'}${a}"
  done <<< "${OPTS[after]}"

  OPTS[before]="${before}"
  OPTS[after]="${after}"
} && __opts_preproc_hooks
