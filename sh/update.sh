#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"

info "Updating nvim-workbench"

update_workbench_checkout
clone_personal_plugins
update_personal_plugins

runtime_root=$(mktemp -d "${TMPDIR:-/tmp}/nvim-workbench-update.XXXXXX")
trap 'rm -rf "$runtime_root"' EXIT
mkdir -p \
    "$runtime_root/config" \
    "$runtime_root/state" \
    "$runtime_root/cache" \
    "$runtime_root/runtime"
chmod 700 "$runtime_root/runtime"
ln -s "$NVIM_WORKBENCH_DIR/config/nvim" "$runtime_root/config/nvim"

XDG_CONFIG_HOME="$runtime_root/config" \
XDG_STATE_HOME="$runtime_root/state" \
XDG_CACHE_HOME="$runtime_root/cache" \
XDG_RUNTIME_DIR="$runtime_root/runtime" \
nvim --headless -i NONE \
    "+lua local ok, err = pcall(function() require('ilyasyoy.pack').update() end); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
    "+qa"

success "nvim-workbench updated"
