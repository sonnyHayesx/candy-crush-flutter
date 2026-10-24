# Prismleaf Vale

Signed APK/AAB candidate and verification results: [RELEASE_RESULT.md](RELEASE_RESULT.md). Keep the private upload keystore and signing properties backed up securely; both are excluded from Git.

Prismleaf Vale is an offline Android match-three puzzle game. Swap faceted leaves to gather each glade's objectives before the move limit. Five glades have different board shapes and goals; completed glades unlock the next stop on the trail.

## Development

Production validation and the publisher handoff are documented in [RELEASE.md](RELEASE.md). Automated checks run in `.github/workflows/validate.yml` with Flutter 3.47.7.

- Flutter 3.47.0 or newer (required for Android built-in Kotlin) and its bundled Dart SDK
- Android SDK and compatible JDK for Android builds; a device or emulator is needed only to run the app
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

The application ID is `com.sunnyHayesx.candyCrush`. Levels, best scores, daily rewards, current and longest streaks, recent reward history, glow, sound, and vibration preferences are stored locally with `shared_preferences`. Existing save keys remain in place; older streak data initializes the longest streak. The game needs no account or backend and remains playable without a network. It has optional AdMob banner and rewarded ads; there is no background music.

## Local testing APK

For this Windows/OneDrive checkout, use the helper to clear read-only attributes on generated build files before building:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tool/build_test_apk.ps1
```

The helper resolves locked dependencies and builds the debug APK. It does not delete source files or change production signing. Avoid running another build of this project at the same time. If OneDrive re-applies attributes during the build, pause its syncing while building.

Run from the project directory:

```powershell
flutter pub get --enforce-lockfile
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`. Copy it to an Android phone and open it to install. This build uses Android's debug signing and Google's sample ad IDs; no production keystore or production-ads flag is needed.

On this memory-constrained machine, close the emulator and other heavy applications while building, then reopen the emulator or install on a phone afterward. Gradle uses a 1536 MiB heap and one worker, compiles Kotlin in-process, and exits after the build. Kotlin incremental compilation is disabled to avoid reusing damaged lookup caches after interrupted builds. These settings reduce memory use at the cost of slower rebuilds.

To build only for an ARM64 phone (not an x64 emulator):

```powershell
flutter build apk --debug --target-platform android-arm64
```

This writes the same APK path, containing only ARM64 native libraries.

## Ads and consent

The official `google_mobile_ads` plugin is used for Android. The App ID is set with `com.google.android.gms.ads.APPLICATION_ID` in the main manifest; Gradle supplies Google's sample App ID for debug and profile builds and `ca-app-pub-4138113569115613~5280989015` for release. The banner and rewarded ad units are in [`lib/ads/ad_config.dart`](lib/ads/ad_config.dart).

Confirmed production configuration (no `.env` file is used):

| Setting | Value |
| --- | --- |
| App ID | `ca-app-pub-4138113569115613~5280989015` |
| Banner ad unit | `ca-app-pub-4138113569115613/8972822010` |
| Rewarded ad unit | `ca-app-pub-4138113569115613/7199566185` |

Only banner and rewarded ads are implemented. There is no production interstitial ID. Keep the manifest placeholder: Gradle resolves it to the production App ID for release and the sample App ID for testing. Adding a `.env` file does not change this configuration.

Debug and profile builds always use Google's sample ad units. Release builds make **no ad requests by default**. To opt into live ad requests in a release build, use `--dart-define=ENABLE_PRODUCTION_ADS=true`. Never use that flag for local ad testing or click live ads. To register a physical test device, use `--dart-define=ADS_TEST_DEVICE_ID=HASH_FROM_LOGCAT` with a debug build; the sample ad units do not require a test device. For UMP geography testing, pass `--dart-define=UMP_TEST_DEVICE_ID=HASH_FROM_UMP_LOGCAT` in a debug build. That enables the EEA debug geography for that registered test device. These debug device IDs are ignored in release builds.

For the confirmed all-ages audience, requests use AgeRestrictedTreatment.child and maximum G content rating for every user, with under-age treatment in UMP. At launch, UMP refreshes consent information and displays a form if required. Ads initialize and load only if `canRequestAds()` returns true. The Settings sheet shows **Privacy options** when UMP requires an entry point. Configure the appropriate privacy messages in the AdMob console before enabling live ads. The in-app Privacy & data screen summarizes local storage and ads. Settings > Privacy & data > Privacy Policy opens https://sonnyhayesx.github.io/app-privacy-policy/ in the external browser. Publisher authorization, audience protections, and Play Data safety answers still need review; see [RELEASE_AUDIT.md](RELEASE_AUDIT.md). SDK initialization or consent does not guarantee ad fill.

## Android release

The release variant is no longer signed with debug keys. For an existing app, use its authorized upload key; do not generate a replacement without an approved key-reset process. For a new app, arrange a private owner-controlled upload keystore. Copy [`android/key.properties.example`](android/key.properties.example) to `android/key.properties`, then fill in the real values and keep both the keystore and properties private. Without signing credentials, a bundle is not upload ready. Confirm that `com.sunnyHayesx.candyCrush` is an identifier you control and that the AdMob App ID belongs to this app.

The installed Flutter 3.44.9 SDK supplies target API 36 through `flutter.targetSdkVersion`. Verify the built candidate's target SDK and current Play Console requirements before submission. Changing the Android application ID creates a separate app sandbox; progress from an app installed under an older ID cannot migrate automatically through `shared_preferences`.

1. Install the Android SDK and JDK; run `flutter doctor` and `flutter devices`.
2. Run `flutter pub get`, `flutter analyze`, and `flutter test`.
3. Run `flutter build apk --debug` and test the app and Google sample ads on a device or emulator.
4. Complete the publisher and audience decisions in [`store_assets/README.md`](store_assets/README.md), configure UMP messages, confirm the supplied privacy policy and add its URL to Play Console, and capture real screenshots.
5. With signing configured, run `flutter build appbundle --release --dart-define=ENABLE_PRODUCTION_ADS=true` only when live ads are intended. Test the signed bundle and verify the merged manifest and ad behavior on a registered test device before uploading.
6. Upload the AAB through Google Play Console for **internal testing**, then **closed testing**, then a **staged production rollout** after review. Uploading and publishing are manual steps.

## Artwork and audio

The valley illustration and leaf icon were generated for this project. Gameplay pieces and the adaptive icon foreground are drawn by project code. The eight short effects are synthesized by [`tool/generate_sfx.ps1`](tool/generate_sfx.ps1). The former example artwork, third-party credited bomb images, and unused Unity sound-source folder were removed. Store listing drafts and asset status are in [`store_assets/README.md`](store_assets/README.md).

The match-three engine began from the Flutter Candy Crush example by Didier Boelens. This repository retains that code lineage while replacing its presentation. Review any upstream code license and the generated artwork before commercial release.
