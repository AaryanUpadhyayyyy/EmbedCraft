// AUTO-GENERATED page — content for /quickstart/stories-integration
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/quickstart/stories-integration";
const TITLE = "Stories Integration";
const DESCRIPTION = "Configuring SDK";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Stories Integration",
    "id": "stories-integration"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Configuring SDK",
    "id": "configuring-sdk"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This will Guide you through the EmbedCraft Stories integration for various platform. Before proceeding with this step you must complete the Basic Integrations of the SDK."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "If you have not done the Basic Integration, you can check"
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
          "v": "Web"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Embedding Stories",
    "id": "embedding-stories"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This documentions will guide you with adding the EmbedCraft Stories into your applicatiom"
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Android View",
    "id": "android-view"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "If your android app is"
      },
      {
        "t": "c",
        "v": "xml"
      },
      {
        "t": "t",
        "v": "based, you can add the Stories into Your app like this"
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Adding Views",
    "id": "adding-views"
  },
  {
    "type": "code",
    "lang": "xml",
    "code": "<com.nudgenow.nudgecorev2.experiences.stories.components.NudgeStoryTray    android:layout_width=\"match_parent\"    android:id=\"@+id/{YOUR_VIEW_ID}\"    android:tag=\"{YOUR_VIEW_TAG}\"    android:layout_height=\"wrap_content\"/>"
  },
  {
    "type": "code",
    "lang": "kotlin",
    "code": "val storyContainer = NudgeStoryTray(    context,    headingLightModeColor = \"#FF0000\", //optional    headingDarkModeColor = \"#00FF00\", //optional    subheadingDarkModeColor = \"#FFFFFF\", //optional    subheadingLightModeColor = \"#000000\" //optional    )val layoutParams = LinearLayout.LayoutParams(    LinearLayout.LayoutParams.MATCH_PARENT,    LinearLayout.LayoutParams.WRAP_CONTENT)storyContainer.orientation = LinearLayout.HORIZONTALstoryContainer.layoutParams = layoutParamsstoryContainer.tag = \"YOUR_TAG\"yourview.addView(storyContainer)"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Make sure you add a id to the view"
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Jetpack Compose",
    "id": "jetpack-compose"
  },
  {
    "type": "code",
    "lang": "kotlin",
    "code": "AndroidView(        factory = { ctx ->            val storyContainer = NudgeStoryTray(                ctx ,                headingLightModeColor = \"#FF0000\", //optional                headingDarkModeColor = \"#00FF00\", //optional                subheadingDarkModeColor = \"#FFFFFF\", //optional                subheadingLightModeColor = \"#000000\" //optional            ).apply {                val _layoutParams = LinearLayout.LayoutParams(                    LinearLayout.LayoutParams.MATCH_PARENT,                    LinearLayout.LayoutParams.WRAP_CONTENT                )                orientation = LinearLayout.HORIZONTAL                layoutParams = _layoutParams                tag = \"YOUR_TAG\"            }            storyContainer        },    )"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To display targeted stories within your app, integrate the EmbedCraft SDK and use the"
      },
      {
        "t": "c",
        "v": "EmbedCraft.getInstance().track(\"event_name\")"
      },
      {
        "t": "t",
        "v": "method to log specific user actions."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Then, leverage the EmbedCraft Dashboard to define which stories, identified by tags, should be presented in designated Story Containers based on those logged events."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "SwiftUI",
    "id": "swiftui"
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Adding the StoriesComponentView",
    "id": "adding-the-storiescomponentview"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To integrate the"
      },
      {
        "t": "c",
        "v": "StoriesComponentView"
      },
      {
        "t": "t",
        "v": "into your SwiftUI layout, add it to a container view such as"
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
        "v": ", or"
      },
      {
        "t": "c",
        "v": "ZStack"
      },
      {
        "t": "t",
        "v": ":"
      }
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "StoriesComponentView(id: \"YOUR_TAG\")    .fixedSize(horizontal: false, vertical: true)"
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
        "v": "It is strongly recommended to use the"
      },
      {
        "t": "c",
        "v": ".fixedSize()"
      },
      {
        "t": "t",
        "v": "modifier to avoid size inconsistencies."
      }
    ]
  },
  {
    "type": "_bq_close"
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 4,
    "text": "UIKit",
    "id": "uikit"
  },
  {
    "type": "heading",
    "level": 5,
    "text": "Using Storyboard",
    "id": "using-storyboard"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Drag an empty"
        },
        {
          "t": "c",
          "v": "UIView"
        },
        {
          "t": "t",
          "v": "onto your storyboard and set the desired size constraints."
        }
      ],
      [
        {
          "t": "t",
          "v": "Select the view, and from the class inspector, assign it to"
        },
        {
          "t": "c",
          "v": "StoriesComponent"
        },
        {
          "t": "t",
          "v": "."
        }
      ],
      [
        {
          "t": "t",
          "v": "Create an outlet for the view in your class."
        }
      ],
      [
        {
          "t": "t",
          "v": "Assign an"
        },
        {
          "t": "c",
          "v": "id"
        },
        {
          "t": "t",
          "v": "to the view:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "view.id = \"YOUR_TAG\"view.headingLightModeColor = \"#000000\";view.headingDarkModeColor = \"#ffffff\";view.subheadingDarkModeColor = \"#ffffff\";view.subheadingLightModeColor = \"#000000\";"
  },
  {
    "type": "heading",
    "level": 5,
    "text": "Using a Custom View",
    "id": "using-a-custom-view"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Initialize the"
        },
        {
          "t": "c",
          "v": "StoriesComponent"
        },
        {
          "t": "t",
          "v": "class:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "let component = StoriesComponent()"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Assign an"
        },
        {
          "t": "c",
          "v": "id"
        },
        {
          "t": "t",
          "v": ":"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "component.id = \"YOUR_TAG\"component.headingLightModeColor = \"#000000\"; // optionalcomponent.headingDarkModeColor = \"#ffffff\"; // optionalcomponent.subheadingDarkModeColor = \"#ffffff\" // optionalcomponent.subheadingLightModeColor = \"#000000\" // optional"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Add it to the desired subview:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "self.view.addSubview(component)"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Apply Auto Layout constraints to fit your view hierarchy:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "component.translatesAutoresizingMaskIntoConstraints = falseNSLayoutConstraint.activate([    component.leadingAnchor.constraint(equalTo: view.leadingAnchor),    component.trailingAnchor.constraint(equalTo: view.trailingAnchor),    component.centerXAnchor.constraint(equalTo: view.centerXAnchor),    component.centerYAnchor.constraint(equalTo: view.centerYAnchor)])"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To display targeted stories within your app, integrate the EmbedCraft SDK and use the"
      },
      {
        "t": "c",
        "v": "EmbedCraft.getInstance().track(\"event_name\")"
      },
      {
        "t": "t",
        "v": "method to log specific user actions."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Then, leverage the EmbedCraft Dashboard to define which stories, identified by tags, should be presented in designated Story Containers based on those logged events."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The EmbedCraft SDK enables seamless integration of interactive stories into your Flutter application, enhancing user engagement through dynamic content delivery."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Importing the Package",
    "id": "importing-the-package"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Ensure that"
      },
      {
        "t": "c",
        "v": "nudgecore_v2"
      },
      {
        "t": "t",
        "v": "is imported in your Dart file:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "cpp",
    "code": "import 'package:nudgecore_v2/nudgecore_v2.dart';"
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Embedding EmbedCraft Stories",
    "id": "embedding-nudge-stories"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To integrate stories within your Flutter UI, use the"
      },
      {
        "t": "c",
        "v": "NudgeStories"
      },
      {
        "t": "t",
        "v": "widget. This widget dynamically renders stories based on the specified"
      },
      {
        "t": "b",
        "v": "widget ID"
      },
      {
        "t": "t",
        "v": "and supports customization."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Usage Example",
    "id": "usage-example"
  },
  {
    "type": "code",
    "lang": "cpp",
    "code": "NudgeStories(    id: 'home_page_banner',    horizontalEdgePadding: HorizontalEdgePadding(left: 16, right: 16),    verticalEdgePadding: VerticalEdgePadding(top: 0, bottom: 0),    titleColorDarkMode: Colors.green,    titleColorLightMode: Colors.yellow,    subtitleColorDarkMode: Colors.red,    subtitleColorLightMode: Colors.blue,)"
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Parameters:",
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
          "v": "(String) - Unique identifier for the story component, as defined in the EmbedCraft dashboard."
        }
      ],
      [
        {
          "t": "c",
          "v": "horizontalEdgePadding"
        },
        {
          "t": "t",
          "v": "(HorizontalEdgePadding) - Sets left and right padding for the stories widget."
        }
      ],
      [
        {
          "t": "c",
          "v": "verticalEdgePadding"
        },
        {
          "t": "t",
          "v": "(VerticalEdgePadding) - Defines top and bottom spacing."
        }
      ],
      [
        {
          "t": "c",
          "v": "titleColorDarkMode"
        },
        {
          "t": "t",
          "v": "(Color) - Title text color in dark mode."
        }
      ],
      [
        {
          "t": "c",
          "v": "titleColorLightMode"
        },
        {
          "t": "t",
          "v": "(Color) - Title text color in light mode."
        }
      ],
      [
        {
          "t": "c",
          "v": "subtitleColorDarkMode"
        },
        {
          "t": "t",
          "v": "(Color) - Subtitle text color in dark mode."
        }
      ],
      [
        {
          "t": "c",
          "v": "subtitleColorLightMode"
        },
        {
          "t": "t",
          "v": "(Color) - Subtitle text color in light mode."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Integration Notes",
    "id": "integration-notes"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Ensure the"
        },
        {
          "t": "b",
          "v": "widget ID"
        },
        {
          "t": "t",
          "v": "matches the one configured in the EmbedCraft dashboard."
        }
      ],
      [
        {
          "t": "t",
          "v": "The"
        },
        {
          "t": "c",
          "v": "NudgeStories"
        },
        {
          "t": "t",
          "v": "widget must be placed within an appropriate widget tree to ensure visibility."
        }
      ],
      [
        {
          "t": "t",
          "v": "The appearance of stories dynamically updates based on campaign settings."
        }
      ]
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To display targeted stories within your app, integrate the EmbedCraft SDK and use the"
      },
      {
        "t": "c",
        "v": "track(\"event_name\")"
      },
      {
        "t": "t",
        "v": "method to log specific user actions."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Then, leverage the EmbedCraft Dashboard to define which stories, identified by tags, should be presented in designated Story Containers based on those logged events."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Ensure the basic integration of the EmbedCraft SDK is complete. If not,"
      },
      {
        "t": "t",
        "v": "check here"
      },
      {
        "t": "t",
        "v": "."
      }
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Add Stories div",
    "id": "add-stories-div"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Now you just need to add a"
      },
      {
        "t": "c",
        "v": "div"
      },
      {
        "t": "t",
        "v": "where you want your stories to appear and make sure to give it the id of"
      },
      {
        "t": "c",
        "v": "nudge_stories"
      }
    ]
  },
  {
    "type": "code",
    "lang": "html",
    "code": "<div id=\"nudge_stories\"><div>"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To display targeted stories within your app, integrate the EmbedCraft SDK and use the"
      },
      {
        "t": "c",
        "v": "track(\"event_name\")"
      },
      {
        "t": "t",
        "v": "method to log specific user actions."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Then, leverage the EmbedCraft Dashboard to define which stories, identified by tags, should be presented in designated Story Containers based on those logged events."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Understanding Widget IDs",
    "id": "understanding-widget-ids"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The"
      },
      {
        "t": "b",
        "v": "Widget ID"
      },
      {
        "t": "t",
        "v": "is the identifier you assign to the stories embed in your app (e.g.,"
      },
      {
        "t": "c",
        "v": "tag"
      },
      {
        "t": "t",
        "v": "on Android,"
      },
      {
        "t": "c",
        "v": "id"
      },
      {
        "t": "t",
        "v": "on iOS/Flutter,"
      },
      {
        "t": "c",
        "v": "label"
      },
      {
        "t": "t",
        "v": "on React Native). When you create a Stories campaign in the EmbedCraft Dashboard, you must enter this same Widget ID so that EmbedCraft knows which embed in your app should display the campaign's stories."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Stories SDK integration is a"
      },
      {
        "t": "b",
        "v": "prerequisite"
      },
      {
        "t": "t",
        "v": "before creating a Stories campaign. You must first embed the stories component in your app with a Widget ID, then use that Widget ID when configuring the campaign in the dashboard."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Configuring Dashboard",
    "id": "configuring-dashboard"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "The Widget ID assigned to the stories embed in your app must be added to the EmbedCraft Dashboard when creating a Stories campaign. In the campaign's Stories step, enter the Widget ID(s) to link the campaign to your app's stories embed."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Creating a Sample Story"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "To help you get started, we've prepared a video tutorial that demonstrates the process of creating a story in the EmbedCraft Dashboard. Watch the video below for step-by-step guidance:"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Your browser does not support the video tag."
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Follow the instructions in the video to configure your story and link it to the appropriate Widget ID in your app."
      }
    ]
  }
] as Block[];

export default function QuickstartStoriesIntegrationPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
