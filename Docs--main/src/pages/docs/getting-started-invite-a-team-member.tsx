import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/getting-started/invite-a-team-member";
const TITLE = "Invite and Manage Team Members";
const DESCRIPTION = "Invite and Manage Team Members for EmbedCraft.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Invite and Manage Team Members",
    "id": "invite-and-manage-team-members"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Invite and Manage Team Members for EmbedCraft."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Invite members",
    "id": "invite-members"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Open workspace settings and choose Team Members."
        }
      ],
      [
        {
          "t": "t",
          "v": "Enter the teammate email address."
        }
      ],
      [
        {
          "t": "t",
          "v": "Assign the least-privileged role required for their work."
        }
      ],
      [
        {
          "t": "t",
          "v": "Send the invite and ask them to accept from their inbox."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Role guidance",
    "id": "role-guidance"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Admins should manage billing, keys, and workspace settings; editors should build campaigns; viewers should only review reports."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
