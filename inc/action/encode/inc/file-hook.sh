if [[ -n "${1}" ]]; then
  while read -r hook; do
    export SOURCE="${src}"
    export SOURCE_BASEDIR="${OPTS[src_basedir]:-$(dirname -- "${SOURCE}")}"
    export DEST="${dest}"
    export DEST_BASEDIR="${OPTS[dest_basedir]:-$(dirname -- "${DEST}")}"

    /bin/bash "${hook}"

    unset SOURCE \
          DEST
  done <<< "${1}"
fi
