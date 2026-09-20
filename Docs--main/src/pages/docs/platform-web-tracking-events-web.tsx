import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/web/tracking-events-web";
const TITLE = "Tracking Events";
const DESCRIPTION = "Configure tracking events for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Tracking Events",
    "id": "tracking-events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure tracking events for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Track an event",
    "id": "track-an-event"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Send product events whenever users perform meaningful actions."
      }
    ]
  },
  {
    "type": "code",
    "lang": "ts",
    "code": "EmbedCraft.track('checkout_started', {\n  cartValue: 1299,\n  currency: 'INR',\n  items: 3,\n});"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Event naming",
    "id": "event-naming"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Use readable snake_case names."
        }
      ],
      [
        {
          "t": "t",
          "v": "Keep property names stable across platforms."
        }
      ],
      [
        {
          "t": "t",
          "v": "Avoid sending sensitive personal data in event properties."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
