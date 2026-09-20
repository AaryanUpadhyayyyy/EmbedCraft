// AUTO-GENERATED page — content for /integrations/cohorts-sync/clevertap
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/cohorts-sync/clevertap";
const TITLE = "CleverTap";
const DESCRIPTION = "Sync cohorts from CleverTap to EmbedCraft.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "CleverTap Integration",
    "id": "clevertap-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sync cohorts from CleverTap to EmbedCraft."
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
    "text": "1. Add New Webhooks in CleverTap",
    "id": "1-add-new-webhooks-in-clevertap"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Go to the settings section in CleverTap and add new webhooks for both adding and removing users."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "2. Configure Webhooks for EmbedCraft",
    "id": "2-configure-webhooks-for-nudge"
  },
  {
    "type": "heading",
    "level": 4,
    "text": "To Add Users to Cohort",
    "id": "to-add-users-to-cohort"
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
          "v": "EmbedCraft add users in cohort"
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
          "v": "{BASE_URL}/integration/cohorts/clevertap"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "To Remove Users from Cohort",
    "id": "to-remove-users-from-cohort"
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
          "v": "EmbedCraft remove users from cohort"
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
          "v": "PUT"
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
          "v": "{BASE_URL}/integration/cohorts/clevertap/remove"
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
        "v": "For both webhooks, enable"
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
    "text": "4. Webhook Component Configuration",
    "id": "4-webhook-component-configuration"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "c",
          "v": "cohortName"
        },
        {
          "t": "t",
          "v": "(string): Your cohort name. Ensure the name is unique"
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
          "v": "Service Provider"
        },
        {
          "t": "t",
          "v": ": Select the webhook name ("
        },
        {
          "t": "c",
          "v": "EmbedCraft"
        },
        {
          "t": "t",
          "v": ") you created"
        }
      ],
      [
        {
          "t": "t",
          "v": "Click"
        },
        {
          "t": "b",
          "v": "Go to Editor"
        }
      ],
      [
        {
          "t": "t",
          "v": "Add a custom key-value pair:"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "5. Create a Journey in CleverTap",
    "id": "5-create-a-journey-in-clevertap"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Go to"
        },
        {
          "t": "b",
          "v": "Journeys"
        },
        {
          "t": "t",
          "v": "and start a new one"
        }
      ],
      [
        {
          "t": "t",
          "v": "Choose your desired"
        },
        {
          "t": "b",
          "v": "Cohort"
        }
      ],
      [
        {
          "t": "t",
          "v": "Add a"
        },
        {
          "t": "b",
          "v": "Webhook Stream"
        },
        {
          "t": "t",
          "v": "component"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The rate limit for CleverTap webhooks is 1000 requests per minute per cohort, and request size limit of 1 MB."
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
        "v": "Your CleverTap integration is now complete. You can start using your CleverTap cohorts in EmbedCraft."
      }
    ]
  }
] as Block[];

export default function IntegrationsCohortsSyncClevertapPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
