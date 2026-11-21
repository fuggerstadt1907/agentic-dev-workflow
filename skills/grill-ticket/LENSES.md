# Lenses (definition of ready)

Every ticket is checked through all eleven lenses. The prompts are starting points for
questioning, not a checklist to tick off. Attach project-specific must-haves from the pre-check
(step 2) to the matching lens.

A lens is `clear` when you can write it into the document without an assumption of your own.

## 1. Problem and goal

- Whose problem is this, and how do they solve it today?
- How do we know it is solved (an observable success criterion)?
- Why now? What happens if we do not build it?

## 2. Actors and roles

- Who uses it, and who is affected without using it?
- Who may see, create, change, delete what? What happens when a role changes or someone leaves?

## 3. Behaviour and acceptance criteria

- What exactly happens, step by step? As numbered requirements (R1, R2 …).
- Every requirement gets at least one testable acceptance criterion (Given/When/Then).
- Are there numbers, limits, orderings, defaults?

## 4. Edge cases and failure modes

- Empty, very large, duplicate, concurrent, retroactive, time zones and date boundaries.
- Offline, interrupted halfway, missing permissions, the other side deleted.
- What does the person see when something goes wrong, and can they fix it?

## 5. UX/UI and texts

- Where in the product does it live? A new screen or an extension of an existing one?
- Empty states, loading states, confirmations, feedback.
- Texts and languages; project-specific UI guidelines.

## 6. Data and schema

- New or changed entities, fields, relations.
- What happens to existing data (migration, defaults, backfill)?
- Lifetime: when is something deleted or archived?

## 7. Security and data protection

- Who may read and write the data, and where is that enforced (server, not only client)?
- Personal data? Does the privacy policy need to change?
- Abuse: spam, rate limits, snooping on other people's data.

## 8. Dependencies

- Other features, tickets or decisions that must be in place first.
- Backend, external services, third parties, accounts, costs.
- Does the other side need a new app or client version for this to work?

## 9. Rollout and release

- Is a plain code update enough, or does it need a new native build, a deploy or a migration?
- Order of delivery (schema before client?), feature flag, minimum version.
- What do existing users see the first time they open it afterwards?

## 10. Non-goals

- What explicitly does not belong to it, even though someone might expect it?
- What might come later (as an outlook, not as a requirement)?

## 11. Docs and help

- Which project docs, help articles, tours, release notes, website texts change?
