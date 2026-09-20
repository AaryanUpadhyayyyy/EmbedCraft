// AUTO-GENERATED page — content for /product/VisualBuilder/actions
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/VisualBuilder/actions";
const TITLE = "Actions";
const DESCRIPTION = "Learn about interfaces in EmbedCraft&#39;s Visual Builder.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Actions",
    "id": "actions"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft provides a variety of user interaction options to enhance the user experience and enable seamless navigation and functionality. Below is an overview of the available actions:"
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "1. External URL",
    "id": "1-external-url"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Description"
        },
        {
          "t": "t",
          "v": ": Redirects the user to an external website or resource."
        }
      ],
      [
        {
          "t": "b",
          "v": "Use Case"
        },
        {
          "t": "t",
          "v": ": Ideal for linking to external content, such as documentation, third-party services, or additional resources."
        }
      ],
      [
        {
          "t": "b",
          "v": "Example"
        },
        {
          "t": "t",
          "v": ": Clicking a button opens"
        },
        {
          "t": "c",
          "v": "https://example.com"
        },
        {
          "t": "t",
          "v": "in a new tab."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "2. Deep Link",
    "id": "2-deep-link"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Description"
        },
        {
          "t": "t",
          "v": ": Navigates the user to a specific location within the app or another app."
        }
      ],
      [
        {
          "t": "b",
          "v": "Use Case"
        },
        {
          "t": "t",
          "v": ": Useful for directing users to specific app screens or features."
        }
      ],
      [
        {
          "t": "b",
          "v": "Example"
        },
        {
          "t": "t",
          "v": ": A deep link navigates to the \"Profile\" section of the app."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "3. Widget",
    "id": "3-widget"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Widgets allow users to interact with various EmbedCraft pages in different formats:"
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
          "v": "Full Page"
        },
        {
          "t": "t",
          "v": ": Opens a EmbedCraft page in full-screen mode."
        }
      ],
      [
        {
          "t": "b",
          "v": "Bottom Sheet"
        },
        {
          "t": "t",
          "v": ": Displays a EmbedCraft page as a bottom sheet overlay."
        }
      ],
      [
        {
          "t": "b",
          "v": "Pop-ups"
        },
        {
          "t": "t",
          "v": ": Shows a EmbedCraft page as a modal pop-up."
        }
      ],
      [
        {
          "t": "b",
          "v": "Use Case"
        },
        {
          "t": "t",
          "v": ": Ideal for displaying additional content, forms, or interactive elements without leaving the current context."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "4. Close",
    "id": "4-close"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Description"
        },
        {
          "t": "t",
          "v": ": Closes the current view or interaction."
        }
      ],
      [
        {
          "t": "b",
          "v": "Use Case"
        },
        {
          "t": "t",
          "v": ": Used to dismiss overlays, modals, or other interactive elements."
        }
      ],
      [
        {
          "t": "b",
          "v": "Example"
        },
        {
          "t": "t",
          "v": ": A \"Cancel\" button closes the bottom sheet."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "5. Callback",
    "id": "5-callback"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Description"
        },
        {
          "t": "t",
          "v": ": Sends specific information back to the client-side application."
        }
      ],
      [
        {
          "t": "b",
          "v": "Use Case"
        },
        {
          "t": "t",
          "v": ": Enables dynamic interactions by passing data or triggering client-side logic."
        }
      ],
      [
        {
          "t": "b",
          "v": "Example"
        },
        {
          "t": "t",
          "v": ": A custom analytics on User Interaction or showing Custom screen not designed with nudge or implemention custom back stack navigation"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "6. Fire Event",
    "id": "6-fire-event"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Description"
        },
        {
          "t": "t",
          "v": ": Triggers a custom event within the application."
        }
      ],
      [
        {
          "t": "b",
          "v": "Use Case"
        },
        {
          "t": "t",
          "v": ": Useful for analytics, logging, or triggering specific workflows."
        }
      ],
      [
        {
          "t": "b",
          "v": "Example"
        },
        {
          "t": "t",
          "v": ": Clicking a button fires an event to track user engagement."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "These user interactions provide flexibility and control, allowing you to create engaging and dynamic experiences within the EmbedCraft platform."
      }
    ]
  }
] as Block[];

export default function ProductVisualBuilderActionsPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
