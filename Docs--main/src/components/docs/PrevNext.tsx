import { Link } from "react-router-dom";
import { ArrowLeft, ArrowRight } from "lucide-react";
import { flattenNav } from "@/data/navigation";

export function PrevNext({ slug }: { slug: string }) {
  const flat = flattenNav();
  const idx = flat.findIndex(f => f.to === slug);
  const prev = idx > 0 ? flat[idx - 1] : null;
  const next = idx >= 0 && idx < flat.length - 1 ? flat[idx + 1] : null;
  if (!prev && !next) return null;
  return (
    <nav className="mt-12 pt-6 border-t border-border grid grid-cols-2 gap-4">
      {prev ? (
        <Link to={prev.to} className="group flex flex-col rounded-lg border border-border p-4 hover:border-primary/50 hover:bg-muted/40 transition-colors">
          <span className="text-[11px] uppercase tracking-widest text-muted-foreground flex items-center gap-1"><ArrowLeft size={12}/> Previous</span>
          <span className="mt-1 font-medium text-foreground group-hover:text-primary">{prev.label}</span>
        </Link>
      ) : <div />}
      {next ? (
        <Link to={next.to} className="group flex flex-col items-end text-right rounded-lg border border-border p-4 hover:border-primary/50 hover:bg-muted/40 transition-colors">
          <span className="text-[11px] uppercase tracking-widest text-muted-foreground flex items-center gap-1">Next <ArrowRight size={12}/></span>
          <span className="mt-1 font-medium text-foreground group-hover:text-primary">{next.label}</span>
        </Link>
      ) : <div />}
    </nav>
  );
}
