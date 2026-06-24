# GlowMate Test Cases

## Manual Functional Tests

1. Launch app with no camera permission.
   - Expected: permission explanation appears; no crash.
2. Grant camera permission.
   - Expected: camera preview appears; score and recommendation update.
3. Tap Fill-Light Camera on Meter.
   - Expected: full-screen capture mode opens, uses the visible recommendation's tone/brightness, and keeps camera preview visible.
4. Tap the shutter in Fill-Light Camera and allow add-only photo library access.
   - Expected: shutter shows saving state, photo is added to Photos, and success feedback appears.
5. Close Fill-Light Camera.
   - Expected: app returns to Meter and the original screen brightness is restored.
6. Deny photo library add access, then tap the Fill-Light Camera shutter.
   - Expected: app does not crash; localized permission feedback appears; no app-local photo copy is created.
7. Deny camera access.
   - Expected: Fill-Light Camera is disabled and the page explains that camera access is needed.
8. Tap Apply on Meter.
   - Expected: Light tab opens; selected brightness/color matches recommendation; feedback appears.
9. Change Light slider and color.
   - Expected: UI updates immediately; values persist after tab changes and app relaunch.
10. Open full-screen soft light and close it.
   - Expected: full-screen color fills display; close returns to Light; state remains.
11. Select each scene.
   - Expected: scene checkmark moves; Light values update; history record is added.
12. Select a history record.
   - Expected: active light state is restored; confirmation feedback appears.
13. Change language to English, Simplified Chinese, and Japanese.
   - Expected: visible labels change immediately and persist.
14. Open Privacy Policy and Support rows.
   - Expected: browser opens; Settings does not show raw URL or support email text.
15. Run screenshot mode script.
    - Expected: deterministic app screens, including Fill-Light Camera, no camera/photo alert, generated screenshots have expected dimensions.
16. Run release validation script.
    - Expected: Info.plist encryption key exists and is false; target uses the expected plist.

## App Store Review-Focused Checks

1. Enable iOS dark mode, launch app.
   - Expected: app remains light; text on warm/white backgrounds stays dark and readable.
2. Open Settings.
   - Expected: no Bundle ID, raw URLs, or support email is visible.
3. Launch Release build with screenshot arguments.
   - Expected: screenshot mode is ignored.
4. Inspect network behavior.
   - Expected: app has no backend calls and no analytics/ads SDKs.
5. Review privacy permission strings.
   - Expected: camera and add-only photo library usage descriptions are present in English, Simplified Chinese, and Japanese.
