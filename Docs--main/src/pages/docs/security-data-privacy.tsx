// AUTO-GENERATED page — content for /security/data-privacy
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/security/data-privacy";
const TITLE = "Data and Privacy";
const DESCRIPTION = "You have full control over the data you send to EmbedCraft. Here, we share best practices for tracking in a privacy-friendly way.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Data and Privacy",
    "id": "data-and-privacy"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You have full control over the data you send to EmbedCraft. Here, we share best practices for tracking in a privacy-friendly way."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Security Overview",
    "id": "security-overview"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Our data collection endpoints use TLS 1.3 encryption protocols, secured with SHA-384 and ECDSA signature algorithms. This ensures that all devices, regardless of their support level, can access our endpoints securely, with TLS 1.3 provided to devices that support it."
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
          "v": "We use encryption at rest for customer data."
        }
      ],
      [
        {
          "t": "t",
          "v": "We have data replicated across 3 nodes for redundancy and faster access."
        }
      ],
      [
        {
          "t": "t",
          "v": "All data stays within India in"
        },
        {
          "t": "c",
          "v": "ap-south-1"
        },
        {
          "t": "t",
          "v": "region."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To enhance the security of our application, we have implemented the following measures:"
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
          "v": "SQL Injection Prevention: Advanced safeguards to protect against SQL injection attacks."
        }
      ],
      [
        {
          "t": "t",
          "v": "Input Validation: We defend against known bad inputs and block malicious requests."
        }
      ],
      [
        {
          "t": "t",
          "v": "IP Address Monitoring: We block requests from compromised or suspicious IP addresses."
        }
      ],
      [
        {
          "t": "t",
          "v": "Linux Environment Protections: We have specific safeguards in place to secure our infrastructure from threats targeting Linux environments."
        }
      ],
      [
        {
          "t": "t",
          "v": "Rate Limiting: We limit the number of requests from a single IP address to prevent denial-of-service (DoS) attacks. Each IP is restricted to a maximum of 2000 requests within a five-minute period."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "These measures work together to provide strong protection for our application and data, keeping them secure from a wide range of threats."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Hosting and Data Compliance",
    "id": "hosting-and-data-compliance"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft leverages industry-leading platforms to ensure the security and scalability of our data infrastructure:"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Amazon Web Services (AWS):"
      },
      {
        "t": "t",
        "v": "AWS is our primary hosting provider, offering data centers that are fully compliant with a wide range of certifications, including those required for finance, healthcare, and government data. AWS manages physical security, allowing us to focus on application and data security. You can find more information about AWS compliance"
      },
      {
        "t": "t",
        "v": "here"
      },
      {
        "t": "t",
        "v": "."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Scylla:"
      },
      {
        "t": "t",
        "v": "We use Scylla for high-performance, scalable data storage. Scylla’s architecture is designed for maximum efficiency and reliability, ensuring that our data operations meet rigorous standards. Scylla is compliant with industry standards, providing a robust foundation for secure data handling. You can find more information about Scylla's compliance"
      },
      {
        "t": "t",
        "v": "here"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "ClickHouse:"
      },
      {
        "t": "t",
        "v": "For data analytics, we rely on ClickHouse, a fast open-source columnar database management system. ClickHouse is optimized for real-time queries, enabling us to provide detailed insights while adhering to stringent compliance requirements. Learn more about ClickHouse's compliance"
      },
      {
        "t": "t",
        "v": "here"
      },
      {
        "t": "t",
        "v": "."
      }
    ]
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [],
      [],
      []
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "These platforms are chosen for their security, performance, and compliance, ensuring that your data is handled with the utmost care."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "User Data",
    "id": "user-data"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft does not require any personally identifiable information (PII) such as email addresses or phone numbers. Instead, EmbedCraft only needs a unique user ID to link events to a specific user. You have the flexibility to choose this ID and determine how it is sent to EmbedCraft."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "If you prefer not to use any personalization or targeting features within EmbedCraft, you can simply send a unique identifier for your users without including any additional personal data."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Other Data Categories",
    "id": "other-data-categories"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The EmbedCraft SDK collects certain data by default to enhance the user experience. This data is not personal and is unrelated to your application’s content."
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
          "v": "Device Info: Brand, model, device ID"
        }
      ],
      [
        {
          "t": "t",
          "v": "Screen Info: Screen size, device type, screen orientation"
        }
      ],
      [
        {
          "t": "t",
          "v": "App Info: App version"
        }
      ],
      [
        {
          "t": "t",
          "v": "System Info: OS type and version, language"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Screen information is crucial for scaling the UI across different mobile screens. Without this data, the UI will not be responsive."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Why We Track This Data",
    "id": "why-we-track-this-data"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "b",
          "v": "Audience Filtering and Targeting:"
        },
        {
          "t": "t",
          "v": "To personalize user experiences in the EmbedCraft dashboard."
        }
      ],
      [
        {
          "t": "b",
          "v": "Analytics:"
        },
        {
          "t": "t",
          "v": "To provide detailed insights into user behavior and app performance."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Opting Out",
    "id": "opting-out"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "If you prefer not to send any of this data to EmbedCraft, you can opt out. You can reach out to your POC at EmbedCraft, and we will guide you through the process."
      }
    ]
  }
] as Block[];

export default function SecurityDataPrivacyPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
