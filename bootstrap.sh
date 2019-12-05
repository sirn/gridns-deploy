#!/bin/sh
#
# Bootstrap Ansible
#

BASE_DIR=$(cd "$(dirname "$0")/" || exit; pwd -P)

INVENTORY_FILE="$BASE_DIR/inventory.yml"
REQUIREMENTS_FILE="$BASE_DIR/requirements.yml"
PLAYBOOK_FILE="$BASE_DIR/playbook.yml"

PLAYBOOK_BIN="ansible-playbook"
GALAXY_BIN="ansible-galaxy"

if [ ! "$PLAYBOOK_BIN" ] || [ ! "$GALAXY_BIN" ]; then
    echo "No suitable Ansible versions found."
    exit 1
fi

case "$UPDATE_GALAXY" in
    1 | y* | Y* | t* | T* )
        if ! "$GALAXY_BIN" install -f -r "$REQUIREMENTS_FILE"; then
            printf "Cannot install Galaxy roles.\\n"
            exit 1
        fi
        ;;

    * )
        ;;
esac

if ! command -v pass >/dev/null; then
    printf "Pass is required to be installed.\\n"
    exit 1
fi

_temp="$(mktemp -d)"
_fifo="$_temp/fifo"
trap 'rm -f $_fifo && rmdir $_temp' 0 1 2 3 6 14 15

mkfifo "$_fifo"
pass Ansible/gridns.xyz > "$_fifo" &

exec \
    env ANSIBLE_CONFIG="$BASE_DIR/ansible.cfg" \
    "$PLAYBOOK_BIN" \
        "$PLAYBOOK_FILE" \
        --user=freebsd \
        --inventory "$INVENTORY_FILE" \
        --vault-password-file="$_fifo" \
        --ssh-common-args "-o StrictHostKeyChecking=no" \
        "$@"
