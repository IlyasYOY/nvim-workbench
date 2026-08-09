#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"

info "Installing nvim-workbench"

mkdir -p "$(dirname "$NVIM_CONFIG_HOME")"
replace_managed_symlink \
    "$NVIM_WORKBENCH_DIR/config/nvim" \
    "$NVIM_CONFIG_HOME" \
    "$PERSONAL_PROJECTS_DIR/dotfiles/config/nvim"
clone_personal_plugins

success "nvim-workbench installed"
