// Manually authored page — content for /product/Campaigns/streaks
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Campaigns/streaks";
const TITLE = 'Streaks';
const DESCRIPTION = 'Reward consistent user behaviour with streak campaigns.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Streaks",
    "id": "streaks"
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
        "v": "Streaks let you reward users for performing a target action across consecutive days, weeks or sessions \u2014 perfect for habit-forming experiences such as learning, fitness and finance apps."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How it works",
    "id": "how-it-works"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Pick a qualifying event (e.g. lesson_completed)."
        }
      ],
      [
        {
          "t": "t",
          "v": "Define the streak window (daily, weekly or custom)."
        }
      ],
      [
        {
          "t": "t",
          "v": "Configure rewards at each milestone (3-day, 7-day, 30-day)."
        }
      ],
      [
        {
          "t": "t",
          "v": "Choose a recovery policy for missed days."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Display",
    "id": "display"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Streaks can be surfaced via any Visual Builder widget \u2014 counters, progress bars, badges, or full-screen celebrations."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Analytics",
    "id": "analytics"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Track streak starts, breaks, recoveries, and milestone reaches to understand long-term engagement."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
