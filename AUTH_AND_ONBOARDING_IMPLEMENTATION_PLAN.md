# Auth & Onboarding Implementation Plan

**Overall Progress:** `93%`

## TLDR
Complete authentication UX overhaul: Add non-intrusive welcome page with logo animation, redesign auth UI with consistent styling (Phone → Google → Apple), create Profile & Settings page with sync status, add notification badges to gear icons, and fix Firebase crashes. Make auth seamless, clear, and delightful.

## Critical Decisions
- **Welcome page**: Show once on first launch with 0.5s delay, dismissible forever with "Nah, I don't want to backup" CTA
- **Button order**: Phone → Google → Apple (consistent everywhere)
- **Button style**: Custom rounded buttons with icons, 48pt height (no native Apple/Google buttons)
- **Badge system**: Red dot = not signed in, Yellow dot = sync error, visible on gear icons in both tabs
- **Gear menu**: Global across TodosView and NotesView, replace "Authentication" with "Profile & Settings"
- **Auth state separation**: Move signed-in state OUT of SignInSheet, INTO Profile & Settings page
- **Single auth method**: Prevent linking multiple providers per account
- **Logo animation**: Spin + confetti shatter effect, under 1 second, playful not jarring

## Tasks

- [x] 🟩 **Step 1: Create Reusable Auth Button Component**
  - [x] 🟩 Create `AuthButtonView.swift` with consistent styling
  - [x] 🟩 Support Phone, Google, Apple variants with proper icons
  - [x] 🟩 Rounded style, 48pt height, icon + centered text
  - [x] 🟩 Match Instagram/Airbnb reference designs
  - [x] 🟩 Handle enabled/disabled states
  - [x] 🟩 Add proper tap handling closure

- [x] 🟩 **Step 2: Create Welcome Page with Logo Animation**
  - [x] 🟩 Create `WelcomeView.swift`
  - [x] 🟩 Add "Welcome to Notelayer" text + Notelayer logo (centered)
  - [x] 🟩 Create `AnimatedLogoView` with spin + confetti shatter effect
  - [x] 🟩 Add auth buttons using `AuthButtonView` (Phone, Google, Apple order)
  - [x] 🟩 Add "Nah, I don't want to backup" dismiss button at bottom
  - [x] 🟩 Brief sync benefit text (regular language, not technical)
  - [x] 🟩 Use themed background consistent with app
  - [x] 🟩 Sheet presentation with drag indicator

- [x] 🟩 **Step 3: Create Welcome Coordinator & State Management**
  - [x] 🟩 Create `WelcomeCoordinator.swift` to track dismissal state
  - [x] 🟩 Use UserDefaults with app group: `group.com.notelayer.app`
  - [x] 🟩 Add `hasSeenWelcome` boolean key
  - [x] 🟩 Logic: Show welcome if NOT signed in AND NOT dismissed before
  - [x] 🟩 Permanent dismissal on "Nah, I don't want to backup" tap

- [x] 🟩 **Step 4: Integrate Welcome Page into App Launch**
  - [x] 🟩 Modify `RootTabsView.swift` to check welcome state
  - [x] 🟩 Add 0.5s delay before showing welcome sheet
  - [x] 🟩 Pass `AuthService` as environment object to welcome
  - [x] 🟩 Auto-dismiss welcome after successful sign-in
  - [x] 🟩 Never show again after dismissal

