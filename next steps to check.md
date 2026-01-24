# Authentication Architecture Code Review

**Date:** January 23, 2026  
**Focus:** Potential crash points when launching authentication sign-in sheet

---

## Executive Summary

The authentication architecture is **generally well-designed** with good separation of concerns, but there are **3 critical timing/race condition issues** that could cause crashes when the sign-in sheet is first presented. These issues are related to SwiftUI sheet presentation timing and view controller hierarchy access.

**Overall Architecture Rating:** 🟢 **Good** (7.5/10)

---

## Architecture Flow

```
NotelayerApp.init()
  ├─> configureFirebaseIfNeeded()
  ├─> AuthService.init()
  │     ├─> configureFirebaseIfNeeded()
  │     └─> Auth.auth().addStateDidChangeListener()
  └─> RootTabsView
        └─> TodosView
              └─> .sheet(isPresented: $showingAuthentication) { SignInSheet() }
                    ├─> onAppear: authService.prepareForPhoneAuth()
                    └─> User taps Apple/Google button
                          ├─> Apple: signInWithApple(presentationAnchor: nil)
                          └─> Google: waitForPresenter() → signInWithGoogle()
```

---

## 🔴 CRITICAL ISSUES (High Crash Risk)

### Issue #1: Sheet Presentation Race Condition

**Location:** `SignInSheet.swift` lines 36-44

**Problem:**
```swift
AppleIDSignInButton(isEnabled: !isBusy) {
    _Concurrency.Task { await runAuthAction { try await authService.signInWithApple(presentationAnchor: nil) } }
}

GoogleSignInButton(isEnabled: !isBusy) {
    _Concurrency.Task { await startGoogleSignIn() }
}
```

**Analysis:**
- Buttons are enabled immediately when `isBusy == false`
- No check if the sheet is fully presented
- SwiftUI sheets animate in (~300-500ms), but buttons can be tapped immediately
- If tapped during animation, presentation anchors/windows may not be ready

**Crash Risk:** 🔴 **HIGH**
- Apple Sign-In: May fail to find presentation anchor
- Google Sign-In: `waitForPresenter()` may return nil or wrong controller

**Evidence:**
- `waitForPresenter()` only waits 250ms max (5 attempts × 50ms)
- Sheet animation typically takes 300-500ms
- No synchronization between sheet presentation and button availability

---

### Issue #2: Insufficient waitForPresenter() Timing

**Location:** `SignInSheet.swift` lines 216-228

**Problem:**
```swift
@MainActor
private func waitForPresenter() async -> UIViewController? {
    // Avoid presenting Google sign-in before the sheet is fully in place.
    for attempt in 0..<5 {
        if let controller = UIApplication.shared.topViewController, controller.view.window != nil {
            return controller
        }
        if attempt < 4 {
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
        await Task.yield()
    }
    return nil
}
```

**Analysis:**
- Maximum wait: 4 × 50ms = 200ms (plus yield time)
- Sheet presentation animation: ~300-500ms
- Window check (`controller.view.window != nil`) may pass before view is actually ready
- No check if view is in the view hierarchy (`view.superview != nil`)
- No check if window is key window

**Crash Risk:** 🔴 **HIGH**
- Google Sign-In SDK requires a fully presented view controller
- If controller isn't ready, `GIDSignIn.sharedInstance.signIn(withPresenting:)` may crash or fail silently

**Evidence:**
- Comment says "Avoid presenting Google sign-in before the sheet is fully in place" but timing is insufficient
- Fixed delay doesn't account for device performance variations
- No exponential backoff or readiness verification

---

### Issue #3: Apple Sign-In Presentation Anchor Fallback Logic

**Location:** `AuthService.swift` lines 124-164

**Problem:**
```swift
func signInWithApple(presentationAnchor: ASPresentationAnchor?) async throws {
    var anchor = presentationAnchor
    if anchor == nil {
        // Try multiple methods to get a window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            anchor = window
        } else if let window = UIApplication.shared.keyWindow {
            anchor = window
        } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first {
            anchor = window
        }
    }
    guard let anchor else {
        throw AuthServiceError.missingPresentationAnchor
    }
    _ = try await appleCoordinator.signIn(presentationAnchor: anchor)
}
```

**Analysis:**
- Called from `SignInSheet` with `presentationAnchor: nil` (line 37)
- Fallback logic may select wrong window if sheet is still presenting
- `UIApplication.shared.keyWindow` is deprecated and may return nil
- First window in scene may not be the correct one for sheet context
- No verification that selected window is appropriate

