// AUTO-GENERATED page — content for /integrations
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations";
const TITLE = "Integrations";
const DESCRIPTION = "&lt;SectionLanding";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Integrations",
    "id": "integrations"
  },
  {
    "type": "heading",
    "level": 1,
    "text": "Integrations",
    "id": "integrations"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Connect EmbedCraft with your favorite tools and platforms. Sync data, automate workflows, and enhance your user engagement strategy."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Cohorts Sync",
    "id": "cohorts-sync"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sync user cohorts from analytics platforms like Amplitude, Mixpanel, and CleverTap."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Google Tag Manager",
    "id": "google-tag-manager"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Integrate EmbedCraft with Google Tag Manager for easy deployment and event tracking."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Shopify",
    "id": "shopify"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Seamlessly integrate EmbedCraft with your Shopify store for e-commerce engagement."
      }
    ]
  }
] as Block[];

export default function IntegrationsPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
