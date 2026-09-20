// AUTO-GENERATED page — content for /product/Campaigns/display-rules
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/Campaigns/display-rules";
const TITLE = "Campaign Display Rules";
const DESCRIPTION = "Control when and how often users see your campaigns with display frequency, interaction limits, and scheduling.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Campaign Display Rules",
    "id": "campaign-display-rules"
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
        "v": "Campaign Display Rules let you control when and how often users see a campaign. Every campaign in EmbedCraft includes display rule settings that determine its frequency, interaction limits, and scheduling behavior. Configuring these correctly ensures users receive the right experience at the right time — without overexposure."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Display rules are configured during campaign creation under the"
      },
      {
        "t": "b",
        "v": "Campaign Display Rules"
      },
      {
        "t": "t",
        "v": "panel."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Display Frequency",
    "id": "display-frequency"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Display frequency determines how often a user can see the campaign. Select one of the following options:"
      }
    ]
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Frequency"
        }
      ],
      [
        {
          "t": "t",
          "v": "Behavior"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "b",
            "v": "Always"
          }
        ],
        [
          {
            "t": "t",
            "v": "Show to every eligible user every time the trigger condition is met"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Once"
          }
        ],
        [
          {
            "t": "t",
            "v": "Show to each user exactly once"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Hourly"
          }
        ],
        [
          {
            "t": "t",
            "v": "Show a set number of times per hour"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Daily"
          }
        ],
        [
          {
            "t": "t",
            "v": "Show a set number of times per day"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Weekly"
          }
        ],
        [
          {
            "t": "t",
            "v": "Show a set number of times per week"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Monthly"
          }
        ],
        [
          {
            "t": "t",
            "v": "Show a set number of times per month"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Custom"
          }
        ],
        [
          {
            "t": "t",
            "v": "Show X times within Y hours"
          }
        ]
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "For"
      },
      {
        "t": "b",
        "v": "Hourly"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "Daily"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "Weekly"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "Monthly"
      },
      {
        "t": "t",
        "v": ", and"
      },
      {
        "t": "b",
        "v": "Custom"
      },
      {
        "t": "t",
        "v": "frequencies, you specify the number of times the campaign should be shown within that period."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "For"
      },
      {
        "t": "b",
        "v": "Custom"
      },
      {
        "t": "t",
        "v": "frequency, you also specify the time window in hours. For example, \"Show"
      },
      {
        "t": "b",
        "v": "3"
      },
      {
        "t": "t",
        "v": "times within"
      },
      {
        "t": "b",
        "v": "72"
      },
      {
        "t": "t",
        "v": "hours\" means the user will see the campaign at most 3 times in any 72-hour window."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Examples",
    "id": "examples"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Onboarding tooltip"
        },
        {
          "t": "t",
          "v": ": Set to"
        },
        {
          "t": "b",
          "v": "Once"
        },
        {
          "t": "t",
          "v": "so users see the guidance only on their first visit."
        }
      ],
      [
        {
          "t": "b",
          "v": "Daily promotion"
        },
        {
          "t": "t",
          "v": ": Set to"
        },
        {
          "t": "b",
          "v": "Daily"
        },
        {
          "t": "t",
          "v": ","
        },
        {
          "t": "b",
          "v": "1"
        },
        {
          "t": "t",
          "v": "time — users see the offer once per day."
        }
      ],
      [
        {
          "t": "b",
          "v": "Persistent upsell"
        },
        {
          "t": "t",
          "v": ": Set to"
        },
        {
          "t": "b",
          "v": "Always"
        },
        {
          "t": "t",
          "v": "to show the campaign every time the user hits the trigger."
        }
      ],
      [
        {
          "t": "b",
          "v": "Limited campaign"
        },
        {
          "t": "t",
          "v": ": Set to"
        },
        {
          "t": "b",
          "v": "Custom"
        },
        {
          "t": "t",
          "v": ","
        },
        {
          "t": "b",
          "v": "5"
        },
        {
          "t": "t",
          "v": "times within"
        },
        {
          "t": "b",
          "v": "168"
        },
        {
          "t": "t",
          "v": "hours (one week) for controlled exposure."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Total Interaction Limit",
    "id": "total-interaction-limit"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Total Interaction Limit is available for"
      },
      {
        "t": "b",
        "v": "In-app Messages"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "In-app Nudges"
      },
      {
        "t": "t",
        "v": ", and"
      },
      {
        "t": "b",
        "v": "Spin the Wheel"
      },
      {
        "t": "t",
        "v": "campaigns only."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This setting caps how many times a user can interact with the campaign over its entire lifetime:"
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
          "v": "Unlimited"
        },
        {
          "t": "t",
          "v": ": The user can interact with the campaign as many times as it is shown (no cap)."
        }
      ],
      [
        {
          "t": "b",
          "v": "Limited to X times total"
        },
        {
          "t": "t",
          "v": ": The user can interact with the campaign at most X times. After reaching this limit, the campaign will no longer be shown to that user."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use this to prevent fatigue — for example, limiting a feedback survey to 2 total interactions ensures users aren't repeatedly asked after they've already responded."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Per-Session Limit",
    "id": "per-session-limit"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Per-Session Limit is available for"
      },
      {
        "t": "b",
        "v": "In-app Messages"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "b",
        "v": "In-app Nudges"
      },
      {
        "t": "t",
        "v": ", and"
      },
      {
        "t": "b",
        "v": "Spin the Wheel"
      },
      {
        "t": "t",
        "v": "campaigns only."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Enable the"
      },
      {
        "t": "b",
        "v": "Add session limit"
      },
      {
        "t": "t",
        "v": "toggle to restrict how many times the campaign appears within a single user session."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "When enabled, set the"
      },
      {
        "t": "b",
        "v": "maximum times per session"
      },
      {
        "t": "t",
        "v": "— for example, setting this to 1 ensures the campaign shows at most once per app session, even if the trigger condition is met multiple times."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This is useful for campaigns with an"
      },
      {
        "t": "b",
        "v": "Always"
      },
      {
        "t": "t",
        "v": "or high-frequency display setting where you still want to avoid showing the same campaign repeatedly in a single visit."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Override Global Limits",
    "id": "override-global-limits"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft applies global frequency and impression limits across all campaigns to protect the user experience. In some cases, you may want a specific campaign to bypass these limits — for example, a critical system announcement or a high-priority promotional campaign."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Enable the"
      },
      {
        "t": "b",
        "v": "Override global limits"
      },
      {
        "t": "t",
        "v": "toggle to allow this campaign to ignore the account-level frequency and impression caps."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This setting requires the"
      },
      {
        "t": "b",
        "v": "Override Limit"
      },
      {
        "t": "t",
        "v": "permission. Contact your account administrator if this option is not available."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Scheduling",
    "id": "scheduling"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "When publishing a campaign, you choose when it goes live:"
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
          "v": "Launch now"
        },
        {
          "t": "t",
          "v": ": The campaign becomes active immediately after publishing."
        }
      ],
      [
        {
          "t": "b",
          "v": "Schedule for later"
        },
        {
          "t": "t",
          "v": ": Set a specific start date and time for the campaign to activate."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You can also configure an optional"
      },
      {
        "t": "b",
        "v": "end time"
      },
      {
        "t": "t",
        "v": "to automatically deactivate the campaign at a specific date and time."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Scheduling Options",
    "id": "scheduling-options"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Option"
        }
      ],
      [
        {
          "t": "t",
          "v": "Description"
        }
      ]
    ],
    "rows": [
      [
        [
          {
            "t": "b",
            "v": "Launch now"
          }
        ],
        [
          {
            "t": "t",
            "v": "Campaign goes live immediately"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "Start time"
          }
        ],
        [
          {
            "t": "t",
            "v": "Campaign activates at the specified date and time"
          }
        ]
      ],
      [
        [
          {
            "t": "b",
            "v": "End time"
          }
        ],
        [
          {
            "t": "t",
            "v": "Campaign automatically deactivates at the specified date and time"
          }
        ]
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "If both start and end times are set, the campaign will only be active during that window."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Traffic Allocation",
    "id": "traffic-allocation"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Traffic allocation controls what percentage of your target audience will see the campaign. Use the slider or input field to set a value between 1% and 100%."
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
          "v": "100%"
        },
        {
          "t": "t",
          "v": ": All eligible users see the campaign."
        }
      ],
      [
        {
          "t": "b",
          "v": "50%"
        },
        {
          "t": "t",
          "v": ": Half of eligible users are randomly selected to see the campaign."
        }
      ],
      [
        {
          "t": "b",
          "v": "Lower values"
        },
        {
          "t": "t",
          "v": ": Useful for A/B testing or gradual rollouts."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "How Display Rules Work Together",
    "id": "how-display-rules-work-together"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Display rules are evaluated in the following order:"
      }
    ]
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "b",
          "v": "Scheduling"
        },
        {
          "t": "t",
          "v": "— Is the campaign currently active (within its start/end time window)?"
        }
      ],
      [
        {
          "t": "b",
          "v": "Traffic allocation"
        },
        {
          "t": "t",
          "v": "— Is this user part of the eligible percentage?"
        }
      ],
      [
        {
          "t": "b",
          "v": "Display frequency"
        },
        {
          "t": "t",
          "v": "— Has the user already seen the campaign the maximum number of times for this period?"
        }
      ],
      [
        {
          "t": "b",
          "v": "Per-session limit"
        },
        {
          "t": "t",
          "v": "— Has the campaign already been shown the maximum times this session?"
        }
      ],
      [
        {
          "t": "b",
          "v": "Total interaction limit"
        },
        {
          "t": "t",
          "v": "— Has the user already reached the lifetime interaction cap?"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "A campaign is only shown when all conditions are satisfied."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Best Practices",
    "id": "best-practices"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Start conservative"
        },
        {
          "t": "t",
          "v": ": Use"
        },
        {
          "t": "b",
          "v": "Once"
        },
        {
          "t": "t",
          "v": "or"
        },
        {
          "t": "b",
          "v": "Daily"
        },
        {
          "t": "t",
          "v": "frequency for new campaigns and increase if engagement data supports it."
        }
      ],
      [
        {
          "t": "b",
          "v": "Combine limits"
        },
        {
          "t": "t",
          "v": ": Pair a"
        },
        {
          "t": "b",
          "v": "Daily"
        },
        {
          "t": "t",
          "v": "frequency with a"
        },
        {
          "t": "b",
          "v": "per-session limit of 1"
        },
        {
          "t": "t",
          "v": "to ensure visibility without overwhelming users in a single session."
        }
      ],
      [
        {
          "t": "b",
          "v": "Use scheduling for time-sensitive campaigns"
        },
        {
          "t": "t",
          "v": ": Set start and end times for promotions, events, or seasonal content."
        }
      ],
      [
        {
          "t": "b",
          "v": "Test with traffic allocation"
        },
        {
          "t": "t",
          "v": ": Roll out to a small percentage first (e.g., 10%) to validate performance before going to 100%."
        }
      ],
      [
        {
          "t": "b",
          "v": "Reserve override sparingly"
        },
        {
          "t": "t",
          "v": ": Only use"
        },
        {
          "t": "b",
          "v": "Override global limits"
        },
        {
          "t": "t",
          "v": "for truly critical campaigns to maintain a good user experience across all campaigns."
        }
      ]
    ]
  }
] as Block[];

export default function ProductCampaignsDisplayRulesPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
