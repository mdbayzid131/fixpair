# Backend Implementation Plan: Social Login

This document outlines the API specifications, token verification code, and configuration credentials required by the backend developer to integrate the social login (Google/Apple) with the Flutter client.

---

## 1. Credentials & Configuration Requirements

To start, the backend developer will need the following credentials from Firebase:

### A. Firebase Service Account JSON File (Mandatory for Backend)

- **What it is**: A private JSON key file that allows the Node.js backend to securely communicate with Firebase services (verify client tokens).
- **How to get it**:
  1. Go to **Firebase Console** > **Project Settings** > **Service Accounts**.
  2. Click **Generate new private key** (Node.js selected).
  3. Send this downloaded `.json` file to the backend developer securely.

### B. Google Play Store & Apple App Store (Optional for Backend)

- **No extra credentials needed**: For token verification, the backend developer **does not** need direct access to the Play Store or App Store. The Firebase Admin SDK handles all Apple and Google token validation automatically using the Service Account JSON.
- **Push Notifications (APNs)**: The Apple `.p8` file (Key ID & Team ID) has already been uploaded to the Firebase Console. The backend sends notifications to iOS through Firebase FCM, so the backend developer only needs the Firebase JSON file.

---

## 2. Social Login API Specification

### POST `/api/v1/auth/social-login`

- **Headers**: `Content-Type: application/json`
- **Request Body**:

  ```json
  {
    "idToken": "<raw_firebase_id_token_string_from_flutter>",
    "provider": "google" | "apple"
  }
  ```

- **Success Response (200 OK)**:

  ```json
  {
    "success": true,
    "message": "Login successful",
    "data": {
      "accessToken": "<your_custom_jwt_access_token>",
      "refreshToken": "<your_custom_jwt_refresh_token>"
    }
  }
  ```

- **Error Response (401 Unauthorized)**:
  ```json
  {
    "success": false,
    "message": "Invalid or expired Firebase ID token"
  }
  ```

---

## 3. Database Synchronization Flow (Find or Create)

When the backend receives a verified Firebase token:

1. **Returning Users**: The backend must query the database by `email` or `firebaseUid`. If a record is found, simply issue the custom JWTs without creating a new user.
2. **First-Time Users (Auto-Registration)**: If no record is found in the database, the backend should automatically create a new user record using the email, name, and profile photo from the token, then issue the custom JWTs.

---

## 4. Node.js Verification Code Example

Below is the exact code the backend developer should use to initialize the Firebase Admin SDK and verify the client's `idToken`:

```javascript
const admin = require("firebase-admin");

// 1. Initialize Firebase Admin SDK (using the downloaded service account JSON)
const serviceAccount = require("./path-to-your-firebase-service-account-key.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// 2. Controller method for Social Login
async function socialLogin(req, res) {
  const { idToken, provider } = req.body;

  if (!idToken || !provider) {
    return res
      .status(400)
      .json({ success: false, message: "idToken and provider are required" });
  }

  try {
    // Verify the Firebase ID Token sent from Flutter
    const decodedToken = await admin.auth().verifyIdToken(idToken);

    // Extracted user details from Firebase token
    const firebaseUid = decodedToken.uid;
    const email = decodedToken.email;
    const name = decodedToken.name || decodedToken.email.split("@")[0];
    const avatar = decodedToken.picture || "";

    // Database Sync Flow:
    // 1. Check if user already exists in database by email or firebaseUid
    let user = await User.findOne({ $or: [{ email }, { firebaseUid }] });

    if (!user) {
      // 2. If user does not exist, create a new record in your database (Auto-Registration)
      user = await User.create({
        name,
        email,
        firebaseUid,
        avatar,
        isVerified: true, // Social accounts are pre-verified
        provider: provider, // 'google' or 'apple'
      });
    } else {
      // Update firebaseUid or provider details if missing
      if (!user.firebaseUid) {
        user.firebaseUid = firebaseUid;
        await user.save();
      }
    }

    // 3. Generate standard backend JWT tokens for the user session
    const accessToken = generateAccessToken(user); // Your custom JWT signing logic
    const refreshToken = generateRefreshToken(user); // Your custom JWT refresh logic

    return res.status(200).json({
      success: true,
      message: "Login successful",
      data: {
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    console.error("Firebase Token Verification Failed:", error);
    return res.status(401).json({
      success: false,
      message: "Invalid or expired Firebase ID token",
    });
  }
}
```
