import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/google-tag-manager";
const TITLE = "Google Tag Manager";
const DESCRIPTION = "Use Google Tag Manager to load EmbedCraft and forward data layer events without changing every page in your application.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Google Tag Manager",
    "id": "google-tag-manager"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use Google Tag Manager to load EmbedCraft and forward data layer events without changing every page in your application."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Pages",
    "id": "pages"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "a",
          "v": "Set Up",
          "h": "/integrations/google-tag-manager/set-up"
        },
        {
          "t": "t",
          "v": " \u2014 open this internal documentation page."
        }
      ],
      [
        {
          "t": "a",
          "v": "Data Layer",
          "h": "/integrations/google-tag-manager/data-layer"
        },
        {
          "t": "t",
          "v": " \u2014 open this internal documentation page."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Recommended order",
    "id": "recommended-order"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Install or load the SDK before calling user, event, or UI APIs."
        }
      ],
      [
        {
          "t": "t",
          "v": "Identify the current user as soon as your authenticated session is available."
        }
      ],
      [
        {
          "t": "t",
          "v": "Track key screens and events before embedding banners, stories, or widgets."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