**Crash Risk:** 🟡 **MEDIUM-HIGH**
- Apple Sign-In may present on wrong window (behind sheet)
- May fail if no window is found
- User experience issue: Sign-In sheet may appear behind the auth sheet

**Evidence:**
- Multiple fallback attempts suggest uncertainty about window selection
- No explicit passing of sheet's window from SwiftUI context

---

## 🟡 MODERATE ISSUES (Potential Problems)

### Issue #4: Concurrent Auth Attempts

**Location:** `SignInSheet.swift` lines 36-44, 154-166

**Problem:**
```swift
@State private var isBusy = false

AppleIDSignInButton(isEnabled: !isBusy) { ... }
GoogleSignInButton(isEnabled: !isBusy) { ... }

@MainActor
private func runAuthAction(_ action: @escaping () async throws -> Void) async {
    isBusy = true  // Set AFTER button tap
    // ...
}
```

**Analysis:**
- Race condition: `isBusy` check happens before setting it
- If user rapidly taps both buttons, both auth flows may start
- Firebase Auth may handle this gracefully, but could cause unexpected state

**Crash Risk:** 🟡 **LOW-MEDIUM**
- More of a UX issue than crash risk
- Could cause confusing error states

---

### Issue #5: EnvironmentObject Dependency

**Location:** `SignInSheet.swift` line 9

**Problem:**
```swift
@EnvironmentObject private var authService: AuthService
```

**Analysis:**
- No fallback if `authService` is missing
- SwiftUI will crash at runtime if environment object not provided
- Currently safe because provided at `NotelayerApp` level (line 127)

**Crash Risk:** 🟡 **LOW** (currently safe, but fragile)

**Evidence:**
- `authService` is provided in `NotelayerApp.body` (line 127)
- If this chain breaks, app will crash with "Missing EnvironmentObject"

---

### Issue #6: Apple Sign-In Coordinator Continuation Safety

**Location:** `AuthService.swift` lines 326-336

**Problem:**
```swift
_Concurrency.Task {
    do {
        let result = try await Auth.auth().signIn(with: credential)
        continuation?.resume(returning: result)
    } catch {
        continuation?.resume(throwing: error)
    }
    continuation = nil
}
```

**Analysis:**
- If Task is cancelled, continuation might not be resumed
- No cancellation handling
- `continuation = nil` happens after resume, which is safe

**Crash Risk:** 🟢 **LOW**
- Task cancellation is handled by Swift's concurrency system
- Continuation will be deallocated if not resumed

---

## 🟢 MINOR ISSUES (Code Quality)

### Issue #7: Duplicate Code

**Location:** `SignInSheet.swift` lines 310-335

**Problem:**
- `topViewController` and `topMostViewController` extensions exist in multiple files
- Code duplication increases maintenance burden

**Crash Risk:** 🟢 **NONE**

---

## Architecture Strengths ✅

1. **Clear Separation of Concerns**
   - `AuthService`: All Firebase Auth logic
   - `SignInSheet`: UI and user interaction
   - `AppleSignInCoordinator`: Apple-specific implementation
   - Clear boundaries between layers

2. **Proper Error Handling**
   - Most async operations have try/catch
   - Errors displayed to users via `generalError` and `phoneError`
   - Comprehensive logging for debugging

3. **State Management**
   - Uses `@Published` for reactive updates
   - `@EnvironmentObject` for dependency injection
   - Proper use of `@State` for local UI state
   - `@MainActor` annotations ensure thread safety

4. **Async/Await Usage**
   - Proper use of Swift concurrency
   - `Task` usage is appropriate
   - Continuations used correctly

5. **Firebase Configuration**
   - Idempotent `configureFirebaseIfNeeded()` function
   - Checks before configuration
   - Good logging for debugging

---

## Most Likely Crash Scenarios

### Scenario 1: Immediate Button Tap After Sheet Appears
**Probability:** 🔴 **HIGH**

**Steps to Reproduce:**
1. User opens authentication sheet
2. User immediately taps Google Sign-In button (< 100ms)
3. `waitForPresenter()` fails to find ready controller
4. `AuthViewError.missingPresenter` thrown
5. Error displayed, but could crash if Google SDK called with nil

**Current Behavior:** Error is caught and displayed (line 164)

**Risk:** If Google SDK is called with invalid controller, may crash

---

### Scenario 2: Apple Sign-In Wrong Window
**Probability:** 🟡 **MEDIUM**

