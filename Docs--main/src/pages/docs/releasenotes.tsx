import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/releasenotes";
const TITLE = "Release Notes";
const DESCRIPTION = "Track product and SDK updates for EmbedCraft across web, mobile, APIs, integrations, and dashboard features.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Release Notes",
    "id": "release-notes"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Track product and SDK updates for EmbedCraft across web, mobile, APIs, integrations, and dashboard features."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Latest updates",
    "id": "latest-updates"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Expanded platform SDK documentation for Web, Android, iOS, Flutter, and React Native."
        }
      ],
      [
        {
          "t": "t",
          "v": "Improved API reference coverage for cohorts, reports, referrals, and webhooks."
        }
      ],
      [
        {
          "t": "t",
          "v": "Added clearer campaign, visual builder, integration, and security guides."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Versioning",
    "id": "versioning"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Review release notes before upgrading SDK versions in production apps."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
