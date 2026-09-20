// Manually authored page — content for /quickstart/basic-integration
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/quickstart/basic-integration";
const TITLE = 'Basic Integration Guide';
const DESCRIPTION = 'End-to-end checklist to ship your first EmbedCraft experience.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Basic Integration Guide",
    "id": "basic-integration-guide"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Prerequisites",
    "id": "prerequisites"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "An active EmbedCraft workspace and public API key."
        }
      ],
      [
        {
          "t": "t",
          "v": "Access to your application's source code."
        }
      ],
      [
        {
          "t": "t",
          "v": "A test user account for previewing experiences."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 1 \u2014 Install the SDK",
    "id": "step-1--install-the-sdk"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Follow the Installation guide for your target platform."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 2 \u2014 Identify users",
    "id": "step-2--identify-users"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Call identify with a stable user id immediately after login so EmbedCraft can target the right audience."
      }
    ]
  },
  {
    "type": "code",
    "lang": "ts",
    "code": "EmbedCraft.identify('user_123', {\n  email: 'jane@example.com',\n  plan: 'pro',\n  signupDate: '2024-03-12'\n});"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 3 \u2014 Track events",
    "id": "step-3--track-events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Track key product events to power triggers and cohorts."
      }
    ]
  },
  {
    "type": "code",
    "lang": "ts",
    "code": "EmbedCraft.track('checkout_started', { cartValue: 79.5 });"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 4 \u2014 Create your first campaign",
    "id": "step-4--create-your-first-campaign"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "In the EmbedCraft dashboard, create a new in-app message, choose a trigger, and publish to your test environment."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 5 \u2014 QA & ship",
    "id": "step-5--qa--ship"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Verify the experience renders correctly on your test build, then promote to production."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
