// AUTO-GENERATED page — content for /quickstart/banner-integration
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/quickstart/banner-integration";
const TITLE = "Embedding Banners";
const DESCRIPTION = "Banners (also known as Embedded Widgets) are native UI components that live directly within your application&#39;s layout. Unlike full-screen modals or floating popups which overlay content, banners flow naturally with your app&#39;s hierarchy.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Embedding Banners",
    "id": "embedding-banners"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Banners"
      },
      {
        "t": "t",
        "v": "(also known as Embedded Widgets) are native UI components that live directly within your application's layout. Unlike full-screen modals or floating popups which overlay content, banners flow naturally with your app's hierarchy."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "They are ideal for:"
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
          "v": "Announcements"
        },
        {
          "t": "t",
          "v": ": New feature alerts, maintenance notices, or updates."
        }
      ],
      [
        {
          "t": "b",
          "v": "Promotions"
        },
        {
          "t": "t",
          "v": ": Personalized offers and cross-selling opportunities."
        }
      ],
      [
        {
          "t": "b",
          "v": "Dynamic Content"
        },
        {
          "t": "t",
          "v": ": Cards that can be updated remotely without an app release."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This guide explains how to embed EmbedCraft Banners into your application."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Prerequisites",
    "id": "prerequisites"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Before embedding banners, ensure you have:"
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
          "v": "Installed the EmbedCraft SDK"
        },
        {
          "t": "t",
          "v": "("
        },
        {
          "t": "t",
          "v": "Installation Guide"
        },
        {
          "t": "t",
          "v": ")."
        }
      ],
      [
        {
          "t": "b",
          "v": "Initialized the SDK"
        },
        {
          "t": "t",
          "v": "("
        },
        {
          "t": "t",
          "v": "Initialization Guide"
        },
        {
          "t": "t",
          "v": ")."
        }
      ],
      [
        {
          "t": "b",
          "v": "Created a Banner Campaign"
        },
        {
          "t": "t",
          "v": "on the EmbedCraft Dashboard. You will need the"
        },
        {
          "t": "b",
          "v": "Widget Id"
        },
        {
          "t": "t",
          "v": "(Tag/ID) defined in the dashboard to link the UI."
        }
      ]
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Implementation Guide",
    "id": "implementation-guide"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Select your platform below to see specific integration code."
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
          "v": "Android"
        }
      ],
      [
        {
          "t": "t",
          "v": "iOS"
        }
      ],
      [
        {
          "t": "t",
          "v": "Flutter"
        }
      ],
      [
        {
          "t": "t",
          "v": "React Native"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "In Android, the"
      },
      {
        "t": "c",
        "v": "NudgeAppComponent"
      },
      {
        "t": "t",
        "v": "is a"
      },
      {
        "t": "c",
        "v": "ViewGroup"
      },
      {
        "t": "t",
        "v": "that you can place in your XML layouts or wrap in Jetpack Compose."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The critical property is the"
      },
      {
        "t": "c",
        "v": "tag"
      },
      {
        "t": "t",
        "v": ". This string must match the Identifier you configured in the EmbedCraft Dashboard."
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
          "v": "XML Layout"
        }
      ],
      [
        {
          "t": "t",
          "v": "Jetpack Compose"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Add the component to your layout file:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "xml",
    "code": "<com.nudgenow.nudgecorev2.experiences.appcomponent.core.NudgeAppComponent    android:id=\"@+id/nudge_banner\"    android:layout_width=\"match_parent\"    android:layout_height=\"wrap_content\"    android:background=\"@android:color/transparent\"    android:tag=\"YOUR_WIDGET_ID\" /> "
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "i",
        "v": "Replace with the ID from your dashboard."
      },
      {
        "t": "c",
        "v": "YOUR_WIDGET_ID"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use"
      },
      {
        "t": "c",
        "v": "AndroidView"
      },
      {
        "t": "t",
        "v": "to wrap the native component:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "kotlin",
    "code": "import androidx.compose.viewinterop.AndroidViewimport com.nudgenow.nudgecorev2.experiences.appcomponent.core.NudgeAppComponentAndroidView(    factory = { context ->        NudgeAppComponent(context).apply {            tag = \"YOUR_WIDGET_ID\" // Must match Dashboard ID        }    },    modifier = Modifier.fillMaxWidth())"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Ensure the"
      },
      {
        "t": "c",
        "v": "tag"
      },
      {
        "t": "t",
        "v": "is set correctly. If the tag doesn't match an active campaign, the view will typically remain empty or hidden (height 0)."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Embed customizable banners using"
      },
      {
        "t": "c",
        "v": "NudgeAppComponentView"
      },
      {
        "t": "t",
        "v": "(SwiftUI) or"
      },
      {
        "t": "c",
        "v": "NudgeAppComponent"
      },
      {
        "t": "t",
        "v": "(UIKit)."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The"
      },
      {
        "t": "c",
        "v": "id"
      },
      {
        "t": "t",
        "v": "parameter links this view to your EmbedCraft Dashboard configuration."
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
          "v": "SwiftUI"
        }
      ],
      [
        {
          "t": "t",
          "v": "UIKit"
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Add the view to any layout container ("
      },
      {
        "t": "c",
        "v": "VStack"
      },
      {
        "t": "t",
        "v": ","
      },
      {
        "t": "c",
        "v": "HStack"
      },
      {
        "t": "t",
        "v": ", etc.):"
      }
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "import Nudgecore_iOSVStack {    // Other content..    NudgeAppComponentView(id: \"YOUR_WIDGET_ID\")        .fixedSize(horizontal: false, vertical: true)        // Other content..}"
  },
  {
    "type": "_bq_open"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Note:"
      },
      {
        "t": "t",
        "v": "The"
      },
      {
        "t": "c",
        "v": ".fixedSize(horizontal: false, vertical: true)"
      },
      {
        "t": "t",
        "v": "modifier helps the view resize dynamically based on the content downloaded from EmbedCraft."
      }
    ]
  },
  {
    "type": "_bq_close"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You can add the view programmatically or via Storyboard."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Programmatic Approach:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "import Nudgecore_iOSlet nudgeBanner = NudgeAppComponent()nudgeBanner.id = \"#YOUR_WIDGET_ID\" // Ensure ID matches dashboardview.addSubview(nudgeBanner)// Layout ConstraintsnudgeBanner.translatesAutoresizingMaskIntoConstraints = falseNSLayoutConstraint.activate([    nudgeBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),    nudgeBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor),    nudgeBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)])"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The EmbedCraft SDK provides a native Flutter widget"
      },
      {
        "t": "c",
        "v": "NudgeAppComponent"
      },
      {
        "t": "t",
        "v": "for seamless integration."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Usage",
    "id": "usage"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Import the package:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "dart",
    "code": "import 'package:nudgecore_v2/nudgecore_v2.dart';"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Place the widget in your build tree:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "dart",
    "code": "Column(  children: [    Text(\"Welcome to the App\"),        // EmbedCraft Banner    NudgeAppComponent(      id: 'YOUR_WIDGET_ID' // Matches ID in EmbedCraft Dashboard    ),    Expanded(child: MainContent()),  ],)"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Parameters",
    "id": "parameters"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "c",
          "v": "id"
        },
        {
          "t": "t",
          "v": "(String, required): The unique identifier for this banner slot. The SDK fetches content associated with this ID."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Use the"
      },
      {
        "t": "c",
        "v": "NudgeWidget"
      },
      {
        "t": "t",
        "v": "component to embed banners."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Usage",
    "id": "usage"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Import the component:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "javascript",
    "code": "import { NudgeWidget } from 'nudge_react_native_v2';"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Add it to your JSX:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "javascript",
    "code": "import React from 'react';import { View } from 'react-native';import { NudgeWidget } from 'nudge_react_native_v2';const HomeScreen = () => {  return (    <View>         {/* EmbedCraft Banner */}        <NudgeWidget             label=\"YOUR_WIDGET_ID\"             pageName=\"HomeScreen\"            style={{ width: '100%', minHeight: 100 }}         />    </View>  );};"
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Props",
    "id": "props"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "c",
          "v": "label"
        },
        {
          "t": "t",
          "v": "(String, required): The unique identifier (Widget ID) from the EmbedCraft Dashboard."
        }
      ],
      [
        {
          "t": "c",
          "v": "pageName"
        },
        {
          "t": "t",
          "v": "(String, optional): Contextual name of the page, useful for analytics."
        }
      ],
      [
        {
          "t": "c",
          "v": "style"
        },
        {
          "t": "t",
          "v": "(Object, optional): Custom styles for the container."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Common Issues",
    "id": "common-issues"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Check that the"
        },
        {
          "t": "c",
          "v": "tag"
        },
        {
          "t": "t",
          "v": "/"
        },
        {
          "t": "c",
          "v": "id"
        },
        {
          "t": "t",
          "v": "/"
        },
        {
          "t": "c",
          "v": "label"
        },
        {
          "t": "t",
          "v": "exactly matches the one in the EmbedCraft Dashboard."
        }
      ],
      [
        {
          "t": "t",
          "v": "Ensure the campaign associated with that ID is"
        },
        {
          "t": "b",
          "v": "Active"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "t",
          "v": "Verify the SDK is initialized with the correct API Key."
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
          "v": "Banners are dynamic in height. Ensure your parent container allows the banner to expand (e.g., inside a"
        },
        {
          "t": "c",
          "v": "ScrollView"
        },
        {
          "t": "t",
          "v": "or"
        },
        {
          "t": "c",
          "v": "Column"
        },
        {
          "t": "t",
          "v": "with flexible height)."
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
          "t": "b",
          "v": "Banner Not Showing?"
        }
      ],
      [
        {
          "t": "b",
          "v": "Layout Issues?"
        }
      ]
    ]
  }
] as Block[];

export default function QuickstartBannerIntegrationPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
