#!/usr/bin/env bash
#
# health-check.sh
# Assignment 2 - Dockerized Diagnostic CLI
#
# Lightweight self-check used by Docker's HEALTHCHECK instruction to confirm
# the diagnostic tool inside the container is actually functional, not just
# that the container process is running.
#
# Exit codes:
#   0 - healthy (diagnostic.sh responds correctly)
#   1 - unhealthy

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -x "${SCRIPT_DIR}/diagnostic.sh" ]]; then
    echo "UNHEALTHY: diagnostic.sh not found or not executable"
    exit 1
fi

if "${SCRIPT_DIR}/diagnostic.sh" help >/dev/null 2>&1; then
    echo "HEALTHY: diagnostic.sh is responding"
    exit 0
else
    echo "UNHEALTHY: diagnostic.sh did not respond as expected"
    exit 1
fi