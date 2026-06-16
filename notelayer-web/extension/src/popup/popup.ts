import {
  GoogleAuthProvider,
  signInWithCredential,
  onAuthStateChanged,
  signOut,
  type User,
} from "firebase/auth";
import { auth, saveTask, saveNote, loadCategories, type Category } from "@notelayer/shared";

const VIEWS = { LOADING: "view-loading", SIGNEDOUT: "view-signedout", MAIN: "view-main" } as const;

let selectedPriority = "high";
let selectedCategory = "";
let pageUrl = "";
let pageTitle = "";
let noteSourceActive = true;
let taskSourceActive = true;
let currentUser: User | null = null;

// ── Init ──
document.addEventListener("DOMContentLoaded", () => {
  loadCurrentTab();
  bindEvents();

  onAuthStateChanged(auth, async (user) => {
    currentUser = user;
    if (user) {
      await onSignedIn(user);
    } else {
      showView(VIEWS.SIGNEDOUT);
    }
  });
});

function loadCurrentTab() {
  if (typeof chrome === "undefined" || !chrome.tabs) return;
  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    const tab = tabs[0];
    if (!tab) return;
    pageUrl = tab.url || "";
    pageTitle = tab.title || "";
    updateSourceChips();
  });
}

function updateSourceChips() {
  const text = pageTitle || pageUrl || "Current page";
  const truncated = text.length > 45 ? text.slice(0, 42) + "…" : text;
  (document.getElementById("source-url-note") as HTMLElement).textContent = truncated;
  (document.getElementById("source-url-task") as HTMLElement).textContent = truncated;
}

function showView(viewId: string) {
  document.querySelectorAll(".view").forEach((v) => v.classList.remove("active"));
  document.getElementById(viewId)?.classList.add("active");
}

async function onSignedIn(user: User) {
  showView(VIEWS.LOADING);
  try {
    const categories = await loadCategories(user.uid);
    renderCategories(categories);
  } catch {
    renderCategories([]);
  }
  showView(VIEWS.MAIN);
}

function renderCategories(categories: Category[]) {
  const scroll = document.getElementById("category-scroll")!;
  scroll.innerHTML = "";

  const none = makeChip({ id: "", name: "None", icon: "", color: "", orderIndex: 0 }, true);
  scroll.appendChild(none);
  categories.forEach((cat) => scroll.appendChild(makeChip(cat, false)));

  scroll.querySelectorAll(".category-chip").forEach((chip) => {
    chip.addEventListener("click", () => {
      scroll.querySelectorAll(".category-chip").forEach((c) => c.classList.remove("active"));
      chip.classList.add("active");
      selectedCategory = (chip as HTMLElement).dataset.category || "";
    });
  });
}

function makeChip(cat: Category, active: boolean) {
  const btn = document.createElement("button");
  btn.className = "category-chip" + (active ? " active" : "");
  btn.dataset.category = cat.id;
  btn.textContent = cat.icon ? `${cat.icon} ${cat.name}` : cat.name;
  return btn;
}

function bindEvents() {
  bindTabs();
  bindPriority();
  bindNoteCounter();
  bindSourceClears();
  bindAuthButtons();
  bindSaveButtons();
}

function bindTabs() {
  document.querySelectorAll(".tab").forEach((btn) => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".tab").forEach((t) => t.classList.remove("active"));
      document.querySelectorAll(".tab-content").forEach((t) => t.classList.remove("active"));
      btn.classList.add("active");
      const tab = (btn as HTMLElement).dataset.tab;
      document.getElementById(`tab-content-${tab}`)?.classList.add("active");
    });
  });
}

function bindPriority() {
  document.querySelectorAll(".priority-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".priority-btn").forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      selectedPriority = (btn as HTMLElement).dataset.priority || "high";
    });
  });
}

function bindNoteCounter() {
  const ta = document.getElementById("note-text") as HTMLTextAreaElement;
  const counter = document.getElementById("note-char-count")!;
  ta.addEventListener("input", () => { counter.textContent = String(ta.value.length); });
}

