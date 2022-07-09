declare RC_OK=0
declare RC_ERR=1
declare exp_out_ok
declare exp_out_err
declare act_out

declare flags
for t in "${!HELP_TXT[@]}"; do
  exp_out_ok="${HELP_TXT[$t]}"
  exp_out_err="$(mk_input_err "Invalid argument: --${GLOB_RANDVAL}")"
  for flag in ${GLOB_OPTKEYS[$t]}; do
    act_out="$(${TOOL} ${flag})"
    assert_result "${RC_OK}" "$?" "${exp_out_ok}" "${act_out}" \
      "Print help: ${flag}"

    act_out="$(${TOOL} "${flag}" --${GLOB_RANDVAL})"
    assert_result "${RC_ERR}" "$?" "${exp_out_err}" "${act_out}" \
      "Help fails on extra argument: ${flag} --${GLOB_RANDVAL}"
  done
done
