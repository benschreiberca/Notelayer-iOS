// Firebase project configuration for the Notelayer Chrome extension.
//
// These values are public client identifiers (the same ones shipped in the iOS
// app's GoogleService-Info.plist). They are safe to embed in a client; access is
// gated by Firestore Security Rules keyed on the authenticated user's uid.
export const FIREBASE = {
  apiKey: "AIzaSyABWHYGN9dr-m3a0qaUwYHlrJAhNd7PfvA",
  projectId: "notelayer-c7bba",
  authDomain: "notelayer-c7bba.firebaseapp.com",
  // Web OAuth client used for chrome.identity. See README "Google sign-in setup".
  // Filled in from manifest.json oauth2.client_id at runtime; kept here for docs.
};

// Firestore REST + Identity Toolkit endpoints.
export const ENDPOINTS = {
  firestore: `https://firestore.googleapis.com/v1/projects/${FIREBASE.projectId}/databases/(default)/documents`,
  signInWithIdp: `https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=${FIREBASE.apiKey}`,
  lookup: `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${FIREBASE.apiKey}`,
};

// Priority raw values must match the iOS `Priority` enum exactly so data round-trips.
export const PRIORITIES = ["high", "medium", "low", "deferred"];

// Accent + priority colors pulled from the app's design tokens (DesignSystem.swift).
export const COLORS = {
  accent: "#6366F1",      // indigo500 — brand primary
  accentDark: "#4F46E5",  // indigo600
  purple: "#A855F7",      // purple500
  high: "#F87171",        // red400
  medium: "#F59E0B",      // amber
  low: "#818CF8",         // indigo400
  deferred: "#6B7280",    // gray500
};
