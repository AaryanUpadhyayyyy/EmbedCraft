import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/web/api-registry";
const TITLE = "API Registry";
const DESCRIPTION = "Configure api registry for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "API Registry",
    "id": "api-registry"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure api registry for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Registry methods",
    "id": "registry-methods"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Method"
        }
      ],
      [
        {
          "t": "t",
          "v": "Purpose"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "t",
            "v": "init"
          }
        ],
        [
          {
            "t": "t",
            "v": "Initialize the SDK with workspace configuration"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "identify"
          }
        ],
        [
          {
            "t": "t",
            "v": "Attach the current app user"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "track"
          }
        ],
        [
          {
            "t": "t",
            "v": "Send user events"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "page"
          }
        ],
        [
          {
            "t": "t",
            "v": "Track screens and routes"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "show"
          }
        ],
        [
          {
            "t": "t",
            "v": "Render a campaign, banner, story, or widget"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Usage",
    "id": "usage"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Keep API calls behind your own integration wrapper when multiple teams contribute to the app."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
