import {
  collection, doc, setDoc, updateDoc, deleteDoc, onSnapshot,
  query, orderBy, writeBatch, getDocs, Timestamp, deleteField,
  type DocumentSnapshot,
} from "firebase/firestore";
import { db } from "./firebase";
import type { Task, Note, Category } from "./types";
import { DEFAULT_CATEGORIES } from "./types";

function tasksCol(uid: string) { return collection(db, "users", uid, "tasks"); }
function notesCol(uid: string) { return collection(db, "users", uid, "notes"); }
function categoriesCol(uid: string) { return collection(db, "users", uid, "categories"); }

// Convert Firestore Timestamp | plain {seconds,nanoseconds} | ISO string → ISO string
function tsToString(val: unknown): string | null {
  if (!val) return null;
  if (val instanceof Timestamp) return val.toDate().toISOString();
  if (typeof val === "object" && "seconds" in (val as object)) {
    return new Date((val as { seconds: number }).seconds * 1000).toISOString();
  }
  if (typeof val === "string") return val;
  return null;
}

// iOS stores completion as `completedAt: Timestamp` (deleted when incomplete).
// The web uses `isCompleted: boolean`. We normalize on read, translate on write.
function normalizeTask(data: Record<string, unknown>): Task {
  return {
    id: (data.id as string) ?? "",
    title: (data.title as string) ?? "",
    categories: Array.isArray(data.categories) ? (data.categories as string[]) : [],
    priority: (data.priority as Task["priority"]) ?? null,
    isCompleted: !!data.completedAt,
    dueDate: tsToString(data.dueDate),
    taskNotes: (data.taskNotes as string) ?? null,
    orderIndex: typeof data.orderIndex === "number" ? data.orderIndex : 0,
    parentTaskId: (data.parentTaskId as string) ?? null,
    createdAt: tsToString(data.createdAt) ?? new Date().toISOString(),
    updatedAt: tsToString(data.updatedAt) ?? new Date().toISOString(),
    createdFrom: data.createdFrom as string | undefined,
  };
}

// iOS stores category data WITHOUT an "id" field (doc ID is the ID).
// iOS uses "order" (int) not "orderIndex". Normalize both.
function normalizeCategory(snap: DocumentSnapshot): Category {
  const data = (snap.data() ?? {}) as Record<string, unknown>;
  const orderIndex =
    typeof data.orderIndex === "number" ? data.orderIndex :
    typeof data.order === "number" ? data.order : 0;
  return {
    id: snap.id,                          // always use Firestore document ID
    name: (data.name as string) ?? "",
    icon: (data.icon as string) ?? "",
    color: (data.color as string) ?? "#818CF8",
    orderIndex,
  };
}

function normalizeNote(data: Record<string, unknown>): Note {
  return {
    id: (data.id as string) ?? "",
    text: ((data.text ?? data.body) as string) ?? "",
    title: data.title as string | undefined,
    isPinned: !!data.isPinned,
    createdAt: tsToString(data.createdAt) ?? new Date().toISOString(),
    updatedAt: tsToString(data.updatedAt) ?? new Date().toISOString(),
    createdFrom: data.createdFrom as string | undefined,
  };
}

export async function saveTask(
  uid: string,
  task: Omit<Task, "id" | "createdAt" | "updatedAt">,
): Promise<string> {
  const id = crypto.randomUUID();
  const now = Timestamp.now();
  const { isCompleted, dueDate, ...rest } = task;
  await setDoc(doc(tasksCol(uid), id), {
    ...rest,
    id,
    createdAt: now,
    updatedAt: now,
    orderIndex: task.orderIndex ?? Date.now(),
    createdFrom: task.createdFrom ?? "chrome-extension",
    ...(isCompleted ? { completedAt: now } : {}),
    ...(dueDate ? { dueDate: Timestamp.fromDate(new Date(dueDate)) } : {}),
  });
  return id;
}

export async function updateTask(uid: string, id: string, patch: Partial<Task>) {
  const { isCompleted, dueDate, ...rest } = patch;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const update: Record<string, any> = { ...rest, updatedAt: Timestamp.now() };
  delete update.isCompleted; // never write the boolean field iOS doesn't use
  if (isCompleted !== undefined) {
    update.completedAt = isCompleted ? Timestamp.now() : deleteField();
  }
  if (dueDate !== undefined) {
    update.dueDate = dueDate ? Timestamp.fromDate(new Date(dueDate)) : deleteField();
  }
  await updateDoc(doc(tasksCol(uid), id), update);
}

