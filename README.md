# AI Lead Scraper + Enricher

Scrapes search results and turns them into structured, AI-enriched leads.

---

## Demo

![Demo Screenshot](./public/screenshot.png)

---

## Problem

Manual lead research is slow and messy.

---

## Solution

Automates scraping + enrichment into usable lead data.

---

## Features

- Scrape DuckDuckGo results
- Extract names + URLs
- Enrich with AI (summary + category)
- Display in clean table

---

## Example

**Query:**
`miami dental clinics`

**Output:**
5-8 enriched leads with summaries + categories

| Name | URL | Summary | Category |
|------|-----|---------|----------|
| 5 Best Dental Clinics in Miami | slicemiami.com | A guide listing the top five dental clinics in Miami | Dental Services |
| Dental Blush | dentalblush.com | Trusted dental clinic in Miami offering cosmetic and general dentistry | Dental Clinic |
| Ultra Smile DentalSpa | ultrasmilemiami.com | Offers comprehensive dental services including cosmetic and restorative treatments | Dental Clinic |

---

## Stack

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

Run:

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## Notes

Built as a fast demo for AI automation workflows.
