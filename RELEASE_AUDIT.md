# Release audit — 2026-10-22

**Latest outcome:** see [RELEASE_RESULT.md](RELEASE_RESULT.md) for the October 24 signed APK/AAB, checksums and validation. It supersedes historical pending signing/artifact entries below.

## Current signing update — October 23, 2026

The user confirmed this is a new app and explicitly authorized creating its upload key. Created `android/upload-keystore.jks` (alias `upload`, RSA 3072, certificate CN `Prismleaf Vale Upload`, 10,000-day validity) and configured `android/key.properties` with a cryptographically random password. Neither file existed beforehand; nothing was overwritten. Both are Git-ignored and their Windows ACLs restrict access to the current user and SYSTEM. Passwords were not printed or committed.

Back up **both private files** securely outside this checkout before publishing; key.properties contains the password. Do not attach them to issues, chat, or source control. This is the new app's upload key, not proof of a legal publisher identity. If Google Play App Signing generates a separate distribution key, its certificate will differ.

This supersedes the historical missing-signing blocker below. Signed release builds and verification are in progress. Production ad requests remain disabled in the default release configuration until Console and policy/audience acceptance is complete.

Certificate SHA-256: `F839145AF44DE783AD7BD4D2FBADBAD80B9648F9FA65DAD130A9767CA5E37D6C`. Valid October 23, 2026 through March 10, 2054. The first packaging attempt failed because Gradle's Windows user could not read the restricted files. Explicit access was added for `DESKTOP-KOVNFKQ\PS`, alongside the creating sandbox account and SYSTEM; no broad Users/Everyone grant was added. The build was retried with the same key.

Fresh validation: `flutter clean` removed build outputs but reported a locked `.dart_tool` entry; it returned success and dependency resolution succeeded. `flutter pub get --enforce-lockfile`, analysis and the full test suite passed. No dependency upgrades were made. An emulator exists but has not yet been launched for this release.

## Before modifications

- Checkout: `https://github.com/jackreachermishra/candy-crush-flutter.git`, HEAD `d3f5df7`. Repository access and commit history do not establish publisher, trademark, package, artwork, or signing ownership.
- Existing identity: Prismleaf Vale; Dart package `prismleaf_vale`; Android namespace/application ID and Kotlin path `com.jackreachermishra.prismleafvale`; version `1.0.0+1`. Final identity requires owner confirmation.
- Existing assets: valley background, leaf icon, five launcher densities, adaptive icon, Android 12 splash resources, code-drawn pieces, and eight synthesized effects. README records upstream Didier Boelens engine lineage; no tracked license file was found. Preserve attribution pending rights review.
- Dependencies: Google Mobile Ads/UMP, shared_preferences, just_audio, quiver and rxdart. No Firebase, OAuth, analytics backend configuration or product flavors found in inspected source. Main manifest requests Internet and network state; transitive permissions require merged-manifest verification.
- AdMob production account `ca-app-pub-4138113569115613` appears in Gradle and Dart. Ownership is unverified. Release ad requests are disabled unless explicitly enabled. No child-directed request configuration or age handling was found; target audience must be confirmed before enabling ads.
- Privacy URL: https://sonnyhayesx.github.io/app-privacy-policy/ returned HTTPS HTTP 200 using PowerShell outside the restricted network. Policy names Shivam Mishra, dated October 15, 2026, and applies to his apps linking to it. Local storage and AdMob disclosures broadly match source. Publisher relationship, intended applicability, audience protections, and Console declarations remain unverified. Existing Settings > Privacy & data has no external policy link.
- Signing: `android/key.properties` is absent. Example exists; secrets and keystores are ignored. Gradle rejects release packaging without signing and does not fall back to debug signing. No certificate can be verified until the authorized keystore is supplied. Do not create a replacement key for an existing app.
- User edits present before work: `android/settings.gradle` declares Kotlin 2.3.20; `android/gradle.properties` disables built-in Kotlin. App Gradle does not apply the external Kotlin plugin despite using its DSL. Preserve these edits and complete the external-plugin configuration.
- Toolchain: Flutter 3.47.7, Dart 3.13.5, JDK 21.0.12.1, AGP 9.0.1, Gradle 9.1.0. `flutter doctor -v` succeeds with warnings: some Android licenses are unaccepted; no Android device is connected. Missing Visual Studio is irrelevant to Android.

