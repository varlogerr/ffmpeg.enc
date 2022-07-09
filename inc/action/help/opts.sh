OPTS+=(
  [func]=
)

__opts_detect() {
  unset __opts_detect

  local suffix=help

  while :; do
    [[ -z "${1+x}" ]] && break

    case "${1}" in
      --help  ) shift; suffix="${1}" ;;
      *       ) ERRBAG+=("Invalid argument: ${1}") ;;
    esac

    shift
  done

  OPTS[func]="print_help_${suffix}"
} && __opts_detect "${@}"
