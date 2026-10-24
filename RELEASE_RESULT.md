# Signed release candidate — October 24, 2026

> Historical five-level artifacts: the 100-level campaign work began after these
> binaries were built. They do not contain the expanded campaign. The rebuilt APK
> installed and its process remained alive without the earlier Room startup crash,
> but the emulator showed splash/black output; home, gameplay and browser-link
> acceptance were not verified. Updated campaign build results must be recorded
> separately before treating new source as a tested release.

**Rebuilt candidate:** The first signed build crashed in AndroidX Startup because R8 removed WorkDatabase_Impl's reflected no-argument constructor. Added android/app/proguard-rules.pro with a targeted constructor keep rule, wired it into release Gradle, and rebuilt both artifacts using the same upload key. R8 seeds now retain the constructor. The table below describes only the rebuilt artifacts. See [R8 full-mode behavior](https://developer.android.com/topic/performance/app-optimization/full-mode). Installed-release acceptance is pending the retry.

Prismleaf Vale — `com.sunnyHayesx.candyCrush` — version **1.0.0 (1)**.

The owner approved this name and identifier, confirmed a new app and the existing AdMob account, and authorized creation of a new upload key. Both artifacts use the default release configuration: **live ad requests are disabled**. The configured production AdMob App ID is retained in both manifests. This is a signed candidate, not a claim of Play approval or complete legal/publisher verification.

## Artifacts

| Artifact | Path | Bytes | Modified (Asia/Calcutta) | SHA-256 |
| --- | --- | ---: | --- | --- |
| APK | `build/app/outputs/flutter-apk/app-release.apk` | 57,006,488 | October 24, 2026 11:48:31 | `6DEEA4255A3CD7D35A4A5C73BE74C15269FE09AA44EBD67BB09D2A0B9FA4C97A` |
| AAB | `build/app/outputs/bundle/release/app-release.aab` | 59,087,163 | October 24, 2026 11:52:31 | `F05B45691C44C991C54DD913EEB077860B755F5A1BF7419722614D80A2323841` |

Both manifests have the same package, version, label, minimum SDK **24**, target/compile SDK **36**, and no enabled `debuggable` or `testOnly` attribute.

## Signing and independent checks

- New private key: `android/upload-keystore.jks`, alias `upload`, RSA 3072, CN `Prismleaf Vale Upload`, expires March 10, 2054. Password is stored in ignored `android/key.properties`; neither private file is tracked. Windows access is restricted to the creating sandbox account, the owner's Windows account and SYSTEM.
- Both artifact certificate SHA-256 fingerprints match the new key: `F839145AF44DE783AD7BD4D2FBADBAD80B9648F9FA65DAD130A9767CA5E37D6C`. Neither is debug-signed.
- APK: `apksigner verify --verbose --print-certs` passed with APK Signature Scheme v2. Package/version/permissions checked with `aapt dump badging`; release flags and AdMob metadata checked with `aapt dump xmltree`.
- AAB: official Google bundletool **1.18.3** `validate` exited 0. `dump manifest --module=base` confirms the matching identity/version. `jarsigner -verify` reports **jar verified**; `keytool -printcert -jarfile` confirms the certificate.
- Jarsigner warnings are retained in `build/release-verification/aab-signature.txt`: self-signed/untrusted certificate chain, no timestamp, POSIX attributes, and manifest ordering causing JarInputStream verification differences. These were not silently suppressed. Bundletool validation and JarFile signature verification passed, but Play Console acceptance is not verified. Java's streaming reader requires the manifest at the start; see [Oracle JarInputStream documentation](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/jar/JarInputStream.html). The Gradle-produced bundle has not been manually repacked.
- Merged release permissions: Internet, network state, advertising ID, AdServices ID/attribution/topics, wake lock, foreground service, and the app-scoped non-exported receiver permission. Review these SDK contributions in Data safety and audience declarations even though live ad requests are disabled.

**Back up the keystore and key.properties securely outside this checkout before publishing.** Do not commit or share them. Play App Signing may use a separate Google-managed distribution certificate; this certificate is the upload key.

## Validation and commands

`flutter clean` removed old builds but warned about a locked `.dart_tool` entry. Locked dependency resolution, analysis and all **28 tests** passed afterward. APK and AAB release builds succeeded. Initial packaging failed due to the build account lacking signing-file access; the ACL was corrected and the same key was reused. The external Kotlin plugin produces a future-compatibility warning; no dependency or Kotlin migration was performed in this signing step.

```powershell
flutter clean
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-release.apk
aapt dump badging build/app/outputs/flutter-apk/app-release.apk
java -jar bundletool-all-1.18.3.jar validate --bundle=build/app/outputs/bundle/release/app-release.aab
java -jar bundletool-all-1.18.3.jar dump manifest --bundle=build/app/outputs/bundle/release/app-release.aab --module=base
jarsigner -verify build/app/outputs/bundle/release/app-release.aab
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
Get-FileHash build/app/outputs/flutter-apk/app-release.apk -Algorithm SHA256
Get-FileHash build/app/outputs/bundle/release/app-release.aab -Algorithm SHA256
```

Android/JDK tools were invoked using their installed absolute paths; bundletool was downloaded from Google's official GitHub release into the Windows temporary directory. APK compilation spanned a machine interruption and prolonged memory-constrained optimization; AAB compilation took 298.5 seconds. This is not a build-speed benchmark.

## Remaining acceptance gates

- Privacy policy is https://sonnyhayesx.github.io/app-privacy-policy/ (HTTPS HTTP 200 verified October 22); accessible in source at Settings > Privacy & data > Privacy Policy, with browser-error tests. Publisher identity/applicability confirmation remains outstanding.
- Existing artwork and upstream engine license rights still require confirmation. Repository access and this newly generated certificate do not establish those rights.
- AdMob ownership and all-ages audience were confirmed by the user. Child-age treatment and maximum G ad content rating are configured for every user. Play Families/audience, Data safety, AdMob app linkage/privacy messages and SDK eligibility require owner Console checks before enabling ads.
- Installed-release testing is in progress on the available emulator; physical-device testing and a full five-level playthrough have not been performed.
- No Play upload or publication was performed. Validate the AAB in the owner's Play Console internal-testing track and resolve any Console findings before production rollout.

This report supersedes historical missing-key/artifact status in RELEASE_AUDIT.md. Earlier debug artifacts were removed by the clean build.
