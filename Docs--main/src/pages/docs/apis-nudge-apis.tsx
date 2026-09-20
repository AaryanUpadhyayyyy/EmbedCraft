import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/nudge-apis";
const TITLE = "EmbedCraft APIs";
const DESCRIPTION = "Use EmbedCraft APIs to identify users, track events, manage cohorts, export reports, and receive webhooks.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "EmbedCraft APIs",
    "id": "embedcraft-apis"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use EmbedCraft APIs to identify users, track events, manage cohorts, export reports, and receive webhooks."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Base workflow",
    "id": "base-workflow"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "a",
          "v": "Identify user",
          "h": "/apis/identify-user"
        },
        {
          "t": "t",
          "v": " \u2014 create or update a profile."
        }
      ],
      [
        {
          "t": "a",
          "v": "Track event",
          "h": "/apis/track-event"
        },
        {
          "t": "t",
          "v": " \u2014 send behavioral events."
        }
      ],
      [
        {
          "t": "a",
          "v": "Create cohort",
          "h": "/apis/create-cohort"
        },
        {
          "t": "t",
          "v": " \u2014 build user groups."
        }
      ],
      [
        {
          "t": "a",
          "v": "Webhook",
          "h": "/apis/webhook"
        },
        {
          "t": "t",
          "v": " \u2014 receive server callbacks."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Authentication",
    "id": "authentication"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use server-generated tokens for protected operations and keep private keys outside client code."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
