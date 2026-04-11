import { FIREBASE_API_KEY, AUTH_BASE, TOKEN_REFRESH_BASE } from "./config.js";

const TOKEN_KEY = "notelayer_id_token";
const REFRESH_KEY = "notelayer_refresh_token";
const USER_ID_KEY = "notelayer_user_id";
const EMAIL_KEY = "notelayer_email";

export async function signIn(email, password) {
  const url = `${AUTH_BASE}/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password, returnSecureToken: true }),
  });
  const data = await res.json();
  if (data.error) throw new Error(data.error.message);

  await chrome.storage.local.set({
    [TOKEN_KEY]: data.idToken,
    [REFRESH_KEY]: data.refreshToken,
    [USER_ID_KEY]: data.localId,
    [EMAIL_KEY]: email,
  });
  return { token: data.idToken, userId: data.localId };
}

export async function signOut() {
  await chrome.storage.local.remove([TOKEN_KEY, REFRESH_KEY, USER_ID_KEY, EMAIL_KEY]);
}

export async function getAuthState() {
  const result = await chrome.storage.local.get([TOKEN_KEY, USER_ID_KEY, EMAIL_KEY]);
  if (!result[TOKEN_KEY]) return null;
  return {
    token: result[TOKEN_KEY],
    userId: result[USER_ID_KEY],
    email: result[EMAIL_KEY],
  };
}

export async function refreshToken() {
  const result = await chrome.storage.local.get(REFRESH_KEY);
  const refreshToken = result[REFRESH_KEY];
  if (!refreshToken) return null;

  const url = `${TOKEN_REFRESH_BASE}/token?key=${FIREBASE_API_KEY}`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=refresh_token&refresh_token=${refreshToken}`,
  });
  const data = await res.json();
  if (data.error) return null;

  await chrome.storage.local.set({ [TOKEN_KEY]: data.id_token });
  return data.id_token;
}
