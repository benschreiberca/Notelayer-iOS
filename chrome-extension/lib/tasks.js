// Task + category domain layer. Maps Firestore documents to/from the exact
// shape the iOS app uses so records created here appear natively on iPhone/iPad.
import { listCollection, setDocument, updateFields } from "./firestore.js";

// RFC-4122 v4 UUID, uppercased to match Swift's `UUID().uuidString`.
export function newUUID() {
  if (crypto.randomUUID) return crypto.randomUUID().toUpperCase();
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    .replace(/[xy]/g, (c) => {
      const r = (Math.random() * 16) | 0;
      const v = c === "x" ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    })
    .toUpperCase();
}

/** Load categories ordered recently-used-first, matching the iOS quick-add row. */
export async function loadCategories(session) {
  const docs = await listCollection(session.idToken, session.uid, "categories");
  const cats = docs.map((d) => ({
    id: d.id || d._name.split("/").pop(),
    name: d.name || "",
    icon: d.icon || "tag",
    color: d.color || "#6366F1",
    order: typeof d.order === "number" ? d.order : 0,
  }));
  cats.sort((a, b) => (a.order - b.order) || a.id.localeCompare(b.id));

  // Recency is stored locally per-browser (the iOS recency lives in an App Group
  // and isn't synced to Firestore), so surface the user's most-used here too.
  const usage = await getCategoryUsage();
  if (Object.keys(usage).length === 0) return cats;
  const used = cats
    .filter((c) => usage[c.id])
    .sort((a, b) => usage[b.id] - usage[a.id])
    .slice(0, 5);
  const usedIds = new Set(used.map((c) => c.id));
  return [...used, ...cats.filter((c) => !usedIds.has(c.id))];
}

const USAGE_KEY = "nl_category_usage";

async function getCategoryUsage() {
  const stored = await chrome.storage.local.get(USAGE_KEY);
  return stored[USAGE_KEY] || {};
}

export async function recordCategoryUsage(categoryIds) {
  if (!categoryIds || categoryIds.length === 0) return;
  const usage = await getCategoryUsage();
  const now = Date.now();
  for (const id of categoryIds) usage[id] = now;
  await chrome.storage.local.set({ [USAGE_KEY]: usage });
}

/** Load incomplete tasks, newest first. */
export async function loadOpenTasks(session) {
  const docs = await listCollection(session.idToken, session.uid, "tasks");
  return docs
    .map(decodeTask)
    .filter((t) => t && !t.completedAt && !t.parentTaskId)
    .sort((a, b) => (b.createdAt?.getTime() || 0) - (a.createdAt?.getTime() || 0));
}

function decodeTask(d) {
  if (!d) return null;
  return {
    id: d.id || d._name.split("/").pop(),
    title: d.title || "",
    categories: Array.isArray(d.categories) ? d.categories : [],
    priority: d.priority || "medium",
    createdAt: d.createdAt instanceof Date ? d.createdAt : null,
    updatedAt: d.updatedAt instanceof Date ? d.updatedAt : null,
    dueDate: d.dueDate instanceof Date ? d.dueDate : null,
    completedAt: d.completedAt instanceof Date ? d.completedAt : null,
    taskNotes: d.taskNotes || null,
    parentTaskId: d.parentTaskId || null,
    orderIndex: typeof d.orderIndex === "number" ? d.orderIndex : 0,
  };
}

/**
 * Create a task in Firestore using the iOS field layout.
 * Returns the new task id.
 */
export async function addTask(session, { title, taskNotes, categories, priority, dueDate }) {
  const id = newUUID();
  const now = new Date();
  const fields = {
    id,
    title: title.trim(),
    categories: categories || [],
    priority: priority || "medium",
    createdAt: now,
    updatedAt: now,
    orderIndex: 0,
  };
  if (taskNotes) fields.taskNotes = taskNotes;
  if (dueDate) fields.dueDate = dueDate;

  await setDocument(session.idToken, session.uid, "tasks", id, fields);
  await recordCategoryUsage(categories);
  return id;
}

/** Mark a task complete (sets completedAt + updatedAt), matching iOS. */
export async function completeTask(session, taskId) {
  const now = new Date();
  await updateFields(session.idToken, session.uid, "tasks", taskId, {
    completedAt: now,
    updatedAt: now,
  });
}
