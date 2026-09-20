import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Cohorts/import";
const TITLE = "Import Cohorts";
const DESCRIPTION = "Use import cohorts to group users for campaigns, rewards, messages, and experiments.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Import Cohorts",
    "id": "import-cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use import cohorts to group users for campaigns, rewards, messages, and experiments."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Use cases",
    "id": "use-cases"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Target campaigns to users who match behavior or profile rules."
        }
      ],
      [
        {
          "t": "t",
          "v": "Exclude internal testers or users already rewarded."
        }
      ],
      [
        {
          "t": "t",
          "v": "Sync cohorts from CSV, analytics tools, or APIs."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Activation",
    "id": "activation"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "After a cohort is created or imported, select it inside campaign display rules or reward eligibility rules."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
