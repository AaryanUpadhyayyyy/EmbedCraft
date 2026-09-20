// AUTO-GENERATED page — content for /product/Cohorts
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Cohorts";
const TITLE = "Cohorts";
const DESCRIPTION = "Group users based on shared behavior or properties to target experiences more effectively";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Cohorts",
    "id": "cohorts"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Overview",
    "id": "overview"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Cohorts"
      },
      {
        "t": "t",
        "v": "in EmbedCraft let you group users based on shared behaviors, properties, or engagement history—so you can target the right users with the right experiences at the right time."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Not every user should see the same message. Cohorts help you segment your audience dynamically, enabling you to personalize campaigns for high-value users, inactive users, new users, and more."
      }
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Types of Cohorts",
    "id": "types-of-cohorts"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Static Cohorts",
    "id": "static-cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Upload a CSV of user IDs to instantly create a fixed cohort. Perfect for targeting users from CRM lists or past campaign exports."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Dynamic Cohorts",
    "id": "dynamic-cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Define rules based on user behavior and properties. Cohorts auto-update in real time as users meet your criteria."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "3rd Party Cohorts",
    "id": "3rd-party-cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sync cohorts from your CDP, CRM, or data warehouse. Use existing segmentation logic without duplicating effort."
      }
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Use Cases",
    "id": "use-cases"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "You can use cohorts to:"
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
          "v": "Target Specific Users"
        },
        {
          "t": "t",
          "v": ": Show campaigns only to users who match certain criteria"
        }
      ],
      [
        {
          "t": "b",
          "v": "Run Experiments"
        },
        {
          "t": "t",
          "v": ": Test different experiences on high-intent segments"
        }
      ],
      [
        {
          "t": "b",
          "v": "Trigger Flows"
        },
        {
          "t": "t",
          "v": ": Automatically start user journeys based on behavior"
        }
      ],
      [
        {
          "t": "b",
          "v": "Personalize Content"
        },
        {
          "t": "t",
          "v": ": Deliver relevant messages to different user groups"
        }
      ],
      [
        {
          "t": "b",
          "v": "Measure Performance"
        },
        {
          "t": "t",
          "v": ": Compare conversion rates across different segments"
        }
      ]
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How Cohorts Work",
    "id": "how-cohorts-work"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Static Cohorts",
    "id": "static-cohorts"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Export a list of user IDs from your CRM or database"
        }
      ],
      [
        {
          "t": "t",
          "v": "Upload the CSV file to EmbedCraft"
        }
      ],
      [
        {
          "t": "t",
          "v": "Target campaigns to this fixed group of users"
        }
      ],
      [
        {
          "t": "t",
          "v": "Update the cohort by uploading a new CSV anytime"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Dynamic Cohorts",
    "id": "dynamic-cohorts"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Define rules using user properties and events"
        }
      ],
      [
        {
          "t": "t",
          "v": "Set conditions (e.g.,"
        },
        {
          "t": "c",
          "v": "tier == \"premium\""
        },
        {
          "t": "t",
          "v": "AND"
        },
        {
          "t": "c",
          "v": "last_purchase < 30 days ago"
        },
        {
          "t": "t",
          "v": ")"
        }
      ],
      [
        {
          "t": "t",
          "v": "Cohort membership updates automatically as users meet or leave criteria"
        }
      ],
      [
        {
          "t": "t",
          "v": "Use complex logic with AND/OR operators"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "3rd Party Cohorts",
    "id": "3rd-party-cohorts"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Connect your CDP, CRM, or data warehouse"
        }
      ],
      [
        {
          "t": "t",
          "v": "Map your existing segments to EmbedCraft cohorts"
        }
      ],
      [
        {
          "t": "t",
          "v": "Sync automatically to keep cohorts up-to-date"
        }
      ],
      [
        {
          "t": "t",
          "v": "Leverage your existing segmentation work"
        }
      ]
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Best Practices",
    "id": "best-practices"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Begin with basic cohorts (e.g., \"Active Users\", \"New Users\") and gradually add complexity as you learn what works."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Create specific cohorts for specific use cases rather than one large \"catch-all\" cohort. This makes targeting more precise."
      }
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Next Steps",
    "id": "next-steps"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Ready to create your first cohort? Choose the type that fits your needs:"
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
          "v": "Create Static Cohort"
        },
        {
          "t": "t",
          "v": "- Upload a CSV list"
        }
      ],
      [
        {
          "t": "t",
          "v": "Set Up Dynamic Cohort"
        },
        {
          "t": "t",
          "v": "- Define behavioral rules"
        }
      ],
      [
        {
          "t": "t",
          "v": "Import from 3rd Party"
        },
        {
          "t": "t",
          "v": "- Sync existing segments"
        }
      ]
    ]
  }
] as Block[];

export default function ProductCohortsPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
