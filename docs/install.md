# Install

Both skills ship as one Claude Code plugin, `agentic-dev-workflow`, from a marketplace of the same
name. Copying the skill folders works too.

## As a plugin (recommended)

Inside Claude Code:

```text
/plugin marketplace add fuggerstadt1907/agentic-dev-workflow
/plugin install agentic-dev-workflow@agentic-dev-workflow
```

The same from a shell:

```bash
claude plugin marketplace add fuggerstadt1907/agentic-dev-workflow
claude plugin install agentic-dev-workflow@agentic-dev-workflow
claude plugin details agentic-dev-workflow   # lists: Skills (2) grill-ticket, implement-ticket
```

Restart Claude Code or start a new session, then type `/grill-ticket` to check that the skill
shows up.

**Update** from a shell, then restart Claude Code:

```bash
claude plugin marketplace update agentic-dev-workflow
claude plugin update agentic-dev-workflow@agentic-dev-workflow
```

## By copying the skills

For all your projects:

```bash
git clone https://github.com/fuggerstadt1907/agentic-dev-workflow.git
mkdir -p ~/.claude/skills
cp -R agentic-dev-workflow/skills/grill-ticket agentic-dev-workflow/skills/implement-ticket ~/.claude/skills/
```

For one project only, copy the two folders into `<project>/.claude/skills/` instead.

**Update:** pull the clone and copy the folders again.

Install one way only. With both, the same skill name exists twice and you need the namespaced form
to pick the plugin's version.

## Skill names

The short form (`/grill-ticket`, `/implement-ticket`) works as long as no other installed skill has
the same name. The plugin's namespaced form always works:

```text
/agentic-dev-workflow:grill-ticket
/agentic-dev-workflow:implement-ticket
```

## Setting up a project

The skills work in any git repository. Two optional files help them:

- **`CLAUDE.md`** (or `AGENTS.md`): language, check commands, git conventions and what needs your
  confirmation. Both skills read it. Start from the [template](../templates/CLAUDE.md).
- **`WORKLOG.md`**: if it exists, `implement-ticket` drafts one entry per stage. Without it there
  is no worklog step. Start from the [template](../templates/WORKLOG.md).

Then follow the [workflow](workflow.md): `/grill-ticket <ticket>` first, then
`/implement-ticket <requirements document>` once per stage, with `/clear` in between.