function bindSourceClears() {
  document.getElementById("source-clear-note")!.addEventListener("click", () => {
    noteSourceActive = false;
    document.getElementById("source-chip-note")!.classList.add("hidden");
  });
  document.getElementById("source-clear-task")!.addEventListener("click", () => {
    taskSourceActive = false;
    document.getElementById("source-chip-task")!.classList.add("hidden");
  });
}

function bindAuthButtons() {
  document.getElementById("btn-google-signin")!.addEventListener("click", async () => {
    showView(VIEWS.LOADING);
    try {
      const token = await getGoogleToken();
      const credential = GoogleAuthProvider.credential(token);
      await signInWithCredential(auth, credential);
    } catch (e: any) {
      console.error("[Notelayer] Google sign-in failed:", e);
      const el = document.getElementById("auth-error")!;
      el.textContent = "Google sign-in failed. Try opening the web app to sign in.";
      el.classList.remove("hidden");
      showView(VIEWS.SIGNEDOUT);
    }
  });

  document.getElementById("btn-webapp-signin")!.addEventListener("click", () => {
    chrome.tabs.create({ url: "http://localhost:5174" });
    window.close();
  });

  document.getElementById("btn-signout")!.addEventListener("click", async () => {
    await signOut(auth);
  });
}

function bindSaveButtons() {
  document.getElementById("btn-save-task")!.addEventListener("click", async () => {
    if (!currentUser) return;
    const title = (document.getElementById("task-title") as HTMLInputElement).value.trim();
    const errorEl = document.getElementById("task-error")!;
    const successEl = document.getElementById("task-success")!;

    if (!title) {
      errorEl.textContent = "Task title cannot be empty.";
      errorEl.classList.remove("hidden");
      return;
    }
    errorEl.classList.add("hidden");

    const dueDate = (document.getElementById("task-due-date") as HTMLInputElement).value;
    const notes = (document.getElementById("task-notes") as HTMLTextAreaElement).value.trim();

    try {
      await saveTask(currentUser.uid, {
        title: taskSourceActive && pageUrl ? `${title} — ${pageTitle || pageUrl}` : title,
        priority: selectedPriority as "high" | "medium" | "low",
        categories: selectedCategory ? [selectedCategory] : [],
        isCompleted: false,
        dueDate: dueDate ? new Date(dueDate).toISOString() : null,
        taskNotes: notes || null,
        parentTaskId: null,
        orderIndex: Date.now(),
      });
      successEl.classList.remove("hidden");
      (document.getElementById("task-title") as HTMLInputElement).value = "";
      (document.getElementById("task-due-date") as HTMLInputElement).value = "";
      (document.getElementById("task-notes") as HTMLTextAreaElement).value = "";
      setTimeout(() => successEl.classList.add("hidden"), 2500);
    } catch {
      errorEl.textContent = "Failed to save. Please try again.";
      errorEl.classList.remove("hidden");
    }
  });

  document.getElementById("btn-save-note")!.addEventListener("click", async () => {
    if (!currentUser) return;
    const text = (document.getElementById("note-text") as HTMLTextAreaElement).value.trim();
    const errorEl = document.getElementById("note-error")!;
    const successEl = document.getElementById("note-success")!;

    if (!text) {
      errorEl.textContent = "Note cannot be empty.";
      errorEl.classList.remove("hidden");
      return;
    }
    errorEl.classList.add("hidden");

    try {
      await saveNote(currentUser.uid, {
        text: noteSourceActive && pageUrl ? `${text}\n\nSource: ${pageUrl}` : text,
      });
      successEl.classList.remove("hidden");
      (document.getElementById("note-text") as HTMLTextAreaElement).value = "";
      (document.getElementById("note-char-count") as HTMLElement).textContent = "0";
      setTimeout(() => successEl.classList.add("hidden"), 2500);
    } catch {
      errorEl.textContent = "Failed to save. Please try again.";
      errorEl.classList.remove("hidden");
    }
  });
}

function getGoogleToken(): Promise<string> {
  return new Promise((resolve, reject) => {
    chrome.identity.getAuthToken({ interactive: true }, (token) => {
      if (chrome.runtime.lastError || !token) {
        reject(chrome.runtime.lastError);
      } else {
        resolve(token);
      }
    });
  });
}
