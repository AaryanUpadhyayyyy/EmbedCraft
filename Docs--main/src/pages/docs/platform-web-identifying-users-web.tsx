import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/web/identifying-users-web";
const TITLE = "Identifying Users";
const DESCRIPTION = "Configure identifying users for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Identifying Users",
    "id": "identifying-users"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure identifying users for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Identify a user",
    "id": "identify-a-user"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Call identify after login or when a stable user id becomes available."
      }
    ]
  },
  {
    "type": "code",
    "lang": "ts",
    "code": "EmbedCraft.identify({\n  userId: 'user_123',\n  name: 'Ava Sharma',\n  email: 'ava@example.com',\n  properties: { plan: 'pro', city: 'Delhi' },\n});"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Best practices",
    "id": "best-practices"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Use the same user id across backend, analytics, and EmbedCraft."
        }
      ],
      [
        {
          "t": "t",
          "v": "Send only attributes needed for segmentation and personalization."
        }
      ],
      [
        {
          "t": "t",
          "v": "Call identify again when important profile attributes change."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
