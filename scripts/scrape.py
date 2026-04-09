"""
DuckDuckGo HTML Scraper

Usage: python scripts/scrape.py "<search query>"

Fetches DDG HTML results for the given query,
parses result titles and URLs with BeautifulSoup,
and prints a JSON array of {name, url} to stdout.

TODO: Implement scraping logic
"""

import sys
import json
from urllib.parse import urlencode, urlparse, parse_qs

import requests
from bs4 import BeautifulSoup

MAX_RESULTS = 8


def scrape(query: str) -> list[dict]:
    """Scrape DuckDuckGo HTML results for the given query.

    Returns a list of dicts with 'name' and 'url' keys (max 8).
    """
    url = f"https://html.duckduckgo.com/html/?{urlencode({'q': query})}"
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/120.0.0.0 Safari/537.36"
        ),
    }

    resp = requests.get(url, headers=headers, timeout=15)
    resp.raise_for_status()

    soup = BeautifulSoup(resp.text, "html.parser")
    links = soup.select(".result__a")

    results: list[dict] = []
    for link in links:
        name = link.get_text(strip=True)
        href = link.get("href", "")

        # DDG wraps URLs in a redirect — extract the actual URL from the
        # `uddg` query parameter.
        parsed = urlparse(href)
        qs = parse_qs(parsed.query)
        actual_url = qs.get("uddg", [href])[0]

        if not name or not actual_url:
            continue

        results.append({"name": name, "url": actual_url})
        if len(results) >= MAX_RESULTS:
            break

    return results


def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/scrape.py <query>", file=sys.stderr)
        sys.exit(1)

    query = sys.argv[1]
    try:
        results = scrape(query)
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)

    print(json.dumps(results))


if __name__ == "__main__":
    main()
