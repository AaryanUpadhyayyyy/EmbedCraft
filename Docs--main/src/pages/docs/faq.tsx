// Manually authored page — content for /faq
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/faq";
const TITLE = 'FAQ';
const DESCRIPTION = 'Answers to the most common questions about EmbedCraft.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "FAQ",
    "id": "faq"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Does EmbedCraft require app store releases for changes?",
    "id": "does-embedcraft-require-app-store-releases-for-changes"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "No. All campaigns, flows and content updates are delivered over the air \u2014 no resubmission required."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "What platforms are supported?",
    "id": "what-platforms-are-supported"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Web (React, Vue, vanilla JS), iOS (Swift), Android (Kotlin/Java), Flutter and React Native."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How is data stored?",
    "id": "how-is-data-stored"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "All data is encrypted at rest and in transit, and is hosted in SOC 2 Type II audited data centers in the region you select."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Can I export my data?",
    "id": "can-i-export-my-data"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Yes \u2014 every workspace can export events, users and campaign analytics via CSV or the Export API."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Is there a free tier?",
    "id": "is-there-a-free-tier"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft offers a free developer tier capped at 10,000 monthly active users."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How do I get support?",
    "id": "how-do-i-get-support"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Reach out via the in-product chat or email support@embedcraft.com \u2014 typical response time is under 4 hours on business days."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
