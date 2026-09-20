// AUTO-GENERATED page — content for /integrations/cohorts-sync
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/cohorts-sync";
const TITLE = "Cohorts Sync";
const DESCRIPTION = "Sync cohorts from your analytics platforms directly into EmbedCraft to create targeted experiences and campaigns.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Cohorts Sync Integration",
    "id": "cohorts-sync-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sync cohorts from your analytics platforms directly into EmbedCraft to create targeted experiences and campaigns."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Supported Platforms",
    "id": "supported-platforms"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Amplitude"
        }
      ],
      [
        {
          "t": "t",
          "v": "CleverTap"
        }
      ],
      [
        {
          "t": "t",
          "v": "Mixpanel"
        }
      ],
      [
        {
          "t": "t",
          "v": "CSV Import"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Getting Started",
    "id": "getting-started"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "1. Generate a Private API Key",
    "id": "1-generate-a-private-api-key"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Before setting up any cohort sync integration, you'll need to generate a private API key:"
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Step 1: Create a Private API Key",
    "id": "step-1-create-a-private-api-key"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Navigate to"
        },
        {
          "t": "b",
          "v": "Settings"
        },
        {
          "t": "t",
          "v": ">"
        },
        {
          "t": "b",
          "v": "API Keys"
        },
        {
          "t": "t",
          "v": "in the EmbedCraft Dashboard."
        }
      ],
      [
        {
          "t": "t",
          "v": "Click on"
        },
        {
          "t": "b",
          "v": "Create API Key"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "t",
          "v": "Select"
        },
        {
          "t": "b",
          "v": "Private Key"
        },
        {
          "t": "t",
          "v": "as the type."
        }
      ]
    ]
  },
  {
    "type": "image",
    "src": "./Cohorts Sync _ Nudge_files/create-private-key.jpg",
    "alt": "Create Private API Key"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Step 2: Configure Permissions",
    "id": "step-2-configure-permissions"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Ensure the API key has the necessary permissions to manage cohorts."
      }
    ]
  },
  {
    "type": "image",
    "src": "./Cohorts Sync _ Nudge_files/private-key-permissions.png",
    "alt": "Private key permissions"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Save your API key securely. You won't be able to view it again after closing this dialog."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "2. Webhook Configuration",
    "id": "2-webhook-configuration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "When configuring webhooks in your analytics platform, you'll use these common settings:"
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Base URLs",
    "id": "base-urls"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Asia"
        },
        {
          "t": "t",
          "v": ":"
        },
        {
          "t": "c",
          "v": "https://main-api.embedcraft.com/api"
        }
      ],
      [
        {
          "t": "b",
          "v": "US"
        },
        {
          "t": "t",
          "v": ":"
        },
        {
          "t": "c",
          "v": "https://us1.api.embedcraft.com/api"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Authorization",
    "id": "authorization"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "i",
        "v": "Using API Key"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Add the following header to your webhook configuration:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "c",
          "v": "apikey"
        },
        {
          "t": "t",
          "v": ": Your private API key (required for authorization)"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "i",
        "v": "Basic Auth"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Alternatively, you can use basic authentication with the following credentials:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Username"
        },
        {
          "t": "t",
          "v": ":"
        },
        {
          "t": "c",
          "v": "nudge"
        }
      ],
      [
        {
          "t": "b",
          "v": "Password"
        },
        {
          "t": "t",
          "v": ": Your private API key"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Request Method",
    "id": "request-method"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Most integrations use"
      },
      {
        "t": "c",
        "v": "POST"
      },
      {
        "t": "t",
        "v": "method for adding users to cohorts, unless stated otherwise."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Webhook limits",
    "id": "webhook-limits"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Rate Limit"
        },
        {
          "t": "t",
          "v": ": All the webhooks have a rate limit of"
        },
        {
          "t": "c",
          "v": "1000"
        },
        {
          "t": "t",
          "v": "requests per minute, unless otherwise stated"
        }
      ],
      [
        {
          "t": "b",
          "v": "Request Size Limit"
        },
        {
          "t": "t",
          "v": ": All the webhooks have a request size limit of"
        },
        {
          "t": "c",
          "v": "1 MB"
        },
        {
          "t": "t",
          "v": ", unless otherwise stated"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "3. View Synced Cohorts",
    "id": "3-view-synced-cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "After setting up the integration:"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Navigate to the"
      },
      {
        "t": "b",
        "v": "Users"
      },
      {
        "t": "t",
        "v": "section in the sidebar of your EmbedCraft dashboard"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You will see the newly created"
      },
      {
        "t": "b",
        "v": "Cohorts"
      },
      {
        "t": "t",
        "v": "imported from your analytics platform"
      }
    ]
  },
  {
    "type": "image",
    "src": "./Cohorts Sync _ Nudge_files/view-cohorts.png",
    "alt": "View Cohorts in EmbedCraft"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [],
      []
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Ensure each cohort has a unique name, as visible in the EmbedCraft cohorts table - EmbedCraft groups cohorts by name only -\nTest your webhook configuration with a small cohort first"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Need help? Contact"
      },
      {
        "t": "t",
        "v": "support@embedcraft.com"
      }
    ]
  }
] as Block[];

export default function IntegrationsCohortsSyncPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
