#!/bin/sh

_base_dir=$(cd "$(dirname "$0")/" || exit; pwd -P)

_inventory_file="$_base_dir/hosts.yml"
_requirements_file="$_base_dir/requirements.yml"
_playbook_file="$_base_dir/playbook.yml"


## Prepare
##

# FreeBSD uses `ansible-playbook-{PYVER}` for Python bins.
for v in "" "-2.7" "-3.6" "-3.7"; do
    if hash "ansible$v" 2>/dev/null; then
        _ansible_playbook="ansible-playbook$v"
        _ansible_galaxy="ansible-galaxy$v"
        break
    fi
done

if [ ! "$_ansible_playbook" ] || [ ! "$_ansible_galaxy" ]; then
    printf "No known Ansible versions found.\\n"
    exit 1
fi

if ! hash pass 2>/dev/null; then
    printf "Pass is required to be installed.\\n"
    exit 1
fi

case "$FORCE_UPDATE_GALAXY" in
    1 | y* | Y* | t* | T* )
        _ansible_galaxy_args="--force";;
    * )
        _ansible_galaxy_args="";;
esac


## Main
##

if ! "$_ansible_galaxy" install $_ansible_galaxy_args -r "$_requirements_file"; then
    printf "Cannot install Galaxy roles.\\n"
    exit 1
fi

pass Ansible/gridns.xyz |
    exec \
        env ANSIBLE_CONFIG="$_base_dir/ansible.cfg" \
        "$_ansible_playbook" \
        "$_playbook_file" \
        -i "$_inventory_file" \
        --user=freebsd \
        --vault-password-file=/dev/stdin \
        --ssh-common-args="-o StrictHostKeyChecking=no" \
        "$@"
