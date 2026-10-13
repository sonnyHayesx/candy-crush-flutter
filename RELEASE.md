# Release verification

Use Flutter **3.47.5**, Dart bundled with that SDK, and JDK 21. CI pins this Flutter version and checks formatting, analysis, tests, and an Android debug build. CI artifacts are for testing only.

## Verification recorded 2026-10-13

- Formatting passed for all 50 Dart files; static analysis reported no issues.
- All 26 automated tests passed, including lifecycle interruption, animation cleanup, startup recovery, malformed saved progress, and banner removal across covered/replacement routes.
- The updated debug APK built and installed successfully: `build/app/outputs/flutter-apk/app-debug.apk`.
- Android 17 emulator smoke check passed: home, level intro, banner removal during gameplay, a match (24 to 23 moves, 80 points), background/resume pause, and a special-piece move after resume (22 moves, 450 points). Inspected Flutter/AndroidRuntime error logs were empty. Real gameplay capture: `store_assets/phone_gameplay_01.png`.
- Missing release signing correctly causes `:app:preReleaseBuild` to fail with setup instructions.

This is a tested development build, not a production release approval. The resource-constrained emulator required software rendering and its initial launch timed out before eventually showing home; production startup and graphics performance remain unverified. No signed release, physical-device acceptance, complete five-level playthrough, or live-ad acceptance was performed. CI is configured but has not been run remotely. Publisher details, privacy policy publication, audience decisions, and private signing remain outstanding.

## Automated checks

```sh
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

## Publisher setup (required before distribution)

- Configure `android/key.properties` from the example, using a private upload keystore. Keep the keystore and passwords outside version control and back up the keystore securely. Release packaging rejects missing signing configuration.
- Confirm ownership of the application ID and configured AdMob IDs.
- Fill in publisher name, support contact, and effective date in `store_assets/privacy_policy_draft.md`; publish the reviewed policy at a public URL.
- Decide the target audience and complete the Play Console declarations. Production ads remain disabled by default. If the audience includes children, adapt and validate the ads configuration before enabling ads.
- Review upstream code licensing and artwork rights. Capture actual device screenshots for the store listing.

## Device acceptance checks

Run on physical Android devices, including a small screen and a current Android version. Record device, OS version, app build number, and results with the release candidate.

- Complete all five glades; test wins, losses, retry, next level, bombs, cascades, and reshuffling.
- Background and resume while idle, dragging, animating, paused, and showing a result. Confirm moves remain playable and no extra moves are consumed.
- Use system Back and the pause menu during animations. Reopen a level and verify no stale tiles or overlays remain.
- Restart the app and verify level unlocks, scores, daily rewards, glow, theme, sound, and vibration settings.
- Test airplane mode and interrupted network access. The game must remain playable when ads fail.
- With sample ads, test consent, privacy options, rewarded completion, dismissal without reward, and ad-load failure. Verify exactly one reward per completed ad.
- Check large text, display resizing, screen-reader labels, and portrait/landscape layouts. Check audio and gameplay responsiveness on a lower-powered device.

## Signed candidate

After signing is configured:

```sh
flutter build appbundle --release
```

This produces the default ad-disabled release. Only after audience, AdMob, consent, and privacy setup has been verified, explicitly enable live ads:

```sh
flutter build appbundle --release --dart-define=ENABLE_PRODUCTION_ADS=true
```

Inspect the merged manifest, signing certificate, version code, and actual target SDK of the candidate. Verify current store requirements in Play Console. Test the signed bundle through internal testing before a staged production rollout. A successful debug build or unit test run does not establish device or store acceptance.