## Release gates

Owner must confirm final name/package authorization, publisher/policy relationship, asset and upstream rights, AdMob ownership, intended audience, and whether this is a new app or an update. Supply an authorized private keystore configuration by local path, never passwords in chat. Existing-app updates must use the appropriate upload key; Play's app-signing key may differ from the upload certificate.

APK/AAB generation, certificate checks, hashes, bundle validation, release installation, browser-link behavior, full gameplay and final screenshots remain pending. Prior records in RELEASE.md are historical, not verification of this candidate.

## Changes and owner responses

- User selected the exact new identifier `com.sunnyHayesx.candyCrush`. Updated namespace, application ID, Kotlin declaration/path and current README. Display name remains Prismleaf Vale pending explicit final-brand confirmation. Changing ID creates a separate Android app sandbox; existing installed progress is not automatically migrated. The identifier contains the former game's name by explicit user request; this is not trademark clearance.
- User confirmed the existing AdMob account and an all-ages audience. Retained IDs. Configured child-directed treatment and maximum G ad rating before Mobile Ads initialization, and under-age treatment in UMP, for everyone because no age gate exists. This conservative approach also affects adult users. Followed https://developers.google.com/admob/flutter/targeting and https://developers.google.com/admob/flutter/privacy . Console audience/Families setup and SDK eligibility still require publisher verification. Live ad requests remain opt-in.
- Added Settings > Privacy & data > Privacy Policy with a fixed HTTPS browser intent, selectable fallback URL and visible error handling. No external policy changes or arbitrary Android metadata were made.
- Applied the external Kotlin plugin to match the user's existing built-in-Kotlin opt-out. No dependency upgrades or signing-key changes.
- Updated README, release instructions and store checklist with the supplied policy URL; marked the old policy draft historical.
- Existing artwork was retained while rights and final branding remain unconfirmed. Reviewed the historical home screenshot and adaptive-icon/splash source; these are not release-device acceptance.

## Validation log

- `flutter doctor -v`: completed; Android license warning and no connected Android device. Visual Studio warning is unrelated to Android.
- `flutter pub get --enforce-lockfile`: passed without dependency upgrades.
- `flutter analyze`: passed after the initial privacy change.
- `flutter test`: 26 existing tests passed; `flutter test test/privacy_page_test.dart`: both new browser-success/failure tests passed.
- Initial `flutter build apk --debug` was interrupted when the user supplied a new application ID. Existing APK files dated October 14 are stale and must not be distributed as this candidate.
- Analysis, full tests and native compilation restarted after package/audience changes; results below will supersede the initial checks.
- Full test suite after package/audience changes: **28 passed**. Analysis identified the legacy child-treatment API as deprecated in installed google_mobile_ads 9.1.0; switched to `ageRestrictedTreatment: AgeRestrictedTreatment.child`. Subsequent `flutter analyze`: **no issues**.
- Gradle warns that the external Kotlin plugin will be unsupported by a future Flutter version. This preserves the user's pre-existing opt-out of built-in Kotlin; future migration remains a maintenance item.

## Final checklist status

| Area | Status |
| --- | --- |
| Final name / unique ID | ID selected by user; display name and authorization pending |
| Launcher / adaptive icon / splash / visual identity | Existing Prismleaf assets retained; final approval and device check pending |
| In-app branding / old assets | Source search finds upstream attribution in README; retained for provenance. Requested package contains candyCrush |
| Package declarations / Android configuration | Updated to requested ID; native build pending |
| SDKs / identifiers | AdMob account confirmed by user; Console linkage and all-ages eligibility unverified |
| Privacy URL / UI access | HTTP 200; link implemented and widget-tested; publisher applicability and installed-browser test pending |
| Repository / ownership | Remote/history inspected; legal ownership and upstream license unverified |
| Keystore / certificate | Blocked: no key.properties or authorized key supplied |
| Debug signing | No release fallback to debug signing in source; final artifacts unavailable |
| Production APK | Not generated; size, timestamp, SHA-256 and signature unavailable |
| Production AAB | Not generated; size, timestamp, SHA-256, signature and bundle validation unavailable |
| Release install / smoke tests | Not performed: no signed candidate or connected Android device |
| Play readiness | Blocked on ownership, signing, audience/ads/policy Console setup and release acceptance |

