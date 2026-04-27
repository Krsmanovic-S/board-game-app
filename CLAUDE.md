# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run

# Tests
flutter test
flutter test test/path/to/test.dart   # single test file
```

## Architecture

### Controllers
`InheritedNotifier` pattern is used. Controllers live in `lib/controllers/`. 
Current controllers: `AuthController`, `WatchlistController`, `SettingsController`, `TipController`.
Wrap the widget tree with scopes in `main.dart`, access via `context.findAncestorStateOfType` or a static `.of(context)` method on each scope.

### Routing
`go_router` is configured in `lib/app/router.dart`. It should be used to navigate to different screens.

### Navigation & Screen Architecture

Bottom navigation bar with 3 tabs:
- **Browse** - paginated list of all games, filter chips (in stock, price range), sort options
- **Watchlist** - games the user is watching with current prices and stock status
- **Profile** - user info, username, avatar placeholder

Each tab is a top-level destination. Nested navigation within tabs uses go_router.

#### Screens
- `AuthScreen` - login/register with Google, Apple, email+password
- `ForgotPasswordScreen` - separate screen, not a dialog
- `UsernamePickerScreen` - shown once after register before entering the app
- `BrowseScreen` - main game listing, infinite scroll
- `SearchScreen` - opens from search bar on BrowseScreen, queries Firestore as user types
- `ProductScreen` - game details, per-store price breakdown, price history chart, watch/unwatch button, per-game notification toggles if watched
- `WatchlistScreen` - watched games list
- `ProfileScreen` - username, email, avatar placeholder
- `SettingsScreen` - accessible via gear icon from ProfileScreen, contains theme picker, global notification toggles, sound toggle, tip jar

#### Layout
Screens that are children of a tab (SearchScreen, ProductScreen, SettingsScreen) are pushed on top of the tab stack, not as new bottom nav destinations.

Never hardcode sized box widgets, instead use the `lib/app/layout.dart` class to create dynamic widgets. Never use hardcoded values for pixels, height, width, padding - use the Layout class for everything.

### Widgets
All widgets are located in the `lib/screens/` (holds entire screen widgets) and `lib/widgets/` (individual components) folders. The folder `lib/utils/` contains helper classes for handling specific part of the application.

### Models
All Dart models live in `lib/models/`. Each model that maps to Firestore has a `fromFirestore(DocumentSnapshot)` factory and a `toFirestore()` method. Models: `AppUser`, `BoardGame`, `StoreInfo`, `WatchlistItem`, `PriceHistoryEntry`, `AppSettings`.

### Notifications
FCM tokens are saved to `users/{userId}/fcmToken` on login and whenever the token refreshes. The scraper (external, not in this repo) reads these tokens and sends notifications. The app only needs to: save the token, handle incoming messages via `firebase_messaging`, and display them via `flutter_local_notifications`.

### Database
Firebase is the source database for board game products, watchlist, and price history. `shared_preferences` package is used for locally related settings — theme, sounds, anything device-specific and which doesn't need to sync across devices.

A scrapper runs daily and pushes scraped board game data into Firestore, we access that data here (no modification).

Global notification toggles (priceDrop, priceIncrease etc.) live in Firestore under `users/{userId}` since the scraper reads them to decide whether to send FCM.

Schema that is used for each product in Firebase:
{
    "id": "7685c03ca8b2fa4185e08a55b8e3f703",
    "name": "Hot Streak",
    "lowestPrice": 6000,
    "lowestPriceStore": "games4you",
    "inStockAnywhere": true,
    "storeInfo": {
      "games4you": {
        "price": 6000,
        "inStock": true,
        "image": "https://games-for-you...",
        "sourceUrl": "https://games4you.rs/proizvodi/drustvene-igre/...",
        "updatedAt": "2026-04-25T10:13:45.052Z"
      },
      "mipl": {
        "price": 6000,
        "inStock": true,
        "image": "https://www.drustveneigre.rs/image/...",
        "sourceUrl": "https://www.drustveneigre.rs/drustvene-igre/...",
        "updatedAt": "2026-04-25T10:23:31.173Z"
      },
      "gnom": {
        "price": 6190,
        "inStock": false,
        "image": "https://gnom.rs/image/cache/catalog/drustvene%20igre/...",
        "sourceUrl": "https://gnom.rs/hot-streak-sr",
        "updatedAt": "2026-04-24T22:30:06.549Z"
      },
      "kraken": {
        "price": 6000,
        "inStock": true,
        "image": "https://www.kraken.rs/wp-content/uploads/...",
        "sourceUrl": "https://www.kraken.rs/proizvod/...",
        "updatedAt": "2026-04-25T10:29:34.984Z"
      }
    }
}

### Auth
Users have profiles and can register/login with an email and password. Relevant data for each user: username (unique), email (unique), password (crypted).
Watched games are stored as a Firestore subcollection `watchlist/{userId}/items/{productId}` rather than a field on the user document. Each item contains: productId, notifyPriceDrop, notifyPriceIncrease, notifyOutOfStock, notifyBackInStock, addedAt.
Login and register options include 'Continue with Google' and 'Continue with Apple' for easier and quicker registration and login.

### Theming & Localization
All colors, text styles, and button styles live in `lib/app/theme.dart` as three abstract classes: `AppColors`, `AppTextStyles`, `AppButtonStyles`. Edit these to retheme the app. Never hardcode colors or text styles inline — always reference these classes.

Main localization file is in `lib/localization/localization.dart`, this should be used for any text within the app, never hardcode string values. For adding new entries, a getter must be implemented in that file and the appropriate translation should be in `lib/localization/lang` folder. Supported languages should include Serbian and English. Take into account the presence of cyrilic letters in Serbian.

### Features
Scrapper runs via Github Actions, gathers and processes all information from different stores and sends it to Firebase (not inside this app).

Profile creation and management - users can create and edit their profiles within the app. Must be logged in to proceed into the app.

Marking and unmarking board games as 'watched' - recieves a notification about the game and what is new about it (now in stock, price drop, price increase etc..).

### Packages
`go_router` - navigation
`in_app_purchase` - tip jar (three tiers, see TipService)
`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging` - Firebase stack
`shared_preferences` - local settings only
`cached_network_image` - product images
`fl_chart` - price history chart
`url_launcher` - opening store URLs
`flutter_local_notifications` - foreground FCM display