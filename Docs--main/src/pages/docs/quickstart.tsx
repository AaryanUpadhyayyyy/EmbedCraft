// AUTO-GENERATED page — content for /quickstart
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/quickstart";
const TITLE = "Quick Start Guide";
const DESCRIPTION = "&lt;SectionLanding";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Quick Start Guide",
    "id": "quick-start-guide"
  },
  {
    "type": "heading",
    "level": 1,
    "text": "Quick Start Guide",
    "id": "quick-start-guide"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Get up and running with EmbedCraft in minutes. Complete integration guide covering installation, user tracking, and widget implementation across all platforms."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Basic Integration",
    "id": "basic-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Complete guide to installing EmbedCraft SDK, initializing the library, and setting up your first integration."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Banner Integration",
    "id": "banner-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Create and display beautiful banner notifications to communicate important messages."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Stories Integration",
    "id": "stories-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Implement engaging Instagram-style stories to boost user engagement and retention."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Integration Checklist",
    "id": "integration-checklist"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Check if your integration is complete and working as expected."
      }
    ]
  }
] as Block[];

export default function QuickstartPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
