import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/flutter/installation-flutter";
const TITLE = "Installation";
const DESCRIPTION = "Configure installation for the Flutter SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Installation",
    "id": "installation"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure installation for the Flutter SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Install",
    "id": "install"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Add the SDK package or CDN script, then initialize it once during application startup."
      }
    ]
  },
  {
    "type": "code",
    "lang": "dart",
    "code": "import 'package:in_app_ninja/in_app_ninja.dart';\n\nvoid main() async {\n  WidgetsFlutterBinding.ensureInitialized();\n  await AppNinja.init(\n    'YOUR_PUBLIC_API_KEY',\n    autoRender: true,\n  );\n  \n  runApp(\n    MaterialApp(\n      navigatorObservers: [NinjaRouteObserver()],\n      home: NinjaApp(\n        child: MyHomePage(),\n      ),\n    ),\n  );\n}"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Verify",
    "id": "verify"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Open the app, complete one test session, and confirm that the user appears in the EmbedCraft dashboard."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
