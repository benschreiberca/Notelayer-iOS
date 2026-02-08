# Authentication and Sync Issues

## Auth crashes on refresh, phone sign-in, Google/Apple sign-in (v1.4)

- **TL;DR**: Multiple auth-related actions immediately close the app in the App Store build v1.4. Some crashes are longstanding across versions; Google/Apple is a regression in v1.4.

### Current vs Expected
- **Current**:
  - Settings → tap refresh icon: app immediately closes. (Multiple versions)
  - Sign-in → phone auth (send code or verify): app immediately closes. (Multiple versions)
  - Sign-in → Google or Apple button: app immediately closes. (v1.4; worked in v1.3 and earlier)
- **Expected**:
  - Refresh triggers sync without crashing.
  - Phone auth completes verification without crashing.
  - Google/Apple sign-in completes or shows recoverable error.

### Repro Details
- Build: v1.4 (App Store)
- Behavior: immediate app close (likely crash)
- Logs: not yet captured

### Relevant Files (initial suspects)
- `/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift`
- `/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/Views/SignInSheet.swift`
- `/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/Services/AuthService.swift`

### Risks / Notes
- Crashes in production auth flows block login paths and break sync.
- Refresh + phone auth issues appear longstanding (not a new regression).
- Google/Apple auth appears to be a regression in v1.4.
- Need crash logs to confirm root cause.

### Labels
- Type: bug
- Priority: high
- Effort: medium
