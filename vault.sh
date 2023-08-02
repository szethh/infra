#!/bin/sh

if bw unlock --check --session "$(cat /tmp/bw.token)" | grep -q 'Vault is unlocked!' ; then
    bw get password vault-infra --session "$(grep '^' /tmp/bw.token)"
else
    bw unlock --raw > /tmp/bw.token
    bw get password vault-infra --session "$(grep '^' /tmp/bw.token)"
fi