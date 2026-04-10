# AI Lead Scraper + Enricher

**Enter a search query and get back clean, AI-enriched leads you can actually use.**

---

## Demo

![Demo GIF](./public/demo.gif)

![Screenshot](./public/screenshot.png)

---

## Overview

Finding leads manually is time-consuming — and cleaning that data takes even longer.

This tool takes a simple search query and turns it into **structured, usable lead data** in one step.

---

## What You Get

For any search, the tool returns a small set of relevant, enriched leads:

- **5-10 businesses** pulled from search
- Short, readable summaries
- Simple categories for quick scanning

All generated in one step — **no manual cleanup required**.

---

## Example

Search: `miami dental clinics`

| Name | Summary | Category |
|------|---------|----------|
| 5 Best Dental Clinics in Miami | Guide listing top clinics | Dental Services |

---

## Why This Matters

Instead of jumping between tabs and cleaning data by hand, you get a quick, structured view of potential leads — ready to act on.

---

## Run Locally

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
