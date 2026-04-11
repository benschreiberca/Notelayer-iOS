import { FIRESTORE_BASE } from "./config.js";

/** Fetch all active (non-completed) tasks for the current user. */
export async function fetchActiveTasks(token, userId) {
  const url = `${FIRESTORE_BASE}/tasks?pageSize=50`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error?.message || "Fetch failed");

  const docs = data.documents || [];
  return docs
    .filter((doc) => {
      const fields = doc.fields || {};
      const docUserId = fields.userId?.stringValue;
      const completedAt = fields.completedAt?.timestampValue;
      return docUserId === userId && !completedAt;
    })
    .map((doc) => parseTask(doc))
    .sort((a, b) => priorityOrder(a.priority) - priorityOrder(b.priority));
}

/** Create a new task document. */
export async function createTask(token, userId, { title, priority = "medium" }) {
  const now = new Date().toISOString();
  const orderIndex = String(Date.now());
  const body = {
    fields: {
      title: { stringValue: title },
      userId: { stringValue: userId },
      priority: { stringValue: priority },
      categories: { arrayValue: { values: [] } },
      createdAt: { timestampValue: now },
      updatedAt: { timestampValue: now },
      orderIndex: { integerValue: orderIndex },
    },
  };
  const res = await fetch(`${FIRESTORE_BASE}/tasks`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error?.message || "Create failed");
  return parseTask(data);
}

/** Mark a task as completed. */
export async function completeTask(token, taskId) {
  const now = new Date().toISOString();
  const url = `${FIRESTORE_BASE}/tasks/${taskId}?updateMask.fieldPaths=completedAt&updateMask.fieldPaths=updatedAt`;
  const body = {
    fields: {
      completedAt: { timestampValue: now },
      updatedAt: { timestampValue: now },
    },
  };
  const res = await fetch(url, {
    method: "PATCH",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const data = await res.json();
    throw new Error(data.error?.message || "Complete failed");
  }
}

function parseTask(doc) {
  const fields = doc.fields || {};
  const nameParts = doc.name?.split("/") || [];
  return {
    id: nameParts[nameParts.length - 1] || "",
    title: fields.title?.stringValue || "",
    priority: fields.priority?.stringValue || "medium",
    userId: fields.userId?.stringValue || "",
    createdAt: fields.createdAt?.timestampValue || "",
  };
}

function priorityOrder(p) {
  return { high: 0, medium: 1, low: 2, deferred: 3 }[p] ?? 1;
}
