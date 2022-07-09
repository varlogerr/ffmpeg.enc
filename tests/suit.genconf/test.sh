declare RC_OK=0
declare RC_ERR=1
declare exp_out
declare act_out

exp_out="${BASECONF_TXT}"
act_out="$(${TOOL} --genconf)"
assert_result "${RC_OK}" $? "${exp_out}" "${act_out}" \
  "Generate base conffile"

exp_out="$(mk_input_err "Invalid PRESET: ${GLOB_RANDVAL}")"
act_out="$(${TOOL} --genconf "${GLOB_RANDVAL}")"
assert_result "${RC_ERR}" $? "${exp_out}" "${act_out}" \
  "Fail on invalid PRESET"

exp_out="${SCREEN720PCONF_TXT}"
act_out="$(${TOOL} --genconf screen720p)"
assert_result "${RC_OK}" $? "${exp_out}" "${act_out}" \
  "Generate PRESET conffile"

exp_out="$(mk_input_err "Invalid argument: ${GLOB_RANDVAL}")"
act_out="$(${TOOL} --genconf screen720p "${GLOB_RANDVAL}")"
assert_result "${RC_ERR}" $? "${exp_out}" "${act_out}" \
  "Fail on invalid argument"
