// AUTO-GENERATED page — content for /product
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product";
const TITLE = "Introduction";
const DESCRIPTION = "Welcome to EmbedCraft";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Introduction",
    "id": "introduction"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Welcome to EmbedCraft",
    "id": "welcome-to-nudge"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft enables product and growth teams to create user experiences without depending on any developer bandwidth."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This documentation lays down the basic usage and integration of EmbedCraft into your application."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Key Concepts",
    "id": "key-concepts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft is built around a few core concepts that work together to help you create personalized, engaging user experiences. Understanding these building blocks will help you get the most out of the platform."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Users",
    "id": "users"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Users are the end users of your application. EmbedCraft identifies and tracks each user to personalize experiences and optimize outcomes like engagement and retention."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Events",
    "id": "events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Events capture user interactions—screen views, button clicks, purchases, and more. Use events to trigger campaigns, measure goals, and personalize experiences."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Cohorts",
    "id": "cohorts"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Cohorts let you group users based on shared behaviors or properties. Target specific segments with personalized campaigns instead of one-size-fits-all messaging."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Rewards",
    "id": "rewards"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Rewards incentivize user behavior—coupons, coins, badges, and more. Use them to drive conversions, increase engagement, and build loyalty."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Campaigns",
    "id": "campaigns"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Campaigns are the experiences you deliver to users—in-app messages, nudges, stories, challenges, streaks, referrals, and surveys."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Visual Builder",
    "id": "visual-builder"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Visual Builder is EmbedCraft's no-code design tool. Create beautiful interfaces, add widgets, configure actions, and personalize content—all without writing code."
      }
    ]
  }
] as Block[];

export default function ProductPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
