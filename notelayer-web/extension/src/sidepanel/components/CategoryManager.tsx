import React, { useState, useEffect, useRef } from "react";
import type { Category } from "@notelayer/shared";
import {
  saveCategory, updateCategory, deleteCategory,
  reorderCategories, applyPresetCategories, resetToDefaultCategories,
} from "@notelayer/shared";
import "./CategoryManager.css";

interface CategoryManagerProps {
  categories: Category[];
  uid: string;
  onClose: () => void;
}

const PRESET_COLORS = [
  "#4F8EF7", "#FF3B30", "#FF9500", "#34C759",
  "#BF5AF2", "#64D2FF", "#FF6B6B", "#30D158",
  "#FFD60A", "#FF6961", "#5AC8FA", "#007AFF",
];

const SNAPSHOT_KEY = "notelayer_cat_snapshot";

function saveSnapshot(cats: Category[]) {
  chrome.storage.local.set({ [SNAPSHOT_KEY]: JSON.stringify(cats) });
}

export function CategoryManager({ categories, uid, onClose }: CategoryManagerProps) {
  const [editing, setEditing] = useState<Category | null>(null);
  const [editName, setEditName] = useState("");
  const [editIcon, setEditIcon] = useState("");
  const [editColor, setEditColor] = useState("#4F8EF7");
  const [newName, setNewName] = useState("");
  const [newIcon, setNewIcon] = useState("📁");
  const [newColor, setNewColor] = useState("#4F8EF7");
  const [confirmDelete, setConfirmDelete] = useState<string | null>(null);
  const [snapshot, setSnapshot] = useState<Category[] | null>(null);
  const [resetPrimed, setResetPrimed] = useState(false);
  const [working, setWorking] = useState(false);
  const resetTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Load snapshot on mount
  useEffect(() => {
    chrome.storage.local.get([SNAPSHOT_KEY], (res) => {
      if (res[SNAPSHOT_KEY]) {
        try { setSnapshot(JSON.parse(res[SNAPSHOT_KEY])); } catch {}
      }
    });
  }, []);

  const startEdit = (cat: Category) => {
    setEditing(cat);
    setEditName(cat.name);
    setEditIcon(cat.icon);
    setEditColor(cat.color);
  };

  const saveEdit = async () => {
    if (!editing || !editName.trim()) return;
    saveSnapshot(categories); // snapshot before mutation
    await updateCategory(uid, editing.id, {
      name: editName.trim(), icon: editIcon, color: editColor,
    });
    setSnapshot(categories);
    setEditing(null);
  };

  const handleCreate = async () => {
    if (!newName.trim()) return;
    saveSnapshot(categories);
    await saveCategory(uid, {
      name: newName.trim(), icon: newIcon, color: newColor,
      orderIndex: categories.length,
    });
    setSnapshot(categories);
    setNewName(""); setNewIcon("📁"); setNewColor("#4F8EF7");
  };

  const handleDelete = async (id: string) => {
    if (confirmDelete !== id) { setConfirmDelete(id); return; }
    saveSnapshot(categories);
    await deleteCategory(uid, id);
    setSnapshot(categories);
    setConfirmDelete(null);
  };

  const moveUp = async (idx: number) => {
    if (idx === 0) return;
    saveSnapshot(categories);
    const updated = categories.map((c, i) => {
      if (i === idx - 1) return { id: c.id, orderIndex: idx };
      if (i === idx)     return { id: c.id, orderIndex: idx - 1 };
      return { id: c.id, orderIndex: i };
    });
    await reorderCategories(uid, updated);
    setSnapshot(categories);
  };

  const handleRestore = async () => {
    if (!snapshot) return;
    setWorking(true);
    try {
      await applyPresetCategories(uid, snapshot.map(({ name, icon, color, orderIndex }) => ({
        name, icon, color, orderIndex,
      })));
    } finally {
      setWorking(false);
    }
  };

  const handleReset = async () => {
    if (!resetPrimed) {
      setResetPrimed(true);
      resetTimer.current = setTimeout(() => setResetPrimed(false), 3000);
      return;
    }
    if (resetTimer.current) clearTimeout(resetTimer.current);
    setResetPrimed(false);
    setWorking(true);
    try {
      saveSnapshot(categories); // snapshot before wiping
      setSnapshot(categories);
      await resetToDefaultCategories(uid);
    } finally {
      setWorking(false);
    }
  };

  return (
    <div className="catmgr-overlay" onClick={onClose}>
      <div className="catmgr" onClick={(e) => e.stopPropagation()}>
        <div className="catmgr__handle" />

        <div className="catmgr__header">
          <button className="catmgr__close" onClick={onClose}>✕</button>
          <h2 className="catmgr__title">Manage Categories</h2>
        </div>

        <div className="catmgr__body">

          {/* ── Category list ── */}
          {categories.map((cat, idx) => (
            <div key={cat.id} className="catmgr__row">
              {editing?.id === cat.id ? (
                <div className="catmgr__edit">
                  <div className="catmgr__edit-row">
                    <input
                      className="catmgr__input catmgr__input--icon"
                      value={editIcon}
                      onChange={(e) => setEditIcon(e.target.value)}
                      maxLength={2}
                      placeholder="🏷️"
                    />
                    <input
                      className="catmgr__input catmgr__input--name"
                      value={editName}
                      onChange={(e) => setEditName(e.target.value)}
                      placeholder="Category name"
                      autoFocus
                    />
                  </div>
                  <div className="catmgr__colors">
                    {PRESET_COLORS.map((c) => (
                      <button
                        key={c}
                        className={`catmgr__color-dot ${editColor === c ? "catmgr__color-dot--active" : ""}`}
                        style={{ backgroundColor: c }}
                        onClick={() => setEditColor(c)}
                      />
                    ))}
                  </div>
                  <div className="catmgr__edit-actions">
                    <button className="catmgr__btn catmgr__btn--cancel" onClick={() => setEditing(null)}>Cancel</button>
                    <button className="catmgr__btn catmgr__btn--save" onClick={saveEdit}>Save</button>
                  </div>
                </div>
              ) : (
                <>
                  <div className="catmgr__row-left">
                    <button className="catmgr__reorder" onClick={() => moveUp(idx)} disabled={idx === 0} title="Move up">↑</button>
                    <span className="catmgr__swatch" style={{ backgroundColor: cat.color }} />
                    <span className="catmgr__icon">{cat.icon}</span>
                    <span className="catmgr__name">{cat.name}</span>
                  </div>
                  <div className="catmgr__row-right">
                    <button className="catmgr__action" onClick={() => startEdit(cat)}>Edit</button>
                    <button
                      className={`catmgr__action catmgr__action--delete ${confirmDelete === cat.id ? "catmgr__action--confirm" : ""}`}
                      onClick={() => handleDelete(cat.id)}
                    >
                      {confirmDelete === cat.id ? "Sure?" : "Delete"}
                    </button>
                  </div>
                </>
              )}
            </div>
          ))}

          {/* ── Add new ── */}
          <div className="catmgr__new">
            <h3 className="catmgr__new-title">Add Category</h3>
            <div className="catmgr__new-row">
              <input
                className="catmgr__input catmgr__input--icon"
                value={newIcon}
                onChange={(e) => setNewIcon(e.target.value)}
                maxLength={2}
                placeholder="🏷️"
              />
              <input
                className="catmgr__input catmgr__input--name"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                placeholder="Category name"
              />
            </div>
            <div className="catmgr__colors">
              {PRESET_COLORS.map((c) => (
                <button
                  key={c}
                  className={`catmgr__color-dot ${newColor === c ? "catmgr__color-dot--active" : ""}`}
                  style={{ backgroundColor: c }}
                  onClick={() => setNewColor(c)}
                />
              ))}
            </div>
            <button className="catmgr__add-btn" onClick={handleCreate} disabled={!newName.trim()}>
              Add Category
            </button>
          </div>

          {/* ── Restore / Reset ── */}
          <div className="catmgr__danger-zone">

            {snapshot && (
              <button
                className="catmgr__restore-btn"
                onClick={handleRestore}
                disabled={working}
              >
                <span className="catmgr__restore-icon">↩</span>
                <span className="catmgr__restore-text">
                  <strong>Restore My Categories</strong>
                  <span>Bring back your last saved setup</span>
                </span>
              </button>
            )}

            <button
              className={`catmgr__reset-btn ${resetPrimed ? "catmgr__reset-btn--primed" : ""}`}
              onClick={handleReset}
              disabled={working}
            >
              <span className="catmgr__reset-icon">⚠</span>
              <span className="catmgr__reset-text">
                <strong>{resetPrimed ? "Tap again to confirm" : "Reset to Defaults"}</strong>
                <span>Replace all categories with the 8 built-in defaults</span>
              </span>
            </button>

            <p className="catmgr__snap-note">
              {snapshot
                ? "Your categories are auto-snapshotted on each edit"
                : "Edit any category to create a restorable snapshot"}
            </p>
          </div>

        </div>
      </div>
    </div>
  );
}
