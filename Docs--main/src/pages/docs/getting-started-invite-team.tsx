// Manually authored page — content for /getting-started/invite-team
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/getting-started/invite-team";
const TITLE = 'Invite and Manage Team Members';
const DESCRIPTION = 'Invite teammates and manage permissions inside your EmbedCraft workspace.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Invite and Manage Team Members",
    "id": "invite-and-manage-team-members"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Inviting members",
    "id": "inviting-members"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Open Settings \u2192 Team and click Invite. Enter one or more email addresses, choose a role, and send the invitations."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Available roles",
    "id": "available-roles"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Owner \u2014 full control including billing and workspace deletion."
        }
      ],
      [
        {
          "t": "t",
          "v": "Admin \u2014 manage members, integrations and all campaigns."
        }
      ],
      [
        {
          "t": "t",
          "v": "Editor \u2014 create and edit campaigns, cohorts and flows."
        }
      ],
      [
        {
          "t": "t",
          "v": "Viewer \u2014 read-only access to dashboards and analytics."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Managing access",
    "id": "managing-access"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Roles can be changed at any time from the Team page. Removing a user immediately revokes their session tokens."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "SSO and SCIM",
    "id": "sso-and-scim"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Enterprise plans support SAML SSO and SCIM provisioning for automated lifecycle management."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
