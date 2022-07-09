declare RC_OK=0
declare RC_ERR=1
declare exp_out
declare act_out
declare version_rex='^v([0-9]+\.){2}[0-9]+$'

for f in ${GLOB_OPTKEYS[version]}; do
  ${TOOL} "${f}" | grep -qE "${version_rex}"
  assert_result "${RC_OK}" "${?}" "" "" \
    "Print matching pattern version (${f})"

  exp_out="$(mk_input_err "Invalid argument: --${GLOB_RANDVAL}")"
  act_out="$(${TOOL} "${f}" "--${GLOB_RANDVAL}")"
  assert_result "${RC_ERR}" "${?}" "${exp_out}" "${act_out}" \
    "Fails on invalid extra argument ($f)"
done
