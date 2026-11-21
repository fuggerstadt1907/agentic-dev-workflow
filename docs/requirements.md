# Requirements: agentic-dev-workflow 1.0

> Status: not ready · Ticket: docs/brief.md · Updated: 2026-11-21

## Summary

This repo becomes a public, measured workflow for agentic development. It ships two Claude Code
skills (`grill-ticket`, `implement-ticket`) as a plugin and has an eval harness that compares each
skill against a plain-prompt baseline. A case study page covers `mcp-project-context`. The main
audience is tech leads and hiring reviewers who read the README and the numbers. When one of them
tries the install, it has to work.

## Problem and goal

Coding agents write code fast. Teams struggle with three things. Agents build on unclear or
contradictory requirements and fill the gaps with assumptions. The agent that wrote the code also
reviews it, so its blind spots survive. Nobody measures whether a prompt or skill works, or whether
a change made it worse.

Goal: a reviewer understands the workflow quickly, can install it, and sees numbers that show
where the skills help and where they do not. The README states "understand in 2 minutes, install
in 5" as a goal, not as a measured fact. Success never includes a target score: the results table
shows whatever the eval measured, including metrics where the skill does not beat the baseline.

## Actors and roles

| Actor | What they do |
| --- | --- |
| Reviewer (tech lead, hiring reviewer) | Reads README, workflow page, results and case study. May install once. |
| Maintainer (repo owner) | Writes every eval case, expected answer and hand label. Approves eval runs in CI, commits new results, posts to GitHub. Uses the published plugin for their own work. |
| Test reader | A developer who knows Claude Code and has never seen the repo, not the maintainer. Tries README and install once before the release. |
| Outside contributor | Opens PRs from forks. Gets the free CI checks, never secrets or paid evals. |
| Coding agent | Builds this repo stage by stage with the repo's own skills. |

## Requirements

### Language and delivery

- **R1**: Skills, docs, eval cases and templates are in English. The skills keep working in the
  language of the project they run in. `skills/` is the only source: the maintainer uses the
  English version from stage 2 on, and the evals run on the same files.
- **R2**: The repo is a Claude Code plugin and a marketplace, both named `agentic-dev-workflow`,
  with both skills in one plugin. The README leads with the plugin install and lists copying
  `skills/<name>` into `~/.claude/skills` or `.claude/skills` as the fallback. Skill text refers to
  the other skill by its short name (`/implement-ticket`); the README shows the short and the
  namespaced form (`/agentic-dev-workflow:implement-ticket`).
- **R3**: The English translation keeps behaviour unchanged and takes no wording from third-party
  skills. If any passage is a word-for-word copy, the original licence notice stays with it.

### Skills 1.0

- **R4**: implement-ticket accepts a `not ready` document for a stage that is unblocked. A stage is
  unblocked when none of the document's open questions touch it. If a stage depends on an open
  question, the skill refuses that stage and names the question.
- **R5**: The review instructions live in `skills/implement-ticket/REVIEW.md`. The skill always
  hands that file to a fresh subagent and never delegates to an external review skill. REVIEW.md
  stays generic: no rule names a defect class that is also a planted eval case.
- **R6**: implement-ticket decides implementation details itself (internal data shapes, naming,
  edge-case handling inside one module), with its recommended option, and records them in the
  decision log. It asks only when a decision changes scope, public output or security behaviour,
  contradicts a doc or ADR, or is hard to undo. Questions are batched, at most one round per stage.
- **R7**: implement-ticket stages explicit paths only and never runs `git add -A` or `git add .`.
- **R8**: Both skills: a question that rests on a technical claim says how the claim was verified,
  or marks it as an assumption.
- **R9**: When implement-ticket refuses an input, it points to the matching requirements document
  and stage. The requirements template maps each stage to its ticket file or issue.
- **R10**: For a security-relevant stage, the plan step adds acceptance criteria written from an
  attacker's view before building.
- **R11**: In the build step, every negative test ("X never appears") gets a positive check that X
  is really present in the input.
- **R12**: If the project has a `WORKLOG.md`, implement-ticket drafts the entry in its closing step:
  questions asked, review findings, what was and was not tested. It leaves "Time" as TODO and asks
  the user for it instead of proposing one; it may show the run's start and current time, labelled
  as raw timestamps (D47). It commits the entry, in its own commit, only after the user's OK and
  time (D48). Without a `WORKLOG.md` there is no worklog step.
- **R13**: A `CHANGELOG.md` links every change to the worklog entry that caused it. Links into the
  case study use permalinks with a commit SHA; later entries link to this repo's worklog.

### Docs

- **R14**: The README's first screen holds the purpose (at most three sentences), the workflow
  diagram, the results table (or the status "Evals in progress – results pending" until stage 9)
  and the install command.
