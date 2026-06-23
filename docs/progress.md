# GlowMate Progress

## Stage 0 - Product Direction

- Selected UI direction: Concept B, "Halo Pop", a friendly selfie and creator-oriented offline soft-light tool.
- Product name: GlowMate.
- Bundle ID: `com.zhouyajie.glowmate`.
- Version: `1.0.0`.
- Device support: iPhone only.
- Network model: local-only app, no account, no backend, no active network requests.

## Stage 1 - User Paths And Acceptance Criteria

### Path 1: Measure Light And Apply Recommendation

1. User opens the app on the Meter tab.
2. If camera permission is missing, the app shows a clear permission request state.
3. After permission is granted, live camera preview starts and the app reads frame brightness/color balance locally.
4. The app shows a lighting issue, score, suggested brightness, color tone, distance, and short direction guidance.
5. User taps Apply.
6. The app switches to the Light tab, applies the recommended brightness/color, stores it as the current configuration, and shows a confirmation message.
7. Returning to Meter shows the current applied state.

Acceptance:

- The Apply action changes visible state.
- The selected brightness/color persists after leaving and reopening the app.
- The recommendation is based on local camera frames or screenshot demo data only.
- No network request is required.

### Path 2: Adjust Screen Soft Light

1. User opens the Light tab.
2. User changes brightness with the slider.
3. User selects a color swatch.
4. User opens the full-screen soft light.
5. User exits the full-screen light.
6. The Light tab still shows the chosen brightness/color and a saved-state message.

Acceptance:

- Slider and swatches update the UI immediately.
- The device screen brightness is set when soft light is active.
- Settings are persisted locally.
- Exiting soft light returns to the previous tab without losing state.

### Path 3: Use A Scene Preset

1. User opens Scenes.
2. User selects a scene such as Selfie, Food, Product, Meeting, or Night Room.
3. The scene's brightness/color/distance guidance becomes the active light configuration.
4. User can jump to Light and use the selected preset.

Acceptance:

- Selected scene is visually marked.
- Returning to Scenes keeps the selection.
- Light tab reflects the selected scene values.

### Path 4: Save And Reuse Local Records

1. User applies a recommendation or scene.
2. A local history record is created.
3. User opens Records.
4. User selects a record.
5. The app restores that record's brightness/color/scene and shows feedback.

Acceptance:

- Records are saved on device only.
- Selecting a record restores all relevant state.
- The records array is reassigned after mutation so SwiftUI refreshes reliably.

### Path 5: Settings And Localization

1. User opens Settings.
2. User changes language to English, Simplified Chinese, or Japanese.
3. UI text changes immediately and the selection persists.
4. User opens Privacy Policy or Support.

Acceptance:

- Explicit language choice wins over system/region inference.
- With no choice, language is inferred from preferred languages/region and falls back to English.
- Settings page does not show Bundle ID, raw URLs, or the support email address.
- External links are only opened after a user taps the corresponding row.

### Path 6: Screenshot Demo Mode

1. Screenshot script launches the app with explicit Debug-only screenshot arguments.
2. App initializes deterministic demo readings and history.
3. Screenshots are captured without camera permission prompts.
4. Normal launches do not initialize or display fake data.
5. Release builds ignore screenshot demo arguments.

Acceptance:

- Demo data code is compiled only in Debug.
- Demo data is never persisted into production defaults.
- Screenshot script uses explicit launch arguments.
- Release validation confirms `ITSAppUsesNonExemptEncryption` is `false` and checks that screenshot mode is Debug-only.

### Path 7: Take And Save A Photo

1. User opens the Meter tab.
2. If camera permission is granted, the live preview is visible and the Take & Save Photo action is enabled.
3. User taps Take & Save Photo.
4. The app captures a still photo from the local camera session and requests add-only photo library permission if needed.
5. The app saves the photo to the system photo library and shows success or permission/error feedback.

Acceptance:

- The action is disabled until camera access is available.
- Saving uses Photos add-only permission and does not upload or persist photo data inside the app.
- Success, camera denial, photo-library denial, and save failure paths show localized feedback.
- Screenshot demo mode does not access camera/photo library and only shows demo feedback in Debug.

## Stage 2 - Implementation Progress

- Created native SwiftUI iPhone project.
- Configured app name, bundle ID, version, iPhone-only device family, forced light mode, and export compliance plist key.
- Implemented local persistence, language selection, camera-based metering, screen soft light, torch control, scenes, records, settings, and Debug-only screenshot mode.
- Added photo capture and save-to-library flow from the Meter screen with localized camera and Photos permission messages.
- Added generated app icon assets with 1024x1024 RGB icon and no alpha channel.
- Added GitHub Pages-ready privacy and support pages in English, Simplified Chinese, and Japanese.
- Added screenshot capture and release validation scripts.

## Stage 3 - Verification

- `plutil -lint GlowMate/Info.plist`: passed.
- Confirmed `ITSAppUsesNonExemptEncryption = false` in the actual target plist.
- `xcodebuild -project GlowMate.xcodeproj -scheme GlowMate -configuration Debug`: passed.
- `scripts/validate-release.sh`: passed, including Release simulator build.
- `scripts/capture-screenshots.sh`: passed.
- Real simulator screenshots generated at `screenshots/iphone-6.5/en/`.
- Visual contact sheet reviewed at `build/screenshot-contact-sheet.png`; screens are rendered, readable, and Settings does not expose URL/email text.
- GitHub repository created and pushed: `https://github.com/Davidzyj/glowmate`.
- GitHub Pages enabled with workflow publishing; workflow completed successfully. Pages URL: `https://davidzyj.github.io/glowmate/`.
- Local `curl` access to `github.io` from this machine was reset by the network, so public page reachability should be rechecked from a normal browser/network after DNS/cache propagation.
