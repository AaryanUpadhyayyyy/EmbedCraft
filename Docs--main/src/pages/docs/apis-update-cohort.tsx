// Manually authored page — content for /apis/update-cohort
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/update-cohort";
const TITLE = 'Update cohort';
const DESCRIPTION = 'Update an existing static cohort by adding or removing user IDs.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Update cohort",
    "id": "update-cohort"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Endpoint",
    "id": "endpoint"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "PATCH https://api.embedcraft.com/v1/cohorts/{cohort_id}"
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Headers",
    "id": "headers"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Authorization: Bearer YOUR_API_KEY"
        }
      ],
      [
        {
          "t": "t",
          "v": "Content-Type: application/json"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Request body",
    "id": "request-body"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Send an action (add or remove) and a list of user_ids."
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{\n  \"action\": \"add\",\n  \"user_ids\": [\"user_123\", \"user_456\"]\n}"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Example",
    "id": "example"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Update a cohort with cURL:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "bash",
    "code": "curl -X PATCH https://api.embedcraft.com/v1/cohorts/cht_8a2 \\\n  -H 'Authorization: Bearer $EMBEDCRAFT_API_KEY' \\\n  -H 'Content-Type: application/json' \\\n  -d '{\"action\":\"add\",\"user_ids\":[\"user_123\"]}'"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Response",
    "id": "response"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Returns the updated cohort document with the new member count and last_updated_at timestamp."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
