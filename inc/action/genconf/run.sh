preset_txt=""
[[ -n "${OPTS[preset]}" ]] \
  && preset_txt="$(cat "${KEEPER[presdir]}/${OPTS[preset]}.conf")"

conffile_merge_to_base "${preset_txt}" | tail -n +6
