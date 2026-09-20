import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/iOS/Embedding%20Widgets/Banners";
const TITLE = "iOS Banners";
const DESCRIPTION = "Configure ios banners for the iOS SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "iOS Banners",
    "id": "ios-banners"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure ios banners for the iOS SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Embed Banners",
    "id": "embed-banners"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Place the banners container where it should appear and pass the current user context through the SDK."
      }
    ]
  },
  {
    "type": "code",
    "lang": "tsx",
    "code": "<EmbedCraftBanners\n  placement=\"home_banners\"\n  userId=\"user_123\"\n/>"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Placement rules",
    "id": "placement-rules"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use stable placement names so campaigns can be targeted without another app release."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
