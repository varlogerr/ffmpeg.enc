declare RC_OK=0
declare RC_ERR=1
declare exp_out
declare act_out

exp_out="$(mk_input_err "Unreachable CONFFILE: ${SUIT_MOCKDIR}/data/${GLOB_RANDVAL}.conf")"
for f in ${GLOB_OPTKEYS[conffile]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" "${f}" "${SUIT_MOCKDIR}/data/${GLOB_RANDVAL}.conf")"
  assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
    "Fail on unreachable CONFFILE (${f})"
done

exp_out="$(msg="Unreachable CONFFILE: ${SUIT_MOCKDIR}/data/${GLOB_RANDVAL}1.conf"
  msg+=$'\n'"Unreachable CONFFILE: ${SUIT_MOCKDIR}/data/${GLOB_RANDVAL}2.conf"
  mk_input_err "${msg}")"
for f in ${GLOB_OPTKEYS[conffile]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
    "${f}" "${SUIT_MOCKDIR}/data/${GLOB_RANDVAL}1.conf" \
    "${f}" "${SUIT_MOCKDIR}/data/${GLOB_RANDVAL}2.conf")"
  assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
    "Fail on multiple unreachable CONFFILE (${f})"
done

exp_out="$(mk_input_err "Invalid CONFFILE line: ${GLOB_RANDVAL}")"
for f in ${GLOB_OPTKEYS[conffile]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
    "${f}" "${SUIT_MOCKDIR}/data/bf-line.conf")"
  assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
    "Fail on invalid CONFFILE line (${f})"
done

exp_out="$(mk_input_err "Unsupported CONFFILE key: ${GLOB_RANDVAL}")"
for f in ${GLOB_OPTKEYS[conffile]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
    "${f}" "${SUIT_MOCKDIR}/data/bf-key.conf")"
  assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
    "Fail on unsupported CONFFILE key (${f})"
done

exp_out="$(mk_input_err "Invalid CONFFILE value for me: ${GLOB_RANDVAL}")"
for f in ${GLOB_OPTKEYS[conffile]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
    "${f}" "${SUIT_MOCKDIR}/data/bf-val.conf")"
  assert_result "${RC_ERR}" "$?" "${exp_out}" "${act_out}" \
    "Fail on invalid CONFFILE value (${f})"
done

set_enc_opts ENC_OPTS "crf=5 me=esa"
exp_out="$(mk_enc_cmd ENC_OPTS "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
for f in ${GLOB_OPTKEYS[conffile]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
    "${f}" "${SUIT_MOCKDIR}/data/cf1.conf")"
  assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
    "Encode with CONFFILE (${f})"
done

set_enc_opts ENC_OPTS "crf=5 me=tesa"
exp_out="$(mk_enc_cmd ENC_OPTS "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
for f in ${GLOB_OPTKEYS[conffile]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
    "${f}" "${SUIT_MOCKDIR}/data/cf1.conf" "${f}" "${SUIT_MOCKDIR}/data/cf2.conf")"
  assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
    "Encode with multiple CONFFILEs (${f})"
done

set_enc_opts ENC_OPTS "width=1280 crf=5 me=esa"
exp_out="$(mk_enc_cmd ENC_OPTS "${MOCKSRC_FILE}" "${MOCKDEST_FILE}")"
for f in ${GLOB_OPTKEYS[conffile]}; do
  act_out="$(${TOOL} "${MOCKSRC_FILE}" "${MOCKDEST_FILE}" \
    -p screen720p "${f}" "${SUIT_MOCKDIR}/data/cf1.conf")"
  assert_result "${RC_OK}" "$?" "${exp_out}" "${act_out}" \
    "Encode with preset overriden by CONFFILE (${f})"
done
