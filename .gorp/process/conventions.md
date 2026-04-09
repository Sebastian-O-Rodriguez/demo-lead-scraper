# Conventions

## Git

- **Branches**: `feat/`, `fix/`, `chore/`, `docs/`
- **Branch format**: `<prefix>/<sprint>-<agent>-<task-slug>` (e.g. `feat/phase2-backend-api-route`)
- **Commits**: Conventional format — `type(scope): description`
- **Scopes**: app, api, ui, scraper, enrich, infra, docs
- **Author flag**: `--author="Gorp, Guava AI <gorp@guava.ai>"`
- **Co-Author tag**: `Co-Authored-By: Gorp, Guava AI <gorp@guava.ai>`
- **Never push directly to main** — feature branches + PRs

## Push & PR Convention

- Agents push their branch when task is complete
- One PR per task group (not per individual task)
- PR title: `[Phase-X/<Agent>] <group description>`
- Robo or owner merges after QA sign-off

## Sprint

- `.gorp/plans/roadmap.md` — CTO-maintained, agents never modify
- `.gorp/plans/current-sprint.md` — active task breakdown
- `.gorp/plans/sprints/` — archived sprint docs
- `.gorp/journal/` — one file per agent per day
- Sprint tasks must have: ID, agent, title, status, acceptance criteria

## Code

- TypeScript strict mode
- No `any` types
- Tailwind for styling (no CSS modules, no styled-components)
- Python follows standard conventions (no linter enforced for demo)

## Doc Convention

- Max ~100 lines per doc. If longer, split and link.

## Task Runner

All project operations go through the `Justfile`. Run `just help` to see all targets.

## Quality

Run before every PR via `just gate`:
```bash
just types    # pnpm tsc --noEmit
just lint     # pnpm eslint .
just build    # pnpm build
```
