# EmbedCraft

# InAppNinja (EmbedCraft)

A powerful, high-performance Flutter SDK for displaying in-app campaigns, user engagement nudges, and interactive experiences.

## Features

- **Rich Tooltips**: Attach contextual guidance tooltips to any Flutter widget.
- **Stories**: Dynamic, Instagram-like stories inside your app.
- **Challenges & Gamification**: Custom progress trackers, scratch cards, and spin-the-wheels.
- **Multiple Formats**: In-app bottom sheets, modals, Picture-in-Picture widgets, banners, and inline elements.
- **Targeting Engine**: Evaluate campaign targets based on event tracking and user properties.
- **Custom HTML Layers**: Render custom web content cleanly in a sandboxed view.

## Installation

Add `in_app_ninja` to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_ninja: ^1.0.0
```

Run:
```bash
flutter pub get
```

## Getting Started

### 1. Initialize the SDK

Initialize `AppNinja` during app startup with your API key:

```dart
import 'package:in_app_ninja/in_app_ninja.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppNinja.init(
    'YOUR_API_KEY',
    autoRender: true,
  );
  
  runApp(const MyApp());
}
```

### 2. Identify Users

Set user properties for personalized targeting:

```dart
await AppNinja.userIdentifier(
  externalId: 'user_123',
  name: 'John Doe',
  email: 'john.doe@example.com',
  userProperties: {
    'subscription': 'premium',
    'sign_up_date': '2026-06-25',
  },
);
```

### 3. Track Events

Track actions to trigger campaigns dynamically:

```dart
await AppNinja.track('add_to_cart', properties: {
  'item_id': 'prod_99',
  'category': 'footwear',
});
```

### 4. Track Pages

Track current screen changes to target page-specific nudges:

```dart
AppNinja.trackPage('checkout_screen', context);
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.


## Dashboard Login

To run the dashboard, use the following login details:

- Email: `big@mail.com`
- Password: `Au20052005`

The dashboard is linked with the Test App. You can link it with any app by following the documentation.

## Deployment Links

- [EmbedCraft](https://embedcraft.com)
- [EmbedCraft Dashboard](https://dashboard.embedcraft.com)
- [EmbedCraft Documentation](https://docs.embedcraft.com)
