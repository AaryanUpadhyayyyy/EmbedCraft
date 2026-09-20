// AUTO-GENERATED page — content for /product/Campaigns
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Campaigns";
const TITLE = "Campaigns";
const DESCRIPTION = "Create Campaigns with EmbedCraft";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Campaigns",
    "id": "campaigns"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Campaigns are the core of how you deliver personalized user experiences with EmbedCraft. Whether you're driving engagement, conversions, or retention, the EmbedCraft Dashboard allows you to build, launch, and measure high-performing campaigns — all without writing code."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Types of Campaigns",
    "id": "types-of-campaigns"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft supports a wide variety of campaign formats tailored to different stages of the user journey:"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "In-App Messages"
      },
      {
        "t": "t",
        "v": ": Deliver contextual messages inside your app through bottom sheets, modals, floaters, or full-screen takeovers. Ideal for promotions, updates, onboarding flows, and more."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "In-App Nudges"
      },
      {
        "t": "t",
        "v": ": Guide users with lightweight nudges such as tooltips, spotlights, and coachmarks. These are great for feature walkthroughs, onboarding guidance, and drawing attention to key UI elements."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Stories"
      },
      {
        "t": "t",
        "v": ": Create immersive, Instagram-style stories directly within your app. Combine videos, images, GIFs, and text to build swipeable content that drives engagement and storytelling."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Challenges"
      },
      {
        "t": "t",
        "v": ": Encourage users to complete tasks in exchange for rewards. You can customize the challenge UI—from inline embeds to dedicated pages—and track progress dynamically."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Streaks"
      },
      {
        "t": "t",
        "v": ": Motivate users to build habits by rewarding consistent behavior. Streak campaigns help reinforce actions like daily logins, workouts, or content consumption."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Referrals"
      },
      {
        "t": "t",
        "v": ": Launch multi-step referral programs that reward both the referrer and referee. Design flexible flows that work across different platforms and customize the reward logic."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Surveys"
      },
      {
        "t": "t",
        "v": ": Collect feedback through customizable surveys that support NPS, CSAT, and multiple question types. Add conditional logic and personalize questions based on user behavior."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Campaign Display Rules",
    "id": "campaign-display-rules"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Every campaign includes configurable"
      },
      {
        "t": "b",
        "v": "display rules"
      },
      {
        "t": "t",
        "v": "that control when and how often users see it. You can set display frequency (once, daily, weekly, custom, etc.), total interaction limits, per-session caps, scheduling windows, and traffic allocation. Learn more in the"
      },
      {
        "t": "t",
        "v": "Campaign Display Rules"
      },
      {
        "t": "t",
        "v": "documentation."
      }
    ]
  }
] as Block[];

export default function ProductCampaignsPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