- [x] 🟩 **Step 5: Create Profile & Settings Page**
  - [x] 🟩 Create `ProfileSettingsView.swift`
  - [x] 🟩 **When NOT signed in:**
    - [x] 🟩 "Sign in to sync" prominent message
    - [x] 🟩 Auth buttons (Phone, Google, Apple) using `AuthButtonView`
    - [x] 🟩 Brief explanation of sync benefits
  - [x] 🟩 **When signed in:**
    - [x] 🟩 Auth status section: "Signed in with [method]"
    - [x] 🟩 Display user identifier (email/phone)
    - [x] 🟩 Last sync time: "Last synced: X mins ago" or "Syncing..." or "Sync error"
    - [x] 🟩 Sign out button (destructive style)
  - [x] 🟩 **About section (not prominent):**
    - [x] 🟩 "About the app" collapsible section
    - [x] 🟩 App version from Bundle
    - [x] 🟩 Privacy policy link placeholder
  - [x] 🟩 Use `InsetCard` for sections
  - [x] 🟩 Sheet presentation with medium/large detents

- [x] 🟩 **Step 6: Add Sync Status Tracking & Badge Logic**
  - [x] 🟩 Add sync status enum to `AuthService` or `SyncService`
  - [x] 🟩 States: `notSignedIn`, `signedInSynced`, `signedInSyncError`
  - [x] 🟩 Publish sync status changes
  - [x] 🟩 Create computed property: `shouldShowBadge` (true if not signed in or sync error)
  - [x] 🟩 Create computed property: `badgeColor` (red = not signed in, yellow = sync error)
  - [x] 🟩 Track last sync timestamp
  - [x] 🟩 Detect sync errors from Firebase

- [x] 🟩 **Step 7: Update TodosView Gear Menu**
  - [x] 🟩 Add notification badge overlay on gear icon
  - [x] 🟩 Badge shows red/yellow dot based on sync status
  - [x] 🟩 Replace "Authentication" menu item with "Profile & Settings"
  - [x] 🟩 Keep "Appearance" and "Manage Categories" as-is
  - [x] 🟩 Add sheet presentation for Profile & Settings
  - [x] 🟩 Remove `showingAuthentication` state
  - [x] 🟩 Add `showingProfileSettings` state

- [x] 🟩 **Step 8: Add Gear Menu to NotesView**
  - [x] 🟩 Add gear icon to top-right (match TodosView position)
  - [x] 🟩 Add notification badge overlay (same logic as TodosView)
  - [x] 🟩 Add identical menu: Profile & Settings, Appearance, Manage Categories
  - [x] 🟩 Add sheet presentations for all menu items
  - [x] 🟩 Share sync status from AuthService
  - [x] 🟩 Ensure consistent styling with TodosView

- [x] 🟩 **Step 9: Redesign SignInSheet UI**
  - [x] 🟩 Replace native Apple/Google buttons with custom `AuthButtonView`
  - [x] 🟩 Reorder: Phone (top), Google, Apple
  - [x] 🟩 Keep phone auth as inline input (country picker + number field)
  - [x] 🟩 Ensure numeric keypad for phone input
  - [x] 🟩 Remove signed-in state display from SignInSheet
  - [x] 🟩 Keep clean spacing and modern aesthetics
  - [x] 🟩 Maintain two-step phone flow (number → code)

- [x] 🟩 **Step 10: Fix Auth Flow Logic**
  - [x] 🟩 Check if user already authenticated before allowing different method
  - [x] 🟩 Show error if trying to sign in with different method than existing account
  - [x] 🟩 Auto-dismiss sheet immediately after successful authentication
  - [x] 🟩 Clear phone verification state on sheet dismiss
  - [x] 🟩 Prevent multiple simultaneous auth attempts

- [x] 🟩 **Step 11: Fix Firebase Crashes**
  - [x] 🟩 Remove all `Task.sleep()` timing workarounds from SignInSheet
  - [x] 🟩 Remove retry loops in `waitForPresenter()` and `findKeyWindow()`
  - [x] 🟩 Use proper SwiftUI lifecycle: `.task` modifier instead of `onAppear` with async
  - [x] 🟩 Validate Firebase initialization before auth flows
  - [x] 🟩 Add proper error handling without presentation timing hacks
  - [x] 🟩 Remove `isSheetReady` delay mechanism
  - [ ] 🟥 Test on iPhone 16e and 17 Pro simulators

