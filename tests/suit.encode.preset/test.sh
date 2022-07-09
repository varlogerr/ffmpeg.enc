local RC_OK=0
local RC_ERR=1
local exp_out
local act_out

exp_out="$(mk_input_err "Invalid PRESET: ${GLOB_RANDVAL}")"
for f in ${GLOB_OPTKEYS[preset]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" "${f}" "${GLOB_RANDVAL}")"
  assert_result "${RC_ERR}" $? "${exp_out}" "${act_out}" \
    "Fail on invalid PRESET ("${f}")"
done

for p in "${!GLOB_PRESETS[@]}"; do
  set_enc_opts ENC_OPTS "${GLOB_PRESETS[$p]}"
  exp_out="$(mk_enc_cmd ENC_OPTS "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
  for f in ${GLOB_OPTKEYS[preset]}; do
    act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" "${f}" "${p}")"
    assert_result "${RC_OK}" $? "${exp_out}" "${act_out}" \
      "Encode with PRESET: ${f} ${p}"
  done
done
