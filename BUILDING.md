# Building Royal Rush for Different Platforms

## Quick Start

```bash
# Install all dependencies
npm install
```

## Desktop (Steam/Electron)

### Development
```bash
# Run the game in Electron (for testing)
npm start
```

### Production Builds

**Windows:**
```bash
npm run build:win
```
Output: `dist-electron/Royal Rush Setup.exe` and portable version

**macOS:**
```bash
npm run build:mac
```
Output: `dist-electron/Royal Rush.dmg`

**Linux:**
```bash
npm run build:linux
```
Output: `dist-electron/Royal Rush.AppImage` and `.deb`

**All Platforms:**
```bash
npm run build:all
```

### Steam Upload

1. Build your target platform(s)
2. Go to Steamworks Partner site
3. Navigate to your app's "Builds" section
4. Use the SteamPipe tool to upload from `dist-electron/`
5. Set the build live for your release branch

## Mobile (iOS/Android)

### First-Time Setup

Both platforms require a one-time setup:

```bash
# Initialize Capacitor (only needed once)
npm install

# Add Android platform
npm run mobile:add:android

# Add iOS platform (macOS only)
npm run mobile:add:ios
```

### Android (Google Play)

#### Prerequisites
- Android Studio installed
- Android SDK 33+ installed
- Java JDK 17+ installed

#### Build Steps
```bash
# 1. Sync latest web code to Android project
npm run mobile:sync

# 2. Open in Android Studio
npm run mobile:open:android

# 3. In Android Studio:
#    - Build → Generate Signed Bundle / APK
#    - Choose "Android App Bundle" (for Play Store) or "APK" (for testing)
#    - Create/use signing key
#    - Build release version

# Output will be in:
# android/app/build/outputs/bundle/release/app-release.aab (for Play Store)
# android/app/build/outputs/apk/release/app-release.apk (for testing)
```

#### Google Play Upload
1. Go to Google Play Console
2. Create new app (or select existing)
3. Upload the `.aab` file
4. Complete store listing (screenshots, description, etc.)
5. Submit for review

### iOS (App Store)

#### Prerequisites
- macOS with Xcode 15+
- Apple Developer account ($99/year)
- Valid signing certificates

#### Build Steps
```bash
# 1. Sync latest web code to iOS project
npm run mobile:sync

# 2. Open in Xcode
npm run mobile:open:ios

# 3. In Xcode:
#    - Select your development team in Signing & Capabilities
#    - Set your Bundle Identifier (must match App Store Connect)
#    - Choose "Any iOS Device" as target
#    - Product → Archive
#    - Click "Distribute App" when archive completes
#    - Choose "App Store Connect"
#    - Follow the wizard to upload

# 4. Go to App Store Connect:
#    - Select your app
#    - Add build to a version
#    - Complete app information
#    - Submit for review
```

## Web Version (itch.io / Own Website)

No build needed! Just upload these files:
- `index.html`
- `style.css`
- `game.js`
- `assets/` folder (if you add images)

### itch.io Upload
1. Create project on itch.io
2. Choose "HTML" as project type
3. Create a ZIP file with the files above
4. Upload and mark `index.html` as the main file
5. Check "This file will be played in the browser"

## Assets Needed Before Publishing

### Icon/Logo
Create an icon for your game:
- **Desktop**: 512x512 PNG, save as `assets/icon.png`
- **Android**: Use Android Studio's asset creator (right-click `res` → New → Image Asset)
- **iOS**: Use Xcode's asset catalog (AppIcon in Assets.xcassets)

### Screenshots
Take screenshots for each platform's store page:
- **Steam**: 1280x720 or 1920x1080 (minimum 5 screenshots)
- **Google Play**: Portrait and landscape screenshots
- **App Store**: Screenshots for required device sizes

## Testing Checklist

Before publishing, test:
- [ ] Game loads without errors
- [ ] All upgrades work correctly
- [ ] Win condition triggers properly
- [ ] Game can be reset
- [ ] UI scales properly on different screen sizes
- [ ] Performance is smooth (60 FPS)
- [ ] No console errors
- [ ] Saves/loads work (if you add persistence)

## Common Issues

### Electron Build Fails
- Make sure you have the required build tools for your platform
- Windows: Install windows-build-tools (`npm install --global windows-build-tools`)
- macOS: Install Xcode command line tools
- Linux: Install build-essential

### Capacitor Sync Fails
- Delete `android/` or `ios/` folder and re-run `mobile:add:android` or `mobile:add:ios`
- Make sure Node.js version is 18+

### Android Build Fails
- Check that ANDROID_HOME environment variable is set
- Verify Android SDK is installed (check in Android Studio → SDK Manager)
- Update Gradle if prompted

### iOS Build Fails
- Check signing certificates in Xcode
- Verify Bundle ID matches your App Store Connect app
- Make sure you're on macOS (iOS builds require macOS)

## Platform-Specific Notes

### Steam
- You need Steamworks SDK for features like achievements
- Consider adding Steam overlay support
- Test with Steam's DRM if you want to use it

### Google Play
- First release takes longer to review (can be several days)
- You'll need a privacy policy URL
- Content rating questionnaire is required

### Apple App Store
- Review process typically takes 1-3 days
- App must comply with App Store guidelines
- Consider implementing In-App Purchases if monetizing

## Next Steps

After your first build:
1. Test thoroughly on the target platform
2. Get feedback from beta testers
3. Make improvements based on feedback
4. Prepare marketing materials
5. Launch!

Good luck with your game! 🎮
