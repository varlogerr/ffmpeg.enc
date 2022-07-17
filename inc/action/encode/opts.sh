OPTS+=(
  [src]=
  [src_basedir]=
  [dest]=
  [dest_basedir]=
  [preset]=
  [conffiles]=
  [before]=
  [after]=
)

__opts_detect() {
  unset __opts_detect
  declare -a files=()
  local stopopt=0

  while :; do
    [[ -z "${1+x}" ]] && break

    [[ ${stopopt} -eq 1 ]] && {
      files+=("${1}")
      shift; continue
    }

    case "${1}" in
      --            ) stopopt=1 ;;
      -p|--preset   ) shift; OPTS[preset]="${1}" ;;
      -f|--conffile ) shift; OPTS[conffiles]+="${OPTS[conffiles]:+$'\n'}${1}" ;;
      --before      ) shift; OPTS[before]+="${OPTS[before]:+$'\n'}${1}" ;;
      --after       ) shift; OPTS[after]+="${OPTS[after]:+$'\n'}${1}" ;;
      -*            ) ERRBAG+=("Invalid option: ${1}") ;;
      *             ) files+=("${1}") ;;
    esac

    shift
  done

  # validate positional properties count
  if [[ ${#files[@]} -gt 3 ]]; then
    ERRBAG+=("Only SOURCE and DEST are allowed. Unexpected: ${files[*]:2}")
  fi

  OPTS[src]="${files[0]}"
  OPTS[dest]="${files[1]}"
} && __opts_detect "${@}"
