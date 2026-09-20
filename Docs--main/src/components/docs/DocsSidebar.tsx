import { Link, NavLink, useLocation } from "react-router-dom";
import { ChevronDown, Rocket, Zap, Layers, Terminal, Package, Plug, Shield, Phone, type LucideIcon } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { navigation } from "@/data/navigation";
import type { NavNode, NavSection } from "@/types/docs";
import { cn } from "@/lib/utils";

const iconMap: Record<string, LucideIcon> = {
  Rocket, Zap, Layers, Terminal, Package, Plug, Shield, Phone,
};

function isPathActive(pathname: string, to?: string) {
  if (!to) return false;
  return pathname === to;
}

function sectionContainsPath(node: NavSection, pathname: string): boolean {
  for (const c of node.children) {
    if (c.kind === "leaf" && c.to === pathname) return true;
    if (c.kind === "section" && sectionContainsPath(c, pathname)) return true;
  }
  if (node.to === pathname) return true;
  return false;
}

function NavItem({ node, depth }: { node: NavNode; depth: number }) {
  const location = useLocation();
  if (node.kind === "leaf") {
    return (
      <NavLink
        to={node.to}
        end
        className={({ isActive }) =>
          cn(
            "block rounded-md text-[13.5px] py-1.5 transition-colors",
            "hover:text-foreground",
            depth === 0 ? "px-3" : "pl-6 pr-3",
            depth === 1 && "pl-7",
            depth >= 2 && "pl-9",
            isActive
              ? "bg-primary-soft text-primary-strong font-medium"
              : "text-muted-foreground",
          )
        }
      >
        {node.label}
      </NavLink>
    );
  }
  return <SectionItem node={node} depth={depth} location={location.pathname} />;
}

function SectionItem({ node, depth, location }: { node: NavSection; depth: number; location: string }) {
  const containsActive = useMemo(() => sectionContainsPath(node, location), [node, location]);
  const [open, setOpen] = useState<boolean>(node.defaultOpen ?? containsActive);
  useEffect(() => {
    if (containsActive) setOpen(true);
  }, [containsActive]);

  const Icon = node.icon ? iconMap[node.icon] : null;

  return (
    <div className="my-0.5">
      <button
        onClick={() => setOpen(o => !o)}
        className={cn(
          "w-full flex items-center justify-between gap-2 rounded-md py-1.5 text-left transition-colors",
          "hover:bg-muted/60",
          depth === 0 ? "px-3 text-[13px] uppercase tracking-wider font-semibold text-foreground/80" : "pl-6 pr-3 text-[13.5px] font-medium",
          depth === 1 && "pl-7",
        )}
        aria-expanded={open}
      >
        <span className="flex items-center gap-2 min-w-0 truncate">
          {Icon && depth === 0 && <Icon size={14} className="shrink-0 text-primary" />}
          <span className="truncate">{node.label}</span>
        </span>
        <ChevronDown
          size={14}
          className={cn("shrink-0 text-muted-foreground transition-transform", open ? "rotate-0" : "-rotate-90")}
        />
      </button>
      {open && (
        <div className={cn("mt-1 flex flex-col gap-0.5", depth === 0 ? "ml-1 border-l border-border pl-2" : "")}>
          {node.children.map((c, i) => (
            <NavItem key={i} node={c} depth={depth + 1} />
          ))}
        </div>
      )}
    </div>
  );
}

interface SidebarProps {
  className?: string;
  onNavigate?: () => void;
}

export function DocsSidebar({ className }: SidebarProps) {
  return (
    <aside
      className={cn(
        "h-[calc(100vh-var(--header-height))] sticky top-[var(--header-height)] overflow-y-auto nudge-scroll",
        "bg-surface-muted border-r border-border",
        "py-6 pr-3 pl-4",
        className,
      )}
    >
      <Link to="/" className="block mb-4 px-3 text-xs uppercase tracking-widest text-muted-foreground font-semibold">
        Documentation
      </Link>
      <nav className="flex flex-col gap-1">
        {navigation.map((n, i) => (
          <NavItem key={i} node={n} depth={0} />
        ))}
      </nav>
    </aside>
  );
}
