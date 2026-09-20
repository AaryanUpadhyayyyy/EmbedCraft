// AUTO-GENERATED page — content for /integrations/google-tag-manager/set-up
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/google-tag-manager/set-up";
const TITLE = "Set up";
const DESCRIPTION = "This guide will help you integrate the EmbedCraft SDK using Google Tag Manager (GTM) to track user activities and events. By following these steps, you will be able to initialize the EmbedCraft SDK, identify users, and track events across your website using GTM.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Set up",
    "id": "set-up"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This guide will help you integrate the EmbedCraft SDK using Google Tag Manager (GTM) to track user activities and events. By following these steps, you will be able to initialize the EmbedCraft SDK, identify users, and track events across your website using GTM."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You need a nudge account to get your"
      },
      {
        "t": "c",
        "v": "API_KEY"
      },
      {
        "t": "t",
        "v": ". See how to create one"
      },
      {
        "t": "t",
        "v": "here"
      },
      {
        "t": "t",
        "v": "."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 1 : EmbedCraft SDK Initialization",
    "id": "step-1-nudge-sdk-initialization"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Initialize the EmbedCraft SDK globally so it's available for tracking events on all pages."
      }
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Log in to Google Tag Manager."
        }
      ],
      [
        {
          "t": "t",
          "v": "Go to Tags > New."
        }
      ],
      [
        {
          "t": "t",
          "v": "Name the tag EmbedCraft SDK Initialization."
        }
      ],
      [
        {
          "t": "t",
          "v": "Select Tag Type as Custom HTML."
        }
      ],
      [
        {
          "t": "t",
          "v": "Add the following script:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "html",
    "code": "<script>\t(function () {\t\tif (!document.getElementById('NudgeCustomScript')) {\t\t\tvar script = document.createElement('script');\t\t\tscript.id = 'NudgeCustomScript';\t\t\tscript.src = 'https://web-scripts.embedcraft.com/index.js';\t\t\tscript.onload = function () {\t\t\t\t// Initialize NudgeLibrary and store it in the global window object\t\t\t\tif (!window.nudge) {\t\t\t\t\twindow.nudge = new NudgeLibrary.EmbedCraft({\t\t\t\t\t\tapiKey: 'YOUR_API_KEY',\t\t\t\t\t});\t\t\t\t}\t\t\t};\t\t\tdocument.head.appendChild(script);\t\t}\t})();</script>"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Set the trigger to All Pages (so it runs on every page)."
        }
      ],
      [
        {
          "t": "t",
          "v": "Save and publish the tag."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 2 : User Identification",
    "id": "step-2-user-identification"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Identify users to personalize their tracking data"
      }
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Go to Tags > New."
        }
      ],
      [
        {
          "t": "t",
          "v": "Name the tag EmbedCraft SDK Initialization."
        }
      ],
      [
        {
          "t": "t",
          "v": "Select Tag Type as Custom HTML."
        }
      ],
      [
        {
          "t": "t",
          "v": "Add the following script:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "html",
    "code": "<script>\t(function () {\t\tif (window.nudge) {\t\t\twindow.nudge.userIdentifier({\t\t\t\tuserId: 'USER_ID', // Replace with actual user ID\t\t\t\temail: 'user@example.com', // Replace with user email\t\t\t});\t\t}\t})();</script>"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Set the trigger to an appropriate event, such as User Login or All Pages."
        }
      ],
      [
        {
          "t": "t",
          "v": "Save and publish the tag."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Anonymous Users",
    "id": "anonymous-users"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "If there is no authenticated user, EmbedCraft can create an anonymous ID for tracking purposes. You can combine initialization and identification in a single tag for anonymous users:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "html",
    "code": "<script>\t(function () {\t\tif (!document.getElementById('NudgeCustomScript')) {\t\t\tvar script = document.createElement('script');\t\t\tscript.id = 'NudgeCustomScript';\t\t\tscript.src = 'https://web-scripts.embedcraft.com/index.js';\t\t\tscript.onload = function () {\t\t\t\t// Initialize NudgeLibrary and store it in the global window object\t\t\t\tif (!window.nudge) {\t\t\t\t\twindow.nudge = new NudgeLibrary.EmbedCraft({\t\t\t\t\t\tapiKey: 'YOUR_API_KEY',\t\t\t\t\t});\t\t\t\t}\t\t\t\twindow.nudge.userIdentifier({});\t\t\t};\t\t\tdocument.head.appendChild(script);\t\t}\t})();</script>"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 3 : Event Tracking",
    "id": "step-3-event-tracking"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Track user events such as button clicks, page views, or other interactions."
      }
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Go to Tags > New."
        }
      ],
      [
        {
          "t": "t",
          "v": "Name the tag EmbedCraft SDK Initialization."
        }
      ],
      [
        {
          "t": "t",
          "v": "Select Tag Type as Custom HTML."
        }
      ],
      [
        {
          "t": "t",
          "v": "Add the following script:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "html",
    "code": "<script>\t(function () {\t\tvar maxRetries = 30;\t\tvar intervalTime = 100;\t\tvar retryCount = 0;\t\tvar checkNudge = setInterval(function () {\t\t\tif (window.nudge) {\t\t\t\tclearInterval(checkNudge);\t\t\t\twindow.nudge.track({\t\t\t\t\tevent: 'page_view',\t\t\t\t});\t\t\t}\t\t\tretryCount++;\t\t\tif (retryCount >= maxRetries) {\t\t\t\tclearInterval(checkNudge);\t\t\t}\t\t}, intervalTime);\t})();</script>"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Set the trigger to an appropriate event, such as User Login or All Pages."
        }
      ],
      [
        {
          "t": "t",
          "v": "Save and publish the tag."
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
        "v": "To ensure optimal performance, EmbedCraft enforces the following limits:"
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
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Initialization must happen first before user identification or event tracking. If you're using separate tags for initialization, identification, and tracking, you must manage the sequencing to ensure the SDK is fully initialized before trying to identify the user or track any events. This can be managed by using tag sequencing in GTM to ensure that the initialization tag runs before the user identification or event tracking tags."
      }
    ]
  }
] as Block[];

export default function IntegrationsGoogleTagManagerSetUpPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
