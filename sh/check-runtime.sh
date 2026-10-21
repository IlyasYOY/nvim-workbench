#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"

runtime_root=$(mktemp -d "${TMPDIR:-/tmp}/nvim-workbench-check.XXXXXX")
trap 'rm -rf "$runtime_root"' EXIT

mkdir -p \
    "$runtime_root/config" \
    "$runtime_root/state" \
    "$runtime_root/cache" \
    "$runtime_root/runtime"
chmod 700 "$runtime_root/runtime"
ln -s "$NVIM_WORKBENCH_DIR/config/nvim" "$runtime_root/config/nvim"

cd "$runtime_root"

XDG_CONFIG_HOME="$runtime_root/config" \
XDG_STATE_HOME="$runtime_root/state" \
XDG_CACHE_HOME="$runtime_root/cache" \
XDG_RUNTIME_DIR="$runtime_root/runtime" \
"${NVIM:-nvim}" --headless -i NONE \
    "+lua local ok, err = pcall(dofile, '$NVIM_WORKBENCH_DIR/tests/runtime.lua'); if not ok then print(err); vim.cmd('cquit') end" \
    "+qa"
