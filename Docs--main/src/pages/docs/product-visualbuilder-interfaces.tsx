// Manually authored page — content for /product/VisualBuilder/interfaces
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/product/VisualBuilder/interfaces";
const TITLE = 'Interfaces';
const DESCRIPTION = 'Surface types you can build inside the EmbedCraft Visual Builder.';

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Interfaces",
    "id": "interfaces"
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
        "v": "Interfaces are the canvases your widgets render on. EmbedCraft ships with a curated set of interface presets that map to native UI patterns on every platform."
      }
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Available interfaces",
    "id": "available-interfaces"
  },
  {
    "type": "list",
    "ordered": false,
    "items": [
      [
        {
          "t": "t",
          "v": "Modal \u2014 centered dialog with optional backdrop."
        }
      ],
      [
        {
          "t": "t",
          "v": "Bottom Sheet \u2014 slide-up panel anchored to the bottom."
        }
      ],
      [
        {
          "t": "t",
          "v": "Full Page \u2014 takeover screen for onboarding and stories."
        }
      ],
      [
        {
          "t": "t",
          "v": "Tooltip \u2014 anchored callout pointing at a UI element."
        }
      ],
      [
        {
          "t": "t",
          "v": "Spotlight \u2014 dimmed overlay highlighting a target."
        }
      ],
      [
        {
          "t": "t",
          "v": "Banner \u2014 inline strip embedded inside your layout."
        }
      ],
      [
        {
          "t": "t",
          "v": "Embed \u2014 fully embedded widget rendered in-flow."
        }
      ]
    ]
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Configuration",
    "id": "configuration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "Each interface exposes its own animation, dismissal, anchoring and accessibility options inside the Visual Builder right panel."
      }
    ]
  }
];

export default function Page() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
