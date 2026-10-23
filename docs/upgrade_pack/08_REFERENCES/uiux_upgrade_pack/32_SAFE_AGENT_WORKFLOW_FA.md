# گردش کار ایمن برای Agentهای UI/UX

1. Read current `AGENTS.md`, `FILE_OWNERSHIP.md`, `DESIGN_SYSTEM_GUIDE.md` and check worktree before edits.
2. Capture exact SHA and assign one owner per file set.
3. Agents may research and write isolated specs in parallel; do not allow parallel edits to tokens, localization ARB, routes or golden baselines without a single owner.
4. For each screen, write a short spec and list no-change constraints before code.
5. Never run a global formatter, clean, checkout, stash, golden update or test command that violates active project instructions.
6. UI-only tasks cannot change money logic, API contracts or crypto policy without a backend/security reviewer.
7. Add tests alongside changes. Final test suites run serially if shared worktree policy requires.
8. Report actual results only: PASS with log/screenshot, FAIL with repro, BLOCKED with missing dependency/access.
9. Keep all changes local until explicit approval; do not push, tag, release or deploy.
