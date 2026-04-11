#!/bin/sh
# Executed by ly before launching the session (login_cmd in config.ini).
# Environment variables set here persist into the session.
# Must end with exec "$@" to actually launch the session.

# Source /etc/environment for GPU configuration (Intel iGPU for Wayland)
# set -a exports all sourced variables automatically
if [ -f /etc/environment ]; then
  set -a
  . /etc/environment
  set +a
fi

exec "$@"
