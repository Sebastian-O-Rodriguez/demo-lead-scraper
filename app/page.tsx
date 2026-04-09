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

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);

    if (!query.trim()) {
      setError("Please enter a search query");
      return;
    }

    setLoading(true);
    setLeads([]);

    try {
      const res = await fetch("/api/leads", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ query: query.trim() }),
      });

      if (!res.ok) {
        const body = (await res.json().catch(() => null)) as LeadErrorResponse | null;
        setError(body?.error ?? "Something went wrong. Please try again.");
        return;
      }

      const data: LeadResponse = await res.json();
      setLeads(data.leads);
    } catch {
      setError("Network error. Please check your connection and try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-10">
          <h1 className="text-3xl font-bold text-gray-900 tracking-tight">
            AI Lead Scraper + Enricher
          </h1>
          <p className="mt-2 text-gray-500 text-base">
            Search for leads and get AI-enriched summaries and categorizations.
          </p>
        </div>

        {/* Search Form */}
        <form onSubmit={handleSubmit} className="flex gap-3 mb-8">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="e.g. AI startups in healthcare"
            className="flex-1 rounded-lg border border-gray-300 px-4 py-2.5 text-gray-900 placeholder:text-gray-400 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-base"
          />
          <button
            type="submit"
            disabled={loading}
            className="rounded-lg bg-blue-600 px-6 py-2.5 text-white font-medium shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors text-base"
          >
            {loading ? "Searching..." : "Search"}
          </button>
        </form>

        {/* Error State */}
        {error && (
          <div className="mb-6 rounded-lg bg-red-50 border border-red-200 px-4 py-3">
            <p className="text-red-700 text-sm">{error}</p>
          </div>
        )}

        {/* Loading State */}
        {loading && (
          <div className="text-center py-16">
            <p className="text-gray-500 text-lg animate-pulse">
              Searching and enriching leads...
            </p>
          </div>
        )}

        {/* Results Table */}
        {!loading && leads.length > 0 && (
          <div className="bg-white rounded-lg border border-gray-200 shadow-sm overflow-x-auto">
            <table className="w-full divide-y divide-gray-200 table-fixed">
              <thead className="bg-gray-50">
                <tr>
                  <th className="w-[20%] px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    Name
                  </th>
                  <th className="w-[20%] px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    URL
                  </th>
                  <th className="w-[45%] px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    Summary
                  </th>
                  <th className="w-[15%] px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    Category
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {leads.map((lead, i) => (
                  <tr key={i} className="hover:bg-gray-50 transition-colors">
                    <td className="px-4 py-4 text-sm font-medium text-gray-900">
                      <div className="truncate" title={lead.name}>
                        {lead.name}
                      </div>
                    </td>
                    <td className="px-4 py-4 text-sm">
                      <a
                        href={lead.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-600 hover:text-blue-800 hover:underline truncate block"
                        title={lead.url}
                      >
                        {displayHost(lead.url)}
                      </a>
                    </td>
                    <td className="px-4 py-4 text-sm text-gray-600">
                      {lead.summary}
                    </td>
                    <td className="px-4 py-4 text-sm">
                      <span className="inline-flex items-center rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-medium text-blue-700">
                        {lead.category}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Empty State (after search completes with no results) */}
        {!loading && !error && leads.length === 0 && query && (
          <div className="text-center py-16">
            <p className="text-gray-400 text-base">No leads found. Try a different query.</p>
          </div>
        )}
      </div>
    </main>
  );
}
