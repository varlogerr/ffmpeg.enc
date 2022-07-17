enc_conf="
  -c:v libx264 {scale_opts} -refs:v {ref} -bf:v {bframes} \
  -b_strategy:v {b-adapt} -me_range:v {merange} -me_method:v {me} \
  -subq:v {subme} -crf:v {crf} -g:v {keyint} -keyint_min:v {min-keyint} \
  -c:a libvorbis -q:a 0 -ac 1 \
  -hide_banner -nostats -map_metadata -1
"

for c in "${!CONFFILE_CONF[@]}"; do
  enc_conf="$(sed "s/{${c}}/${CONFFILE_CONF[$c]}/g" <<< "${enc_conf}")"
done

enc_conf="$(tr '\n' ' ' <<< "${enc_conf}" | sed -E 's/\s+/ /g')"

declare -A ERRBAG_ENC=(
  # [destdir]=
  # [before]=
  # [interrupted]=
  # [unknown]=
  # [after]=
)

mapfile -t sources_arr <<< "${OPTS[src]}"
mapfile -t dests_arr <<< "${OPTS[dest]}"
for ix in "${!sources_arr[@]}"; do
  src="${sources_arr[$ix]}"

  [[ -z "${src}" ]] && continue

  dest="${dests_arr[$ix]}"
  (( line++ ))

  destdir="$(dirname "${dest}")"
  mkdir -p "${destdir}" || {
    ERRBAG_ENC[destdir]+="${ERRBAG_ENC[destdir]:+$'\n'}${destdir}"
    continue
  }

  . "${KEEPER[actdir]}/inc/file-hook.sh" "${OPTS[before]}" \
  || {
    ERRBAG_ENC[before]+="${ERRBAG_ENC[before]:+$'\n'}${src} => ${dest}"
    continue
  }

  echo "Encoding: ${src} ..."
  ffmpeg -i "${src}" ${enc_conf} "${dest}" 2> /dev/null
  rc=$?
  if [[ $rc -eq 255 ]]; then
    ERRBAG_ENC[interrupted]+="${ERRBAG_ENC[interrupted]:+$'\n'}${src} => ${dest}"
    break
  elif [[ $rc -gt 0 ]]; then
    ERRBAG_ENC[unknown]+="${ERRBAG_ENC[unknown]:+$'\n'}(${rc})${src} => ${dest}"
    continue
  fi

  . "${KEEPER[actdir]}/inc/file-hook.sh" "${OPTS[after]}" \
  || {
    ERRBAG_ENC[after]+="${ERRBAG_ENC[after]:+$'\n'}${src} => ${dest}"
    continue
  }
done

if [[ ${#ERRBAG_ENC[@]} -lt 1 ]]; then
  exit
fi

echo "=============="

{
  [[ -n "${ERRBAG_ENC[destdir]}" ]] && {
    echo "Error creating destination directories:"
    while read -r d; do
      echo "* ${d}"
    done <<< "${ERRBAG_ENC[destdir]}"
  }

  [[ -n "${ERRBAG_ENC[before]}" ]] && {
    echo "Before hook errors:"
    while read -r d; do
      echo "* ${d}"
    done <<< "${ERRBAG_ENC[before]}"
  }

  [[ -n "${ERRBAG_ENC[interrupted]}" ]] && {
    echo "Interrupted encode:"
    while read -r d; do
      echo "* ${d}"
    done <<< "${ERRBAG_ENC[interrupted]}"
  }

  [[ -n "${ERRBAG_ENC[unknown]}" ]] && {
    echo "Unknown encode errors:"
    while read -r d; do
      echo "* ${d}"
    done <<< "${ERRBAG_ENC[unknown]}"
  }

  [[ -n "${ERRBAG_ENC[after]}" ]] && {
    echo "After hook errors:"
    while read -r d; do
      echo "* ${d}"
    done <<< "${ERRBAG_ENC[after]}"
  }
} >&2

# for err in "${ERRBAG_ENC[@]}"; do
#   echo "* ${err}"
# done >&2
