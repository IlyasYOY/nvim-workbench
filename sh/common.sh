#!/usr/bin/env bash

set -euo pipefail

NVIM_WORKBENCH_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
PERSONAL_PROJECTS_DIR="${ILYASYOY_PERSONAL_PROJECTS_DIR:-$HOME/Projects/IlyasYOY}"
NVIM_CONFIG_HOME="${NVIM_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/nvim}"
PERSONAL_PLUGINS_MANIFEST="$NVIM_WORKBENCH_DIR/config/nvim/personal-plugins.txt"

info() {
    printf "\n\033[1;34m%s\033[0m\n" "$1"
}

success() {
    printf "✅ \033[1;32m%s\033[0m\n" "$1"
}

warning() {
    printf "⚠️ \033[1;33m%s\033[0m\n" "$1"
}

replace_managed_symlink() {
    local target="$1"
    local link="$2"
    local legacy_target="$3"

    if [ -L "$link" ]; then
        local current_target
        current_target=$(readlink "$link")
        if [ "$current_target" = "$target" ]; then
            return 0
        fi
        if [ "$current_target" != "$legacy_target" ]; then
            warning "$link points to an unmanaged target; leaving it unchanged"
            return 1
        fi
        rm -f "$link"
    elif [ -e "$link" ]; then
        warning "$link exists and is not a symlink; leaving it unchanged"
        return 1
    fi

    ln -s "$target" "$link"
    success "Linked $link -> $target"
}

personal_plugins() {
    sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$PERSONAL_PLUGINS_MANIFEST"
}

clone_personal_plugins() {
    local plugin destination

    mkdir -p "$PERSONAL_PROJECTS_DIR"
    while IFS= read -r plugin; do
        destination="$PERSONAL_PROJECTS_DIR/$plugin"
        if [ -d "$destination/.git" ]; then
            continue
        fi
        if [ -e "$destination" ]; then
            warning "$destination exists but is not a Git checkout"
            continue
        fi
        git clone "git@github.com:IlyasYOY/$plugin.git" "$destination"
    done < <(personal_plugins)
}

update_personal_plugins() {
    local plugin destination

    while IFS= read -r plugin; do
        info "$plugin"
        destination="$PERSONAL_PROJECTS_DIR/$plugin"
        if [ ! -d "$destination/.git" ]; then
            warning "$destination is not installed; skipping"
            continue
        fi
        if [ -n "$(git -C "$destination" status --porcelain --untracked-files=all)" ]; then
            warning "$destination has local changes; skipping upstream update"
            continue
        fi
        git -C "$destination" pull --ff-only
    done < <(personal_plugins)
}

update_workbench_checkout() {
    if [ ! -d "$NVIM_WORKBENCH_DIR/.git" ]; then
        warning "Workbench is not a Git checkout; skipping upstream update"
        return 0
    fi
    if ! git -C "$NVIM_WORKBENCH_DIR" remote get-url origin >/dev/null 2>&1; then
        warning "Workbench has no origin remote; skipping upstream update"
        return 0
    fi
    if [ -n "$(git -C "$NVIM_WORKBENCH_DIR" status --porcelain --untracked-files=all)" ]; then
        warning "Workbench has local changes; skipping upstream update"
        return 0
    fi

    git -C "$NVIM_WORKBENCH_DIR" pull --ff-only
}
