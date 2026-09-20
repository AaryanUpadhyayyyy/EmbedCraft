// AUTO-GENERATED page — content for /integrations/cohorts-sync/mixpanel
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/cohorts-sync/mixpanel";
const TITLE = "Mixpanel";
const DESCRIPTION = "Sync cohorts from Mixpanel to EmbedCraft.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Mixpanel Integration",
    "id": "mixpanel-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sync cohorts from Mixpanel to EmbedCraft."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Prerequisites",
    "id": "prerequisites"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Before starting, make sure you have"
      },
      {
        "t": "t",
        "v": "generated a private API key"
      },
      {
        "t": "t",
        "v": "as described in the main Cohorts Sync guide."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Setup Instructions",
    "id": "setup-instructions"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Step 4: Add EmbedCraft Integrations",
    "id": "step-4-add-nudge-integrations"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Navigate to"
      },
      {
        "t": "b",
        "v": "Integrations"
      },
      {
        "t": "t",
        "v": "from the top right settings menu in Mixpanel. Select"
      },
      {
        "t": "b",
        "v": "Custom Webhook"
      },
      {
        "t": "t",
        "v": "from the integration menu."
      }
    ]
  },
  {
    "type": "image",
    "src": "./Mixpanel _ Nudge_files/mixpanel-page.png",
    "alt": "Mixpanel page select integrations"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Step 5: Create Webhook",
    "id": "step-5-create-webhook"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Create a new webhook connection with the URL copied in"
      },
      {
        "t": "t",
        "v": "Step 3"
      },
      {
        "t": "t",
        "v": "."
      }
    ]
  },
  {
    "type": "image",
    "src": "./Mixpanel _ Nudge_files/mixpanel-webhook.png",
    "alt": "Mixpanel set a custom webhook"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Connector name"
      },
      {
        "t": "t",
        "v": ":"
      },
      {
        "t": "c",
        "v": "EmbedCraft cohort sync"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "URL"
      },
      {
        "t": "t",
        "v": ":"
      },
      {
        "t": "c",
        "v": "{BASE_URL}/integration/cohorts/mixpanel"
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
          "v": "Use the"
        },
        {
          "t": "t",
          "v": "base URLs"
        },
        {
          "t": "t",
          "v": "from the main guide"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Add username and password for webhook"
      },
      {
        "t": "t",
        "v": "authorization"
      },
      {
        "t": "t",
        "v": "as described in the main guide."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Select only the"
      },
      {
        "t": "c",
        "v": "mixpanel_distinct_id"
      },
      {
        "t": "t",
        "v": "parameter in the"
      },
      {
        "t": "c",
        "v": "properties to export"
      },
      {
        "t": "t",
        "v": ", as other details are not required for syncing cohorts."
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [],
      [],
      [],
      []
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "3. Webhook Payload Schema",
    "id": "3-webhook-payload-schema"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Mixpanel uses the default webhook schema as per their"
      },
      {
        "t": "t",
        "v": "docs"
      },
      {
        "t": "t",
        "v": ". The following provides a minimal request schema for the webhook:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{\t\"action\": \"add_members\", // [add_members, remove_members, members]\t\"parameters\": {\t\t\"mixpanel_cohort_name\": \"{mixpanel_cohort_name}\",\t\t\"members\": [\t\t\t{\t\t\t\t\"mixpanel_distinct_id\": \"string\"\t\t\t},\t\t\t{\t\t\t\t\"mixpanel_distinct_id\": \"string\"\t\t\t}\t\t]\t}}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The response schema for the webhook follows the schema as mentioned in the Mixpanel docs."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Viewing Your Cohorts",
    "id": "viewing-your-cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Follow the instructions in the"
      },
      {
        "t": "t",
        "v": "main guide"
      },
      {
        "t": "t",
        "v": "to view your synced cohorts in EmbedCraft."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Your Mixpanel integration is now complete. You can start using your Mixpanel cohorts in EmbedCraft."
      }
    ]
  }
] as Block[];

export default function IntegrationsCohortsSyncMixpanelPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
