# Flutter Social Login Setup Documentation (Google & Apple)

This document provides a comprehensive, step-by-step developer guide for setting up Google and Apple Social Logins in the **Fixpair** Flutter application.

---

## 1. Portal Configuration Guides

### A. Apple Developer Portal Configuration
To enable Apple Sign-In (and iOS Push Notifications) on both iOS and Android platforms:

1. **Enable App ID Capabilities**:
   * Go to **Apple Developer Account** > **Certificates, Identifiers & Profiles** > **Identifiers**.
   * Click on your App ID (e.g., `com.fixpair.app`).
   * Scroll down and check the boxes for:
     * **Sign In with Apple** (click Edit, select *Enable as a primary App ID*, and save).
     * **Push Notifications** (required for APNs notifications).
   * Save and update.

2. **Generate Apple Auth Keys (`.p8` file)**:
   * Go to **Keys** section, click **+** to add a new key.
   * Enter a Key Name (e.g., `Fixpair Auth Key`).
   * Select **Sign In with Apple** (and optionally **Apple Push Notifications service (APNs)** if you are using the same key for notifications).
   * Click **Register**, then click **Download** to download the `.p8` private key file.
   * **Crucial Note**: Save this file securely. You can only download it once. Copy down the **Key ID** (10-character string) and your **Team ID** (found in Membership settings).

3. **Configure Services ID (Required for Android Apple Sign-In)**:
   * Go to **Identifiers**, click the drop-down menu on the top-right and select **Services IDs**, then click **+**.
   * Enter a Description and Identifier (e.g., `com.fixpair.app.services`).
   * Register the Services ID, click on it, check the **Sign In with Apple** box, and click **Configure**.
   * Select your **Primary App ID** (`com.fixpair.app`).
   * Under **Domains and Subdomains**, add: `fixpair-606c8.firebaseapp.com`
   * Under **Return URLs** (Redirect URI), add:
     `https://fixpair-606c8.firebaseapp.com/__/auth/handler`
   * Click **Save** > **Continue** > **Save**.

---

### B. Android Keystore & SHA Fingerprints Configuration
To verify Google Sign-In requests, Google requires verification of the app's signing credentials:

1. **Obtain SHA Fingerprints**:
   * Open a terminal in your project directory and run:
     ```bash
     ./gradlew signingReport
     ```
   * Extract the **SHA-1** and **SHA-256** fingerprints for both:
     * `debug` variant (for local development testing).
     * `release` variant (from your production release keystore).

2. **Add Fingerprints to Firebase**:
   * Go to **Firebase Console** > **Project Settings** > **General** tab.
   * Under your Android app settings, click **Add fingerprint** and add both the SHA-1 and SHA-256 hashes.
   * Download the updated `google-services.json` file and place it in your `android/app/` directory.

---

## 2. Firebase Console Configuration

1. **Enable Sign-in Providers**:
   * Go to **Firebase Console** > **Authentication** > **Sign-in method** tab.
   * Click **Add new provider** and enable **Google**. Save.
   * Click **Add new provider** and enable **Apple**.

2. **Upload Apple Credentials**:
   * Under the Apple provider settings:
     * Enter your **Apple Team ID**.
     * Enter your **Key ID** (from the `.p8` key generation).
     * Paste the contents of or upload your **private key `.p8` file**.
     * Click **Save**.

---

## 3. Flutter Client-Side Implementation

### A. Dependencies Added
In [pubspec.yaml](file:///c:/Users/mdbay/StudioProjects/fixpair/pubspec.yaml), we added the native Google Sign-in package:
```yaml
dependencies:
  firebase_auth: ^6.1.3
  google_sign_in: ^6.2.1
```

### B. API Constant & Repository Layers
1. **Endpoint Mapping** in [api_constants.dart](file:///c:/Users/mdbay/StudioProjects/fixpair/lib/config/constants/api_constants.dart):
   ```dart
   static const String socialLogin = '/auth/social-login';
   ```
2. **REST API Request** in [auth_repository.dart](file:///c:/Users/mdbay/StudioProjects/fixpair/lib/data/repositories/auth_repository.dart):
   ```dart
   Future<Response> socialLogin({
     required String idToken,
     required String provider,
   }) async {
     return await apiClient.postData(ApiConstants.socialLogin, {
       "idToken": idToken,
       "provider": provider,
     });
   }
   ```

### C. Authentication Service Logic
In [auth_service.dart](file:///c:/Users/mdbay/StudioProjects/fixpair/lib/core/services/auth_service.dart), we implemented the native flows:

* **Google Login**:
  ```dart
  Future<Response> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled.');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve Firebase ID Token.');
      }
      final Response response = await _authRepo.socialLogin(
        idToken: idToken,
        provider: 'google',
      );
      await handleAuthResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  ```

* **Apple Login (Using `signInWithProvider` for Android Compatibility)**:
  We use `signInWithProvider` with `AppleAuthProvider()` to let Firebase automatically initialize the state in a webview on Android, preventing "missing initial state" redirect errors:
  ```dart
  Future<Response> loginWithApple() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithProvider(AppleAuthProvider());
      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve Firebase ID Token.');
      }
      final Response response = await _authRepo.socialLogin(
        idToken: idToken,
        provider: 'apple',
      );
      await handleAuthResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  ```

### D. Controller Trigger Methods
In both [login_controller.dart](file:///c:/Users/mdbay/StudioProjects/fixpair/lib/modules/auth/controllers/login_controller.dart) and [register_controller.dart](file:///c:/Users/mdbay/StudioProjects/fixpair/lib/modules/auth/controllers/register_controller.dart):
```dart
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final response = await _authService.loginWithGoogle();
      if (response.statusCode == 200) {
        Helpers.showSuccess('Login successful');
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else {
        Helpers.showError(response.data['message'] ?? 'Google Login failed');
      }
    } catch (e) {
      Helpers.showDebugLog(e.toString());
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;
      final response = await _authService.loginWithApple();
      if (response.statusCode == 200) {
        Helpers.showSuccess('Login successful');
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else {
        Helpers.showError(response.data['message'] ?? 'Apple Login failed');
      }
    } catch (e) {
      Helpers.showDebugLog(e.toString());
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
```

### E. UI Buttons Configuration
Wired the Google and Apple buttons in [login_view.dart](file:///c:/Users/mdbay/StudioProjects/fixpair/lib/modules/auth/views/login_view.dart) and [register_view.dart](file:///c:/Users/mdbay/StudioProjects/fixpair/lib/modules/auth/views/register_view.dart):
```dart
// 8. Social Buttons
Row(
  children: [
    Expanded(
      child: _buildSocialButton(
        icon: ImagePaths.googleIcon,
        label: 'Google',
        onTap: controller.loginWithGoogle, // Wired Google login
      ),
    ),
    SizedBox(width: 16.w),
    Expanded(
      child: _buildSocialButton(
        icon: Icons.apple,
        label: 'Apple',
        onTap: controller.loginWithApple, // Wired Apple login
        isSvg: false,
      ),
    ),
  ],
)
```
