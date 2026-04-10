# AI Lead Scraper + Enricher

**Enter a search query and get back clean, AI-enriched leads you can actually use.**

This is a simple example of how AI can turn raw search data into something structured and usable.

It shows how repetitive research tasks can be automated in a lightweight, fast way.

---

## Demo

![Demo GIF](./public/demo.gif)

---

## Overview

Finding leads manually is time-consuming, and cleaning that data takes even longer.

This tool takes a simple search query and turns it into structured, usable lead data in one step.

---

## What You Get

For any search, the tool returns a small set of relevant, enriched leads:

- **5-10 businesses** pulled from search

- Short, readable summaries

- Simple categories for quick scanning

All generated in one step, with **no manual cleanup required**.

![Screenshot](./public/screenshot.png)

---

## Example

Search: `miami dental clinics`

| Name | Summary | Category |
|------|---------|----------|
| 5 Best Dental Clinics in Miami | Guide listing top clinics | Dental Services |

---

## Why This Matters

Instead of jumping between tabs and cleaning data by hand, you get a quick, structured view of potential leads, ready to act on.

---

## Use Cases

This pattern can be used for:

- Lead generation for sales teams
- Market research and competitor discovery
- Pulling and summarizing business data
- Automating repetitive data collection workflows

The same approach can be adapted to different data sources and workflows.

---

## Run Locally (Optional)

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

This is a lightweight demo showing how AI-powered automation can be applied to real workflows.
