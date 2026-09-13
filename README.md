# Assignment 2 — Dockerized Diagnostic CLI

A Bash-based diagnostic CLI, packaged as a Docker image, providing system
information, disk usage, and basic network checks through a single
`diagnostic` command with subcommands.

## Contents

- `app/diagnostic.sh` — the CLI itself (`system`, `network <host>`, `disk`, `help`).
- `app/health-check.sh` — lightweight self-check used by Docker's `HEALTHCHECK`.
- `Dockerfile` — builds a lightweight Alpine-based image around the CLI.
- `compose.yaml` — runs the CLI locally via Docker Compose.
- `.dockerignore` — excludes `.git`, logs, and local/temp files from the build context.
- `test.sh` — functional tests against the built Docker image.
- `grade.sh` — instructor-supplied local grading script.

## Installation / Setup

Requires Docker (Docker Desktop on Mac/Windows, or the Docker Engine on Linux).

```bash
git clone <this-repository-url>
cd assignment-2
chmod +x app/*.sh test.sh
docker build -t diagnostic-tool .
```

## Usage

**Direct Docker run:**
```bash
docker run --rm diagnostic-tool help
docker run --rm diagnostic-tool system
docker run --rm diagnostic-tool disk
docker run --rm diagnostic-tool network example.com
```

**Via Docker Compose:**
```bash
docker compose run --rm diagnostic system
docker compose run --rm diagnostic disk
docker compose run --rm diagnostic help
```

**Exit codes:**
- `0` — success
- `1` — operational/runtime failure (e.g. host unreachable)
- `2` — invalid command or invalid/missing input (unknown subcommand, missing host)

## Testing

Run the project's own test suite, which builds a throwaway image and checks
`help`, `system`, `disk`, and invalid-command handling:
```bash
./test.sh
```

Run the instructor-supplied grader, which covers project structure, syntax,
the Dockerfile, `.dockerignore`, image build, functional container tests,
Compose validation, and the test suite above:
```bash
chmod +x grade.sh
./grade.sh
```

## Assumptions

- Docker (with Compose v2, i.e. `docker compose`, not the older standalone
  `docker-compose`) is installed and running before any of these commands
  are used.
- The base image is Alpine Linux; package names/behavior assume `apk`, not
  `apt`/`yum`.
- The `network` subcommand's connectivity check depends on the container
  having outbound network access; DNS resolution inside the container
  depends on the host's Docker network configuration.
- No secrets, credentials, or environment-specific values are required to
  build or run the image.