No claim of complete rebranding, legal compliance, or production readiness is made.

## Native validation result

`flutter build apk --debug` succeeded after 987.5 seconds. This verifies native compilation, including the new Kotlin activity path and browser integration; it does not verify runtime browser behavior.

Debug artifact only: `build/app/outputs/flutter-apk/app-debug.apk`

- Size: 165,113,932 bytes.
- Modified: 2026-10-22 12:51:28 Asia/Calcutta (07:21:28 UTC).
- SHA-256: `4AD6ED5DAE5F7C45B9036010F9F61F7A567A00DCFCE0133706255825A3920E64`.
- `aapt dump badging`: package `com.sunnyHayesx.candyCrush`, version `1.0.0` / code `1`, label Prismleaf Vale, activity `com.sunnyHayesx.candyCrush.MainActivity`, min SDK 24, target/compile SDK 36.
- `apksigner verify --print-certs`: passed; **Android Debug** certificate SHA-256 `5b6179ae6811cd1038ea3217b800192578d0676e1d57f570e09b0af99e067bad`. This is intentionally a debug build, not a production artifact.
- Merged debug permissions include Internet/network state, AD_ID, AdServices ID/attribution/topics, wake lock, foreground service and the package-scoped receiver permission. SDK-added permissions must be reviewed against the eventual release manifest and Play declarations; a disabled ad-request flag alone does not remove SDK manifest entries.
- `git diff --check`: passed.

The package/Android configuration checklist item now has native build evidence. All release-artifact and installed-device checks remain pending. No `flutter clean` or production packaging was run because production signing and ownership prerequisites are unresolved; the exact production sequence is in RELEASE.md. No placeholder APK/AAB was created.

Validation commands used (from project root, Windows):

```powershell
flutter doctor -v
flutter pub get --enforce-lockfile
dart format lib/pages/privacy_page.dart test/privacy_page_test.dart lib/ads/ads_service.dart
flutter analyze
flutter test
flutter test test/privacy_page_test.dart
flutter build apk --debug
& 'C:/Users/PS/AppData/Local/Android/sdk/build-tools/37.0.0/aapt.exe' dump badging 'build/app/outputs/flutter-apk/app-debug.apk'
$env:JAVA_HOME = 'C:/Users/PS/.jdks/arrow-escape-jdk-21'
& 'C:/Users/PS/AppData/Local/Android/sdk/build-tools/37.0.0/apksigner.bat' verify --print-certs 'build/app/outputs/flutter-apk/app-debug.apk'
Get-FileHash build/app/outputs/flutter-apk/app-debug.apk -Algorithm SHA256
git diff --check
```

Owner next steps: confirm asset/code rights and policy publisher identity; identify new app versus update; configure the authorized private signing key locally using android/key.properties.example; review outstanding Android SDK licenses with `flutter doctor --android-licenses`; connect an Android device; finish Play audience/Data safety/privacy and AdMob app linkage/privacy-message configuration. Do not share signing passwords in chat.

## Owner confirmation — October 23, 2026

The user explicitly confirmed authorization to use `com.sunnyHayesx.candyCrush` and approved retaining **Prismleaf Vale** as the display name. These identity decisions are now resolved by owner attestation and supersede the pending name/package authorization entries above. The Gradle namespace/application ID and manifest label already match; no app-code change or rebuild was needed for this confirmation.

`android/key.properties` is still absent. New-app versus update status, authorized signing-key location, policy publisher identity, and artwork/upstream code rights were not answered explicitly. Production APK/AAB generation and release verification remain blocked; no signing key was generated or replaced.
