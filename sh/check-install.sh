#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"

test_root=$(mktemp -d "${TMPDIR:-/tmp}/nvim-workbench-install.XXXXXX")
trap 'rm -rf "$test_root"' EXIT

test_home="$test_root/home"
test_projects="$test_home/Projects/IlyasYOY"
test_config="$test_home/.config"
mkdir -p "$test_projects/dotfiles/config" "$test_config"

while IFS= read -r plugin; do
    mkdir -p "$test_projects/$plugin/.git"
done < <(personal_plugins)

ln -s "$test_projects/dotfiles/config/nvim" "$test_config/nvim"

for _ in 1 2; do
    HOME="$test_home" \
    ILYASYOY_PERSONAL_PROJECTS_DIR="$test_projects" \
    NVIM_CONFIG_HOME="$test_config/nvim" \
        "$NVIM_WORKBENCH_DIR/sh/install.sh" >/dev/null
done

[ "$(readlink "$test_config/nvim")" = "$NVIM_WORKBENCH_DIR/config/nvim" ]
