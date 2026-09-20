import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/flutter/callbacks-flutter";
const TITLE = "Flutter Callbacks";
const DESCRIPTION = "Configure flutter callbacks for the Flutter SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Flutter Callbacks",
    "id": "flutter-callbacks"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure flutter callbacks for the Flutter SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Register callbacks",
    "id": "register-callbacks"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Callbacks let your app react when EmbedCraft content is shown, clicked, dismissed, completed, or fails to load."
      }
    ]
  },
  {
    "type": "code",
    "lang": "dart",
    "code": "NinjaCallbackManager.onEvent.listen((event) {\n  print('Action: ${event.action}, Data: ${event.data}');\n});"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Common callbacks",
    "id": "common-callbacks"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "content.loaded \u2014 content is ready to render."
        }
      ],
      [
        {
          "t": "t",
          "v": "content.dismissed \u2014 the user closed the experience."
        }
      ],
      [
        {
          "t": "t",
          "v": "action.triggered \u2014 the user selected a configured action."
        }
      ]
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
