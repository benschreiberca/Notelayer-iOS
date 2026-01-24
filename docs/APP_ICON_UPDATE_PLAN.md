# App Icon Update Plan

**Overall Progress:** `87%`

## TLDR
Update the Notelayer iOS app icon by replacing the existing 1024x1024 PNG asset and ensuring it displays correctly across all appearance modes (light, dark, and tinted).

## Critical Decisions
Key architectural/implementation choices made during exploration:
- **Universal Icon Format**: The project uses a single 1024x1024 PNG for all icon appearances (light, dark, tinted), which simplifies asset management
- **Asset Catalog Structure**: Icons are managed through Xcode's Asset Catalog (`AppIcon.appiconset`), which automatically handles different sizes and appearances
- **Source Asset Location**: New icon should be placed in the `AppIcon.appiconset` directory, replacing the existing `AppIcon-1024.png`

## Tasks:

- [x] 🟩 **Step 1: Prepare New Icon Asset**
  - [x] 🟩 Obtain or confirm the new icon design (1024x1024 pixels minimum)
  - [x] 🟩 Verify the icon meets Apple's App Icon guidelines (no transparency, proper corner radius handling, etc.)
  - [x] 🟩 Ensure the icon is optimized as PNG format
  - [x] 🟩 Review icon for all appearance modes (light, dark, tinted) if different versions are needed

- [x] 🟩 **Step 2: Backup Existing Icon**
  - [x] 🟩 Create backup of current `AppIcon-1024.png` file
  - [x] 🟩 Document current icon design for reference

- [x] 🟩 **Step 3: Replace Icon Asset**
  - [x] 🟩 Copy new icon to `ios-swift/Notelayer/Notelayer/Assets.xcassets/AppIcon.appiconset/`
  - [x] 🟩 Name the file `AppIcon-1024.png` (matching current naming convention)
  - [x] 🟩 Verify file permissions and that it's properly included in the Xcode project

- [x] 🟩 **Step 4: Update Asset Catalog Configuration (if needed)**
  - [x] 🟩 Review `Contents.json` to ensure it correctly references the new icon
  - [x] 🟩 Verify all three appearance modes (default, dark, tinted) are configured
  - [x] 🟩 Update `Contents.json` if separate icon files are needed for different appearances

- [ ] 🟨 **Step 5: Clean Build and Verify**
  - [ ] 🟥 Clean Xcode build folder (Product → Clean Build Folder)
  - [ ] 🟥 Delete derived data if necessary
  - [ ] 🟥 Rebuild the project to ensure new icon is compiled into asset catalog

- [ ] 🟨 **Step 6: Test Icon Display**
  - [ ] 🟥 Verify icon appears correctly in Xcode's asset catalog preview
  - [ ] 🟥 Test icon on iOS Simulator (check home screen, app switcher, settings)
  - [ ] 🟥 Test icon on physical device if available
  - [ ] 🟥 Verify icon displays correctly in all appearance modes (light mode, dark mode, tinted)
  - [ ] 🟥 Check icon at different sizes (home screen, app switcher, settings, notifications)

- [ ] 🟥 **Step 7: Update Source Assets (Optional)**
  - [ ] 🟥 If new icon has an SVG source, update or replace files in `NoteLayer-AppIcon.icon/Assets/` directory
  - [ ] 🟥 Remove old SVG files if they're no longer needed
  - [ ] 🟥 Document source asset location for future updates

- [ ] 🟥 **Step 8: Final Verification**
  - [ ] 🟥 Confirm icon meets App Store requirements (1024x1024, no transparency, proper format)
  - [ ] 🟥 Verify icon looks good at all required sizes
  - [ ] 🟥 Test icon in App Store Connect preview if preparing for submission
  - [ ] 🟥 Update any documentation that references the app icon
