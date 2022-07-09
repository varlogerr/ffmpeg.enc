declare RC_OK=0
declare RC_ERR=1
declare act_out
declare exp_out

exp_out="$(mk_input_err "SOURCE is required"$'\n'"DEST is required")"
act_out="$(${TOOL})"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on SOURCE and DEST is required"

exp_out="$(mk_input_err "DEST is required")"
act_out="$(${TOOL} "${MOCKSRC_FILE}")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on DEST is required"

exp_out="$(mk_input_err "Unreachable SOURCE: ${MEDIADIR}/${GLOB_RANDVAL}.txt")"
act_out="$(${TOOL} "${MEDIADIR}/${GLOB_RANDVAL}.txt" "${MOCKDEST_FILE}")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on unreachable SOURCE"

exp_out="$(mk_input_err "Unsupported 'image/jpeg' mime for SOURCE: ${MEDIADIR}/mess/img1.txt")"
act_out="$(${TOOL} "${MEDIADIR}/mess/img1.txt" "${MOCKDEST_FILE}")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on unsupported mime for SOURCE"

exp_out="$(mk_input_err "Unsupported SOURCE: /dev/null")"
act_out="$(${TOOL} "/dev/null" "${MOCKDEST_FILE}")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on unsupported SOURCE"

exp_out="$(mk_input_err "DEST file already exists: ${MOCKSRC_FILE}")"
act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKSRC_FILE}")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on DEST file already exists (file encode)"

for f in -vid.txt --vid.txt; do
  exp_out="$(mk_input_err "Invalid option: ${f}")"
  act_out="$(cd "${MEDIADIR}"; ${TOOL} "${f}" "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
  assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
    "Fail on \`-\` prefixed SOURCE: ${f}"
done

exp_out="Can't create destination directory $(dirname ${MOCKDEST_FILE})"
act_out="$(MKDIR_FAILS='' ${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
  "Pinrt error on can't create destination directory"

set_enc_opts ENC_OPTS
exp_out="$(mk_enc_cmd ENC_OPTS "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
  "Encode SOURCE file"

for f in -vid.txt --vid.txt; do
  exp_out="$(mk_enc_cmd ENC_OPTS "${MEDIADIR}/${f}" "${MOCKDEST_FILE}")"
  act_out="$(cd "${MEDIADIR}"; ${TOOL} -- "${f}" "${MOCKDEST_FILE}")"
  assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
    "Encode \`-\` prefixed SOURCE file after \`--\`: ${f}"
done

for f in -${GLOB_RANDVAL}.txt --${GLOB_RANDVAL}.txt; do
  exp_out="$(mk_enc_cmd ENC_OPTS "${MOCKSRC_FILE}" "${MEDIADIR}/${f}")"
  act_out="$(cd "${MEDIADIR}"; ${TOOL} "${MOCKSRC_FILE}" -- "${f}")"
  assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
    "Encode with \`-\` prefixed DEST after \`--\`: ${f}"
done

exp_out="$(mk_input_err "Unsupported DEST: /dev/null")"
act_out="$(${TOOL} "${MOCKSRC_DIR}" "/dev/null")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on unsupported DEST"

exp_out="$(mk_input_err "Can't encode SOURCE directory to DEST file: ${MOCKSRC_DIR} -> ${MOCKSRC_FILE}")"
act_out="$(${TOOL} "${MOCKSRC_DIR}" "${MOCKSRC_FILE}")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on can't encode SOURCE directory to DEST file"

exp_out="$(mk_input_err "DEST file already exists: ${MOCKSRC_DIR}/vid2.mkv")"
act_out="$(${TOOL} "${MOCKSRC_DIR}/sub" "${MOCKSRC_DIR}")"
assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
  "Fail on DEST file already exists (directory encode)"

exp_out="$(mk_enc_cmd ENC_OPTS "${MEDIADIR}/mess" "${MEDIADIR}/${GLOB_RANDVAL}")"
act_out="$(${TOOL} "${MEDIADIR}/mess" "${MEDIADIR}/${GLOB_RANDVAL}")"
assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
  "Encode SOURCE directory to non-existing DEST directory"

exp_out="$(mk_enc_cmd ENC_OPTS "${MEDIADIR}/mess" "${MEDIADIR}")"
act_out="$(${TOOL} "${MEDIADIR}/mess" "${MEDIADIR}")"
assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
  "Encode SOURCE directory to existing DEST directory"

exp_out=""
act_out="$(${TOOL} "${MEDIADIR}/empty" "${MEDIADIR}/${GLOB_RANDVAL}")"
assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
  "Encode empty SOURCE directory"
