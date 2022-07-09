conffile_merge_to_base() {
  # reset "${RETVAL}"
  RETVAL=""
  local merge_txt="${1}"
  # expression to unify kv lines to a unified form
  # `key=value#some comment`, i.e. no spaces anywhere
  # but the comment
  local kv_unify_expr="$(printf -- \
    's/^(%s)\s*=\s*(%s)(\s*#\s*)?(%s)$/\\1=\\2#\\4/' \
    '[^#][^ |=]*' '[^ |#]*' '.*')"
  local kv_strip_rule='s/^([^#][^=]*=[^#]*).*$/\1/'
  # content with rm spaces between value and trailing
  # hashed comment (rule)
  local content="$(txt_trim "${KEEPER[presdir]}/_base.conf" \
    | sed -E "${kv_unify_expr}")"
  # hash separated key#rule lines
  local key_rule="$(txt_rmcomment <<< "${content}" \
    | txt_rmblank \
    | sed -E 's/^([^#][^=]*)=[^#]*(#.*)/\1\2/')"
  declare -A key_rule_map=()
  declare -A overrides=()

  while read -r kr; do
    [[ -z "${kr}" ]] && continue
    key_rule_map[${kr%%\#*}]="${kr#*\#}"
  done <<< "${key_rule}"

  # we created a rule map, now we can cleanup content
  # from trailing rule comments
  content="$(sed -E "${kv_strip_rule}" <<< "${content}")"

  # leave only key=value in the merge text
  merge_txt="$(txt_trim <<< "${merge_txt}" \
    | sed -E -e "${kv_unify_expr}")"

  local merged_txt="${content}"$'\n'"${merge_txt}"
  # we need only `key=val` to form `conf` structure
  merged_txt="$(sed -E "${kv_strip_rule}" <<< "${merged_txt}" \
    | txt_rmblank | txt_rmcomment)"

  # collect valid and invalid lines
  local val_lines="$(grep -E '^[a-z][^=]*=' <<< "${merged_txt}")"
  local inval_lines="$(grep -vFxf <(printf -- '%s' "${val_lines}") <(printf -- '%s' "${merged_txt}"))"

  while read -r inval; do
    [[ -n "${inval}" ]] && ERRBAG+=("Invalid CONFFILE line: ${inval}")
  done <<< "${inval_lines}"

  local key
  local val
  local ckeck_fnc
  local param1
  local param2
  while read -r l; do
    [[ -z "${l}" ]] && continue

    key="${l%%=*}"
    val="${l#*=}"

    [[ -z "${key_rule_map[${key}]}" ]] && {
      ERRBAG+=("Unsupported CONFFILE key: ${key}")
      continue
    }

    # if the key is fine no need to check empty value
    [[ -n "${val}" ]] && {
      check_fnc="_conffile_rule_${key_rule_map[$key]%%:*}"
      param1="${val}"
      param2="$(cut -d':' -f2 <<< "${key_rule_map[$key]}:")"

      ${check_fnc} "${param1}" "${param2}" || {
        ERRBAG+=("Invalid CONFFILE value for ${key}: ${val}")
        val=''
      }
    }

    overrides[${key}]="${val}"
  done <<< "${val_lines}"

  for k in "${!overrides[@]}"; do
    val="${overrides[$k]}"
    [[ -z "${val}" ]] && val='\2' || val=" ${val}"
    content="$(sed -E "s/^(${k})=(.*)/\1 =${val}/" <<< "${content}")"
  done

  RETVAL="${content}"
  printf -- '%s\n' "${content}"
}

_conffile_rule_int() {
  local val="${1}"
  [[ "${val}" =~ ^[0-9]+$ ]]
}

_conffile_rule_range() {
  local val="${1}"
  local range="${2}"
  local from=${range%%-*}
  local to=${range#*-}

  [[ ( "${val}" =~ ^[0-9]+$ \
    && ${val} -ge ${from} \
    && ${val} -le ${to} ) ]]
}

_conffile_rule_rex() {
  local val="${1}"
  local rex="${2}"
  grep -qE -- "${rex}" <<< "${1}"
}
