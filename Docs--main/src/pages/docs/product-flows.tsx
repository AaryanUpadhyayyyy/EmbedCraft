// AUTO-GENERATED page — content for /product/Flows
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Flows";
const TITLE = "Flows";
const DESCRIPTION = "Orchestrate user journeys with EmbedCraft.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Flows",
    "id": "flows"
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
        "v": "Flows enable you to orchestrate multi-step user journeys within your application by connecting different experience blocks (nodes). You can define conditions, actions, and transitions that guide users dynamically based on their behavior."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Flows are a powerful way to chain experiences together—like surveys, modals, nudges, and more—and create intelligent, branching journeys."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Nodes",
    "id": "nodes"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Each node in a Flow represents a specific experience or decision point. You can configure the behavior of each node and define how users move from one node to another using"
      },
      {
        "t": "b",
        "v": "edges"
      },
      {
        "t": "t",
        "v": "."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Start Node",
    "id": "start-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The starting point of your Flow. Define the entry conditions here."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Automatically transitions to the next node based on its trigger condition."
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
          "v": "Configuration"
        },
        {
          "t": "t",
          "v": ": Set user filters and event-based triggers that determine who enters the Flow."
        }
      ],
      [
        {
          "t": "b",
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Event Node",
    "id": "event-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Represents a user event checkpoint in the journey."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Automatically continues based on trigger conditions in the next node."
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
          "v": "Use case"
        },
        {
          "t": "t",
          "v": ": Wait for a specific event to occur before progressing."
        }
      ],
      [
        {
          "t": "b",
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Modal Node",
    "id": "modal-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Displays a modal UI as part of the journey. You can fully design the modal using the Visual Builder."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Proceeds automatically based on the next node’s trigger."
        }
      ],
      [
        {
          "t": "b",
          "v": "Dismiss"
        },
        {
          "t": "t",
          "v": ": Triggered when the user dismisses the modal."
        }
      ],
      [
        {
          "t": "b",
          "v": "Custom Actions"
        },
        {
          "t": "t",
          "v": ": Triggered when a user interacts with a specific button or action defined in the modal."
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
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Bottom Sheet Node",
    "id": "bottom-sheet-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Displays a bottom sheet UI in the journey."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Proceeds automatically based on the next node’s trigger."
        }
      ],
      [
        {
          "t": "b",
          "v": "Dismiss"
        },
        {
          "t": "t",
          "v": ": Triggered when the user dismisses the bottom sheet."
        }
      ],
      [
        {
          "t": "b",
          "v": "Custom Actions"
        },
        {
          "t": "t",
          "v": ": Triggered when a user interacts with a specific button or action defined in the bottom sheet."
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
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Full Page Node",
    "id": "full-page-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Displays a full-page experience in the journey."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Proceeds automatically based on the next node’s trigger."
        }
      ],
      [
        {
          "t": "b",
          "v": "Dismiss"
        },
        {
          "t": "t",
          "v": ": Triggered when the user dismisses the full-page view."
        }
      ],
      [
        {
          "t": "b",
          "v": "Custom Actions"
        },
        {
          "t": "t",
          "v": ": Triggered when a user interacts with a specific button or action defined in the full-page design."
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
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Tooltip Node",
    "id": "tooltip-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Adds a tooltip nudge within the flow to guide users."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Proceeds automatically based on the next node’s trigger."
        }
      ],
      [
        {
          "t": "b",
          "v": "Dismiss"
        },
        {
          "t": "t",
          "v": ": Triggered when the user dismisses the tooltip."
        }
      ],
      [
        {
          "t": "b",
          "v": "Custom Actions"
        },
        {
          "t": "t",
          "v": ": Triggered when a user interacts with a specific button or action defined in the tooltip."
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
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Spotlight Node",
    "id": "spotlight-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Adds a spotlight nudge to highlight a UI element."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Proceeds automatically based on the next node’s trigger."
        }
      ],
      [
        {
          "t": "b",
          "v": "Dismiss"
        },
        {
          "t": "t",
          "v": ": Triggered when the user dismisses the spotlight."
        }
      ],
      [
        {
          "t": "b",
          "v": "Custom Actions"
        },
        {
          "t": "t",
          "v": ": Triggered when a user interacts with a specific button or action defined in the spotlight."
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
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Coachmark Node",
    "id": "coachmark-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Displays a coachmark to guide or inform users."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Proceeds automatically based on the next node’s trigger."
        }
      ],
      [
        {
          "t": "b",
          "v": "Dismiss"
        },
        {
          "t": "t",
          "v": ": Triggered when the user dismisses the coachmark."
        }
      ],
      [
        {
          "t": "b",
          "v": "Custom Actions"
        },
        {
          "t": "t",
          "v": ": Triggered when a user interacts with a specific button or action defined in the coachmark."
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
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Survey Node",
    "id": "survey-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Presents a survey to collect feedback from users mid-journey."
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
          "v": "Auto"
        },
        {
          "t": "t",
          "v": ": Automatically progresses based on the next node’s trigger."
        }
      ],
      [
        {
          "t": "b",
          "v": "Complete"
        },
        {
          "t": "t",
          "v": ": Triggered when the user submits the survey."
        }
      ],
      [
        {
          "t": "b",
          "v": "Dismiss"
        },
        {
          "t": "t",
          "v": ": Triggered when the user dismisses the survey."
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
          "v": "Edges"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Exit Node",
    "id": "exit-node"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Ends the user's journey through the Flow."
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
          "v": "Behavior"
        },
        {
          "t": "t",
          "v": ": When a user reaches this node, they exit the Flow and no further nodes are evaluated."
        }
      ]
    ]
  }
] as Block[];

export default function ProductFlowsPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
