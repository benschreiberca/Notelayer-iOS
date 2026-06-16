import {
  collection, doc, setDoc, updateDoc, deleteDoc, onSnapshot,
  query, orderBy, writeBatch, getDocs,
} from "firebase/firestore";
import { db } from "./firebase";
import type { Task, Note, Category } from "./types";
import { DEFAULT_CATEGORIES } from "./types";

function tasksCol(uid: string) { return collection(db, "users", uid, "tasks"); }
function notesCol(uid: string) { return collection(db, "users", uid, "notes"); }
function categoriesCol(uid: string) { return collection(db, "users", uid, "categories"); }

export async function saveTask(
  uid: string,
  task: Omit<Task, "id" | "createdAt" | "updatedAt">,
): Promise<string> {
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  await setDoc(doc(tasksCol(uid), id), {
    ...task,
    id,
    createdAt: now,
    updatedAt: now,
    orderIndex: task.orderIndex ?? Date.now(),
    createdFrom: task.createdFrom ?? "chrome-extension",
  });
  return id;
}

export async function updateTask(uid: string, id: string, patch: Partial<Task>) {
  await updateDoc(doc(tasksCol(uid), id), { ...patch, updatedAt: new Date().toISOString() });
}

export async function deleteTask(uid: string, id: string) {
  await deleteDoc(doc(tasksCol(uid), id));
}

export async function reorderTasks(uid: string, updates: { id: string; orderIndex: number }[]) {
  const batch = writeBatch(db);
  const now = new Date().toISOString();
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
  const now = new Date().toISOString();
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
  await updateDoc(doc(notesCol(uid), id), { ...patch, updatedAt: new Date().toISOString() });
}

export async function deleteNote(uid: string, id: string) {
  await deleteDoc(doc(notesCol(uid), id));
}

export function subscribeTasks(uid: string, onChange: (tasks: Task[]) => void) {
  const q = query(tasksCol(uid), orderBy("orderIndex", "desc"));
  return onSnapshot(q, (snap) => {
    onChange(snap.docs.map((d) => d.data() as Task));
  });
}

export function subscribeNotes(uid: string, onChange: (notes: Note[]) => void) {
  const q = query(notesCol(uid), orderBy("updatedAt", "desc"));
  return onSnapshot(q, (snap) => {
    onChange(snap.docs.map((d) => d.data() as Note));
  });
}

export function subscribeCategories(uid: string, onChange: (cats: Category[]) => void) {
  const q = query(categoriesCol(uid), orderBy("orderIndex", "asc"));
  return onSnapshot(q, (snap) => {
    onChange(snap.docs.map((d) => d.data() as Category));
  });
}

export async function saveCategory(uid: string, cat: Omit<Category, "id">): Promise<string> {
  const id = crypto.randomUUID();
  await setDoc(doc(categoriesCol(uid), id), { ...cat, id });
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
  const snap = await getDocs(query(categoriesCol(uid), orderBy("orderIndex", "asc")));
  return snap.docs.map((d) => d.data() as Category);
}
