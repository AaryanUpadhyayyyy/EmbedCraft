// Type definitions for parsed doc content (mirrors python extractor output)

export type InlineRun =
  | { t: "t"; v: string }
  | { t: "c"; v: string }
  | { t: "b"; v: string }
  | { t: "i"; v: string }
  | { t: "a"; v: string; h: string };

export type Block =
  | { type: "heading"; level: 1 | 2 | 3 | 4 | 5 | 6; text: string; id: string }
  | { type: "p"; runs: InlineRun[] }
  | { type: "code"; lang: string; code: string }
  | { type: "list"; ordered: boolean; items: InlineRun[][] }
  | { type: "table"; header: InlineRun[][]; rows: InlineRun[][][] }
  | { type: "image"; src: string; alt: string }
  | { type: "hr" }
  | { type: "_bq_open" }
  | { type: "_bq_close" };

export interface DocPage {
  slug: string;
  title: string;
  description?: string;
  blocks: Block[];
  source?: string;
}

export type DocPageMap = Record<string, DocPage>;

// ---- Navigation tree ----
export interface NavLeaf {
  kind: "leaf";
  label: string;
  to: string;
}
export interface NavSection {
  kind: "section";
  label: string;
  to?: string;          // optional landing for the section
  icon?: string;        // lucide icon name
  defaultOpen?: boolean;
  children: NavNode[];
}
export type NavNode = NavLeaf | NavSection;
