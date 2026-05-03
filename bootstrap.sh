#!/usr/bin/env bash

if ! command -v curl &> /dev/null; then
  echo "curl is needed"
  exit 1
fi

readonly URL="https://hydra.nixos.org/job/nix/master/buildStatic.nix-cli.x86_64-linux/latest/download"

readonly XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

readonly NIXENV_CONFIG="${XDG_CONFIG_HOME}/nixenv"

TMPFILE="$(mktemp -t 'nixStatic.XXX')"
readonly TMPFILE

curl -L "${URL}" --output "${TMPFILE}"

chmod +x "${TMPFILE}"

"${TMPFILE}" \
  --extra-experimental-features "nix-command flakes" \
  run \
  "${NIXENV_CONFIG}#nixenv-rebuild"

rm "${TMPFILE}"