- [x] 🟩 **Step 12: Improve Phone Auth UX**
  - [x] 🟩 Add country code picker (default US +1)
  - [x] 🟩 Format phone number as user types (add dashes/spaces)
  - [x] 🟩 Show verification code step clearly
  - [x] 🟩 Add "Resend code" button with countdown timer
  - [x] 🟩 Clear error messages for invalid phone numbers
  - [x] 🟩 Proper APNS setup validation

- [x] 🟩 **Step 13: Polish & Visual Consistency**
  - [x] 🟩 Ensure all auth buttons match across WelcomeView, ProfileSettings, SignInSheet
  - [x] 🟩 Use consistent loading states throughout
  - [x] 🟩 Match app's design language for errors
  - [x] 🟩 Test logo animation with reduce motion accessibility
  - [x] 🟩 Verify VoiceOver labels on all new UI
  - [ ] 🟥 Test Dynamic Type scaling
  - [ ] 🟥 Ensure badge visibility on all theme presets

- [ ] 🟥 **Step 14: End-to-End Testing**
  - [ ] 🟥 **First launch flow:**
    - [ ] 🟥 Welcome page appears after 0.5s
    - [ ] 🟥 Logo animation plays smoothly
    - [ ] 🟥 "Nah, I don't want to backup" dismisses forever
    - [ ] 🟥 Gear badge appears after dismissal
  - [ ] 🟥 **Sign-in flows:**
    - [ ] 🟥 Phone auth works end-to-end
    - [ ] 🟥 Google sign-in works without crashes
    - [ ] 🟥 Apple sign-in works without crashes
    - [ ] 🟥 Badge clears after successful sign-in
  - [ ] 🟥 **Profile & Settings:**
    - [ ] 🟥 Shows correct auth status when signed in
    - [ ] 🟥 Displays sync status accurately
    - [ ] 🟥 Sign out works and updates UI
    - [ ] 🟥 Works from both Todos and Notes tabs
  - [ ] 🟥 **Edge cases:**
    - [ ] 🟥 Verify only one auth method active per account
    - [ ] 🟥 Test sync error badge (yellow dot)
    - [ ] 🟥 Test on physical device
    - [ ] 🟥 Verify no Firebase crashes

## Design Reference Notes

### From Instagram/Airbnb Examples
- Phone auth at top with direct input
- Country picker integrated cleanly  
- All auth buttons same height, consistent rounded style
- Icons left-aligned, text centered
- Clean spacing between options
- Minimal text, clear CTAs

### App-Specific Details
- Welcome text: "Welcome to Notelayer"
- Dismiss CTA: "Nah, I don't want to backup" (or similar droll variant)
- Badge colors: Red = not signed in, Yellow = sync error
- Logo animation: Spin + confetti shatter, under 1 second
- Sync message: Regular language, not technical terms

## Files to Create
1. `WelcomeView.swift` - Welcome page with logo animation
2. `AnimatedLogoView.swift` - Logo animation component
3. `ProfileSettingsView.swift` - Profile & Settings page
4. `AuthButtonView.swift` - Reusable auth button component
5. `WelcomeCoordinator.swift` - Welcome state management

## Files to Modify
1. `RootTabsView.swift` - Show welcome on first launch
2. `TodosView.swift` - Update gear menu, add badge
3. `NotesView.swift` - Add gear icon with menu and badge
4. `SignInSheet.swift` - Redesign UI with custom buttons
5. `AuthService.swift` - Add sync status tracking
6. `SyncService.swift` - Track last sync time
7. `FirebaseBackendService.swift` - Emit sync status changes

## Success Metrics
- Welcome page appears only once, dismissible forever
- Logo animation is smooth and delightful
- Auth UI is consistent across all entry points
- Gear icons show accurate sync status badges
- Profile & Settings clearly communicates auth state
- No Firebase crashes on sign-in flows
- Single auth method enforced per account
- Phone auth flows work reliably
