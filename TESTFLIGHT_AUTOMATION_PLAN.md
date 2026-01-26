# TestFlight Automation Setup - Review & Fix Plan

**Overall Progress:** `0%`

## TLDR
Review and fix the GitHub Actions workflow that automatically uploads builds to TestFlight when pushing to the main branch. The current setup has configuration issues causing CI failures.

## Critical Decisions

- **Code Signing Strategy**: Using `fastlane match` with git storage for certificate management (readonly mode in CI)
- **Build Number Strategy**: Using GitHub run number + attempt for unique build identifiers
- **Authentication Method**: App Store Connect API key (preferred over Apple ID for CI)
- **Ruby Version**: Ruby 3.2 with bundler cache enabled for faster builds

## Current Issues Identified

### 1. Missing Dependencies
- No `Gemfile.lock` exists, indicating `bundle install` hasn't been run locally
- Workflow relies on `bundler-cache: true` but the lockfile is missing

### 2. Incomplete GitHub Secrets Configuration
The workflow expects but doesn't validate these secrets exist:
- `ASC_KEY_ID` - App Store Connect API Key ID
- `ASC_ISSUER_ID` - App Store Connect Issuer ID  
- `ASC_PRIVATE_KEY` - App Store Connect Private Key (base64 or PEM format)
- `MATCH_GIT_URL` - Git repo URL for certificates (optional, conditionally used)
- `MATCH_GIT_BRANCH` - Branch in certificates repo (optional)
- `MATCH_PASSWORD` - Encryption password for certificates
- `MATCH_GIT_BASIC_AUTHORIZATION` or `MATCH_GIT_PRIVATE_KEY` - Git authentication

### 3. Workflow Robustness Issues
- No Xcode version specified (can cause inconsistent builds)
- No validation of required secrets before starting build
- No artifact upload for debugging failures
- No build log preservation
- Match environment variables set conditionally but some might be required

### 4. Fastlane Configuration Gaps
- Potential workspace vs project ambiguity
- No explicit cleanup steps
- Missing notification/reporting on failure
- No build artifact retention

### 5. Documentation Missing
- No guide on how to set up required secrets
- No troubleshooting documentation
- No local testing instructions before pushing to CI

## Tasks

- [ ] 🟥 **Step 1: Create Local Gemfile.lock**
  - [ ] 🟥 Run `bundle install` locally to generate Gemfile.lock
  - [ ] 🟥 Commit Gemfile.lock to repository for consistent CI dependencies
  - [ ] 🟥 Test that bundler cache will work in CI

- [ ] 🟥 **Step 2: Document Required GitHub Secrets**
  - [ ] 🟥 Create `docs/TESTFLIGHT_SETUP.md` with complete secrets documentation
  - [ ] 🟥 Add instructions for generating App Store Connect API key
  - [ ] 🟥 Document how to set up fastlane match (first-time setup vs ongoing use)
  - [ ] 🟥 Add instructions for encoding private key to base64 if needed
  - [ ] 🟥 List required vs optional secrets clearly

- [ ] 🟥 **Step 3: Improve GitHub Actions Workflow**
  - [ ] 🟥 Add Xcode version selection step (e.g., Xcode 15.2)
  - [ ] 🟥 Add secret validation step at beginning of workflow
  - [ ] 🟥 Improve match environment configuration (make required secrets explicit)
  - [ ] 🟥 Add build artifacts upload on failure (logs, .ipa if generated)
  - [ ] 🟥 Add status notifications or better error messages
  - [ ] 🟥 Add workflow dispatch for manual triggering (testing)

- [ ] 🟥 **Step 4: Enhance Fastlane Configuration**
  - [ ] 🟥 Add error handling with explicit error messages
  - [ ] 🟥 Add gym/build_app output directory specification
  - [ ] 🟥 Add cleanup_build_artifacts call
  - [ ] 🟥 Add skip_waiting_for_build_processing flag (faster CI)
  - [ ] 🟥 Verify project path is correct vs workspace usage
  - [ ] 🟥 Add changelog/release notes from git commits

- [ ] 🟥 **Step 5: Create Local Testing Setup**
  - [ ] 🟥 Create `.env.example` file showing required environment variables
  - [ ] 🟥 Document how to test fastlane locally before pushing
  - [ ] 🟥 Add local lane for testing without uploading (`lane :build_only`)
  - [ ] 🟥 Create script to validate local setup before CI push

- [ ] 🟥 **Step 6: Add CI Debugging Tools**
  - [ ] 🟥 Add verbose logging flag for troubleshooting
  - [ ] 🟥 Add step to show available provisioning profiles
  - [ ] 🟥 Add step to show available certificates
  - [ ] 🟥 Add pre-build validation checks (bundle ID matches, etc.)

- [ ] 🟥 **Step 7: Verify and Test End-to-End**
  - [ ] 🟥 Push to a test branch first to verify workflow
  - [ ] 🟥 Verify build succeeds
  - [ ] 🟥 Verify upload to TestFlight succeeds
  - [ ] 🟥 Check TestFlight shows new build with correct version/build number
  - [ ] 🟥 Test that subsequent pushes increment build number correctly
  - [ ] 🟥 Document any manual TestFlight settings needed (compliance, etc.)

