# Contributing

## Pull requests

Every PR runs free checks in CI, without an API key: plugin and marketplace validation, an install
check in an empty HOME, a local link check and a privacy lint. Paid evals never run on pull
requests.

The privacy lint fails on absolute home paths (for example a macOS or Linux home directory with a
user name in it) and on email addresses that are not noreply addresses. Commits must use a noreply
author and committer email, for GitHub `<id>+<login>@users.noreply.github.com`:

```bash
git config user.email "<id>+<login>@users.noreply.github.com"
```

Findings print as `file:line` only. The lint reads committed content, not uncommitted changes.
Run it yourself with:

```bash
scripts/privacy-lint.sh --tree --range origin/main..HEAD
```

## Pre-push hook (maintainer)

The pre-push hook runs the same lint plus a private pattern list on every commit you push. The
list lives outside the repo and is never committed.

1. Create the list: one POSIX extended regular expression per line, matched case-insensitively;
   lines starting with `#` are comments. `\b`, `\w` and `\s` are not supported (the lint rejects
   them); use bracket expressions such as `[^a-z]` instead.

   ```bash
   mkdir -p ~/.config/agentic-dev-workflow
   $EDITOR ~/.config/agentic-dev-workflow/private-patterns
   ```

   To use another path, set `AGENTIC_DEV_WORKFLOW_PATTERNS`.

2. Point git at the repo's hooks:

   ```bash
   git config core.hooksPath scripts/hooks
   ```

The hook blocks the push when the list is missing or invalid, or when a pushed commit matches it
(added lines, file paths, commit messages). It also runs the generic checks, including the noreply
check on author and committer emails. It prints file and line, never the matched text or the
pattern.

CI checks the same list on pushes to `main`, from the secret `PRIVATE_PATTERNS` (same format).
Fork PRs never see it.
