declare RC_OK=0
declare RC_ERR=1
declare exp_out
declare act_out

exp_out="$(mk_input_err "Unreachable BEFORE hook: ${HOOKDIR}/${GLOB_RANDVAL}.sh")"
act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
  --before "${HOOKDIR}/${GLOB_RANDVAL}.sh")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on unreachable BEFORE hook"

exp_out="$(mk_input_err "Unreachable AFTER hook: ${HOOKDIR}/${GLOB_RANDVAL}.sh")"
act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
  --after "${HOOKDIR}/${GLOB_RANDVAL}.sh")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on unreachable AFTER hook"

{
  export PREENC_TXT
  export POSTENC_TXT
  PREENC_TXT="BEFORE"
  PREENC_TXT+=$'\n'"src: ${MOCKSRC_FILE}"
  PREENC_TXT+=$'\n'"dest: ${MOCKDEST_FILE}"
  PREENC_TXT+=$'\n'"src_basedir: $(dirname "${MOCKSRC_FILE}")"
  PREENC_TXT+=$'\n'"dest_basedir: $(dirname "${MOCKDEST_FILE}")"
  PREENC_TXT+=$'\n'"before2"
  POSTENC_TXT="AFTER"
  POSTENC_TXT+=$'\n'"src: ${MOCKSRC_FILE}"
  POSTENC_TXT+=$'\n'"dest: ${MOCKDEST_FILE}"
  POSTENC_TXT+=$'\n'"src_basedir: $(dirname "${MOCKSRC_FILE}")"
  POSTENC_TXT+=$'\n'"dest_basedir: $(dirname "${MOCKDEST_FILE}")"
  POSTENC_TXT+=$'\n'"after2"

  set_enc_opts ENC_OPTS
  exp_out="$(mk_enc_cmd ENC_OPTS "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
    --before "${HOOKDIR}/before1.sh" --before "${HOOKDIR}/before2.sh" \
    --after "${HOOKDIR}/after1.sh" --after "${HOOKDIR}/after2.sh")"
  assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
    "Encode with multiple hooks"

  unset PREENC_TXT POSTENC_TXT
}

{
  export PREENC_TXT
  export POSTENC_TXT
  PREENC_TXT="before2"
  POSTENC_TXT="after2"

  set_enc_opts ENC_OPTS
  exp_out="$(mk_enc_cmd ENC_OPTS "${MEDIADIR}/mess/sub" "${MEDIADIR}")"
  act_out="$(${TOOL} "${MEDIADIR}/mess/sub" "${MEDIADIR}" \
    --before "${HOOKDIR}/before2.sh" \
    --after "${HOOKDIR}/after2.sh")"
  assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
    "Encode batch with before and after hook"

  unset PREENC_TXT POSTENC_TXT
}
