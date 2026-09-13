# Assignment 2 - Dockerized Diagnostic CLI
#
# Lightweight Alpine-based image. Only the packages the CLI actually needs
# are installed: bash (the CLI is written in bash, not POSIX sh), coreutils
# (GNU-compatible date/uname/df/whoami/hostname behavior), procps (real
# `free` and `uptime`), util-linux (`lscpu`), and iputils (`ping`, used by
# the network subcommand).

FROM alpine:3.20

RUN apk add --no-cache \
        bash \
        coreutils \
        procps \
        util-linux \
        iputils

COPY app/ /app/

RUN chmod +x /app/diagnostic.sh /app/health-check.sh

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD ["/app/health-check.sh"]

ENTRYPOINT ["/app/diagnostic.sh"]
CMD ["help"]