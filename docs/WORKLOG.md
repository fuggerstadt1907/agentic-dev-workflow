# Worklog

One entry per stage of [requirements.md](requirements.md). Each entry records which skill version
ran (R25). The entry format becomes a template in stage 4.

## 2026-11-21 · Stage 1: Repo skeleton (private)

- **Skill version:** `implement-ticket` from the installed copy in `~/.claude/skills`, identical
  (`diff -r`) to `skills/` at the initial commit `854a750`. German text, pre-1.0.
- **Branch:** `stage-01-skeleton` · Ticket: [01-repo-skeleton](tickets/01-repo-skeleton.md) ·
  Issue #1
- **Time:** ~70 min wall-clock (2026-11-20 ~10 min context and plan; 2026-11-21 ~60 min build,
  review, push, CI), estimated from file and commit timestamps

### Questions asked (one round)

1. GitHub actions (repo, issues, PR, planted test): allowed under conditions. Show
   `git log --format='%h %ae %ce'` before the first push; the planted test runs on a throwaway
   branch and PR that is closed unmerged; the private-pattern test stays local (D36).
2. Private pattern list: the maintainer fills it and sets the secret (D34).
3. Link check scope: split into blocking local and non-blocking external, plus a weekly run (D35).
4. Plan confirmation: confirmed, with a stop before the first push so the maintainer can fill the
   pattern list.

### What was tested

- Plugin and marketplace manifests: `claude plugin validate --strict` passes for both.
- Install check in an empty HOME, locally with Claude Code 2.1.329: marketplace add, install, and
  `details` lists both skills. The copied `skills/` validate with `--strict`.
- Privacy lint and pre-push hook in a temp repo with a fake remote: a fake private term in a file
  and in a commit message blocks the push and prints file:line or commit only. Output was grepped
  to confirm the term is absent. A missing list blocks the push. A fake home path is flagged while
  the `someone` placeholder passes, a non-noreply email in a file and as author is flagged. Each
  planted term was confirmed present in the input first.
- Lint over this repo's tree and history: clean.

### Tested on GitHub

- Before the first push: `git log --format='%h %ae %ce' --all` showed only the noreply address;
  the lint with the maintainer's real private list over the tree and all branches was clean. A
  self-check (the list's patterns run against a copy of the list in a temp repo) confirmed the
  patterns fire; matching is case-insensitive (tested with upper, lower and mixed case).
- Private repo created, `main` pushed through the hook. Issues #1–#12 created, matching the ticket
  files.
- PR #13: all four checks green. The CI log shows `Skills (2)  grill-ticket, implement-ticket` and
  both strict validations.
- PR #14 (throwaway, based on `stage-01-skeleton`) planted a fake home path. The local hook blocked
  the push (pushed with `--no-verify` on purpose); CI's privacy lint failed with `planted.md:3`
  only, and the planted text does not appear anywhere in the run log. This also covers mawk on the
  Ubuntu runner. PR closed unmerged, branch deleted (D36).

### Not tested yet

- The `PRIVATE_PATTERNS` step on `main` (runs on the merge, needs the secret) and the weekly link
  job.

### Review findings (fresh subagent, two axes: standards and spec)

Fixed:

- An invalid private regex made awk print the pattern to stderr while the lint reported clean.
  Patterns are now validated up front (errors name the line number only), backslash escapes are
  rejected, and awk failures stop the lint.
- File paths were never checked; they are now, in tree and range mode, without printing the path.
- Any address containing "noreply" passed. Only GitHub noreply addresses pass now (plus
  `noreply@anthropic.com` as a co-author trailer in text).
- A colon in a file name broke tree mode and could print content as the location. Locations are
  now passed to awk through the environment, never parsed out of git output.
- A space in a file name dropped the line number in range mode.
- The CI install check grepped `details` for the skill names, which the description also contains.
  It now matches the inventory line.
- `include_fragments = false` is invalid lychee config (enum since 0.24); removed.
- A force-push to `main`, or a remote tip that is not local, broke the range; both fall back to the
  full history of the pushed commit.
- AC16 planted exactly the allowed placeholder and could not fail; reworded (D40).
- Doc nits: CONTRIBUTING said the private list is matched against emails; `--help` printed code
  lines; usage errors exited 1 instead of 2; ticket lines over 100 columns.

Not fixed: the external link job's red check is non-blocking by design (D35).

All tests above were rerun after the fixes, plus the review's cases (pattern in a file name,
invalid and `\b` patterns, loose noreply addresses, colon and space in file names, unknown remote
tip).

## 2026-11-21 · Stage 2: Skills in English

- **Skill version:** `implement-ticket` from the installed copy in `~/.claude/skills`, identical
  (`diff -r`) to `skills/` at `0cf58ff` (`main`). German text, pre-1.0. This is the last stage
  run with the German version.
- **Branch:** `stage-02-skills-english` · Ticket:
  [02-skills-in-english](tickets/02-skills-in-english.md) · Issue #2
- **Time:** ~60 min wall-clock, given by the maintainer

### Questions asked

1. Vocabulary: the terms of `requirements.md` (D41). The maintainer added that both skills keep
   reading the German terms of older documents, and that the skills write only English status
   markers.
2. Switch to the English skills: copy after the merge, with the German copies moved to
   `~/.claude/skills-backup-de/`, a restart and a test on a German requirements document (D43).
3. Plan confirmation: confirmed. After the first commit the maintainer asked to move the AC1 check
   into the repo with a CI step (D45).
4. During the build: reading German terms conflicts with AC1 ("no German text"). Decision: one
   exact legacy-terms block per SKILL.md, the AC1 exception covers exactly that block (D42).
5. After the review: German projects keep headings and column names in their own language
   (behaviour unchanged); only status markers are always English (D41).

### What was tested

- AC1, no German: `scripts/check-no-german.sh` blanks out the legacy block only when it matches
  the allowed text byte for byte, then greps for umlauts, ß and common German words. `skills/` is
  clean. Positive controls: the German files from `main` give 229 hits; `--self-test` plants a
  German sentence after the block and an edit inside it, and both are flagged. CI runs the
  self-test and the check on every PR (D45).
- AC1, no behaviour change: side-by-side review of German and English by a fresh subagent (below).
- R3: the reviewer compared the diff with Matt Pocock's `grilling`, `grill-me`, `grill-with-docs`,
  `tdd` and `to-tickets` using shared 4- and 5-word runs. After the fixes only generic runs remain.
- `claude plugin validate --strict` for plugin and marketplace, the install check in an empty HOME
  for both paths (Claude Code 2.1.330 locally): both pass, `details` lists both skills.

### Not tested yet

- The switch (D43) and reading a real German requirements document with the English skills. Both
  happen after the merge.
- The link check runs in CI only (lychee is not installed locally).

### Review findings (fresh subagent, plus a re-check of the fixes)

Fixed:

- The template kept headings in the project's language while the legacy block said "never write"
  them. Status markers and human-facing headings are now split explicitly.
- Legacy mappings were missing for `AK`, `Etappen` and `Wer klärt`.
- "Checks" meant two things in implement-ticket (per-criterion verification and the project's
  checks); the first is now "verification".
- Four passages were close to Pocock's wording (frontier definition, later-round rule, file paths
  go stale, tracer slice, one-line seam note); rephrased.
- Smaller: "clear the context" was descriptive instead of an instruction; "anything that leaves
  the machine" was narrower than the German; user-facing labels were not marked as
  project-language; "the document is the brief" clashed with `docs/brief.md`; the "Blocks"
  column is now read in the document's language.

Not fixed: none.
