# Key Gotchas

Situational knowledge for agents working in this codebase. Populate as you discover issues.

## Scraper

- Python deps require a venv (`python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt`). macOS blocks system-wide pip installs.
- The API route uses `venv/bin/python3` by default. Override with `PYTHON_BIN` env var if your venv is elsewhere.
- DDG HTML results use `.result__a` selector. URLs are wrapped in DDG redirects — extract from `uddg` query param.

## API Route

- Scraper runs as a subprocess with 15s timeout. If it fails for any reason, the route falls back to mock data from `lib/mock-leads.ts`.
- The route never 500s on scraper failure — that's by design (CTO mandate).

## Enrichment

- Uses `openai/gpt-oss-20b:free` on OpenRouter. The original model (`meta-llama/llama-3.1-8b-instruct:free`) was removed.
- Free tier rate limits aggressively. Enrichment runs sequentially with 500ms delay between calls + retry on 429 (2 retries, exponential backoff).
- Model sometimes wraps JSON in markdown fences despite instructions. `enrich.ts` strips these.
- Individual enrichment failures produce fallback leads ("Unable to enrich" / "Unknown"), never throw.
- Shell env vars override `.env.local`. If `OPENROUTER_API_KEY` is set in your shell, Next.js will use that instead of `.env.local`.

## Frontend

- If dev server returns 500 with `__webpack_modules__[moduleId] is not a function`, the `.next` cache is corrupted. Fix: `rm -rf .next && pnpm dev`.
