import { getValidSession, signIn, signOut } from "./lib/auth.js";
import {
  loadCategories,
  loadOpenTasks,
  addTask,
  completeTask,
} from "./lib/tasks.js";
import { PRIORITIES, COLORS } from "./lib/config.js";

// ---- DOM refs ---------------------------------------------------------------
const $ = (id) => document.getElementById(id);
const els = {
  loading: $("loading"),
  signedOut: $("signed-out"),
  app: $("app"),
  signinBtn: $("signin-btn"),
  signinError: $("signin-error"),
  accountBtn: $("account-btn"),
  accountInitial: $("account-initial"),
  title: $("task-title"),
  attachUrl: $("attach-url"),
  pagePreview: $("page-preview"),
  pageTitle: $("page-title"),
  pageUrl: $("page-url"),
  priorityRow: $("priority-row"),
  categoryRow: $("category-row"),
  addBtn: $("add-btn"),
  addStatus: $("add-status"),
  refreshBtn: $("refresh-btn"),
  taskList: $("task-list"),
  tasksEmpty: $("tasks-empty"),
};

// ---- State ------------------------------------------------------------------
let session = null;
let currentTab = null;
let selectedPriority = "medium";
const selectedCategories = new Set();

// ---- View helpers -----------------------------------------------------------
function show(view) {
  els.loading.hidden = view !== "loading";
  els.signedOut.hidden = view !== "signedOut";
  els.app.hidden = view !== "app";
  els.accountBtn.hidden = view !== "app";
}

const PRIORITY_LABELS = { high: "High", medium: "Medium", low: "Low", deferred: "Deferred" };
const priorityColor = (p) => COLORS[p] || COLORS.medium;

function renderPriorityChips() {
  els.priorityRow.replaceChildren(
    ...PRIORITIES.map((p) => {
      const chip = document.createElement("button");
      chip.className = "chip";
      chip.dataset.selected = String(p === selectedPriority);
      if (p === selectedPriority) {
        chip.style.background = priorityColor(p);
        chip.style.color = "#fff";
      }
      const dot = document.createElement("span");
      dot.className = "dot";
      dot.style.background = priorityColor(p);
      chip.append(dot, document.createTextNode(PRIORITY_LABELS[p]));
      chip.addEventListener("click", () => {
        selectedPriority = p;
        renderPriorityChips();
      });
      return chip;
    })
  );
}

function renderCategoryChips(categories) {
  if (!categories.length) {
    els.categoryRow.replaceChildren(
      Object.assign(document.createElement("span"), {
        className: "muted",
        textContent: "No categories yet",
      })
    );
    return;
  }
  els.categoryRow.replaceChildren(
    ...categories.map((cat) => {
      const chip = document.createElement("button");
      chip.className = "chip";
      const selected = selectedCategories.has(cat.id);
      chip.dataset.selected = String(selected);
      const color = cat.color || COLORS.accent;
      if (selected) {
        chip.style.background = hexWithAlpha(color, 0.22);
        chip.style.borderColor = "transparent";
      }
      const dot = document.createElement("span");
      dot.className = "dot";
      dot.style.background = color;
      chip.append(dot, document.createTextNode(`${cat.icon || ""} ${cat.name}`.trim()));
      chip.addEventListener("click", () => {
        if (selectedCategories.has(cat.id)) selectedCategories.delete(cat.id);
        else selectedCategories.add(cat.id);
        renderCategoryChips(categories);
      });
      return chip;
    })
  );
}

function hexWithAlpha(hex, alpha) {
  const m = /^#?([0-9a-f]{6})$/i.exec(hex);
  if (!m) return hex;
  const n = parseInt(m[1], 16);
  return `rgba(${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}, ${alpha})`;
}

function renderTasks(tasks) {
  els.tasksEmpty.hidden = tasks.length > 0;
  els.taskList.replaceChildren(
    ...tasks.map((task) => {
      const li = document.createElement("li");
      li.className = "task-item";
      li.dataset.id = task.id;

      const check = document.createElement("button");
      check.className = "task-check";
      check.title = "Mark complete";
      check.addEventListener("click", () => onComplete(task.id, li));

      const body = document.createElement("div");
      body.className = "task-body";
      const title = document.createElement("div");
      title.className = "task-title";
      title.textContent = task.title;
      body.appendChild(title);

      const sub = document.createElement("div");
      sub.className = "task-sub";
      const prio = document.createElement("span");
      prio.className = "prio-tag";
      prio.style.color = priorityColor(task.priority);
      prio.textContent = PRIORITY_LABELS[task.priority] || "Medium";
      sub.appendChild(prio);
      if (task.dueDate) {
        const due = document.createElement("span");
        due.textContent = "· " + task.dueDate.toLocaleDateString();
        sub.appendChild(due);
      }
      body.appendChild(sub);

      li.append(check, body);
      return li;
    })
  );
}

