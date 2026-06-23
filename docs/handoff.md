# GlowMate Handoff

## Current Goal

Build a native iPhone-only SwiftUI app named GlowMate: an offline soft-light and lighting recommendation tool using local camera frames, screen brightness/color, torch control, local records, and three localizations.

## Design Direction

Use `ui-concepts/index.html`, Concept B / Halo Pop, as the visual reference:

- Warm cream background.
- Coral/orange primary action.
- Friendly selfie/creator tone.
- Main tabs: Meter, Light, Scenes, Records, Settings.

## Key Requirements

- iPhone only.
- No accounts, no backend, no active network requests.
- Local persistence on device.
- Supported languages: English, Simplified Chinese, Japanese.
- Explicit in-app language selection; system/region inference only when the user has not chosen.
- `CFBundleDisplayName` localized in English, Chinese, and Japanese.
- App Store encryption export key: `ITSAppUsesNonExemptEncryption = false`.
- Screenshot-only fake data via explicit launch arguments, Debug only.
- Release builds must not initialize, display, or persist demo data.
- Settings must not display Bundle ID, raw URLs, or support email address.

## Important Files

- `GlowMate.xcodeproj/`: Xcode project.
- `GlowMate/App/`: SwiftUI app entry and root shell.
- `GlowMate/Core/`: models, persistence, localization, screenshot mode.
- `GlowMate/Camera/`: AVFoundation measurement and preview.
- `GlowMate/Features/`: app screens.
- `GlowMate/Resources/`: assets, Info.plist, localizations.
- `scripts/`: screenshot and release validation scripts.
- `docs/`: product, testing, App Store, and handoff docs.
- `web/`: GitHub Pages privacy/support pages.

## Development Notes

- Keep demo data separated from production paths.
- For SwiftUI arrays/dictionaries, reassign the whole value after mutation when UI refresh matters.
- Avoid system dynamic text colors on warm/light backgrounds unless the background is also dynamic. This app uses forced light mode and explicit dark text colors.
- Do not add SDKs or networking dependencies unless the product scope changes.

## Verified Commands

- `plutil -lint GlowMate/Info.plist`
- `xcodebuild -project GlowMate.xcodeproj -scheme GlowMate -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2' -derivedDataPath build/DerivedData build`
- `scripts/validate-release.sh`
- `scripts/capture-screenshots.sh`

## Current Known Manual Steps

- Apple Developer signing/team selection remains owner-managed.
- Final App Store Connect app record, archive upload, and submission remain owner-managed.
- GitHub Pages may need a minute after the first workflow run before the public URLs are live.
