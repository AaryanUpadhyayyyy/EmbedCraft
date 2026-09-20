// AUTO-GENERATED page — content for /getting-started/finding-your-api-keys
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/getting-started/finding-your-api-keys";
const TITLE = "Finding and Managing Your API Keys";
const DESCRIPTION = "EmbedCraft utilizes two distinct types of API keys\u2014a Public Client Key and Private Secret Keys\u2014to securely enable front-end tracking and back-end integrations. Understanding their intended use is critical for security and functionality.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Finding and Managing Your API Keys",
    "id": "finding-and-managing-your-api-keys"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft utilizes two distinct types of API keys—a"
      },
      {
        "t": "b",
        "v": "Public Client Key"
      },
      {
        "t": "t",
        "v": "and"
      },
      {
        "t": "b",
        "v": "Private Secret Keys"
      },
      {
        "t": "t",
        "v": "—to securely enable front-end tracking and back-end integrations. Understanding their intended use is critical for security and functionality."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "1. Public Client Key",
    "id": "1-public-client-key"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Public Client Key is used for"
      },
      {
        "t": "b",
        "v": "front-end operations"
      },
      {
        "t": "t",
        "v": ", primarily for initializing the EmbedCraft SDK and tracking user events directly from your client application (browser, mobile app). This key is designed to be publicly accessible."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Accessing Your Public Client Key:",
    "id": "accessing-your-public-client-key"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Log in to the EmbedCraft Dashboard."
        }
      ],
      [
        {
          "t": "t",
          "v": "Navigate to the"
        },
        {
          "t": "b",
          "v": "Settings"
        },
        {
          "t": "t",
          "v": "section via the sidebar."
        }
      ],
      [
        {
          "t": "t",
          "v": "In the default"
        },
        {
          "t": "b",
          "v": "General"
        },
        {
          "t": "t",
          "v": "tab, locate and copy the"
        },
        {
          "t": "b",
          "v": "Public Client Key"
        },
        {
          "t": "t",
          "v": "."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "While this key is designed for client-side use, it is still sensitive."
      },
      {
        "t": "b",
        "v": "Do not embed this key directly in publicly accessible source code repositories (e.g., GitHub)."
      },
      {
        "t": "t",
        "v": "Store it securely, such as using environment variables during your build process."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "2. Private Secret Keys",
    "id": "2-private-secret-keys"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Private Secret Keys (often referred to as 'Secret Keys') are high-permission keys intended exclusively for"
      },
      {
        "t": "b",
        "v": "back-end integrations, server-to-server API calls, and Webhook verification."
      },
      {
        "t": "t",
        "v": "These keys must be kept absolutely secret."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Generating and Securing a Private Secret Key:",
    "id": "generating-and-securing-a-private-secret-key"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Since Secret Keys are high-access, they must be generated with specific intent and handled securely."
      }
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Log in to the EmbedCraft Dashboard and go to the"
        },
        {
          "t": "b",
          "v": "Settings"
        },
        {
          "t": "t",
          "v": "section."
        }
      ],
      [
        {
          "t": "t",
          "v": "Click on the"
        },
        {
          "t": "b",
          "v": "Secret Keys"
        },
        {
          "t": "t",
          "v": "tab."
        }
      ],
      [
        {
          "t": "t",
          "v": "Click"
        },
        {
          "t": "b",
          "v": "Add New Secret Key"
        },
        {
          "t": "t",
          "v": "to open the creation modal."
        }
      ],
      [
        {
          "t": "b",
          "v": "Name the Key:"
        },
        {
          "t": "t",
          "v": "Provide a descriptive name (e.g.,"
        },
        {
          "t": "c",
          "v": "Webhook_Integration_Staging"
        },
        {
          "t": "t",
          "v": "or"
        },
        {
          "t": "c",
          "v": "CRM_Sync_Production"
        },
        {
          "t": "t",
          "v": ")."
        }
      ],
      [
        {
          "t": "b",
          "v": "Set Permissions (Scope):"
        },
        {
          "t": "t",
          "v": "Select only the minimum necessary permissions required for the integration to function."
        }
      ],
      [
        {
          "t": "t",
          "v": "Click"
        },
        {
          "t": "b",
          "v": "Generate Key"
        },
        {
          "t": "t",
          "v": "."
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
          "v": "One-Time Display:"
        },
        {
          "t": "t",
          "v": "Your Private Secret Key is displayed"
        },
        {
          "t": "b",
          "v": "only once"
        },
        {
          "t": "t",
          "v": "upon generation. You"
        },
        {
          "t": "i",
          "v": "must"
        },
        {
          "t": "t",
          "v": "copy and save it immediately in a secure vault, such as AWS Secrets Manager or HashiCorp Vault. If you lose it, you must revoke and regenerate a new one."
        }
      ],
      [
        {
          "t": "b",
          "v": "Access Scope:"
        },
        {
          "t": "t",
          "v": "Handle Private API keys with extreme care. They grant direct, high-level access to your EmbedCraft data and backend APIs according to the permissions you set."
        }
      ],
      [
        {
          "t": "b",
          "v": "Deletion Delay:"
        },
        {
          "t": "t",
          "v": "Deletion of a Private Secret Key can take up to"
        },
        {
          "t": "b",
          "v": "60 seconds"
        },
        {
          "t": "t",
          "v": "to fully propagate and cease function across all systems."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Summary of Key Usage",
    "id": "summary-of-key-usage"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Key Type"
        }
      ],
      [
        {
          "t": "t",
          "v": "Use Case"
        }
      ],
      [
        {
          "t": "t",
          "v": "Integration Location"
        }
      ],
      [
        {
          "t": "t",
          "v": "Security Required"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "b",
            "v": "Public Client Key"
          }
        ],
        [
          {
            "t": "t",
            "v": "SDK Initialization, User/Event Tracking"
          }
        ],
        [
          {
            "t": "t",
            "v": "Client-side (Front-end)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Moderate (Environment Variables)"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Private Secret Key"
          }
        ],
        [
          {
            "t": "t",
            "v": "Server-to-server APIs, Webhooks"
          }
        ],
        [
          {
            "t": "t",
            "v": "Server-side (Back-end)"
          }
        ],
        [
          {
            "t": "t",
            "v": "High (Dedicated Secret Manager)"
          }
        ]
      ]
    ]
  }
] as Block[];

export default function GettingStartedFindingYourApiKeysPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
