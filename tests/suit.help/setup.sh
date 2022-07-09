declare -A HELP_TXT
declare -A HELP_TXT+=(
  [usage]="$(
    txt="$(cat "${SUIT_MOCKDIR}/data/help.usage.txt")"
    for key in "${!GLOB_OPTKEYS[@]}"; do
      val="$(cut -d' ' -f1 <<< "${GLOB_OPTKEYS[${key}]}")"
      txt="$(sed "s/{${key}1}/${val}/g" <<< "${txt}")"
    done
    txt="$(sed "s/{TOOL}/${TOOL}/g" <<< "${txt}")"
    printf -- '%s' "${txt}"
  )"
  [opts]="$(
    txt="$(cat "${SUIT_MOCKDIR}/data/help.opts.txt")"
    for key in "${!GLOB_OPTKEYS[@]}"; do
      val="$(sed "s/ /, /g" <<< "${GLOB_OPTKEYS[${key}]}")"
      txt="$(sed "s/{${key}}/${val}/g" <<< "${txt}")"
    done
    printf -- '%s' "${txt}"
  )"
  [presets]="$(
    cat "${SUIT_MOCKDIR}/data/help.presets.txt"
    echo "${!GLOB_PRESETS[@]}" | tr ' ' '\n' | sort -n \
    | while read -r p; do
      echo "* ${p}"
    done
  )"
  [demo]="$(
    txt="$(cat "${SUIT_MOCKDIR}/data/help.demo.txt")"
    for key in "${!GLOB_OPTKEYS[@]}"; do
      val="$(cut -d' ' -f1 <<< "${GLOB_OPTKEYS[${key}]} ")"
      txt="$(sed "s/{${key}1}/${val}/g" <<< "${txt}")"
    done
    txt="$(sed "s/{TOOL}/${TOOL}/g" <<< "${txt}")"
    printf -- '%s' "${txt}"
  )"
)
HELP_TXT[help]="${HELP_TXT[usage]}"
HELP_TXT[help]+=$'\n'$'\n'"${HELP_TXT[opts]}"
HELP_TXT[help]+=$'\n'$'\n'"${HELP_TXT[presets]}"
HELP_TXT[help]+=$'\n'$'\n'"${HELP_TXT[demo]}"
