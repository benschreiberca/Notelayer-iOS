// Minimal Firestore REST client for Manifest V3.
//
// MV3's content security policy forbids loading the Firebase JS SDK from a CDN,
// and bundling it would require a build step. The Firestore REST API covers
// everything this extension needs (list/get/create/update) and keeps the
// extension a zero-build, plain-ES-module project.
//
// Document paths mirror the iOS app exactly:
//   users/{uid}/tasks/{taskId}
//   users/{uid}/categories/{categoryId}
import { ENDPOINTS } from "./config.js";

// ---- Typed value conversion -------------------------------------------------
// Firestore REST represents every field as a typed wrapper, e.g.
//   { stringValue: "hi" }, { integerValue: "3" }, { arrayValue: { values: [...] } }
// These helpers convert between that wire format and plain JS values.

function toFirestoreValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (typeof value === "boolean") return { booleanValue: value };
  if (typeof value === "number") {
    return Number.isInteger(value)
      ? { integerValue: String(value) }
      : { doubleValue: value };
  }
  if (typeof value === "string") return { stringValue: value };
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(toFirestoreValue) } };
  }
  if (typeof value === "object") {
    const fields = {};
    for (const [k, v] of Object.entries(value)) fields[k] = toFirestoreValue(v);
    return { mapValue: { fields } };
  }
  return { stringValue: String(value) };
}

function fromFirestoreValue(value) {
  if (value == null) return null;
  if ("nullValue" in value) return null;
  if ("stringValue" in value) return value.stringValue;
  if ("booleanValue" in value) return value.booleanValue;
  if ("integerValue" in value) return parseInt(value.integerValue, 10);
  if ("doubleValue" in value) return value.doubleValue;
  if ("timestampValue" in value) return new Date(value.timestampValue);
  if ("arrayValue" in value) {
    return (value.arrayValue.values || []).map(fromFirestoreValue);
  }
  if ("mapValue" in value) {
    const out = {};
    for (const [k, v] of Object.entries(value.mapValue.fields || {})) {
      out[k] = fromFirestoreValue(v);
    }
    return out;
  }
  return null;
}

export function encodeFields(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v === undefined) continue;
    fields[k] = toFirestoreValue(v);
  }
  return fields;
}

export function decodeDocument(doc) {
  if (!doc || !doc.fields) return null;
  const out = { _name: doc.name };
  for (const [k, v] of Object.entries(doc.fields)) {
    out[k] = fromFirestoreValue(v);
  }
  return out;
}

// ---- REST operations --------------------------------------------------------

async function authedFetch(idToken, url, options = {}) {
  const res = await fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${idToken}`,
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Firestore ${res.status}: ${body}`);
  }
  return res.json();
}

/** List all documents in a user subcollection (handles pagination). */
export async function listCollection(idToken, uid, collection) {
  const base = `${ENDPOINTS.firestore}/users/${uid}/${collection}`;
  let pageToken = "";
  const docs = [];
  do {
    const url = `${base}?pageSize=300${pageToken ? `&pageToken=${pageToken}` : ""}`;
    const data = await authedFetch(idToken, url);
    for (const d of data.documents || []) {
      const decoded = decodeDocument(d);
      if (decoded) docs.push(decoded);
    }
    pageToken = data.nextPageToken || "";
  } while (pageToken);
  return docs;
}

/**
 * Create or overwrite a document at a known id.
 * Uses PATCH (create-or-update) so retries are idempotent.
 */
export async function setDocument(idToken, uid, collection, docId, fields) {
  const url = `${ENDPOINTS.firestore}/users/${uid}/${collection}/${encodeURIComponent(docId)}`;
  return authedFetch(idToken, url, {
    method: "PATCH",
    body: JSON.stringify({ fields: encodeFields(fields) }),
  });
}

/** Patch only specific fields, leaving the rest of the document intact. */
export async function updateFields(idToken, uid, collection, docId, fields) {
  const mask = Object.keys(fields)
    .map((f) => `updateMask.fieldPaths=${encodeURIComponent(f)}`)
    .join("&");
  const url = `${ENDPOINTS.firestore}/users/${uid}/${collection}/${encodeURIComponent(docId)}?${mask}`;
  return authedFetch(idToken, url, {
    method: "PATCH",
    body: JSON.stringify({ fields: encodeFields(fields) }),
  });
}
