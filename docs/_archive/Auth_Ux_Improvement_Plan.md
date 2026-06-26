# Auth UX Improvement Plan

**Overall Progress:** `0%`

## TLDR
Redesign authentication UI to be clean, consistent, and user-friendly. Fix Firebase crashes, prevent multiple auth methods per user, and clearly show sync status. Phone auth first, followed by Google and Apple, with consistent button styling inspired by Instagram/Airbnb patterns.

## Critical Decisions
- **Button order**: Phone → Google → Apple (matches user preference and modern app patterns)
- **Button style**: Consistent rounded buttons with icons and clear labels (no native Apple/Google buttons - custom styled for uniformity)
- **Phone input**: Direct inline input with country picker (not expandable accordion)
- **Auth state separation**: Move signed-in state to Settings page instead of showing in sign-in sheet
- **Single auth method**: Prevent linking multiple providers - one method per account
- **Firebase stability**: Remove all timing workarounds, use proper view lifecycle hooks

## Tasks

- [ ] 🟥 **Step 1: Redesign SignInSheet UI**
  - [ ] 🟥 Create custom button component with consistent styling (rounded, 48pt height, icon + text)
  - [ ] 🟥 Reorder auth options: Phone (top), Google, Apple
  - [ ] 🟥 Replace native Apple/Google buttons with custom styled buttons using same design
  - [ ] 🟥 Add phone input section at top with country picker + phone number field
  - [ ] 🟥 Style phone input to match reference designs (clean, minimal)
  - [ ] 🟥 Ensure numeric keypad appears for phone number input
  - [ ] 🟥 Remove signed-in state display from SignInSheet
  - [ ] 🟥 Add proper spacing and padding to match modern app aesthetics

- [ ] 🟥 **Step 2: Fix Auth Flow Logic**
  - [ ] 🟥 Add check to prevent signing in with different method if already authenticated
  - [ ] 🟥 Show error if user tries to sign in with method different from existing account
  - [ ] 🟥 Auto-dismiss sheet immediately after successful authentication
  - [ ] 🟥 Clear phone verification state properly on sheet dismiss

- [ ] 🟥 **Step 3: Add Settings Page for Auth Status**
  - [ ] 🟥 Create new SettingsView/Sheet accessible from app
  - [ ] 🟥 Show current auth status: "Signed in with [Phone/Google/Apple]"
  - [ ] 🟥 Display user identifier (phone number, email, or Apple ID)
  - [ ] 🟥 Add clear "Sign Out" button in Settings
  - [ ] 🟥 Show sync status indicator (synced/local-only)
  - [ ] 🟥 Add link to sign in if not authenticated

- [ ] 🟥 **Step 4: Fix Firebase Crashes**
  - [ ] 🟥 Remove all `Task.sleep()` timing workarounds from SignInSheet
  - [ ] 🟥 Remove retry loops in `waitForPresenter()` and `findKeyWindow()`
  - [ ] 🟥 Use proper SwiftUI `.task` modifier instead of `onAppear` with async tasks
  - [ ] 🟥 Ensure Firebase is initialized before auth flows (validate in AuthService)
  - [ ] 🟥 Add proper error handling without presentation timing hacks
  - [ ] 🟥 Test on multiple simulator types to confirm stability

- [ ] 🟥 **Step 5: Improve Phone Auth UX**
  - [ ] 🟥 Add country code picker (default US +1, but allow selection)
  - [ ] 🟥 Format phone number input as user types (add dashes/spaces)
  - [ ] 🟥 Show verification code input in separate step/view
  - [ ] 🟥 Add resend code button with countdown timer
  - [ ] 🟥 Show clear error messages for invalid phone numbers

- [ ] 🟥 **Step 6: Polish & Validation**
  - [ ] 🟥 Add loading states that match app's design language
  - [ ] 🟥 Ensure all error messages are user-friendly
  - [ ] 🟥 Test full flow: sign in → use app → sign out → sign in again
  - [ ] 🟥 Verify only one auth method can be active per account
  - [ ] 🟥 Test on physical device to ensure no crashes
  - [ ] 🟥 Validate APNS setup for phone auth works correctly

## Design Reference Notes

From Instagram/Airbnb examples:
- Phone auth at top with direct input (not hidden behind button)
- Country picker integrated cleanly
- All auth buttons same height, consistent rounded style
- Icons left-aligned, text centered
- Clean spacing between options
- "or" divider between primary (phone) and social options
- Minimal text, clear CTAs
