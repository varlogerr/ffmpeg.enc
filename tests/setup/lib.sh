mk_enc_cmd() {
  declare -n opts_in="${1}"
  local src="${2}"
  local dest="${3}"
  local opts="
    -c:v libx264 {scale_opts} -refs:v {ref} \
    -bf:v {bframes} -b_strategy:v {b-adapt} -me_range:v {merange} \
    -me_method:v {me} -subq:v {subme} -crf:v {crf} -g:v {keyint} \
    -keyint_min:v {min-keyint} -c:a libvorbis -q:a 0 -ac 1
  "

  for c in "${!opts_in[@]}"; do
    opts="$(sed "s/{${c}}/${opts_in[$c]}/g" <<< "${opts}")"
  done

  opts="$(tr '\n' ' ' <<< "${opts}" \
  | sed -E -e 's/\s+/ /g' -e 's/^\s+//' -e 's/\s+$//')"

  declare -a sources=()
  declare -a dests=()
  [[ -d "${src}" ]] && {
    while read -r f; do
      [[ -z "${f}" ]] && continue

      mime="$(file -b --mime-type -- "${f}")"
      [[ ! "${mime}" =~ ^video\/.* ]] && continue

      dir_prefix="$(dirname -- "${f#*${src}}")"
      filename="$(basename -- "${f}")"
      grep -q '\.' <<< "${filename}" \
        && filename="${filename%.*}"
      sources+=("${f}")
      dests+=("$(realpath -m "${dest}/${dir_prefix}/${filename}.mkv")")
    done <<< "$(find "${src}" -type f)"
  } || {
    sources+=("${src}")
    dests+=("${dest}")
  }

  for ix in "${!sources[@]}"; do
    echo "mkdir -p $(dirname -- "${dests[$ix]}")"
    echo "Encoding: ${sources[$ix]} ..."
    echo "ffmpeg -i ${sources[$ix]} ${opts} -hide_banner -nostats ${dests[$ix]}"
  done
}

set_enc_opts() {
  declare -n opts_in="${1}"
  local overrides="${2}"

  opts_in=(
    [width]=""
    [height]=""
    [scale_opts]=""
    [ref]=6
    [bframes]=7
    [b-adapt]=2
    [merange]=24
    [me]=umh
    [subme]=9
    [crf]=18
    [keyint]=300
    [min-keyint]=25
  )

  local kv
  for oi in "${!opts_in[@]}"; do
    kv="$(grep -Eo " ${oi}=[^ ]+ " <<< " ${overrides} ")"
    [[ $? -gt 0 ]] && continue
    kv="$(sed -E -e 's/^\s+//' -e 's/\s+$//' <<< "${kv}")"

    opts_in["${kv%%=*}"]="${kv#*=}"
  done

  if [[ -n "${opts_in[width]}" ]] && [[ -z "${opts_in[height]}" ]]; then
    opts_in[height]='-1'
  elif [[ -n "${opts_in[height]}" ]] && [[ -z "${opts_in[width]}" ]]; then
    opts_in[width]='-1'
  fi
  if [[ -n "${opts_in[width]}" ]] && [[ -n "${opts_in[height]}" ]]; then
    opts_in[scale_opts]="-vf scale=${opts_in[width]}:${opts_in[height]} -sws_flags lanczos"
  fi

  unset opts_in[width] opts_in[height]
}

mk_input_err() {
  local msg="${1}"
  printf -- '%s\n\n%s' "${msg}" "Issue \`${TOOL} -h\` for help"
}
