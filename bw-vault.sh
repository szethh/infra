#!/bin/bash

set -e

# there is a bug in bitwarden
# bw always reports the vault as locked
# although the session is set
# see https://github.com/bitwarden/cli/issues/480
[[ "$(bw unlock --check --quiet)" = *" locked"* ]] && export BW_SESSION="$(bw unlock --raw)"
bw get password vault-infra
