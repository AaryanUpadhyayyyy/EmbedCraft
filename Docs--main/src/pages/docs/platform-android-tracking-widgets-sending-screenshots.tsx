import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/android/Tracking%20Widgets/sending-screenshots";
const TITLE = "Sending Screenshots on Android";
const DESCRIPTION = "Configure sending screenshots on android for the Android SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Sending Screenshots on Android",
    "id": "sending-screenshots-on-android"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure sending screenshots on android for the Android SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Send screenshots",
    "id": "send-screenshots"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Screenshots help the visual builder preview in-app placements and configure campaigns accurately."
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
          "v": "Capture only screens that are safe for your team to preview."
        }
      ],
      [
        {
          "t": "t",
          "v": "Mask sensitive fields before upload."
        }
      ],
      [
        {
          "t": "t",
          "v": "Refresh screenshots when layouts change significantly."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
