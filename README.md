# Lead Scraper + Enrichment Pipeline

Request-scoped scrape-and-enrich demo that runs a Python DuckDuckGo scraper from a Next.js API route, parses JSON results through a subprocess boundary, enriches each lead through an LLM classification step, and returns typed records to the UI.

Built as a workflow automation demo — one of several projects demonstrating how scraping, subprocess orchestration, and AI-assisted classification combine into a practical data pipeline.

---

## How It Works

```
User query
  |
  v
POST /api/leads          (Next.js API route)
  |
  v
execFile python3          (subprocess boundary, 15s timeout)
  |
  v
scripts/scrape.py         (DuckDuckGo HTML fetch + BeautifulSoup parse)
  |
  v
JSON stdout -> parse      (RawLead[] — name + url per result)
  |
  v
enrichLeads()             (Promise.all — parallel OpenRouter calls)
  |
  v
LLM classification        (Llama 3.1 8B via OpenRouter — summary + category)
  |
  v
Lead[]                    (typed response to UI)
```

If the scraper fails or returns no results, the API falls back to mock data so the enrichment step always has input.

---

## Stack

| Layer | Tech |
|-------|------|
| App | Next.js 15.3.1 (App Router) |
| UI | React 19 + TypeScript + Tailwind CSS 4 |
| API | Next.js API route (`app/api/leads/route.ts`) |
| Scraper | Python 3 + requests + BeautifulSoup4 |
| Enrichment | OpenRouter (`meta-llama/llama-3.1-8b-instruct`) |
| Task runner | [just](https://github.com/casey/just) |

---

## Key Implementation Details

### Subprocess Boundary

The API route calls the Python scraper via `execFile` (not `exec`) with a 15-second timeout. The scraper prints a JSON array to stdout, which the API route parses directly. No HTTP server, no IPC — just process invocation and stdout capture.

```typescript
const { stdout } = await execFileAsync(PYTHON_BIN, [SCRAPER_PATH, query], {
  timeout: 15_000,
});
const parsed = JSON.parse(stdout);
```

`execFile` is used over `exec` to avoid shell interpolation of the query string.

### DuckDuckGo Scraping

The Python script fetches DDG's HTML search endpoint (`html.duckduckgo.com/html/`), parses result links with BeautifulSoup (`.result__a` selector), and unwraps DDG's redirect URLs by extracting the `uddg` query parameter from each href. Results are capped at 8.

### LLM Enrichment

Each `RawLead` (name + URL) is sent to OpenRouter's Llama 3.1 8B Instruct model with a system prompt requesting a JSON object with `summary` and `category` fields. All leads are enriched in parallel via `Promise.all`.

The enrichment step handles:

- **Markdown-wrapped JSON** — strips `` ```json `` fences before parsing
- **429 rate limiting** — single retry after 1-second delay
- **Transient errors** — single retry with backoff, then returns `null`
- **Missing fields** — validates that both `summary` and `category` are present strings
- **Graceful failure** — failed enrichments are filtered out, never throw

### Mock Fallback

When the Python scraper is unavailable or returns no results, the API substitutes mock `RawLead` data generated from the query string. This ensures the enrichment pipeline always has input and the demo remains functional without a working Python environment.

### Data Contracts

```typescript
type RawLead = { name: string; url: string }              // scraper output
type Lead    = { name: string; url: string;                // enriched output
                 summary: string; category: string }
```

The transformation is `RawLead[] -> enrichLeads() -> Lead[]`. Enrichment adds `summary` and `category` via LLM classification.

---

## Project Structure

```
ai-lead-enricher/
├── app/
│   ├── page.tsx                  # Single-page UI (query input, results table)
│   └── api/leads/route.ts        # POST endpoint — scrape, enrich, respond
├── lib/
│   ├── types.ts                  # RawLead, Lead, request/response types
│   ├── enrich.ts                 # OpenRouter enrichment (parallel, retry, defensive parsing)
│   └── mock-leads.ts             # Fallback mock data generator
├── scripts/
│   ├── scrape.py                 # DDG HTML scraper (BeautifulSoup, stdout JSON)
│   ├── quality-gate.sh           # Type check + lint + build gates
│   └── dispatch.sh               # Multi-agent dispatch runner
├── Justfile                      # Task runner targets
├── .env.example                  # Environment variable template
├── requirements.txt              # Python dependencies
└── docs/assets/                  # Screenshots and demo GIF
```

---

## Setup

### Prerequisites

- Node.js 20+
- pnpm
- Python 3.10+
- [just](https://github.com/casey/just) (`brew install just`)

### Local Development

```bash
pnpm install
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env.local        # add your LEAD_SCRAPER_OPENROUTER_KEY
pnpm dev
```

Or with `just`:

```bash
just install
just dev
```

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `LEAD_SCRAPER_OPENROUTER_KEY` | Yes | OpenRouter API key for LLM enrichment |
| `PYTHON_BIN` | No | Path to Python binary (defaults to `venv/bin/python3`) |

---

## Quality Gates

Run all gates with `just gate` or individually:

| Gate | Command | What it checks |
|------|---------|----------------|
| Type check | `just types` | `tsc --noEmit` |
| Lint | `just lint` | `eslint . --max-warnings 0` |
| Build | `just build` | `next build` |

---

## Agent Orchestration (Development Tooling)

This repo includes a multi-agent dispatch system used during development. It is **not part of the runtime application** — it is development tooling for coordinating work across the codebase.

Agents are defined in `.claude/agents/` and orchestrated via `just` targets:

| Agent | Role |
|-------|------|
| robo | Sprint planning and dispatch |
| architect | Type definitions and API contracts |
| backend | API route, enrichment, scraper integration |
| frontend | UI components and interactions |
| qa | Validation and quality checks |

```bash
just sprint-plan          # Plan a sprint interactively
just sprint-run <name>    # Dispatch agents in waves
just agent <name>         # Launch a single agent
just status               # View sprint progress
```

---

## Known Limitations

- **No persistent storage** — all data is ephemeral per request
- **No authentication** — open demo, no access control
- **No tests** — demo project, no test suite
- **No CI/CD** — no automated pipeline
- **No deployment configuration** — local development only
- **No proxy rotation or rate limiting** — single-origin DDG requests
- **No pagination** — returns up to 8 results per query
- **DDG HTML endpoint** — unofficial, may change without notice
- **Single retry on 429** — minimal retry strategy, not production-grade
- **Mock fallback masks failures** — scraper errors are silent to the user

---

## License

Source available for technical review. No open-source license is currently provided.
