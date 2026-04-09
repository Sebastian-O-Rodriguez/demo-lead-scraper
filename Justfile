# AI Lead Scraper + Enricher — Justfile
# Usage: just <target> [args...]

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

SPRINT_FILE  := ".gorp/plans/current-sprint.md"
JOURNAL_DIR  := ".gorp/journal"
DATE         := `date +%Y-%m-%d`

# ---------------------------------------------------------------------------
# Development
# ---------------------------------------------------------------------------

# Start Next.js dev server
dev:
    pnpm dev

# Install all dependencies
install:
    pnpm install
    pip install -r requirements.txt

# ---------------------------------------------------------------------------
# Sprint lifecycle
# ---------------------------------------------------------------------------

# Launch Robo in interactive mode to plan a sprint
sprint-plan:
    claude --agent robo

# Mark a sprint as approved and tag it in git
sprint-approve NAME:
    sed -i '' 's/Status: Planning/Status: Approved/' {{SPRINT_FILE}}
    git add {{SPRINT_FILE}}
    git commit -m "sprint({{NAME}}): approved on {{DATE}}"
    git tag "sprint/{{NAME}}/approved"

# Run the hardened dispatch script for a sprint
sprint-run NAME:
    ./scripts/dispatch.sh {{NAME}}

# Show current sprint status
sprint-status:
    grep -A 100 '| Task' {{SPRINT_FILE}} | grep '|'

# ---------------------------------------------------------------------------
# Quality gates
# ---------------------------------------------------------------------------

# Run quality gate checks
gate TARGET='all':
    ./scripts/quality-gate.sh {{TARGET}}

# Type-check the project
types: (gate "types")

# Lint the project
lint: (gate "lint")

# Build the project
build: (gate "build")

# ---------------------------------------------------------------------------
# Agent operations
# ---------------------------------------------------------------------------

# Launch an agent interactively
agent NAME:
    claude --agent {{NAME}}

# Dispatch a single agent with a task prompt headlessly
dispatch AGENT TASK:
    claude --agent {{AGENT}} --print "{{TASK}}"

# ---------------------------------------------------------------------------
# Journal / monitoring
# ---------------------------------------------------------------------------

# Show the latest journal entry for an agent
journal AGENT:
    cat "$(ls -t {{JOURNAL_DIR}}/{{AGENT}}-*.md | head -1)"

# Show current sprint status (alias)
status: sprint-status

# Show the dispatch log for a sprint
log SPRINT:
    cat {{JOURNAL_DIR}}/dispatch-{{SPRINT}}-*.log

# ---------------------------------------------------------------------------
# Scraper
# ---------------------------------------------------------------------------

# Run the scraper standalone for testing
scrape QUERY:
    python scripts/scrape.py "{{QUERY}}"

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

# Remove dispatch JSON output files
clean:
    rm -f {{JOURNAL_DIR}}/*.json

# List all available targets
help:
    @just --list
