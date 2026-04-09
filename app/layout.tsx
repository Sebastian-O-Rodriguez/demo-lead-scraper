import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AI Lead Scraper + Enricher",
  description: "Scrapes DuckDuckGo results and enriches them into structured leads with AI.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
