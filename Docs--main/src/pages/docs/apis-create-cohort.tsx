// AUTO-GENERATED page — content for /apis/create-cohort
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/create-cohort";
const TITLE = "Create cohort";
const DESCRIPTION = "Create a new external cohort.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Create cohort",
    "id": "create-cohort"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "POST https://main-api.embedcraft.com/api/cohorts/external"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Create a new external cohort."
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
    "text": "Notes",
    "id": "notes"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Each cohort name must be unique"
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
      ],
      [
        {
          "t": "b",
          "v": "Organization based:"
        },
        {
          "t": "t",
          "v": "10 requests per minute per organization"
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
        "v": "Name of the cohort (must be unique)"
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
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Description of the cohort"
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
        "v": "<= 500 characters"
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
        "v": "Cohort created successfully"
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
    "code": "{  \"message\": \"Operation completed successfully\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Validation error or duplicate cohort name"
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
    "code": "curl -L 'https://main-api.embedcraft.com/api/cohorts/external' \\-H 'Content-Type: application/json' \\-H 'Accept: application/json' \\-H 'apikey: <apikey>' \\-d '{  \"name\": \"Cohort 1\",  \"descr\": \"My nudge cohort\"}'"
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
    "code": "{\n  \"name\": \"Cohort 1\",\n  \"descr\": \"My nudge cohort\"\n}"
  }
] as Block[];

export default function ApisCreateCohortPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
