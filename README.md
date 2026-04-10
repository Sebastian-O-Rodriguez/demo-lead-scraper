# AI Lead Scraper + Enricher

**Turn a search query into usable, AI-cleaned leads in seconds.**

---

## Demo

<img src="./public/demo.gif" alt="Demo GIF" width="800" />

<img src="./public/screenshot.png" alt="Demo Screenshot" width="800" />

---

## What You Get

- 5-10 relevant leads from a simple search
- Clean summaries of each business
- Categorized results (no manual sorting)

All generated in one step.

---

## Problem

Finding and cleaning leads manually takes time and breaks focus.

---

## Solution

This tool pulls search results and turns them into structured, usable lead data instantly.

---

## What It Does

- Pulls results from search
- Extracts key business info
- Uses AI to summarize and categorize
- Outputs ready-to-use leads

---

## Example

**Query:** `miami dental clinics`

**Output:** 5-8 enriched leads, each with a summary + category

| Name | Summary | Category |
|------|---------|----------|
| 5 Best Dental Clinics in Miami | Guide listing top dental clinics in Miami | Dental Services |

---

## Why This Matters

- Saves time on lead research
- Removes manual cleanup
- Turns raw search into usable data fast

---

## Tech (for reference)

- Next.js, React, TypeScript
- Python (BeautifulSoup)
- OpenRouter

---

## How to Run

```bash
git clone https://github.com/Sebastian-O-Rodriguez/demo-lead-scraper.git
cd demo-lead-scraper
pnpm install
python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt
```

Create `.env.local`:
```
LEAD_SCRAPER_OPENROUTER_KEY=your_key_here
```

```bash
pnpm dev
```

---

## Note

Built as a fast demo of AI-powered automation for real business workflows.
