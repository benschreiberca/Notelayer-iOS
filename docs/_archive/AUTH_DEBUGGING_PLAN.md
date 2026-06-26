# Authentication Debugging Plan

## Overview
This plan provides a systematic approach to debug authentication issues in the Notelayer iOS app. Follow these steps methodically to identify and resolve the authentication bug.

## Prerequisites
- Xcode project opens without errors
- Firebase project is configured
- GoogleService-Info.plist is present and valid
- App can build and run on simulator or device

---

## Phase 1: Configuration Verification

### 1.1 Firebase Configuration Files

**Check GoogleService-Info.plist:**
- [ ] File exists at: `ios-swift/Notelayer/GoogleService-Info.plist`
- [ ] File is included in Xcode project (check Build Phases > Copy Bundle Resources)
- [ ] Verify all required keys are present:
  - `CLIENT_ID` (should match Firebase console)
  - `REVERSED_CLIENT_ID` (should be `com.googleusercontent.apps.{CLIENT_ID}`)
  - `API_KEY`
  - `PROJECT_ID`
  - `BUNDLE_ID` (should match `com.notelayer.app`)
- [ ] Check file is not corrupted (open in Xcode, verify XML is valid)

**Action:** If missing or incorrect, download fresh `GoogleService-Info.plist` from Firebase Console.

### 1.2 Info.plist Configuration

**Check URL Schemes:**
- [ ] Open `ios-swift/Notelayer/Info.plist`
- [ ] Verify `CFBundleURLTypes` array exists
- [ ] Verify `CFBundleURLSchemes` contains `$(REVERSED_CLIENT_ID)`
- [ ] Build the app and check that `REVERSED_CLIENT_ID` build setting resolves correctly

**Action:** If missing, add URL scheme configuration (see current Info.plist lines 45-57).

### 1.3 Entitlements

**Check Notelayer.entitlements:**
- [ ] File exists at: `ios-swift/Notelayer/Notelayer/Notelayer.entitlements`
- [ ] Verify `com.apple.developer.applesignin` is set to `["Default"]`
- [ ] Verify `aps-environment` is set (development or production)
- [ ] Check entitlements are linked in Xcode project settings

**Action:** If missing, add Apple Sign In capability in Xcode.

### 1.4 Xcode Project Settings

**Check Build Settings:**
- [ ] Bundle Identifier is `com.notelayer.app`
- [ ] Signing & Capabilities includes:
  - Sign in with Apple
  - Push Notifications (for phone auth)
- [ ] GoogleService-Info.plist is in Copy Bundle Resources

**Check Build Phases:**
- [ ] GoogleService-Info.plist is listed in "Copy Bundle Resources"

---

## Phase 2: Runtime Debugging Setup

### 2.1 Add Comprehensive Error Logging

**Location:** `AuthService.swift` and `AuthTestView.swift`

**Add logging to:**
1. `signInWithEmail` - log email, error details
2. `signInWithGoogle` - log clientID, token retrieval, credential creation
3. `signInWithApple` - log nonce, token, credential creation
4. `startPhoneNumberSignIn` - log phone number, verification ID
5. `verifyPhoneNumber` - log code, verification ID, credential

**Example logging pattern:**
```swift
print("🔐 [AuthService] signInWithEmail - email: \(email)")
do {
    let result = try await Auth.auth().signIn(withEmail: email, password: password)
    print("✅ [AuthService] signInWithEmail - SUCCESS - user: \(result.user.uid)")
} catch {
    print("❌ [AuthService] signInWithEmail - ERROR: \(error.localizedDescription)")
    print("   Full error: \(error)")
    if let nsError = error as NSError? {
        print("   Domain: \(nsError.domain), Code: \(nsError.code)")
        print("   UserInfo: \(nsError.userInfo)")
    }
    throw error
}
```

### 2.2 Add Firebase Initialization Logging

**Location:** `configureFirebaseIfNeeded()` function

**Add:**
```swift
private func configureFirebaseIfNeeded() {
    if FirebaseApp.app() == nil {
        print("🔥 [Firebase] Configuring Firebase...")
        FirebaseApp.configure()
        print("🔥 [Firebase] Configuration complete")
        if let app = FirebaseApp.app() {
            print("🔥 [Firebase] App name: \(app.name)")
            print("🔥 [Firebase] Options: \(app.options)")
        }
    } else {
        print("🔥 [Firebase] Already configured")
    }
}
```

