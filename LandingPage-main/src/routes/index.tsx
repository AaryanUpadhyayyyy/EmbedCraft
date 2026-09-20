import { useState, useEffect } from "react";
import { toast } from "sonner";
import { createFileRoute } from "@tanstack/react-router";
import { motion, type Variants, useScroll, useMotionValueEvent, useSpring } from "framer-motion";
import { InteractivePhoneMockup } from "@/components/InteractivePhoneMockup";
import {
  ArrowRight,
  Zap,
  WifiOff,
  MousePointerClick,
  ShieldCheck,
  Store,
  Send,
  Layers,
  Boxes,
  Square,
  Mail,
  Sparkles,
  PlayCircle,
  Smartphone,
  Bell,
  Image as ImageIcon,
  Target,
  BarChart3,
  Gamepad2,
  Gift,
  LayoutDashboard,
  Megaphone,
  GitBranch,
  Users,
  FileText,
  Palette,
  Trophy,
  MonitorPlay,
  Code2,
  Settings,
  Sun,
  Moon,
} from "lucide-react";
import bottomsheetGif from "@/assets/bottomsheet.gif";
import storiesGif from "@/assets/stories.gif";
import embedCraftLogo from "@/assets/logo.png";
import onboardingImg from "@/assets/onboarding.avif";
import adoptionImg from "@/assets/adoption.avif";
import conversionImg from "@/assets/conversion.avif";
import gamificationImg from "@/assets/gamification.avif";
import gdprBadge from "@/assets/gdpr-badge.svg";
import soc2Badge from "@/assets/soc2-badge.png";
import isoBadge from "@/assets/iso-badge.png";

export const Route = createFileRoute("/")({
  component: Landing,
});

const fadeUp: Variants = {
  hidden: { opacity: 0, y: 24 },
  show: { opacity: 1, y: 0, transition: { duration: 0.6, ease: [0.22, 1, 0.36, 1] as const } },
};

const stagger: Variants = {
  hidden: {},
  show: { transition: { staggerChildren: 0.08 } },
};

const slideInLeft: Variants = {
  hidden: { opacity: 0, x: -60 },
  show: { opacity: 1, x: 0, transition: { duration: 0.7, ease: [0.22, 1, 0.36, 1] as const } },
};

const slideInRight: Variants = {
  hidden: { opacity: 0, x: 60 },
  show: { opacity: 1, x: 0, transition: { duration: 0.7, ease: [0.22, 1, 0.36, 1] as const } },
};

const scaleIn: Variants = {
  hidden: { opacity: 0, scale: 0.85 },
  show: { opacity: 1, scale: 1, transition: { duration: 0.6, ease: [0.22, 1, 0.36, 1] as const } },
};

const countUp: Variants = {
  hidden: { opacity: 0, y: 40 },
  show: { opacity: 1, y: 0, transition: { duration: 0.8, ease: [0.22, 1, 0.36, 1] as const } },
};

const staggerSlow: Variants = {
  hidden: {},
  show: { transition: { staggerChildren: 0.15 } },
};

function ThemeToggle() {
  const [theme, setTheme] = useState(() => {
    if (typeof window !== "undefined") {
      return localStorage.getItem("theme") || "light";
    }
    return "light";
  });

  useEffect(() => {
    const root = window.document.documentElement;
    if (theme === "dark") {
      root.classList.add("dark");
    } else {
      root.classList.remove("dark");
    }
    localStorage.setItem("theme", theme);
  }, [theme]);

  return (
    <button
      onClick={() => setTheme(theme === "light" ? "dark" : "light")}
      className="flex h-10 w-10 items-center justify-center rounded-full border border-border bg-background/70 backdrop-blur-xl transition-all hover:bg-secondary"
      aria-label="Toggle theme"
    >
      {theme === "light" ? (
        <Moon className="h-5 w-5 text-neutral-600 dark:text-neutral-400" />
      ) : (
        <Sun className="h-5 w-5 text-neutral-400" />
      )}
    </button>
  );
}

function Logo() {
  return (
    <div className="flex items-center gap-2 group cursor-pointer select-none">
      <div className="h-6 w-6 sm:h-8 sm:w-8 flex items-center justify-center transition-transform duration-300 group-hover:scale-105">
        <img src={embedCraftLogo} alt="EmbedCraft" className="h-full w-full object-contain dark:invert" />
      </div>
      <span className="font-bold text-lg sm:text-2xl tracking-tighter text-foreground">EmbedCraft</span>
    </div>
  );
}

function Navbar() {
  const { scrollY } = useScroll();
  const [scrolled, setScrolled] = useState(false);

  useMotionValueEvent(scrollY, "change", (latest) => {
    setScrolled(latest > 50);
  });

  return (
    <header className="fixed top-0 left-0 right-0 z-50 px-4 transition-all duration-300" style={{ paddingTop: scrolled ? '0.5rem' : '1rem' }}>
      <motion.nav 
        className={`mx-auto max-w-5xl transition-all duration-300 ${
          scrolled ? "shadow-sm shadow-foreground/5" : ""
        }`}
      >
        <div 
          className={`flex items-center justify-between gap-4 rounded-xl transition-colors duration-300 px-4 py-2 glass-panel`}
        >
          <Logo />
          <div className="hidden md:flex items-center gap-1 rounded-full border border-border bg-background/40 p-1">
            {[
              { label: "Features", href: "#features" },
              { label: "Integrations", href: "#integrations" },
              { label: "Docs", href: "https://docs.embedcraft.com/" },
              { label: "Pricing", href: "#pricing" },
            ].map((l) => (
              <a
                key={l.label}
                href={l.href}
                target={l.href.startsWith("http") ? "_blank" : undefined}
                rel={l.href.startsWith("http") ? "noreferrer" : undefined}
                className="px-3.5 py-1 text-xs font-semibold uppercase tracking-wider text-neutral-500 hover:text-foreground hover:bg-neutral-100 dark:hover:bg-neutral-900 rounded-full transition-all"
              >
                {l.label}
              </a>
            ))}
          </div>
          <div className="flex items-center gap-2">
            <ThemeToggle />
            <a
              className="hidden sm:inline-flex px-3 py-1.5 text-xs font-semibold uppercase tracking-wider text-neutral-500 hover:text-foreground transition-colors"
              href="https://dashboard.embedcraft.com"
              target="_blank"
              rel="noreferrer"
            >
              Log in
            </a>
            <a
              href="#contact"
              className="inline-flex items-center gap-1.5 rounded-full bg-foreground px-4 py-2 text-xs font-bold text-background btn-hover-invert"
            >
              Book Demo
            </a>
          </div>
        </div>
      </motion.nav>
    </header>
  );
}

function Hero({ scrollPercentage }: { scrollPercentage: number }) {
  return (
    <section className="relative px-4 pt-10 pb-16 sm:pt-14 bg-spotlight bg-dots border border-border/40 rounded-3xl overflow-hidden shadow-sm">
      <motion.div
        initial="hidden"
        animate="show"
        variants={stagger}
        className="mx-auto max-w-4xl text-center"
      >
        <motion.div
          variants={fadeUp}
          className="flex justify-center mb-5"
        >
          <a
            href="https://github.com/embedcraft"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-2 rounded-full border border-border bg-background/60 backdrop-blur-md px-3.5 py-1 text-xs font-mono uppercase tracking-widest text-neutral-500 hover:text-foreground hover:border-foreground transition-all duration-300"
          >
            <span className="relative flex h-1.5 w-1.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-foreground opacity-75"></span>
              <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-foreground"></span>
            </span>
            <span>v2.0 SDK is Live</span>
            <ArrowRight className="h-3 w-3 text-neutral-400" />
          </a>
        </motion.div>

        <motion.div
          variants={fadeUp}
          className="flex flex-col items-center mb-6"
        >
          <h1 className="text-4xl sm:text-6xl md:text-7xl font-extrabold tracking-tightest leading-[1.08] text-foreground select-none max-w-3xl">
            <span className="text-gradient">Tailored app </span>
            <span className="font-serif italic font-normal text-neutral-400 dark:text-neutral-500">experiences</span>
            <span className="text-gradient"> in minutes.</span>
          </h1>
        </motion.div>

        <motion.p
          variants={fadeUp}
          className="mx-auto mt-4 max-w-xl text-xs sm:text-sm text-neutral-500 leading-relaxed font-normal"
        >
          Launch nudges, stories, gamification, and rich in-app widgets directly inside
          your Flutter app. Zero code changes. No app store reviews. 145ms latency.
        </motion.p>

        <motion.div variants={fadeUp} className="mt-6 flex flex-wrap items-center justify-center gap-3">
          <a
            href="#contact"
            className="inline-flex items-center gap-2 rounded-full bg-foreground px-5 py-2.5 text-xs sm:text-sm font-semibold text-background btn-hover-invert"
          >
            Get a Demo <ArrowRight className="h-4 w-4" strokeWidth={2} />
          </a>
          <a
            href="https://docs.embedcraft.com/"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-2 rounded-full border border-border bg-background/50 backdrop-blur px-5 py-2.5 text-xs sm:text-sm font-semibold text-foreground hover:bg-secondary transition-all"
          >
            Read Docs
          </a>
        </motion.div>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
        className="mx-auto mt-12 max-w-5xl"
      >
        <div className="relative rounded-2xl border border-border/80 bg-secondary/10 p-2 sm:p-3 shadow-2xl">
          <div className="relative overflow-x-auto overflow-y-hidden rounded-xl border border-border/60 bg-background bg-grid scrollbar-none">
            <div className="min-w-[800px]">
              <DashboardMockup />
            </div>
          </div>
        </div>
      </motion.div>

      {/* Mobile-only inline phone mockup */}
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        className="mt-12 flex justify-center lg:hidden"
      >
        <InteractivePhoneMockup scrollPercentage={scrollPercentage} />
      </motion.div>
    </section>
  );
}

