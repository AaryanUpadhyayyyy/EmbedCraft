// AUTO-GENERATED page — content for /product/Campaigns/in-app-nudges
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Campaigns/in-app-nudges";
const TITLE = "In-app nudges";
const DESCRIPTION = "Guide users with tooltips, spotlights, and coachmarks to drive product adoption.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "In-app Nudges",
    "id": "in-app-nudges"
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
        "v": "In-app Nudges campaigns allow you to overlay lightweight guidance elements—like tooltips, spotlights, and coachmarks on top of your application. These nudges help draw attention to specific UI components and are particularly effective for onboarding new users, highlighting new features, and improving overall product adoption."
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
          "v": "Mobile"
        }
      ],
      [
        {
          "t": "t",
          "v": "Web"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "In-app Nudges require SDK integration to be completed by your development team before they can be displayed in your app. Your team must:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "b",
          "v": "Track widgets"
        },
        {
          "t": "t",
          "v": "- Add tags to the UI elements where nudges will appear"
        }
      ],
      [
        {
          "t": "b",
          "v": "Send widget data"
        },
        {
          "t": "t",
          "v": "- Configure the SDK to send tagged widget information to EmbedCraft"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Refer to the Tracking Widgets documentation for your platform:"
      },
      {
        "t": "t",
        "v": "Android"
      },
      {
        "t": "t",
        "v": "·"
      },
      {
        "t": "t",
        "v": "iOS"
      },
      {
        "t": "t",
        "v": "·"
      },
      {
        "t": "t",
        "v": "Flutter"
      },
      {
        "t": "t",
        "v": "·"
      },
      {
        "t": "t",
        "v": "React Native"
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "How to Create an In-app Nudges Campaign",
    "id": "how-to-create-an-in-app-nudges-campaign"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 1: Create a New Campaign"
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
          "v": "Navigate to the"
        },
        {
          "t": "b",
          "v": "Campaigns"
        },
        {
          "t": "t",
          "v": "page"
        }
      ],
      [
        {
          "t": "t",
          "v": "Click"
        },
        {
          "t": "c",
          "v": "Create Campaign"
        }
      ],
      [
        {
          "t": "t",
          "v": "Select"
        },
        {
          "t": "b",
          "v": "In-app nudges"
        },
        {
          "t": "t",
          "v": "as the experience type"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 2: Targeting"
      }
    ]
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
          "v": ": Choose Android or iOS"
        }
      ],
      [
        {
          "t": "b",
          "v": "User filters"
        },
        {
          "t": "t",
          "v": ": Target users based on properties or saved cohorts"
        }
      ],
      [
        {
          "t": "b",
          "v": "Trigger condition"
        },
        {
          "t": "t",
          "v": ": Specify the event(s) that activate the campaign (e.g.,"
        },
        {
          "t": "c",
          "v": "home_page_open"
        },
        {
          "t": "t",
          "v": ")"
        }
      ],
      [
        {
          "t": "b",
          "v": "Recurrence"
        },
        {
          "t": "t",
          "v": ": Set how often users see this campaign (once, always, or custom frequency)"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 3: Goals & Traffic Allocation"
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
          "v": "Goals"
        },
        {
          "t": "t",
          "v": ": Select primary goal events (e.g.,"
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
          "v": ")"
        }
      ],
      [
        {
          "t": "b",
          "v": "Traffic allocation"
        },
        {
          "t": "t",
          "v": ": Define what percentage of your target audience receives this campaign"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 4: Design Nudges"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Design and configure your nudges using the"
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
          "t": "b",
          "v": "Element-based"
        },
        {
          "t": "t",
          "v": ": Target elements imported when adding your app pages to EmbedCraft"
        }
      ],
      [
        {
          "t": "b",
          "v": "Position-based"
        },
        {
          "t": "t",
          "v": ": Use fixed positioning for static components or hardcoded layouts"
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
          "v": "Select the target page"
        },
        {
          "t": "t",
          "v": ": Choose the screen where the nudge will appear"
        }
      ],
      [
        {
          "t": "b",
          "v": "Choose the targeting method"
        },
        {
          "t": "t",
          "v": ":"
        }
      ],
      [
        {
          "t": "b",
          "v": "Select EmbedCraft Type"
        },
        {
          "t": "t",
          "v": ": Choose from tooltips, spotlights, or coachmarks"
        }
      ],
      [
        {
          "t": "b",
          "v": "Customize the Design"
        },
        {
          "t": "t",
          "v": ": Modify styles, positioning, and content"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 5: Launch"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
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
        "v": "to go live immediately, or schedule for later."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To create In-app Nudges for web applications, ensure the following are set up:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "b",
          "v": "Install the Web SDK"
        },
        {
          "t": "t",
          "v": "- Integrate the EmbedCraft Web SDK into your application"
        }
      ],
      [
        {
          "t": "b",
          "v": "Install the Chrome Extension"
        },
        {
          "t": "t",
          "v": "- Required for the visual builder to select elements on your web pages"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Make sure the Chrome extension is enabled and you're logged into the EmbedCraft dashboard before proceeding."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "How to Create an In-app Nudges Campaign",
    "id": "how-to-create-an-in-app-nudges-campaign"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 1: Create a New Campaign"
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
          "v": "Navigate to the"
        },
        {
          "t": "b",
          "v": "Campaigns"
        },
        {
          "t": "t",
          "v": "page"
        }
      ],
      [
        {
          "t": "t",
          "v": "Click"
        },
        {
          "t": "c",
          "v": "Create Campaign"
        }
      ],
      [
        {
          "t": "t",
          "v": "Select"
        },
        {
          "t": "b",
          "v": "In-app nudges"
        },
        {
          "t": "t",
          "v": "as the experience type"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 2: Targeting"
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
          "v": ": Select"
        },
        {
          "t": "b",
          "v": "Web"
        }
      ],
      [
        {
          "t": "b",
          "v": "Enter your website URL"
        },
        {
          "t": "t",
          "v": "where the nudges will appear"
        }
      ],
      [
        {
          "t": "b",
          "v": "User filters"
        },
        {
          "t": "t",
          "v": ": Target users based on properties or saved cohorts"
        }
      ],
      [
        {
          "t": "b",
          "v": "Trigger condition"
        },
        {
          "t": "t",
          "v": ": Specify the event(s) that activate the campaign"
        }
      ],
      [
        {
          "t": "b",
          "v": "Recurrence"
        },
        {
          "t": "t",
          "v": ": Set how often users see this campaign"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 3: Goals & Traffic Allocation"
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
          "v": "Goals"
        },
        {
          "t": "t",
          "v": ": Select primary goal events (e.g.,"
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
          "v": ")"
        }
      ],
      [
        {
          "t": "b",
          "v": "Traffic allocation"
        },
        {
          "t": "t",
          "v": ": Define what percentage of your target audience receives this campaign"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 4: Design Nudges"
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
          "v": "Click"
        },
        {
          "t": "c",
          "v": "Create EmbedCraft"
        },
        {
          "t": "t",
          "v": "— your website will open in a new tab"
        }
      ],
      [
        {
          "t": "b",
          "v": "Click the Chrome extension icon"
        },
        {
          "t": "t",
          "v": "to activate the visual editor"
        }
      ],
      [
        {
          "t": "t",
          "v": "Select elements directly on your page and design your nudges"
        }
      ],
      [
        {
          "t": "t",
          "v": "Choose from tooltips, spotlights, or coachmarks"
        }
      ],
      [
        {
          "t": "t",
          "v": "Customize styles, positioning, and content"
        }
      ],
      [
        {
          "t": "t",
          "v": "Click"
        },
        {
          "t": "b",
          "v": "Save"
        },
        {
          "t": "t",
          "v": "in the extension — you'll be redirected back to the dashboard"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Step 5: Launch"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
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
        "v": "to go live immediately, or schedule for later."
      }
    ]
  }
] as Block[];

export default function ProductCampaignsInAppNudgesPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
