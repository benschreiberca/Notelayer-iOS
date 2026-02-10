# Welcome Page & Profile Settings Exploration

## Summary
Add a non-intrusive welcome page on first launch with auth options, and create a comprehensive Profile & Settings page accessible from a global gear menu in both tabs. Include sync status indicators and notification badges.

## Key Requirements

### 1. Welcome Page
**When to show:**
- Only if user hasn't signed in AND hasn't dismissed it before
- Track dismissal state in UserDefaults
- Never show again after first dismissal (even if not signed in)

**Content:**
- Notelayer logo (centered)
- Fun logo animation: spin + shatter/confetti effect (like iMessage confetti)
- Auth buttons: Phone (top), Google, Apple - consistent styling
- Brief text: Regular language explaining that login enables cloud sync
- Dismiss button with droll, short CTA (e.g., "Maybe later", "Skip for now")
- Note below skip: Short reminder that not signing in = no cloud backup (regular language)

**Dismissal:**
- Easy to tap, obvious
- One-time dismissal (stored in UserDefaults)
- After dismissal, gear icon shows notification badge if not signed in

### 2. Profile & Settings Page
**Access:**
- New menu item in gear menu: "Profile & Settings"
- Global feature: same gear icon + menu in both TodosView AND NotesView

**Content when NOT signed in:**
- "Sign in to sync" message
- Auth buttons: Phone, Google, Apple (same as welcome page)
- Brief explanation of benefits

**Content when signed in:**
- Auth status section (prominent):
  - "Signed in with [Phone/Google/Apple]"
  - User identifier (email/phone number)
  - Last sync time: "Last synced: [relative time]" or "Syncing..." or "Sync issue"
  - Sign out button
- "About the app" section (not prominent):
  - App version
  - Privacy policy link
  - Other legal/info links as needed

### 3. Gear Icon & Notification Badge
**Gear Icon Location:**
- TodosView: Already exists (top-right)
- NotesView: Add identical gear icon (top-right, same position)

**Gear Menu Items:**
- Profile & Settings (NEW)
- Appearance (existing)
- Manage Categories (existing)
- Authentication (REMOVE - replaced by Profile & Settings)

**Notification Badge:**
- Show red dot/badge on gear icon when:
  - User not signed in
  - Sync connection issue detected
- Badge visible on both TodosView and NotesView gear icons
- Clear badge when user signs in successfully and sync is working

### 4. Logo Animation
**Effect:**
- Logo appears centered on screen
- Spinning rotation effect
- Shatter/pop with confetti-like particles
- Similar to iMessage confetti effect
- Quick animation (under 1 second)
- Smooth, playful, not jarring

## Technical Implementation Notes

### Files to Create
1. `WelcomeView.swift` - Welcome page with logo animation
2. `ProfileSettingsView.swift` - Profile & Settings page
3. `WelcomeCoordinator.swift` - Tracks if welcome has been shown/dismissed

### Files to Modify
1. `NotelayerApp.swift` - Show welcome page on first launch
2. `RootTabsView.swift` or `TodosView.swift` - Add welcome coordination
3. `TodosView.swift` - Update gear menu, add badge indicator
4. `NotesView.swift` - Add gear icon with menu, add badge indicator
5. `SignInSheet.swift` - May reuse components for consistent button styling
6. `AuthService.swift` - May need sync status tracking

### State Management
**UserDefaults keys:**
- `hasSeenWelcome` - Boolean, true if user has dismissed welcome
- Could reuse existing app group: `group.com.notelayer.app`

**Sync Status:**
- Track in AuthService or SyncService
- Emit state changes for notification badge
- States: signed out, signed in + synced, signed in + sync issue

### Auth Button Component
Create reusable `AuthButtonView` component:
- Consistent styling across WelcomeView, ProfileSettingsView, SignInSheet
- Phone, Google, Apple variants
- Rounded, 48pt height, icon + text
- Matches Instagram/Airbnb reference designs

### Logo Animation Component
Create `AnimatedLogoView`:
- SwiftUI animation using `.rotationEffect()` and `.scaleEffect()`
- Custom particle effect for shatter/confetti
- Could use `GeometryEffect` or `Canvas` for particles
- Trigger on appear, auto-complete

## Open Questions / Decisions Needed

### Design Specifics
1. ✅ **Welcome page background** - Use same themed background as rest of app?
2. ✅ **Logo size** - How large should the logo be on welcome page?
3. ✅ **Skip button placement** - Bottom of screen, below auth buttons?
4. ✅ **Profile & Settings presentation** - Sheet or NavigationLink? (Probably sheet to match existing patterns)

### Behavior
1. ✅ **Welcome page timing** - Show immediately on launch or after slight delay?
2. ✅ **Badge persistence** - Should badge show every session or user can permanently dismiss?
3. ✅ **Sync status refresh** - How often to check sync status for badge?

### Copy/Messaging
1. ✅ **Welcome headline** - What text above/below logo? Just "Welcome to Notelayer"?
2. ✅ **Sync explanation** - Exact wording for "sign in to sync" messaging?
3. ✅ **Skip button text** - Suggestions: "Maybe later", "Skip for now", "Nah, I'm good"?
4. ✅ **No backup warning** - Exact wording for "not signing in = no cloud backup"?

## User Flow Examples

### First Launch (Not Signed In)
1. App launches → WelcomeView appears
2. Logo animation plays (spin + confetti)
3. User sees auth options + skip button
4. **Option A:** User taps skip → Welcome dismissed forever, gear badge appears
5. **Option B:** User signs in → Welcome dismissed, no badge, Profile shows auth status

### Returning User (Not Signed In, Dismissed Welcome)
1. App launches → Goes straight to TodosView
2. Gear icon shows notification badge
3. User taps gear → Sees "Profile & Settings" in menu
4. User taps Profile & Settings → Can sign in

### Signed In User
1. App launches → Goes straight to TodosView (no welcome)
2. Gear icon has no badge
3. User taps gear → Sees "Profile & Settings" in menu
4. User taps Profile & Settings → Sees auth status, last sync, sign out option

## Consistency with Existing Patterns

### Visual Style
- Use existing `InsetCard` component
- Match `ThemeManager` and color tokens
- Consistent button styling with rest of app
- Use system fonts and spacing

### Interaction Patterns
- Sheet presentations with `.presentationDetents([.medium, .large])`
- `.presentationDragIndicator(.visible)`
- Match existing animation durations and styles
- Maintain accessibility (VoiceOver, Dynamic Type, Reduce Motion)

### Architecture
- SwiftUI views with `@StateObject` for data
- `@EnvironmentObject` for AuthService
- Use existing LocalStore app group for persistence
- Follow existing error handling patterns

## Success Criteria
- [ ] Welcome page appears only on first launch (if not signed in)
- [ ] Welcome can be dismissed and never shows again
- [ ] Logo animation is smooth and playful
- [ ] Gear icon appears on both Todos and Notes tabs
- [ ] Gear icon shows badge when not signed in or sync issues
- [ ] Profile & Settings clearly shows auth status
- [ ] Profile & Settings allows signing in when not authenticated
- [ ] All auth buttons have consistent styling
- [ ] Sync status is accurate and updates appropriately
- [ ] No crashes related to Firebase presentation timing