function DashboardMockup() {
  return (
    <div className="relative h-[480px] p-4 select-none bg-neutral-50 dark:bg-neutral-950/20 rounded-xl">
      {/* Console Chrome window */}
      <div className="w-full h-full rounded-xl border border-border bg-background shadow-xl overflow-hidden flex flex-col">
        {/* Header Bar */}
        <div className="flex items-center justify-between border-b border-border px-4 py-2.5 bg-neutral-50 dark:bg-neutral-900/40">
          {/* OS Windows Dots */}
          <div className="flex items-center gap-1.5 w-20">
            <span className="h-2 w-2 rounded-full bg-neutral-300 dark:bg-neutral-800 border border-neutral-400/20" />
            <span className="h-2 w-2 rounded-full bg-neutral-300 dark:bg-neutral-800 border border-neutral-400/20" />
            <span className="h-2 w-2 rounded-full bg-neutral-300 dark:bg-neutral-800 border border-neutral-400/20" />
          </div>
          {/* Address Bar */}
          <div className="flex items-center gap-1.5 rounded-md border border-border bg-background px-4 py-1 text-[10px] text-neutral-400 font-mono tracking-wide w-96 justify-center shadow-inner">
            <span className="w-1.5 h-1.5 rounded-full bg-foreground opacity-30 animate-pulse" />
            <span>console.embedcraft.app</span>
          </div>
          {/* SDK Status Badge */}
          <div className="flex items-center gap-2">
            <span className="rounded-full bg-foreground text-background px-2.5 py-0.5 text-[9px] font-black uppercase tracking-wider">
              SDK v2.0 Active
            </span>
          </div>
        </div>

        {/* 3-Pane Editor Layout */}
        <div className="flex flex-1 overflow-hidden min-h-0 divide-x divide-border">
          {/* Pane 1: Sidebar (Campaigns) */}
          <div className="w-[20%] p-3 space-y-4 bg-neutral-50/50 dark:bg-neutral-900/10 flex flex-col justify-between">
            <div className="space-y-3.5">
              {/* Workspace Switcher */}
              <div className="flex items-center justify-between px-1.5 py-1 rounded border border-border bg-background">
                <span className="text-[10px] font-bold tracking-tight text-foreground truncate">Main Workspace</span>
                <span className="text-[9px] text-neutral-400 font-bold">▼</span>
              </div>

              {/* Sidebar Tabs */}
              <div className="space-y-1">
                {[
                  { label: "Overview", icon: LayoutDashboard },
                  { label: "Campaigns", icon: Target, active: true },
                  { label: "Audiences", icon: Users },
                  { label: "Analytics", icon: BarChart3 },
                ].map((item) => (
                  <div
                    key={item.label}
                    className={`flex items-center gap-2 rounded px-2 py-1.5 text-[10px] font-bold tracking-wide uppercase transition-colors ${
                      item.active
                        ? "bg-foreground text-background animate-fade-in"
                        : "text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-900"
                    }`}
                  >
                    <item.icon className="h-3 w-3 shrink-0" />
                    <span>{item.label}</span>
                  </div>
                ))}
              </div>

              <div className="h-px bg-border/60 mx-1" />

              {/* Campaign list */}
              <div className="space-y-1">
                <div className="text-[8px] font-black uppercase tracking-widest text-neutral-400 px-2 mb-1">Injections</div>
                {[
                  { name: "Welcome Promo", status: "active" },
                  { name: "Checkout Survey", status: "active" },
                  { name: "Spin Wheel Quiz", status: "draft" },
                  { name: "Winter Sale Code", status: "paused" },
                ].map((camp) => (
                  <div key={camp.name} className="flex items-center justify-between rounded px-2 py-1 text-[10px] text-neutral-600 dark:text-neutral-400 hover:bg-neutral-100 dark:hover:bg-neutral-900/60 cursor-pointer">
                    <div className="flex items-center gap-1.5 truncate">
                      <span className={`h-1.5 w-1.5 rounded-full shrink-0 ${
                        camp.status === "active" ? "bg-foreground" : camp.status === "draft" ? "bg-neutral-300 dark:bg-neutral-700" : "bg-neutral-200 dark:bg-neutral-800"
                      }`} />
                      <span className="truncate">{camp.name}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            
            <div className="rounded border border-border bg-background p-2 text-[9px] text-neutral-400">
              ⚡ <strong>145ms</strong> P99 latency
            </div>
          </div>

          {/* Pane 2: Central Canvas Editor */}
          <div className="w-[52%] flex flex-col bg-neutral-100/30 dark:bg-neutral-950/20 bg-dots relative overflow-hidden">
            {/* Canvas Header */}
            <div className="flex items-center justify-between border-b border-border/60 px-4 py-2 bg-background/80 backdrop-blur-sm z-10">
              <div className="text-[9px] font-bold text-neutral-400 uppercase tracking-wider">
                Canvas / Welcome Promo
              </div>
              <div className="flex items-center gap-1.5 border border-border rounded px-1.5 py-0.5 bg-background text-[9px] font-mono">
                <span>85%</span>
                <span className="text-neutral-300">|</span>
                <button className="hover:text-foreground font-bold">-</button>
                <button className="hover:text-foreground font-bold">+</button>
              </div>
            </div>

            {/* Central Canvas Screen Wrapper */}
            <div className="flex-1 flex items-center justify-center p-4 relative">
              {/* Simulated Device Frame in Canvas */}
              <div className="w-[170px] h-[300px] rounded-[1.75rem] border-[3px] border-foreground bg-background shadow-2xl overflow-hidden flex flex-col relative scale-[0.9] sm:scale-100 origin-center">
                {/* iPhone Notch */}
                <div className="absolute top-1.5 left-1/2 -translate-x-1/2 w-12 h-3.5 bg-foreground rounded-full z-20" />
                {/* Screen Content */}
                <div className="p-3 pt-6 flex-1 flex flex-col justify-between select-none">
                  {/* Background Mock elements */}
                  <div className="space-y-2 opacity-35 pointer-events-none">
                    <div className="flex gap-1">
                      {[0, 1, 2].map((i) => (
                        <div key={i} className="h-6 w-6 rounded-full bg-neutral-200 dark:bg-neutral-800 shrink-0" />
                      ))}
                    </div>
                    <div className="h-1.5 w-full bg-neutral-200 dark:bg-neutral-800 rounded" />
                    <div className="h-1.5 w-3/4 bg-neutral-200 dark:bg-neutral-800 rounded" />
                  </div>

                  {/* Active Nudge being Edited (Highlighted) */}
                  <div className="rounded-xl border border-dashed border-foreground/50 bg-secondary/60 p-2.5 shadow-sm relative group cursor-pointer ring-2 ring-foreground/20">
                    {/* Corners edit anchors */}
                    <span className="absolute -top-1 -left-1 w-2 h-2 rounded-full bg-foreground border border-background" />
                    <span className="absolute -top-1 -right-1 w-2 h-2 rounded-full bg-foreground border border-background" />
                    <span className="absolute -bottom-1 -left-1 w-2 h-2 rounded-full bg-foreground border border-background" />
                    <span className="absolute -bottom-1 -right-1 w-2 h-2 rounded-full bg-foreground border border-background" />
                    
                    {/* Nudge Content */}
                    <div className="text-[9px] font-black uppercase tracking-wider text-foreground flex items-center gap-1">
                      <span>🎉 Welcome Offer</span>
                    </div>
                    <div className="text-[7.5px] text-neutral-500 mt-1 leading-normal font-medium">
                      Get 40% off code on checkout. Valid for today.
                    </div>
                    <div className="mt-2 rounded bg-foreground text-background text-[7px] text-center font-bold py-1 uppercase tracking-widest">
                      Apply Discount
                    </div>
                  </div>

                  {/* Bottom mock element */}
                  <div className="space-y-1 opacity-20 pointer-events-none">
                    <div className="h-1.5 w-full bg-neutral-200 dark:bg-neutral-800 rounded" />
                  </div>
                </div>
              </div>

              {/* Bounding box Tooltip */}
              <div className="absolute top-[32%] left-[64%] bg-foreground text-background text-[8px] font-mono py-1 px-2 rounded shadow-md z-20 flex items-center gap-1.5 border border-background/25">
                <span className="w-1.5 h-1.5 bg-neutral-300 rounded-full animate-ping" />
                <span>BottomSheet (W:340, H:220)</span>
              </div>
            </div>
          </div>

          {/* Pane 3: Right Inspector Pane */}
          <div className="w-[28%] p-3.5 space-y-4 bg-neutral-50/50 dark:bg-neutral-900/10 flex flex-col justify-between overflow-y-auto">
            <div className="space-y-4">
              <div className="text-[9px] font-black uppercase tracking-widest text-neutral-400">Inspector Properties</div>
              
              {/* Properties Input Mimic */}
              <div className="space-y-3">
                <div className="space-y-1">
                  <div className="text-[8px] font-black uppercase tracking-wider text-neutral-400 font-bold">Trigger Event</div>
                  <div className="w-full rounded border border-border bg-background px-2.5 py-1.5 text-[9px] font-mono text-foreground flex justify-between items-center">
                    <span>on_app_open</span>
                    <span className="text-[7px] text-neutral-400">▼</span>
                  </div>
                </div>

                <div className="space-y-1">
                  <div className="text-[8px] font-black uppercase tracking-wider text-neutral-400 font-bold">Target Segment</div>
                  <div className="w-full rounded border border-border bg-background px-2.5 py-1.5 text-[9px] font-mono text-foreground flex justify-between items-center">
                    <span>new_users</span>
                    <span className="text-[7px] text-neutral-400">▼</span>
                  </div>
                </div>

                <div className="space-y-1">
                  <div className="text-[8px] font-black uppercase tracking-wider text-neutral-400 font-bold">Audience Rules</div>
                  <div className="rounded border border-border bg-background p-2 text-[9px] font-mono text-neutral-500 space-y-1.5">
                    <div className="flex items-center gap-1 text-foreground font-semibold">
                      <span>AND</span>
                    </div>
                    <div className="pl-2 border-l border-border space-y-1">
                      <div>session_count &lt; 2</div>
                      <div>platform == "iOS"</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="rounded-lg border border-border bg-background p-2.5 space-y-1">
              <div className="text-[8px] font-black uppercase tracking-wider text-neutral-400 font-bold">Runtime Info</div>
              <div className="flex items-center gap-1 text-[9px] font-semibold text-foreground">
                <span className="h-1.5 w-1.5 rounded-full bg-foreground animate-ping shrink-0" />
                <span>145ms P99 Delivery</span>
              </div>
              <div className="text-[8px] text-neutral-400 leading-snug">
                Delta synced via local SQLite database. Native rendering active.
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function SectionHeader({ eyebrow, title, sub }: { eyebrow: string; title: string; sub?: string }) {
  return (
    <motion.div
      initial="hidden"
      whileInView="show"
      viewport={{ once: true, margin: "-80px" }}
      variants={stagger}
      className="mx-auto max-w-3xl text-center"
    >
      <motion.div variants={fadeUp} className="text-xs uppercase tracking-[0.2em] text-neutral-500 font-medium">
        {eyebrow}
      </motion.div>
      <motion.h2
        variants={fadeUp}
        className="mt-3 text-4xl sm:text-5xl font-semibold tracking-tighter text-foreground"
      >
        {title}
      </motion.h2>
      {sub && (
        <motion.p variants={fadeUp} className="mt-4 text-neutral-600">
          {sub}
        </motion.p>
      )}
    </motion.div>
  );
}

function Bento() {
  return (
    <section id="features" className="px-4 py-20 select-none">
      <SectionHeader
        eyebrow="In-App Experiences"
        title="Everything you need. Nothing you don't."
        sub="The highest-converting surface in your product, fully owned by your growth team."
      />

      <motion.div
        initial="hidden"
        whileInView="show"
        viewport={{ once: true, margin: "-60px" }}
        variants={stagger}
        className="mx-auto mt-12 grid max-w-5xl grid-cols-1 md:grid-cols-3 gap-4"
      >
        {/* Card 1 - large */}
        <motion.div
          variants={fadeUp}
          className="md:col-span-2 group rounded-2xl border border-border bg-card p-6 glass-panel card-hover"
        >
          <div className="flex items-center gap-2 text-[10px] font-bold tracking-widest text-neutral-400 uppercase">
            <Send className="h-3.5 w-3.5" strokeWidth={2} />
            ZERO-UPDATE AGILITY
          </div>
          <h3 className="mt-3 text-xl sm:text-2xl font-bold tracking-tight">
            Publish UI in seconds. Not weeks.
          </h3>
          <p className="mt-1 text-xs text-neutral-500 max-w-md">
            Hot-swap stories, nudges, and banners straight to production. Skip the App Store review queue entirely.
          </p>

          <div className="mt-6 relative h-44 rounded-xl border border-border bg-secondary/5 dark:bg-secondary/10 bg-dots overflow-hidden">
            <div className="absolute inset-0 flex flex-col md:flex-row items-stretch divide-y md:divide-y-0 md:divide-x divide-border">
              {/* Terminal panel */}
              <div className="flex-1 p-3.5 font-mono text-[9px] text-foreground bg-background/50 flex flex-col justify-between">
                <div className="space-y-1">
                  <div className="flex items-center gap-1.5 opacity-60">
                    <span className="h-1.5 w-1.5 rounded-full bg-foreground" />
                    <span>deploy_prod.sh</span>
                  </div>
                  <div className="pt-2 text-neutral-400">$ embedcraft push --production</div>
                  <div className="text-neutral-400">⠋ compiling layout trees...</div>
                  <div className="font-bold text-foreground">✔ deployed to edge CDN successfully!</div>
                </div>
                <div className="flex items-center justify-between text-[8px] text-neutral-400 pt-2 border-t border-border/40">
                  <span>HASH: e7bc3a9</span>
                  <span>VERSION: 2.4.1</span>
                </div>
              </div>

              {/* Sync pathing visual */}
              <div className="w-[10%] hidden md:flex items-center justify-center relative bg-neutral-50/20 dark:bg-neutral-900/10">
                <div className="absolute left-0 right-0 h-[1px] bg-border border-dashed" />
                <motion.div
                  animate={{ x: [-20, 20], opacity: [0, 1, 0] }}
                  transition={{ repeat: Infinity, duration: 2, ease: "linear" }}
                  className="h-2 w-2 rounded-full bg-foreground shadow-md z-10"
                />
              </div>

              {/* Screen Update panel */}
              <div className="flex-1 p-3.5 flex flex-col justify-between bg-neutral-50/50 dark:bg-neutral-950/20">
                <div className="flex items-center justify-between">
                  <span className="text-[8px] font-black uppercase tracking-wider text-neutral-400">Live Device Output</span>
                  <span className="rounded-full bg-foreground text-background px-1.5 py-0.5 text-[8px] font-bold">145ms update</span>
                </div>
                
                {/* Mock Card Fading In */}
                <div className="rounded border border-border bg-background p-2.5 shadow-sm space-y-1 relative overflow-hidden animate-pulse">
                  <div className="h-1.5 w-1/3 bg-neutral-200 dark:bg-neutral-800 rounded" />
                  <div className="h-1 w-2/3 bg-neutral-200 dark:bg-neutral-800 rounded" />
                  <div className="absolute right-2 top-2 h-4 w-4 rounded-full bg-foreground/10 flex items-center justify-center text-[7px] font-bold">⚡</div>
                </div>

                <div className="text-[8px] text-neutral-400 truncate">
                  No App Store review queue or JS Bridge compile latency.
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Card 2 */}
        <motion.div variants={fadeUp} className="rounded-2xl border border-border bg-card p-6 glass-panel card-hover flex flex-col justify-between">
          <div className="flex items-center gap-2 text-[10px] font-bold tracking-widest text-neutral-400 uppercase">
            <Zap className="h-3.5 w-3.5" strokeWidth={2} />
            LATENCY
          </div>
          <div>
            <div className="text-5xl font-extrabold tracking-tighter text-foreground">
              145<span className="text-xl font-bold text-neutral-400 ml-0.5">ms</span>
            </div>
            
            {/* High-fidelity Latency Comparison Chart */}
            <div className="mt-4 border border-border/80 rounded-lg p-2.5 bg-background/50 relative overflow-hidden">
              <div className="text-[8px] font-black tracking-wider text-neutral-400 uppercase mb-2 flex justify-between">
                <span>Latency Over Time</span>
                <span className="font-mono text-foreground font-bold">P99 Metric</span>
              </div>
              <div className="h-16 w-full relative">
                {/* Horizontal Grid lines */}
                <div className="absolute inset-0 flex flex-col justify-between opacity-15 pointer-events-none">
                  <div className="h-[1px] bg-foreground w-full" />
                  <div className="h-[1px] bg-foreground w-full" />
                  <div className="h-[1px] bg-foreground w-full" />
                </div>
                {/* SVG Graph Paths */}
                <svg className="w-full h-full overflow-visible" viewBox="0 0 100 40">
                  {/* WebView volatile path */}
                  <motion.path
                    d="M 0,5 Q 15,2 25,18 T 50,8 T 75,25 T 100,5"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="1"
                    strokeDasharray="2,2"
                    className="text-neutral-400 dark:text-neutral-600"
                    initial={{ pathLength: 0 }}
                    animate={{ pathLength: 1 }}
                    transition={{ duration: 1.5, ease: "easeOut" }}
                  />
                  {/* EmbedCraft stable path */}
                  <motion.path
                    d="M 0,35 L 100,35"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="1.5"
                    className="text-foreground"
                    initial={{ pathLength: 0 }}
                    animate={{ pathLength: 1 }}
                    transition={{ duration: 1, ease: "easeOut", delay: 0.2 }}
                  />
                  {/* Highlight circles */}
                  <circle cx="50" cy="35" r="2" className="fill-foreground" />
                  <circle cx="50" cy="8" r="2" className="fill-neutral-400 dark:fill-neutral-600" />
                </svg>
                {/* Badges */}
                <div className="absolute left-[40%] top-[1px] bg-foreground text-background text-[7px] font-mono px-1 rounded">
                  1,240ms WebView
                </div>
                <div className="absolute left-[40%] bottom-[8px] bg-foreground text-background text-[7px] font-mono px-1 rounded">
                  145ms Native
                </div>
              </div>
            </div>
            
            <p className="mt-3 text-[11px] text-neutral-500 leading-snug">
              Pure Dart layout compiler. No WebViews or slow JS bridges.
            </p>
          </div>
        </motion.div>

        {/* Card 3 */}
        <motion.div variants={fadeUp} className="rounded-2xl border border-border bg-card p-6 glass-panel card-hover flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-2 text-[10px] font-bold tracking-widest text-neutral-400 uppercase mb-4">
              <WifiOff className="h-3.5 w-3.5" strokeWidth={2} />
              OFFLINE-FIRST
            </div>
            <h3 className="text-lg font-bold tracking-tight">
              SQLite local sync.
            </h3>
            <p className="mt-1 text-[11px] text-neutral-500 leading-snug">
              Updates occur via delta synchronization. Reconnect and resume instantly.
            </p>
          </div>

          {/* SQLite Sync Pipeline Diagram */}
          <div className="mt-4 border border-border/80 rounded-lg p-3 bg-secondary/10 relative overflow-hidden flex flex-col gap-2.5">
            {/* Status indicators */}
            <div className="flex justify-between items-center text-[8px] font-mono">
              <div className="flex items-center gap-1">
                <span className="h-1.5 w-1.5 rounded-full bg-neutral-400 dark:bg-neutral-600" />
                <span>Device Cache</span>
              </div>
              <span className="rounded bg-foreground text-background px-1 py-0.25 text-[7px] font-bold">Offline Queue</span>
              <div className="flex items-center gap-1">
                <span className="h-1.5 w-1.5 rounded-full bg-foreground animate-pulse" />
                <span>Cloud Server</span>
              </div>
            </div>

            {/* Sync Visualizer Nodes */}
            <div className="flex items-center justify-between border border-border bg-background p-2 rounded-md">
              {/* SQLite DB */}
              <div className="flex flex-col items-center">
                <div className="h-6 w-6 rounded border border-border bg-neutral-50 dark:bg-neutral-900 flex items-center justify-center text-[9px] font-bold">
                  DB
                </div>
                <span className="text-[7px] font-mono mt-0.5 text-neutral-400">sqlite</span>
              </div>

              {/* Sync Pipeline arrows */}
              <div className="flex-1 px-2 relative flex items-center justify-center">
                <div className="w-full h-[1px] bg-border border-dashed" />
                <motion.span
                  animate={{ x: [-15, 15], opacity: [0, 1, 0] }}
                  transition={{ repeat: Infinity, duration: 1.5, ease: "linear" }}
                  className="absolute h-1 w-1 bg-foreground rounded-full"
                />
              </div>

              {/* Delta Sync Manager */}
              <div className="flex flex-col items-center">
                <div className="h-6 w-12 rounded border border-foreground bg-foreground text-background flex items-center justify-center text-[7px] font-mono tracking-tighter">
                  DELTA
                </div>
                <span className="text-[7px] font-mono mt-0.5 text-neutral-400 font-bold">sync_queue</span>
              </div>

              {/* Sync Pipeline arrows */}
              <div className="flex-1 px-2 relative flex items-center justify-center">
                <div className="w-full h-[1px] bg-border border-dashed" />
                <motion.span
                  animate={{ x: [-15, 15], opacity: [0, 1, 0] }}
                  transition={{ repeat: Infinity, duration: 1.5, ease: "linear", delay: 0.7 }}
                  className="absolute h-1 w-1 bg-foreground rounded-full"
                />
              </div>

              {/* Cloud DB */}
              <div className="flex flex-col items-center">
                <div className="h-6 w-6 rounded border border-border bg-neutral-50 dark:bg-neutral-900 flex items-center justify-center text-[9px] font-bold">
                  ☁
                </div>
                <span className="text-[7px] font-mono mt-0.5 text-neutral-400">cloud</span>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Card 4 - large */}
        <motion.div
          variants={fadeUp}
          className="md:col-span-2 rounded-2xl border border-border bg-card p-6 glass-panel card-hover"
        >
          <div className="flex items-center gap-2 text-[10px] font-bold tracking-widest text-neutral-400 uppercase">
            <MousePointerClick className="h-3.5 w-3.5" strokeWidth={2} />
            NO-CODE AUTONOMY
          </div>
          <h3 className="mt-3 text-xl sm:text-2xl font-bold tracking-tight">
            Your growth team ships. No dev cycles.
          </h3>
          <p className="mt-1 text-xs text-neutral-500 max-w-md">
            Drag, drop, target, and schedule. A clean visual editor allows marketing teams to deploy experiences in minutes.
          </p>

          <div className="mt-6 rounded-xl border border-border bg-secondary/5 dark:bg-secondary/10 p-3 bg-grid">
            <div className="grid grid-cols-1 sm:grid-cols-12 gap-3 h-36">
              {/* Layers List Panel */}
              <div className="hidden sm:block col-span-4 space-y-1.5 bg-background/60 p-2 rounded border border-border flex flex-col justify-between overflow-y-auto scrollbar-none">
                <div className="space-y-1">
                  <div className="text-[7px] font-black tracking-widest text-neutral-400 uppercase mb-1">Hierarchy Outliner</div>
                  {[
                    { label: "Modal Container", depth: 0, active: true },
                    { label: "Sparkle Header Icon", depth: 1 },
                    { label: "Title: 'Welcome'", depth: 1 },
                    { label: "Body Text Paragraph", depth: 1 },
                    { label: "Primary Button Block", depth: 1 },
                  ].map((layer, idx) => (
                    <div
                      key={idx}
                      className={`flex items-center gap-1.5 rounded px-1.5 py-0.75 text-[8.5px] font-medium transition-colors ${
                        layer.active ? "bg-foreground text-background font-bold" : "text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-900"
                      }`}
                      style={{ paddingLeft: `${layer.depth * 8 + 6}px` }}
                    >
                      <span className="opacity-50">▤</span>
                      <span className="truncate">{layer.label}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Inspector Pane + Alignment controls */}
              <div className="col-span-1 sm:col-span-8 rounded border border-dashed border-neutral-300 dark:border-neutral-700 bg-background/80 p-3 relative h-full flex flex-col justify-between">
                <div className="flex items-center justify-between">
                  <span className="text-[8px] font-mono tracking-widest text-neutral-400 uppercase">Alignment & Layout</span>
                  <div className="flex items-center gap-1">
                    {[0, 1, 2, 3, 4, 5].map((i) => (
                      <button key={i} className={`h-4 w-4 rounded border border-border text-[8px] flex items-center justify-center font-bold ${i === 2 ? "bg-foreground text-background" : "bg-background text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-900"}`}>
                        {["├", "┼", "┤", "┯", "╂", "┷"][i]}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="space-y-2 mt-2">
                  {/* Slider controls simulator */}
                  <div className="space-y-1">
                    <div className="flex justify-between text-[7px] font-black tracking-wider text-neutral-400 uppercase">
                      <span>Opacity Accent</span>
                      <span className="font-mono text-foreground font-bold">85%</span>
                    </div>
                    <div className="h-1 bg-neutral-200 dark:bg-neutral-800 rounded-full overflow-hidden relative">
                      <div className="h-full w-[85%] bg-foreground" />
                      <span className="absolute right-[15%] top-1/2 -translate-y-1/2 h-2 w-2 rounded-full bg-foreground border border-background shadow" />
                    </div>
                  </div>

                  <div className="flex gap-2">
                    <div className="flex-1 space-y-1.5">
                      <div className="flex justify-between text-[7px] font-mono text-neutral-400">
                        <span>Padding</span>
                        <span>16px</span>
                      </div>
                      <div className="h-4 rounded border border-border bg-secondary/35 text-[8px] font-mono flex items-center px-1.5 text-neutral-500">
                        p: 16px, m: 0px
                      </div>
                    </div>
                    <div className="flex-1 space-y-1.5">
                      <div className="flex justify-between text-[7px] font-mono text-neutral-400">
                        <span>Corner Radius</span>
                        <span>12px</span>
                      </div>
                      <div className="h-4 rounded border border-border bg-secondary/35 text-[8px] font-mono flex items-center px-1.5 text-neutral-500">
                        r: 12px
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Bonus row */}
        <motion.div variants={fadeUp} className="md:col-span-3 rounded-2xl border border-border bg-card p-6 glass-panel card-hover">
          <div className="grid md:grid-cols-3 gap-6">
            {[
              { icon: ShieldCheck, t: "Enterprise Security", d: "SOC 2, GDPR & HIPAA aligned. End-to-end encrypted payloads." },
              { icon: Layers, t: "Native Components", d: "Renders to actual Flutter widgets. Pixel-identical to your designs." },
              { icon: Boxes, t: "Composable SDK", d: "3 lines of code. Tree-shakeable. Under 80kb compressed." },
            ].map((f, i) => (
              <div key={i} className="flex gap-3">
                <div className="h-8 w-8 shrink-0 rounded border border-border flex items-center justify-center bg-background">
                  <f.icon className="h-4 w-4" strokeWidth={1.5} />
                </div>
                <div>
                  <div className="text-xs font-extrabold uppercase tracking-wide text-foreground">{f.t}</div>
                  <p className="mt-1 text-xs text-neutral-500 leading-relaxed">{f.d}</p>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </motion.div>
    </section>
  );
}

function DevExperience() {
  const [copied, setCopied] = useState(false);
  const code = `import 'package:embedcraft/embedcraft.dart';\n\nawait EmbedCraft.initialize(\n  apiKey: "YOUR_KEY",\n);\n\nEmbedCraft.attachToRouter(navigatorKey);`;

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    toast.success("Code copied to clipboard!");
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <section id="docs" className="px-4 py-20 select-none">
      <div className="mx-auto max-w-5xl rounded-2xl bg-neutral-950 text-neutral-100 p-6 sm:p-10 overflow-hidden relative border border-neutral-900 shadow-2xl">
        <div className="absolute inset-0 bg-grid-dark opacity-20 pointer-events-none" />
        <div className="relative grid md:grid-cols-2 gap-8 items-center">
          <motion.div
            initial="hidden"
            whileInView="show"
            viewport={{ once: true }}
            variants={stagger}
          >
            <motion.div variants={fadeUp} className="text-[10px] font-bold uppercase tracking-widest text-neutral-500">
              Developer Experience
            </motion.div>
            <h2 className="mt-3 text-2xl sm:text-4xl font-extrabold tracking-tightest leading-tight text-white">
              Built by developers.<br />Integrate in 3 lines.
            </h2>
            <p className="mt-2 text-xs sm:text-sm text-neutral-400 leading-relaxed max-w-md">
              First-class Flutter support. Type-safe APIs. Zero configuration. Ship your integration before standup.
            </p>
            <div className="mt-6 flex gap-3">
              <a href="https://docs.embedcraft.com/" target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 rounded-full bg-white px-4 py-2 text-xs font-bold text-neutral-950 hover:bg-neutral-200 transition-colors btn-hover-invert">
                View Docs <ArrowRight className="h-3 w-3" strokeWidth={2} />
              </a>
              <a href="https://pub.dev" target="_blank" rel="noreferrer" className="inline-flex items-center gap-1.5 rounded-full border border-neutral-800 px-4 py-2 text-xs font-bold text-neutral-300 hover:bg-neutral-900 transition-colors">
                pub.dev
              </a>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="rounded-xl border border-neutral-800 bg-neutral-900/50 backdrop-blur overflow-hidden shadow-2xl relative"
          >
            <div className="flex items-center justify-between border-b border-neutral-800 px-4 py-2.5 bg-neutral-950/40">
              <div className="flex items-center gap-1.5">
                <span className="h-2 w-2 rounded-full bg-neutral-700" />
                <span className="h-2 w-2 rounded-full bg-neutral-600" />
                <span className="h-2 w-2 rounded-full bg-neutral-500" />
                <span className="ml-3 text-[10px] text-neutral-500 font-mono">main.dart</span>
              </div>
              <button 
                onClick={handleCopy}
                className="text-[9px] font-bold uppercase tracking-widest text-neutral-400 hover:text-white px-2 py-0.5 border border-neutral-800 hover:border-neutral-600 bg-neutral-950/20 rounded transition-all"
              >
                {copied ? "Copied" : "Copy"}
              </button>
            </div>
            <pre className="p-4 sm:p-5 text-[11px] sm:text-[12px] leading-relaxed font-mono overflow-x-auto text-neutral-300">
              <span className="text-neutral-500">// 1. Import</span>{"\n"}
              <span className="text-white font-bold">import</span> <span className="text-neutral-100">'package:embedcraft/embedcraft.dart'</span><span className="text-neutral-500">;</span>{"\n\n"}
              <span className="text-neutral-500">// 2. Initialize</span>{"\n"}
              <span className="text-white font-bold">await</span> <span className="text-white font-bold">EmbedCraft</span><span className="text-neutral-500">.</span><span className="text-neutral-300">initialize</span><span className="text-neutral-500">(</span>{"\n"}
              {"  "}<span className="text-neutral-400">apiKey</span><span className="text-neutral-500">:</span> <span className="text-neutral-100 font-semibold">"YOUR_KEY"</span><span className="text-neutral-500">,</span>{"\n"}
              <span className="text-neutral-500">);</span>{"\n\n"}
              <span className="text-neutral-500">// 3. Attach</span>{"\n"}
              <span className="text-white font-bold">EmbedCraft</span><span className="text-neutral-500">.</span><span className="text-neutral-300">attachToRouter</span><span className="text-neutral-500">(</span><span className="text-neutral-400 font-semibold">navigatorKey</span><span className="text-neutral-500">);</span>
            </pre>
          </motion.div>
        </div>
      </div>
    </section>
  );
}

function FeatureRow({ icon: Icon, eyebrow, title, desc, bullets, index }: {
  icon: React.ElementType; eyebrow: string; title: string; desc: string; bullets: string[]; index: number;
}) {
  const isEven = index % 2 === 0;
  return (
    <motion.div
      initial="hidden"
      whileInView="show"
      viewport={{ once: true, margin: "-60px" }}
      variants={staggerSlow}
      className={`grid lg:grid-cols-2 gap-8 lg:gap-14 items-center ${isEven ? "" : "lg:direction-rtl"}`}
    >
      <motion.div variants={isEven ? slideInLeft : slideInRight} className={`${isEven ? "" : "lg:order-2"}`}>
        <div className="inline-flex items-center gap-2 rounded-full border border-border bg-secondary/60 px-3 py-1 text-xs font-medium text-neutral-500 uppercase tracking-[0.15em] mb-4">
          <Icon className="h-3.5 w-3.5" strokeWidth={1.75} />
          {eyebrow}
        </div>
        <h3 className="text-3xl sm:text-4xl font-semibold tracking-tighter text-foreground">{title}</h3>
        <p className="mt-4 text-neutral-600 leading-relaxed max-w-lg">{desc}</p>
        <ul className="mt-6 space-y-3">
          {bullets.map((b) => (
            <li key={b} className="flex items-start gap-3 text-sm text-neutral-600">
              <div className="mt-1 h-5 w-5 rounded-full bg-foreground/5 flex items-center justify-center flex-shrink-0">
                <Zap className="h-3 w-3 text-foreground" strokeWidth={2} />
              </div>
              {b}
            </li>
          ))}
        </ul>
      </motion.div>

      <motion.div variants={isEven ? slideInRight : slideInLeft} className={`${isEven ? "" : "lg:order-1"}`}>
        <div className="relative rounded-2xl border border-border bg-card p-6 sm:p-8 card-hover overflow-hidden">
          <div className="absolute top-0 left-0 w-1 h-full bg-foreground rounded-r-full" />
          <div className="flex items-center gap-3 mb-6">
            <div className="h-10 w-10 rounded-xl flex items-center justify-center bg-foreground text-background">
              <Icon className="h-5 w-5" strokeWidth={1.75} />
            </div>
            <div className="text-lg font-semibold text-foreground">{eyebrow}</div>
          </div>
          <div className="space-y-3">
            {bullets.map((b, i) => (
              <motion.div
                key={b}
                initial={{ opacity: 0, x: 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.1 * i, duration: 0.5 }}
                className="flex items-center gap-3 rounded-lg border border-border/50 bg-secondary px-4 py-3 hover:bg-foreground hover:text-background transition-all duration-300"
              >
                <div className="h-1.5 w-1.5 rounded-full flex-shrink-0 bg-current" />
                <span className="text-sm">{b}</span>
              </motion.div>
            ))}
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}

function PlatformDeepDive() {
  const features = [
    {
      icon: Megaphone,
      eyebrow: "Campaign Builder",
      title: "Build campaigns visually. Ship without code.",
      desc: "A drag-and-drop visual editor that lets your growth team design, target, and schedule native in-app experiences — bottom sheets, modals, banners, and more — without a single line of code.",
      bullets: [
        "Visual drag-and-drop campaign editor with live preview",
        "Schedule campaigns with start/end dates and time zones",
        "Target by segment, screen, event, or user property",
        "A/B test multiple variants with auto-winner selection",
        "Campaign templates for instant launch",
      ],
    },
    {
      icon: Target,
      eyebrow: "Audience Segments",
      title: "Reach the right users at the right moment.",
      desc: "Create dynamic audience segments based on user properties, behavioral events, and real-time conditions. No SQL, no data team needed.",
      bullets: [
        "Build segments with AND/OR rule combinators",
        "Filter by user properties, events, and session data",
        "Real-time segment evaluation on the device",
        "Pre-built segment templates for common patterns",
        "Export and sync segments across campaigns",
      ],
    },
    {
      icon: GitBranch,
      eyebrow: "User Flows",
      title: "Orchestrate multi-step journeys.",
      desc: "Design branching user flows that guide users through onboarding, feature discovery, and conversion funnels with conditional logic and delay steps.",
      bullets: [
        "Visual flow builder with drag-and-drop nodes",
        "Branch on events, properties, or time delays",
        "Trigger nudges, emails, or webhooks at each step",
        "Measure funnel conversion at every stage",
        "Clone and iterate flows without starting from scratch",
      ],
    },
    {
      icon: Gamepad2,
      eyebrow: "Gamification Engine",
      title: "Turn engagement into a game worth playing.",
      desc: "Scratch cards, spin-the-wheel, streaks, milestone challenges, and quiz modules that drive habit formation and reward-based retention loops.",
      bullets: [
        "Spin the wheel with configurable segments and odds",
        "Scratch cards with custom reveal animations",
        "Daily streaks with milestone reward tiers",
        "Challenge campaigns with leaderboard rankings",
        "Quiz modules with instant reward distribution",
      ],
    },
    {
      icon: BarChart3,
      eyebrow: "Real-Time Analytics",
      title: "Measure everything. Guess nothing.",
      desc: "Live dashboards with impressions, clicks, conversions, and revenue attribution tied directly to each campaign. Know what's working in real time.",
      bullets: [
        "Real-time impression and click tracking",
        "Funnel analysis with step-by-step drop-off",
        "Campaign comparison with side-by-side metrics",
        "Revenue attribution per campaign and variant",
        "Custom date ranges and exportable reports",
      ],
    },
    {
      icon: Bell,
      eyebrow: "Event Tracking",
      title: "Capture every signal. Miss nothing.",
      desc: "Track screen views, button taps, form submissions, and custom events with a lightweight SDK. Use events to trigger campaigns and build segments.",
      bullets: [
        "Auto-track screen views and navigation events",
        "Custom event logging with typed properties",
        "Event timeline per user with full history",
        "Use events as campaign triggers in real-time",
        "Debug console for live event inspection",
      ],
    },
    {
      icon: Trophy,
      eyebrow: "Rewards & Coupons",
      title: "Incentivize action with real rewards.",
      desc: "Configure reward tiers, generate unique coupon codes, and distribute them through gamification modules. Track redemption rates and manage inventory.",
      bullets: [
        "Auto-generate unique coupon codes at scale",
        "Reward tiers with configurable win probabilities",
        "Track coupon claims and redemption rates",
        "Integrate rewards with scratch cards and spin wheel",
        "Expiry management and inventory controls",
      ],
    },
    {
      icon: Palette,
      eyebrow: "Asset Library",
      title: "All your creative assets in one place.",
      desc: "Upload, organize, and reuse images, icons, and media files across campaigns. Centralized asset management that keeps your team moving fast.",
      bullets: [
        "Drag-and-drop upload with auto-optimization",
        "Organize assets with folders and tags",
        "Search and filter across all uploaded media",
        "CDN-powered delivery for instant load times",
        "Reuse assets across multiple campaigns",
      ],
    },
    {
      icon: MonitorPlay,
      eyebrow: "Page Builder",
      title: "Create landing pages inside your app.",
      desc: "Build rich in-app pages with a visual editor — webviews, deep links, and custom content that lives inside your app without app store updates.",
      bullets: [
        "WYSIWYG editor for in-app landing pages",
        "Embed videos, images, and interactive elements",
        "Deep link to any screen in your app",
        "Track page views and engagement metrics",
        "Version control with publish/draft states",
      ],
    },
    {
      icon: Code2,
      eyebrow: "API & Developer SDK",
      title: "Built for developers. Loved by product teams.",
      desc: "A clean REST API and lightweight Flutter SDK with offline-first architecture, delta sync, and comprehensive documentation for rapid integration.",
      bullets: [
        "Flutter SDK with 3-line initialization",
        "REST API with full CRUD for all entities",
        "Offline-first with SQLite persistence",
        "Webhook callbacks for real-time event forwarding",
        "Comprehensive API docs with code examples",
      ],
    },
  ];

  return (
    <section className="px-4 py-24">
      <SectionHeader
        eyebrow="Platform Deep Dive"
        title="10 powerful modules. One unified platform."
        sub="Every tool your growth team needs to create, target, gamify, and measure native in-app experiences."
      />
      <div className="mx-auto mt-16 max-w-6xl space-y-20">
        {features.map((f, i) => (
          <FeatureRow key={f.eyebrow} {...f} index={i} />
        ))}
      </div>
    </section>
  );
}

function UseCases() {
  const cases = [
    { label: "Onboarding & Activation", img: onboardingImg, desc: "Get users to their first value moment, fast, with guided tours, spotlights, and checklists that turn sign-ups into activated users." },
    { label: "Cross-Sell & Upsell", img: adoptionImg, desc: "Surface the right product to the right user at the right moment. In the app, not in an email they'll ignore." },
    { label: "Conversion & Monetization", img: conversionImg, desc: "Remove friction at every paywall and decision point. Contextual nudges that convert hesitation into action." },
    { label: "Gamification & Retention", img: gamificationImg, desc: "Make your app worth coming back to. Streaks, rewards, and challenges that turn casual users into daily actives." },
  ];
  return (
    <section className="px-4 py-24 bg-secondary/30 border-y border-border">
      <SectionHeader
        eyebrow="Use Cases"
        title="From first open to loyal power user."
        sub="Built for every stage of the user lifecycle."
      />
      <motion.div
        initial="hidden"
        whileInView="show"
        viewport={{ once: true, margin: "-80px" }}
        variants={stagger}
        className="mx-auto mt-14 grid max-w-6xl grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4"
      >
        {cases.map((c) => (
          <motion.div
            key={c.label}
            variants={fadeUp}
            className="group rounded-2xl border border-border bg-card p-4 card-hover overflow-hidden"
          >
            <div className="relative aspect-[4/3] rounded-xl overflow-hidden bg-secondary/60">
              <img src={c.img} alt={c.label} className="w-full h-full object-cover" loading="lazy" />
            </div>
            <div className="px-1 pt-3 pb-1">
              <div className="text-sm font-medium text-foreground">{c.label}</div>
              <p className="mt-1.5 text-xs text-neutral-500 leading-relaxed">{c.desc}</p>
            </div>
          </motion.div>
        ))}
      </motion.div>
    </section>
  );
}

function TrustStats() {
  const stats = [
    { value: "145ms", label: "P99 latency" },
    { value: "99.9%", label: "Platform uptime" },
    { value: "10K+", label: "Experiences created" },
    { value: "24/7", label: "Support coverage" },
  ];
  return (
    <section className="px-4 py-24">
      <SectionHeader
        eyebrow="Trust & Security"
        title="Enterprise-grade from day one."
      />
      <div className="mx-auto mt-10 max-w-3xl flex items-center justify-center gap-8 sm:gap-12">
        <img src={gdprBadge} alt="GDPR Compliant" className="h-12 sm:h-16 w-auto opacity-70 hover:opacity-100 transition-opacity" />
        <img src={soc2Badge} alt="SOC 2 Certified" className="h-12 sm:h-16 w-auto opacity-70 hover:opacity-100 transition-opacity" />
        <img src={isoBadge} alt="ISO 27001 Certified" className="h-12 sm:h-16 w-auto opacity-70 hover:opacity-100 transition-opacity" />
      </div>
      <motion.div
        initial="hidden"
        whileInView="show"
        viewport={{ once: true, margin: "-80px" }}
        variants={stagger}
        className="mx-auto mt-14 max-w-5xl grid grid-cols-2 md:grid-cols-4 gap-4"
      >
        {stats.map((s) => (
          <motion.div
            key={s.label}
            variants={fadeUp}
            className="rounded-2xl border border-border bg-card p-6 text-center card-hover"
          >
            <div className="text-4xl font-semibold tracking-tighter text-foreground">{s.value}</div>
            <div className="mt-2 text-sm text-neutral-500">{s.label}</div>
          </motion.div>
        ))}
      </motion.div>
    </section>
  );
}

function FinalCTA() {
  return (
    <section id="cta" className="px-4 pb-24">
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.7 }}
        className="mx-auto max-w-6xl rounded-3xl bg-foreground text-background p-12 sm:p-20 text-center relative overflow-hidden"
      >
        <div className="absolute inset-0 bg-grid-dark opacity-30 pointer-events-none" />
        <div className="relative">
          <h2 className="text-4xl sm:text-6xl font-semibold tracking-tighter">
            Ready to launch native<br />in-app experiences?
          </h2>
          <p className="mt-5 text-neutral-400 max-w-lg mx-auto">
            Ship nudges, stories, gamification, and widgets — without waiting for app store reviews.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
            <a href="#contact" className="inline-flex items-center gap-2 rounded-full bg-background px-6 py-3 text-sm font-medium text-foreground hover:bg-neutral-200 transition-colors">
              Get a Demo <ArrowRight className="h-4 w-4" strokeWidth={1.75} />
            </a>
            <a href="https://docs.embedcraft.com/" target="_blank" rel="noreferrer" className="inline-flex items-center gap-2 rounded-full border border-neutral-700 px-6 py-3 text-sm font-medium text-background hover:bg-neutral-900 transition-colors">
              Read the Docs
            </a>
          </div>
        </div>
      </motion.div>
    </section>
  );
}

function Showcase() {
  const items = [
    { label: "Bottom Sheets", icon: Smartphone, src: bottomsheetGif, kind: "img" as const, desc: "Native modals & PiP widgets, scratch cards, & nudges." },
    { label: "Stories", icon: ImageIcon, src: storiesGif, kind: "img" as const, desc: "Instagram-style stories with deep links & analytics." },
    { label: "Animated Nudges", icon: Bell, src: "/media/nudges.mp4", kind: "vid" as const, desc: "Lottie-grade animations rendered natively in Flutter." },
    { label: "In-line Widgets", icon: Layers, src: "/media/widgets.mp4", kind: "vid" as const, desc: "Drop dynamic banners and carousels into any screen." },
  ];
  return (
    <section id="integrations" className="px-4 py-24 bg-secondary/30 border-y border-border">
      <SectionHeader
        eyebrow="Showcase"
        title="Every surface, fully native."
        sub="Bottom sheets, modals, scratch cards, stories, banners, and more — rendered as real Flutter widgets."
      />
      <motion.div
        initial="hidden"
        whileInView="show"
        viewport={{ once: true, margin: "-80px" }}
        variants={stagger}
        className="mx-auto mt-14 grid max-w-6xl grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4"
      >
        {items.map((item) => (
          <motion.div
            key={item.label}
            variants={fadeUp}
            className="group rounded-2xl border border-border bg-card p-3 card-hover overflow-hidden"
          >
            <div className="relative aspect-[9/16] rounded-xl overflow-hidden bg-neutral-950">
              {item.kind === "img" ? (
                <img src={item.src} alt={item.label} className="w-full h-full object-cover" loading="lazy" />
              ) : (
                <video
                  src={item.src}
                  autoPlay
                  loop
                  muted
                  playsInline
                  className="w-full h-full object-cover"
                />
              )}
            </div>
            <div className="px-2 pt-3 pb-1">
              <div className="flex items-center gap-2 text-sm font-medium text-foreground">
                <item.icon className="h-4 w-4 text-neutral-500" strokeWidth={1.5} />
                {item.label}
              </div>
              <p className="mt-1 text-xs text-neutral-500 leading-relaxed">{item.desc}</p>
            </div>
          </motion.div>
        ))}
      </motion.div>
    </section>
  );
}

function Capabilities() {
  const caps = [
    { t: "Campaign Builder", d: "Visual drag-and-drop editor for creating native in-app experiences." },
    { t: "Gamification", d: "Scratch cards, spin-the-wheel, streaks, and milestone rewards." },
    { t: "Audience Segments", d: "Target users by behavior, properties, events, and custom rules." },
    { t: "Event Tracking", d: "Track screen views, taps, and custom events with real-time analytics." },
    { t: "Stories & Nudges", d: "Full-screen stories and contextual nudges with deep-link actions." },
    { t: "A/B Experimentation", d: "Test variants, measure impact, and auto-deploy winners." },
    { t: "Rewards Engine", d: "Configure reward tiers, coupons, and gamified incentive flows." },
    { t: "Offline-First SDK", d: "SQLite sync with delta updates. Works without connectivity." },
  ];
  return (
    <section className="px-4 py-20 select-none">
      <SectionHeader
        eyebrow="Capabilities"
        title="A complete engagement runtime."
        sub="Everything from campaign creation to analytics, built for Flutter apps."
      />
      <div className="mx-auto mt-12 max-w-5xl grid grid-cols-2 md:grid-cols-4 gap-3">
        {caps.map((c) => (
          <div key={c.t} className="rounded-xl border border-border bg-card p-4.5 glass-panel card-hover">
            <Sparkles className="h-3.5 w-3.5 text-neutral-400" strokeWidth={2} />
            <div className="mt-2.5 text-xs font-bold text-foreground uppercase tracking-wider">{c.t}</div>
            <div className="mt-1 text-[11px] text-neutral-500 leading-snug">{c.d}</div>
          </div>
        ))}
      </div>
    </section>
  );
}

function Contact() {
  const [name, setName] = useState("");
  const [company, setCompany] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!name.trim() || !email.trim() || !message.trim()) {
      toast.error("Please fill in all required fields.");
      return;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email.trim())) {
      toast.error("Please enter a valid email address.");
      return;
    }

    setSubmitting(true);
    try {
      const baseUrl = (
        import.meta.env.VITE_API_URL || 
        (import.meta.env.PROD ? "https://embed-backend-w9j0.onrender.com" : "http://localhost:4000")
      ).replace(/\/$/, "");
      const res = await fetch(`${baseUrl}/api/support/contact`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: name.trim(),
          email: email.trim(),
          message: company.trim() ? `Company: ${company.trim()}\n\n${message.trim()}` : message.trim(),
        }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Failed to send message");
      }

      toast.success("Request sent! We'll get back to you soon.");
      setName("");
      setCompany("");
      setEmail("");
      setMessage("");
    } catch (error: any) {
      console.error("Contact form error:", error);
      toast.error(error.message || "Failed to send request. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <section id="contact" className="px-4 py-20 select-none">
      <div className="mx-auto max-w-5xl rounded-2xl border border-border bg-card p-6 sm:p-10 glass-panel shadow-sm">
        <div className="grid lg:grid-cols-2 gap-8 items-center">
          <div>
            <div className="text-[10px] font-bold uppercase tracking-widest text-neutral-400">
              Book a Demo
            </div>
            <h2 className="mt-2 text-3xl sm:text-4xl font-extrabold tracking-tightest leading-tight text-foreground">
              Let's make your app dynamic.
            </h2>
            <p className="mt-2 text-xs text-neutral-500 max-w-md leading-relaxed">
              Reach out for a personalized walkthrough, pricing, or technical deep-dive. We typically reply within 24 hours.
            </p>
            <div className="mt-6 space-y-2">
              <a
                href="mailto:contactembedcraft@gmail.com"
                className="group flex items-center gap-3 rounded-xl border border-border/80 bg-background/50 p-3 hover:border-foreground transition-all"
              >
                <div className="h-8 w-8 rounded-lg bg-foreground text-background flex items-center justify-center">
                  <Mail className="h-4 w-4" strokeWidth={2} />
                </div>
                <div className="flex-1">
                  <div className="text-[9px] font-bold uppercase tracking-wide text-neutral-400">Email us</div>
                  <div className="text-xs font-bold text-foreground">contactembedcraft@gmail.com</div>
                </div>
                <ArrowRight className="h-3.5 w-3.5 text-neutral-400 group-hover:text-foreground group-hover:translate-x-0.5 transition-all" strokeWidth={2} />
              </a>
              <a
                href="#docs"
                className="group flex items-center gap-3 rounded-xl border border-border/80 bg-background/50 p-3 hover:border-foreground transition-all"
              >
                <div className="h-8 w-8 rounded-lg border border-border flex items-center justify-center">
                  <PlayCircle className="h-4 w-4" strokeWidth={2} />
                </div>
                <div className="flex-1">
                  <div className="text-[9px] font-bold uppercase tracking-wide text-neutral-400">Or self-serve</div>
                  <div className="text-xs font-bold text-foreground">Read the documentation</div>
                </div>
                <ArrowRight className="h-3.5 w-3.5 text-neutral-400 group-hover:text-foreground group-hover:translate-x-0.5 transition-all" strokeWidth={2} />
              </a>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="rounded-xl border border-border/80 bg-background/40 p-5 space-y-3.5 shadow-sm">
            <div className="grid sm:grid-cols-2 gap-3">
              <label className="block">
                <span className="text-[10px] font-bold uppercase tracking-wide text-neutral-400">Name</span>
                <input
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="mt-1 w-full rounded-lg border border-border/80 bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground transition-colors"
                  placeholder="Jane Doe"
                />
              </label>
              <label className="block">
                <span className="text-[10px] font-bold uppercase tracking-wide text-neutral-400">Company</span>
                <input
                  value={company}
                  onChange={(e) => setCompany(e.target.value)}
                  className="mt-1 w-full rounded-lg border border-border/80 bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground transition-colors"
                  placeholder="Acme Inc."
                />
              </label>
            </div>
            <label className="block">
              <span className="text-[10px] font-bold uppercase tracking-wide text-neutral-400">Work email</span>
              <input
                required
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="mt-1 w-full rounded-lg border border-border/80 bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground transition-colors"
                placeholder="jane@acme.com"
              />
            </label>
            <label className="block">
              <span className="text-[10px] font-bold uppercase tracking-wide text-neutral-400">What are you building?</span>
              <textarea
                required
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                rows={3}
                className="mt-1 w-full rounded-lg border border-border/80 bg-background px-3 py-2 text-xs focus:outline-none focus:border-foreground transition-colors resize-none"
                placeholder="Tell us about your app."
              />
            </label>
            <button
              type="submit"
              disabled={submitting}
              className="w-full inline-flex items-center justify-center gap-1.5 rounded-full bg-foreground px-4 py-2.5 text-xs font-bold text-background hover:bg-neutral-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed btn-hover-invert"
            >
              {submitting ? "Sending..." : "Send request"} <ArrowRight className="h-3.5 w-3.5" strokeWidth={2} />
            </button>
            <p className="text-[10px] text-neutral-400 text-center font-medium">
              We typically get back to you within 24 hours.
            </p>
          </form>
        </div>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="border-t border-border px-4 py-10">
      <div className="mx-auto max-w-6xl flex flex-col gap-6">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <Logo />
          <div className="flex gap-6 text-sm text-neutral-500">
            <a href="#features" className="hover:text-foreground">Features</a>
            <a href="#integrations" className="hover:text-foreground">Showcase</a>
            <a href="https://docs.embedcraft.com/" target="_blank" rel="noreferrer" className="hover:text-foreground">Docs</a>
            <a href="mailto:contactembedcraft@gmail.com" className="hover:text-foreground">Contact</a>
          </div>
        </div>
        <div className="border-t border-border pt-6 flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-neutral-500">
          <div>© 2026 EmbedCraft, Inc. All rights reserved.</div>
          <a href="mailto:contactembedcraft@gmail.com" className="inline-flex items-center gap-1.5 hover:text-foreground">
            <Mail className="h-3.5 w-3.5" strokeWidth={1.5} />
            <span>contactembedcraft@gmail.com</span>
          </a>
        </div>
      </div>
    </footer>
  );
}

function TechEdge() {
  const specs = [
    { title: "Offline-First", desc: "Local SQLite + SharedPreferences persistence. Campaigns work even without a connection." },
    { title: "Delta Sync", desc: "Only fetch what changed. Minimal payload sizes and lightning-fast updates." },
    { title: "Native Rendering", desc: "Zero webviews. Campaigns are rendered as 100% native Flutter widgets." },
    { title: "Ultra-Low Latency", desc: "Average 145ms from event trigger to UI reveal. Built for high-frequency apps." },
  ];
  return (
    <section className="px-4 py-24 bg-foreground text-background">
      <div className="mx-auto max-w-6xl">
        <div className="text-xs uppercase tracking-[0.3em] opacity-50 font-semibold mb-3">The Technical Edge</div>
        <h2 className="text-5xl sm:text-7xl font-bold tracking-tightest leading-none">Built for the<br/>modern stack.</h2>
        <div className="mt-16 grid sm:grid-cols-2 lg:grid-cols-4 gap-12">
          {specs.map((s, i) => (
            <motion.div
              key={s.title}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              viewport={{ once: true }}
            >
              <div className="text-xl font-bold mb-4">{s.title}</div>
              <p className="text-background/60 leading-relaxed text-sm">{s.desc}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Pricing() {
  const tiers = [
    {
      name: "Starter",
      desc: "Best for apps just getting started with in-app engagement.",
      price: "$849",
      priceSub: "/ month",
      action: "Get Started",
      actionType: "outline",
      featuresLabel: "INCLUDES",
      features: [
        "Drag-and-drop templates — tooltips, nudges, surveys",
        "Segmentation and targeting",
        "Impact measurement",
        "Sync cohorts from Amplitude, Mixpanel, etc",
        "Email support",
      ],
    },
    {
      name: "Growth",
      popular: true,
      desc: "Best for fast-growing consumer brands looking to maximize engagement.",
      price: "$2,149",
      priceSub: "/ month",
      action: "Talk to Us",
      actionType: "solid",
      featuresLabel: "EVERYTHING IN STARTER, PLUS",
      features: [
        "Stories, videos, PiP, and native widgets",
        "Advanced targeting capabilities",
        "A/B/n testing",
        "30-day onboarding program",
      ],
    },
    {
      name: "Enterprise",
      desc: "Enterprise contracts are annual and can have more flexible terms.",
      price: "Custom",
      priceSub: "AMU based and impression based billing.",
      action: "Talk to Us",
      actionType: "outline",
      featuresLabel: "EVERYTHING IN GROWTH, PLUS",
      features: [
        "Gamification — streaks, quizzes, skill-based games, rewards",
        "Off-app channels — push, email, WhatsApp, SMS, voice",
        "Journey builder to connect campaigns",
        "Security certificates on request",
        "Account roles and permissions",
        "Dedicated support and customer success",
      ],
    },
  ];

  return (
    <section id="pricing" className="px-4 py-20 border-t border-border bg-background">
      <SectionHeader
        eyebrow="Pricing"
        title="Simple, predictable pricing."
        sub="Choose the plan that fits your growth stage."
      />
      <div className="mx-auto mt-12 max-w-5xl">
        <div className="grid md:grid-cols-3 gap-5">
          {tiers.map((tier, i) => (
            <motion.div
              key={tier.name}
              initial={{ opacity: 0, y: 15 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.08 }}
              className={`relative flex flex-col rounded-2xl p-6 ${
                tier.popular
                  ? "border-2 border-foreground bg-card shadow-lg"
                  : "border border-border bg-card glass-panel"
              } card-hover`}
            >
              {tier.popular && (
                <div className="absolute top-5 right-5 inline-flex rounded-full bg-foreground px-2.5 py-0.5 text-[8px] font-bold uppercase tracking-wider text-background select-none">
                  Most Popular
                </div>
              )}
              <h3 className="text-xl font-bold tracking-tight text-foreground">{tier.name}</h3>
              <p className="mt-2 text-xs text-neutral-500 min-h-[32px] leading-relaxed">
                {tier.desc}
              </p>
              
              <div className="mt-6">
                {tier.price === "Custom" ? (
                  <div className="flex flex-col justify-center min-h-[64px]">
                    <div className="text-3xl font-extrabold tracking-tightest text-foreground">{tier.price}</div>
                    <div className="text-[10px] text-neutral-400 mt-1">{tier.priceSub}</div>
                  </div>
                ) : (
                  <div className="flex flex-col min-h-[64px] justify-center">
                    <div className="text-[9px] font-bold uppercase tracking-wider text-neutral-400">Starting at</div>
                    <div className="flex items-baseline gap-1 mt-0.5">
                      <span className="text-3xl font-extrabold tracking-tightest text-foreground">{tier.price}</span>
                      <span className="text-neutral-500 font-bold text-xs">{tier.priceSub}</span>
                    </div>
                  </div>
                )}
              </div>
              
              <button
                className={`mt-6 w-full rounded-lg py-2.5 text-xs font-bold uppercase tracking-wider transition-colors btn-hover-invert ${
                  tier.actionType === "solid"
                    ? "bg-foreground text-background hover:bg-neutral-800"
                    : "border border-border bg-background text-foreground hover:bg-neutral-100 dark:hover:bg-neutral-900"
                }`}
              >
                {tier.action}
              </button>

              <div className="mt-8 border-t border-border/40 pt-6 flex-1">
                <div className="text-[9px] font-bold uppercase tracking-wider text-foreground mb-4">
                  {tier.featuresLabel}
                </div>
                <ul className="space-y-3">
                  {tier.features.map((f) => (
                    <li key={f} className="flex items-start gap-2.5">
                      <div className="mt-0.5 flex-shrink-0 text-foreground">
                        <svg width="14" height="14" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                          <path d="M13.3333 4L5.99999 11.3333L2.66666 8" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                      </div>
                      <span className="text-xs text-neutral-500 leading-normal">{f}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001
  });

  return (
    <motion.div
      className="fixed top-0 left-0 right-0 h-1 bg-foreground origin-left z-[60]"
      style={{ scaleX }}
    />
  );
}

function Landing() {
  const { scrollYProgress } = useScroll();
  const [scrollPercentage, setScrollPercentage] = useState(0);

  useMotionValueEvent(scrollYProgress, "change", (latest) => {
    setScrollPercentage(latest);
  });

  return (
    <div className="bg-background min-h-screen">
      {/* Fixed UI Layer (Scaled) */}
      <div 
        style={{
          position: "fixed",
          top: 0, left: 0, right: 0,
          zIndex: 50,
          transform: "scale(0.8)",
          transformOrigin: "top left",
          width: "125%",
          pointerEvents: "none"
        }}
      >
        <div style={{ pointerEvents: "auto" }}>
          <ScrollProgress />
          <Navbar />
        </div>
      </div>

      {/* Main Scrollable Content (Scaled) */}
      <main 
        className="bg-background pb-12 relative overflow-x-clip"
        style={{
          transform: "scale(0.8)",
          transformOrigin: "top left",
          width: "125%",
          minHeight: "125vh"
        }}
      >
        {/* Centered Hero section */}
        <div className="mx-auto max-w-[1680px] pt-20 px-4 sm:px-6 lg:px-12 xl:px-20">
          <Hero scrollPercentage={scrollPercentage} />
        </div>

        {/* Grid container spanning the full width */}
        <div className="mx-auto max-w-[1680px] px-4 sm:px-6 lg:px-12 xl:px-20">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 xl:gap-14 relative">
            <div className="col-span-1 lg:col-span-9 flex flex-col transition-all duration-300">
              <Bento />
              <PlatformDeepDive />
              <Showcase />
              <UseCases />
              <TechEdge />
              <Capabilities />
              <Pricing />
              <TrustStats />
              <DevExperience />
              <Contact />
              <FinalCTA />
            </div>
          </div>
        </div>
        
        <Footer />
      </main>

      {/* Fixed Phone Mockup Layer (Scaled) */}
      <div 
        className="hidden lg:block"
        style={{
          position: "fixed",
          top: 0, left: 0, right: 0, bottom: 0,
          zIndex: 40,
          transform: "scale(0.8)",
          transformOrigin: "top left",
          width: "125%",
          height: "125vh",
          pointerEvents: "none"
        }}
      >
        <motion.div
          initial={{ opacity: 0, x: 80 }}
          animate={scrollPercentage >= 0.04 ? { opacity: 1, x: 0 } : { opacity: 0, x: 80 }}
          transition={{ duration: 0.45, ease: "easeOut" }}
          className="absolute top-40 right-20 xl:right-[7.5rem] w-[300px] xl:w-[325px] pointer-events-none"
        >
          <div className="pointer-events-auto">
            <InteractivePhoneMockup scrollPercentage={scrollPercentage} />
          </div>
        </motion.div>
      </div>
    </div>
  );
}
