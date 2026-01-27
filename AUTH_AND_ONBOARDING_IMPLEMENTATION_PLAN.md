# Auth & Onboarding Implementation Plan

**Overall Progress:** `0%`

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

- [ ] 🟥 **Step 1: Create Reusable Auth Button Component**
  - [ ] 🟥 Create `AuthButtonView.swift` with consistent styling
  - [ ] 🟥 Support Phone, Google, Apple variants with proper icons
  - [ ] 🟥 Rounded style, 48pt height, icon + centered text
  - [ ] 🟥 Match Instagram/Airbnb reference designs
  - [ ] 🟥 Handle enabled/disabled states
  - [ ] 🟥 Add proper tap handling closure

- [ ] 🟥 **Step 2: Create Welcome Page with Logo Animation**
  - [ ] 🟥 Create `WelcomeView.swift`
  - [ ] 🟥 Add "Welcome to Notelayer" text + Notelayer logo (centered)
  - [ ] 🟥 Create `AnimatedLogoView` with spin + confetti shatter effect
  - [ ] 🟥 Add auth buttons using `AuthButtonView` (Phone, Google, Apple order)
  - [ ] 🟥 Add "Nah, I don't want to backup" dismiss button at bottom
  - [ ] 🟥 Brief sync benefit text (regular language, not technical)
  - [ ] 🟥 Use themed background consistent with app
  - [ ] 🟥 Sheet presentation with drag indicator

- [ ] 🟥 **Step 3: Create Welcome Coordinator & State Management**
  - [ ] 🟥 Create `WelcomeCoordinator.swift` to track dismissal state
  - [ ] 🟥 Use UserDefaults with app group: `group.com.notelayer.app`
  - [ ] 🟥 Add `hasSeenWelcome` boolean key
  - [ ] 🟥 Logic: Show welcome if NOT signed in AND NOT dismissed before
  - [ ] 🟥 Permanent dismissal on "Nah, I don't want to backup" tap

- [ ] 🟥 **Step 4: Integrate Welcome Page into App Launch**
  - [ ] 🟥 Modify `RootTabsView.swift` to check welcome state
  - [ ] 🟥 Add 0.5s delay before showing welcome sheet
  - [ ] 🟥 Pass `AuthService` as environment object to welcome
  - [ ] 🟥 Auto-dismiss welcome after successful sign-in
  - [ ] 🟥 Never show again after dismissal

- [ ] 🟥 **Step 5: Create Profile & Settings Page**
  - [ ] 🟥 Create `ProfileSettingsView.swift`
  - [ ] 🟥 **When NOT signed in:**
    - [ ] 🟥 "Sign in to sync" prominent message
    - [ ] 🟥 Auth buttons (Phone, Google, Apple) using `AuthButtonView`
    - [ ] 🟥 Brief explanation of sync benefits
  - [ ] 🟥 **When signed in:**
    - [ ] 🟥 Auth status section: "Signed in with [method]"
    - [ ] 🟥 Display user identifier (email/phone)
    - [ ] 🟥 Last sync time: "Last synced: X mins ago" or "Syncing..." or "Sync error"
    - [ ] 🟥 Sign out button (destructive style)
  - [ ] 🟥 **About section (not prominent):**
    - [ ] 🟥 "About the app" collapsible section
    - [ ] 🟥 App version from Bundle
    - [ ] 🟥 Privacy policy link placeholder
  - [ ] 🟥 Use `InsetCard` for sections
  - [ ] 🟥 Sheet presentation with medium/large detents

- [ ] 🟥 **Step 6: Add Sync Status Tracking & Badge Logic**
  - [ ] 🟥 Add sync status enum to `AuthService` or `SyncService`
  - [ ] 🟥 States: `notSignedIn`, `signedInSynced`, `signedInSyncError`
  - [ ] 🟥 Publish sync status changes
  - [ ] 🟥 Create computed property: `shouldShowBadge` (true if not signed in or sync error)
  - [ ] 🟥 Create computed property: `badgeColor` (red = not signed in, yellow = sync error)
  - [ ] 🟥 Track last sync timestamp
  - [ ] 🟥 Detect sync errors from Firebase

