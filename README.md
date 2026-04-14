# AI Lead Scraper and Enricher

### Enter a search query → get structured lead data in seconds

Built for teams doing manual prospect research.

No manual research. No cleanup.

---

## Demo

![Demo GIF](./public/demo.gif)

---

## What You Get

For any search, the tool returns:

- **5-10 relevant businesses**
- Short summaries for each business
- Categories to scan results quickly

No manual cleanup required.

---

## Example

Search: `miami dental clinics`

| Name | Summary | Category |
|------|---------|----------|
| 5 Best Dental Clinics in Miami | Guide listing top clinics | Dental Services |

Each result is cleaned and categorized, ready to review or use immediately.

---

## Why This Matters

Skip the manual research loop. No tabs, no copy-pasting, no spreadsheet cleanup. One query returns structured leads you can act on.

---

## Use Cases

- Building lead lists from search results
- Scanning new markets or competitors
- Turning raw search data into structured datasets

---

> This generates leads. The next step is tracking and acting on them.

---

## Built by Guava AI

We build tools like this in 48 to 72 hours.

If your team is doing manual lead research, we can automate it with a system like this.

---

## Run Locally (Optional)

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
