# GlowMate Test Cases

## Manual Functional Tests

1. Launch app with no camera permission.
   - Expected: permission explanation appears; no crash.
2. Grant camera permission.
   - Expected: camera preview appears; score and recommendation update.
3. Tap Apply on Meter.
   - Expected: Light tab opens; selected brightness/color matches recommendation; feedback appears.
4. Change Light slider and color.
   - Expected: UI updates immediately; values persist after tab changes and app relaunch.
5. Open full-screen soft light and close it.
   - Expected: full-screen color fills display; close returns to Light; state remains.
6. Select each scene.
   - Expected: scene checkmark moves; Light values update; history record is added.
7. Select a history record.
   - Expected: active light state is restored; confirmation feedback appears.
8. Change language to English, Simplified Chinese, and Japanese.
   - Expected: visible labels change immediately and persist.
9. Open Privacy Policy and Support rows.
   - Expected: browser opens; Settings does not show raw URL or support email text.
10. Run screenshot mode script.
    - Expected: deterministic app screens, no camera alert, generated screenshots have expected dimensions.
11. Run release validation script.
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