// ---- Actions ----------------------------------------------------------------
async function onComplete(taskId, li) {
  li.classList.add("completing");
  try {
    await completeTask(session, taskId);
    li.remove();
    if (!els.taskList.children.length) els.tasksEmpty.hidden = false;
  } catch (err) {
    console.error(err);
    li.classList.remove("completing");
    flashStatus("Couldn't complete task", true);
  }
}

async function onAdd() {
  const title = els.title.value.trim();
  if (!title) {
    els.title.focus();
    return;
  }
  els.addBtn.disabled = true;
  try {
    const taskNotes =
      els.attachUrl.checked && currentTab?.url ? currentTab.url : undefined;
    await addTask(session, {
      title,
      taskNotes,
      categories: [...selectedCategories],
      priority: selectedPriority,
    });
    els.title.value = "";
    selectedCategories.clear();
    selectedPriority = "medium";
    renderPriorityChips();
    await refreshCategories();
    flashStatus("Added ✓");
    await refreshTasks();
  } catch (err) {
    console.error(err);
    flashStatus("Couldn't add task — try signing in again", true);
  } finally {
    els.addBtn.disabled = false;
  }
}

function flashStatus(text, isError = false) {
  els.addStatus.textContent = text;
  els.addStatus.style.color = isError ? COLORS.high : COLORS.accent;
  els.addStatus.hidden = false;
  setTimeout(() => (els.addStatus.hidden = true), 2500);
}

async function refreshCategories() {
  try {
    const cats = await loadCategories(session);
    renderCategoryChips(cats);
  } catch (err) {
    console.error("loadCategories failed", err);
  }
}

async function refreshTasks() {
  try {
    const tasks = await loadOpenTasks(session);
    renderTasks(tasks);
  } catch (err) {
    console.error("loadOpenTasks failed", err);
  }
}

// ---- Init -------------------------------------------------------------------
async function initApp() {
  show("app");
  els.accountInitial.textContent = (session.displayName || session.email || "?")
    .charAt(0)
    .toUpperCase();

  // Current tab → capture preview.
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    currentTab = tab || null;
    if (currentTab?.url && /^https?:/.test(currentTab.url)) {
      els.pageTitle.textContent = currentTab.title || currentTab.url;
      els.pageUrl.textContent = currentTab.url;
      els.pagePreview.hidden = false;
      if (!els.title.value) els.title.value = currentTab.title || "";
    } else {
      els.attachUrl.checked = false;
      els.attachUrl.parentElement.style.display = "none";
    }
  } catch (err) {
    console.error("tabs.query failed", err);
  }

  renderPriorityChips();
  await Promise.all([refreshCategories(), refreshTasks()]);
  els.title.focus();
}

async function boot() {
  show("loading");
  try {
    session = await getValidSession();
  } catch (err) {
    console.error(err);
    session = null;
  }
  if (session) {
    await initApp();
  } else {
    show("signedOut");
  }
}

// ---- Wiring -----------------------------------------------------------------
els.signinBtn.addEventListener("click", async () => {
  els.signinError.hidden = true;
  els.signinBtn.disabled = true;
  try {
    session = await signIn();
    await initApp();
  } catch (err) {
    console.error(err);
    els.signinError.textContent =
      "Sign-in failed. Check the extension's OAuth client setup (see README).";
    els.signinError.hidden = false;
  } finally {
    els.signinBtn.disabled = false;
  }
});

els.accountBtn.addEventListener("click", async () => {
  if (confirm("Sign out of Notelayer?")) {
    await signOut();
    session = null;
    show("signedOut");
  }
});

els.addBtn.addEventListener("click", onAdd);
els.title.addEventListener("keydown", (e) => {
  if (e.key === "Enter") onAdd();
});
els.refreshBtn.addEventListener("click", refreshTasks);

boot();
