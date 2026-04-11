import { signIn, signOut, getAuthState, refreshToken } from "../firebase/auth.js";
import { fetchActiveTasks, createTask, completeTask } from "../firebase/firestore.js";

const PRIORITY_COLORS = {
  high: "#E53E3E",
  medium: "#DD6B20",
  low: "#38A169",
  deferred: "#718096",
};

// State
let authState = null;
let tasks = [];

// DOM refs
const loadingScreen = document.getElementById("loading-screen");
const authScreen = document.getElementById("auth-screen");
const mainScreen = document.getElementById("main-screen");
const emailInput = document.getElementById("email-input");
const passwordInput = document.getElementById("password-input");
const signinBtn = document.getElementById("signin-btn");
const authError = document.getElementById("auth-error");
const taskInput = document.getElementById("task-input");
const prioritySelect = document.getElementById("priority-select");
const addBtn = document.getElementById("add-btn");
const taskList = document.getElementById("task-list");
const taskCount = document.getElementById("task-count");
const signoutBtn = document.getElementById("signout-btn");
const refreshBtn = document.getElementById("refresh-btn");

// Init
async function init() {
  showScreen("loading");
  authState = await getAuthState();
  if (authState) {
    await loadTasks();
    showScreen("main");
  } else {
    showScreen("auth");
    emailInput.focus();
  }
}

// Screen management
function showScreen(name) {
  loadingScreen.classList.add("hidden");
  authScreen.classList.add("hidden");
  mainScreen.classList.add("hidden");
  if (name === "loading") loadingScreen.classList.remove("hidden");
  if (name === "auth") authScreen.classList.remove("hidden");
  if (name === "main") mainScreen.classList.remove("hidden");
}

// Auth
signinBtn.addEventListener("click", async () => {
  const email = emailInput.value.trim();
  const password = passwordInput.value;
  if (!email || !password) return;

  signinBtn.disabled = true;
  signinBtn.textContent = "Signing in…";
  authError.classList.add("hidden");

  try {
    authState = await signIn(email, password);
    showScreen("loading");
    await loadTasks();
    showScreen("main");
  } catch (err) {
    authError.textContent = formatAuthError(err.message);
    authError.classList.remove("hidden");
    signinBtn.disabled = false;
    signinBtn.textContent = "Sign In";
  }
});

// Allow pressing Enter in auth fields
passwordInput.addEventListener("keydown", (e) => {
  if (e.key === "Enter") signinBtn.click();
});
emailInput.addEventListener("keydown", (e) => {
  if (e.key === "Enter") passwordInput.focus();
});

signoutBtn.addEventListener("click", async () => {
  await signOut();
  authState = null;
  tasks = [];
  emailInput.value = "";
  passwordInput.value = "";
  showScreen("auth");
  emailInput.focus();
});

// Load tasks
async function loadTasks() {
  try {
    tasks = await fetchActiveTasks(authState.token, authState.userId);
  } catch (err) {
    // Token might be expired — attempt refresh
    const newToken = await refreshToken();
    if (newToken) {
      authState = { ...authState, token: newToken };
      tasks = await fetchActiveTasks(authState.token, authState.userId);
    } else {
      // Refresh failed — force re-auth
      await signOut();
      authState = null;
      showScreen("auth");
    }
  }
  renderTasks();
}

refreshBtn.addEventListener("click", async () => {
  refreshBtn.textContent = "…";
  await loadTasks();
  refreshBtn.textContent = "↺";
});

// Render task list
function renderTasks() {
  taskCount.textContent = `${tasks.length} active`;
  taskList.innerHTML = "";

  if (tasks.length === 0) {
    taskList.innerHTML = '<div class="empty-state">No active tasks — nice work! 🎉</div>';
    return;
  }

  for (const task of tasks) {
    const item = document.createElement("div");
    item.className = "task-item";
    item.dataset.id = task.id;

    const dot = document.createElement("div");
    dot.className = "priority-dot";
    dot.style.background = PRIORITY_COLORS[task.priority] || "#718096";

    const title = document.createElement("div");
    title.className = "task-title";
    title.textContent = task.title;

    const btn = document.createElement("button");
    btn.className = "complete-btn";
    btn.textContent = "✓";
    btn.title = "Mark complete";
    btn.addEventListener("click", () => handleComplete(task.id));

    item.appendChild(dot);
    item.appendChild(title);
    item.appendChild(btn);
    taskList.appendChild(item);
  }
}

// Add task
addBtn.addEventListener("click", handleAddTask);
taskInput.addEventListener("keydown", (e) => {
  if (e.key === "Enter") handleAddTask();
});

// Pre-fill from selected page text if available
async function prefillFromSelection() {
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    if (!tab?.id) return;
    const results = await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: () => window.getSelection()?.toString().trim() || "",
    });
    const selected = results?.[0]?.result;
    if (selected && selected.length <= 200) {
      taskInput.value = selected;
      taskInput.select();
    }
  } catch {
    // No permission or scripting not available — silently ignore
  }
}

async function handleAddTask() {
  const title = taskInput.value.trim();
  if (!title) return;

  addBtn.disabled = true;
  try {
    const task = await createTask(authState.token, authState.userId, {
      title,
      priority: prioritySelect.value,
    });
    tasks.unshift(task);
    renderTasks();
    taskInput.value = "";
    taskInput.focus();
  } catch {
    // Silent — user can retry
  } finally {
    addBtn.disabled = false;
  }
}

async function handleComplete(taskId) {
  // Optimistic
  tasks = tasks.filter((t) => t.id !== taskId);
  renderTasks();
  try {
    await completeTask(authState.token, taskId);
  } catch {
    // Could reload on failure but not critical for MVP
  }
}

function formatAuthError(msg) {
  const map = {
    "EMAIL_NOT_FOUND": "No account with that email.",
    "INVALID_PASSWORD": "Wrong password.",
    "INVALID_EMAIL": "Invalid email address.",
    "USER_DISABLED": "This account has been disabled.",
    "TOO_MANY_ATTEMPTS_TRY_LATER": "Too many attempts. Try again later.",
  };
  return map[msg] || msg.replace(/_/g, " ").toLowerCase();
}

// Context menu: "Save to Notelayer" on selected text
chrome.contextMenus?.onClicked?.addListener((info) => {
  if (info.menuItemId === "save-to-notelayer" && info.selectionText) {
    chrome.storage.local.set({ pendingCapture: info.selectionText.trim() });
  }
});

init().then(() => {
  prefillFromSelection();
  taskInput.focus();
});
