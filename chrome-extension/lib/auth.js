// Google sign-in for the extension, exchanged for a Firebase ID token.
//
// Flow:
//   1. chrome.identity.getAuthToken() -> Google OAuth access token
//      (requires an OAuth client of type "Chrome Extension" in Google Cloud,
//       wired via manifest.json "oauth2". See README.)
//   2. Identity Toolkit accounts:signInWithIdp exchanges that for a Firebase
//      ID token + the user's uid (localId), which Firestore rules understand.
//
// Firebase ID tokens last ~1 hour; we cache in chrome.storage.session and
// re-exchange on expiry. The Google token from getAuthToken is cached by Chrome.
import { ENDPOINTS } from "./config.js";

const SESSION_KEY = "nl_firebase_session";
const SKEW_MS = 5 * 60 * 1000; // refresh 5 min before expiry

function getGoogleToken(interactive) {
  return new Promise((resolve, reject) => {
    chrome.identity.getAuthToken({ interactive }, (token) => {
      if (chrome.runtime.lastError || !token) {
        reject(new Error(chrome.runtime.lastError?.message || "No Google token"));
      } else {
        resolve(token);
      }
    });
  });
}

function removeCachedGoogleToken(token) {
  return new Promise((resolve) => {
    if (!token) return resolve();
    chrome.identity.removeCachedAuthToken({ token }, () => resolve());
  });
}

async function exchangeForFirebase(googleToken) {
  const res = await fetch(ENDPOINTS.signInWithIdp, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      postBody: `access_token=${googleToken}&providerId=google.com`,
      requestUri: "https://notelayer-c7bba.firebaseapp.com",
      returnIdpCredential: true,
      returnSecureToken: true,
    }),
  });
  if (!res.ok) {
    throw new Error(`signInWithIdp ${res.status}: ${await res.text()}`);
  }
  const data = await res.json();
  return {
    idToken: data.idToken,
    refreshToken: data.refreshToken,
    uid: data.localId,
    email: data.email,
    displayName: data.displayName || data.fullName || data.email,
    photoUrl: data.photoUrl || null,
    // expiresIn is seconds-as-string
    expiresAt: Date.now() + (parseInt(data.expiresIn || "3600", 10) * 1000),
  };
}

async function readSession() {
  const stored = await chrome.storage.session.get(SESSION_KEY);
  return stored[SESSION_KEY] || null;
}

async function writeSession(session) {
  await chrome.storage.session.set({ [SESSION_KEY]: session });
}

/** Returns a valid Firebase session, signing in interactively if needed. */
export async function signIn() {
  const googleToken = await getGoogleToken(true);
  try {
    const session = await exchangeForFirebase(googleToken);
    await writeSession(session);
    return session;
  } catch (err) {
    // A stale Google token can cause the exchange to fail; drop it and retry once.
    await removeCachedGoogleToken(googleToken);
    const fresh = await getGoogleToken(true);
    const session = await exchangeForFirebase(fresh);
    await writeSession(session);
    return session;
  }
}

/**
 * Returns a non-expired session without prompting, or null if the user must
 * sign in. Re-exchanges silently when the cached Firebase token is near expiry.
 */
export async function getValidSession() {
  const session = await readSession();
  if (session && session.expiresAt - SKEW_MS > Date.now()) {
    return session;
  }
  // Try a silent refresh via Chrome's cached Google token.
  try {
    const googleToken = await getGoogleToken(false);
    const refreshed = await exchangeForFirebase(googleToken);
    await writeSession(refreshed);
    return refreshed;
  } catch {
    return null;
  }
}

export async function signOut() {
  const session = await readSession();
  try {
    const googleToken = await getGoogleToken(false);
    await removeCachedGoogleToken(googleToken);
  } catch {
    /* no cached token */
  }
  await chrome.storage.session.remove(SESSION_KEY);
  return session;
}
