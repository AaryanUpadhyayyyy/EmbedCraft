// AUTO-GENERATED page — content for /product/Campaigns/referrals
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Campaigns/referrals";
const TITLE = "Referrals";
const DESCRIPTION = "Create multi-level referral campaigns to drive acquisition and engagement.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Referrals",
    "id": "referrals"
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
        "v": "Referral campaigns allow you to reward both referrers and referees for participating in your app's growth. Referees can earn rewards for completing key actions, while referrers stay incentivized as their friends continue engaging with your product."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Setting Up Referral Codes",
    "id": "setting-up-referral-codes"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Before creating a referral campaign, configure how referral codes are generated for your users."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Accessing Referral Settings",
    "id": "accessing-referral-settings"
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
          "v": "Settings → Referral Settings"
        }
      ],
      [
        {
          "t": "t",
          "v": "Click"
        },
        {
          "t": "b",
          "v": "Edit"
        },
        {
          "t": "t",
          "v": "to configure the referral code rules"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Referral Code Components",
    "id": "referral-code-components"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Build your referral code by combining one or more of these components:"
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Component"
        }
      ],
      [
        {
          "t": "t",
          "v": "Description"
        }
      ],
      [
        {
          "t": "t",
          "v": "Example"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "b",
            "v": "Constant"
          }
        ],
        [
          {
            "t": "t",
            "v": "A fixed string value"
          }
        ],
        [
          {
            "t": "c",
            "v": "NUDGE"
          },
          {
            "t": "t",
            "v": ","
          },
          {
            "t": "c",
            "v": "REF2024"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "User Property"
          }
        ],
        [
          {
            "t": "t",
            "v": "Dynamic value from user data (name, city code, etc.)"
          }
        ],
        [
          {
            "t": "c",
            "v": "JOHN"
          },
          {
            "t": "t",
            "v": ","
          },
          {
            "t": "c",
            "v": "NYC"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Random"
          }
        ],
        [
          {
            "t": "t",
            "v": "Auto-generated alphanumeric or numeric characters of specified length"
          }
        ],
        [
          {
            "t": "c",
            "v": "A7X9"
          },
          {
            "t": "t",
            "v": ","
          },
          {
            "t": "c",
            "v": "4821"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Phone"
          }
        ],
        [
          {
            "t": "t",
            "v": "User's phone number (ensure phone data is passed to EmbedCraft)"
          }
        ],
        [
          {
            "t": "c",
            "v": "9876543210"
          }
        ]
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Combine components to create unique, meaningful codes. For example:"
      },
      {
        "t": "c",
        "v": "NUDGE"
      },
      {
        "t": "t",
        "v": "(constant) +"
      },
      {
        "t": "c",
        "v": "JOHN"
      },
      {
        "t": "t",
        "v": "(user property) +"
      },
      {
        "t": "c",
        "v": "X7K2"
      },
      {
        "t": "t",
        "v": "(random) ="
      },
      {
        "t": "c",
        "v": "NUDGEJOHNX7K2"
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Additional Settings",
    "id": "additional-settings"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Max Referrals Per User"
        },
        {
          "t": "t",
          "v": ": Set the maximum number of users each referrer can invite."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Once configured, EmbedCraft automatically generates and assigns a unique referral code to each user based on your rules."
      }
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How to Create a Referrals Campaign",
    "id": "how-to-create-a-referrals-campaign"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Follow these steps to set up a Referrals campaign:"
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "1. Create a New Campaign",
    "id": "1-create-a-new-campaign"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Navigate to the"
        },
        {
          "t": "b",
          "v": "Campaigns"
        },
        {
          "t": "t",
          "v": "page."
        }
      ],
      [
        {
          "t": "t",
          "v": "Click the"
        },
        {
          "t": "c",
          "v": "Create Campaign"
        },
        {
          "t": "t",
          "v": "button."
        }
      ],
      [
        {
          "t": "t",
          "v": "In the experience type dialog, select"
        },
        {
          "t": "b",
          "v": "Referrals"
        },
        {
          "t": "t",
          "v": "."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "2. Targeting",
    "id": "2-targeting"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Define who should receive the campaign and when:"
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
          "v": "Platform"
        },
        {
          "t": "t",
          "v": ": Choose Android, iOS, or Web."
        }
      ],
      [
        {
          "t": "b",
          "v": "User filters"
        },
        {
          "t": "t",
          "v": ": Target users using filters based on user properties or saved cohorts."
        }
      ],
      [
        {
          "t": "b",
          "v": "Trigger condition"
        },
        {
          "t": "t",
          "v": ": Specify the event(s) that must occur to activate the campaign (e.g.,"
        },
        {
          "t": "c",
          "v": "home_page_open"
        },
        {
          "t": "t",
          "v": ")."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "3. Goals & Traffic Allocation",
    "id": "3-goals-traffic-allocation"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Goals"
        },
        {
          "t": "t",
          "v": ": Select the primary goal events for the campaign (e.g.,"
        },
        {
          "t": "c",
          "v": "add_to_cart"
        },
        {
          "t": "t",
          "v": ","
        },
        {
          "t": "c",
          "v": "transaction_success"
        },
        {
          "t": "t",
          "v": ")."
        }
      ],
      [
        {
          "t": "b",
          "v": "Traffic allocation"
        },
        {
          "t": "t",
          "v": ": Define what percentage of your target audience will receive this campaign."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "4. Tasks",
    "id": "4-tasks"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "For each task, configure the following:"
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
          "v": "Task Properties"
        },
        {
          "t": "t",
          "v": ": Add properties such as title, subtitle, task ID, task image, and any additional custom fields."
        }
      ],
      [
        {
          "t": "b",
          "v": "Task Logic"
        },
        {
          "t": "t",
          "v": ": Define the conditions required for task completion, and optionally apply user filters (similar to campaign targeting)."
        }
      ],
      [
        {
          "t": "b",
          "v": "Task Rewards"
        },
        {
          "t": "t",
          "v": ": Assign one or more rewards to each task and configure delivery methods. You can set separate rewards for referrers and referees."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "5. Designs",
    "id": "5-designs"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Customize the campaign interface using the"
      },
      {
        "t": "b",
        "v": "Visual Builder"
      },
      {
        "t": "t",
        "v": ":"
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
          "v": "Choose from multiple interface types: Full page, bottom sheet, modal, floater, or embed."
        }
      ],
      [
        {
          "t": "t",
          "v": "Learn how to use the Visual Builder →"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "6. Publish",
    "id": "6-publish"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Click the"
        },
        {
          "t": "c",
          "v": "Publish"
        },
        {
          "t": "t",
          "v": "button."
        }
      ],
      [
        {
          "t": "t",
          "v": "Choose whether to launch the campaign immediately or schedule it for later."
        }
      ],
      [
        {
          "t": "t",
          "v": "Click"
        },
        {
          "t": "c",
          "v": "Launch"
        },
        {
          "t": "t",
          "v": "to go live."
        }
      ]
    ]
  }
] as Block[];

export default function ProductCampaignsReferralsPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
