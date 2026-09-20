// AUTO-GENERATED page — content for /integrations/shopify.integration
// Edit freely; this file owns the full content for this route.
import { DocPageShell } from "@/components/docs/DocPageShell";
import type { Block } from "@/types/docs";

const SLUG = "/integrations/shopify.integration";
const TITLE = "Shopify Integration";
const DESCRIPTION = "Set up EmbedCraft on your Shopify store and track events using Customer Events.";

const BLOCKS: Block[] = [
  {
    "type": "heading",
    "level": 1,
    "text": "Shopify Integration",
    "id": "shopify-integration"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "This guide will walk you through integrating EmbedCraft with your Shopify store. It includes steps to install the SDK, identify users based on their phone number, and capture Shopify events via Customer Events."
      }
    ]
  },
  {
    "type": "hr"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 1: Add EmbedCraft to theme.liquid",
    "id": "step-1-add-nudge-to-theme-liquid"
  },
  {
    "type": "p",
    "runs": [
      {
        "t": "t",
        "v": "We’ll use the customer’s phone number as the"
      },
      {
        "t": "c",
        "v": "externalId"
      },
      {
        "t": "t",
        "v": "to identify users. Insert the following script inside your"
      },
      {
        "t": "c",
        "v": "theme.liquid"
      },
      {
        "t": "t",
        "v": "file, ideally before the closing"
      },
      {
        "t": "c",
        "v": "</body>"
      },
      {
        "t": "t",
        "v": "tag."
      }
    ]
  },
  {
    "type": "heading",
    "level": 3,
    "text": "theme.liquid",
    "id": "theme-liquid"
  },
  {
    "type": "code",
    "lang": "html",
    "code": "<script>  {% if customer %}    const customer = {      id: \"{{ customer.id }}\",      phone: \"{{ customer.phone | remove: '+91' | strip }}\"    };  {% else %}    const customer = null;  {% endif %}</script><script>  if (!window.NudgeLibrary) {    const script = document.createElement('script');    script.src = 'https://web-scripts.embedcraft.com/index.js';    script.async = true;    script.onload = function () {      initNudge();    };    document.head.appendChild(script);  } else {    initNudge();  }  function initNudge() {    if (!window.nudge) {      window.nudge = new NudgeLibrary.EmbedCraft({        apiKey: \"YOUR_API_KEY\",      });    }    monitorLoginState(window.nudge);  }  async function monitorLoginState(nudge) {    const userLoggedInKey = \"UserLoggedIn\";    let userLoggedIn = localStorage.getItem(userLoggedInKey) === \"true\";    const customerPhone = customer?.phone || null;    const customerId = customer?.id || null;    if (customerPhone && !userLoggedIn) {      nudge.userSignOut();      nudge.userIdentifier({        externalId: customerPhone,        properties: {          customerid: customerId,        },      });      localStorage.setItem(userLoggedInKey, \"true\");    } else if (!customerPhone && userLoggedIn) {      await nudge.track({ event: \"logout\" });      nudge.userSignOut();      nudge.userIdentifier({});      localStorage.setItem(userLoggedInKey, \"false\");    } else if (!customerPhone && !userLoggedIn) {      nudge.userIdentifier({});    }  }  window.addEventListener(\"message\", (event) => {    const { type, detail } = event?.data || {};    if (type === \"nudgeCustomEvent\" && window.nudge) {      window.nudge.track({        event: detail.name,        properties: detail.payload,      });    }  });</script>"
  },
  {
    "type": "heading",
    "level": 2,
    "text": "Step 2: Set up Shopify Customer Events",
    "id": "step-2-set-up-shopify-customer-events"
  },
  {
    "type": "list",
    "ordered": true,
    "items": [
      [
        {
          "t": "t",
          "v": "Go to your Shopify Admin."
        }
      ],
      [
        {
          "t": "t",
          "v": "Navigate to Settings → Customer Events."
        }
      ],
      [
        {
          "t": "t",
          "v": "Add a Custom Pixel and use the following code:"
        }
      ]
    ]
  },
  {
    "type": "code",
    "lang": "js",
    "code": "function subscribeToEvents() {  analytics.subscribe(\"all_standard_events\", (event) => {    console.log(\"📦 Event received in Customer Events:\", event.name);    // Send the event to the main site (where EmbedCraft is initialized)    window.parent.postMessage(      {        type: \"nudgeCustomEvent\",        detail: {          name: event.name,          payload: event.payload,        },      },      \"*\"    );  });}subscribeToEvents();"
  }
] as Block[];

export default function IntegrationsShopifyIntegrationPage() {
  return <DocPageShell slug={SLUG} title={TITLE} description={DESCRIPTION} blocks={BLOCKS} />;
}