- **R15**: A workflow page shows brief → grill → requirements → implement → worklog as a Mermaid
  diagram, including the inner loop of implement-ticket per stage (plan → thin slice →
  fresh-context review → fix → commit, repeated per stage). One plain-text line under the diagram
  repeats the flow. The README uses the same diagram.
- **R16**: An install guide and templates for `CLAUDE.md` and `WORKLOG.md`.
- **R17**: A Credits section names only ideas actually used, with links (for example Matt Pocock's
  `grilling` skill for the design tree, frontier and facts-versus-decisions split; his `tdd` and
  `to-tickets` skills for seams and tracer bullets).
- **R18**: README and report separate prevention from detection. Plan and build rules (R10, R11)
  prevent defects and are not measured by the review eval. REVIEW.md detects defects and is what
  the review eval measures. No text claims the skill catches a defect class that only a build rule
  addresses.
- **R19**: `CONTRIBUTING.md` explains how to install the pre-push hook (R22).

### Repo hygiene and CI

- **R20**: Commits in this repo use the maintainer's GitHub noreply address. The initial commit is
  rewritten before the first push.
- **R21**: CI on every PR, without API cost: `claude plugin validate --strict` for plugin and
  marketplace, link check, generic privacy patterns (absolute home paths such as `/Users/` and
  `/home/`, email addresses other than noreply), and author and committer emails of new commits.
  On pushes to `main`, CI also checks a private pattern list from a secret; fork PRs skip that
  part. A match prints file and line, never the matched text or the pattern.
- **R22**: A local pre-push hook checks the private pattern list, which lives outside the repo
  (for example `~/.config/agentic-dev-workflow/private-patterns`).
- **R23**: CI install check on every PR, in an empty HOME and without model calls: (a) add the
  repo as a local marketplace, install the plugin, and check that `claude plugin details` lists
  both skills; (b) copy `skills/` into `~/.claude/skills` and validate it.
- **R24**: Every stage of this document has a ticket file under `docs/tickets/` and a GitHub
  issue, so R9 works from stage 3 on.
- **R25**: This repo is built with its own skills. Every `docs/WORKLOG.md` entry records which
  skill version ran (installed copy, or commit SHA of `skills/`).

### Evals

- **R26**: Runner spike. `claude plugin eval` is the runner if one case passes all exit criteria:
  1. A call to `AskUserQuestion` does not stall the run, and the first question round can be read
     from the trace or the output.
  2. Per-run tokens and duration can be read.
  3. The fixture loads into the run's workspace.
  4. The baseline is skill-free: its transcript contains no text from the skill or REVIEW.md, in
     the prompt or anywhere in the context (including skill listings).

  Skill and baseline run as separate cases (`--ablation none`), so the baseline gets its own
  prompt. If any criterion fails, the fallback is headless `claude -p --output-format
  stream-json` on a temp copy of the fixture.
- **R27**: Before any paid run, the agent estimates the cost of one full run and the maintainer
  sets the spending limit on the key. Every eval run passes `--max-cost-usd` (or the fallback's
  equivalent).
- **R28**: Review eval: 8 diffs with one planted defect each and 4 clean diffs, all written by the
  maintainer and seeded from real case-study findings. Skill arm: the REVIEW.md step on the diff.
  Baseline: same model, tools and diff, prompt "Review this diff for defects." Metrics: defect
  found (yes/no), false findings per clean diff, tokens, duration.
- **R29**: Grill eval: 5 tickets, each with a small fixture repo, all written by the maintainer.
  Four have planted contradictions and gaps; one is clean. In 1.0 the eval scores the first pass
  only, the same way for both arms: for the skill, the readiness summary and first question round;
  for the baseline, its first reply to "Read this ticket and the repo; list what must be clarified
  before implementing." Metrics: planted issues surfaced, noise questions (the clean ticket counts
  them for both arms), number of questions.
- **R30**: Method. 3 runs per case and arm; the report gives mean and spread (min–max).
  Deterministic checks first; the LLM judge only matches a free-text finding to a planted issue,
  with a fixed rubric. Model under test and judge are pinned to `claude-sonnet-5-5`.
- **R31**: Judge validation before judge scores count. The maintainer labels 30 (finding, planted
  issue) pairs blind, without seeing the judge's verdict. The pairs mix skill and baseline outputs,
  real matches and near misses. The judge must agree on at least 27. If the rubric changes after a
  failed check, the next check uses 30 new pairs. The agreement rate is published.
- **R32**: Failed runs. Infrastructure errors (API error, rate limit, runner crash) and timeouts are
  counted separately per arm, never scored as 0 and never dropped silently. A case with fewer than
  3 valid runs is rerun once, for both arms. If one arm times out clearly more often, that goes
  into the report as a result. A partial run (cost ceiling) is never committed and never used as
  the regression baseline.