### 2.3 Add Auth State Listener Logging

**Location:** `AuthService.init()`

**Add:**
```swift
authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
    print("👤 [AuthService] Auth state changed - user: \(user?.uid ?? "nil")")
    if let user = user {
        print("   Email: \(user.email ?? "nil")")
        print("   Phone: \(user.phoneNumber ?? "nil")")
        print("   Provider: \(user.providerData.map { $0.providerID })")
    }
    self?.user = user
}
```

### 2.4 Add UI Error Display Enhancement

**Location:** `AuthTestView.swift` - `runAction` method

**Enhance error display:**
```swift
@MainActor
private func runAction(_ action: @escaping () async throws -> Void) async {
    isBusy = true
    defer { isBusy = false }
    statusMessage = ""
    do {
        try await action()
        statusMessage = "✅ Success"
    } catch {
        let errorMsg = error.localizedDescription
        let fullError = "\(error)"
        print("❌ [AuthTestView] Error: \(fullError)")
        statusMessage = "❌ \(errorMsg)\n\nDetails: \(fullError)"
    }
}
```

---

## Phase 3: Method-Specific Debugging

### 3.1 Email/Password Authentication

**Test Steps:**
1. Enter valid email and password
2. Try "Sign up" first (creates new account)
3. Try "Sign in" with existing account
4. Check console logs for:
   - Firebase configuration
   - Email/password being sent
   - Error messages from Firebase

**Common Issues:**
- **"Invalid email format"** - Check email validation
- **"User not found"** - Account doesn't exist, use Sign up
- **"Wrong password"** - Password mismatch
- **"Network error"** - Check internet connection, Firebase rules
- **"Too many requests"** - Rate limiting, wait before retry

**Debug Checklist:**
- [ ] Email format is valid
- [ ] Password meets Firebase requirements (min 6 chars)
- [ ] Firebase Authentication is enabled in Firebase Console
- [ ] Email/Password provider is enabled in Firebase Console
- [ ] No network connectivity issues

### 3.2 Google Sign-In

**Test Steps:**
1. Tap "Continue with Google"
2. Check console logs for:
   - Client ID retrieval
   - Google Sign-In SDK initialization
   - Token retrieval
   - Credential creation
   - Firebase sign-in

**Common Issues:**
- **"Missing Google Client ID"** - GoogleService-Info.plist not loaded or CLIENT_ID missing
- **"Missing Google ID Token"** - Google Sign-In didn't complete properly
- **URL scheme not configured** - Info.plist missing REVERSED_CLIENT_ID
- **AppDelegate not handling URL** - Check `application(_:open:options:)` is called

**Debug Checklist:**
- [ ] GoogleService-Info.plist CLIENT_ID is present and valid
- [ ] Info.plist has REVERSED_CLIENT_ID in URL schemes
- [ ] AppDelegate handles URL callback correctly
- [ ] Google Sign-In SDK is properly installed (check Package.resolved)
- [ ] OAuth consent screen is configured in Google Cloud Console
- [ ] iOS client ID is added in Firebase Console

**Add specific logging:**
```swift
func signInWithGoogle(presenting viewController: UIViewController) async throws {
    configureFirebaseIfNeeded()
    print("🔵 [AuthService] Starting Google Sign-In...")
    
    guard let app = FirebaseApp.app() else {
        print("❌ [AuthService] FirebaseApp is nil")
        throw AuthServiceError.missingGoogleClientID
    }
    
    guard let clientID = app.options.clientID, !clientID.isEmpty else {
        print("❌ [AuthService] Client ID is missing or empty")
        print("   Options: \(app.options)")
        throw AuthServiceError.missingGoogleClientID
    }
    
    print("✅ [AuthService] Client ID found: \(clientID)")
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    
    print("🔵 [AuthService] Calling GIDSignIn.sharedInstance.signIn...")
    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
    
    print("✅ [AuthService] Google Sign-In completed")
    print("   User ID: \(result.user.userID ?? "nil")")
    print("   Email: \(result.user.profile?.email ?? "nil")")
    
    guard let idToken = result.user.idToken?.tokenString else {
        print("❌ [AuthService] ID Token is nil")
        throw AuthServiceError.missingGoogleIDToken
    }
    
    print("✅ [AuthService] ID Token retrieved")
    let credential = GoogleAuthProvider.credential(
        withIDToken: idToken,
        accessToken: result.user.accessToken.tokenString
    )
    
    print("🔵 [AuthService] Signing in to Firebase with Google credential...")
    _ = try await Auth.auth().signIn(with: credential)
    print("✅ [AuthService] Firebase sign-in successful")
}
```

