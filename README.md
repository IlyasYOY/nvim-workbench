# nvim-workbench

Personal Neovim configuration and local plugin-development workbench.

The repository owns:

- the full Neovim configuration under `config/nvim`;
- personal plugin checkout discovery and updates;
- Java formatter, Checkstyle, and PMD configuration used by Neovim;
- static and headless runtime checks.

## Install

```bash
make install
```

This links `config/nvim` to `~/.config/nvim` and clones missing personal
Neovim plugin repositories under `~/Projects/IlyasYOY`.
It also removes the retired `~/.config/nvim-minimal` link when that link still
points to the former dotfiles-managed configuration.

Override those defaults with `NVIM_CONFIG_HOME` and
`ILYASYOY_PERSONAL_PROJECTS_DIR`.

## Update

```bash
make update
```

The update follows the checkout's configured upstream branch, pulls personal
plugin checkouts with fast-forward-only updates, and refreshes `vim.pack`
dependencies.

## Check

```bash
make check
```

The canonical check runs Luacheck, StyLua, ShellCheck, and an isolated
headless Neovim startup using the real configuration.
