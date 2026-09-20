import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/platform/flutter/tracking-pages-flutter";
const TITLE = "Flutter Tracking Pages";
const DESCRIPTION = "Configure flutter tracking pages for the Flutter SDK and keep the integration aligned with the rest of your EmbedCraft workspace.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Flutter Tracking Pages",
    "id": "flutter-tracking-pages"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Configure flutter tracking pages for the Flutter SDK and keep the integration aligned with the rest of your EmbedCraft workspace."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Track pages",
    "id": "track-pages"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Record screen or route changes so flows and campaigns can react to user navigation."
      }
    ]
  },
  {
    "type": "code",
    "lang": "dart",
    "code": "AppNinja.trackPage('Product Details', context);"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "When to call",
    "id": "when-to-call"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Call page tracking after navigation completes and the screen title is known. Note: If you have added NinjaRouteObserver to your MaterialApp navigatorObservers, this is done automatically."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