### 3.3 Apple Sign-In

**Test Steps:**
1. Tap "Continue with Apple"
2. Check console logs for:
   - Nonce generation
   - Apple ID authorization request
   - Token retrieval
   - Credential creation
   - Firebase sign-in

**Common Issues:**
- **"Missing presentation anchor"** - UIWindow not available
- **"Missing Apple ID token"** - User cancelled or error occurred
- **Entitlements not configured** - Apple Sign In capability missing
- **Nonce mismatch** - SHA256 hash doesn't match

**Debug Checklist:**
- [ ] Apple Sign In capability is enabled in Xcode
- [ ] Entitlements file includes `com.apple.developer.applesignin`
- [ ] App is signed with valid provisioning profile
- [ ] Testing on physical device or simulator with Apple ID configured

**Add specific logging:**
```swift
func signInWithApple(presentationAnchor: ASPresentationAnchor?) async throws {
    configureFirebaseIfNeeded()
    print("🍎 [AuthService] Starting Apple Sign-In...")
    
    let anchor = presentationAnchor ?? UIApplication.shared.keyWindow
    guard let anchor else {
        print("❌ [AuthService] Missing presentation anchor")
        throw AuthServiceError.missingPresentationAnchor
    }
    
    print("✅ [AuthService] Presentation anchor found")
    _ = try await appleCoordinator.signIn(presentationAnchor: anchor)
    print("✅ [AuthService] Apple Sign-In completed")
}
```

### 3.4 Phone Authentication

**Test Steps:**
1. Enter phone number in E.164 format (+1...)
2. Tap "Send code"
3. Check console for verification ID
4. Enter verification code
5. Tap "Verify code"

**Common Issues:**
- **"Invalid phone number"** - Format must be E.164
- **"Verification code expired"** - Code timeout (usually 5 minutes)
- **"Invalid verification code"** - Wrong code entered
- **APNS not configured** - Push notifications required for phone auth

**Debug Checklist:**
- [ ] Phone number is in E.164 format (+country code)
- [ ] Push notifications are configured (APNS)
- [ ] Phone authentication is enabled in Firebase Console
- [ ] Test phone numbers are added in Firebase Console (for development)

---

## Phase 4: Firebase Console Verification

### 4.1 Authentication Providers

**Check Firebase Console > Authentication > Sign-in method:**
- [ ] Email/Password: Enabled
- [ ] Google: Enabled (with correct iOS client ID)
- [ ] Apple: Enabled
- [ ] Phone: Enabled

### 4.2 Authorized Domains

**Check Firebase Console > Authentication > Settings > Authorized domains:**
- [ ] App domain is listed
- [ ] No restrictions blocking authentication

### 4.3 OAuth Redirect URIs

**For Google Sign-In:**
- [ ] Check Google Cloud Console > APIs & Services > Credentials
- [ ] iOS client has correct bundle ID
- [ ] OAuth redirect URIs are configured

---

## Phase 5: Code Flow Verification

### 5.1 Initialization Flow

**Verify execution order:**
1. `NotelayerApp.init()` calls `configureFirebaseIfNeeded()`
2. `AuthService.init()` sets up auth state listener
3. `AppDelegate.application(_:didFinishLaunchingWithOptions:)` configures Firebase
4. `AppDelegate.application(_:open:options:)` handles URL callbacks

**Add breakpoints and verify:**
- [ ] Firebase is configured before any auth calls
- [ ] Auth state listener is active
- [ ] AppDelegate methods are being called

### 5.2 View Controller Presentation

**For Google Sign-In:**
- [ ] `waitForPresenter()` successfully finds a view controller
- [ ] View controller has a window
- [ ] View controller is presented when Google Sign-In is called

