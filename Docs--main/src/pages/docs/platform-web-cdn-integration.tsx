import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/web/cdn-integration";
const TITLE = "CDN Integration";
const DESCRIPTION = "Configure cdn integration for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "CDN Integration",
    "id": "cdn-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure cdn integration for the Web SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Install",
    "id": "install"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Add the SDK package or CDN script, then initialize it once during application startup."
      }
    ]
  },
  {
    "type": "code",
    "lang": "ts",
    "code": "import { EmbedCraft } from '@embedcraft/sdk';\n\nEmbedCraft.init({\n  apiKey: 'YOUR_PUBLIC_API_KEY',\n  workspaceId: 'YOUR_WORKSPACE_ID',\n});"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Verify",
    "id": "verify"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Open the app, complete one test session, and confirm that the user appears in the EmbedCraft dashboard."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
