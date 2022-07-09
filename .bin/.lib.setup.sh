UTILDIR="$(realpath "${BINDIR}/..")"
VENDORDIR="${UTILDIR}/vendor"
VENDOR_BINDIR="${VENDORDIR}/.bin"

read_vendor_conf() {
  declare -n vendors="${1}"
  local conffile="${2:-$(pwd)/.setup.conf}"

  local name
  local url

  while read -r tool_info; do
    [[ -z "${tool_info}" ]] && continue

    name="$(cut -d= -f1 <<< "${tool_info}=")"
    url="$(cut -d= -f2 <<< "${tool_info}=")"

    vendors[${name}]="${url}"
  done <<< "$(
    grep -E '^\s*vendor\.[^=]+=' "${conffile}" \
    | sed -E -e 's/^\s*vendor\.//' -e 's/\s*=\s*/=/' \
    | grep -oE '^[^# ]+'
  )"
}

install_vendors() {
  declare -n vendors="${1}"
  local vendordir="${2}"

  local default_ver=master
  local tool_name
  local tool_ver
  local tool_repo
  local tool_dir

  for tool in "${!VENDORS[@]}"; do
    tool_name="$(cut -d'@' -f1 <<< "${tool}@")"
    tool_ver="$(cut -d'@' -f2 <<< "${tool}@")"
    tool_ver="${tool_ver:-${default_ver}}"
    tool_repo="${VENDORS[${tool}]}"
    tool_dir=$(realpath -m "${vendordir}/${tool_name}")

    echo ">>> Installing ${tool_name}@${tool_ver} to ${tool_dir} ..."

    mkdir -p "${tool_dir}" 2> /dev/null || {
      echo "Error creating directory: ${tool_dir}" >&2
      exit 1
    }
    cd "${tool_dir}" 2> /dev/null || {
      echo "Error changing to directory: ${tool_dir}" >&2
      exit 1
    }

    # before destructive actions some additional precaution
    [[ (
      "${tool_dir#*${vendordir}}" == "${tool_dir}" \
      || "$(pwd)" != "${tool_dir}"
    ) ]] && {
      echo "Not in vendor directory: ${tool_dir}" >&2
      exit 1
    }

    # check if the directory is tester repo
    git_top_level="$(git rev-parse --show-toplevel 2> /dev/null)"
    [[ "${git_top_level}" != "${tool_dir}" ]] && {
      # ensure directory is empty
      echo "Cleaning the directory"
      rm -rf ./* ./.* 2> /dev/null
      git clone "${tool_repo}" .
    }

    git checkout master
    # -p and -P for pruning non-existing remotely
    # references and tags
    git fetch -p -P -f
    git reset origin/master --hard
    # remove untracked files
    git clean -f -d -X
    git checkout -q "${tool_ver}"

    [[ -n "$(ls "${tool_dir}/bin" 2> /dev/null)" ]] && {
      # configure vendor bin directory
      mkdir -p "${vendordir}/.bin"
      cd "${vendordir}/.bin"
      ln -sf "${tool_dir}/bin"/* .
    }

    echo ">>> Done installing ${tool_name}@${tool_ver} to ${tool_dir} ..."

    if [[ "$(type -t vendor_post_install)" == 'function' ]]; then
      vendor_post_install "${tool_name}" "${tool_dir}"
    fi
  done
}
