// AUTO-GENERATED page — content for /apis/campaign-csv-report
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/campaign-csv-report";
const TITLE = "Campaign CSV Report";
const DESCRIPTION = "Retrieve the CSV report file for users associated with a specific campaign.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Campaign CSV Report",
    "id": "campaign-csv-report"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "GET https://main-api.embedcraft.com/api/reports/:taskId/users/file"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Retrieve the CSV report file for users associated with a specific campaign."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "IMPORTANT"
      },
      {
        "t": "t",
        "v": ": This endpoint needs to be called in a polling manner until the file is ready. First, call the endpoint to initiate report generation. The report will be generated asynchronously. You can then poll the same endpoint to check if the report is ready for download. Once the report is ready, the response will contain a signed URL to download the CSV file."
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
      ],
      [
        {
          "t": "b",
          "v": "Organization based:"
        },
        {
          "t": "t",
          "v": "5 requests per 5 minutes per organization"
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
    "text": "Path Parameters",
    "id": "path-parameters"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "ID of the campaign/task"
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
    "level": 3,
    "text": "Query Parameters",
    "id": "query-parameters"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Start date for filtering users (optional)"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "End date for filtering users (optional)"
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
        "v": "Successful response"
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
        "v": "Message indicating report status"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "URL to download the generated report file"
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
    "code": "{  \"message\": \"Report generation in progress.\",  \"file\": \"string\"}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Bad request - invalid task ID or report generation error"
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
        "v": "Error message regarding report generation"
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
    "code": "curl -L 'https://main-api.embedcraft.com/api/reports/:taskId/users/file' \\-H 'Accept: application/json' \\-H 'apikey: <apikey>'"
  }
] as Block[];

export default function ApisCampaignCsvReportPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
