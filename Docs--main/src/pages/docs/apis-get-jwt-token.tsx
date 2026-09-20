// AUTO-GENERATED page — content for /apis/get-jwt-token
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/get-jwt-token";
const TITLE = "Get JWT token";
const DESCRIPTION = "Retrieve a signed Bearer token (JWT) for client authentication.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Get JWT token",
    "id": "get-jwt-token"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "GET https://main-api.embedcraft.com/api/clients/jwt/token"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Retrieve a signed Bearer token (JWT) for client authentication."
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
    "type": "heading",
    "level": 3,
    "text": "Query Parameters",
    "id": "query-parameters"
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
        "v": ">= 30"
      },
      {
        "t": "t",
        "v": "and"
      },
      {
        "t": "c",
        "v": "<= 1440"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Duration in minutes for which the token is valid"
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
        "v": "External ID of the user to associate with the token"
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
        "v": "Successful response with JWT token"
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
        "v": "Signed JWT bearer token"
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
    "code": "{  \"token\": \"eyJhbGciOiJIUzI1NiIsInR5cCI6...\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Sample JWT token response"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"token\": \"eyJhbGciOiJIUzI1NiIsInR5cCI6...\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Invalid parameters"
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
    "code": "curl -L 'https://main-api.embedcraft.com/api/clients/jwt/token' \\-H 'Accept: application/json' \\-H 'apikey: <apikey>'"
  }
] as Block[];

export default function ApisGetJwtTokenPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
