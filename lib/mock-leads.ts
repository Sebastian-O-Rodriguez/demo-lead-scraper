import { RawLead } from "./types";

/**
 * Returns mock RawLead data for the given query.
 * Used as a fallback when the Python scraper is unavailable or fails.
 */
export function getMockRawLeads(query: string): RawLead[] {
  return [
    {
      name: `${query} - Top Local Provider`,
      url: "https://example.com/result/1",
    },
    {
      name: `Best ${query} Near You`,
      url: "https://example.com/result/2",
    },
    {
      name: `${query} | Professional Services Directory`,
      url: "https://example.com/result/3",
    },
    {
      name: `Find ${query} - Verified Listings`,
      url: "https://example.com/result/4",
    },
    {
      name: `${query} Reviews & Ratings`,
      url: "https://example.com/result/5",
    },
    {
      name: `Top-Rated ${query} in Your Area`,
      url: "https://example.com/result/6",
    },
  ];
}
