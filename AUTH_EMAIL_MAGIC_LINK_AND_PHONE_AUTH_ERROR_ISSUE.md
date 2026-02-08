# Missing Email Magic Link Auth + Phone Auth Captcha Error (TestFlight v1.4.1)

## TL;DR
- Need an email magic-link sign-up/login flow (currently missing).
- Phone auth shows a spinning state, then a full-screen white reCAPTCHA, then returns with red error: “an internal error has occured, print and inspecft the error details for more information” (TestFlight v1.4.1).

## Current State
- Email auth: No email sign-up flow exists.
- Phone auth: Spinner → white screen with captcha logo → back to app → red error text: “an internal error has occured, print and inspecft the error details for more information.”
- Environment: TestFlight v1.4.1.

## Expected Outcome
- Add email magic-link sign-up/login flow.
- Phone auth completes successfully or surfaces a clear, recoverable error without the blank captcha takeover or the generic “internal error” message.

## Most Relevant Files (max 3)
- `ios-swift/Notelayer/Notelayer/Views/SignInSheet.swift`
- `ios-swift/Notelayer/Notelayer/Services/AuthService.swift`
- `ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift`

## Notes / Risks
- Phone auth failures may be related to reCAPTCHA/App Check configuration or APNS verification flow for TestFlight/production.
- Error message suggests underlying error detail is currently not surfaced to the UI.

## Console Log Excerpt (TestFlight v1.4.1)
- `12.8.0 - [FirebaseAuth][I-AUT000014] Failed to receive remote notification to verify app identity within 4.9999799728393555 second(s), falling back to reCAPTCHA verification.`

## Labels
- Type: bug + feature
- Priority: high
- Effort: medium
