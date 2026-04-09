# AI Lead Scraper + Enricher

Scrapes DuckDuckGo results and enriches them into structured leads with AI.

## Why

Manual lead research is slow. This demo turns a raw search query into structured, enriched lead data in seconds — proving that search scraping + AI enrichment can be wired together into a usable pipeline.

**Business value:** Supports the AI automation offer by demonstrating a practical end-to-end workflow.

## What It Does

1. You enter a search query (e.g. "miami dental clinics")
2. The app scrapes DuckDuckGo HTML results
3. It extracts titles and URLs from the results
4. Each result is sent to an AI model for enrichment
5. You get back a table with structured lead data:

| Name | URL | Summary | Category |
|------|-----|---------|----------|
| 5 Best Dental Clinics in Miami | slicemiami.com | A blog post listing and reviewing the top five dental clinics in Miami | Dental Services |
| Dental Blush - Trusted Dental Clinic Miami | dentalblush.com | Dental Blush is a trusted dental clinic in Miami offering cosmetic and general dentistry | Dental Clinic |

5-8 rows per query. That's it.

## Stack

| Layer | Tech |
|-------|------|
| Frontend | Next.js + React + TypeScript + Tailwind v4 |
| API | Next.js API route |
| Scraper | Python + requests + BeautifulSoup4 |
| AI | OpenRouter (openai/gpt-oss-20b:free) |

## Scope

**In scope:** Single page UI, query input, DDG scrape, AI enrichment, results table, scraper fallback to mock data.

**Out of scope:** Auth, database, exports, pagination, background jobs, crawl depth, fancy design.

## Quick Start

### Prerequisites

- Node.js 20+
- pnpm
- Python 3.10+

### Setup

```bash
# Install JS dependencies
pnpm install

# Create Python venv and install deps
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Set up environment
cp .env.example .env.local
# Edit .env.local and add your OpenRouter API key

# Start dev server
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) and enter a search query.

### Test Queries

- `miami dental clinics`
- `ecommerce skincare brands`
- `saas payroll startups`

## Architecture

```
User -> [Next.js Page] -> POST /api/leads -> [Python Scraper] -> RawLead[]
                                          -> [OpenRouter AI]  -> Lead[]
                                          -> (mock fallback if scraper fails)
```

- Scraper runs as a Python subprocess, returns JSON to stdout
- If scraper fails for any reason, API falls back to mock data
- Enrichment calls OpenRouter sequentially with retry on rate limits
- Each lead gets a 1-sentence summary and 1-2 word category

## Project Structure

```
├── app/
│   ├── page.tsx              # Search UI + results table
│   └── api/leads/route.ts    # Scrape + enrich endpoint
├── lib/
│   ├── types.ts              # RawLead, Lead, request/response types
│   ├── enrich.ts             # OpenRouter enrichment with retry
│   └── mock-leads.ts         # Fallback mock data
├── scripts/
│   └── scrape.py             # DDG HTML scraper
├── .env.example              # Environment template
├── requirements.txt          # Python dependencies
└── CLAUDE.md                 # Full project spec
```

## Development

This repo uses a multiagent orchestration system. See `CLAUDE.md` for the full spec.

```bash
just sprint-plan    # Plan a sprint with Robo
just agent backend  # Launch backend agent
just gate           # Run quality gates
just status         # Check sprint status
```

## Status

**Phase 1 — Scaffold:** Complete
**Phase 2 — Implementation:** Complete
**Phase 3 — Polish:** Complete (screenshot pending)
