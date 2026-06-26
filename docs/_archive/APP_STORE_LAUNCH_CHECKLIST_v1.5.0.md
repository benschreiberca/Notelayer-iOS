# App Store Launch Checklist — Notelayer 1.5.0

**Status:** Ready for launch  
**Version:** 1.5.0  
**Target Release Date:** [TBD]

---

## 📋 Pre-Launch Preparation

### Code & Build
- [ ] All commits reviewed and merged to main
- [ ] Latest commit tagged as `v1.5.0`
- [ ] Clean build succeeds: `xcodebuild -scheme Notelayer build`
- [ ] No compiler warnings
- [ ] All code signed correctly for App Store distribution

### Testing (Physical Device)
- [ ] Fresh install on iOS 15+: onboarding auto-shows
- [ ] All 4 onboarding steps work smoothly
- [ ] First task can be added with category selection
- [ ] Task persists to main app after onboarding
- [ ] Tab bar shows only To-Dos and Insights
- [ ] Voice input works (tap microphone button)
- [ ] Insights tab loads and shows analytics
- [ ] Category rows in Insights are tappable (jump to To-Dos)
- [ ] Oldest task rows in Insights are tappable (open editor)
- [ ] Gear menu "Onboarding Guide" replays full flow
- [ ] Light mode: no visual glitches
- [ ] Dark mode: no visual glitches
- [ ] Scrolling is smooth (no jank or lag)
- [ ] No crashes during normal use
- [ ] Background sync works
- [ ] Settings/profile work correctly

### Version Management
- [ ] Version number set to 1.5.0 in Xcode
- [ ] Build number incremented from previous release
- [ ] Info.plist marketing version updated
- [ ] CHANGELOG.md updated with 1.5.0 entry

---

## 📦 App Store Connect Preparation

### Metadata
- [ ] App name and subtitle finalized
- [ ] Category/subcategory correct
- [ ] Description updated (see RELEASE_NOTES_v1.5.0.md)
- [ ] Keywords updated if needed
- [ ] Support email/URL valid
- [ ] Privacy policy URL current

### Screenshots & Preview Video
- [ ] At least 5 screenshots in each device size
  - [ ] iPhone 6.7" (or largest)
  - [ ] iPhone 6.1" (standard)
  - [ ] iPhone 5.5" (smallest)
- [ ] Screenshots show new onboarding flow
- [ ] Onboarding walkthrough captions added
- [ ] Preview video updated (optional, but recommended)

### Release Notes
- [ ] Release notes pasted from RELEASE_NOTES_v1.5.0.md
- [ ] Highlights new onboarding (what's new for first-time users)
- [ ] Highlights feature availability (experimental features now standard)
- [ ] Highlights Insights deep linking
- [ ] Tone matches brand voice
- [ ] No typos or grammatical errors

### Ratings & Content
- [ ] Age rating questionnaire completed
- [ ] Content advisory set correctly
- [ ] Export compliance confirmed (cryptography, if applicable)

---

## 🏗️ Build & Archive

### Create Archive
```bash
# Clean build directory
xcodebuild clean

# Archive for distribution
xcodebuild -scheme Notelayer \
  -configuration Release \
  -derivedDataPath build \
  -archivePath build/Notelayer.xcarchive \
  archive
```

- [ ] Archive created successfully
- [ ] No warnings during archive
- [ ] Archive size is reasonable (~150-200MB typical)

### Validate Archive
```bash
# Validate with App Store specifics
xcodebuild -validateArchive \
  -archivePath build/Notelayer.xcarchive \
  -exportOptionsPlist ExportOptions.plist
```

- [ ] Validation passes
- [ ] No code signing issues
- [ ] All provisioning profiles valid

---

## 🚀 App Store Connect Upload

### Upload Build
- [ ] Open App Store Connect
- [ ] Go to Builds section
- [ ] Upload archived .ipa file (via Transporter or web UI)
- [ ] Build processes without errors
- [ ] Build appears in Builds list within 5–10 minutes

### Configure Release
- [ ] Select build for version 1.5.0
- [ ] Add release notes (from RELEASE_NOTES_v1.5.0.md)
- [ ] Set release method:
  - [ ] Automatic after approval (recommended)
  - [ ] Manual (if you want to schedule release)
- [ ] Review all metadata one final time

---

## ✅ Final Review (Pre-Submit)

### App Review Compliance
- [ ] No app crashes during testing
- [ ] All features work as described
- [ ] No placeholder text or debug messages
- [ ] No external payment systems not disclosed to Apple
- [ ] Privacy practices match privacy policy
- [ ] No excessive battery/network usage

### Marketing Compliance
- [ ] Screenshots don't show UI bugs or glitches
- [ ] Feature descriptions are truthful and not misleading
- [ ] No comparisons to competitors
- [ ] No URLs that might be broken or redirect elsewhere

### Localization (if applicable)
- [ ] Translations reviewed for accuracy
- [ ] Screenshots localized if required
- [ ] No untranslated strings in UI

---

## 📤 Submit for Review

- [ ] All checklist items above completed
- [ ] Double-check release notes one last time
- [ ] Click "Submit for Review" in App Store Connect
- [ ] Confirm app review information section:
  - [ ] Contact email valid
  - [ ] Demo account (if needed) works
  - [ ] Sign-in instructions provided (if applicable)
- [ ] Submission confirmed with email receipt

---

## 📊 Post-Submission Monitoring

### Review Status
- [ ] Monitor review status in App Store Connect daily
- [ ] Typical review time: 24–48 hours
- [ ] If rejected, review feedback and address before resubmit

### Release Monitoring (Once Approved)
- [ ] Monitor crash reports in Xcode Organizer
- [ ] Monitor user ratings/reviews for issues
- [ ] Monitor feedback in analytics systems
- [ ] Prepare hotfix 1.5.1 if critical issues emerge

---

## 📝 Post-Launch

### Launch Announcement
- [ ] Blog post / press release (if applicable)
- [ ] Social media announcement
- [ ] Email to beta testers / waitlist

### Analytics & Feedback
- [ ] First 24h: monitor crash dashboard
- [ ] First week: review App Store review sentiment
- [ ] Track onboarding completion rate
- [ ] Track Insights deep-link usage

### Documentation
- [ ] Update website with new version info
- [ ] Update in-app release notes
- [ ] Archive this release checklist for future reference

---

## 🔧 Rollback Preparation (Just in Case)

If critical issue discovered pre-release:
- [ ] Revert all commits on main branch back to stable point
- [ ] Create hotfix branch
- [ ] Fix issue
- [ ] Re-test
- [ ] Resubmit as 1.5.0 build 2 (or 1.5.1 if needed)

---

## Sign-Off

| Role | Name | Date | Signature |
|---|---|---|---|
| Development | [Your Name] | [Date] | [ ] |
| QA / Testing | [QA Lead] | [Date] | [ ] |
| Product Manager | [PM Name] | [Date] | [ ] |
| App Store Release | [Release Manager] | [Date] | [ ] |

---

**Last Updated:** 2026-06-06  
**Next Review:** Upon submission to App Store
