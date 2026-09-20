import { Link } from "react-router-dom";
import { Check, Copy, Hash } from "lucide-react";
import { useState } from "react";
import type { Block, InlineRun } from "@/types/docs";
import { cn } from "@/lib/utils";

/* ---------- Inline runs ---------- */

function isInternalHref(href: string): boolean {
  if (!href) return false;
  if (href.startsWith("#")) return true;
  if (href.startsWith("/")) return true;
  // External docs.embedcraft.com links — convert to internal slugs
  if (href.startsWith("https://docs.embedcraft.com")) return true;
  return false;
}

function normalizeInternal(href: string): string {
  if (href.startsWith("https://docs.embedcraft.com")) {
    const u = href.replace("https://docs.embedcraft.com", "");
    return u.replace(/\/$/, "") || "/product";
  }
  return href;
}

function InlineRuns({ runs }: { runs: InlineRun[] }) {
  return (
    <>
      {runs.map((r, i) => {
        switch (r.t) {
          case "t":
            return <span key={i}>{r.v} </span>;
          case "c":
            return (
              <code key={i} className="inline-code">
                {r.v}
              </code>
            );
          case "b":
            return (
              <strong key={i}>
                {r.v}{" "}
              </strong>
            );
          case "i":
            return <em key={i}>{r.v} </em>;
          case "a": {
            if (isInternalHref(r.h)) {
              const to = normalizeInternal(r.h);
              return (
                <Link key={i} to={to}>
                  {r.v}
                </Link>
              );
            }
            return (
              <a key={i} href={r.h} target="_blank" rel="noopener noreferrer">
                {r.v}
              </a>
            );
          }
        }
      })}
    </>
  );
}

/* ---------- Code block ---------- */

const langLabels: Record<string, string> = {
  js: "JavaScript",
  javascript: "JavaScript",
  ts: "TypeScript",
  typescript: "TypeScript",
  json: "JSON",
  bash: "Shell",
  sh: "Shell",
  shell: "Shell",
  py: "Python",
  python: "Python",
  java: "Java",
  kotlin: "Kotlin",
  swift: "Swift",
  dart: "Dart",
  flutter: "Flutter",
  curl: "cURL",
  html: "HTML",
  css: "CSS",
  text: "Text",
  yaml: "YAML",
  yml: "YAML",
};

function CodeBlock({ lang, code }: { lang: string; code: string }) {
  const [copied, setCopied] = useState(false);
  const onCopy = async () => {
    try {
      await navigator.clipboard.writeText(code);
      setCopied(true);
      setTimeout(() => setCopied(false), 1600);
    } catch {/* noop */}
  };
  const label = langLabels[lang.toLowerCase()] ?? lang.toUpperCase();
  return (
    <div className="my-5 rounded-lg overflow-hidden border border-border-strong bg-surface-code text-surface-code-foreground">
      <div className="flex items-center justify-between px-4 py-2 text-xs font-medium border-b border-white/10 bg-black/20">
        <span className="font-mono uppercase tracking-wide text-white/70">{label}</span>
        <button
          onClick={onCopy}
          className="inline-flex items-center gap-1.5 rounded px-2 py-1 text-white/70 hover:text-white hover:bg-white/10 transition"
          aria-label="Copy code"
        >
          {copied ? <Check size={14} /> : <Copy size={14} />}
          <span>{copied ? "Copied" : "Copy"}</span>
        </button>
      </div>
      <pre className="overflow-x-auto p-4 text-[13.5px] leading-[1.65] nudge-scroll">
        <code className="font-mono">{code}</code>
      </pre>
    </div>
  );
}

/* ---------- Headings with anchor ---------- */

function HeadingBlock({ level, text, id }: { level: number; text: string; id: string }) {
  const Tag = (`h${Math.min(level, 6)}`) as keyof JSX.IntrinsicElements;
  return (
    <Tag id={id} className="group scroll-mt-24">
      {text}
      <a href={`#${id}`} className="heading-anchor inline-block align-middle" aria-label={`Anchor for ${text}`}>
        <Hash size={16} className="inline -mt-1" />
      </a>
    </Tag>
  );
}

