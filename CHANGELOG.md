# Changelog

## Unreleased

### Added
- Firebase Firestore backend sync service for notes/tasks/categories with per-user collections and realtime listeners.
- Push Notifications capability and `aps-environment` entitlement to support phone auth via APNs.
- Explicit `Info.plist` checked in for URL schemes and app configuration.
- Project Cursor slash command templates under `.cursor/commands`.
- Command implementation tracking doc for the new slash commands.

### Changed
- App bootstrap now guards Firebase configuration and initializes the backend sync service on launch.
- Local store writes through the backend when available and suppresses writes during remote snapshots.
- Auth test view delays provider sign-in until after sheet dismiss and uses a more resilient top-view-controller lookup.
- App icon asset set consolidated to a single 1024 PNG for light/dark/tinted.

### Removed
- Legacy app icon SVG assets and icon.json from the app icon source set.
