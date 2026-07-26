#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"

test_root=$(mktemp -d "${TMPDIR:-/tmp}/nvim-workbench-update.XXXXXX")
trap 'rm -rf "$test_root"' EXIT

test_home="$test_root/home"
test_projects="$test_home/Projects/IlyasYOY"
pull_log="$test_root/pulls"
nvim_log="$test_root/nvim"
expected_pulls="$test_root/expected-pulls"
mkdir -p "$test_projects"

while IFS= read -r plugin; do
    mkdir -p "$test_projects/$plugin/.git"
    printf "%s\n" "$test_projects/$plugin" >>"$expected_pulls"
done < <(personal_plugins)

git() {
    local repository=""

    if [ "${1:-}" = "-C" ]; then
        repository="$2"
        shift 2
    fi

    case "${1:-}" in
        remote)
            return 1
            ;;
        status)
            return 0
            ;;
        pull)
            [ "${2:-}" = "--ff-only" ]
            printf "%s\n" "$repository" >>"$pull_log"
            ;;
        *)
            return 1
            ;;
    esac
}

nvim() {
    touch "$nvim_log"
    return 1
}

(
    HOME="$test_home"
    ILYASYOY_PERSONAL_PROJECTS_DIR="$test_projects"
    export HOME ILYASYOY_PERSONAL_PROJECTS_DIR
    # shellcheck disable=SC1091
    source "$NVIM_WORKBENCH_DIR/sh/update.sh" >/dev/null
)

cmp "$expected_pulls" "$pull_log"
[ ! -e "$nvim_log" ]
