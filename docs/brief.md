# Brief: agentic-dev-workflow

> Status: draft · input for /grill-ticket · not yet requirements

## Problem

Coding agents write code fast. Teams struggle with three things:

1. Agents build on unclear or contradictory requirements and fill gaps with assumptions.
2. The agent that wrote the code also judges it, so its own blind spots survive review.
3. Nobody measures whether a prompt or skill actually works, or whether a change made it worse.

## Goal

A public repository that shows a complete, measured workflow for agentic development:

- Two Claude Code skills, `grill-ticket` and `implement-ticket`, that a team can install.
- An eval harness that measures what the skills claim to do, compared against a plain-prompt baseline.
- A case study: `mcp-project-context`, built entirely with these skills, with its public worklog.

Success means: a reviewer understands the workflow in two minutes, can install it in five, and can
see numbers that show where the skills help and where they do not.

## Non-goals

- No general prompt library. Two skills, done well.
- No claims beyond what the evals measure. One model, small sample, stated openly.
- No customer or employer content. Skills from other projects stay private.

## Scope

### Skills (version 1.0)

- `grill-ticket`: requirements interview, finds contradictions between ticket, docs and code,
  writes a requirements document with status, decision log and stages.
- `implement-ticket`: accepts only ready documents, plan with checkpoints, thin slices, review by
  a fresh subagent, one commit per stage, worklog draft.
- Fold in the lessons from the case study before 1.0. Candidates (to confirm in the interview):
  - Decide implementation details yourself, ask only about scope, public output, security,
    ADR conflicts or irreversible choices (CLAUDE.md rule 7 in the case study).
  - Never `git add -A`; stage explicit paths.
  - When a question rests on a technical claim, say how it was verified or mark it as an
    assumption.
  - On refusal, suggest the matching requirements document and stage instead of only
    "skip precondition".
- A CHANGELOG that links each change to the worklog entry that caused it.

### Install and docs

- Install per user (`~/.claude/skills`) or per repo (`.claude/skills`). Check whether a Claude Code
  plugin is the better delivery format.
- One page that explains the workflow with a diagram: brief → grill → requirements → implement
  (plan, slice, fresh review, commit) → worklog.
- A template for `CLAUDE.md` and `WORKLOG.md`.

### Evals

Two evals, one per skill. Each compares the skill against a baseline prompt with the same model.

**Review eval (implement-ticket, review step)**
- Cases: small diffs with one planted defect each, written by hand. Seed them from real findings
  in the case study worklog, for example: case-sensitive deny list on macOS, overlapping redaction
  matches, slug lowercasing that breaks a secret pattern, schema that silently drops unknown
  fields, a negative test that can never fail.
- Plus clean diffs with no defect, to measure false alarms.
- Metrics: defect found (yes/no), false findings per clean diff, tokens, duration.

**Grill eval (grill-ticket)**
- Cases: a ticket plus a small fixture repo with planted contradictions and gaps, written by hand
  (for example: ticket says filename is the id, docs say frontmatter is the id).
- Metrics: planted issues surfaced, questions that are noise, number of questions.

**Method**
- Run each case several times (start with 3) per variant; report mean and spread.
- Scoring: deterministic checks first; LLM-as-judge only to match a free-text finding to a
  planted issue, with a fixed rubric. Validate the judge against a hand-labelled sample.
- The human writes every case and every expected answer. The model does not generate test cases.
- Results are committed as data, not only as a conclusion.

**Execution (to clarify)**
- Options: headless `claude -p` in a temp copy of a fixture, the Claude Agent SDK, or promptfoo.
  Pick by: can it load the skill as-is, does it capture tool calls and tokens, can it run in CI.
- Cost: estimate per full run before building it; set a spending limit on the API key.

### CI

- Lint and validate skill files on every PR (frontmatter, links, no private paths).
- Evals run on changes under `skills/` and on manual dispatch, not on every PR.
- A drop below the last committed result beyond the noise margin fails the run.

### Case study

- Link to `mcp-project-context` and its worklog: 12 stages, 1,131 tests, 75 review findings.
- Show two or three findings the fresh review caught and the same author missed.
- Be honest about what the skills did not catch, such as the npx issue found only in a fresh clone.

## Open questions for the interview

1. Delivery: plain skill folders, a Claude Code plugin, or both?
2. Eval runner: headless CLI, Agent SDK or promptfoo? What does each cost per run?
3. How many cases are enough for a first honest result (proposal: 8 review, 5 grill)?
4. Baseline prompt: what exactly does "plain prompt" mean, so the comparison is fair?
5. Judge model and rubric; how many hand-labelled samples to validate it?
6. Which lessons from the case study go into skills 1.0, which wait?
7. Licence: MIT like the case study? Attribution for ideas taken from others (for example
   Matt Pocock's "grill me" idea)?
8. Language of skills and docs: English only?

## Proposed stages (to refine)

1. Repo skeleton, licence, README stub, CI lint for skill files
2. Skills 1.0 with case-study lessons and CHANGELOG
3. Install guide, workflow page with diagram, CLAUDE.md and WORKLOG templates
4. Eval runner skeleton: one case, one variant, captures output, tokens and duration
5. Review cases (human-written) and baseline prompt
6. Review eval scoring and judge validation
7. Grill cases (human-written) and grill eval
8. Report: results data, markdown report, README table
9. CI for evals with threshold and cost cap
10. Case study page
11. Release 1.0
