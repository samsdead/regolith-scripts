#!/bin/sh

set -eu
: "${HOME:?Set HOME before resetting Regolith configuration.}"

# Record the paths once so deletion uses the same paths as the backup.
set --
for config in "$HOME"/.Xresources.d "$HOME"/.Xresources-regolith* \
              "$HOME"/.config/i3-regolith "$HOME"/.config/i3xrocks; do
    if [ -e "$config" ] || [ -L "$config" ]; then
        set -- "$@" "$config"
    fi
done

if [ "$#" -eq 0 ]; then
    echo "No Regolith configuration files to reset."
    exit 0
fi

umask 077
timestamp=$(date +%Y%m%d%H%M%S)
backup=$(mktemp -d -- "$HOME/regolith-config-backup-$timestamp-XXXXXXXX")
if ! cp -a -- "$@" "$backup"; then
    printf 'Backup failed. Configuration was preserved. Partial backup: %s\n' "$backup" >&2
    exit 1
fi

printf 'Copied all Regolith configuration files to: %s\n' "$backup"
if ! rm -rf -- "$@"; then
    printf 'Reset incomplete. The configuration backup is at: %s\n' "$backup" >&2
    exit 1
fi

echo "Removed Regolith configuration files.  Please log back in to reload, or run regolith-config-init.sh."
