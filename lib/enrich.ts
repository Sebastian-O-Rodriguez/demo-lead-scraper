import { RawLead, Lead } from "./types";

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";
const MODEL = "meta-llama/llama-3.1-8b-instruct";
const MAX_LEADS_PER_CALL = 8;
const MAX_RETRIES = 1;
const RETRY_DELAY_MS = 1000;

const SYSTEM_PROMPT =
  "You are a lead classifier. Given a search query and a website name+URL, return a JSON object with exactly two fields: summary (one sentence about what this website/business does) and category (1-2 words classifying the business type). Return ONLY the JSON object, no markdown, no explanation.";

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Enrich a raw lead with AI-generated summary and category.
 * Single retry on transient errors. Returns null on failure so caller can filter.
 */
export async function enrichLead(
  query: string,
  rawLead: RawLead,
): Promise<Lead | null> {
  for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
    try {
      const res = await fetch(OPENROUTER_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${process.env.LEAD_SCRAPER_OPENROUTER_KEY}`,
        },
        body: JSON.stringify({
          model: MODEL,
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            {
              role: "user",
              content: `Query: ${query}\nName: ${rawLead.name}\nURL: ${rawLead.url}`,
            },
          ],
          max_tokens: 100,
          temperature: 0,
        }),
      });

      if (res.status === 429 && attempt < MAX_RETRIES) {
        console.warn(`[enrich] 429 for "${rawLead.name}" — retry ${attempt + 1}/${MAX_RETRIES}`);
        await delay(RETRY_DELAY_MS);
        continue;
      }

      if (!res.ok) {
        const body = await res.text().catch(() => "");
        console.warn(`[enrich] HTTP ${res.status} for "${rawLead.name}": ${body.slice(0, 200)}`);
        return null;
      }

      const data = await res.json();
      const content: string | undefined =
        data?.choices?.[0]?.message?.content?.trim();

      if (!content) {
        console.warn(`[enrich] Empty content for "${rawLead.name}":`, JSON.stringify(data).slice(0, 200));
        return null;
      }

      const cleaned = content.replace(/```json\s*/gi, "").replace(/```/g, "").trim();
      const parsed = JSON.parse(cleaned);

      const summary = typeof parsed.summary === "string" ? parsed.summary : null;
      const category = typeof parsed.category === "string" ? parsed.category : null;

      if (!summary || !category) {
        console.warn(`[enrich] Missing fields for "${rawLead.name}": summary=${!!summary} category=${!!category}, raw=${cleaned.slice(0, 200)}`);
        return null;
      }

      return { name: rawLead.name, url: rawLead.url, summary, category };
    } catch (err) {
      console.warn(`[enrich] Exception for "${rawLead.name}" (attempt ${attempt + 1}):`, err instanceof Error ? err.message : err);
      if (attempt < MAX_RETRIES) {
        await delay(RETRY_DELAY_MS);
        continue;
      }
      return null;
    }
  }

  return null;
}

/**
 * Enrich multiple raw leads in parallel.
 * Paid model — no rate limit throttling needed.
 * Drops leads that fail enrichment.
 * Never throws.
 */
export async function enrichLeads(
  query: string,
  rawLeads: RawLead[],
): Promise<Lead[]> {
  const capped = rawLeads.slice(0, MAX_LEADS_PER_CALL);
  const results = await Promise.all(
    capped.map((lead) => enrichLead(query, lead)),
  );
  return results.filter((lead): lead is Lead => lead !== null);
}
