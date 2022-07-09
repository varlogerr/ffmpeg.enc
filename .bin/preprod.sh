#!/usr/bin/env bash

BINDIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
TOOLDIR="$(realpath "${BINDIR}/..")"
TOOLPATH="${TOOLDIR}/bin/vencoder.sh"

RELEASE_TYPE="${1}"

# new version
declare VERSION

declare -A RELEASE_TYPE_MAP=(
  [patch]=3
  [minor]=2
  [major]=1
)
RELEASE_TYPES_LIST="$(
  tr ' ' '\n' <<< "${!RELEASE_TYPE_MAP[@]}" \
  | sort -n
)"

print_err() {
  local msg="${1}"

  {
    echo "${msg}"
    echo "Supported types:"
    sed 's/^/* /' <<< "${RELEASE_TYPES_LIST}"
    echo
    echo "USAGE"
    echo '```sh'
    echo "$(basename "${BASH_SOURCE[0]}") RELEASE_TYPE"
    echo '```'
  } >&2
}

[[ -z ${RELEASE_TYPE} ]] && {
  print_err "Release type is required!"
  exit 1
} >&2

! grep -qFx "${RELEASE_TYPES_LIST}" <<< "${RELEASE_TYPE}" && {
  print_err "Invalid release type!"
  exit 1
}

__get_version() {
  unset __get_version

  echo ">>> Getting current version ..."

  local currver_line
  local currver_rex='^declare TOOL_VERSION=v([0-9]+\.){2}[0-9]+$'
  local currver
  local segment
  local segment_no=${RELEASE_TYPE_MAP[$RELEASE_TYPE]}

  # detect current version
  currver_line="$(grep -E "${currver_rex}" "${TOOLPATH}")"
  [[ $? -gt 0 ]] && {
    echo "Can't detect current version line!" >&2
    return 1
  }
  currver="$(cut -d'=' -f2 <<< "${currver_line}" | sed 's/^v//')"

  # get required segment
  segment="$(cut -d'.' -f${segment_no} <<< "${currver}")"

  # increment and put into variable
  VERSION="v$(sed -E -e "s/[0-9]+/$(( segment + 1 ))/${segment_no}" \
    -e "s/[0-9]+/0/$(( segment_no + 1 ))g" <<< "${currver}")"
} && __get_version || exit 1

__check_changes() {
  unset __check_changes

  echo ">>> Checking for uncommited changes ..."
  if [[ -n  "$(git status --porcelain)" ]]; then
    echo "Uncommited changes detected!" >&2
    return 1
  fi
} && __check_changes || exit 1

__setup_dev() {
  unset __setup_dev

  echo ">>> Configuring dev environment ..."
  "${BINDIR}/setup-dev.sh"
} && __setup_dev || exit 1

__set_version() {
  unset __set_version

  local retver

  local currver_rex='^(declare TOOL_VERSION=)v([0-9]+\.){2}[0-9]+$'
  echo ">>> Updating version ..."

  sed -E -i "s/${currver_rex}/\1${VERSION}/" "${TOOLPATH}"
  retver="$("${TOOLPATH}" --version)"
  if [[ ($? -gt 0 || "${retver}" != "${VERSION}") ]]; then
    echo "Couldn't update version!" >&2
    return 1
  fi
} && __set_version || exit 1

__run_tests() {
  unset __run_tests

  echo ">>> Runnint tests ..."
  export TESTDIR="${TOOLDIR}/tests"
  "${TOOLDIR}/vendor/.bin/tester.sh" run
} && __run_tests || exit 1

__commit_and_tag() {
  unset __commit_and_tag

  local print_version="Version: $(sed 's/^v//' <<< "${VERSION}")"

  echo ">>> Commiting ..."
  git add .
  git commit -m "Release: ${VERSION}"
  if [[ $? -gt 0 ]]; then return 1; fi

  echo ">>> Tagging with ${VERSION} ..."
  git tag -a "${VERSION}" -m "${print_version}"
  if [[ $? -gt 0 ]]; then return 1; fi
} && __commit_and_tag

__print_postmsg() {
  unset __print_postmsg

  while read -r l; do
    [[ -n "${l}" ]] && printf -- '%s\n' "${l}"
  done <<< "
    ######################
    ##### POST STEPS #####
    ######################
    Run the following commands to complete the release:
    \`\`\`sh
    git push
    git push origin ${VERSION}
    \`\`\`
  "
} && __print_postmsg
