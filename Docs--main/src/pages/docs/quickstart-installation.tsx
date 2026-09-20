// Manually authored page — content for /quickstart/installation
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/quickstart/installation";
const TITLE = 'Installation';
const DESCRIPTION = 'Install the EmbedCraft SDK in your web or mobile app.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Installation",
    "id": "installation"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Web",
    "id": "web"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Install via npm or yarn:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "bash",
    "code": "npm install @embedcraft/web\n# or\nyarn add @embedcraft/web"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Initialize the SDK",
    "id": "initialize-the-sdk"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Initialize once at app startup with your public API key."
      }
    ]
  },
  {
    "type": "code",
    "lang": "ts",
    "code": "import { EmbedCraft } from '@embedcraft/web';\n\nEmbedCraft.init({\n  apiKey: 'YOUR_PUBLIC_API_KEY',\n  workspaceId: 'YOUR_WORKSPACE_ID',\n});"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "iOS",
    "id": "ios"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Add the EmbedCraft pod to your Podfile and run pod install."
      }
    ]
  },
  {
    "type": "code",
    "lang": "ruby",
    "code": "pod 'EmbedCraft', '~> 1.0'"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Android",
    "id": "android"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Add the EmbedCraft dependency to your module build.gradle."
      }
    ]
  },
  {
    "type": "code",
    "lang": "groovy",
    "code": "implementation 'com.embedcraft:sdk:1.0.0'"
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
        "v": "After initializing, you should see a successful handshake event in the EmbedCraft dashboard within a few seconds."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
