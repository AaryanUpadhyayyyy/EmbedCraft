// AUTO-GENERATED page — content for /integrations/cohorts-sync/csv-import
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/cohorts-sync/csv-import";
const TITLE = "CSV Import";
const DESCRIPTION = "Import cohorts to EmbedCraft using CSV files.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "CSV Import",
    "id": "csv-import"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Import cohorts to EmbedCraft using CSV files."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Setup Instructions",
    "id": "setup-instructions"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Step 1: Create Cohort",
    "id": "step-1-create-cohort"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Navigate to the"
      },
      {
        "t": "b",
        "v": "Cohorts"
      },
      {
        "t": "t",
        "v": "page on the EmbedCraft Dashboard. Click on the"
      },
      {
        "t": "b",
        "v": "Create New Cohort"
      },
      {
        "t": "t",
        "v": "button."
      }
    ]
  },
  {
    "type": "image",
    "src": "./CSV Import _ Nudge_files/create-new-cohort.png",
    "alt": "Create a new cohort"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Step 2: Upload CSV",
    "id": "step-2-upload-csv"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Select"
      },
      {
        "t": "b",
        "v": "Upload CSV"
      },
      {
        "t": "t",
        "v": "as the cohort source. Provide a name and description for your cohort."
      }
    ]
  },
  {
    "type": "image",
    "src": "./CSV Import _ Nudge_files/create-csv-cohort.png",
    "alt": "Fill the cohort details"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Upload the CSV file containing the list of users."
      }
    ]
  },
  {
    "type": "image",
    "src": "./CSV Import _ Nudge_files/upload-csv-cohort.png",
    "alt": "upload the csv file"
  },
  {
    "type": "code",
    "lang": "csv",
    "code": "iduser_123user_234user_897"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "sample csv file, with header"
        },
        {
          "t": "c",
          "v": "id"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft requires a unique identifier for each user. Ensure this identifier is in a column with the header"
      },
      {
        "t": "c",
        "v": "id"
      },
      {
        "t": "t",
        "v": "."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Viewing Your Cohorts",
    "id": "viewing-your-cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "After importing your CSV, the cohort will be immediately available in the"
      },
      {
        "t": "b",
        "v": "Users"
      },
      {
        "t": "t",
        "v": "section of your EmbedCraft dashboard."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Your CSV import is now complete. You can start using your imported cohorts in EmbedCraft."
      }
    ]
  }
] as Block[];

export default function IntegrationsCohortsSyncCsvImportPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
