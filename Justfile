# AI Lead Scraper + Enricher — Justfile
# Usage: just <target> [args...]

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Journal / monitoring
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Scraper
# ---------------------------------------------------------------------------

# Run the scraper standalone for testing
scrape QUERY:
    python scripts/scrape.py "{{QUERY}}"

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

# Remove build artifacts
clean:

# List all available targets
help:
    @just --list
