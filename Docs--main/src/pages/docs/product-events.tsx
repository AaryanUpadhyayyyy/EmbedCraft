// Manually authored page — content for /product/events
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/events";
const TITLE = 'Events';
const DESCRIPTION = 'Track user actions to power triggers, cohorts and analytics.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Events",
    "id": "events"
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
        "v": "Events are the atomic unit of behaviour in EmbedCraft. Every track() call creates an event that can be used to build cohorts, trigger campaigns, branch flows, and measure performance."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Event structure",
    "id": "event-structure"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "name \u2014 a short, machine-friendly identifier (e.g. checkout_started)."
        }
      ],
      [
        {
          "t": "t",
          "v": "properties \u2014 a flat map of values describing the event."
        }
      ],
      [
        {
          "t": "t",
          "v": "timestamp \u2014 automatically captured by the SDK."
        }
      ],
      [
        {
          "t": "t",
          "v": "user_id \u2014 automatically attached from identify()."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Recommended events",
    "id": "recommended-events"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "session_started, session_ended"
        }
      ],
      [
        {
          "t": "t",
          "v": "screen_viewed, page_viewed"
        }
      ],
      [
        {
          "t": "t",
          "v": "signup_completed, login_succeeded"
        }
      ],
      [
        {
          "t": "t",
          "v": "checkout_started, purchase_completed"
        }
      ],
      [
        {
          "t": "t",
          "v": "feature_used (with a feature property)"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Best practices",
    "id": "best-practices"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use snake_case event names, keep property keys consistent, and avoid sending PII as properties \u2014 use identify traits for that."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
