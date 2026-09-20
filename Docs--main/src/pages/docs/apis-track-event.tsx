// AUTO-GENERATED page — content for /apis/track-event
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/track-event";
const TITLE = "Track event";
const DESCRIPTION = "Track events and event properties from your backend.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Track event",
    "id": "track-event"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "POST https://main-api.embedcraft.com/api/track/event"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Track events and event properties from your backend."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Edit the in request schema for switching between regions."
      },
      {
        "t": "c",
        "v": "Base URL"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Only Identified users' events can be tracked. Ensure the user is identified before tracking events."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Rate Limits",
    "id": "rate-limits"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "IP-based:"
        },
        {
          "t": "t",
          "v": "6000 requests per minute per IP address"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Request",
    "id": "request"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Header Parameters",
    "id": "header-parameters"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": ">= 5 characters"
      },
      {
        "t": "t",
        "v": "and"
      },
      {
        "t": "c",
        "v": "<= 36 characters"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Unique key to prevent duplicate processing. Valid for 12 hours"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": []
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "application/json"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Bodyrequired",
    "id": "bodyrequired"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Your internal user ID performing the event"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": "non-empty"
      },
      {
        "t": "t",
        "v": "and"
      },
      {
        "t": "c",
        "v": "<= 64 characters"
      },
      {
        "t": "t",
        "v": ", Value must match regular expression"
      },
      {
        "t": "c",
        "v": "^[^\\s|]+$"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Name of the event"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": "non-empty"
      },
      {
        "t": "t",
        "v": "and"
      },
      {
        "t": "c",
        "v": "<= 100 characters"
      },
      {
        "t": "t",
        "v": ", Value must match regular expression"
      },
      {
        "t": "c",
        "v": "^[A-Za-z0-9_]+$"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Number-based properties"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Text-based properties"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Boolean flags"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Timestamp of event occurrence"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": []
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Responses",
    "id": "responses"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "200"
        }
      ],
      [
        {
          "t": "t",
          "v": "204"
        }
      ],
      [
        {
          "t": "t",
          "v": "400"
        }
      ],
      [
        {
          "t": "t",
          "v": "401"
        }
      ],
      [
        {
          "t": "t",
          "v": "429"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Successful response with rewards"
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
          "v": "application/json"
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
          "v": "Schema"
        }
      ],
      [
        {
          "t": "t",
          "v": "Example (auto)"
        }
      ],
      [
        {
          "t": "t",
          "v": "successfulResponse"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Unique reward transaction ID"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "User's unique identifier"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Quantity of the reward"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": ">= 1"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Identifier of the reward configuration"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Name of the reward"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Task ID associated with the reward"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Type of reward (1=coin, 2=coupon, 3=other)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "t",
        "v": "["
      },
      {
        "t": "c",
        "v": "1"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "c",
        "v": "2"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "c",
        "v": "3"
      },
      {
        "t": "t",
        "v": "]"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Coin value (for coin type rewards)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": ">= 0"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Number of times reward has been used"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": ">= 0"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Additional notes"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Status of the reward (1=pending, 2=active, 3=expired)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "t",
        "v": "["
      },
      {
        "t": "c",
        "v": "1"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "c",
        "v": "2"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "c",
        "v": "3"
      },
      {
        "t": "t",
        "v": "]"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Last update timestamp"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Creation timestamp"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Coupon code (for coupon type rewards)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Expiry timestamp"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Human-readable expiry information"
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
          "v": "Array ["
        }
      ],
      [
        {
          "t": "t",
          "v": "]"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"rewards\": [    {      \"id\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\",      \"uid\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\",      \"reward_qty\": 0,      \"reward_id\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\",      \"reward_name\": \"string\",      \"task_id\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\",      \"reward_type\": 1,      \"coin_val\": 0,      \"used_count\": 0,      \"note\": \"string\",      \"status\": 1,      \"updated_at\": \"2024-07-29T15:51:28.071Z\",      \"created_at\": \"2024-07-29T15:51:28.071Z\",      \"coupon_code\": \"string\",      \"expiry_at\": \"2024-07-29T15:51:28.071Z\",      \"expiry_text\": \"string\"    }  ]}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sample successful response"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"rewards\": [    {      \"id\": \"d6de30f2-9429-492a-90ca-f68af2d96726\",      \"uid\": \"f08ea141-e499-4790-8581-8dac9ceb8d10\",      \"reward_qty\": 1,      \"reward_id\": \"154d9166-cbdb-44f5-b9f4-a499482ae16a\",      \"reward_name\": \"coin\",      \"task_id\": \"a60e6b8e-d270-45ca-8f98-d57808afe607\",      \"reward_type\": 2,      \"coin_val\": 1,      \"used_count\": 0,      \"note\": \"\",      \"status\": 2,      \"updated_at\": \"2024-11-23T09:12:04.552Z\",      \"created_at\": \"2024-11-23T09:12:05.418Z\",      \"coupon_code\": \"\",      \"expiry_at\": null,      \"expiry_text\": \"\"    }  ]}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Duplicate request (idempotent key reused within 12 hours)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Bad request - validation or missing fields"
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
          "v": "application/json"
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
          "v": "Schema"
        }
      ],
      [
        {
          "t": "t",
          "v": "Example (auto)"
        }
      ],
      [
        {
          "t": "t",
          "v": "validationError"
        }
      ],
      [
        {
          "t": "t",
          "v": "invalidUser"
        }
      ],
      [
        {
          "t": "t",
          "v": "userNotFound"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Error message"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": []
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"message\": \"string\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Validation error"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"message\": \"VALIDATION FAILED\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Invalid user"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"message\": \"invalid user\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "User not identified"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"message\": \"user not found\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Unauthorized - Invalid or missing API key"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Too Many Requests - Rate limit exceeded"
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Authorization: apikey",
    "id": "authorization-apikey"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "name: apikeytype: apiKeyin: headerdescription: Private key as in the nudge dashboard settings > Secret Keys"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "curl"
        }
      ],
      [
        {
          "t": "t",
          "v": "python"
        }
      ],
      [
        {
          "t": "t",
          "v": "go"
        }
      ],
      [
        {
          "t": "t",
          "v": "nodejs"
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
          "v": "CURL"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "bash",
    "code": "curl -L 'https://main-api.embedcraft.com/api/track/event' \\-H 'Content-Type: application/json' \\-H 'Accept: application/json' \\-H 'apikey: <apikey>' \\-d '{  \"ext_id\": \"sp_nudge_141\",  \"name\": \"event\",  \"props_num\": {    \"amount\": 100  },  \"props_text\": {    \"type\": \"upi\"  },  \"props_bool\": {    \"prime\": true  },  \"occurred_at\": \"2024-04-30T08:54:22.666Z\"}'"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Example (from schema)"
        }
      ],
      [
        {
          "t": "t",
          "v": "sampleRequest"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{\n  \"ext_id\": \"sp_nudge_141\",\n  \"name\": \"event\",\n  \"props_num\": {\n    \"amount\": 100\n  },\n  \"props_text\": {\n    \"type\": \"upi\"\n  },\n  \"props_bool\": {\n    \"prime\": true\n  },\n  \"occurred_at\": \"2024-04-30T08:54:22.666Z\"\n}"
  }
] as Block[];

export default function ApisTrackEventPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
