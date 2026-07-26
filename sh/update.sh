#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"

info "Updating nvim-workbench"

update_workbench_checkout
clone_personal_plugins
update_personal_plugins

success "nvim-workbench updated"
