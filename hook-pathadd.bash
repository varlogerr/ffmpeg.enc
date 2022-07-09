[[ -n "${BASH_VERSION}" ]] && {
  __iife() {
    unset __iife
    local projdir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

    [[ "$(type -t pathadd.append)" != 'function' ]] && return

    FFMPEG_ENC_BINDIR="${FFMPEG_ENC_BINDIR:-${projdir}/bin}"
    [[ -z "$(bash -c 'echo ${FFMPEG_ENC_BINDIR+x}')" ]] \
      && export FFMPEG_ENC_BINDIR

    pathadd.append "${FFMPEG_ENC_BINDIR}"
  } && __iife
}
