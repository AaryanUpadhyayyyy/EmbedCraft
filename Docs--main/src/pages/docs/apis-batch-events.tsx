// AUTO-GENERATED page — content for /apis/batch-events
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/batch-events";
const TITLE = "Batch events";
const DESCRIPTION = "Ingest a batch of events in a single request for efficiency.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Batch events",
    "id": "batch-events"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "POST https://main-api.embedcraft.com/api/integration/events/batch"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Ingest a batch of events in a single request for efficiency."
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
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Batch event ingestion doesn't update any states/counters for the given user. This api should only be used to ingest user events for only analytics purposes or cohort creation. These events won't effect any task/campaign completions for the user"
        }
      ],
      [
        {
          "t": "t",
          "v": "This can also ingest events for unidentified users. Such users will be created in the system with a unique ID during event ingestion."
        }
      ]
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
          "v": "max 1000"
        },
        {
          "t": "t",
          "v": "items."
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
          "v": "1200 requests per minute per IP address"
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
        "v": "Timestamp when the event occurred"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Event properties (property names will be converted to lowercase)"
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
          "v": "413"
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
        "v": "Batch events processed successfully"
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
    "type": "list",
    "ordered": false,
    "items": []
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Successful batch processing"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Bad request - validation errors or invalid batch data"
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
          "v": "batchTooLarge"
        }
      ],
      [
        {
          "t": "t",
          "v": "invalidEvent"
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
        "v": "Batch size exceeded"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"message\": \"Maximum 1000 events allowed per batch\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Invalid event data"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"message\": \"Invalid event format in batch\"}"
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
        "v": "Payload too large - batch request exceeds size limits"
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
    "code": "curl -L 'https://main-api.embedcraft.com/api/integration/events/batch' \\-H 'Content-Type: application/json' \\-H 'Accept: application/json' \\-H 'apikey: <apikey>' \\-d '[  {    \"ext_id\": \"user_123\",    \"name\": \"purchase_completed\",    \"occurred_at\": \"2024-04-30T08:54:22.666Z\",    \"props\": {      \"amount\": 100,      \"payment_method\": \"credit_card\",      \"is_premium\": true    }  }]'"
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
          "v": "batchRequest"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "[\n  {\n    \"ext_id\": \"user_123\",\n    \"name\": \"purchase_completed\",\n    \"occurred_at\": \"2024-04-30T08:54:22.666Z\",\n    \"props\": {\n      \"amount\": 100,\n      \"payment_method\": \"credit_card\",\n      \"is_premium\": true\n    }\n  }\n]"
  }
] as Block[];

export default function ApisBatchEventsPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
