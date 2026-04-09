# Agent Communication Protocol

## Execution Loop

```
PLAN -> APPROVE -> DISPATCH (waves) -> EXECUTE -> VERIFY -> LOG -> REPLAN
```

The dispatch script (`dispatch.sh`) enforces this loop:
1. Checks sprint approval status before dispatching
2. Parses task dependencies and builds execution waves
3. Dispatches each wave in parallel, waits for completion
4. Validates results (exit codes, journal entries, status)
5. Failed/blocked tasks cascade to skip downstream dependents
6. Logs all events to `.gorp/journal/dispatch-<sprint>-<date>.log`
7. Auto-dispatches Robo for replanning if failures occur

## Dispatch (Robo -> Agent)

```bash
just sprint-plan              # Plan a sprint
just sprint-approve <name>    # Approve a sprint
just sprint-run <name>        # Full wave-based dispatch
just agent <name>             # Interactive single agent
just dispatch <name> "<task>" # Headless single-task dispatch
```

### Dispatch Prompt Structure

```
## Task
ID: [from sprint table]
Title: [task title]
Agent: [agent name]

## Scope
Files to modify: [list]
Files to read first: [list]

## Acceptance Criteria
- [ ] criterion 1
- [ ] criterion 2

## Rules
- Only modify files within scope
- Don't touch CLAUDE.md, .gorp/plans/roadmap.md
- Conventional commits with scope
- Write journal entry when done
```

## Report (Agent -> Robo)

Agents write reports to `.gorp/journal/<agent>-YYYY-MM-DD.md`:

```markdown
## Task [ID] — [Title]
Status: done | in-progress | blocked
Files: modified file list
Summary: what was done
Blockers: issues encountered (if any)
```

## Blocker Escalation

```markdown
## BLOCKED — [one-line summary]
Severity: low | medium | high | critical
Affected tasks: [IDs]
Context: what was tried, what failed
Suggested fix: best guess
```

## Agent Work Loop

1. **Read dispatch** — load prompt + context files
2. **For each task:**
   a. Set task status to `in-progress` in `current-sprint.md`
   b. Implement within declared scope
   c. Run quality gates
   d. Commit with conventions
   e. Set task status to `done` (or `blocked`)
3. **Write journal entry** with task results

## Journal

One file per agent per day. Append-only during the day.
Format: `.gorp/journal/<agent>-YYYY-MM-DD.md`
