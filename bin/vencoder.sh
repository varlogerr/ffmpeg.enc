#!/usr/bin/env bash

declare RETVAL
declare -a ERRBAG=()

# don't modify manually
declare TOOL_VERSION=v0.0.1

declare -A KEEPER=(
  [tool]="$(basename "${BASH_SOURCE[0]}")"
  [bindir]="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
)
KEEPER[tooldir]="$(realpath "${KEEPER[bindir]}/..")"
KEEPER[vendordir]="${KEEPER[tooldir]}/vendor"
KEEPER[incdir]="${KEEPER[tooldir]}/inc"

. "${KEEPER[vendordir]}/.prod/sh.lib/sh.lib.sh"
. "${KEEPER[incdir]}/init.sh"

KEEPER+=(
  [commondir]="${KEEPER[incdir]}/common"
  [presdir]="${KEEPER[tooldir]}/presets"
)
KEEPER[presets]="$(
  find "${KEEPER[presdir]}" -type f -name '*.conf' ! -name '_*' \
  | rev | cut -d'/' -f1 | rev | sed 's/\.conf$//' | sort -n
)"

. "${KEEPER[incdir]}/opts.sh"
. "${KEEPER[incdir]}/run.sh"
