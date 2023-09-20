export PATH := justfile_directory() + "/env/bin:" + env_var("PATH")

# Recipes
@default:
  just --list

### Run/Builds
build_proxmox:
    ansible-playbook -b proxmox.yml --limit pve -c paramiko

build +HOST:
    ansible-playbook -b run.yml --limit {{ HOST }} -c paramiko

build_all:
    ansible-playbook -b run.yml -c paramiko


configure +HOST:
    ansible-playbook -b services.yml --limit {{ HOST }} -c paramiko

### Updates
# update:
#     ansible-playbook update.yml

# docker:
#     ansible-playbook docker.yml

# test:
#     ansible-playbook -b test.yml

### Vault
decrypt:
    ansible-vault decrypt vars/vault.yml

encrypt:
    ansible-vault encrypt vars/vault.yml

### Lint
yamllint:
    yamllint -s .

ansible-lint: yamllint
    #!/usr/bin/env bash
    ansible-lint .
    ansible-playbook run.yml --syntax-check

### Bootstrap/Setup
bootstrap_lxc:
    ansible-playbook -b bootstrap.yml --limit lxc ambition

bootstrap +HOST:
    ansible-playbook -b bootstrap.yml --limit {{ HOST }} --ask-pass --ask-become-pass

install:
    @chmod +x prereqs.sh git-init.sh
    @./prereqs.sh
    @echo "Ansible Vault pre-hook script setup and vault password set"