"use client";

import { useState, FormEvent } from "react";
import type { Lead, LeadResponse, LeadErrorResponse } from "@/lib/types";

function displayHost(url: string): string {
  try {
    return new URL(url).hostname.replace("www.", "");
  } catch {
    return url;
  }
}

export default function Home() {
  const [query, setQuery] = useState("");
  const [leads, setLeads] = useState<Lead[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [searched, setSearched] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);

    if (!query.trim()) {
      setError("Please enter a search query");
      return;
    }

    setLoading(true);
    setLeads([]);
    setSearched(true);

    try {
      const res = await fetch("/api/leads", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ query: query.trim() }),
      });

      if (!res.ok) {
        const body = (await res.json().catch(() => null)) as LeadErrorResponse | null;
        setError(body?.error ?? "Something went wrong. Try again.");
        return;
      }

      const data: LeadResponse = await res.json();
      setLeads(data.leads);
    } catch {
      setError("Something went wrong. Try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-3xl mx-auto space-y-6">
        {/* Title + Description */}
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            AI Lead Scraper + Enricher
          </h1>
          <p className="mt-1 text-gray-500 text-sm">
            Turn search queries into structured, AI-enriched leads in seconds.
          </p>
        </div>

        {/* Input Section */}
        <div className="border border-gray-200 rounded-xl p-4 bg-white shadow-sm">
          <form onSubmit={handleSubmit} className="flex gap-3">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="e.g. cobblers in manhattan"
              className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
            <button
              type="submit"
              disabled={loading}
              className="bg-blue-600 text-white rounded-md px-4 py-2 text-sm font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? "Searching..." : "Search"}
            </button>
          </form>
        </div>

        {/* Error State */}
        {error && (
          <p className="text-red-600 text-sm">Something went wrong. Try again.</p>
        )}

        {/* Loading State */}
        {loading && (
          <div className="flex items-center justify-center gap-2 py-12">
            <svg
              className="h-4 w-4 text-gray-400"
              viewBox="0 0 24 24"
              fill="none"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
              />
            </svg>
            <p className="text-gray-500 text-sm">Fetching + enriching leads...</p>
          </div>
        )}

        {/* Results Table */}
        {!loading && leads.length > 0 && (
          <div className="border border-gray-200 rounded-xl bg-white shadow-sm overflow-hidden">
            <table className="w-full table-fixed">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="w-[22%] px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase">
                    Name
                  </th>
                  <th className="w-[18%] px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase">
                    URL
                  </th>
                  <th className="w-[44%] px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase">
                    Summary
                  </th>
                  <th className="w-[16%] px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase">
                    Category
                  </th>
                </tr>
              </thead>
              <tbody>
                {leads.map((lead, i) => (
                  <tr
                    key={i}
                    className={i % 2 === 1 ? "bg-gray-50" : "bg-white"}
                  >
                    <td className="px-4 py-3 text-sm font-medium text-gray-900">
                      <div className="truncate" title={lead.name}>
                        {lead.name}
                      </div>
                    </td>
                    <td className="px-4 py-3 text-sm">
                      <a
                        href={lead.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-600 hover:underline truncate block"
                        title={lead.url}
                      >
                        {displayHost(lead.url)}
                      </a>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600">
                      <div className="line-clamp-2">{lead.summary}</div>
                    </td>
                    <td className="px-4 py-3 text-sm">
                      <span className="inline-block rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-medium text-blue-700">
                        {lead.category}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Empty State */}
        {!loading && !error && leads.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-400 text-sm">
              {searched
                ? "No leads found. Try a different query."
                : "No leads yet. Try a search above."}
            </p>
          </div>
        )}
      </div>
    </main>
  );
}
