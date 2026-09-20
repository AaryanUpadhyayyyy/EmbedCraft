// AUTO-GENERATED page — content for /apis/identify-user
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/identify-user";
const TITLE = "Identify user";
const DESCRIPTION = "Identify or update users from your backend and associate custom properties.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Identify user",
    "id": "identify-user"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "PUT https://main-api.embedcraft.com/api/track/user"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Identify or update users from your backend and associate custom properties."
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
    "type": "heading",
    "level": 4,
    "text": "Request Validations",
    "id": "request-validations"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "c",
          "v": "ext_id"
        },
        {
          "t": "t",
          "v": ": Must match regex"
        },
        {
          "t": "c",
          "v": "/^[A-Za-z0-9_]{1,99}$/"
        }
      ],
      [
        {
          "t": "t",
          "v": "Property keys (in"
        },
        {
          "t": "c",
          "v": "props_*"
        },
        {
          "t": "t",
          "v": "): Must match"
        },
        {
          "t": "c",
          "v": "/^[$A-Za-z][A-Za-z0-9_]{1,99}$/"
        }
      ],
      [
        {
          "t": "c",
          "v": "props_num"
        },
        {
          "t": "t",
          "v": ": Max value"
        },
        {
          "t": "c",
          "v": "2147483647"
        }
      ],
      [
        {
          "t": "c",
          "v": "props_text"
        },
        {
          "t": "t",
          "v": ": Max length"
        },
        {
          "t": "c",
          "v": "200"
        },
        {
          "t": "t",
          "v": "characters"
        }
      ]
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
        "v": "Client-identifiable unique ID for the user"
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
        "v": "Name of the user"
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
        "v": "<= 100 characters"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Email of the user"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Phone number of the user"
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
        "v": "Value must match regular expression"
      },
      {
        "t": "c",
        "v": "^\\+?[1-9]\\d{1,14}$"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "IANA timezone (e.g., \"Asia/Kolkata\")"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "BCP 47 language tag (e.g., \"en-IN\")"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Numeric user attributes"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Text user attributes"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Boolean user attributes"
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
        "v": "Successful response with user UID"
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
        "v": "Unique UUIDv4 user identifier"
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
    "code": "{  \"uid\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sample response"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"uid\": \"2762ff09-d7f0-4288-b25d-e5ffe5434724\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Validation error or invalid user"
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
          "v": "validationError"
        }
      ],
      [
        {
          "t": "t",
          "v": "invalidUser"
        }
      ]
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": []
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Validation Failed"
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
        "v": "Invalid User"
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
    "code": "curl -L -X PUT 'https://main-api.embedcraft.com/api/track/user' \\-H 'Content-Type: application/json' \\-H 'Accept: application/json' \\-H 'apikey: <apikey>' \\--data-raw '{  \"ext_id\": \"sample_id\",  \"name\": \"Sample User\",  \"email\": \"sample@provider.com\",  \"phone\": \"9999999999\",  \"tz\": \"string\",  \"locale\": \"string\",  \"props_num\": {    \"rank\": 1,    \"wallet_balance\": 500.05  },  \"props_text\": {    \"segment\": \"power\"  },  \"props_bool\": {    \"has_subscribed\": true  }}'"
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
    "code": "{\n  \"ext_id\": \"sample_id\",\n  \"name\": \"Sample User\",\n  \"email\": \"sample@provider.com\",\n  \"phone\": \"9999999999\",\n  \"tz\": \"string\",\n  \"locale\": \"string\",\n  \"props_num\": {\n    \"rank\": 1,\n    \"wallet_balance\": 500.05\n  },\n  \"props_text\": {\n    \"segment\": \"power\"\n  },\n  \"props_bool\": {\n    \"has_subscribed\": true\n  }\n}"
  }
] as Block[];

export default function ApisIdentifyUserPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
