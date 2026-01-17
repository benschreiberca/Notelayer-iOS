# Quick Start - Running the App

## Opening the Project in Xcode

1. **Open Xcode** on your Mac

2. **Open the Project**:
   - File → Open (or press `⌘O`)
   - Navigate to: `ios-swift/Notelayer/Notelayer.xcodeproj`
   - Click "Open"

3. **Select a Device/Simulator**:
   - At the top of Xcode, click the device selector (next to the Play button)
   - Choose:
     - **iPhone Simulator** (any iPhone model) - Recommended for quick testing
     - **Your iPhone** (if connected via USB with Developer Mode enabled)

4. **Build and Run**:
   - Press `⌘R` (or click the Play button)
   - Xcode will build the app and launch it

## Running on Your iPhone

### Requirements:
- iPhone connected via USB
- Developer Mode enabled on iPhone (Settings → Privacy & Security → Developer Mode)
- Your Apple Developer account configured in Xcode
- Trust your Mac on the iPhone when prompted

### Steps:
1. Connect your iPhone via USB
2. Unlock your iPhone
3. Trust your Mac (if prompted)
4. In Xcode, select your iPhone from the device selector
5. Press `⌘R` to build and run
6. On your iPhone: Settings → General → VPN & Device Management → Trust your developer account

## Current App State

⚠️ **Note**: The current implementation is minimal (prototype level):

- **Notes Tab**: Shows a list of notes (if any exist). Can delete notes by swiping.
- **Todos Tab**: Shows a list of todos with a "Doing/Done" toggle. Can delete todos by swiping.

**What's Missing**:
- No way to add new notes or todos (no + button)
- No editing capability
- No persistence beyond basic UserDefaults
- Minimal data models

## Next Steps

To get a functional app, follow the **Implementation Plan** (`docs/IMPLEMENTATION_PLAN.md`):
- **Phase 1** (4 days): Basic working app with create/edit/delete
- Current state: Can view/delete, but can't create or edit

## Troubleshooting

### Build Errors:
- Ensure you have Xcode installed and updated
- Check that all Swift files are included in the target
- Clean build folder: Product → Clean Build Folder (`⇧⌘K`)

### Signing Errors:
- Xcode → Project Settings → Signing & Capabilities
- Select "Automatically manage signing"
- Choose your Team

### Simulator Issues:
- If simulator doesn't launch, try: Xcode → Window → Devices and Simulators
- Create a new simulator if needed

### App Crashes:
- Check the Xcode console for error messages
- The current implementation is minimal - some features may not work fully
