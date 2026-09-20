import { Link, useLocation } from "react-router-dom";
import { useEffect } from "react";
import type { Block } from "@/types/docs";
import { DocRenderer } from "@/components/docs/DocRenderer";
import { DocsToc } from "@/components/docs/DocsToc";
import { PrevNext } from "@/components/docs/PrevNext";
import { ChevronRight, Home } from "lucide-react";

interface Props {
  slug: string;
  title: string;
  description?: string;
  blocks: Block[];
}

function buildBreadcrumbs(slug: string) {
  const parts = slug.split("/").filter(Boolean);
  const crumbs: { label: string; to: string }[] = [];
  let acc = "";
  for (const p of parts) {
    acc += "/" + p;
    crumbs.push({ label: p.replace(/-/g, " ").replace(/^\w/, (c) => c.toUpperCase()), to: acc });
  }
  return crumbs;
}

/**
 * Shared shell used by every individual doc page file (one per route).
 * Each page in src/pages/docs/*.tsx owns its own content (BLOCKS array)
 * and simply hands it to this shell for layout + rendering.
 */
export function DocPageShell({ slug, title, blocks }: Props) {
  const location = useLocation();
  // Allow shell to be reused even when slug prop differs from current path
  const activeSlug = slug || location.pathname.replace(/\/$/, "") || "/";

  useEffect(() => {
    window.scrollTo({ top: 0 });
    document.title = `${title} | EmbedCraft Docs`;
  }, [activeSlug, title]);

  const crumbs = buildBreadcrumbs(activeSlug);

  return (
    <div className="flex gap-8 px-6 md:px-10 py-8 max-w-[1400px] mx-auto">
      <article className="min-w-0 flex-1 max-w-content animate-fade-in">
        <nav className="flex items-center gap-1.5 text-xs text-muted-foreground mb-6" aria-label="Breadcrumbs">
          <Link to="/" className="inline-flex items-center hover:text-foreground">
            <Home size={12} />
          </Link>
          {crumbs.map((c, i) => (
            <span key={i} className="inline-flex items-center gap-1.5">
              <ChevronRight size={12} />
              {i === crumbs.length - 1 ? (
                <span className="text-foreground font-medium">{c.label}</span>
              ) : (
                <Link to={c.to} className="hover:text-foreground">
                  {c.label}
                </Link>
              )}
            </span>
          ))}
        </nav>
        <DocRenderer blocks={blocks} />
        <PrevNext slug={activeSlug} />
      </article>
      <DocsToc blocks={blocks} />
    </div>
  );
}
