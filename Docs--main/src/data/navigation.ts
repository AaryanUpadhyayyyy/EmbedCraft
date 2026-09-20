import type { NavNode } from "@/types/docs";

export const navigation: NavNode[] = [
  { kind: "leaf", label: "Introduction", to: "/introduction" },
  {
    kind: "section",
    label: "Getting Started",
    to: "/getting-started",
    icon: "Rocket",
    defaultOpen: true,
    children: [
      { kind: "leaf", label: "Overview", to: "/getting-started" },
      { kind: "leaf", label: "Account Setup", to: "/getting-started/account-setup" },
      { kind: "leaf", label: "Account Setup & Configuration", to: "/getting-started/account-setup-configuration" },
      { kind: "leaf", label: "Finding & Managing API Keys", to: "/getting-started/finding-your-api-keys" },
      { kind: "leaf", label: "Roles & Permissions", to: "/getting-started/Roles-and-permissions" },
      { kind: "leaf", label: "Invite & Manage Team", to: "/getting-started/invite-a-team-member" },
      { kind: "leaf", label: "Invite Team", to: "/getting-started/invite-team" },
    ],
  },
  {
    kind: "section",
    label: "Quick Start",
    to: "/quickstart",
    icon: "Zap",
    defaultOpen: true,
    children: [
      { kind: "leaf", label: "Quick Start Guide", to: "/quickstart" },
      { kind: "leaf", label: "Installation", to: "/quickstart/installation" },
      { kind: "leaf", label: "Basic Integration Guide", to: "/quickstart/basic-integration" },
      { kind: "leaf", label: "Banner Integration", to: "/quickstart/banner-integration" },
      { kind: "leaf", label: "Stories Integration", to: "/quickstart/stories-integration" },
    ],
  },
  {
    kind: "section",
    label: "Platform SDKs",
    to: "/platform",
    icon: "Layers",
    children: [
      { kind: "leaf", label: "Overview", to: "/platform" },
      {
        kind: "section",
        label: "Web",
        to: "/platform/web",
        children: [
          { kind: "leaf", label: "Overview", to: "/platform/web" },
          { kind: "leaf", label: "CDN Integration", to: "/platform/web/cdn-integration" },
          { kind: "leaf", label: "Identifying Users", to: "/platform/web/identifying-users-web" },
          { kind: "leaf", label: "Tracking Events", to: "/platform/web/tracking-events-web" },
          { kind: "leaf", label: "API Registry", to: "/platform/web/api-registry" },
          { kind: "leaf", label: "Adding Banners", to: "/platform/web/04a-adding-banners-web" },
          { kind: "leaf", label: "Adding Stories", to: "/platform/web/adding-stories-web" },
          {
            kind: "section",
            label: "Callbacks",
            to: "/platform/web/Callbacks",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/web/Callbacks" },
              { kind: "leaf", label: "UI Callbacks", to: "/platform/web/Callbacks/uicallbacks" },
            ],
          },
        ],
      },
      {
        kind: "section",
        label: "Android",
        to: "/platform/android",
        children: [
          { kind: "leaf", label: "Overview", to: "/platform/android" },
          { kind: "leaf", label: "Installation", to: "/platform/android/installation-android" },
          { kind: "leaf", label: "Identifying Users", to: "/platform/android/identifying-users-android" },
          { kind: "leaf", label: "Tracking Events", to: "/platform/android/tracking-events-android" },
          { kind: "leaf", label: "Tracking Pages", to: "/platform/android/tracking-pages" },
          { kind: "leaf", label: "API Registry", to: "/platform/android/api-registry" },
          {
            kind: "section",
            label: "Callbacks",
            to: "/platform/android/Callbacks",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/android/Callbacks" },
              { kind: "leaf", label: "Core Callbacks", to: "/platform/android/Callbacks/corecallbacks" },
              { kind: "leaf", label: "UI Callbacks", to: "/platform/android/Callbacks/uicallbacks" },
            ],
          },
          {
            kind: "section",
            label: "Embedding Widgets",
            to: "/platform/android/Embedding%20Widgets",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/android/Embedding%20Widgets" },
              { kind: "leaf", label: "Banners", to: "/platform/android/Embedding%20Widgets/Banners" },
              { kind: "leaf", label: "Stories", to: "/platform/android/Embedding%20Widgets/Stories" },
            ],
          },
          {
            kind: "section",
            label: "Tracking Widgets",
            to: "/platform/android/Tracking%20Widgets",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/android/Tracking%20Widgets" },
              { kind: "leaf", label: "Widget Tracking", to: "/platform/android/Tracking%20Widgets/widget-tracking" },
              { kind: "leaf", label: "Sending Screenshots", to: "/platform/android/Tracking%20Widgets/sending-screenshots" },
            ],
          },
        ],
      },
      {
        kind: "section",
        label: "iOS",
        to: "/platform/iOS",
        children: [
          { kind: "leaf", label: "Overview", to: "/platform/iOS" },
          { kind: "leaf", label: "Installation", to: "/platform/iOS/installation-ios" },
          { kind: "leaf", label: "Identifying Users", to: "/platform/iOS/identifying-users-ios" },
          { kind: "leaf", label: "Tracking Events", to: "/platform/iOS/tracking-events-ios" },
          { kind: "leaf", label: "Tracking Pages", to: "/platform/iOS/tracking-pages" },
          { kind: "leaf", label: "API Registry", to: "/platform/iOS/api-registry" },
          {
            kind: "section",
            label: "Callbacks",
            to: "/platform/iOS/Callbacks",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/iOS/Callbacks" },
              { kind: "leaf", label: "Core Callbacks", to: "/platform/iOS/Callbacks/corecallbacks" },
              { kind: "leaf", label: "UI Callbacks", to: "/platform/iOS/Callbacks/uicallbacks" },
            ],
          },
          {
            kind: "section",
            label: "Embedding Widgets",
            to: "/platform/iOS/Embedding%20Widgets",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/iOS/Embedding%20Widgets" },
              { kind: "leaf", label: "Banners", to: "/platform/iOS/Embedding%20Widgets/Banners" },
              { kind: "leaf", label: "Stories", to: "/platform/iOS/Embedding%20Widgets/Stories" },
            ],
          },
          {
            kind: "section",
            label: "Tracking Widgets",
            to: "/platform/iOS/Tracking%20Widgets",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/iOS/Tracking%20Widgets" },
              { kind: "leaf", label: "Widget Tracking", to: "/platform/iOS/Tracking%20Widgets/tracking-widgets-ios" },
              { kind: "leaf", label: "Sending Screenshots", to: "/platform/iOS/Tracking%20Widgets/sending-screenshots-ios" },
            ],
          },
        ],
      },
      {
        kind: "section",
        label: "Flutter",
        to: "/platform/flutter",
        children: [
          { kind: "leaf", label: "Overview", to: "/platform/flutter" },
          { kind: "leaf", label: "Installation", to: "/platform/flutter/installation-flutter" },
          { kind: "leaf", label: "Identifying Users", to: "/platform/flutter/identifying-users-flutter" },
          { kind: "leaf", label: "Tracking Events", to: "/platform/flutter/tracking-events-flutter" },
          { kind: "leaf", label: "Tracking Pages", to: "/platform/flutter/tracking-pages-flutter" },
          { kind: "leaf", label: "API Registry", to: "/platform/flutter/api-registry" },
          { kind: "leaf", label: "Callbacks", to: "/platform/flutter/callbacks-flutter" },
          {
            kind: "section",
            label: "Embedding Widgets",
            to: "/platform/flutter/Embedding%20Widgets",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/flutter/Embedding%20Widgets" },
              { kind: "leaf", label: "Banners", to: "/platform/flutter/Embedding%20Widgets/banners" },
              { kind: "leaf", label: "Stories", to: "/platform/flutter/Embedding%20Widgets/stories" },
            ],
          },
          {
            kind: "section",
            label: "Tracking Widgets",
            to: "/platform/flutter/Tracking%20Widgets",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/flutter/Tracking%20Widgets" },
              { kind: "leaf", label: "Tracking Pages", to: "/platform/flutter/Tracking%20Widgets/tracking-pages" },
              { kind: "leaf", label: "Tracking Widgets", to: "/platform/flutter/Tracking%20Widgets/tracking-widgets" },
            ],
          },
        ],
      },
      {
        kind: "section",
        label: "React Native",
        to: "/platform/react-native",
        children: [
          { kind: "leaf", label: "Overview", to: "/platform/react-native" },
          { kind: "leaf", label: "Installation", to: "/platform/react-native/installation-react-native" },
          { kind: "leaf", label: "Identifying Users", to: "/platform/react-native/identifying-users-react-native-sdk" },
          { kind: "leaf", label: "Tracking Events", to: "/platform/react-native/tracking-events-react-native" },
          { kind: "leaf", label: "API Registry", to: "/platform/react-native/api-registry" },
          { kind: "leaf", label: "Callbacks", to: "/platform/react-native/callbacks" },
          {
            kind: "section",
            label: "Embedding Widgets",
            to: "/platform/react-native/Embedding%20Widgets",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/react-native/Embedding%20Widgets" },
              { kind: "leaf", label: "Banners", to: "/platform/react-native/Embedding%20Widgets/banners" },
              { kind: "leaf", label: "Stories", to: "/platform/react-native/Embedding%20Widgets/stories" },
            ],
          },
          {
            kind: "section",
            label: "Tracking Widgets",
            to: "/platform/react-native/Tracking%20Widgets",
            children: [
              { kind: "leaf", label: "Overview", to: "/platform/react-native/Tracking%20Widgets" },
              { kind: "leaf", label: "Tracking Pages", to: "/platform/react-native/Tracking%20Widgets/tracking-pages" },
              { kind: "leaf", label: "Tracking Widgets", to: "/platform/react-native/Tracking%20Widgets/tracking-widgets" },
            ],
          },
        ],
      },
    ],
  },
  {
    kind: "section",
    label: "API Reference",
    to: "/apis",
    icon: "Terminal",
    children: [
      { kind: "leaf", label: "Overview", to: "/apis" },
      { kind: "leaf", label: "EmbedCraft APIs", to: "/apis/nudge-apis" },
      { kind: "leaf", label: "Identify user", to: "/apis/identify-user" },
      { kind: "leaf", label: "Identify users (batch)", to: "/apis/identify-users-batch" },
      { kind: "leaf", label: "Track event", to: "/apis/track-event" },
      { kind: "leaf", label: "Batch events", to: "/apis/batch-events" },
      { kind: "leaf", label: "Apply referral", to: "/apis/apply-referral" },
      { kind: "leaf", label: "Get JWT token", to: "/apis/get-jwt-token" },
      { kind: "leaf", label: "Create cohort", to: "/apis/create-cohort" },
      { kind: "leaf", label: "Update cohort", to: "/apis/update-cohort" },
      { kind: "leaf", label: "Campaign CSV report", to: "/apis/campaign-csv-report" },
      { kind: "leaf", label: "Webhook", to: "/apis/webhook" },
    ],
  },
  {
    kind: "section",
    label: "Product",
    to: "/product",
    icon: "Package",
    children: [
      { kind: "leaf", label: "Introduction", to: "/product" },
      { kind: "leaf", label: "Events", to: "/product/Events" },
      {
        kind: "section",
        label: "Users",
        to: "/product/Users",
        children: [{ kind: "leaf", label: "Users", to: "/product/Users" }],
      },
      {
        kind: "section",
        label: "Cohorts",
        to: "/product/Cohorts",
        children: [
          { kind: "leaf", label: "Cohorts", to: "/product/Cohorts" },
          { kind: "leaf", label: "Static Cohorts", to: "/product/Cohorts/static" },
          { kind: "leaf", label: "Dynamic Cohorts", to: "/product/Cohorts/dynamic" },
          { kind: "leaf", label: "Import Cohorts", to: "/product/Cohorts/import" },
        ],
      },
      {
        kind: "section",
        label: "Rewards",
        to: "/product/rewards",
        children: [
          { kind: "leaf", label: "Rewards Overview", to: "/product/rewards" },
          { kind: "leaf", label: "Creating a Reward", to: "/product/rewards/reward" },
          { kind: "leaf", label: "Reward Delivery", to: "/product/rewards/reward-delivery" },
        ],
      },
      {
        kind: "section",
        label: "Campaigns",
        to: "/product/Campaigns",
        children: [
          { kind: "leaf", label: "Campaigns", to: "/product/Campaigns" },
          { kind: "leaf", label: "In-app Messages", to: "/product/Campaigns/in-app-messages" },
          { kind: "leaf", label: "In-app Nudges", to: "/product/Campaigns/in-app-nudges" },
          { kind: "leaf", label: "Stories", to: "/product/Campaigns/stories" },
          { kind: "leaf", label: "Surveys", to: "/product/Campaigns/surveys" },
          { kind: "leaf", label: "Referrals", to: "/product/Campaigns/referrals" },
          { kind: "leaf", label: "Streaks", to: "/product/Campaigns/streaks" },
          { kind: "leaf", label: "Challenges", to: "/product/Campaigns/challenges" },
          { kind: "leaf", label: "Display Rules", to: "/product/Campaigns/display-rules" },
        ],
      },
      {
        kind: "section",
        label: "Visual Builder",
        to: "/product/VisualBuilder",
        children: [
          { kind: "leaf", label: "Overview", to: "/product/VisualBuilder" },
          { kind: "leaf", label: "Interfaces", to: "/product/VisualBuilder/Interfaces" },
          { kind: "leaf", label: "Widgets", to: "/product/VisualBuilder/widgets" },
          { kind: "leaf", label: "Actions", to: "/product/VisualBuilder/actions" },
          { kind: "leaf", label: "Variables", to: "/product/VisualBuilder/variables" },
        ],
      },
      { kind: "leaf", label: "Flows", to: "/product/Flows" },
    ],
  },
  {
    kind: "section",
    label: "Integrations",
    to: "/integrations",
    icon: "Plug",
    children: [
      { kind: "leaf", label: "Overview", to: "/integrations" },
      { kind: "leaf", label: "Shopify", to: "/integrations/shopify.integration" },
      {
        kind: "section",
        label: "Cohorts Sync",
        to: "/integrations/cohorts-sync",
        children: [
          { kind: "leaf", label: "Overview", to: "/integrations/cohorts-sync" },
          { kind: "leaf", label: "Amplitude", to: "/integrations/cohorts-sync/amplitude" },
          { kind: "leaf", label: "Mixpanel", to: "/integrations/cohorts-sync/mixpanel" },
          { kind: "leaf", label: "CleverTap", to: "/integrations/cohorts-sync/clevertap" },
          { kind: "leaf", label: "CSV Import", to: "/integrations/cohorts-sync/csv-import" },
        ],
      },
      {
        kind: "section",
        label: "Google Tag Manager",
        to: "/integrations/google-tag-manager",
        children: [
          { kind: "leaf", label: "Overview", to: "/integrations/google-tag-manager" },
          { kind: "leaf", label: "Set up", to: "/integrations/google-tag-manager/set-up" },
          { kind: "leaf", label: "Data Layer", to: "/integrations/google-tag-manager/data-layer" },
        ],
      },
    ],
  },
  {
    kind: "section",
    label: "Security",
    to: "/security",
    icon: "Shield",
    children: [
      { kind: "leaf", label: "Overview", to: "/security" },
      { kind: "leaf", label: "Short-Lived Token Auth", to: "/security/authentication" },
      { kind: "leaf", label: "Data and Privacy", to: "/security/data-privacy" },
    ],
  },
  { kind: "leaf", label: "Callback Integration", to: "/callback-integration" },
  { kind: "leaf", label: "Release Notes", to: "/releasenotes" },
  { kind: "leaf", label: "FAQ", to: "/faq" },
];

export function flattenNav(nodes: NavNode[] = navigation): { label: string; to: string }[] {
  const out: { label: string; to: string }[] = [];
  const walk = (list: NavNode[]) => {
    for (const n of list) {
      if (n.kind === "leaf") out.push({ label: n.label, to: n.to });
      else walk(n.children);
    }
  };
  walk(nodes);
  return out;
}
