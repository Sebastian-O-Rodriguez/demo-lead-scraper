# AI Lead Scraper + Enricher

**Enter a search query and get back clean, AI-enriched leads you can actually use.**

---

## Demo

<img src="./public/demo.gif" alt="Demo GIF" width="800" />

<img src="./public/screenshot.png" alt="Demo Screenshot" width="800" />

Here's what the tool produces:

---

## What You Get

For any search, the tool returns a small set of relevant, enriched leads:

- 5-10 businesses pulled from search
- Short, readable summaries
- Simple categories for quick scanning

Everything is generated in one pass, with no manual cleanup needed.

---

## Overview

Finding leads manually is time-consuming — and cleaning that data takes even longer.

This tool takes a simple search query and turns it into structured, usable lead data in one step.

---

## Example

For example:

**Search:** `miami dental clinics`

**Result:** A list of local clinics, each with a short description and category — ready to review or use immediately.

| Name | Summary | Category |
|------|---------|----------|
| 5 Best Dental Clinics in Miami | Guide listing top dental clinics in Miami | Dental Services |

---

## Why This Matters

Instead of jumping between tabs and cleaning data by hand, you get a quick, structured view of potential leads — ready to act on.

---

## Run Locally

If you want to try it yourself:

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

## Tech Stack (Optional)

- Next.js, React, TypeScript
- Python (BeautifulSoup)
- OpenRouter

---

## Note

Built as a fast demo of AI-powered automation for real business workflows.
