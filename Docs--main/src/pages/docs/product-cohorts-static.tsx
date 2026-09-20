// AUTO-GENERATED page — content for /product/Cohorts/static
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Cohorts/static";
const TITLE = "Static Cohorts";
const DESCRIPTION = "Upload a CSV to create a fixed group of users for targeting.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Static Cohorts",
    "id": "static-cohorts"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Overview",
    "id": "overview"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Static Cohorts let you define a fixed group of users by uploading a CSV file. This is ideal when you already know which users to target—like exporting a list from your CRM, analytics platform, or internal tool."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use Static Cohorts to:"
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
          "v": "Target users from a past campaign Reports"
        }
      ],
      [
        {
          "t": "t",
          "v": "Launch one-time campaigns for curated user groups"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "All you need is a CSV with user IDs. We’ll handle the rest."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Format of CSV",
    "id": "format-of-csv"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To create a Static Cohort, upload a CSV file that contains a list of user identifiers. This is how we match the users in your upload with those tracked via the EmbedCraft SDK."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Your CSV must include a single column named"
      },
      {
        "t": "c",
        "v": "id"
      },
      {
        "t": "t",
        "v": ", which represents the unique ID you use to identify users in your system."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Example:",
    "id": "example"
  },
  {
    "type": "code",
    "lang": "csv",
    "code": "iduser_123user_456user_789"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How to Create a static cohort",
    "id": "how-to-create-a-static-cohort"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Watch this video for a step-by-step walkthrough on uploading a CSV to create your cohort:"
      }
    ]
  }
] as Block[];

export default function ProductCohortsStaticPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