- **R33**: Results are committed as data (raw per-run results, summary, hand labels) next to a
  Markdown report. Only the maintainer commits a new result. The report states: one model, small
  sample; the case study was built with Opus 5.5 and the eval runs Sonnet 5.5, so results do not
  transfer one to one; judge and model under test are from the same family, which is why
  deterministic checks come first and the judge is validated against hand labels; prevention
  versus detection (R18).
- **R34**: Overfitting guard. Once the first results exist, every change to REVIEW.md or to the
  grill instructions made after looking at results is logged in the worklog with its reason, and
  the report says so.
- **R35**: CI evals run on pushes to `main` that touch `skills/` or `evals/`, and on manual
  dispatch, never on `pull_request`. The API key is a dedicated key for this repo with a monthly
  spending limit set in the Anthropic console, stored in a GitHub environment `evals` with the
  maintainer as required reviewer. Workflow permissions are `contents: read`. Reports are not
  published from CI.
- **R36**: Regression rule. Per metric, the margin is the larger of the min–max spread in the last
  committed result and a floor (10 percentage points for detection rates, 0.5 for false findings
  per clean diff). A run fails if the skill-versus-baseline gap shrinks beyond the margin, or if the
  skill arm drops beyond it while the baseline does not. If both arms drop together, the run is
  reported as a probable model or provider change and does not fail. Improvements never fail.

### Case study and release

- **R37**: The case study page links `mcp-project-context` and its worklog (12 of 13 tickets done,
  1,131 tests, 75 agent mistakes caught in review). It states openly that the worklog does not
  record whether the review subagent used the built-in `code-review` skill or implement-ticket's own
  instructions, that the 75 also count gaps the user found with their own criteria, and that these
  numbers are not results of REVIEW.md. It shows two or three findings the fresh review caught, and
  what the skills missed, such as the npx issue found only in a fresh clone.
- **R38**: The repo stays private until stage 4 is done. Before it goes public, the privacy lint
  and the pre-push hook run over the whole git history. The README then says "Evals in progress –
  results pending".
- **R39**: Release 1.0: `plugin.json` version 1.0.0, tag `v1.0.0` created with `claude plugin tag`,
  GitHub release notes from the CHANGELOG. One manual check as a real user: fresh HOME, install
  from the GitHub URL exactly as the README says, run `/grill-ticket` once. The test reader tries
  the README and install; time and stumbling points go into the worklog as they happened, then the
  README gets fixed. Afterwards the maintainer switches to the plugin and removes the old copies
  from `~/.claude/skills`. All results go into the worklog.

### Acceptance criteria

- **AC1 (R1, R3)**: Given stage 2 is done, when `skills/` is searched, then it contains no German
  text apart from the legacy-terms block that both skills read (D42), and a side-by-side check
  against the German version lists no behaviour change.
- **AC2 (R2, R23)**: Given a fresh HOME, when the CI install check runs, then both install paths
  pass and `claude plugin details` lists `grill-ticket` and `implement-ticket`.
- **AC3 (R4)**: Given a `not ready` document whose stage 2 is touched by an open question, when
  `/implement-ticket <doc> stage 2` runs, then it refuses and names that question; stage 1 (not
  touched) is accepted.
- **AC4 (R5)**: Given implement-ticket reaches the review step, then the fresh subagent's prompt
  contains REVIEW.md and no call to another review skill appears in the trace.
- **AC5 (R6)**: Given a stage with internal design choices only, when implement-ticket plans it,
  then it asks no question about them and lists them in the decision log.
- **AC6 (R7)**: Given an unrelated uncommitted file in the working tree, when implement-ticket
  commits, then that file is not in the commit.
- **AC7 (R8)**: Given a question based on a technical claim, then the question says how the claim
  was verified or marks it "assumption".
- **AC8 (R9, R24)**: Given a raw ticket file from `docs/tickets/` as input, when implement-ticket
  refuses, then it names the requirements document and stage that cover the ticket.
- **AC9 (R10, R11)**: Given a stage marked security-relevant, then the plan shown to the user
  contains attacker-view acceptance criteria; given a negative test in the diff, then a positive
  check for the same input exists next to it.
- **AC10 (R12)**: Given a project with `WORKLOG.md`, when a stage closes, then a draft entry exists
  with Time "TODO", no time is proposed, and the worklog entry is not committed before the user's OK
  and time; given no `WORKLOG.md`, no worklog file is created.
- **AC11 (R13)**: Every CHANGELOG entry has at least one link; every link into
  `mcp-project-context` contains a commit SHA.
- **AC12 (R14, R15)**: Given a 1280×800 browser window on GitHub, the README's first screen shows
  purpose, diagram, results table or status line, and install command. The diagram shows the inner
  loop, and the plain-text line repeats it.
- **AC13 (R17, R3)**: Every idea named in Credits appears in the skills, and every credited source
  is linked.
- **AC14 (R18)**: README and report contain no sentence that attributes detection of a defect class
  to the skill when only R10 or R11 address it.