/* ---------- Lists ---------- */

function ListBlock({ ordered, items }: { ordered: boolean; items: InlineRun[][] }) {
  const Tag = ordered ? "ol" : "ul";
  return (
    <Tag>
      {items.map((it, i) => (
        <li key={i}>
          <InlineRuns runs={it} />
        </li>
      ))}
    </Tag>
  );
}

/* ---------- Table ---------- */

function TableBlock({ header, rows }: { header: InlineRun[][]; rows: InlineRun[][][] }) {
  return (
    <div className="my-6 overflow-x-auto nudge-scroll">
      <table>
        {header && header.length > 0 && (
          <thead>
            <tr>
              {header.map((h, i) => (
                <th key={i}>
                  <InlineRuns runs={h} />
                </th>
              ))}
            </tr>
          </thead>
        )}
        <tbody>
          {rows.map((row, ri) => (
            <tr key={ri}>
              {row.map((cell, ci) => (
                <td key={ci}>
                  <InlineRuns runs={cell} />
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

/* ---------- Renderer ---------- */

export function DocRenderer({ blocks }: { blocks: Block[] }) {
  // Detect "tile/card" landing pages: groups of (h3, p, p?) with the second p saying "Learn more"
  // For visual fidelity to the original Docusaurus landing pages, render H3+description+CTA as cards.
  const out: JSX.Element[] = [];
  let i = 0;
  let h1Count = 0;
  while (i < blocks.length) {
    const b = blocks[i];

    // Skip duplicate consecutive H1 (extractor sometimes captures both header + page title)
    if (b.type === "heading" && b.level === 1) {
      h1Count++;
      if (h1Count > 1) { i++; continue; }
    }

    // Detect tile sequence: H3 + P + P("Learn more") repeated
    if (b.type === "heading" && b.level === 3) {
      const tiles: { title: string; id: string; desc: string }[] = [];
      let j = i;
      while (j < blocks.length) {
        const head = blocks[j];
        const desc = blocks[j + 1];
        const cta = blocks[j + 2];
        if (
          head?.type === "heading" && head.level === 3 &&
          desc?.type === "p" &&
          cta?.type === "p" && cta.runs.some(r => "v" in r && /learn more/i.test(r.v))
        ) {
          const descText = desc.runs.map(r => ("v" in r ? r.v : "")).join(" ").trim();
          tiles.push({ title: head.text, id: head.id, desc: descText });
          j += 3;
        } else break;
      }
      if (tiles.length >= 2) {
        out.push(
          <div className="doc-card-grid" key={`tiles-${i}`}>
            {tiles.map((t, k) => (
              <Link key={k} to={`#${t.id}`} className="doc-card no-underline" onClick={(e) => {
                e.preventDefault();
                document.getElementById(t.id)?.scrollIntoView({ behavior: "smooth" });
              }}>
                <h3>{t.title}</h3>
                <p>{t.desc}</p>
                <span className="doc-card-cta">Learn more →</span>
              </Link>
            ))}
          </div>,
        );
        i = j;
        continue;
      }
    }

    switch (b.type) {
      case "heading":
        out.push(<HeadingBlock key={i} level={b.level} text={b.text} id={b.id} />);
        break;
      case "p":
        out.push(<p key={i}><InlineRuns runs={b.runs} /></p>);
        break;
      case "code":
        out.push(<CodeBlock key={i} lang={b.lang} code={b.code} />);
        break;
      case "list":
        out.push(<ListBlock key={i} ordered={b.ordered} items={b.items} />);
        break;
      case "table":
        out.push(<TableBlock key={i} header={b.header} rows={b.rows} />);
        break;
      case "image":
        out.push(
          <img key={i} src={b.src} alt={b.alt} loading="lazy" />,
        );
        break;
      case "hr":
        out.push(<hr key={i} />);
        break;
      case "_bq_open":
      case "_bq_close":
        // ignored — blockquote pairing requires more state; rare in this content
        break;
    }
    i++;
  }
  return <div className={cn("doc-prose")}>{out}</div>;
}
