OPTS+=(
  [preset]=
)

__opts_detect() {
  unset __opts_detect

  declare -a presets=()

  while :; do
    [[ -z "${1+x}" ]] && break

    case "${1}" in
      * ) presets+=("${1}") ;;
    esac

    shift
  done

  OPTS[preset]="${presets[0]}"
  for inval in "${presets[@]:1}"; do
    ERRBAG+=("Invalid argument: ${inval}")
  done

  [[ -n "${OPTS[preset]}" ]] \
    && ! grep -qFx -- "${OPTS[preset]}" <<< "${KEEPER[presets]}" \
    && ERRBAG+=("Invalid PRESET: "${OPTS[preset]}"")
} && __opts_detect "${@}"
