# Requirements document template

Headings, column names and criterion IDs (`AC1`) in the project's language. The status line
fields (`Status`, `Ticket`, `Updated`), the stage label (`Stage`) and the stage status (`open`,
`done`) stay in English, because `/implement-ticket` reads them. Sections whose lens is confirmed
not relevant stay in with one sentence ("No schema change.") so it is visible that they were
checked.

```markdown
# <Title>

> Status: ready | not ready · Ticket: <#123 / link / file path / "free text"> · Updated: <YYYY-MM-DD>

## Summary

2–3 sentences: what, for whom, why.

## Problem and goal

The problem as the people affected see it. Success criterion.

## Actors and roles

Who may do what, as a list or table.

## Requirements

- **R1** – …
- **R2** – …

### Acceptance criteria

- **AC1 (R1)** – Given … When … Then …

## Edge cases and failure modes

## UX/UI and texts

## Data and schema

## Security and data protection

## Dependencies

## Target picture (solution)

Affected areas, data model, interfaces. Every decision with a short reason and the rejected
alternative.

### Stages

Only where it makes sense. Per stage: scope (R-numbers), why it is deliverable and testable on its
own, and a status (`open`, later set by `/implement-ticket` to `done · <date> · <branch>`).

- **Stage 1: <title>** · open · R1, R2 – …

## Rollout and release

## Non-goals

## Docs and help

## Decision log

| #   | Question | Decision | Reason |
| --- | -------- | -------- | ------ |

## Open questions

| #   | Question | Owner | Blocks |
| --- | -------- | ----- | ------ |
```
