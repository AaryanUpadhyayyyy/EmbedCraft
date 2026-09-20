// AUTO-GENERATED page — content for /product/Campaigns/stories
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Campaigns/stories";
const TITLE = "Stories";
const DESCRIPTION = "Embed Instagram-style story campaigns directly into your app.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Stories",
    "id": "stories"
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
        "v": "Stories campaigns allow you to embed Instagram-like stories directly within your application. You can configure multiple stories, each with a customizable set of slides. Design unique thumbnails and enrich each slide with interactive components such as swipe actions, countdowns, carousels, and more—giving you a powerful format to drive engagement and storytelling."
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
        "v": "Before creating a Stories campaign, you must complete the"
      },
      {
        "t": "b",
        "v": "Stories SDK integration"
      },
      {
        "t": "t",
        "v": "in your app. This involves embedding the stories component (e.g.,"
      },
      {
        "t": "c",
        "v": "NudgeStoryTray"
      },
      {
        "t": "t",
        "v": "on Android,"
      },
      {
        "t": "c",
        "v": "StoriesComponentView"
      },
      {
        "t": "t",
        "v": "on iOS,"
      },
      {
        "t": "c",
        "v": "NudgeStories"
      },
      {
        "t": "t",
        "v": "on Flutter,"
      },
      {
        "t": "c",
        "v": "NudgeStoriesWidget"
      },
      {
        "t": "t",
        "v": "on React Native, or the"
      },
      {
        "t": "c",
        "v": "nudge_stories"
      },
      {
        "t": "t",
        "v": "div on Web) into your app's UI."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "During integration, you assign a"
      },
      {
        "t": "b",
        "v": "Widget ID"
      },
      {
        "t": "t",
        "v": "to the stories embed. This Widget ID is required when creating a Stories campaign — it tells EmbedCraft which embed in your app should display the stories from this campaign."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "If you haven't completed the stories integration yet, follow the"
      },
      {
        "t": "t",
        "v": "Stories Integration Guide"
      },
      {
        "t": "t",
        "v": "first."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How to Create a Stories Campaign",
    "id": "how-to-create-a-stories-campaign"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Follow these steps to set up a Stories campaign:"
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
    "text": "4. Stories",
    "id": "4-stories"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Create and customize your stories using the"
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
          "v": "Add one or more stories to your campaign."
        }
      ],
      [
        {
          "t": "b",
          "v": "Widget IDs"
        },
        {
          "t": "t",
          "v": ": Enter the Widget ID(s) that correspond to the stories embed in your app. This is the same ID you assigned during the"
        },
        {
          "t": "t",
          "v": "stories SDK integration"
        },
        {
          "t": "t",
          "v": "(e.g., the"
        },
        {
          "t": "c",
          "v": "tag"
        },
        {
          "t": "t",
          "v": "on Android,"
        },
        {
          "t": "c",
          "v": "id"
        },
        {
          "t": "t",
          "v": "on iOS/Flutter, or"
        },
        {
          "t": "c",
          "v": "label"
        },
        {
          "t": "t",
          "v": "on React Native). The Widget ID links this campaign to the correct embed location in your app. You can add multiple Widget IDs if the same stories should appear in different locations."
        }
      ],
      [
        {
          "t": "t",
          "v": "For each story, add multiple slides."
        }
      ],
      [
        {
          "t": "t",
          "v": "Customize slide content using the visual builder—add components like swipe-up CTAs, countdowns, carousels, and more."
        }
      ],
      [
        {
          "t": "t",
          "v": "Design custom story thumbnails for a polished in-app presentation."
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

export default function ProductCampaignsStoriesPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
