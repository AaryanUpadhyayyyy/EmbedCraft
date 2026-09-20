// AUTO-GENERATED page — content for /product/VisualBuilder/variables
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/VisualBuilder/variables";
const TITLE = "Variables";
const DESCRIPTION = "Learn about interfaces in EmbedCraft&#39;s Visual Builder.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Variables",
    "id": "variables"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft provides a powerful templating system to personalise UI elements such as profile picture URLs, text, and other dynamic content. This guide explains how to use EmbedCraft's templating syntax to create personalised experiences."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Templating Syntax",
    "id": "templating-syntax"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The templating system uses the following regex to identify placeholders in strings:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "text",
    "code": "\\{\\{(.*?)\\}\\}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "A string can contain substrings matching this regex. For example:"
      },
      {
        "t": "c",
        "v": "\"Hey {{U.name}}, Your age is {{U.age}}\""
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Templating Parts and Uses",
    "id": "templating-parts-and-uses"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Template Syntax"
        }
      ],
      [
        {
          "t": "t",
          "v": "Parts"
        }
      ],
      [
        {
          "t": "t",
          "v": "Use Case"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "c",
            "v": "{{U.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "2 (U, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "User Templating"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{D.l.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "3 (Data Source, list, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Task Templating in a list"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{D.1.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "3 (Data Source, Index, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Task Templating for a specific index"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{D.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "2 (Data Source, Variable Name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Task Templating while using in list view or step view"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{R.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "2 (R, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Reward Templating"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{A.id.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "3 (A, api id, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "API Templating"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{S.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "2 (S, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Referral Templating"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{L.l.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "3 (Leaderboard, list, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Leaderboard Users"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{C.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "2 (Leaderboard Current User, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Leaderboard Current User"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{W.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "2 (W, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Wallet Templating"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{G.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "2 (G, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Global Variables"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "{{X.variable_name}}"
          }
        ],
        [
          {
            "t": "t",
            "v": "2 (X, variable_name)"
          }
        ],
        [
          {
            "t": "t",
            "v": "Root Variables"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Advanced API Templating",
    "id": "advanced-api-templating"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "For API templating, variables can include"
      },
      {
        "t": "c",
        "v": "|"
      },
      {
        "t": "t",
        "v": "to represent a nested structure in a JSON response or"
      },
      {
        "t": "c",
        "v": "*i"
      },
      {
        "t": "t",
        "v": "to represent a specific index in an array."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Examples:",
    "id": "examples"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "c",
          "v": "{{A.id.users|name}}"
        },
        {
          "t": "t",
          "v": "retrieves the"
        },
        {
          "t": "c",
          "v": "name"
        },
        {
          "t": "t",
          "v": "field from the"
        },
        {
          "t": "c",
          "v": "users"
        },
        {
          "t": "t",
          "v": "array."
        }
      ],
      [
        {
          "t": "c",
          "v": "{{A.id.users*1|name}}"
        },
        {
          "t": "t",
          "v": "retrieves the"
        },
        {
          "t": "c",
          "v": "name"
        },
        {
          "t": "t",
          "v": "field from the"
        },
        {
          "t": "c",
          "v": "users"
        },
        {
          "t": "t",
          "v": "array at index 1."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Fallback Values",
    "id": "fallback-values"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You can specify fallback values using"
      },
      {
        "t": "c",
        "v": "="
      },
      {
        "t": "t",
        "v": "."
      },
      {
        "t": "t",
        "v": "For example:"
      },
      {
        "t": "c",
        "v": "{{U.name=SampleUser}}"
      },
      {
        "t": "t",
        "v": "will display \"SampleUser\" if"
      },
      {
        "t": "c",
        "v": "U.name"
      },
      {
        "t": "t",
        "v": "is not available."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "API Parameter Override",
    "id": "api-parameter-override"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You can override API parameters by specifying them in the root key."
      },
      {
        "t": "t",
        "v": "Example:"
      },
      {
        "t": "c",
        "v": "api = [\"api_id?key1=value1&key2=value2\"]"
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "At a Glance: Templating Prefixes",
    "id": "at-a-glance-templating-prefixes"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Prefix"
        }
      ],
      [
        {
          "t": "t",
          "v": "Description"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "c",
            "v": "D"
          }
        ],
        [
          {
            "t": "t",
            "v": "Task"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "T"
          }
        ],
        [
          {
            "t": "t",
            "v": "Task Property"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "E"
          }
        ],
        [
          {
            "t": "t",
            "v": "Event Property"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "R"
          }
        ],
        [
          {
            "t": "t",
            "v": "Rewards"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "U"
          }
        ],
        [
          {
            "t": "t",
            "v": "User"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "A"
          }
        ],
        [
          {
            "t": "t",
            "v": "API"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "S"
          }
        ],
        [
          {
            "t": "t",
            "v": "Referral"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "W"
          }
        ],
        [
          {
            "t": "t",
            "v": "Wallet"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "G"
          }
        ],
        [
          {
            "t": "t",
            "v": "Global Variables"
          }
        ]
      ],
      [
        [
          {
            "t": "c",
            "v": "X"
          }
        ],
        [
          {
            "t": "t",
            "v": "Widget Variables"
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
        "v": "By leveraging these templating options, you can dynamically personalise your UI to create engaging and user-specific experiences."
      }
    ]
  }
] as Block[];

export default function ProductVisualBuilderVariablesPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
