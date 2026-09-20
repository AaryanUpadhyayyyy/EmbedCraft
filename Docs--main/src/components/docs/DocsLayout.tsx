import { useEffect, useState } from "react";
import { Outlet } from "react-router-dom";
import { DocsHeader } from "@/components/docs/DocsHeader";
import { DocsSidebar } from "@/components/docs/DocsSidebar";
import { SearchDialog } from "@/components/docs/SearchDialog";

export function DocsLayout() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setSearchOpen(true);
      }
      if (e.key === "Escape") setSearchOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  return (
    <div className="min-h-screen bg-background">
      <DocsHeader
        onToggleMobileNav={() => setMobileOpen(o => !o)}
        mobileNavOpen={mobileOpen}
        onOpenSearch={() => setSearchOpen(true)}
      />
      <div className="flex">
        <div className="hidden md:block w-[var(--sidebar-width)] shrink-0">
          <DocsSidebar />
        </div>
        {mobileOpen && (
          <div className="fixed inset-0 z-30 md:hidden">
            <div className="absolute inset-0 bg-black/40" onClick={() => setMobileOpen(false)} />
            <div className="absolute left-0 top-[var(--header-height)] bottom-0 w-[280px] bg-surface-muted border-r border-border overflow-y-auto" onClick={() => setMobileOpen(false)}>
              <DocsSidebar />
            </div>
          </div>
        )}
        <main className="flex-1 min-w-0">
          <Outlet />
        </main>
      </div>
      <SearchDialog open={searchOpen} onClose={() => setSearchOpen(false)} />
    </div>
  );
}
