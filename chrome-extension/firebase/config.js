// Firebase project config — same project as iOS app.
// Auth: Firebase Identity Toolkit REST API
// Firestore: Cloud Firestore REST API
// No Firebase JS SDK needed — raw REST calls keep the extension bundle tiny.

export const FIREBASE_API_KEY = "AIzaSyABWHYGN9dr-m3a0qaUwYHlrJAhNd7PfvA";
export const FIREBASE_PROJECT_ID = "notelayer-c7bba";
export const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`;
export const AUTH_BASE = "https://identitytoolkit.googleapis.com/v1";
export const TOKEN_REFRESH_BASE = "https://securetoken.googleapis.com/v1";
