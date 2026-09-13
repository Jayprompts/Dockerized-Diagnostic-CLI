#!/usr/bin/env bash
#
# test.sh
# Assignment 2 - Dockerized Diagnostic CLI
#
# Builds the Docker image and runs functional tests against it, covering
# help, system, disk, and invalid-command handling.

set -u

IMAGE="diagnostic-tool-test"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "======================================="
echo " Assignment 2 - Docker Image Tests"
echo "======================================="

echo "Building image..."
if ! docker build -t "$IMAGE" . >/tmp/assignment2-test-build.log 2>&1; then
    echo "Docker build failed:"
    cat /tmp/assignment2-test-build.log
    exit 1
fi
pass "Docker image builds successfully"

run_case() {
    local desc="$1"
    shift
    if docker run --rm "$IMAGE" "$@" >/tmp/assignment2-test-run.log 2>&1; then
        pass "$desc"
    else
        fail "$desc"
        cat /tmp/assignment2-test-run.log
    fi
}

run_case "help command works" help
run_case "system command works" system
run_case "disk command works" disk

if docker run --rm "$IMAGE" invalid-command >/tmp/assignment2-test-run.log 2>&1; then
    fail "invalid command should have failed but returned success"
else
    pass "invalid command correctly returns non-zero"
fi

docker image rm "$IMAGE" >/dev/null 2>&1 || true

echo "======================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================="

[[ $FAIL -eq 0 ]]