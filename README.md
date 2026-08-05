# nvim-workbench

Personal Neovim configuration and local plugin-development workbench.

The repository owns:

- the full Neovim configuration under `config/nvim`;
- personal plugin checkout discovery and updates;
- GolangCI, Java formatter, Checkstyle, and PMD configuration used by Neovim;
- static and headless runtime checks.

## Install

```bash
make install
```

This links `config/nvim` to `~/.config/nvim` and clones missing personal
Neovim plugin repositories under `~/Projects/IlyasYOY`.

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

CI pins the runtime check to Neovim 0.12.4. Run the same check locally with:

```bash
make check NVIM_VERSION=v0.12.4
```

The selected Neovim archive is cached under the ignored `.test-deps`
directory. Without `NVIM_VERSION`, the check uses the `nvim` executable from
`PATH`.

## Release

Run the manual **Release** workflow from the repository's default branch and
choose `patch`, `minor`, or `major`. The workflow runs the canonical check,
creates an annotated `vX.Y.Z` tag, and publishes a GitHub Release with generated
notes.

Versions live only in Git tags and GitHub Releases. With no existing release,
the first patch, minor, and major choices produce `v0.0.1`, `v0.1.0`, and
`v1.0.0`, respectively. The workflow refuses to release the same commit twice.
