// Manually authored page — content for /getting-started/account-setup-configuration
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/getting-started/account-setup-configuration";
const TITLE = 'Account Setup & Configuration';
const DESCRIPTION = 'Configure your workspace, environments and defaults after signing up.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Account Setup & Configuration",
    "id": "account-setup-&-configuration"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Workspace basics",
    "id": "workspace-basics"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "After creating your account, configure your workspace name, logo, default timezone and primary contact under Settings \u2192 Workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Environments",
    "id": "environments"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft provisions Development, Staging and Production environments by default. Each environment has its own API keys and isolated data."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Default targeting",
    "id": "default-targeting"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Set workspace-wide defaults for language, locale, frequency caps and quiet hours so every new campaign inherits sensible guardrails."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Notifications",
    "id": "notifications"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure where workspace alerts (delivery failures, integration issues, billing events) are routed \u2014 email, Slack or webhook."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Next steps",
    "id": "next-steps"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Invite your team."
        }
      ],
      [
        {
          "t": "t",
          "v": "Connect your first integration."
        }
      ],
      [
        {
          "t": "t",
          "v": "Create your first cohort."
        }
      ],
      [
        {
          "t": "t",
          "v": "Ship your first campaign."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
