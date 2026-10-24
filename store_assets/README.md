# Prismleaf Vale — Play listing package

The icon and feature graphic are artwork. Files named `phone_*.png` are unedited captures of the running Android app in an emulator. Review them against the final signed release before uploading. Do not upload invented or composited gameplay as screenshots.

| File | Dimensions | Format | Status |
| --- | --- | --- | --- |
| `feature_graphic_1024x500.jpg` | 1024 × 500 | JPEG, no alpha | Created; review layout in Play Console |
| `play_icon_512.png` | 512 × 512 | 32-bit PNG | Created; review against Play icon mask |
| `phone_home_01.png` | 1080 × 1920 | PNG | Captured from the running app on an Android 17 emulator |
| `phone_gameplay_01.png` | 720 × 1280 | PNG | Captured after a real match on an Android 17 emulator |
| `phone_levels_*.png` | Device native | PNG | Pending actual device capture after unlocking levels |
| `phone_completion_*.png` | Device native | PNG | Pending actual completed level |

Google's current [preview asset requirements](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en) require a 1024 × 500 feature graphic, a 512 × 512 PNG listing icon at most 1024 KB, and at least two real screenshots. Capture phone screenshots from the built Android app after playing it, at native device resolution. Prefer a portrait device with at least 1080 × 1920 pixels. Check framing, legibility, and policy requirements before uploading.

Suggested capture order: home, trail with unlocked levels, live gameplay after the intro card, and a genuine success result. Use `adb shell screencap -p /sdcard/prismleaf.png` and `adb pull /sdcard/prismleaf.png store_assets/phone_gameplay_01.png` while the relevant screen is visible. Review each screenshot to confirm it matches the shipping app. Do not add captions that cover gameplay.

## Listing copy draft

**Short description:** Restore a glowing valley in an offline match-three journey

**Full description:**

Follow a trail through Prismleaf Vale, a quiet valley lit by every match. Swap colorful faceted leaves, collect each glade's objectives, and clear the board before your moves run out. Special pieces add a spark, while a fresh shuffle keeps the trail moving when swaps run dry.

Explore five glades with different board shapes and goals. Completed glades unlock the next stop, and your progress stays on your device. Claim daily glow, track your current and longest streaks and best scores, and unlock a Twilight backdrop. Turn sound effects on or off at any time. The game plays offline without an account; optional ads may appear on the trail map or offer extra moves after a loss.

**Relevant search terms for editorial review:** match three, offline puzzle, tile matching, colorful gems, casual puzzle, level progression.

## Release checklist

- Capture and inspect real Android screenshots for the screens above; verify Google Play's latest screenshot rules.
- Review icon, feature graphic, descriptions, and localization for each target market.
- Confirm original artwork and upstream code rights for commercial distribution.
- Configure private release signing; build and install a release variant on Android.
- Test gameplay, pause, sound setting, progress persistence, and lifecycle on physical devices.
- Complete Play Console data safety, content rating, privacy and target-audience declarations as applicable.
- Use https://sonnyhayesx.github.io/app-privacy-policy/ in Play Console and in the app. HTTPS accessibility was verified October 22, 2026; confirm publisher authorization, target audience, and actual data practices before submission. `privacy_policy_draft.md` is historical drafting material, not the published policy.
- Configure UMP privacy messages in AdMob, verify ad units, register test devices, and validate consent behavior in relevant regions.
- If children are in the target audience, review Families requirements and adapt ads and age handling before enabling production ads.
