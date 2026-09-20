import { useState, useMemo } from "react";
import { Link } from "react-router-dom";
import { Search, X } from "lucide-react";
import pages from "@/data/pages.json";
import type { DocPageMap } from "@/types/docs";

const docs = pages as unknown as DocPageMap;

export function SearchDialog({ open, onClose }: { open: boolean; onClose: () => void }) {
  const [q, setQ] = useState("");
  const results = useMemo(() => {
    if (!q.trim()) return [];
    const needle = q.toLowerCase();
    return Object.values(docs)
      .filter(p => p.title.toLowerCase().includes(needle) || (p.description || "").toLowerCase().includes(needle))
      .slice(0, 12);
  }, [q]);
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm flex items-start justify-center pt-[12vh] px-4" onClick={onClose}>
      <div className="w-full max-w-xl bg-card border border-border rounded-xl shadow-2xl overflow-hidden animate-fade-in" onClick={e => e.stopPropagation()}>
        <div className="flex items-center gap-2 px-4 py-3 border-b border-border">
          <Search size={16} className="text-muted-foreground" />
          <input
            autoFocus
            value={q}
            onChange={e => setQ(e.target.value)}
            placeholder="Search docs…"
            className="flex-1 bg-transparent outline-none text-sm"
          />
          <button onClick={onClose} className="p-1 rounded hover:bg-muted text-muted-foreground"><X size={16}/></button>
        </div>
        <div className="max-h-[50vh] overflow-y-auto nudge-scroll">
          {results.length === 0 && q && (
            <div className="px-4 py-8 text-center text-sm text-muted-foreground">No results for "{q}"</div>
          )}
          {results.map(r => (
            <Link key={r.slug} to={r.slug} onClick={onClose} className="block px-4 py-3 hover:bg-muted border-b border-border last:border-0">
              <div className="text-sm font-medium">{r.title}</div>
              <div className="text-xs text-muted-foreground truncate">{r.slug}</div>
            </Link>
          ))}
          {!q && (
            <div className="px-4 py-8 text-center text-sm text-muted-foreground">Type to search across {Object.keys(docs).length} pages.</div>
          )}
        </div>
      </div>
    </div>
  );
}
