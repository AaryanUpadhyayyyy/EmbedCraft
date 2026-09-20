import { useEffect, useState } from "react";
import type { Block } from "@/types/docs";
import { cn } from "@/lib/utils";

interface TocItem { id: string; text: string; level: number }

export function DocsToc({ blocks }: { blocks: Block[] }) {
  const items: TocItem[] = blocks
    .filter((b): b is Extract<Block, { type: "heading" }> => b.type === "heading" && (b.level === 2 || b.level === 3))
    .map(b => ({ id: b.id, text: b.text, level: b.level }));

  const [active, setActive] = useState<string | null>(null);

  useEffect(() => {
    if (items.length === 0) return;
    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries.filter(e => e.isIntersecting).sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
        if (visible[0]) setActive(visible[0].target.id);
      },
      { rootMargin: "-80px 0px -70% 0px", threshold: [0, 1] },
    );
    items.forEach(i => {
      const el = document.getElementById(i.id);
      if (el) observer.observe(el);
    });
    return () => observer.disconnect();
  }, [items]);

  if (items.length === 0) return null;
  return (
    <aside className="hidden xl:block w-[var(--toc-width)] shrink-0 sticky top-[calc(var(--header-height)+1rem)] self-start max-h-[calc(100vh-var(--header-height)-2rem)] overflow-y-auto nudge-scroll pl-6">
      <p className="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground mb-3">On this page</p>
      <ul className="flex flex-col gap-1.5 border-l border-border">
        {items.map((it) => (
          <li key={it.id}>
            <a
              href={`#${it.id}`}
              className={cn(
                "block text-[13px] py-0.5 -ml-px border-l-2 transition-colors",
                it.level === 2 ? "pl-3" : "pl-6",
                active === it.id
                  ? "border-primary text-primary-strong font-medium"
                  : "border-transparent text-muted-foreground hover:text-foreground",
              )}
            >
              {it.text}
            </a>
          </li>
        ))}
      </ul>
    </aside>
  );
}
