import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Events";
const TITLE = "Events";
const DESCRIPTION = "Events for EmbedCraft.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Events",
    "id": "events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Events for EmbedCraft."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Implementation notes",
    "id": "implementation-notes"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Keep API keys and workspace identifiers in environment-specific configuration."
        }
      ],
      [
        {
          "t": "t",
          "v": "Initialize EmbedCraft once and reuse the SDK instance across screens."
        }
      ],
      [
        {
          "t": "t",
          "v": "Validate the page in a staging workspace before shipping to production."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
