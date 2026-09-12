#!/usr/bin/env bash
#
# diagnostic.sh
# Assignment 2 - Dockerized Diagnostic CLI
#
# Usage:
#   diagnostic system
#   diagnostic network <host>
#   diagnostic disk
#   diagnostic help
#
# Exit codes:
#   0 - success
#   1 - operational/runtime failure
#   2 - invalid command or invalid/missing input

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/diagnostic.log"

log() {
    mkdir -p "$LOG_DIR" 2>/dev/null || true
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE" 2>/dev/null || true
}

print_help() {
    cat <<EOF
Diagnostic CLI - Assignment 2

Usage:
  diagnostic system            Display Linux system information
  diagnostic network <host>    Check connectivity to <host>
  diagnostic disk               Display disk usage information
  diagnostic help               Display this help message

Exit codes:
  0  success
  1  operational/runtime failure
  2  invalid command or invalid/missing input
EOF
}

cmd_system() {
    echo "===================================="
    echo " System Information"
    echo "===================================="
    echo "Hostname        : $(hostname)"
    echo "Current User    : $(whoami)"
    echo "Date/Time       : $(date '+%Y-%m-%d %H:%M:%S')"

    if [ -f /etc/os-release ]; then
        OS_NAME=$(. /etc/os-release && echo "$PRETTY_NAME")
    else
        OS_NAME=$(uname -s)
    fi
    echo "Operating System: ${OS_NAME}"
    echo "Kernel Version  : $(uname -r)"
    echo "Uptime          : $(uptime -p 2>/dev/null || uptime)"

    echo
    echo "--- CPU Information ---"
    if command -v lscpu >/dev/null 2>&1; then
        lscpu | grep -E 'Model name|CPU\(s\)|Architecture'
    else
        grep -m1 'model name' /proc/cpuinfo 2>/dev/null
        echo "CPU(s): $(grep -c ^processor /proc/cpuinfo 2>/dev/null)"
    fi

    echo
    echo "--- Memory Information ---"
    if command -v free >/dev/null 2>&1; then
        free -h
    else
        grep -E 'MemTotal|MemFree|MemAvailable' /proc/meminfo 2>/dev/null
    fi

    log "system command executed successfully"
    return 0
}

cmd_disk() {
    echo "===================================="
    echo " Disk Information"
    echo "===================================="
    df -h

    log "disk command executed successfully"
    return 0
}

cmd_network() {
    local host="${1:-}"

    if [[ -z "$host" ]]; then
        echo "Error: network command requires a host argument." >&2
        echo "Usage: diagnostic network <host>" >&2
        log "network command failed: missing host argument"
        return 2
    fi

    if ! [[ "$host" =~ ^[A-Za-z0-9.:_-]+$ ]]; then
        echo "Error: '$host' is not a valid hostname or IP address." >&2
        log "network command failed: invalid host format '$host'"
        return 2
    fi

    echo "===================================="
    echo " Network Check: $host"
    echo "===================================="

    local status=0
    local resolved=""

    if command -v getent >/dev/null 2>&1; then
        resolved=$(getent hosts "$host" 2>/dev/null | awk '{print $1}' | head -n1)
    fi

    if [[ -n "$resolved" ]]; then
        echo "Resolved Address: $resolved"
    else
        echo "Resolved Address: could not resolve '$host'"
        status=1
    fi

    if command -v ping >/dev/null 2>&1 && ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
        echo "Connectivity    : REACHABLE"
    else
        echo "Connectivity    : UNREACHABLE"
        status=1
    fi

    log "network command checked '$host' with status $status"
    return "$status"
}

# --- Main dispatch ---
COMMAND="${1:-}"

if [[ -z "$COMMAND" ]]; then
    echo "Error: a command is required." >&2
    print_help >&2
    log "diagnostic.sh failed: missing command"
    exit 2
fi

case "$COMMAND" in
    system)
        cmd_system
        exit $?
        ;;
    disk)
        cmd_disk
        exit $?
        ;;
    network)
        shift
        cmd_network "${1:-}"
        exit $?
        ;;
    help|-h|--help)
        print_help
        exit 0
        ;;
    *)
        echo "Error: unknown command '$COMMAND'." >&2
        print_help >&2
        log "diagnostic.sh failed: unknown command '$COMMAND'"
        exit 2
        ;;
esac