**Add logging:**
```swift
@MainActor
private func waitForPresenter() async -> UIViewController? {
    print("🔍 [AuthTestView] Waiting for presenter...")
    for attempt in 0..<5 {
        if let controller = UIApplication.shared.topViewController, controller.view.window != nil {
            print("✅ [AuthTestView] Presenter found: \(type(of: controller))")
            return controller
        }
        print("⏳ [AuthTestView] Attempt \(attempt + 1)/5: No presenter yet")
        await _Concurrency.Task.yield()
        if attempt < 4 {
            try? await _Concurrency.Task.sleep(nanoseconds: 50_000_000)
        }
    }
    print("❌ [AuthTestView] Failed to find presenter after 5 attempts")
    return nil
}
```

---

## Phase 6: Testing Checklist

### 6.1 Test Each Authentication Method

**Email/Password:**
- [ ] Sign up with new email
- [ ] Sign in with existing email
- [ ] Sign out
- [ ] Sign in again
- [ ] Password reset flow

**Google:**
- [ ] Tap "Continue with Google"
- [ ] Complete Google Sign-In flow
- [ ] Verify user is authenticated
- [ ] Sign out
- [ ] Sign in again

**Apple:**
- [ ] Tap "Continue with Apple"
- [ ] Complete Apple Sign-In flow
- [ ] Verify user is authenticated
- [ ] Sign out
- [ ] Sign in again

**Phone:**
- [ ] Enter phone number
- [ ] Receive verification code
- [ ] Enter code and verify
- [ ] Verify user is authenticated

### 6.2 Test Error Scenarios

- [ ] Invalid email format
- [ ] Wrong password
- [ ] Cancel Google Sign-In
- [ ] Cancel Apple Sign-In
- [ ] Invalid phone number format
- [ ] Wrong verification code
- [ ] Network offline scenario

---

## Phase 7: Common Solutions

### Solution 1: Firebase Not Initialized
**Symptom:** All auth methods fail silently or with generic errors
**Fix:** Ensure `configureFirebaseIfNeeded()` is called before any auth operations

### Solution 2: GoogleService-Info.plist Not Loaded
**Symptom:** "Missing Google Client ID" error
**Fix:** 
- Verify file is in Copy Bundle Resources
- Clean build folder (Cmd+Shift+K)
- Delete derived data
- Rebuild

### Solution 3: URL Scheme Not Working
**Symptom:** Google Sign-In doesn't return to app
**Fix:**
- Verify Info.plist has correct REVERSED_CLIENT_ID
- Check AppDelegate handles URL callback
- Verify bundle ID matches Firebase project

### Solution 4: Apple Sign-In Entitlements
**Symptom:** Apple Sign-In button doesn't work
**Fix:**
- Enable "Sign in with Apple" capability in Xcode
- Verify entitlements file is linked
- Check provisioning profile includes Apple Sign In

### Solution 5: Phone Auth APNS
**Symptom:** Phone verification never arrives
**Fix:**
- Configure APNS in Firebase Console
- Upload APNS certificate/key
- Verify push notification capability is enabled

---

## Phase 8: Debugging Output Template

When reporting issues, include:

```
### Environment
- Xcode version: [version]
- iOS version: [simulator/device version]
- Firebase SDK version: [from Package.resolved]

### Configuration
- Bundle ID: [bundle ID]
- Firebase Project: [project ID]
- GoogleService-Info.plist: [present/valid]

### Error Details
- Method: [email/google/apple/phone]
- Error message: [exact error]
- Console logs: [relevant logs]
- Steps to reproduce: [detailed steps]

### Console Output
[paste full console output with 🔐 🔥 👤 emoji markers]
```

---

## Next Steps After Debugging

1. **Document the root cause** - What was the actual issue?
2. **Fix the bug** - Implement the solution
3. **Add tests** - Prevent regression
4. **Update error handling** - Improve user experience
5. **Update documentation** - Help future developers

---

## Quick Reference: Key Files

- `AuthService.swift` - Main authentication service
- `AuthTestView.swift` - UI for testing auth
- `NotelayerApp.swift` - App initialization
- `GoogleService-Info.plist` - Firebase configuration
- `Info.plist` - URL schemes
- `Notelayer.entitlements` - Capabilities

---

## Notes

- Always test on a physical device for Apple Sign-In
- Simulator works for email/password and Google Sign-In
- Phone auth requires APNS configuration
- Check Firebase Console logs for server-side errors
- Enable verbose logging in Firebase (if available)
