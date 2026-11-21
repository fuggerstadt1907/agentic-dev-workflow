# Changelog

Changes to the skills and the plugin. Every entry links to the worklog entry that caused it.
Links into the case study, `mcp-project-context`, are permalinks pinned to a commit SHA; later
entries link to this repo's [worklog](docs/WORKLOG.md).

## Unreleased

### Added

- implement-ticket: the review instructions live in `skills/implement-ticket/REVIEW.md`, and the
  skill hands their full text to a fresh subagent instead of delegating to another review skill.
  Users get the review the evals measure. ([worklog, stage 3](docs/WORKLOG.md#2026-11-21--stage-3-skills-10))
- implement-ticket: a worklog step. If the project has a `WORKLOG.md`, the skill drafts the stage's
  entry with the time left as `TODO`, and commits it only after the user's OK and time.
  ([worklog, stage 3](docs/WORKLOG.md#2026-11-21--stage-3-skills-10))
- implement-ticket: a security-relevant stage gets acceptance criteria written from an attacker's
  view before building. In the case study, security gaps surfaced only in review.
  ([case study, ticket 02](https://github.com/fuggerstadt1907/mcp-project-context/blob/127aae84a569510ddb2f63244731b573992d511f/docs/WORKLOG.md#L109-L111),
  [ticket 03](https://github.com/fuggerstadt1907/mcp-project-context/blob/127aae84a569510ddb2f63244731b573992d511f/docs/WORKLOG.md#L144-L157))
- implement-ticket: every negative test or check gets a positive check that what it looks for is
  really in the input.
  ([case study, ticket 09](https://github.com/fuggerstadt1907/mcp-project-context/blob/127aae84a569510ddb2f63244731b573992d511f/docs/WORKLOG.md#L545-L546))
- This changelog. ([worklog, stage 3](docs/WORKLOG.md#2026-11-21--stage-3-skills-10))

### Changed

- implement-ticket: decides implementation details itself and records them in the decision log.
  It asks only about scope, public output, security behaviour, contradictions with a doc or ADR,
  and decisions that are hard to undo, in one round per stage.
  ([case study, ticket 03](https://github.com/fuggerstadt1907/mcp-project-context/blob/127aae84a569510ddb2f63244731b573992d511f/docs/WORKLOG.md#L761-L764))
- implement-ticket: stages explicit paths only, never `git add -A` or `git add .`.
  ([case study, ticket 03](https://github.com/fuggerstadt1907/mcp-project-context/blob/127aae84a569510ddb2f63244731b573992d511f/docs/WORKLOG.md#L765-L766))
- Both skills: a question that rests on a technical claim says how the claim was verified, or
  marks it as an assumption.
  ([case study, ticket 12](https://github.com/fuggerstadt1907/mcp-project-context/blob/127aae84a569510ddb2f63244731b573992d511f/docs/WORKLOG.md#L768-L771))
- implement-ticket: when it refuses a raw ticket, it names the requirements document and stage
  that cover it. The requirements template maps each stage to its ticket.
  ([case study, ticket 01](https://github.com/fuggerstadt1907/mcp-project-context/blob/127aae84a569510ddb2f63244731b573992d511f/docs/WORKLOG.md#L751-L759))
- implement-ticket: builds a stage of a `not ready` document when no open question blocks it, and
  refuses a blocked stage by naming the blocking questions. It no longer asks whether open
  questions were settled. ([worklog, stage 3](docs/WORKLOG.md#2026-11-21--stage-3-skills-10))
- Both skills are in English and keep working in the project's language; they still read
  documents written with the German version.
  ([worklog, stage 2](docs/WORKLOG.md#2026-11-21--stage-2-skills-in-english))
- The repo is a Claude Code plugin and marketplace, `agentic-dev-workflow`, with both skills.
  ([worklog, stage 1](docs/WORKLOG.md#2026-11-21--stage-1-repo-skeleton-private))
