# GitHub Actions Setup Checklist

Use this checklist to verify your TestFlight automation is configured correctly.

## ✅ Prerequisites

- [ ] I have the .p8 API key file
- [ ] I know my Key ID and Issuer ID
- [ ] I have run `fastlane match appstore` locally at least once
- [ ] I have a private Git repository for storing certificates
- [ ] I know my MATCH_PASSWORD

## ✅ GitHub Secrets Configured

Navigate to: `https://github.com/YOUR_USERNAME/Notelayer-iOS-1/settings/secrets/actions`

### App Store Connect API (3 required)
- [ ] `ASC_KEY_ID` - Added (Key ID from App Store Connect)
- [ ] `ASC_ISSUER_ID` - Added (Issuer ID from App Store Connect)
- [ ] `ASC_PRIVATE_KEY` - Added (base64 encoded .p8 file contents)

### Fastlane Match (3 required)
- [ ] `MATCH_PASSWORD` - Added (password used in `fastlane match` setup)
- [ ] `MATCH_GIT_URL` - Added (URL to certificates repository)
- [ ] `MATCH_GIT_PRIVATE_KEY` OR `MATCH_GIT_BASIC_AUTHORIZATION` - Added (one of these for Git auth)

## ✅ Local Files

- [ ] `Gemfile.lock` exists and is committed
- [ ] `.github/workflows/testflight.yml` exists
- [ ] `fastlane/Fastfile` exists
- [ ] `fastlane/Matchfile` exists

## ✅ Verification Commands

Run these locally to verify setup:

```bash
# 1. Verify bundle works
cd /Users/bens/Notelayer/Notelayer-iOS-1
bundle install
# Should complete without errors

# 2. Verify match can access certificates (dry run)
bundle exec fastlane match appstore --readonly --app_identifier com.notelayer.app
# Should show "All required keys, certificates and provisioning profiles are installed"

# 3. Test local build (optional but recommended)
bundle exec fastlane build_only
# Should build successfully and create .ipa file
```

## ✅ Push to Test

- [ ] All secrets are set
- [ ] Gemfile.lock is committed
- [ ] Ready to push to main branch
- [ ] Monitoring GitHub Actions tab for workflow run

## 🔍 After Pushing

1. Go to: `https://github.com/YOUR_USERNAME/Notelayer-iOS-1/actions`
2. Click on the latest "TestFlight" workflow run
3. Watch the job output
4. If it fails, check which step failed and refer to troubleshooting below

## 🚨 Common Issues & Solutions

### "No such file or directory - AuthKey_XXX.p8"
**Fix:** Your `ASC_PRIVATE_KEY` secret is not set correctly. Re-encode and re-add:
```bash
base64 -i AuthKey_YOUR_KEY_ID.p8 | pbcopy
```

### "Invalid API Key"
**Fix:** Check that `ASC_KEY_ID` and `ASC_ISSUER_ID` match exactly what's in App Store Connect

### "Git authentication failed"
**Fix:** Your match Git authentication is wrong. Verify:
- If using SSH: `MATCH_GIT_PRIVATE_KEY` contains full private key including headers
- If using HTTPS: `MATCH_GIT_BASIC_AUTHORIZATION` is base64 of `username:token`

### "No matching provisioning profile found"
**Fix:** 
- Verify `MATCH_PASSWORD` is correct
- Check bundle ID is exactly `com.notelayer.app`
- Verify match repo has certificates: `ls -la ~/.match` after running match locally

### "Gem::GemNotFoundException"
**Fix:** Commit and push `Gemfile.lock`:
```bash
bundle install
git add Gemfile.lock
git commit -m "Add Gemfile.lock"
git push
```

## 📊 Success Indicators

When everything works, you should see:
1. ✅ Workflow completes all steps in ~10-15 minutes
2. ✅ "Upload to TestFlight" step shows "Successfully uploaded package"
3. ✅ Build appears in App Store Connect → TestFlight within a few minutes
4. ✅ Build number matches GitHub run number

## 🎯 Next Steps After Success

- [ ] Add internal testers in TestFlight
- [ ] Configure automatic distribution
- [ ] Set up export compliance
- [ ] Add what's new notes (changelog)
- [ ] Test the build on a device

## 📞 Need Help?

If the workflow fails:
1. Copy the error message from the GitHub Actions log
2. Check the specific step that failed
3. Refer to the error in the troubleshooting section above
4. Check that all secrets are set correctly (they're hidden but you can re-add them)
