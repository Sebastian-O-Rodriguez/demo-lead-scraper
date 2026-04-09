import { NextRequest, NextResponse } from "next/server";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import path from "node:path";
import { RawLead, LeadResponse, LeadErrorResponse } from "@/lib/types";
import { enrichLeads } from "@/lib/enrich";
import { getMockRawLeads } from "@/lib/mock-leads";

const execFileAsync = promisify(execFile);

const PYTHON_BIN =
  process.env.PYTHON_BIN ||
  path.join(process.cwd(), "venv", "bin", "python3");
const SCRAPER_PATH = path.join(process.cwd(), "scripts", "scrape.py");

/**
 * Attempt to scrape DDG via the Python subprocess.
 * Returns null on any failure (caller falls back to mock data).
 */
async function scrapeLeads(query: string): Promise<RawLead[] | null> {
  try {
    const { stdout } = await execFileAsync(PYTHON_BIN, [SCRAPER_PATH, query], {
      timeout: 15_000,
    });
    const parsed = JSON.parse(stdout);
    if (!Array.isArray(parsed)) return null;
    return parsed as RawLead[];
  } catch {
    return null;
  }
}

/**
 * POST /api/leads
 *
 * Accepts a search query, scrapes DDG for raw leads (with mock fallback),
 * enriches each with AI, and returns structured leads.
 */
export async function POST(
  request: NextRequest,
): Promise<NextResponse<LeadResponse | LeadErrorResponse>> {
  try {
    const body = await request.json();
    const query = typeof body?.query === "string" ? body.query.trim() : "";

    if (!query) {
      return NextResponse.json(
        { error: "Query is required" },
        { status: 400 },
      );
    }

    // Scrape with fallback to mock data
    let rawLeads = await scrapeLeads(query);
    if (!rawLeads || rawLeads.length === 0) {
      rawLeads = getMockRawLeads(query);
    }

    // Enrich (capped at 8, never throws)
    const leads = await enrichLeads(query, rawLeads);

    return NextResponse.json({ leads });
  } catch {
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 },
    );
  }
}
