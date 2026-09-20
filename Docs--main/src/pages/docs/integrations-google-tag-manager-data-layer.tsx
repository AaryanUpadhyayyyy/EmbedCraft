// AUTO-GENERATED page — content for /integrations/google-tag-manager/data-layer
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/google-tag-manager/data-layer";
const TITLE = "Data Layer";
const DESCRIPTION = "The Data Layer is a JavaScript object used by Google Tag Manager (GTM) to pass information from your website to GTM tags. It allows for dynamic data (such as user properties or event details) to be captured and utilized in the EmbedCraft SDK, ensuring more flexible and personalized tracking.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Data Layer",
    "id": "data-layer"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Data Layer is a JavaScript object used by Google Tag Manager (GTM) to pass information from your website to GTM tags. It allows for dynamic data (such as user properties or event details) to be captured and utilized in the EmbedCraft SDK, ensuring more flexible and personalized tracking."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "In this guide, you’ll learn how to set up the Data Layer, create variables in GTM, and use them with the EmbedCraft SDK."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "What is the Data Layer?",
    "id": "what-is-the-data-layer"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Data Layer is a shared object that stores information about the user, events, or other contextual details of your website. GTM listens for changes in the Data Layer and reacts accordingly, allowing you to capture dynamic information and use it in your tags."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 1 : Setting up Variables in GTM",
    "id": "step-1-setting-up-variables-in-gtm"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Variables in GTM are used to extract data from the Data Layer and pass it to the EmbedCraft SDK. Here's how to set them up:"
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
          "v": "Navigate to Variables:"
        }
      ],
      [
        {
          "t": "t",
          "v": "Click New to create a new variable."
        }
      ],
      [
        {
          "t": "t",
          "v": "Select Variable Configuration > Data Layer Variable."
        }
      ],
      [
        {
          "t": "t",
          "v": "Enter the name of the key from the Data Layer that you want to extract. For example, userId, email, or userProperties.age."
        }
      ],
      [
        {
          "t": "t",
          "v": "Create separate variables for each piece of data you want to extract (e.g., userId, email, age, gender).\nHere’s an example of a variable configuration for userId:"
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
          "v": "Variable Name: DLV_USERID"
        }
      ],
      [
        {
          "t": "t",
          "v": "Data Layer Variable Name: userId"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 2 : Using the Data Layer Variables in EmbedCraft SDK",
    "id": "step-2-using-the-data-layer-variables-in-nudge-sdk"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Once your Data Layer variables are set up, you can use them in your EmbedCraft SDK tags to dynamically pass user and event data."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Sending user properties using Data Layer",
    "id": "sending-user-properties-using-data-layer"
  },
  {
    "type": "code",
    "lang": "html",
    "code": "<script>\t(function() {\t  if (window.nudge) {\t    window.nudge.userIdentifier({\t      event : \"userData\"\t      externalId: \"{{DLV_USERID}}\",\t      email: \"{{DLV_EMAIL}}\",\t      properties: {\t        age: \"{{DLV_AGE}}\",\t        gender: \"{{DLV_GENDER}}\",\t        country: \"{{DLV_COUNTRY}}\"\t      }\t    });\t  }\t})();</script>"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Sending event properties using data layer",
    "id": "sending-event-properties-using-data-layer"
  },
  {
    "type": "code",
    "lang": "html",
    "code": "<script>\t(function () {\t\tif (window.nudge) {\t\t\twindow.nudge.track({\t\t\t\tevent: 'purchase',\t\t\t\tproperties: {\t\t\t\t\tproduct: '{{DLV_PRODUCT}}',\t\t\t\t\tquantity: '{{DLV_QUANTITY}}',\t\t\t\t\tcountryOfExport: '{{DLV_COUNTRYOFEXPORT}}',\t\t\t\t},\t\t\t});\t\t}\t})();</script>"
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
    "type": "heading",
    "level": 2,
    "text": "Step 3 : Pushing Data to the Data Layer",
    "id": "step-3-pushing-data-to-the-data-layer"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To send user or event-specific data to GTM, you need to push this information to the Data Layer dynamically when the event happens on your website."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Here’s an example of how to push a purchase event to the Data Layer:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "js",
    "code": "window.dataLayer.push({\tevent: 'purchaseEvent',\tproduct: 'Fortune Cookies',\tquantity: 5,\tcountryOfExport: 'US',});"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Triggering Tags Based on Data Layer Events",
    "id": "triggering-tags-based-on-data-layer-events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You can create triggers in GTM to fire tags when specific Data Layer events occur. For example, you can set a trigger to fire when the purchaseEvent occurs:"
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
          "v": "Go to Triggers in GTM and create a new trigger."
        }
      ],
      [
        {
          "t": "t",
          "v": "Choose Custom Event as the trigger type."
        }
      ],
      [
        {
          "t": "t",
          "v": "Set the Event Name to match the event in your Data Layer (purchaseEvent in this case)."
        }
      ],
      [
        {
          "t": "t",
          "v": "Link this trigger to your EmbedCraft SDK event tracking tag."
        }
      ]
    ]
  }
] as Block[];

export default function IntegrationsGoogleTagManagerDataLayerPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
