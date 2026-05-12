/**
 * Notelayer Chrome Extension — Popup UI Controller
 *
 * Currently: pure UI logic with mock auth state.
 * Next phase: wire up Firebase Web SDK (Auth + Firestore).
 */

// ── View IDs ──────────────────────────────────────────────────────────────────
const VIEW_LOADING  = 'view-loading';
const VIEW_SIGNEDOUT = 'view-signedout';
const VIEW_EMAIL    = 'view-email';
const VIEW_MAIN     = 'view-main';

// ── Priority state ────────────────────────────────────────────────────────────
let selectedPriority = 'high';
let selectedCategory = '';
let pageUrl = '';
let pageTitle = '';
let noteSourceActive = true;
let taskSourceActive = true;

// ── Init ──────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  loadCurrentTab();
  bindEvents();
  // TODO: replace with real Firebase auth check
  const mockSignedIn = false;
  showView(mockSignedIn ? VIEW_MAIN : VIEW_SIGNEDOUT);
});

// ── Tab info ──────────────────────────────────────────────────────────────────
function loadCurrentTab() {
  if (typeof chrome === 'undefined' || !chrome.tabs) return;
  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    const tab = tabs[0];
    if (!tab) return;
    pageUrl   = tab.url   || '';
    pageTitle = tab.title || '';
    updateSourceChips();
  });
}

function updateSourceChips() {
  const displayText = pageTitle || pageUrl || 'Current page';
  const truncated = displayText.length > 45
    ? displayText.slice(0, 42) + '…'
    : displayText;

  document.getElementById('source-url-note').textContent = truncated;
  document.getElementById('source-url-task').textContent = truncated;

  document.getElementById('source-chip-note').classList.toggle('hidden', !noteSourceActive);
  document.getElementById('source-chip-task').classList.toggle('hidden', !taskSourceActive);
}

// ── View management ───────────────────────────────────────────────────────────
function showView(viewId) {
  document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
  const target = document.getElementById(viewId);
  if (target) target.classList.add('active');
}

// ── Tab switcher ──────────────────────────────────────────────────────────────
function bindTabSwitcher() {
  document.querySelectorAll('.tab').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
      btn.classList.add('active');
      document.getElementById(`tab-content-${btn.dataset.tab}`)?.classList.add('active');
    });
  });
}

// ── Priority picker ───────────────────────────────────────────────────────────
function bindPriorityPicker() {
  document.querySelectorAll('.priority-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.priority-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      selectedPriority = btn.dataset.priority;
    });
  });
}

// ── Category chips ────────────────────────────────────────────────────────────
function renderCategories(categories) {
  const scroll = document.getElementById('category-scroll');
  scroll.innerHTML = '';

  const none = createCategoryChip({ id: '', name: 'None', icon: '' });
  none.classList.add('active');
  scroll.appendChild(none);

  categories.forEach(cat => {
    scroll.appendChild(createCategoryChip(cat));
  });

  scroll.querySelectorAll('.category-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      scroll.querySelectorAll('.category-chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      selectedCategory = chip.dataset.category;
    });
  });
}

function createCategoryChip(cat) {
  const btn = document.createElement('button');
  btn.className = 'category-chip';
  btn.dataset.category = cat.id;
  btn.textContent = cat.icon ? `${cat.icon} ${cat.name}` : cat.name;
  if (cat.color) {
    btn.style.setProperty('--cat-color', cat.color);
  }
  return btn;
}

// ── Note: char counter ────────────────────────────────────────────────────────
function bindNoteCharCounter() {
  const ta = document.getElementById('note-text');
  const counter = document.getElementById('note-char-count');
  ta.addEventListener('input', () => {
    counter.textContent = ta.value.length;
  });
}

// ── Source chip dismiss ───────────────────────────────────────────────────────
function bindSourceClears() {
  document.getElementById('source-clear-note').addEventListener('click', () => {
    noteSourceActive = false;
    document.getElementById('source-chip-note').classList.add('hidden');
  });
  document.getElementById('source-clear-task').addEventListener('click', () => {
    taskSourceActive = false;
    document.getElementById('source-chip-task').classList.add('hidden');
  });
}

