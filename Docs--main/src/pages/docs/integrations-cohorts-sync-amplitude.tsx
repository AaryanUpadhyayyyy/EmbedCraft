// AUTO-GENERATED page — content for /integrations/cohorts-sync/amplitude
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/cohorts-sync/amplitude";
const TITLE = "Amplitude";
const DESCRIPTION = "Sync cohorts from Amplitude Data to EmbedCraft.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Amplitude Integration",
    "id": "amplitude-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sync cohorts from Amplitude Data to EmbedCraft."
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
    "text": "1. Add a New Webhook in Amplitude",
    "id": "1-add-a-new-webhook-in-amplitude"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "In Amplitude Data, go to"
        },
        {
          "t": "c",
          "v": "Catalog > Destinations"
        }
      ],
      [
        {
          "t": "t",
          "v": "Click webhook in the cohorts section"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "2. Configure the Webhook for EmbedCraft",
    "id": "2-configure-the-webhook-for-nudge"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "When setting up the webhook in Amplitude, use the following configuration:"
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
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Name"
        },
        {
          "t": "t",
          "v": ":"
        },
        {
          "t": "c",
          "v": "EmbedCraft"
        }
      ],
      [
        {
          "t": "b",
          "v": "Request Type"
        },
        {
          "t": "t",
          "v": ":"
        },
        {
          "t": "c",
          "v": "POST"
        }
      ],
      [
        {
          "t": "b",
          "v": "Request URL"
        },
        {
          "t": "t",
          "v": ":"
        },
        {
          "t": "c",
          "v": "{BASE_URL}/integration/cohorts/amplitude"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "3. Header Parameters",
    "id": "3-header-parameters"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Enable"
      },
      {
        "t": "b",
        "v": "Header Parameters"
      },
      {
        "t": "t",
        "v": "and add your"
      },
      {
        "t": "t",
        "v": "API key"
      },
      {
        "t": "t",
        "v": "as described in the main guide."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "4. Define the Payload Schema",
    "id": "4-define-the-payload-schema"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use the default Apache freemaker schema in Amplitude. A payload should look like this:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{\t\"cohort_name\": \"sample cohort\", // the name for each cohort must be unique\t\"cohort_id\": \"qwertypoiuyt\",\t\"in_cohort\": true,\t\"message_id\": \"4415e348-2537-46cb-8bf2-b27523ad724a::enter::0\",\t\"users\": [\t\t{\t\t\t\"user_id\": \"usr_1\" // your user id\t\t},\t\t{\t\t\t\"user_id\": \"usr_2\"\t\t},\t\t{\t\t\t\"user_id\": \"usr_3\"\t\t}\t]}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use cohort sync with updates per cohort instead of per user."
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
        "v": "Your Amplitude integration is now complete. You can start using your Amplitude cohorts in EmbedCraft."
      }
    ]
  }
] as Block[];

export default function IntegrationsCohortsSyncAmplitudePage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
