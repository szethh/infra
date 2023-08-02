#!/bin/bash

ansible-galaxy install -r requirements.yml
echo "Ansible Galaxy roles & collections installed"
./git-init.sh
echo "Ansible vault git pre-commit hook installed"

read -p "Add Ansible Vault Password: " pass
if [ -d / ]; then
rm .vault-password
cat <<EOT >> .vault-password
$pass
EOT

fi

chmod 0600 .vault-password