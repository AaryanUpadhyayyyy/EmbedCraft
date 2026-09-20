// AUTO-GENERATED page — content for /platform/flutter/tracking-events-flutter
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/flutter/tracking-events-flutter";
const TITLE = "Tracking Events";
const DESCRIPTION = "What are Events?";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Tracking Events",
    "id": "tracking-events"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "What are Events?",
    "id": "what-are-events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Events"
      },
      {
        "t": "t",
        "v": "represent specific user interactions within your application. These can be anything from a button click ("
      },
      {
        "t": "c",
        "v": "add_to_cart"
      },
      {
        "t": "t",
        "v": "), a screen view ("
      },
      {
        "t": "c",
        "v": "view_profile"
      },
      {
        "t": "t",
        "v": "), or a system state change ("
      },
      {
        "t": "c",
        "v": "subscription_expired"
      },
      {
        "t": "t",
        "v": ")."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Why Track Events?",
    "id": "why-track-events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Tracking events is crucial for two main reasons:"
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
          "v": "Triggering Campaigns"
        },
        {
          "t": "t",
          "v": ": AppNinja uses events to determine"
        },
        {
          "t": "i",
          "v": "when"
        },
        {
          "t": "t",
          "v": "to show a specific experience (e.g., show a tooltip when a user clicks \"Help\")."
        }
      ],
      [
        {
          "t": "b",
          "v": "Analytics & Segmentation"
        },
        {
          "t": "t",
          "v": ": Events allow you to understand user behavior and create segments (e.g., users who have triggered"
        },
        {
          "t": "c",
          "v": "checkout_completed"
        },
        {
          "t": "t",
          "v": "> 3 times)."
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
    "text": "Usage",
    "id": "usage"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use the"
      },
      {
        "t": "c",
        "v": "track"
      },
      {
        "t": "t",
        "v": "method to log an event. You can also pass a map of properties to provide more context about the event."
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
          "v": "Only small alphabets, numbers, and underscores (_) are allowed."
        }
      ],
      [
        {
          "t": "t",
          "v": "Spaces are not allowed in event names."
        }
      ],
      [
        {
          "t": "t",
          "v": "Name cannot start with a number; it needs to start with an alphabet."
        }
      ],
      [
        {
          "t": "t",
          "v": "The name should be between 2 and 99 characters in length."
        }
      ],
      [
        {
          "t": "t",
          "v": "If any capital letter is sent, it will be converted to lowercase."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Payload Size Limits",
    "id": "payload-size-limits"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To ensure optimal performance, AppNinja enforces the following limits:"
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Limit Type"
        }
      ],
      [
        {
          "t": "t",
          "v": "Maximum Value"
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
            "t": "b",
            "v": "Single Event Payload"
          }
        ],
        [
          {
            "t": "t",
            "v": "12 KB"
          }
        ],
        [
          {
            "t": "t",
            "v": "Total size for individual track events"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "String Property Length"
          }
        ],
        [
          {
            "t": "t",
            "v": "256 characters"
          }
        ],
        [
          {
            "t": "t",
            "v": "Individual string properties are truncated beyond this limit"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Unique Keys per Event"
          }
        ],
        [
          {
            "t": "t",
            "v": "128 keys"
          }
        ],
        [
          {
            "t": "t",
            "v": "Maximum number of properties per event"
          }
        ]
      ]
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Only lowercase letters, numbers, and underscores allowed"
        }
      ],
      [
        {
          "t": "t",
          "v": "Must start with a letter (not a number)"
        }
      ],
      [
        {
          "t": "t",
          "v": "Length: 2-99 characters"
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
          "v": "Event Names"
        },
        {
          "t": "t",
          "v": ": Must be in"
        },
        {
          "t": "b",
          "v": "lowercase"
        },
        {
          "t": "t",
          "v": "(e.g.,"
        },
        {
          "t": "c",
          "v": "item_purchased"
        },
        {
          "t": "t",
          "v": ", not"
        },
        {
          "t": "c",
          "v": "ItemPurchased"
        },
        {
          "t": "t",
          "v": ")."
        }
      ],
      [
        {
          "t": "b",
          "v": "Property Keys"
        },
        {
          "t": "t",
          "v": ": Must be in"
        },
        {
          "t": "b",
          "v": "lowercase"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "b",
          "v": "Naming Pattern"
        },
        {
          "t": "t",
          "v": ": Must match the regex"
        },
        {
          "t": "c",
          "v": "^[a-z][a-z0-9_]{2,99}$"
        }
      ],
      [
        {
          "t": "b",
          "v": "String Limits"
        },
        {
          "t": "t",
          "v": ": String property values should not exceed"
        },
        {
          "t": "b",
          "v": "256 characters"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "b",
          "v": "Maximum Keys"
        },
        {
          "t": "t",
          "v": ": Up to"
        },
        {
          "t": "b",
          "v": "128 property keys"
        },
        {
          "t": "t",
          "v": "allowed in the properties map."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Basic Event Tracking",
    "id": "basic-event-tracking"
  },
  {
    "type": "code",
    "lang": "dart",
    "code": "import 'package:in_app_ninja/in_app_ninja.dart';\n\n// Track a simple event\nAppNinja.track('button_clicked');"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Event with Properties",
    "id": "event-with-properties"
  },
  {
    "type": "code",
    "lang": "dart",
    "code": "// Define event properties\nMap<String, dynamic> eventProps = {\n  'product_name': 'Running Shoes',\n  'price': 99.99,\n  'is_sale_item': true,\n  'category_id': 1024\n};\n\n// Track the event with properties\nAppNinja.track('add_to_cart', properties: eventProps);"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Do not call"
      },
      {
        "t": "c",
        "v": "AppNinja.track()"
      },
      {
        "t": "t",
        "v": "inside the"
      },
      {
        "t": "c",
        "v": "build()"
      },
      {
        "t": "t",
        "v": "method of a StatefulWidget. This can cause performance issues and duplicate events. Instead, call it in event handlers or lifecycle methods."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Common Event Examples",
    "id": "common-event-examples"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Here are some typical events you might track in your app:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "dart",
    "code": "// User viewed a product\nAppNinja.track('product_viewed', properties: {\n  'product_id': 'SKU-12345',\n  'product_name': 'Wireless Headphones',\n  'price': 79.99\n});\n\n// User completed checkout\nAppNinja.track('checkout_completed', properties: {\n  'order_id': 'ORD-98765',\n  'total_amount': 249.99,\n  'item_count': 3\n});\n\n// User shared content\nAppNinja.track('content_shared', properties: {\n  'content_type': 'article',\n  'share_method': 'whatsapp'\n});"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Best Practices",
    "id": "best-practices"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "b",
          "v": "Track Meaningful Actions"
        },
        {
          "t": "t",
          "v": ": Focus on events that provide business value or user insights"
        }
      ],
      [
        {
          "t": "b",
          "v": "Use Descriptive Names"
        },
        {
          "t": "t",
          "v": ": Event names should clearly indicate what happened"
        }
      ],
      [
        {
          "t": "b",
          "v": "Keep Properties Relevant"
        },
        {
          "t": "t",
          "v": ": Only include properties that add context to the event"
        }
      ],
      [
        {
          "t": "b",
          "v": "Be Consistent"
        },
        {
          "t": "t",
          "v": ": Use the same event names across platforms (iOS, Android, Web)"
        }
      ]
    ]
  }
] as Block[];

export default function PlatformFlutterTrackingEventsFlutterPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