- **AC15 (R20)**: Given the first push, every commit's author and committer email is a noreply
  address.
- **AC16 (R21, R22)**: Given a planted fake home path in a PR (any user name except the
  documented placeholder `someone`, see D32), CI fails and prints file and line only. Given a
  private pattern in a local commit, the pre-push hook blocks the push without printing the
  pattern.
- **AC17 (R26)**: The spike's worklog entry lists each of the four exit criteria with pass or fail
  and its evidence, and names the chosen runner.
- **AC18 (R27)**: The cost estimate is in the worklog before the first paid run, and every eval
  command carries a cost ceiling.
- **AC19 (R28, R29)**: The cases exist as committed files written by the maintainer: 8 defect
  diffs, 4 clean diffs, 5 grill tickets with fixtures (one clean), each with its expected answer.
- **AC20 (R5, R34)**: Every planted review case is checked against REVIEW.md, and no case matches a
  rule in it. The check is recorded in the worklog.
- **AC21 (R30, R32)**: The report gives mean and min–max per metric and arm, plus error and timeout
  counts per arm.
- **AC22 (R31)**: The committed label file holds 30 blind labels, and the report states the
  agreement rate; judge scores appear only if it is at least 90 %.
- **AC23 (R35)**: A PR from a fork triggers no eval job and no job with access to the `evals`
  environment.
- **AC24 (R36)**: Given a committed result and a new run where both arms drop by the same amount,
  CI reports a probable model change and passes; given a run where only the skill arm drops beyond
  the margin, CI fails.
- **AC25 (R37)**: The case study page contains the reviewer-provenance statement and at least one
  thing the skills missed.
- **AC26 (R38)**: Before the visibility switch, the full-history privacy scan has run with zero
  matches, and that is recorded in the worklog.
- **AC27 (R39)**: The worklog has entries for the real-user install from GitHub, the test reader
  session and the switch of the maintainer's own setup.
- **AC28 (R38, attacker view)**: Given someone who clones the public repo with all refs, including
  GitHub's `refs/pull/*`, when they search the history for home paths, non-noreply emails or the
  maintainer's private terms, then they find nothing except the fake path of the throwaway PR #14
  (D60).
- **AC29 (R38, attacker view)**: Given someone who reads every issue, pull request and comment of
  the public repo, when they search for private terms, non-noreply emails or home paths, then they
  find none.

## Edge cases and failure modes

- An eval run errors, times out or hits the cost ceiling: R32. A timeout can be the skill's fault
  (looping, asking forever) and is a result, not only noise.
- `AskUserQuestion` stalls or errors in headless runs: spike criterion 1, fallback runner.
- The baseline sees skill text through a skill listing: spike criterion 4, fallback runner.
- Both arms drop after a model update: R36 reports it and does not fail.
- Rubric tuned on the same pairs until it passes: R31 requires fresh pairs.
- Eval cases leak into REVIEW.md: R5, AC20.
- A fork PR tries to spend the key: R35, AC23.
- The private pattern list leaks through CI output: R21 prints only file and line.
- Bootstrapping: this repo changes the skills it is built with; R25 records which version ran.
- A plugin skill name collides with another installed skill: the namespaced form in the README
  (R2) still works.

## UX/UI and texts

No product UI. The reader-facing surfaces are the README (R14), the workflow page with its Mermaid
diagram (R15), the install guide (R16), the report (R33) and the case study page (R37). All in
English, plain and factual, with goals and caveats stated as such.

## Data and schema

No database. Committed data: eval cases (diffs, tickets, fixture repos, expected answers), raw
per-run results, summary per run, hand labels for judge validation. Results are append-only per
run; only the maintainer commits a new result. Partial runs are never committed.

## Security and data protection

- No customer or employer content; skills from other projects stay private.
- Privacy protection runs before the push (pre-push hook) and again in CI (R21, R22). The private
  pattern list is never committed or printed.
- Commit emails are noreply (R20). Existing commits in `mcp-project-context` stay as they are.
- API key: dedicated, spending-limited, in a protected environment, never available to fork PRs;
  workflow permissions read-only (R35).
- `claude plugin eval --trust-plugin` runs only on code already on `main` (R35).

## Dependencies

- Claude Code with `claude plugin eval`, `validate`, `tag` and `details` (available in 2.1.3xx).
  If the spike fails: headless `claude -p`; for the later full grill run, possibly the Claude Agent
  SDK.
- An Anthropic API key for this repo with a spending limit; the limit follows the estimate (R27).
- A GitHub repo (private first), a GitHub environment `evals`, secrets for the API key and the
  private pattern list.
- A test reader for the release stage, organised by the maintainer.
- Case study repo `mcp-project-context` and its worklog as the source for seed findings and links.

## Target picture (solution)

