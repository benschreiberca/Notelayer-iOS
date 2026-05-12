/**
 * Firebase Web SDK configuration for Notelayer.
 * Project: notelayer-c7bba
 *
 * Replace the placeholder values with the real config from:
 * Firebase Console → Project Settings → Your apps → Web app → SDK setup
 */

export const firebaseConfig = {
  apiKey:            "REPLACE_WITH_API_KEY",
  authDomain:        "notelayer-c7bba.firebaseapp.com",
  projectId:         "notelayer-c7bba",
  storageBucket:     "notelayer-c7bba.appspot.com",
  messagingSenderId: "REPLACE_WITH_SENDER_ID",
  appId:             "REPLACE_WITH_APP_ID",
};

/**
 * Email magic link action settings.
 * The redirect URL must be added to Firebase Auth → Authorized domains.
 */
export const emailLinkSettings = {
  url:             "https://notelayer-c7bba.firebaseapp.com/emailSignIn",
  handleCodeInApp: true,
};
