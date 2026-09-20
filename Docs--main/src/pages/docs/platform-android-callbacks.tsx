import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/android/Callbacks";
const TITLE = "Android Callbacks";
const DESCRIPTION = "This section collects the Android SDK guides for installing EmbedCraft, identifying users, tracking activity, embedding experiences, and handling callbacks.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Android Callbacks",
    "id": "android-callbacks"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This section collects the Android SDK guides for installing EmbedCraft, identifying users, tracking activity, embedding experiences, and handling callbacks."
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
          "v": "Android Core Callbacks",
          "h": "/platform/android/Callbacks/corecallbacks"
        },
        {
          "t": "t",
          "v": " \u2014 open this internal documentation page."
        }
      ],
      [
        {
          "t": "a",
          "v": "Android UI Callbacks",
          "h": "/platform/android/Callbacks/uicallbacks"
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