export async function deleteTask(uid: string, id: string) {
  await deleteDoc(doc(tasksCol(uid), id));
}

export async function reorderTasks(uid: string, updates: { id: string; orderIndex: number }[]) {
  const batch = writeBatch(db);
  const now = Timestamp.now();
  for (const { id, orderIndex } of updates) {
    batch.update(doc(tasksCol(uid), id), { orderIndex, updatedAt: now });
  }
  await batch.commit();
}

export async function saveNote(
  uid: string,
  note: Omit<Note, "id" | "createdAt" | "updatedAt">,
): Promise<string> {
  const id = crypto.randomUUID();
  const now = Timestamp.now();
  await setDoc(doc(notesCol(uid), id), {
    ...note,
    id,
    createdAt: now,
    updatedAt: now,
    isPinned: note.isPinned ?? false,
    createdFrom: note.createdFrom ?? "chrome-extension",
  });
  return id;
}

export async function updateNote(uid: string, id: string, patch: Partial<Note>) {
  await updateDoc(doc(notesCol(uid), id), { ...patch, updatedAt: Timestamp.now() });
}

export async function deleteNote(uid: string, id: string) {
  await deleteDoc(doc(notesCol(uid), id));
}

export function subscribeTasks(uid: string, onChange: (tasks: Task[]) => void) {
  const q = query(tasksCol(uid), orderBy("orderIndex", "desc"));
  return onSnapshot(q, (snap) => {
    onChange(snap.docs.map((d) => normalizeTask(d.data() as Record<string, unknown>)));
  });
}

export function subscribeNotes(uid: string, onChange: (notes: Note[]) => void) {
  const q = query(notesCol(uid), orderBy("updatedAt", "desc"));
  return onSnapshot(q, (snap) => {
    onChange(snap.docs.map((d) => normalizeNote(d.data() as Record<string, unknown>)));
  });
}

export function subscribeCategories(uid: string, onChange: (cats: Category[]) => void) {
  // No orderBy — iOS uses "order", web uses "orderIndex"; sort client-side after normalizing.
  return onSnapshot(query(categoriesCol(uid)), (snap) => {
    const cats = snap.docs.map(normalizeCategory);
    cats.sort((a, b) => a.orderIndex - b.orderIndex);
    onChange(cats);
  });
}

export async function saveCategory(uid: string, cat: Omit<Category, "id">): Promise<string> {
  const id = crypto.randomUUID();
  // Write both "order" (iOS) and "orderIndex" (web) so both platforms read it correctly.
  await setDoc(doc(categoriesCol(uid), id), {
    name: cat.name,
    icon: cat.icon,
    color: cat.color,
    order: cat.orderIndex,
    orderIndex: cat.orderIndex,
  });
  return id;
}

export async function updateCategory(uid: string, id: string, patch: Partial<Category>) {
  await updateDoc(doc(categoriesCol(uid), id), patch);
}

export async function deleteCategory(uid: string, id: string) {
  await deleteDoc(doc(categoriesCol(uid), id));
}

export async function reorderCategories(uid: string, updates: { id: string; orderIndex: number }[]) {
  const batch = writeBatch(db);
  for (const { id, orderIndex } of updates) {
    batch.update(doc(categoriesCol(uid), id), { orderIndex });
  }
  await batch.commit();
}

export async function seedDefaultCategories(uid: string) {
  const existing = await getDocs(categoriesCol(uid));
  if (!existing.empty) return;
  const batch = writeBatch(db);
  for (const cat of DEFAULT_CATEGORIES) {
    const id = crypto.randomUUID();
    batch.set(doc(categoriesCol(uid), id), { ...cat, id });
  }
  await batch.commit();
}

export async function applyPresetCategories(
  uid: string,
  preset: Omit<Category, "id">[],
): Promise<void> {
  const existing = await getDocs(categoriesCol(uid));
  const batch = writeBatch(db);
  existing.docs.forEach((d) => batch.delete(d.ref));
  preset.forEach((cat, i) => {
    const id = crypto.randomUUID();
    batch.set(doc(categoriesCol(uid), id), { ...cat, id, orderIndex: i });
  });
  await batch.commit();
}

export async function resetToDefaultCategories(uid: string): Promise<void> {
  await applyPresetCategories(uid, DEFAULT_CATEGORIES);
}

export async function loadCategories(uid: string): Promise<Category[]> {
  const snap = await getDocs(query(categoriesCol(uid)));
  const cats = snap.docs.map(normalizeCategory);
  return cats.sort((a, b) => a.orderIndex - b.orderIndex);
}
