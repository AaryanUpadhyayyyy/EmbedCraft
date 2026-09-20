// AUTO-GENERATED page — content for /apis/identify-users-batch
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/identify-users-batch";
const TITLE = "Identify users (batch)";
const DESCRIPTION = "Identify or update **multiple** users from your backend in a single call and associate custom properties to each user.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Identify users (batch)",
    "id": "identify-users-batch"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "POST https://main-api.embedcraft.com/api/track/users/batch"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Identify or update"
      },
      {
        "t": "b",
        "v": "multiple"
      },
      {
        "t": "t",
        "v": "users from your backend in a single call and associate custom properties to each user."
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
          "t": "t",
          "v": "Request body must be an"
        },
        {
          "t": "b",
          "v": "array"
        },
        {
          "t": "t",
          "v": "with"
        },
        {
          "t": "b",
          "v": "max 200"
        },
        {
          "t": "t",
          "v": "items."
        }
      ],
      [
        {
          "t": "t",
          "v": "Each item requires"
        },
        {
          "t": "c",
          "v": "ext_id"
        },
        {
          "t": "t",
          "v": "(unique per user in your system)."
        }
      ],
      [
        {
          "t": "c",
          "v": "ext_id"
        },
        {
          "t": "t",
          "v": ": Must match"
        },
        {
          "t": "b",
          "v": "format"
        },
        {
          "t": "c",
          "v": "ext-id"
        },
        {
          "t": "t",
          "v": "(alphanumeric/underscore), length"
        },
        {
          "t": "b",
          "v": "1–64"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "t",
          "v": "Property keys (in"
        },
        {
          "t": "c",
          "v": "props"
        },
        {
          "t": "t",
          "v": "): Must match"
        },
        {
          "t": "c",
          "v": "/^[$A-Za-z][A-Za-z0-9_ -]{1,99}$/"
        },
        {
          "t": "t",
          "v": ". Prop keys will be converted to lowercase and space and hyphen '-' in the keys will be converted to underscore '_', before ingesting."
        }
      ],
      [
        {
          "t": "c",
          "v": "number props"
        },
        {
          "t": "t",
          "v": ": Max value"
        },
        {
          "t": "c",
          "v": "2147483647"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "c",
          "v": "text props"
        },
        {
          "t": "t",
          "v": ": Max length"
        },
        {
          "t": "c",
          "v": "250"
        },
        {
          "t": "t",
          "v": "characters, longer strings are trimmed to 250 characters."
        }
      ],
      [
        {
          "t": "t",
          "v": "Nullable fields may be sent as"
        },
        {
          "t": "c",
          "v": "null"
        },
        {
          "t": "t",
          "v": "or omitted."
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
    "text": "Body arrayrequired",
    "id": "body-arrayrequired"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "External user identifier from your system"
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
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Full name of the user"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Email address (may be empty string per server rules)"
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
        "v": "User properties (property names will be converted to lowercase)"
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
        "v": "Batch processed; any failed records are listed by ext_id"
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
          "v": "sampleSuccess"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "List of ext_id values that failed validation or processing"
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
    "code": "{  \"failedExtIds\": [    \"string\"  ]}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sample success payload"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"failedExtIds\": [    \"bob_02\"  ]}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Validation error on one or more records"
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
    "code": "curl -L 'https://main-api.embedcraft.com/api/track/users/batch' \\-H 'Content-Type: application/json' \\-H 'Accept: application/json' \\-H 'apikey: <apikey>' \\--data-raw '[  {    \"ext_id\": \"string\",    \"name\": \"string\",    \"email\": \"user@example.com\",    \"phone\": \"string\",    \"tz\": \"string\",    \"locale\": \"string\",    \"props\": {      \"rank\": 2,      \"points\": 23.5,      \"segment\": \"casual\",      \"has_subscribed\": false    }  }]'"
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
          "v": "sampleBatchRequest"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "[\n  {\n    \"ext_id\": \"string\",\n    \"name\": \"string\",\n    \"email\": \"user@example.com\",\n    \"phone\": \"string\",\n    \"tz\": \"string\",\n    \"locale\": \"string\",\n    \"props\": {\n      \"rank\": 2,\n      \"points\": 23.5,\n      \"segment\": \"casual\",\n      \"has_subscribed\": false\n    }\n  }\n]"
  }
] as Block[];

export default function ApisIdentifyUsersBatchPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
