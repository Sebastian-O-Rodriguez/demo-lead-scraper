// Raw lead from Python scraper (DDG HTML parse)
export type RawLead = {
  name: string;
  url: string;
};

// Enriched lead returned to the UI
export type Lead = {
  name: string;
  url: string;
  summary: string;
  category: string;
};

// API request body
export type LeadRequest = {
  query: string;
};

// API response body
export type LeadResponse = {
  leads: Lead[];
};

// API error response
export type LeadErrorResponse = {
  error: string;
};