// ── Auth buttons (UI only — Firebase wired up in Phase 2) ─────────────────────
function bindAuthButtons() {
  document.getElementById('btn-google-signin').addEventListener('click', () => {
    // TODO: call firebase.auth().signInWithPopup(googleProvider)
    showView(VIEW_LOADING);
    setTimeout(() => {
      // Mock success — replace with real auth callback
      onSignedIn({ displayName: 'Demo User', email: 'demo@example.com' });
    }, 800);
  });

  document.getElementById('btn-email-signin').addEventListener('click', () => {
    showView(VIEW_EMAIL);
  });

  document.getElementById('btn-back-from-email').addEventListener('click', () => {
    showView(VIEW_SIGNEDOUT);
  });

  document.getElementById('btn-send-link').addEventListener('click', () => {
    const email = document.getElementById('input-email').value.trim();
    const errorEl = document.getElementById('email-error');
    const sentEl  = document.getElementById('email-sent-msg');

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      errorEl.textContent = 'Please enter a valid email address.';
      errorEl.classList.remove('hidden');
      return;
    }
    errorEl.classList.add('hidden');
    // TODO: firebase.auth().sendSignInLinkToEmail(email, actionCodeSettings)
    sentEl.classList.remove('hidden');
    document.getElementById('btn-send-link').disabled = true;
  });

  document.getElementById('btn-signout').addEventListener('click', () => {
    // TODO: firebase.auth().signOut()
    onSignedOut();
  });
}

// ── Save handlers (UI only — Firestore wired up in Phase 2) ──────────────────
function bindSaveButtons() {
  document.getElementById('btn-save-note').addEventListener('click', () => {
    const text = document.getElementById('note-text').value.trim();
    const errorEl   = document.getElementById('note-error');
    const successEl = document.getElementById('note-success');

    if (!text) {
      errorEl.textContent = 'Note cannot be empty.';
      errorEl.classList.remove('hidden');
      return;
    }
    errorEl.classList.add('hidden');

    const noteData = {
      id: crypto.randomUUID(),
      text: noteSourceActive && pageUrl ? `${text}\n\nSource: ${pageUrl}` : text,
      createdAt: new Date().toISOString(),
    };

    console.log('[Notelayer] Save note (mock):', noteData);
    // TODO: firestoreService.saveNote(noteData)

    successEl.classList.remove('hidden');
    document.getElementById('note-text').value = '';
    document.getElementById('note-char-count').textContent = '0';
    setTimeout(() => successEl.classList.add('hidden'), 2500);
  });

  document.getElementById('btn-save-task').addEventListener('click', () => {
    const title = document.getElementById('task-title').value.trim();
    const errorEl   = document.getElementById('task-error');
    const successEl = document.getElementById('task-success');

    if (!title) {
      errorEl.textContent = 'Task title cannot be empty.';
      errorEl.classList.remove('hidden');
      return;
    }
    errorEl.classList.add('hidden');

    const dueDate = document.getElementById('task-due-date').value;
    const notes   = document.getElementById('task-notes').value.trim();

    const taskData = {
      id: crypto.randomUUID(),
      title: taskSourceActive && pageUrl ? `${title} — ${pageTitle || pageUrl}` : title,
      priority: selectedPriority,
      categories: selectedCategory ? [selectedCategory] : [],
      dueDate: dueDate ? new Date(dueDate).toISOString() : null,
      taskNotes: notes || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    console.log('[Notelayer] Save task (mock):', taskData);
    // TODO: firestoreService.saveTask(taskData)

    successEl.classList.remove('hidden');
    document.getElementById('task-title').value = '';
    document.getElementById('task-due-date').value = '';
    document.getElementById('task-notes').value = '';
    setTimeout(() => successEl.classList.add('hidden'), 2500);
  });
}

// ── Auth state callbacks ───────────────────────────────────────────────────────
function onSignedIn(user) {
  // TODO: load categories from Firestore then call renderCategories()
  renderCategories(MOCK_CATEGORIES);
  showView(VIEW_MAIN);
}

function onSignedOut() {
  showView(VIEW_SIGNEDOUT);
}

// ── Wire everything up ────────────────────────────────────────────────────────
function bindEvents() {
  bindTabSwitcher();
  bindPriorityPicker();
  bindNoteCharCounter();
  bindSourceClears();
  bindAuthButtons();
  bindSaveButtons();
}

// ── Mock data (replaced by Firestore in Phase 2) ──────────────────────────────
const MOCK_CATEGORIES = [
  { id: 'house',    name: 'House',       icon: '🏠', color: '#4F8EF7' },
  { id: 'tech',     name: 'Tech',        icon: '💻', color: '#2D9CDB' },
  { id: 'finance',  name: 'Finance',     icon: '💰', color: '#2F855A' },
  { id: 'shopping', name: 'Shopping',    icon: '🛍️', color: '#F72585' },
  { id: 'travel',   name: 'Travel',      icon: '✈️', color: '#00B4D8' },
  { id: 'vehicle',  name: 'Vehicle',     icon: '🚗', color: '#9B5DE5' },
  { id: 'garage',   name: 'Garage',      icon: '🔧', color: '#FF8A3D' },
  { id: 'printing', name: '3D Printing', icon: '🖨️', color: '#20C997' },
];
