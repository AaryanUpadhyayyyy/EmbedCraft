// AUTO-GENERATED page — content for /getting-started/Roles-and-permissions
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/getting-started/Roles-and-permissions";
const TITLE = "User Access Roles and Permissions";
const DESCRIPTION = "This document outlines the required access level (role) for every major action within the system&#39;s core modules, with terminology updated to use &quot;view&quot; for retrieval actions and &quot;Campaigns&quot; for tasks/journeys.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "User Access Roles and Permissions",
    "id": "user-access-roles-and-permissions"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This document outlines the required access level (role) for every major action within the system's core modules, with terminology updated to use \"view\" for retrieval actions and \"Campaigns\" for tasks/journeys."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "I. Access Level Definitions",
    "id": "i-access-level-definitions"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Access Level"
        }
      ],
      [
        {
          "t": "t",
          "v": "Role Summary"
        }
      ],
      [
        {
          "t": "t",
          "v": "Permissions Scope"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "b",
            "v": "Viewer"
          }
        ],
        [
          {
            "t": "t",
            "v": "Read-only access to data and settings."
          }
        ],
        [
          {
            "t": "t",
            "v": "Can retrieve existing data (e.g., campaigns, users, analytics)."
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Editor"
          }
        ],
        [
          {
            "t": "t",
            "v": "Write access for operational content."
          }
        ],
        [
          {
            "t": "t",
            "v": "Can create, modify, and delete operational content (e.g., campaigns, rewards, events)."
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Admin"
          }
        ],
        [
          {
            "t": "t",
            "v": "Full control over workspace settings and management."
          }
        ],
        [
          {
            "t": "t",
            "v": "Can manage users, client settings, API keys, and sensitive configurations."
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Backend Apikey"
          }
        ],
        [
          {
            "t": "t",
            "v": "Server-to-server integration access."
          }
        ],
        [
          {
            "t": "t",
            "v": "Used exclusively for system-level actions, such as direct API cohort creation or fetching sensitive survey data."
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Temporary Auth"
          }
        ],
        [
          {
            "t": "t",
            "v": "Short-term or specialized access."
          }
        ],
        [
          {
            "t": "t",
            "v": "Used for specific non-persistent actions, such as generating page screenshots."
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "II. Permissions by Module",
    "id": "ii-permissions-by-module"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "A. Campaigns Module (Tasks & Journeys)",
    "id": "a-campaigns-module-tasks-journeys"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Campaigns module manages user-facing campaigns and journeys."
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "API Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Required Access Level"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "t",
            "v": "Create Campaign"
          }
        ],
        [
          {
            "t": "c",
            "v": "createCampaign"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Single Campaign"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewCampaign"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View All Campaigns"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewAllCampaigns"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Campaign"
          }
        ],
        [
          {
            "t": "c",
            "v": "update Campaign"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Campaign Status"
          }
        ],
        [
          {
            "t": "c",
            "v": "update CampaignStatus"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Delete Campaign"
          }
        ],
        [
          {
            "t": "c",
            "v": "delete Campaign"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Upload Quiz Result"
          }
        ],
        [
          {
            "t": "c",
            "v": "uploadQuizResult"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Journey"
          }
        ],
        [
          {
            "t": "c",
            "v": "createJrny"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Journey"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewJrny"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View All Journeys"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewAllJrnys"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Journey"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateJrny"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Journey Status"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateJrnyStatus"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Delete Journey"
          }
        ],
        [
          {
            "t": "c",
            "v": "deleteJrny"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "B. Rewards Module",
    "id": "b-rewards-module"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Rewards module manages rewards, coupons, and templates."
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "API Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Required Access Level"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "t",
            "v": "View Rewards (Generic)"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewRewards"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Rewards (Generic, duplicate)"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewRewards"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Coupons Upload URL"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewCouponsUploadUrl"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Reward"
          }
        ],
        [
          {
            "t": "c",
            "v": "createReward"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Reward"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateReward"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Reward Template"
          }
        ],
        [
          {
            "t": "c",
            "v": "createRwdTemplate"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View All Reward Templates"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewAllRwdTemplates"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Single Reward Template"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewRwdTemplate"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Reward Template"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateRwdTemplate"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "C. Users Module (Data and Cohorts)",
    "id": "c-users-module-data-and-cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Users module manages user data, timelines, and cohort management."
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "API Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Required Access Level"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "t",
            "v": "View Single User"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewUser"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Multiple Users"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewUsers"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View User Timeline"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewUser Timeline"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View User Wallet History"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewUserWalletHistory"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Cohort (Web UI)"
          }
        ],
        [
          {
            "t": "c",
            "v": "createCohort"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level*"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Cohort Upload URL"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewCohortUploadUrl"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View All Cohorts"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewCohorts"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Single Cohort"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewCohort"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Cohort"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateCohort"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Delete Cohort"
          }
        ],
        [
          {
            "t": "c",
            "v": "deleteCohort"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Cohort (External API)"
          }
        ],
        [
          {
            "t": "c",
            "v": "createCohortApiExternal"
          }
        ],
        [
          {
            "t": "t",
            "v": "Backend Apikey"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Cohorts (External API)"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewCohortsApiExternal"
          }
        ],
        [
          {
            "t": "t",
            "v": "Backend Apikey"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Cohort (External API)"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateCohortApiExternal"
          }
        ],
        [
          {
            "t": "t",
            "v": "Backend Apikey"
          }
        ]
      ],
      [
        [
          {
            "t": "i",
            "v": "*Note: Source used \"Azimin level\", standardized to Admin level."
          }
        ],
        [],
        []
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "D. Client Module (Settings and Management)",
    "id": "d-client-module-settings-and-management"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Client module controls workspace settings, team management, and API key configuration."
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "API Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Required Access Level"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "t",
            "v": "Update Client Details"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateClient"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level*"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Client Details"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewClient"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update General Settings"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateSettings"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level*"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Referral Settings"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateReferralSettings"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Referral Settings"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewReferralSettings"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Generate Private Key"
          }
        ],
        [
          {
            "t": "c",
            "v": "generate PrivateKey"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level*"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Private Keys"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewPrivateKeys"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Delete Private Key"
          }
        ],
        [
          {
            "t": "c",
            "v": "deletePrivateKey"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Invite Member"
          }
        ],
        [
          {
            "t": "c",
            "v": "invite Member"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Remove Member"
          }
        ],
        [
          {
            "t": "c",
            "v": "removeMember"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Edit Member Role"
          }
        ],
        [
          {
            "t": "c",
            "v": "editMemberRole"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Members"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewMembers"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Member Status"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateMemberStatus"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Events"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewEvents"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Webhook Settings"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateWebhookSettings"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level*"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Webhook Settings"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewWebhookSettings"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Webhook Settings"
          }
        ],
        [
          {
            "t": "c",
            "v": "createWebhookSettings"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level*"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Goal Event"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateGoalEvent"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Black Listed Event"
          }
        ],
        [
          {
            "t": "c",
            "v": "updateBlackListedEvent"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Brand Guidelines"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewBrandGuidelines"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Add Brand Font"
          }
        ],
        [
          {
            "t": "c",
            "v": "addBrandFont"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level*"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Remove Font"
          }
        ],
        [
          {
            "t": "c",
            "v": "removeFont"
          }
        ],
        [
          {
            "t": "t",
            "v": "Admin level"
          }
        ]
      ],
      [
        [
          {
            "t": "i",
            "v": "*Note: Source used various typo levels (e.g., \"Admih level,\" \"Adminlave,\" \"Admith Evel,\" \"Adlimin level\"), standardized to Admin level."
          }
        ],
        [],
        []
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "E. Pages Module",
    "id": "e-pages-module"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Pages module manages content pages and related actions."
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "API Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Required Access Level"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "t",
            "v": "View Pages (Generic)"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewPages"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Pages (Duplicate)"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewPages"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Page"
          }
        ],
        [
          {
            "t": "c",
            "v": "updatePage"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View QR Code"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewQrCode"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Page"
          }
        ],
        [
          {
            "t": "c",
            "v": "createPage"
          }
        ],
        [
          {
            "t": "t",
            "v": "temporary auth"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Page Screenshot URL"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewPageScreenshotUrl"
          }
        ],
        [
          {
            "t": "t",
            "v": "temporary auth"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "F. Assets and Templates Modules",
    "id": "f-assets-and-templates-modules"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Module"
        }
      ],
      [
        {
          "t": "t",
          "v": "API Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Required Access Level"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "t",
            "v": "View Assets"
          }
        ],
        [
          {
            "t": "c",
            "v": "assets"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewAssets"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Asset"
          }
        ],
        [
          {
            "t": "c",
            "v": "assets"
          }
        ],
        [
          {
            "t": "c",
            "v": "createAsset"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Delete Asset"
          }
        ],
        [
          {
            "t": "c",
            "v": "assets"
          }
        ],
        [
          {
            "t": "c",
            "v": "deleteAsset"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Create Template"
          }
        ],
        [
          {
            "t": "c",
            "v": "templates"
          }
        ],
        [
          {
            "t": "c",
            "v": "create Template"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Update Template"
          }
        ],
        [
          {
            "t": "c",
            "v": "templates"
          }
        ],
        [
          {
            "t": "c",
            "v": "update Template"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Delete Template"
          }
        ],
        [
          {
            "t": "c",
            "v": "templates"
          }
        ],
        [
          {
            "t": "c",
            "v": "delete Template"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Templates (Viewer)"
          }
        ],
        [
          {
            "t": "c",
            "v": "templates"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewTemplates"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Templates (Editor)"
          }
        ],
        [
          {
            "t": "c",
            "v": "templates"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewTemplates"
          }
        ],
        [
          {
            "t": "t",
            "v": "Editor level"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "G. Analytics Module",
    "id": "g-analytics-module"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Analytics module provides reporting and user activity data."
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "API Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Required Access Level"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "t",
            "v": "View Report Analytics"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewReportAnalytics"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Report Users"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewReportUsers"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "Download Report Users"
          }
        ],
        [
          {
            "t": "c",
            "v": "downloadReportUsers"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Goal Conversions"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewGoalConversions"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Survey Responses"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewSurvey Responses"
          }
        ],
        [
          {
            "t": "t",
            "v": "Backend Apikey"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Journey Analytics"
          }
        ],
        [
          {
            "t": "c",
            "v": "view Journey Analytics"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Analytics"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewAnalytics"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "View Analytics Graph"
          }
        ],
        [
          {
            "t": "c",
            "v": "viewAnalyticsGraph"
          }
        ],
        [
          {
            "t": "t",
            "v": "Viewer Level"
          }
        ]
      ]
    ]
  }
] as Block[];

export default function GettingStartedRolesAndPermissionsPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
