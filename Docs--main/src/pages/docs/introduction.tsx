// Manually authored page — content for /introduction
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/introduction";
const TITLE = 'Introduction';
const DESCRIPTION = 'Welcome to EmbedCraft — a no-code platform for in-app campaigns, nudges, surveys, and journeys.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Introduction",
    "id": "introduction"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Overview",
    "id": "overview"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft helps product, growth and engineering teams launch in-app experiences without shipping new builds. Configure once, target precisely, and ship instantly to web, iOS, Android and Flutter."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Core capabilities",
    "id": "core-capabilities"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Campaigns \u2014 in-app messages, nudges, stories, surveys, referrals."
        }
      ],
      [
        {
          "t": "t",
          "v": "Visual Builder \u2014 drag-and-drop authoring with widgets, actions and variables."
        }
      ],
      [
        {
          "t": "t",
          "v": "Flows \u2014 multi-step journeys with conditional branching."
        }
      ],
      [
        {
          "t": "t",
          "v": "Cohorts \u2014 static and dynamic audience segmentation."
        }
      ],
      [
        {
          "t": "t",
          "v": "Rewards \u2014 gamified incentives with delivery automation."
        }
      ],
      [
        {
          "t": "t",
          "v": "Integrations \u2014 Shopify, GTM, Mixpanel, Amplitude, CleverTap and more."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Where to next?",
    "id": "where-to-next"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Start with the Quick Start Guide to ship your first experience in under 10 minutes, or jump straight into the API Reference if you prefer to integrate manually."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
