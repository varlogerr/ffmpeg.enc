declare RC_ERR=1
declare exp_out
declare act_out

for util in "${DEPENDENCIES[@]}"; do
  [[ -z "${util}" ]] && continue

  eval "export ${util^^}_MOCK=''"

  exp_out="Unavailable or corrupted util: ${util}"
  act_out="$(${TOOL})"
  assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
    "Fail on unavailable or corrupted util: ${util}"

  eval "unset ${util^^}_MOCK"
done
