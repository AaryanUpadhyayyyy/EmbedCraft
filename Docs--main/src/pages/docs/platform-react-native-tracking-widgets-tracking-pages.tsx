import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/react-native/Tracking%20Widgets/tracking-pages";
const TITLE = "React Native Tracking Pages";
const DESCRIPTION = "Configure react native tracking pages for the React Native SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "React Native Tracking Pages",
    "id": "react-native-tracking-pages"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure react native tracking pages for the React Native SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Track pages",
    "id": "track-pages"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Record screen or route changes so flows and campaigns can react to user navigation."
      }
    ]
  },
  {
    "type": "code",
    "lang": "ts",
    "code": "EmbedCraft.page({\n  name: 'Product Details',\n  path: '/products/laptop',\n  properties: { category: 'electronics' },\n});"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "When to call",
    "id": "when-to-call"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Call page tracking after navigation completes and the screen title is known."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
