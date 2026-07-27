# Key Gotchas

Situational knowledge for agents working in this codebase.

## Scraper

- Python deps require a venv (`python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt`). macOS blocks system-wide pip installs.
- The API route uses `venv/bin/python3` by default. Override with `PYTHON_BIN` env var if your venv is elsewhere.
- DDG HTML results use `.result__a` selector. URLs are wrapped in DDG redirects — extract from `uddg` query param.

## API Route

- Scraper runs as a subprocess with 15s timeout. If it fails for any reason, the route falls back to mock data from `lib/mock-leads.ts`.
- The route never 500s on scraper failure — that's by design (CTO mandate).

## Enrichment

- Uses paid `meta-llama/llama-3.1-8b-instruct` on OpenRouter (~$0.00003/query). Previous models tried: `llama-3.1-8b-instruct:free` (removed), `openai/gpt-oss-20b:free` (rate limited).
- Enrichment runs in parallel via `Promise.all` — paid tier handles concurrent requests fine.
- Model sometimes wraps JSON in markdown fences despite instructions. `enrich.ts` strips these.
- Failed enrichments return `null` and are filtered out — users never see "Unable to enrich".
- Env var is `LEAD_SCRAPER_OPENROUTER_KEY` (not `OPENROUTER_API_KEY`) to avoid collision with shell env vars.

## Frontend

- If dev server returns 500 with `__webpack_modules__[moduleId] is not a function`, the `.next` cache is corrupted. Fix: `rm -rf .next && pnpm dev`.
- Table uses `table-fixed` with explicit column widths (22/18/44/16%) to prevent summary/category from being pushed off-screen.
