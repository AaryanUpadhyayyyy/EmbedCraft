// AUTO-GENERATED page — content for /apis/apply-referral
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/apply-referral";
const TITLE = "Apply referral";
const DESCRIPTION = "Apply referrals for a user via your backend system.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Apply referral",
    "id": "apply-referral"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "POST https://main-api.embedcraft.com/api/track/referral"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Apply referrals for a user via your backend system."
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
        "v": "UUID of the user receiving the referral (must be identified first)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Session ID of the user (optional)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Referral code used. Optional for lead-added flows."
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
        "v": "<= 50 characters"
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
        "v": "Successful response with referral data"
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
        "v": "UUIDv4 of the referrer"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Name of the referrer"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Boolean properties applied to the referred user"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Text properties applied to the referred user"
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
    "code": "{  \"ref_by\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\",  \"ref_by_name\": \"string\",  \"props_bool\": {},  \"props_text\": {}}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Successful referral response"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"ref_by\": \"98dcec9a-b0c2-4d90-a82a-7351bd6f9f28\",  \"ref_by_name\": \"Alice Doe\",  \"props_bool\": {    \"referred\": true  },  \"props_text\": {    \"ref_channel\": \"social\"  }}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Bad request - validation, referral, or user errors"
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
          "v": "validationFailed"
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
          "v": "notIdentified"
        }
      ],
      [
        {
          "t": "t",
          "v": "noReferral"
        }
      ],
      [
        {
          "t": "t",
          "v": "maxReferrals"
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
    "code": "{  \"message\": \"user is not identified yet\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Referral data missing"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"message\": \"referral code and lead both unavailable\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Referrer limit reached"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"message\": \"Referrer has reached the maximum referral limit\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Unauthorized - missing or invalid API key"
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
    "code": "curl -L 'https://main-api.embedcraft.com/api/track/referral' \\-H 'Content-Type: application/json' \\-H 'Accept: application/json' \\-H 'apikey: <apikey>' \\-d '{  \"uid\": \"2762ff09-d7f0-4288-b25d-e5ffe5434724\",  \"session_id\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\",  \"referral_code\": \"nudgeQWE12\"}'"
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
    "code": "{\n  \"uid\": \"2762ff09-d7f0-4288-b25d-e5ffe5434724\",\n  \"session_id\": \"3fa85f64-5717-4562-b3fc-2c963f66afa6\",\n  \"referral_code\": \"nudgeQWE12\"\n}"
  }
] as Block[];

export default function ApisApplyReferralPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
