import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/iOS/Tracking%20Widgets/tracking-widgets-ios";
const TITLE = "iOS Widget Tracking";
const DESCRIPTION = "Configure ios widget tracking for the iOS SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "iOS Widget Tracking",
    "id": "ios-widget-tracking"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure ios widget tracking for the iOS SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Track widget lifecycle",
    "id": "track-widget-lifecycle"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Widget tracking records impressions, clicks, dismissals, and completion states for embedded UI."
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Track impressions only when the widget is visible."
        }
      ],
      [
        {
          "t": "t",
          "v": "Forward click metadata to your analytics layer if needed."
        }
      ],
      [
        {
          "t": "t",
          "v": "Use callbacks to sync custom UI state."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
