// Manually authored page — content for /product/Campaigns/challenges
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Campaigns/challenges";
const TITLE = 'Challenges';
const DESCRIPTION = 'Time-bound goals that drive activation, retention and monetisation.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Challenges",
    "id": "challenges"
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
        "v": "Challenges combine goals, progress tracking and rewards into a single campaign primitive. Use them for onboarding checklists, seasonal events, and re-engagement pushes."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Components",
    "id": "components"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Goal \u2014 the target metric (events, revenue, sessions)."
        }
      ],
      [
        {
          "t": "t",
          "v": "Duration \u2014 start and end dates, or rolling window."
        }
      ],
      [
        {
          "t": "t",
          "v": "Progress UI \u2014 built with Visual Builder widgets."
        }
      ],
      [
        {
          "t": "t",
          "v": "Reward \u2014 points, coupons, badges or custom payloads."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Targeting",
    "id": "targeting"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Combine cohorts and event triggers to enroll the right users automatically."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Examples",
    "id": "examples"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Onboarding 7-day checklist with a coupon at completion."
        }
      ],
      [
        {
          "t": "t",
          "v": "Holiday spend challenge \u2014 earn double points on purchases."
        }
      ],
      [
        {
          "t": "t",
          "v": "Win-back challenge \u2014 return 3 times in 14 days for a free trial."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
