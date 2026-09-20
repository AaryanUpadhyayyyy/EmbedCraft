// AUTO-GENERATED page — content for /product/Campaigns/in-app-messages
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Campaigns/in-app-messages";
const TITLE = "In-app messages";
const DESCRIPTION = "Communicate with your users through modals, sheets, banners, and more.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "In-app Messages",
    "id": "in-app-messages"
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
        "v": "In-app Messages campaigns allow you to communicate directly with users inside your app using customizable UI formats like modals, bottom sheets, banners, floaters, and full pages. These campaigns are ideal for announcing updates, running promotions, onboarding users, or nudging key actions at the right moment."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How to Create an In-app messages Campaign",
    "id": "how-to-create-an-in-app-messages-campaign"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Follow these steps to set up an In-app messages campaign:"
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
          "v": "In-app messages"
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
      ],
      [
        {
          "t": "b",
          "v": "Recurrence"
        },
        {
          "t": "t",
          "v": ": Decide how many times a user can see this campaign. It can be set to once, always, or a custom frequency like 3 times every 72 hours."
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
    "text": "4. Designs",
    "id": "4-designs"
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
    "text": "5. Publish",
    "id": "5-publish"
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

export default function ProductCampaignsInAppMessagesPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
