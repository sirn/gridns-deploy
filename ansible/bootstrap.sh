#!/usr/bin/env bash
BASE_DIR=$(cd "$(dirname "$0")/../" || exit; pwd -P)
PLAYBOOK_FILE="${BASE_DIR}/ansible/playbook.yml"
HOST_FILE="${BASE_DIR}/terraform/terraform.py"

export ANSIBLE_CONFIG="${BASE_DIR}/ansible/ansible.cfg"
ansible-playbook "${PLAYBOOK_FILE}" -i "${HOST_FILE}" --ssh-common-args "-o StrictHostKeyChecking=no" "$@"
