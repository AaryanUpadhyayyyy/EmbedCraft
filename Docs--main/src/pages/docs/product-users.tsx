// AUTO-GENERATED page — content for /product/Users
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Users";
const TITLE = "Users";
const DESCRIPTION = "Understanding Users in EmbedCraft";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Users",
    "id": "users"
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
        "t": "t",
        "v": "In EmbedCraft, a"
      },
      {
        "t": "b",
        "v": "User"
      },
      {
        "t": "t",
        "v": "represents an end user of your application—someone who interacts with the experiences powered by the EmbedCraft SDK. EmbedCraft identifies, tracks, and personalizes experiences for each user to optimize outcomes like engagement, conversion, and retention."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How Users Work",
    "id": "how-users-work"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "User Identification",
    "id": "user-identification"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Each user is identified using a unique"
        },
        {
          "t": "c",
          "v": "externalId"
        },
        {
          "t": "t",
          "v": ", typically mapped to your app's user ID (database ID, email, UUID, etc.)"
        }
      ],
      [
        {
          "t": "t",
          "v": "This identifier links all user interactions and behaviors to a single profile"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "User Properties",
    "id": "user-properties"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Send custom user properties to EmbedCraft for personalization (e.g.,"
        },
        {
          "t": "c",
          "v": "tier"
        },
        {
          "t": "t",
          "v": ","
        },
        {
          "t": "c",
          "v": "subscription_status"
        },
        {
          "t": "t",
          "v": ","
        },
        {
          "t": "c",
          "v": "location"
        },
        {
          "t": "t",
          "v": ")"
        }
      ],
      [
        {
          "t": "t",
          "v": "Properties enable you to create targeted segments and deliver personalized experiences"
        }
      ],
      [
        {
          "t": "t",
          "v": "Update properties as user attributes change over time"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Data Collection",
    "id": "data-collection"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "EmbedCraft automatically collects user behavior data (events, page views, interactions)"
        }
      ],
      [
        {
          "t": "t",
          "v": "All data is stored under the user's profile for personalization and analytics"
        }
      ],
      [
        {
          "t": "t",
          "v": "Historical data helps predict user preferences and optimize experiences"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Integration Methods",
    "id": "integration-methods"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You can send user data to EmbedCraft through:"
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
          "v": "Frontend SDK"
        },
        {
          "t": "t",
          "v": ": Identify users directly from your mobile or web app"
        }
      ],
      [
        {
          "t": "b",
          "v": "Backend APIs"
        },
        {
          "t": "t",
          "v": ": Send user data from your server for better security and control"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Segmentation",
    "id": "segmentation"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Group users based on properties (e.g.,"
        },
        {
          "t": "c",
          "v": "tier == \"premium\""
        },
        {
          "t": "t",
          "v": ")"
        }
      ],
      [
        {
          "t": "t",
          "v": "Create cohorts based on behaviors (e.g., users who completed checkout)"
        }
      ],
      [
        {
          "t": "t",
          "v": "Target specific segments with personalized campaigns"
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
    "text": "Finding Your Users",
    "id": "finding-your-users"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "User Search",
    "id": "user-search"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "In the EmbedCraft Dashboard, you can find users by searching via:"
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
          "v": "Name"
        },
        {
          "t": "t",
          "v": ": User's display name"
        }
      ],
      [
        {
          "t": "b",
          "v": "External ID"
        },
        {
          "t": "t",
          "v": ": Your unique user identifier"
        }
      ],
      [
        {
          "t": "b",
          "v": "UID"
        },
        {
          "t": "t",
          "v": ": EmbedCraft's internal user ID"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "All users you send to EmbedCraft are visible in the"
      },
      {
        "t": "b",
        "v": "Users"
      },
      {
        "t": "t",
        "v": "section in the dashboard sidebar."
      }
    ]
  },
  {
    "type": "image",
    "src": "/assets/user.png",
    "alt": "Users Table in Dashboard"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "User Profile",
    "id": "user-profile"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Click on any user to view their complete profile, including:"
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
          "v": "User Properties"
        },
        {
          "t": "t",
          "v": ": All custom attributes you've sent"
        }
      ],
      [
        {
          "t": "b",
          "v": "Activity Timeline"
        },
        {
          "t": "t",
          "v": ": Chronological history of events and interactions"
        }
      ],
      [
        {
          "t": "b",
          "v": "Campaign History"
        },
        {
          "t": "t",
          "v": ": Which campaigns they've seen and engaged with"
        }
      ],
      [
        {
          "t": "b",
          "v": "Rewards Earned"
        },
        {
          "t": "t",
          "v": ": Coins, coupons, and other rewards"
        }
      ]
    ]
  },
  {
    "type": "image",
    "src": "/assets/userprofile.png",
    "alt": "User Activity Timeline"
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
        "v": "Use the same"
      },
      {
        "t": "c",
        "v": "externalId"
      },
      {
        "t": "t",
        "v": "across all platforms (iOS, Android, Web) to maintain a unified user profile."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Only send necessary user data. Avoid sending sensitive PII unless required for your use case."
      }
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Further Reading",
    "id": "further-reading"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "For technical implementation details:"
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
          "v": "SDK Documentation"
        },
        {
          "t": "t",
          "v": ": Learn how to integrate and use the EmbedCraft SDK in your application"
        }
      ],
      [
        {
          "t": "t",
          "v": "REST API Documentation"
        },
        {
          "t": "t",
          "v": ": Explore how to implement user tracking and management using EmbedCraft's REST APIs"
        }
      ]
    ]
  }
] as Block[];

export default function ProductUsersPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
