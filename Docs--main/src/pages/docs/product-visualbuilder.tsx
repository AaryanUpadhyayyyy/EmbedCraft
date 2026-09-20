// AUTO-GENERATED page — content for /product/VisualBuilder
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/VisualBuilder";
const TITLE = "Visual Builder";
const DESCRIPTION = "Learn to use the visual builder in EmbedCraft.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Overview",
    "id": "overview"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft's Visual Builder lets you design rich, customizable user interfaces directly within your application—without writing code."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "It’s a powerful tool to create and personalize experiences across multiple interface types, using a combination of widgets, variables, actions, and templates."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Key Concepts",
    "id": "key-concepts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Here are the core building blocks of the Visual Builder:"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Interfaces"
      },
      {
        "t": "t",
        "v": "EmbedCraft supports five types of interfaces:"
      },
      {
        "t": "b",
        "v": "Modal"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "Bottom Sheet"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "Full Page"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "Floater"
      },
      {
        "t": "t",
        "v": ", and"
      },
      {
        "t": "b",
        "v": "Embed"
      },
      {
        "t": "t",
        "v": ". Think of an interface as"
      },
      {
        "t": "i",
        "v": "what"
      },
      {
        "t": "t",
        "v": "you want to display to the user."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Widgets"
      },
      {
        "t": "t",
        "v": "Interfaces are made up of widgets—such as"
      },
      {
        "t": "b",
        "v": "Text"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "Media"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "Buttons"
      },
      {
        "t": "t",
        "v": ", and more. These are the UI components you use to build your interface layout."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Variables"
      },
      {
        "t": "t",
        "v": "Widgets that include text can be personalized using variables. EmbedCraft provides different types of variables:"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "User Properties"
      },
      {
        "t": "t",
        "v": "(e.g., user name, location)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Task Properties"
      },
      {
        "t": "t",
        "v": "- Pull in data from tasks defined in Challenges, Streaks, or Referral campaigns (e.g., task title, reward amount)."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Referral Properties"
      },
      {
        "t": "t",
        "v": "- Include referral-specific values like each user’s unique referral code."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "API Data"
      },
      {
        "t": "t",
        "v": "(fetched from your backend)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Other dynamic values provided by EmbedCraft\nThese allow you to display personalized, user-specific content in real time."
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [],
      [],
      [],
      [],
      []
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Actions"
      },
      {
        "t": "t",
        "v": "Widgets can have actions associated with them—such as:"
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
          "v": "Navigating to an external URL or deep link"
        }
      ],
      [
        {
          "t": "t",
          "v": "Sending a callback to your backend"
        }
      ],
      [
        {
          "t": "t",
          "v": "Triggering another campaign or event"
        },
        {
          "t": "t",
          "v": "Some actions are campaign-type specific, but all actions help drive interactivity and flow."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Variants"
      },
      {
        "t": "t",
        "v": "Each interface can have multiple variants. For example, you might create five versions of a bottom sheet to test or target different segments."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Templates"
      },
      {
        "t": "t",
        "v": "EmbedCraft offers a library of ready-to-use interface templates. You can also export any of your own designs as a reusable template, making it easy to maintain consistency and speed up future campaign creation."
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [],
      [],
      [],
      [],
      [],
      []
    ]
  }
] as Block[];

export default function ProductVisualBuilderPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
