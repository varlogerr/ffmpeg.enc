. "${KEEPER[commondir]}/conffile.sh"

declare -A CONFFILE_CONF=()

conffile_parse() {
  local merge_files="${1}"
  declare -A conf=()
  local merge_txt
  local content=""

  while read -r f; do
    [[ -z "${f}" ]] && continue

    [[ ! -f "${f}" ]] \
      && ERRBAG+=("Unreachable CONFFILE: ${f}") \
      && continue

    merge_txt+=$'\n'"$(cat "${f}")"
  done <<< "${merge_files}"

  conffile_merge_to_base "${merge_txt}" > /dev/null
  content="$(txt_rmcomment <<< "${RETVAL}" | txt_rmblank | sed -E 's/\s*=\s*/=/')"

  while read -r l; do
    [[ -z "${l}" ]] && continue
    conf[${l%%=*}]="${l#*=}"
  done <<< "${content}"

  conf[scale_opts]=""
  if [[ -n "${conf[width]}" ]] && [[ -z "${conf[height]}" ]]; then
    conf[height]='-1'
  elif [[ -n "${conf[height]}" ]] && [[ -z "${conf[width]}" ]]; then
    conf[width]='-1'
  fi
  if [[ -n "${conf[width]}" ]] && [[ -n "${conf[height]}" ]]; then
    conf[scale_opts]="-vf scale=${conf[width]}:${conf[height]} -sws_flags lanczos"
  fi

  for k in "${!conf[@]}"; do
    CONFFILE_CONF[$k]="${conf[$k]}"
  done

  [[ ${#ERRBAG[@]} -gt 0 ]] && return 1
  return 0
}

srcdir_to_files() {
  # unset retval
  RETVAL=""
  local dir="${1}"
  local files

  files="$( find "${dir}" -type f \
    | while read -r f; do
      [[ -z "${f}" ]] && continue

      mime="$(file -b --mime-type -- "${f}")"
      [[ "${mime}" =~ ^video\/.* ]] \
        && echo "${f}"
    done )"

  RETVAL="${files}"
  echo "${files}"
}

srcdir_to_destfiles() {
  # unset retval
  RETVAL=""
  local basedir="${1}"
  local srcfiles="${2}"
  local destdir="${3}"
  local destfiles

  destfiles="$( while read -r f; do
    dir_prefix="$(dirname -- "${f#*${basedir}}")"
    filename="$(basename -- "${f}")"
    grep -q '\.' <<< "${filename}" \
      && filename="${filename%.*}"
    realpath -m "${destdir}/${dir_prefix}/${filename}.mkv"
  done <<< "${srcfiles}" )"

  RETVAL="${destfiles}"
  echo "${destfiles}"
}
