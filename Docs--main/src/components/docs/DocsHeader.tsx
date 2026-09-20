import { Link, NavLink, useNavigate } from "react-router-dom";
import { Search, Menu, X, BookOpen, Sun, Moon, LogOut } from "lucide-react";
import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";
import embedCraftLogo from "@/assets/embedcraft-logo.png";
import { useAuth } from "@/context/AuthContext";

const topNav = [
  { label: "Getting Started", to: "/getting-started/account-setup" },
  { label: "Quick Start", to: "/quickstart" },
  { label: "Platform SDKs", to: "/platform" },
  { label: "API Reference", to: "/apis" },
  { label: "Product", to: "/product" },
  { label: "Integrations", to: "/integrations" },
  { label: "Security", to: "/security/authentication" },
  { label: "FAQ", to: "/product" },
];

interface Props {
  onToggleMobileNav?: () => void;
  mobileNavOpen?: boolean;
  onOpenSearch?: () => void;
}

export function DocsHeader({ onToggleMobileNav, mobileNavOpen, onOpenSearch }: Props) {
  const [dark, setDark] = useState<boolean>(() =>
    typeof window !== "undefined" && document.documentElement.classList.contains("dark"),
  );
  const { logout } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
  }, [dark]);

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <header className="sticky top-0 z-40 h-[var(--header-height)] bg-background/85 backdrop-blur border-b border-border">
      <div className="h-full flex items-center gap-3 px-4 md:px-6">
        <button
          onClick={onToggleMobileNav}
          className="md:hidden -ml-1 p-2 rounded-md hover:bg-muted text-foreground"
          aria-label="Toggle navigation"
        >
          {mobileNavOpen ? <X size={20} /> : <Menu size={20} />}
        </button>

        <Link to="/" className="flex items-center gap-2.5 mr-4 shrink-0 group">
          <img
            src={embedCraftLogo}
            alt="EmbedCraft"
            className="h-9 w-9 object-contain group-hover:scale-105 transition-transform dark:invert"
          />
          <div className="flex flex-col leading-none">
            <span className="text-[15px] font-bold tracking-tight">EmbedCraft</span>
            <span className="text-[10px] uppercase tracking-widest text-muted-foreground -mt-0.5">Docs</span>
          </div>
        </Link>

        <nav className="hidden lg:flex items-center gap-1 mr-auto">
          {topNav.map((item) => (
            <NavLink
              key={item.to + item.label}
              to={item.to}
              className={({ isActive }) =>
                cn(
                  "px-3 py-1.5 rounded-md text-[13.5px] font-medium transition-colors",
                  "hover:text-foreground hover:bg-muted/60",
                  isActive ? "text-foreground" : "text-muted-foreground",
                )
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="lg:hidden mr-auto" />

        <button
          onClick={onOpenSearch}
          className="hidden sm:flex items-center gap-2 h-9 px-3 pr-2 rounded-md border border-border bg-surface-muted text-sm text-muted-foreground hover:border-border-strong transition-colors min-w-[200px]"
        >
          <Search size={15} />
          <span className="flex-1 text-left">Search docs…</span>
          <kbd className="text-[10px] font-sans font-medium border border-border rounded px-1.5 py-0.5 bg-background">⌘K</kbd>
        </button>

        <button
          onClick={() => setDark(d => !d)}
          className="p-2 rounded-md hover:bg-muted text-muted-foreground hover:text-foreground transition-colors"
          aria-label="Toggle theme"
        >
          {dark ? <Sun size={16} /> : <Moon size={16} />}
        </button>

        <button
          onClick={handleLogout}
          className="p-2 rounded-md hover:bg-muted text-muted-foreground hover:text-red-500 transition-colors"
          title="Sign out"
        >
          <LogOut size={16} />
        </button>

        <Link
          to="/quickstart"
          className="hidden md:inline-flex items-center gap-1.5 h-9 px-3 rounded-md bg-primary text-primary-foreground text-sm font-medium hover:bg-primary-strong transition-colors"
        >
          <BookOpen size={14} />
          Quickstart
        </Link>
      </div>
    </header>
  );
}