- [ ] 🟥 **Step 7: Update TodosView Gear Menu**
  - [ ] 🟥 Add notification badge overlay on gear icon
  - [ ] 🟥 Badge shows red/yellow dot based on sync status
  - [ ] 🟥 Replace "Authentication" menu item with "Profile & Settings"
  - [ ] 🟥 Keep "Appearance" and "Manage Categories" as-is
  - [ ] 🟥 Add sheet presentation for Profile & Settings
  - [ ] 🟥 Remove `showingAuthentication` state
  - [ ] 🟥 Add `showingProfileSettings` state

- [ ] 🟥 **Step 8: Add Gear Menu to NotesView**
  - [ ] 🟥 Add gear icon to top-right (match TodosView position)
  - [ ] 🟥 Add notification badge overlay (same logic as TodosView)
  - [ ] 🟥 Add identical menu: Profile & Settings, Appearance, Manage Categories
  - [ ] 🟥 Add sheet presentations for all menu items
  - [ ] 🟥 Share sync status from AuthService
  - [ ] 🟥 Ensure consistent styling with TodosView

- [ ] 🟥 **Step 9: Redesign SignInSheet UI**
  - [ ] 🟥 Replace native Apple/Google buttons with custom `AuthButtonView`
  - [ ] 🟥 Reorder: Phone (top), Google, Apple
  - [ ] 🟥 Keep phone auth as inline input (country picker + number field)
  - [ ] 🟥 Ensure numeric keypad for phone input
  - [ ] 🟥 Remove signed-in state display from SignInSheet
  - [ ] 🟥 Keep clean spacing and modern aesthetics
  - [ ] 🟥 Maintain two-step phone flow (number → code)

- [ ] 🟥 **Step 10: Fix Auth Flow Logic**
  - [ ] 🟥 Check if user already authenticated before allowing different method
  - [ ] 🟥 Show error if trying to sign in with different method than existing account
  - [ ] 🟥 Auto-dismiss sheet immediately after successful authentication
  - [ ] 🟥 Clear phone verification state on sheet dismiss
  - [ ] 🟥 Prevent multiple simultaneous auth attempts

- [ ] 🟥 **Step 11: Fix Firebase Crashes**
  - [ ] 🟥 Remove all `Task.sleep()` timing workarounds from SignInSheet
  - [ ] 🟥 Remove retry loops in `waitForPresenter()` and `findKeyWindow()`
  - [ ] 🟥 Use proper SwiftUI lifecycle: `.task` modifier instead of `onAppear` with async
  - [ ] 🟥 Validate Firebase initialization before auth flows
  - [ ] 🟥 Add proper error handling without presentation timing hacks
  - [ ] 🟥 Remove `isSheetReady` delay mechanism
  - [ ] 🟥 Test on iPhone 16e and 17 Pro simulators

- [ ] 🟥 **Step 12: Improve Phone Auth UX**
  - [ ] 🟥 Add country code picker (default US +1)
  - [ ] 🟥 Format phone number as user types (add dashes/spaces)
  - [ ] 🟥 Show verification code step clearly
  - [ ] 🟥 Add "Resend code" button with countdown timer
  - [ ] 🟥 Clear error messages for invalid phone numbers
  - [ ] 🟥 Proper APNS setup validation

- [ ] 🟥 **Step 13: Polish & Visual Consistency**
  - [ ] 🟥 Ensure all auth buttons match across WelcomeView, ProfileSettings, SignInSheet
  - [ ] 🟥 Use consistent loading states throughout
  - [ ] 🟥 Match app's design language for errors
  - [ ] 🟥 Test logo animation with reduce motion accessibility
  - [ ] 🟥 Verify VoiceOver labels on all new UI
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
