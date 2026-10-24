# Release verification

Latest signed candidate: [RELEASE_RESULT.md](RELEASE_RESULT.md), October 24, 2026. Both APK and AAB are generated with the new authorized upload key; see that report for checksums, signature checks and remaining acceptance gates.

## Current candidate — October 22, 2026

See [RELEASE_AUDIT.md](RELEASE_AUDIT.md) for current evidence and unresolved release gates. Older results below do not validate this candidate.

Privacy policy: https://sonnyhayesx.github.io/app-privacy-policy/

The link is available under Settings > Privacy & data > Privacy Policy. HTTPS returned HTTP 200; publisher authorization and audience-specific disclosures still need confirmation. The externally hosted policy was not edited. No Android manifest field in this project explicitly supports a privacy policy URL; enter the URL in Play Console.

After ownership, audience, SDK licenses and authorized signing are resolved, build both artifacts from the same configuration:

```sh
flutter clean
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

These commands leave production ad requests disabled. Enable live ads in **both** build commands only after the AdMob and audience gates are cleared. Validate APK signatures with `apksigner verify --verbose --print-certs`, AAB signatures with `jarsigner -verify -verbose -certs`, and the bundle with `bundletool validate`. Inspect both manifests and record SHA-256, sizes, timestamps and certificates before distribution. Upload-key and Play-distributed app-signing certificates can differ under Play App Signing.

Use Flutter **3.47.7** (Dart **3.13.5**) and JDK 21. Android built-in Kotlin requires Flutter **3.47.0** or newer. CI pins this Flutter version and checks formatting, analysis, tests, and an Android debug build. Newer SDKs satisfy the package constraints, but may change SDK-pinned dependencies. CI artifacts are for testing only.

## Compatibility validation 2026-10-14

- Follow-up for the WebView Kotlin deletion failure: generated directories had Windows read-only attributes. `tool/build_test_apk.ps1` clears those attributes before dependency resolution and debug packaging. The validation run recreated the WebView Kotlin output successfully, then failed in `JetifyTransform` with Java heap exhaustion while processing the Flutter x64 engine JAR. Disabled Jetifier for the AndroidX dependencies. The subsequent retry was stopped while waiting for a separate shared-SDK `flutter upgrade` to finish; the Jetifier change still needs a completed build. After that upgrade finishes, run the helper again and verify the SDK version against the pinned CI version.
- Flutter 3.44.9 / Dart 3.12.2: locked dependency resolution, formatting (50 files unchanged), static analysis, and all 26 tests passed again.
- The installed SDK defines compile and target API 36.
- Native rebuild troubleshooting: Windows prevented Gradle from replacing generated resources for `audio_session` and `google_mobile_ads`. Cleared generated resource caches and then the app and affected plugin outputs. Full build-directory cleanup was interrupted by a locked `build/reports/problems/problems-report.html` file.
- JVM crash logs reported insufficient native memory with both the former 4 GiB heap and a reduced 1536 MiB heap. Gradle now uses the reduced heap and at most two workers. The final crash (`android/hs_err_pid19712.log`, ignored by Git) failed to allocate about 1.8 MB of native memory, so reducing the heap alone did not resolve system memory pressure.
- **Android rebuild remains blocked:** no current APK was produced; the previous APK was removed with the generated app outputs. No new install or emulator smoke test was performed. Free system memory before retrying `flutter build apk --debug`, then install and validate that new APK. An Android 17 emulator was connected, but its existing app is not evidence of this rebuild passing.

## Previous verification recorded 2026-10-13

The native build and emulator results below were obtained with Flutter 3.47.5 before restoring compatibility with the installed Flutter 3.44.9 SDK. Rebuild the release candidate with the selected SDK before device acceptance.

Compatibility recheck on Flutter 3.44.9 / Dart 3.12.2: locked dependency resolution, static analysis, formatting, and all 26 tests passed. The lockfile and CI now target this installed SDK.

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
- Confirm authorization and applicability of https://sonnyhayesx.github.io/app-privacy-policy/ and use this exact URL in Play Console. The local draft is historical only.
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
