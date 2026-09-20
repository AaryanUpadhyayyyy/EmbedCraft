// AUTO-GENERATED page — content for /callback-integration
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/callback-integration";
const TITLE = "Callback Integration";
const DESCRIPTION = "This will Guide you through the basic integration of EmbedCraft SDK&#39;s Callback with various platform";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Callback Integration",
    "id": "callback-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This will Guide you through the basic integration of EmbedCraft SDK's Callback with various platform"
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Available Callbacks",
    "id": "available-callbacks"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "EmbedCraft's SDK sends 2 types of Callbacks,"
      },
      {
        "t": "c",
        "v": "Core Callbacks"
      },
      {
        "t": "t",
        "v": "and"
      },
      {
        "t": "c",
        "v": "Ui Callbacks"
      },
      {
        "t": "t",
        "v": ". Here are the list of all available callbacks:"
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Core Callbacks:",
    "id": "core-callbacks"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Callback Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Callback Data"
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
            "t": "t",
            "v": "NUDGE_INITIALISED"
          }
        ],
        [
          {
            "t": "c",
            "v": "{sdk_version: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "SDK Initialisation"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_USER_IDENTIFIER_SUCCESS"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ user_details: { name: string, email: string, phone_number: string, external_id: string } }"
          }
        ],
        [
          {
            "t": "t",
            "v": "User Identification Success"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_USER_IDENTIFIER_FAILURE"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ user_details: { name: string, email: string, phone_number: string, external_id: string }, error: string, message: string }"
          }
        ],
        [
          {
            "t": "t",
            "v": "User Identification Failure"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_TRACK_EVENT"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ event: string, response: object }"
          }
        ],
        [
          {
            "t": "t",
            "v": "Tracking Events Success"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_REWARD_RECEIVED"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ rewards: [object] }"
          }
        ],
        [
          {
            "t": "t",
            "v": "Reward Received"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "Ui Callbacks:",
    "id": "ui-callbacks"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Generic Displays"
        }
      ],
      [
        {
          "t": "t",
          "v": "Floater"
        }
      ],
      [
        {
          "t": "t",
          "v": "Banners"
        }
      ],
      [
        {
          "t": "t",
          "v": "Stories"
        }
      ],
      [
        {
          "t": "t",
          "v": "In App Nudges"
        }
      ],
      [
        {
          "t": "t",
          "v": "Surveys"
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "For Any Fullscreen, Bottomsheet and Pop Up",
    "id": "for-any-fullscreen-bottomsheet-and-pop-up"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Callback Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Callback Data"
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
            "t": "t",
            "v": "NUDGE_EXPERIENCE_OPEN"
          }
        ],
        [
          {
            "t": "c",
            "v": "{CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience Visible to User"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_EXPERIENCE_DISMISS"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience is Dismissed"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_COMPONENT_CTA_CLICK"
          }
        ],
        [
          {
            "t": "c",
            "v": "{TARGET: string, CAMPAIGN_ID: string, CAMPAIGN_NAME: string, WIDGET_NAME: string, WIDGET_ID: string, DISPLAY_NAME: string, CLICK_TYPE: string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "User Clicks on any Widget"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "For Floater",
    "id": "for-floater"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Callback Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Callback Data"
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
            "t": "t",
            "v": "NUDGE_EXPERIENCE_OPEN"
          }
        ],
        [
          {
            "t": "c",
            "v": "{CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string }"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience Visible to User"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_EXPERIENCE_DISMISS"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience is Dismissed"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_COMPONENT_CTA_CLICK"
          }
        ],
        [
          {
            "t": "c",
            "v": "{TARGET: string, CAMPAIGN_ID: string, CAMPAIGN_NAME: string, WIDGET_NAME: string, WIDGET_ID: string, DISPLAY_NAME: string, CLICK_TYPE: string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "User Clicks on any Widget"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_FLOATER_EXPANDED"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Floater Expanded"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "For Banners",
    "id": "for-banners"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Callback Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Callback Data"
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
            "t": "t",
            "v": "NUDGE_EXPERIENCE_OPEN"
          }
        ],
        [
          {
            "t": "c",
            "v": "{CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string, COMPONENT_ID: string }"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience Visible to User"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_COMPONENT_CTA_CLICK"
          }
        ],
        [
          {
            "t": "c",
            "v": "{TARGET: string, CAMPAIGN_ID: string, CAMPAIGN_NAME: string, WIDGET_NAME: string, WIDGET_ID: string, DISPLAY_NAME: string, CLICK_TYPE: string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "User Clicks on any Widget"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "For Stories",
    "id": "for-stories"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Callback Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Callback Data"
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
            "t": "t",
            "v": "NUDGE_EXPERIENCE_OPEN"
          }
        ],
        [
          {
            "t": "c",
            "v": "{CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string, COMPONENT_ID: string }"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience Visible to User"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_COMPONENT_CTA_CLICK"
          }
        ],
        [
          {
            "t": "c",
            "v": "{TARGET: string, CAMPAIGN_ID: string, CAMPAIGN_NAME: string, WIDGET_NAME: string, WIDGET_ID: string, DISPLAY_NAME: string, CLICK_TYPE: string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "User Clicks on any Widget"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_SLIDE_OPEN"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Slide Opened"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_SLIDE_DISMISS"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Slide Dismissed"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "In App Nudges",
    "id": "in-app-nudges"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Callback Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Callback Data"
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
            "t": "t",
            "v": "NUDGE_EXPERIENCE_OPEN"
          }
        ],
        [
          {
            "t": "c",
            "v": "{CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_TYPE : string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience Visible to User"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_EXPERIENCE_DISMISS"
          }
        ],
        [
          {
            "t": "c",
            "v": "{CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_TYPE : string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience is Dismissed"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_COMPONENT_CTA_CLICK"
          }
        ],
        [
          {
            "t": "c",
            "v": "{TARGET: string, CAMPAIGN_ID: string, CAMPAIGN_NAME: string, WIDGET_NAME: string, WIDGET_ID: string, DISPLAY_NAME: string, CLICK_TYPE: string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "User Clicks on any Widget"
          }
        ]
      ]
    ]
  },
  {
    "type": "heading",
    "level": 4,
    "text": "Surveys",
    "id": "surveys"
  },
  {
    "type": "table",
    "header": [
      [
        {
          "t": "t",
          "v": "Callback Action"
        }
      ],
      [
        {
          "t": "t",
          "v": "Callback Data"
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
            "t": "t",
            "v": "NUDGE_EXPERIENCE_OPEN"
          }
        ],
        [
          {
            "t": "c",
            "v": "{CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience Visible to User"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_EXPERIENCE_DISMISS"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_NAME: string, DISPLAY_TYPE : string, DISPLAY_ID: string}"
          }
        ],
        [
          {
            "t": "t",
            "v": "Experience is Dismissed"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_SURVEY_SUBMIT"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_TYPE : string, DISPLAY_ID: string, ANSWER: object }"
          }
        ],
        [
          {
            "t": "t",
            "v": "When user attempts any question"
          }
        ]
      ],
      [
        [
          {
            "t": "t",
            "v": "NUDGE_SURVEY_SUBMIT"
          }
        ],
        [
          {
            "t": "c",
            "v": "{ CAMPAIGN_ID : string, CAMPAIGN_NAME : string, DISPLAY_TYPE : string, DISPLAY_ID: string, RESPONSES: object, TOTAL_QUESTIONS: Int, SKIPED_QUESTIONS: Int, ANSWERED_QUESTIONS: Int }"
          }
        ],
        [
          {
            "t": "t",
            "v": "When user attempts all questions"
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
        "v": "Format for"
      },
      {
        "t": "c",
        "v": "ANSWER"
      },
      {
        "t": "t",
        "v": "Object"
      }
    ]
  },
  {
    "type": "code",
    "lang": "text",
    "code": "ANSWER:{    QUESTION_TYPE: String    QUESTION_NAME: String    RESPONSE: user's response / SKIPPED    ID: questionId}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Format for"
      },
      {
        "t": "c",
        "v": "RESPONSES"
      },
      {
        "t": "t",
        "v": "Object"
      }
    ]
  },
  {
    "type": "code",
    "lang": "text",
    "code": "ANSWER:{    questionId:{        QUESTION_TYPE:        QUESTION_NAME:        RESPONSE: user's response / SKIPPED        ID: questionId    }}"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Listening Callbacks",
    "id": "listening-callbacks"
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
        "v": "Extend the class in which you want to Listen the Callback with"
      },
      {
        "t": "c",
        "v": "NudgeGlobalCallback"
      },
      {
        "t": "t",
        "v": "and register the class for receiving the callback by passing the instance of the class to"
      },
      {
        "t": "c",
        "v": "NudgeGlobalCallbackManager"
      },
      {
        "t": "t",
        "v": "'s"
      },
      {
        "t": "c",
        "v": "registerListener"
      },
      {
        "t": "t",
        "v": "method.\nNow by overriding the"
      },
      {
        "t": "c",
        "v": "onEvent"
      },
      {
        "t": "t",
        "v": "method you can listen to the callbacks"
      }
    ]
  },
  {
    "type": "code",
    "lang": "kotlin",
    "code": "class YourClass : NudgeGlobalCallback {    init{        NudgeGlobalCallbackManager.registerListener(this)    }    override fun onEvent(event: NudgeCallback) {        when (event){            is NudgeCoreCallback ->{                when (event.action){                    \"NUDGE_INITIALISED\"->{                        Log.d(\"Story From EmbedCraft\",event.DATA)                    }                }            }            is NudgeUICallback -> {                when (event.action){                    NCM.NUDGE_COMPONENT_CTA_CLICK.name->{                        Log.d(\"CTA CLICK FROM NUDGE\",event.action)                        Log.d(\"NUDGE CALLBACK\",event.data.toString())                    }                    NCM.NUDGE_EXPERIENCE_OPEN.name->{                        Log.d(\"NUDGE CALLBACKE\",event.data.toString())                    }                    NCM.NUDGE_EXPERIENCE_DISMISS.name->{                        Log.d(\"NUDGE CALLBACKE\",event.data.toString())                    }                }            }        }    }}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Extend the class in which you want to Listen the Callback with"
      },
      {
        "t": "c",
        "v": "NudgeGlobalCallback"
      },
      {
        "t": "t",
        "v": "and register the class for receiving the callback by passing the instance of the class to"
      },
      {
        "t": "c",
        "v": "NudgeGlobalCallbackManager"
      },
      {
        "t": "t",
        "v": "'s"
      },
      {
        "t": "c",
        "v": "registerListener"
      },
      {
        "t": "t",
        "v": "method.\nNow by overriding the"
      },
      {
        "t": "c",
        "v": "onEvent"
      },
      {
        "t": "t",
        "v": "method you can listen to the callbacks"
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
          "v": "UI Kit"
        }
      ],
      [
        {
          "t": "t",
          "v": "Swift UI"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "public class YourClass: NudgeGlobalCallback {    var callbackManager = NudgeGlobalCallbackManager.shared    init() {        callbackManager.registerListener(self)    }    public func onEvent(event: NudgeCallback) {        switch event {            case let coreEvent as NudgeCoreCallback:                // Handle NudgeCoreCallback                let action = coreEvent.action                let data = coreEvent.data             case let uiEvent as NudgeUICallback:                // Handle NudgeUICallback                let action = uiEvent.action                let data = uiEvent.data                // Perform logic based on the action/data here            default:                // Handle any other (perhaps unexpected) NudgeCallback subclasses                break        }    }}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You must remove the callback listener, on the destroy of the class."
      }
    ]
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "callbackManager.unregisterListener(self)"
  },
  {
    "type": "code",
    "lang": "swift",
    "code": "import SwiftUIstruct YourView: View {    @StateObject private var nudgeVM = NudgeEvents()    var body: some View {        VStack {            Text(\"EmbedCraft SDK Events\")                .font(.headline)                .padding(.bottom, 10)            Text(nudgeVM.eventText.isEmpty ? \"No events yet\" : nudgeVM.eventText)                .padding()                .background(nudgeVM.eventText.isEmpty ? Color.clear : Color.black)                .foregroundColor(.white)                .cornerRadius(10)                .animation(.easeInOut, value: nudgeVM.eventText)        }        .padding()    }}class NudgeEvents: NSObject, ObservableObject, NudgeGlobalCallback {    @Published var eventText: String = \"\"    override init() {        super.init()        NudgeGlobalCallbackManager.shared.registerListener(self)    }    deinit {        NudgeGlobalCallbackManager.shared.unregisterListener(self)    }    func onEvent(event: NudgeCallback) {        if let coreEvent = event as? NudgeCoreCallback {            let action = coreEvent.action            let data = coreEvent.data            DispatchQueue.main.async {                self.eventText = \"Action: \\(action)\\nData: \\(data)\"            }        }        if let coreEvent = event as? NudgeUICallback {            let action = coreEvent.action            let data = coreEvent.data            DispatchQueue.main.async {                self.eventText = \"Action: \\(action)\\nData: \\(data)\"            }        }    }}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Implement the"
      },
      {
        "t": "c",
        "v": "NudgeCallbackListener"
      },
      {
        "t": "t",
        "v": "in your screen:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "cpp",
    "code": "class _HomePageState extends State<HomePage>    with SingleTickerProviderStateMixin implements NudgeCallbackListener {...}"
  },
  {
    "type": "heading",
    "level": 4,
    "text": "2. Register the Callback",
    "id": "2-register-the-callback"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Register the listener in the"
      },
      {
        "t": "c",
        "v": "initState"
      },
      {
        "t": "t",
        "v": "method:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "cpp",
    "code": "@Overridevoid initState() {super.initState();NudgeCallbackManager.registerListener(this);}"
  },
  {
    "type": "heading",
    "level": 4,
    "text": "3. Listening to Events",
    "id": "3-listening-to-events"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Now, you can listen and respond to events:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "cpp",
    "code": "@overridevoid onEvent(NudgeCallbackData event) {print(\"callback event: ${event}\");switch (event.type) {    case \"CORE\":    break;    case \"UI\":    break;    default:    break;}}"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Here’s how you can set up and handle these callback events in a React Native component:"
      }
    ]
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "b",
        "v": "Example:"
      }
    ]
  },
  {
    "type": "code",
    "lang": "js",
    "code": "import { useEffect } from 'react';import { DeviceEventEmitter } from 'react-native';const MyComponent = () => {    useEffect(() => {        // Listener for Core Events        const coreCallbackListener = DeviceEventEmitter.addListener('NUDGE_CORE_CALLBACK', event => {            console.log('Core Event Received:', event);            handleCoreEvent(event);        });        // Listener for UI Events        const uiCallbackListener = DeviceEventEmitter.addListener('NUDGE_UI_CALLBACK', event => {            console.log('UI Event Received:', event);            handleUIEvent(event);        });        // Cleanup listeners on unmount        return () => {            coreCallbackListener.remove();            uiCallbackListener.remove();        };    }, []);    const handleCoreEvent = event => {        switch (event.action) {            case 'NUDGE_INITIALISED':                console.log('SDK Initialized:', event.data.sdk_version);                break;            case 'NUDGE_USER_IDENTIFIER_SUCCESS':                console.log('User Identified Successfully:', event.data.user_details);                break;            case 'NUDGE_USER_IDENTIFIER_FAILURE':                console.error('User Identification Failed:', event.data.error);                console.log('User Details:', event.data.user_details);                console.warn('Retry Message:', event.data.message);                break;            case 'NUDGE_TRACK_EVENT':                console.log('Track Event:', event.data.event, 'Response:', event.data.response);                break;            case 'NUDGE_REWARD_RECEIVED':                console.log('Reward Received:', event.data.rewards);                break;            default:                console.log('Unhandled Core Event:', event.action, event.data);        }    };    const handleUIEvent = event => {        switch (event.action) {            case 'NUDGE_EXPERIENCE_OPEN':                console.log('Experience Opened:', {                    campaignId: event.data.CAMPAIGN_ID,                    rootId: event.data.ROOT_ID,                    displayType: event.data.DISPLAY_TYPE,                });                break;            case 'NUDGE_EXPERIENCE_DISMISS':                console.log('Experience Dismissed:', {                    campaignId: event.data.CAMPAIGN_ID,                    rootId: event.data.ROOT_ID,                    displayType: event.data.DISPLAY_TYPE,                });                break;            case 'NUDGE_EXPERIENCE_HIDDEN':                console.log('Experience Hidden:', event.data);                break;            case 'NUDGE_COMPONENT_CTA_CLICK':                console.log('CTA Clicked:', {                    clickType: event.data.CLICK_TYPE,                    target: event.data.TARGET,                });                break;            default:                console.log('Unhandled UI Event:', event.action, event.data);        }    };    return null; // Replace with your UI components};export default MyComponent;"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Unregistering Callbacks",
    "id": "unregistering-callbacks"
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
        "v": "You must remove the callback listener, on the destory of the class."
      }
    ]
  },
  {
    "type": "code",
    "lang": "kotlin",
    "code": "NudgeGlobalCallbackManager.unregisterListener(this)"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "You must remove the callback listener, on the deinit of the class."
      }
    ]
  },
  {
    "type": "code",
    "lang": "text",
    "code": " deinit {     NudgeGlobalCallbackManager.shared.unregisterListener(self) } "
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "For Deregistering the Listerner you can do this"
      }
    ]
  },
  {
    "type": "code",
    "lang": "text",
    "code": "NudgeCallbackManager.unregisterListener(this) "
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "For Removing callbacks you can do this"
      }
    ]
  },
  {
    "type": "code",
    "lang": "text",
    "code": " coreCallbackListener.remove(); uiCallbackListener.remove();"
  }
] as Block[];

export default function CallbackIntegrationPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