## Specific Improvements Needed

### GitHub Actions Workflow (`.github/workflows/testflight.yml`)

```yaml
# Add before the checkout step
- name: Select Xcode version
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.2'

# Add after checkout
- name: Validate required secrets
  run: |
    MISSING_SECRETS=""
    [ -z "${{ secrets.ASC_KEY_ID }}" ] && MISSING_SECRETS="$MISSING_SECRETS ASC_KEY_ID"
    [ -z "${{ secrets.ASC_ISSUER_ID }}" ] && MISSING_SECRETS="$MISSING_SECRETS ASC_ISSUER_ID"
    [ -z "${{ secrets.ASC_PRIVATE_KEY }}" ] && MISSING_SECRETS="$MISSING_SECRETS ASC_PRIVATE_KEY"
    [ -z "${{ secrets.MATCH_PASSWORD }}" ] && MISSING_SECRETS="$MISSING_SECRETS MATCH_PASSWORD"
    
    if [ -n "$MISSING_SECRETS" ]; then
      echo "::error::Missing required secrets:$MISSING_SECRETS"
      exit 1
    fi

# Add workflow_dispatch trigger for manual runs
on:
  push:
    branches:
      - main
  workflow_dispatch:

# Add after the fastlane step
- name: Upload build artifacts on failure
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: build-logs
    path: |
      ~/Library/Logs/gym/
      fastlane/report.xml
      fastlane/test_output/
```

### Fastlane Fastfile Improvements

```ruby
# Add to beta lane
skip_waiting_for_build_processing(true)  # Faster CI feedback

# Add changelog from git commits
changelog = changelog_from_git_commits(
  pretty: "- %s",
  merge_commit_filtering: "exclude_merges"
)

upload_to_testflight(
  api_key: api_key,
  changelog: changelog,
  skip_waiting_for_build_processing: true
)

# Add build-only lane for local testing
lane :build_only do
  setup_ci if ENV["CI"] == "true"
  
  sync_code_signing(
    type: "appstore",
    app_identifier: "com.notelayer.app",
    readonly: true
  )
  
  build_app(
    project: "ios-swift/Notelayer/Notelayer.xcodeproj",
    scheme: "Notelayer",
    export_method: "app-store",
    output_directory: "./build"
  )
end
```

### Required GitHub Secrets Setup

| Secret Name | Description | How to Get It |
|------------|-------------|---------------|
| `ASC_KEY_ID` | App Store Connect API Key ID | Create at https://appstoreconnect.apple.com/access/api |
| `ASC_ISSUER_ID` | App Store Connect Issuer ID | Found on same API Keys page |
| `ASC_PRIVATE_KEY` | Private key file contents | Download .p8 file, then base64 encode it: `base64 -i AuthKey_XXX.p8` or use raw PEM |
| `MATCH_PASSWORD` | Encryption password for certificates | Create a strong password, store securely |
| `MATCH_GIT_URL` | Git repo URL for storing certificates | Create private repo, get SSH or HTTPS URL |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 of `username:token` | For HTTPS: `echo -n "username:token" \| base64` |
| `MATCH_GIT_PRIVATE_KEY` | SSH private key | For SSH: Contents of `~/.ssh/id_rsa` or deploy key |

## Common Failure Scenarios & Solutions

### 1. Code Signing Failures
**Symptoms**: "No matching provisioning profile found"
**Solutions**:
- Verify match password is correct
- Check match git repo is accessible
- Run `fastlane match appstore` locally first to initialize certificates
- Ensure bundle ID matches exactly: `com.notelayer.app`

### 2. Authentication Failures  
**Symptoms**: "Invalid API key" or "Authorization failed"
**Solutions**:
- Verify API key hasn't expired (they last ~6 months)
- Check API key has "Admin" or "Developer" role
- Verify base64 encoding is correct (no extra whitespace)

### 3. Build Failures
**Symptoms**: Compilation errors in CI but not locally
**Solutions**:
- Specify exact Xcode version in workflow
- Check for missing dependencies in Gemfile.lock
- Verify project file isn't corrupted

### 4. Upload Failures
**Symptoms**: Build succeeds but upload to TestFlight fails
**Solutions**:
- Check App Store Connect status page for outages
- Verify app exists in App Store Connect
- Check export method is "app-store" not "ad-hoc"
- Ensure API key has TestFlight permissions

## Success Criteria

- ✅ Push to main triggers workflow automatically
- ✅ Workflow completes successfully without manual intervention
- ✅ Build appears in TestFlight within 10-15 minutes
- ✅ Build number increments automatically on each push
- ✅ Failure logs are accessible for debugging
- ✅ Setup is documented for team members to replicate

## Next Steps After Implementation

1. Set up TestFlight internal testing group
2. Configure automatic distribution to testers
3. Add beta tester feedback monitoring
4. Consider adding automated testing before upload
5. Set up notifications for successful deployments

## References

- [Fastlane Match Documentation](https://docs.fastlane.tools/actions/match/)
- [App Store Connect API Keys](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/deployment/deploying-xcode-applications)
- [TestFlight Beta Testing](https://developer.apple.com/testflight/)