- One repo that is both marketplace and plugin `agentic-dev-workflow`. `skills/` holds both skills;
  `skills/implement-ticket/REVIEW.md` is the single review text used by the skill and by the review
  eval. Rejected: two plugins (more manifests, no benefit for two skills that belong together);
  delegating to `code-review` (the eval would measure a different skill than users get).
- `evals/` holds the cases, fixtures, expected answers, hand labels and results. Runner:
  `claude plugin eval` with skill and baseline as separate cases, plus a small script for spread,
  regression check and judge agreement. Rejected up front: promptfoo (extra dependency, unclear
  loading of skills as-is); the Agent SDK as main runner (most code, furthest from how users run
  the skills). Kept as fallback: `claude -p`.
- CI has two parts: free checks on every PR (validate, links, privacy, emails, install), and paid
  evals on `main` behind a protected environment.
- Docs: README, workflow page, install guide, templates, CONTRIBUTING, CHANGELOG, report, case study
  page, and this repo's own `docs/WORKLOG.md`.

### Stages

Each stage has a ticket file `docs/tickets/NN-<slug>.md` and a GitHub issue (R24). Stage *n* maps
to the ticket file whose `NN` is *n* (zero-padded) and to issue #*n*.

- **Stage 1: Repo skeleton (private)** · done · 2026-11-21 · stage-01-skeleton · R2 (manifest, marketplace, README stub), R19, R20,
  R21, R22, R23, R24, R25. Rewrite the initial commit to noreply, then push to a private GitHub
  repo; CI is green on a PR; tickets and issues exist. Testable through CI and a planted lint
  violation.
- **Stage 2: Skills in English** · done · 2026-11-21 · stage-02-skills-english · R1, R3. Pure translation, behaviour unchanged; testable
  by side-by-side review. The maintainer switches to the English version afterwards.
- **Stage 3: Skills 1.0** · done · 2026-11-21 · stage-03-skills-1-0 · R4–R13. Lessons from the case study, REVIEW.md, worklog step,
  CHANGELOG. Testable with AC3–AC11 on a small scratch project.
- **Stage 4: Docs and going public** · done · 2026-11-21 · stage-04-docs-public · R14 (with status line), R15, R16, R17, R18, R38.
  Also remove the exclusion of this repo's own URLs from `.github/lychee.toml` (D35).
  Ends with the full-history privacy scan and the visibility switch.
- **Stage 5: Cost estimate and runner spike** · open · R26, R27. One case, both arms; decides the
  runner.
- **Stage 6: Review cases and baseline** · open · R28, R34 (AC20).
- **Stage 7: Review scoring and judge validation** · open · R30, R31, R32 for the review eval.
- **Stage 8: Grill cases and grill eval** · open · R29, plus R30–R32 for the grill eval.
- **Stage 9: Report and results** · open · R33, R14 (results table replaces the status line).
- **Stage 10: CI for evals** · open · R35, R36.
- **Stage 11: Case study page** · open · R37.
- **Stage 12: Release 1.0** · open · R39.

## Rollout and release

Private repo from stage 1, public after stage 4 (R38), release v1.0.0 in stage 12 (R39). No
deploy and no migration. Users update through the plugin system; copy-path users copy again.

## Non-goals

- No general prompt library: two skills.
- No claims beyond what the evals measure; no target score.
- No customer or employer content; no history rewrite in `mcp-project-context`.
- Not in 1.0, possible later: full grill runs with hidden answer files written by the maintainer
  and a simulated user (Agent SDK if `claude plugin eval` cannot answer); an Opus 5.5 run of the
  review eval as a comparison.
- No paid evals on pull requests.

## Docs and help

README, workflow page, install guide, `CLAUDE.md` and `WORKLOG.md` templates, `CONTRIBUTING.md`,
`CHANGELOG.md`, eval report, case study page, `docs/WORKLOG.md`, ticket files under
`docs/tickets/`. The existing README (German, placeholder install URL `<user>/claude-skills.git`)
is replaced in stage 1 and 4.

## Decision log

