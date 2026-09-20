import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/web/adding-stories-web";
const TITLE = "Adding Stories on Web";
const DESCRIPTION = "Configure adding stories on web for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Adding Stories on Web",
    "id": "adding-stories-on-web"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure adding stories on web for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Embed Stories",
    "id": "embed-stories"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Place the stories container where it should appear and pass the current user context through the SDK."
      }
    ]
  },
  {
    "type": "code",
    "lang": "tsx",
    "code": "<EmbedCraftStories\n  placement=\"home_stories\"\n  userId=\"user_123\"\n/>"
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