**Steps to Reproduce:**
1. User opens authentication sheet
2. User taps Apple Sign-In immediately
3. `signInWithApple(presentationAnchor: nil)` called
4. Fallback logic selects wrong window (e.g., window behind sheet)
5. Apple Sign-In presents on wrong window or fails

**Current Behavior:** May present on wrong window or throw error

**Risk:** User experience issue, may appear broken

---

### Scenario 3: Sheet Dismissal During Auth Flow
**Probability:** 🟢 **LOW**

**Steps to Reproduce:**
1. User starts Google/Apple Sign-In
2. User dismisses sheet during auth flow
3. Auth callbacks may reference deallocated view controllers

**Current Behavior:** Likely handled gracefully by SDKs

**Risk:** Low, but could cause issues

---

## Recommendations

### Priority 1: Fix Critical Timing Issues

1. **Add Sheet Ready State**
   ```swift
   @State private var isSheetReady = false
   
   .onAppear {
       authService.prepareForPhoneAuth()
       Task {
           // Wait for sheet animation to complete
           try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
           isSheetReady = true
       }
   }
   
   AppleIDSignInButton(isEnabled: !isBusy && isSheetReady) { ... }
   GoogleSignInButton(isEnabled: !isBusy && isSheetReady) { ... }
   ```

2. **Improve waitForPresenter()**
   ```swift
   @MainActor
   private func waitForPresenter() async -> UIViewController? {
       for attempt in 0..<10 { // Increase attempts
           if let controller = UIApplication.shared.topViewController,
              let window = controller.view.window,
              window.isKeyWindow,
              controller.view.superview != nil, // In hierarchy
              controller.isViewLoaded { // View is loaded
               return controller
           }
           // Exponential backoff
           let delay = min(50_000_000 * Int64(pow(2.0, Double(attempt))), 500_000_000)
           try? await Task.sleep(nanoseconds: delay)
           await Task.yield()
       }
       return nil
   }
   ```

3. **Pass Window Explicitly for Apple Sign-In**
   ```swift
   // In SignInSheet, get window from environment or find it
   private func findWindow() -> UIWindow? {
       if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
           return windowScene.windows.first(where: { $0.isKeyWindow })
       }
       return nil
   }
   
   AppleIDSignInButton {
       Task {
           let window = findWindow()
           await runAuthAction { 
               try await authService.signInWithApple(presentationAnchor: window) 
           }
       }
   }
   ```

### Priority 2: Improve Error Handling

4. **Better Error Messages**
   - If `waitForPresenter()` fails, show user-friendly message
   - Suggest retrying after a moment

5. **Prevent Concurrent Auth**
   ```swift
   @State private var authInProgress = false
   
   AppleIDSignInButton(isEnabled: !isBusy && !authInProgress) {
       guard !authInProgress else { return }
       authInProgress = true
       Task {
           defer { authInProgress = false }
           await runAuthAction { ... }
       }
   }
   ```

### Priority 3: Code Quality

6. **Consolidate Extensions**
   - Move `topViewController` to shared utility file

7. **Add Unit Tests**
   - Test `waitForPresenter()` with various hierarchies
   - Test concurrent auth attempts
   - Test sheet presentation timing

---

## Testing Checklist

Before releasing, test these scenarios:

- [ ] Tap Google Sign-In immediately after sheet appears (< 100ms)
- [ ] Tap Apple Sign-In immediately after sheet appears (< 100ms)
- [ ] Rapidly tap both buttons multiple times
- [ ] Dismiss sheet during phone verification
- [ ] Present sheet while another sheet is already presented
- [ ] Test on slow device (iPhone SE, older models)
- [ ] Test with slow network connection
- [ ] Test with Firebase not initialized (should show error, not crash)
- [ ] Test with missing environment object (should handle gracefully)
- [ ] Test on iPad (different window behavior)
- [ ] Test in landscape orientation
- [ ] Test with multiple windows (iPad multitasking)

---

## Conclusion

The authentication architecture is **solid overall** with good practices, but has **critical timing issues** that could cause crashes or failures when the sign-in sheet is first presented. The main issues are:

1. **Sheet presentation race condition** - Buttons enabled before sheet ready
2. **Insufficient waitForPresenter() timing** - May fail to find ready controller
3. **Apple Sign-In window selection** - May select wrong window

These issues are **fixable** with the recommendations above. The architecture is well-designed otherwise, with good separation of concerns, error handling, and state management.

**Recommendation:** Fix Priority 1 issues before release to prevent crashes and improve user experience.
