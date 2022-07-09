enc_conf="
  -c:v libx264 {scale_opts} -refs:v {ref} -bf:v {bframes} \
  -b_strategy:v {b-adapt} -me_range:v {merange} -me_method:v {me} \
  -subq:v {subme} -crf:v {crf} -g:v {keyint} -keyint_min:v {min-keyint} \
  -c:a libvorbis -q:a 0 -ac 1
"

for c in "${!CONFFILE_CONF[@]}"; do
  enc_conf="$(sed "s/{${c}}/${CONFFILE_CONF[$c]}/g" <<< "${enc_conf}")"
done

enc_conf="$(tr '\n' ' ' <<< "${enc_conf}" | sed -E 's/\s+/ /g')"

line=1; while read -r src; do
  [[ -z "${src}" ]] && continue

  dest="$(head -n ${line} <<< "${OPTS[dest]}" | tail -n 1)"
  (( line++ ))

  destdir="$(dirname "${dest}")"
  mkdir -p "${destdir}" || {
    echo "Can't create destination directory ${destdir}"
    continue
  }

  echo "Encoding: ${src} ..."
  ffmpeg -i "${src}" ${enc_conf} -hide_banner -nostats "${dest}" 2> /dev/null
  rc=$?
  if [[ $rc -eq 255 ]]; then
    echo "Interrupted!"
  elif [[ $rc -gt 0 ]]; then
    echo "($rc) Some error occured!"
  fi
done <<< "${OPTS[src]}"
