#!/usr/bin/env bash

BINDIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

. "${BINDIR}/.lib.setup.sh"

declare -A VENDORS=()

vendor_post_install() {
  # not really needed, but just in case
  local tool="${1}"
  local tooldir="${2}"
  local proddir="${VENDORDIR}/.prod"
  local tooldir_prod="${proddir}/$(basename "${tooldir}")"

  mkdir -p "${tooldir_prod}"
  find "${tooldir}" -mindepth 1 -maxdepth 1 \
    ! -name '.*' -exec cp -r {} "${tooldir_prod}" \;
}

read_vendor_conf VENDORS "${UTILDIR}/.setup-prod.conf"
install_vendors VENDORS "${VENDORDIR}"
