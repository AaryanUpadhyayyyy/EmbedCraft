// AUTO-GENERATED page — content for /product/rewards/reward-delivery
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/rewards/reward-delivery";
const TITLE = "Creating Reward Delivery";
const DESCRIPTION = "Understand Rewards Delivery";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Reward Delivery",
    "id": "reward-delivery"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Once you've created a reward, the next step is to decide"
      },
      {
        "t": "b",
        "v": "how"
      },
      {
        "t": "t",
        "v": "it gets delivered to users. EmbedCraft gives you complete flexibility to define the reward delivery experience — from the type of reward (Coins or Coupons) to the UI it appears in."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How to Configure Reward Delivery",
    "id": "how-to-configure-reward-delivery"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "b",
          "v": "Go to the Rewards section"
        },
        {
          "t": "t",
          "v": "in the dashboard."
        }
      ],
      [
        {
          "t": "t",
          "v": "Select the reward you want to deliver."
        }
      ],
      [
        {
          "t": "t",
          "v": "Click on the"
        },
        {
          "t": "b",
          "v": "“Delivery”"
        },
        {
          "t": "t",
          "v": "tab."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Choose the Reward Type",
    "id": "choose-the-reward-type"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You’ll be asked to confirm the type of reward you're delivering:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Coupon"
        },
        {
          "t": "t",
          "v": ": Discount codes or promo offers."
        }
      ],
      [
        {
          "t": "b",
          "v": "Coin"
        },
        {
          "t": "t",
          "v": ": Virtual currency with a specified value and image."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Select the Delivery UI",
    "id": "select-the-delivery-ui"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You can choose the user interface where the reward will appear:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Bottom Sheet"
        },
        {
          "t": "t",
          "v": ": Slides up from the bottom of the screen."
        }
      ],
      [
        {
          "t": "b",
          "v": "Modal"
        },
        {
          "t": "t",
          "v": ": Centered popup, great for high-visibility rewards."
        }
      ],
      [
        {
          "t": "b",
          "v": "Full Page"
        },
        {
          "t": "t",
          "v": ": Dedicated screen for showcasing large or complex rewards."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Using Scratch Cards (Optional)",
    "id": "using-scratch-cards-optional"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Want to make it more interactive?"
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
          "v": "You can add a"
        },
        {
          "t": "b",
          "v": "Scratch Card"
        },
        {
          "t": "t",
          "v": "component using the"
        },
        {
          "t": "b",
          "v": "Visual Builder"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "t",
          "v": "Attach the reward behind the scratch layer to create a reveal moment."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Dynamic Reward Content",
    "id": "dynamic-reward-content"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To personalize the reward message, use reward-specific placeholders with Templating"
      }
    ]
  }
] as Block[];

export default function ProductRewardsRewardDeliveryPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
