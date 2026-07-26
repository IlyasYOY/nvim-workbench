# Agent Instructions

- Do not make commits unless the user explicitly asks.
- Preserve existing user changes.
- Explain what changed, why, and how it was verified.
- Run `make check` before calling work complete.
- Keep plugin registration and the personal plugin manifest in this repository.
- Keep reusable plugin behavior in its sibling plugin repository; keep personal
  mappings and defaults here.
- Prefer real headless Neovim verification over syntax-only checks.
