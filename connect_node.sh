#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: connect_node.sh [-l|--list] HOST CMD [ARGS ...]

Run CMD inside the Mininet namespace for HOST.

Options:
  -l, --list  Print the known host names and exit
  -h, --help  Show this help message

Example:
  connect_node.sh R1 vtysh -c 'show ip route'
EOF
}

discover_hosts() {
  ps -eo args |
    sed -n -E '/^bash.* mininet:([[:alnum:]_.-]+)$/s/^bash.* mininet:([[:alnum:]_.-]+)$/\1/p' |
    sort -u
}

list_hosts() {
  local found=0

  while IFS= read -r host; do
    printf '%s\n' "$host"
    found=1
  done < <(discover_hosts)

  if (( found == 0 )); then
    echo "No Mininet hosts detected." >&2
  fi
}

host_known() {
  local target=$1
  if discover_hosts | grep -Fxq "$target"; then
    return 0
  fi
  return 1
}

require_mnexec() {
  if ! command -v mnexec >/dev/null 2>&1; then
    echo "mnexec not found in PATH; install Mininet or ensure mnexec is available." >&2
    exit 3
  fi
}

get_host_pid() {
  local host=$1
  local pid

  pid=$(pgrep -f -n -- "bash.* mininet:${host}$" || true)
  if [[ -z $pid || ! $pid =~ ^[0-9]+$ ]]; then
    echo "Unable to locate PID for host '${host}'. Is it running?" >&2
    exit 2
  fi

  printf '%s' "$pid"
}

main() {
  if [[ $# -eq 0 ]]; then
    usage
    exit 1
  fi

  case $1 in
    -l|--list)
      list_hosts
      return 0
      ;;
    -h|--help)
      usage
      return 0
      ;;
  esac

  if [[ $# -lt 2 ]]; then
    echo "Missing HOST or CMD." >&2
    usage
    exit 1
  fi

  local host=$1
  shift

  if ! host_known "$host"; then
    echo "Warning: host '${host}' is not in the known host list." >&2
  fi

  require_mnexec
  local host_pid
  host_pid=$(get_host_pid "$host")

  mnexec -a "$host_pid" "$@"
}

main "$@"
