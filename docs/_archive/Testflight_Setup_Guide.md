# TestFlight Automation - Quick Setup Guide

Follow these steps to set up automatic TestFlight uploads on push to main.

## Prerequisites

- ✅ You have the .p8 API key file
- ✅ You have an Apple Developer account
- ✅ Your app exists in App Store Connect

## Step 1: Initialize Fastlane Match (One-Time Setup)

This stores your code signing certificates in a private Git repo.

```bash
cd /Users/bens/Notelayer/Notelayer-iOS-1

# Install fastlane (if not already installed)
sudo gem install fastlane

# Initialize match
fastlane match init
```

When prompted:
1. Select **git** as the storage mode
2. Create a **private GitHub repo** (e.g., `notelayer-certificates`)
3. Enter the repo URL (SSH format: `git@github.com:YOUR_USERNAME/notelayer-certificates.git`)

```bash
# Generate your certificates
fastlane match appstore --app_identifier com.notelayer.app
```

When prompted:
1. Create a **strong password** - **SAVE THIS PASSWORD!** You'll need it for GitHub secrets
2. Confirm your Apple ID and accept any prompts

## Step 2: Gather Your Credentials

### A. App Store Connect API Key

1. Go to: https://appstoreconnect.apple.com/access/api
2. Find your API key (or create a new one if needed)
3. Copy these values:
   - **Key ID** (e.g., `ABC123XYZ4`)
   - **Issuer ID** (UUID format)

4. Encode your .p8 file:
```bash
# Navigate to where your .p8 file is located
cd /path/to/your/p8/file

# Encode it (copies to clipboard)
base64 -i AuthKey_YOUR_KEY_ID.p8 | pbcopy
```

### B. Match Git Repository Access

Get your SSH private key:
```bash
# Copy your SSH private key (entire contents including headers)
cat ~/.ssh/id_rsa | pbcopy
```

**If you don't have an SSH key:**
```bash
# Generate one
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add to GitHub: https://github.com/settings/keys

# Then copy it
cat ~/.ssh/id_ed25519 | pbcopy
```

## Step 3: Add GitHub Secrets

Go to your repository settings:
```
https://github.com/YOUR_USERNAME/Notelayer-iOS-1/settings/secrets/actions
```

Click **"New repository secret"** for each of these:

### Required Secrets (6 total):

| Secret Name | Value | Where to Get It |
|------------|-------|-----------------|
| `ASC_KEY_ID` | Your Key ID | From Step 2A |
| `ASC_ISSUER_ID` | Your Issuer ID | From Step 2A |
| `ASC_PRIVATE_KEY` | Base64 encoded .p8 | From Step 2A (should be in clipboard) |
| `MATCH_PASSWORD` | Password from Step 1 | The password you created when running `fastlane match` |
| `MATCH_GIT_URL` | Git repo URL | From Step 1 (e.g., `git@github.com:USERNAME/notelayer-certificates.git`) |
| `MATCH_GIT_PRIVATE_KEY` | SSH private key | From Step 2B (entire key including `-----BEGIN` and `-----END` lines) |

### How to Add Each Secret:
1. Click "New repository secret"
2. Enter the **Name** exactly as shown above
3. Paste the **Value**
4. Click "Add secret"
5. Repeat for all 6 secrets

## Step 4: Push to Main and Test

```bash
# Make any small change (or just trigger the workflow)
git add .
git commit -m "Test TestFlight automation"
git push origin main
```

## Step 5: Monitor the Workflow

1. Go to: `https://github.com/YOUR_USERNAME/Notelayer-iOS-1/actions`
2. Click on the "TestFlight" workflow run
3. Watch the progress

**Expected timeline:**
- Checkout & Setup: ~1-2 minutes
- Code Signing: ~1 minute
- Build: ~5-10 minutes
- Upload: ~2-3 minutes
- **Total: ~10-15 minutes**

## Step 6: Verify in TestFlight

1. Go to: https://appstoreconnect.apple.com
2. Navigate to your app → TestFlight
3. Look for the new build under "iOS" builds
4. Build number should match the GitHub run number

## Troubleshooting

### "Missing required secrets" Error

**Problem:** One or more secrets aren't set correctly.

**Solution:** Double-check all 6 secrets are added exactly as named above.

### "Git authentication failed"

**Problem:** Match can't access your certificates repository.

**Solution:**
1. Verify `MATCH_GIT_URL` is correct
2. Ensure `MATCH_GIT_PRIVATE_KEY` includes the full key with headers:
   ```
   -----BEGIN OPENSSH PRIVATE KEY-----
   ...
   -----END OPENSSH PRIVATE KEY-----
   ```
3. Verify the SSH key is added to GitHub: https://github.com/settings/keys

### "No matching provisioning profile found"

**Problem:** Code signing certificates are missing or password is wrong.

**Solution:**
1. Verify `MATCH_PASSWORD` is correct (the password from Step 1)
2. Run locally to verify: `fastlane match appstore --readonly --app_identifier com.notelayer.app`
3. If that fails, regenerate certificates: `fastlane match appstore --force --app_identifier com.notelayer.app`

### "Invalid API Key"

**Problem:** App Store Connect API credentials are incorrect.

**Solution:**
1. Go to https://appstoreconnect.apple.com/access/api
2. Verify the Key ID and Issuer ID match your secrets
3. Re-encode the .p8 file: `base64 -i AuthKey_XXX.p8 | pbcopy`
4. Update the `ASC_PRIVATE_KEY` secret with the new value

### Build Succeeds Locally But Fails in CI

**Problem:** Environment differences between local and CI.

**Solution:**
1. Check the Xcode version in the workflow (currently 15.2)
2. Verify your local Xcode version: `xcodebuild -version`
3. The workflow uses Ruby 3.2, which should handle dependencies correctly

## Testing Locally (Optional)

Before pushing to CI, you can test the build locally:

```bash
cd /Users/bens/Notelayer/Notelayer-iOS-1

# Test the build without uploading
fastlane build_only

# Check the output
ls -lh build/Notelayer.ipa
```

If this succeeds, your CI build should also succeed.

## Manual Trigger (For Testing)

You can manually trigger the workflow without pushing to main:

1. Go to: `https://github.com/YOUR_USERNAME/Notelayer-iOS-1/actions`
2. Click "TestFlight" workflow
3. Click "Run workflow" dropdown
4. Select "main" branch
5. Click "Run workflow"

This is useful for testing without making code changes.

## Success! What's Next?

Once your first build succeeds:

1. **Add Internal Testers:**
   - Go to App Store Connect → TestFlight → Internal Testing
   - Add testers or create a group

2. **Configure Automatic Distribution:**
   - In TestFlight, enable "Automatically distribute to testers"
   - New builds will go to testers immediately after processing

3. **Set Export Compliance:**
   - If your app uses encryption, configure this in App Store Connect
   - Or add `ITSAppUsesNonExemptEncryption: false` to your Info.plist

4. **Add Release Notes:**
   - The workflow automatically generates changelog from git commits
   - Keep commit messages descriptive for better release notes

## Summary Checklist

- [ ] Ran `fastlane match init` and generated certificates
- [ ] Added all 6 GitHub secrets
- [ ] Pushed to main branch
- [ ] Workflow completed successfully
- [ ] Build appears in TestFlight
- [ ] Added internal testers (optional)

## Need Help?

If you're still stuck:
1. Check the GitHub Actions logs for the specific error
2. Compare the error against the troubleshooting section above
3. Verify all 6 secrets are set correctly (you can't view them, but you can update them)
4. Try running `fastlane build_only` locally to isolate the issue
