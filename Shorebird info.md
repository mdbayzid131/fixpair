# Shorebird Code Push — Universal Cheatsheet & Guide

A clean and reusable cheatsheet for Flutter projects using **Shorebird Code Push** on Android and iOS.

---

## 1. When to Patch vs. When to Release

| Scenario | Action | Reason |
| :--- | :--- | :--- |
| **Dart / UI changes, bug fixes, text updates** | **`Patch`** | Delivers instant Over-The-Air (OTA) updates directly to user devices without store review. |
| **Added packages with native code (plugins)** | **`Release`** | Native code cannot be updated via OTA. Requires a new store build. |
| **Modified `android/` or `ios/` native files** | **`Release`** | Native platform changes require full binary rebuild. |
| **Bumped `version` in `pubspec.yaml`** | **`Release`** | Version bumps create a new base release. |

---

## 2. Commands Reference

### Step 1: Initial Setup (One-Time per Project)
Initialize Shorebird in any Flutter project:
```bash
# Initialize Shorebird (generates shorebird.yaml)
shorebird init

# Check environment and setup health
shorebird doctor
```

---

### Step 2: Store Releases (Base Builds)
Run these commands when uploading a new version to the Play Store / App Store:

#### Android Release (Generates AAB):
```bash
shorebird release android
```
*(Upload the generated `.aab` file to Google Play Console)*

#### iOS Release (Generates IPA):
```bash
shorebird release ios
```
*(Upload the generated `.ipa` file to App Store Connect)*

---

### Step 3: Instant Over-The-Air Patches
Run these commands to deploy instant updates to users without store review:

#### Android Patch:
```bash
shorebird patch android --allow-asset-diffs
```

#### iOS Patch:
```bash
shorebird patch ios --allow-asset-diffs
```

> [!TIP]
> **Why `--allow-asset-diffs`?**
> Ensures the build succeeds automatically even if assets, fonts, or `.arb` localization files have differences, avoiding interactive prompts or build halts.

---

### Step 4: Monitoring & Testing

#### List all releases:
```bash
shorebird releases list
```

#### List patches for a specific release:
```bash
shorebird patches list --release-version=<VERSION>

# Example:
shorebird patches list --release-version=1.0.9+13
```

#### Test patch locally on a connected device:
```bash
shorebird preview
```

#### Diagnostic health check:
```bash
shorebird doctor
```

---

## 3. Project Configuration & History

- **App Name:** `tbsosick`
- **Shorebird App ID:** `d226346b-cb15-423f-b148-2d1f233a1516`
- **Current Version:** `1.0.9+13`
- **Flutter SDK:** `3.44.8`

### Patch Log:
- **Patch #1 (Android):**
  - **Date:** August 10, 2026
  - **Details:** PDF footer link changed to `www.smrtscrub.com`, subscription premium card text updated to monthly indicator (`20 Preference Cards / Month`).
