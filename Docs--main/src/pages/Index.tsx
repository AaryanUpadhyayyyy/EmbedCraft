import { Link } from "react-router-dom";
import { ArrowRight, BookOpen, Code2, Layers, Plug, Rocket, Shield, Sparkles, Terminal } from "lucide-react";
import embedCraftLogo from "@/assets/embedcraft-logo.png";

const sections = [
  { icon: Rocket, title: "Getting Started", desc: "Set up your account, find your API keys, and invite teammates.", to: "/getting-started/account-setup" },
  { icon: Sparkles, title: "Quick Start", desc: "Integrate banners, stories, and your first embed in minutes.", to: "/quickstart" },
  { icon: Layers, title: "Platform SDKs", desc: "Web, iOS, Android, Flutter and React Native.", to: "/platform" },
  { icon: Terminal, title: "API Reference", desc: "Identify users, track events, manage cohorts and webhooks.", to: "/apis" },
  { icon: BookOpen, title: "Product", desc: "Users, cohorts, rewards, campaigns, and the visual builder.", to: "/product" },
  { icon: Plug, title: "Integrations", desc: "Connect Shopify, Mixpanel, Amplitude, GTM and more.", to: "/integrations" },
  { icon: Shield, title: "Security", desc: "Short-lived token authentication and data privacy.", to: "/security/authentication" },
  { icon: Code2, title: "Callbacks", desc: "Handle in-app events and route them across your app.", to: "/callback-integration" },
];

export default function Index() {
  return (
    <div className="px-6 md:px-10 py-12 max-w-[1100px] mx-auto">
      <section className="text-center mb-14">
        <img
          src={embedCraftLogo}
          alt="EmbedCraft"
          className="mx-auto h-20 w-20 object-contain mb-6 dark:invert"
        />
        <span className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-border bg-surface-muted text-foreground text-xs font-medium mb-5">
          <Sparkles size={12} /> Welcome to EmbedCraft
        </span>
        <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-foreground" style={{ letterSpacing: "-0.025em" }}>
          Build personalized in-app experiences
          <span className="block text-muted-foreground">without writing code.</span>
        </h1>
        <p className="mt-5 text-base md:text-lg text-muted-foreground max-w-2xl mx-auto">
          EmbedCraft helps product and growth teams launch in-app messages, stories, surveys, rewards
          and onboarding flows — all powered by a visual builder and a flexible API.
        </p>
        <div className="mt-7 flex flex-wrap items-center justify-center gap-3">
          <Link to="/quickstart" className="inline-flex items-center gap-2 h-11 px-5 rounded-md bg-primary text-primary-foreground font-medium hover:bg-primary-strong transition-colors">
            Quick Start <ArrowRight size={16} />
          </Link>
          <Link to="/apis" className="inline-flex items-center gap-2 h-11 px-5 rounded-md border border-border bg-card hover:border-foreground transition-colors font-medium">
            Browse API Reference
          </Link>
        </div>
      </section>

      <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {sections.map(s => (
          <Link key={s.to} to={s.to} className="group rounded-xl border border-border bg-card p-5 hover:shadow-md hover:border-foreground hover:-translate-y-0.5 transition-all">
            <div className="h-10 w-10 rounded-lg bg-foreground grid place-items-center text-background shadow-sm mb-4">
              <s.icon size={18} />
            </div>
            <h3 className="font-semibold text-[15px] mb-1.5 text-foreground">{s.title}</h3>
            <p className="text-sm text-muted-foreground leading-relaxed">{s.desc}</p>
            <span className="mt-3 inline-flex items-center gap-1 text-xs font-medium text-foreground opacity-0 group-hover:opacity-100 transition-opacity">
              Read more <ArrowRight size={12} />
            </span>
          </Link>
        ))}
      </section>

      <footer className="mt-16 pt-8 border-t border-border text-center text-sm text-muted-foreground">
        EmbedCraft documentation
      </footer>
    </div>
  );
}