| # | Question | Decision | Reason |
| --- | --- | --- | --- |
| D1 | Language | English for everything; translation is its own stage; evals run on the English version | Public repo; one source of truth, no drift between published and used skills |
| D2 | Audience | Tech leads and hiring reviewers first; install must really work | Matches the brief; one documented, CI-checked install path |
| D3 | `not ready` documents | Unblocked stages allowed; "unblocked" = no open question touches the stage; otherwise refuse and name it | Tested in the case study; brief's "only ready" corrected |
| D4 | Delivery | Plugin + marketplace first, copy as fallback; CI checks both; evals on the same `skills/` | One source, two install paths |
| D5 | Review step | Own REVIEW.md, no delegation to `code-review` | Users get what the eval measured |
| D6 | Baseline | Same model, tools and input; one neutral sentence | Fair comparison without giving away the skill's structure |
| D7 | Case count | 8 defect + 4 clean review diffs, 5 grill tickets incl. 1 clean; 3 runs per arm | Enough for direction; stated as small sample |
| D8 | Cost | Estimate a full run before the runner is built; maintainer sets the key limit | Spend is controlled up front |
| D9 | Licence | MIT; Credits only for ideas actually used; licence notice kept for any verbatim text | Honest attribution |
| D10 | Runner | `claude plugin eval` after a spike with four exit criteria; fallback `claude -p` | Built-in baseline, runs, cost cap and threshold; known gaps checked first |
| D11 | Grill eval scope | First pass in 1.0 for both arms; full runs with hidden answer files later | Headless runs have nobody to answer; same scoring for both arms |
| D12 | Plugin name | `agentic-dev-workflow`; maintainer switches to the plugin at release | Same as repo name; dogfooding the published artifact |
| D13 | Case study reviewer | State openly that the reviewer is unknown | The worklog does not record it |
| D14 | Lessons in 1.0 | R6–R11 | Observed in the case study worklog |
| D15 | Negative-test lesson vs planted case | Lesson goes into the build step, the case stays; prevention and detection reported separately | Keeps the review eval from measuring its own checklist |
| D16 | Worklog step | Only if `WORKLOG.md` exists; Time TODO; no commit without OK | No convention forced on projects |
| D17 | Models | Sonnet 5.5 under test and as judge, pinned; caveats in the report; Opus run later | Affordable, typical daily model; judge bias handled by deterministic checks and validation |
| D18 | Judge validation | 30 blind, mixed pairs; ≥ 90 %; new pairs after a rubric change | Prevents tuning the rubric to the check |
| D19 | Regression | Margin = max(observed spread, floor); fails only on gap or skill-arm-alone drop | Separates skill regressions from model changes |
| D20 | CI eval trigger | Push to `main` + manual; protected environment; dedicated key; read-only permissions | Forks never spend the key |
| D21 | Privacy lint | Pre-push hook with private list (real protection); CI generic on PRs plus private list on `main`; output file and line only | CI runs after the push; the list itself must not leak |
| D22 | Commit email | noreply; rewrite the initial commit; no rewrite in `mcp-project-context` | Cheap now, painful later |
| D23 | Dogfooding | Own `docs/WORKLOG.md` with skill version per entry; CHANGELOG uses permalinks | Bootstrapping stays traceable; links do not break |
| D24 | Install check | Fresh-HOME install without API in CI; one real install from GitHub at release | CI tests a local marketplace; users install from GitHub |
| D25 | Success | README first-screen contract; one external test reader; times as goals; no target score | One reader is not a study |
| D26 | Failed runs | Errors and timeouts counted separately; symmetric reruns; partial runs never committed | Infrastructure noise kept apart from skill behaviour |
| D27 | Diagram | Mermaid with the inner loop, plus a plain-text line | Renders on GitHub, diffable |
| D28 | Publishing | Public after stage 4 with a full-history privacy scan; v1.0.0 at release | Work in the open once the claims are backed |
| D29 | Overfitting | Result-driven changes logged with reason; no planted case may match a REVIEW.md rule | Keeps the eval honest |
| D30 | Stage map | Ticket file and GitHub issue per stage | R9 works from stage 3 on |
| D31 | Commit identity (stage 1) | Repo-local `user.email` is the GitHub noreply address; the initial commit was rewritten with `--amend --reset-author` before the first push | R20; global git config stays untouched |
| D32 | Privacy lint (stage 1) | One script, `scripts/privacy-lint.sh`, for CI and the hook. It scans tracked files at HEAD (paths and content) and a commit range (author and committer emails, messages, paths, added lines). The only allowed home-path placeholder is `someone`. Allowed emails: `*@users.noreply.github.com`, `noreply@github.com`, and `noreply@anthropic.com` in text (co-author trailers). Private patterns are POSIX ERE, validated before use; an invalid one stops the lint and names only its line number | Same rules locally and in CI; AC16's own text must pass, any other fake path must not; a broken pattern must neither leak nor pass silently |
| D33 | Missing pattern list (stage 1) | The pre-push hook fails closed when the list is missing; `AGENTIC_DEV_WORKFLOW_PATTERNS` overrides the path | A forgotten list must not silently disable the real protection |
| D34 | Owner of the private list (stage 1) | The maintainer writes the list and sets the `PRIVATE_PATTERNS` secret; the agent never sees the content | The list holds the very terms it protects |
| D35 | Link check (stage 1) | Local links block the PR (lychee offline). External links run non-blocking on PRs and weekly on a schedule, which opens or comments on an issue. The repo's own URLs are excluded until stage 4 | External links are flaky; the private repo's URLs 404 anonymously |
| D36 | Proving the checks (stage 1) | The planted generic violation runs on a throwaway branch with its own PR, closed unmerged and deleted; nothing of it lands on `main`. The private-pattern test runs only locally in a temp repo | The full-history scan before going public would flag it; closed PRs stay visible; no real private term is ever committed |
| D37 | Pinning (stage 1) | Actions pinned by commit SHA; CI installs Claude Code 2.1.329, the version the install check was tried with | Reproducible CI; updates are deliberate |
| D38 | Plugin version (stage 1) | `0.1.0` until the 1.0 release | R39 sets 1.0.0 |
| D39 | Ticket files (stage 1) | Thin: title, R-numbers, scope line, issue link, pointer to this document | Decisions live in one place |
| D40 | AC16 wording (stage 1) | AC16 plants a fake home path other than `someone`; the stage 1 test used a fake `example` user | The old wording planted exactly the allowed placeholder and could not fail |
| D41 | Vocabulary (stage 2) | The English skills use the terms of this document: `Updated`, `Stage n: <title>`, `open`, `done · <date> · <branch>`, `AC1`, Decision log, Open questions (Question, Owner, Blocks). Status markers (status line fields, stage label, stage status) are machine-facing and always written in English. Headings, column names, criterion IDs and user-facing labels such as "(Recommended)" are human-facing and follow the project's language. The per-criterion test plan is called "verification", so it is not confused with the project's checks | One vocabulary across template, skill and existing document; markers the skills parse must not depend on the language, while what people read stays in their language as before (R3) |
| D42 | Legacy terms (stage 2) | Both skills read documents from the German version. The German terms appear only in one exact blockquote per SKILL.md ("Legacy terms from the German version"), split into status markers and headings/columns/IDs. The skills never write the German status markers. AC1 allows exactly that block; the check compares it verbatim and flags any other German | The maintainer's other projects have German requirements documents that must keep working after the switch |
| D43 | Switch to the English skills (stage 2) | After the merge to `main`: move the German copies to `~/.claude/skills-backup-de/` (not deleted), copy `skills/` into `~/.claude/skills`, restart Claude Code, check that both skills show up and read an existing German requirements document correctly, record the SHA in the worklog | Rollback stays possible; the skill version stays fixed and traceable (R25); a half-built stage never runs itself |
| D44 | Third-party wording (stage 2) | The review found passages close to Matt Pocock's `grilling`, `to-tickets` and `tdd` (frontier definition, later-round rule, file paths go stale, tracer slice, one-line seam note). They were rephrased, so no licence notice is needed | R3; the ideas stay and are credited in stage 4 (R17) |
| D45 | AC1 check in the repo (stage 2) | `scripts/check-no-german.sh` checks `skills/` for German outside the legacy block, comparing the block byte for byte. CI runs it on every PR, after a `--self-test` that plants German outside and inside the block and must see both flagged | The check is the evidence for AC1 and has to be reproducible; the self-test keeps a broken check from passing silently |
| D46 | Extra question round (stage 3) | The plan round is the one round of R6. A second round is allowed only for a decision in the ask categories that the plan could not have foreseen; only the dependent part stops, the rest keeps building. The report names the trigger and why the plan missed it, and the worklog counts extra rounds | Unforeseeable scope or security decisions must not be guessed; frequent extra rounds are a signal to improve the plan step |
| D47 | Worklog time (stage 3) | The skill does not estimate or propose a time. It leaves `TODO` and asks the user; at most it shows the run's start and current time, labelled as raw timestamps. Amends R12, which said "proposes a time" | An agent's estimate is not a measured fact |
| D48 | Worklog commit (stage 3) | The stage commit (code and document) stays as before; only the worklog entry waits for the user's OK and time, then gets its own commit. AC10 reworded to match | Keeps the build flow unchanged; the worklog records what the user confirms |
| D49 | Blocked stages (stage 3) | An open question blocks a stage when its "Blocks" column names the stage, one of its R-numbers or ACs; an empty entry or one naming the whole document blocks every stage. The skill no longer asks at the start whether open questions are settled. A refusal names the blocking questions, points to `/grill-ticket <path>` and lists the unblocked open stages. Decided by the agent | R4 says refuse; settling questions is grill-ticket's job; an extra question at the start would break R6's one round |
| D50 | Ticket lookup (stage 3) | On a raw ticket or issue, the skill searches files that start with the status line and matches the ticket against stage lines, a stage-to-ticket rule, the `Ticket:` field, or a link back from the ticket file. The template's stage line gets `· Ticket: <file / #issue>`. Decided by the agent | Covers both the per-stage field and documents like this one that state a mapping rule |
| D51 | REVIEW.md content (stage 3) | Method, the two axes, and a finding format that needs a concrete failure and evidence; no checklist of defect classes. A rule about checks that cannot fail was left out because R11 covers it in the build step (D15). Decided by the agent | R5 and D29: the review must stay generic so the review eval does not measure its own checklist |
| D52 | Labels and security relevance (stage 3) | The "assumption" label follows the project's language, like "(Recommended)" (D41). A stage is security-relevant if the document marks it so or it touches authentication, authorization, secrets, untrusted input, personal data or the security section; attacker-view ACs go into the document's acceptance criteria at close. Decided by the agent | Human-facing labels follow D41; a marker alone would miss unmarked stages |
| D53 | AC11 check (stage 3) | `scripts/check-changelog.sh` with a self-test, run in CI on every PR. Entries are list items (`-`, `*`, `+`, `1.`) below the first `##` heading; a case-study link needs a full 40-character SHA after `/blob/`, `/tree/`, `/raw/` or `/commit/`. Case-study links are pinned to `127aae8`; the R4, R5, R12 and R13 entries link to this repo's stage 3 worklog entry | AC11 stays checked after this stage; the self-test keeps a broken check from passing silently (as in D45) |
| D54 | Verifying stage 3 | AC3 (refusal) and AC8 run headless with `claude -p --plugin-dir` on a scratch project, after a load check of the plugin command. Everything else is one manual run by the maintainer on the same scratch project, also with `--plugin-dir`, never the installed copies. Results per AC go into the worklog | Tests the new version, not the installed one; headless runs cannot answer questions |
| D55 | Free-text "Blocks" entries (stage 3, review) | implement-ticket treats a "Blocks" entry without a stage, R or AC ID as blocking every stage whose requirements it touches, and as blocking when unsure (fail closed). grill-ticket and the template name stages, R-numbers or AC IDs in "Blocks". Asked as the stage's one extra round (D46): the review found it, the plan had not foreseen it | Free text failed open and could let a stage be built on an unsettled decision; older documents keep working |
| D56 | User edits in files the stage touches (stage 3, review) | If a file the skill edits (the worklog included) already had uncommitted changes of the user's, the skill stages only its own hunks or asks; the worklog confirmation names such changes. Decided by the agent | The R7 incident in the case study was exactly a swept worklog note |
| D57 | File locations (stage 4) | `docs/workflow.md`, `docs/install.md`, `templates/CLAUDE.md`, `templates/WORKLOG.md` | Public names; templates at the top level are easy to find and copy |
| D58 | README first screen (stage 4) | Purpose in three sentences, the status line, the diagram, the plain-text line, then the install command; text as confirmed by the maintainer. AC12's first screen is measured at 1280×800 from the README title, because GitHub's repo page puts the file list above the README. The measure was decided by the agent | R14; nothing else is achievable on the repo page |
| D59 | `CLAUDE.md` template (stage 4) | Only what the skills read: language, checks, git and confirmation rules, where requirements and worklog live, must-haves. The `WORKLOG.md` template follows this repo's entry format | Short templates get filled in; every section has a reader |
| D60 | PR refs in the privacy scan (stage 4) | The full-history scan covers all branches and tags, GitHub's `refs/pull/*` (mirror clone) and the text of issues, PRs and comments. Its only match is `planted.md:3` in `7da7cf6`, reachable only from `refs/pull/14/head`: the fake `example` path of D36. Accepted and recorded as a known exception; AC26's "zero matches" applies to branches and tags | PR refs go public with the repo and cannot be deleted without GitHub Support; the match is a fake name planted on purpose |
| D61 | "Pre-push hook over the whole history" (stage 4) | The hook skips commits already on the remote, so the full-history run calls `scripts/privacy-lint.sh` directly with the private list, which is what the hook runs. Decided by the agent | Same rules as the hook, over every commit |
| D62 | Visibility switch (stage 4) | The maintainer switches the repo to public after viewing the README on GitHub. The agent stops after the final scan and hands over the command; after the switch it runs the link check once against the repo's own URLs | Irreversible and outward-facing; the maintainer checks the first screen first |
| D63 | Credits and CHANGELOG (stage 4) | Credits name Matt Pocock's `grilling`, `tdd` and `to-tickets`, linked by permalink at `abeeaf9`, each with the ideas used and where. No CHANGELOG entry, since stage 4 changes neither the skills nor the plugin. Decided by the agent | R17, AC13: every named idea appears in the skills (checked by grep); the CHANGELOG covers skills and plugin |
| D64 | Prevention vs detection (stage 4) | A section in the README and on the workflow page; the report follows in stage 9 (R33) | R18 for the texts that exist now |

## Open questions

| # | Question | Owner | Blocks |
| --- | --- | --- | --- |
| Q1 | `plugin.json` stays at `0.1.0` until the release (D38). Does `claude plugin update` pick up skill changes from GitHub while the version is unchanged, or does it keep the cached copy? Then either bump the version with each skill change, or add a note to the install guide. Found in the stage 4 review; not tested (assumption) | Maintainer and agent, at the latest in stage 12 | Stage 12 |
