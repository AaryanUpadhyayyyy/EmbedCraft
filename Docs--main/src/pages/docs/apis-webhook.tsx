// AUTO-GENERATED page — content for /apis/webhook
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/apis/webhook";
const TITLE = "Webhook";
const DESCRIPTION = "Webhook events sent by EmbedCraft to notify your application.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Webhook",
    "id": "webhook"
  },
  {
    "type": "code",
    "lang": "text",
    "code": "Webhook "
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Webhook events sent by EmbedCraft to notify your application."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Webhook Events",
    "id": "webhook-events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Our system currently supports the following webhook events:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "c",
          "v": "reward.earned"
        },
        {
          "t": "t",
          "v": ": Triggered when a user gets a reward"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Setting up Webhooks",
    "id": "setting-up-webhooks"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure webhooks in your EmbedCraft dashboard:"
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
          "v": "Add your endpoint URL"
        }
      ],
      [
        {
          "t": "t",
          "v": "Add your secret for request signing"
        }
      ],
      [
        {
          "t": "t",
          "v": "Select event types to receive"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Verifying Webhook Signatures",
    "id": "verifying-webhook-signatures"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Each request to your webhook URL will include a signature in the"
      },
      {
        "t": "c",
        "v": "x-nudge-signature"
      },
      {
        "t": "t",
        "v": "header. Follow these steps to verify the signature:"
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
          "v": "Generate the Hash signature of the request body using your"
        },
        {
          "t": "c",
          "v": "secret"
        },
        {
          "t": "t",
          "v": "and HMAC with sha256."
        }
      ],
      [
        {
          "t": "t",
          "v": "Compare the generated signature with the value in the"
        },
        {
          "t": "c",
          "v": "x-nudge-signature"
        },
        {
          "t": "t",
          "v": "header."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Node.js Code Snippet for Verification",
    "id": "node-js-code-snippet-for-verification"
  },
  {
    "type": "code",
    "lang": "javascript",
    "code": "const crypto = require('crypto');const verifySignature = (bodyString, signature, secretKey) => {\tconst hmac = crypto.createHmac('sha256', secretKey).update(bodyString).digest('hex');\treturn hmac === signature;};// Example usage const bodyString = JSON.stringify(request.body); const signature = request.headers[\"x-nudge-signature\"]; const secretKey = \"terces\"; // Your secret keyif (verifySignature(bodyString, signature, secretKey)) {\tresponse.status(200).send('Signature verified');} else {\tresponse.status(403).send('Invalid signature');}"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Idempotency",
    "id": "idempotency"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "There could be scenarios where your endpoint might receive the same webhook event multiple times. This is expected behavior based on the webhook design.\nTo handle duplicate webhook events:"
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
          "v": "You can identify duplicate webhooks using the"
        },
        {
          "t": "c",
          "v": "x-idempotent-key"
        },
        {
          "t": "t",
          "v": "header. The value for this header is unique per event."
        }
      ],
      [
        {
          "t": "t",
          "v": "Check the value of"
        },
        {
          "t": "c",
          "v": "x-idempotent-key"
        },
        {
          "t": "t",
          "v": "in the webhook request header."
        }
      ],
      [
        {
          "t": "t",
          "v": "Verify if an event with the same header is processed at your end."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Limits",
    "id": "limits"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Max webhook timeout:"
        },
        {
          "t": "t",
          "v": "3,000 ms"
        }
      ],
      [
        {
          "t": "b",
          "v": "Retry Logic:"
        },
        {
          "t": "t",
          "v": "Messages are retried up to 3 times"
        }
      ],
      [
        {
          "t": "b",
          "v": "Max payload size:"
        },
        {
          "t": "t",
          "v": "4 KB"
        }
      ]
    ]
  },
  {
    "type": "_bq_open"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "📘 Important > > If your API doesn't respond within 3 seconds, we will consider it as failed and retry"
      }
    ]
  },
  {
    "type": "_bq_close"
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
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Webhook payload sent to your endpoint"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Unique identifier key for each event"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Signature of the request body for verification"
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": []
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
      ],
      [
        {
          "t": "t",
          "v": "CoinReward"
        }
      ],
      [
        {
          "t": "t",
          "v": "CouponReward"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Type of webhook event"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "t",
        "v": "["
      },
      {
        "t": "c",
        "v": "reward.earned"
      },
      {
        "t": "t",
        "v": "]"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Unique reward instance ID"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Reward configuration ID"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Name of the reward"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft user ID"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "External user ID"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Campaign/task ID"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Reward quantity"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": ">= 1"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Reward creation timestamp"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Coin reward details"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": ">= 0"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Coupon reward details"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "c",
        "v": ">= 0"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "1 = Flat Discount, 2 = Percentage Discount"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Possible values:"
      },
      {
        "t": "t",
        "v": "["
      },
      {
        "t": "c",
        "v": "1"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "c",
        "v": "2"
      },
      {
        "t": "t",
        "v": "]"
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
          "v": "Array ["
        }
      ],
      [
        {
          "t": "t",
          "v": "]"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"event\": \"reward.earned\",  \"payload\": {    \"rewards\": [      {        \"id\": \"string\",        \"reward_id\": \"string\",        \"reward_name\": \"string\",        \"nudge_id\": \"string\",        \"ext_id\": \"string\",        \"task_id\": \"string\",        \"quantity\": 0,        \"created_at\": \"2024-07-29T15:51:28.071Z\",        \"coin\": {          \"value\": 0        },        \"coupon\": {          \"code\": \"string\",          \"discount\": 0,          \"type\": 1,          \"expiry_at\": \"2024-07-29T15:51:28.071Z\"        }      }    ]  }}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Coin Reward Event"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"event\": \"reward.earned\",  \"payload\": {    \"rewards\": [      {        \"id\": \"fd9dd612-5387-42f7-aecb-d64e4ce657c0\",        \"reward_id\": \"845cdfaa-81a9-42e1-9755-c11df61823d4\",        \"reward_name\": \"10 Rs Off\",        \"nudge_id\": \"a4b43bf8-4972-44b3-a9bd-3370ebf14ed9\",        \"ext_id\": \"c4bb3bf8-45672-44b3-a9bd-3370ebf15rrgd\",        \"task_id\": \"bfrb3bf8-4972-44b3-78bd-3370ebf43ed9\",        \"quantity\": 10,        \"coin\": {          \"value\": 1        },        \"created_at\": \"2024-07-04T12:53:58.129Z\"      }    ]  }}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Coupon Reward Example"
      }
    ]
  },
  {
    "type": "code",
    "lang": "json",
    "code": "{  \"event\": \"reward.earned\",  \"payload\": {    \"rewards\": [      {        \"id\": \"fd9dd612-5387-42f7-aecb-d64e4ce657c0\",        \"reward_id\": \"845cdfaa-81a9-42e1-9755-c11df61823d4\",        \"reward_name\": \"10 Rs Off\",        \"nudge_id\": \"a4b43bf8-4972-44b3-a9bd-3370ebf14ed9\",        \"ext_id\": \"c4bb3bf8-45672-44b3-a9bd-3370ebf15rrgd\",        \"task_id\": \"bfrb3bf8-4972-44b3-78bd-3370ebf43ed9\",        \"quantity\": 10,        \"coupon\": {          \"code\": \"ABCD\",          \"discount\": 20,          \"type\": 1,          \"expiry_at\": null        },        \"created_at\": \"2024-07-04T12:53:58.129Z\"      }    ]  }}"
  }
] as Block[];

export default function ApisWebhookPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
