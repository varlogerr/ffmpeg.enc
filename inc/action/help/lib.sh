#
# https://stackoverflow.com/questions/36495669/difference-between-terms-option-argument-and-parameter
# Definition by example:
# `grep -e '<ptn>' -F <file>`
# where:
# * `grep -e <ptn> -F -- <file>` - each element is an argument
# * `-e <ptn>` - option with option parameter
# * `-F` - flag, option without parameter
# * `--` - explicit end of options
# * `<file>` - positional parameter
#

print_help_help() {
  print_help_usage
  echo
  print_help_opts
  echo
  print_help_presets
  echo
  print_help_demo
}

print_help_usage() {
  _print "
    USAGE
    =====
    \`\`\`sh
    # encode:
    ${KEEPER[tool]} SOURCE DEST [-p PRESET] [-f CONFFILE...] \\
   !  [--before BEFORE_HOOK...] [--after AFTER_HOOK...]
   !
    # view encoding settings (base and for preset):
    ${KEEPER[tool]} --genconf [PRESET]
   !
    # info options:
    ${KEEPER[tool]} -h|--usage|--opt|--presets|--demo
   !
    # version:
    ${KEEPER[tool]} -v
    \`\`\`
  "
}

print_help_presets() {
  _print "
    PRESETS
    =======
  "
  sed -E 's/^/* /' <<< "${KEEPER[presets]}"
}

print_help_opts() {
  _print "
    OPTIONS
    =======
    --              End of options
    -p, --preset    Encoding preset, see PRESETS section
    -f, --conffile  Use configuration file
    --before        Before encode video hook
    --after         After encode video hook
    --genconf       Generate conffile
    -h, -?, --help  (flag) Print full help
    --usage         (flag) Print usage help
    --opt, --opts   (flag) Print options help
    --presets       (flag) Print presets help
    --demo          (flag) Print demo help
    -v, --version   (flag) Print version
  "
}

print_help_demo() {
  _print "
    DEMO
    ====
    \`\`\`sh
    # generate conffile to stdout
    ${KEEPER[tool]} --genconf
    !
    # generate \`screen720p\` preset conffile to stdout
    ${KEEPER[tool]} --genconf screen720p
    !
    # \`./vid.mp4\` to \`./enc.mkv\` with default
    # settings and with \`screen720p\` preset
    ${KEEPER[tool]} vid.mp4 enc.mkv
    ${KEEPER[tool]} vid.mp4 enc720p.mkv -p screen720p
    !
    # all vids from \`./vids\` to \`./enc/<vid-name>.mkv\`
    ${KEEPER[tool]} ./vids ./enc
    \`\`\`
    !
    Hooks are triggered for before or after encoding of
    each file. They are populated with variables:
    \`SOURCE\`, \`DEST\`, \`SOURCE_BASEDIR\` and \`DEST_BASEDIR\`
    !
    \`\`\`sh
    # create a hook
    {
   !  echo '# you can do something useful with these vars'
   !  echo 'echo \"src file path: \${SOURCE}\"'
   !  echo 'echo \"dest file path: \${DEST}\"'
   !  echo 'echo \"src directory path: \${SOURCE_BASEDIR}\"'
   !  echo 'echo \"dest directory path: \${DEST_BASEDIR}\"'
    } > ./myhook.sh
   !
    # will print paths before encoding
    ${KEEPER[tool]} v.mp4 e.mkv --before ./myhook.sh
    # will print paths after encoding
    ${KEEPER[tool]} v.mp4 e.mkv --after ./myhook.sh
    \`\`\`
  "
}

_print() {
  local lines="${1}"
  local line_symbol="${2:-!}"

  while read -r line; do
    [[ -z "${line}" ]] && continue

    [[ "${line:0:1}" == "${line_symbol}" ]] \
      && line="${line:1}"

    printf -- '%s\n' "${line}"
  done <<< "${lines}"
}
