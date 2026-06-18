import React, { useState, useEffect, useRef } from "react";
import type { Task, Category, Priority } from "@notelayer/shared";
import { updateTask, deleteTask } from "@notelayer/shared";
import { CategoryPill } from "@notelayer/ui";
import "./TaskEditSheet.css";

interface TaskEditSheetProps {
  task: Task;
  categories: Category[];
  uid: string;
  onClose: () => void;
}

const PRIORITIES: { value: Priority; label: string }[] = [
  { value: "high",     label: "High"     },
  { value: "medium",   label: "Medium"   },
  { value: "low",      label: "Low"      },
  { value: "deferred", label: "Deferred" },
  { value: null,       label: "None"     },
];

export function TaskEditSheet({ task, categories, uid, onClose }: TaskEditSheetProps) {
  const [title, setTitle]           = useState(task.title);
  const [priority, setPriority]     = useState<Priority>(task.priority);
  const [selectedCats, setSelectedCats] = useState<string[]>(task.categories);
  const [dueDate, setDueDate]       = useState(task.dueDate ? task.dueDate.split("T")[0] : "");
  const [notes, setNotes]           = useState(task.taskNotes ?? "");
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [savedFlash, setSavedFlash] = useState(false);

  const saveTimer  = useRef<number | undefined>();
  const flashTimer = useRef<number | undefined>();
  const isFirst    = useRef(true);

  // Auto-save with 600ms debounce on any field change
  useEffect(() => {
    if (isFirst.current) { isFirst.current = false; return; }
    if (saveTimer.current) clearTimeout(saveTimer.current);
    saveTimer.current = window.setTimeout(async () => {
      if (!title.trim()) return;
      await updateTask(uid, task.id, {
        title:      title.trim(),
        priority,
        categories: selectedCats,
        dueDate:    dueDate || null,
        taskNotes:  notes.trim() || null,
      });
      setSavedFlash(true);
      if (flashTimer.current) clearTimeout(flashTimer.current);
      flashTimer.current = window.setTimeout(() => setSavedFlash(false), 1800);
    }, 600);
    return () => { if (saveTimer.current) clearTimeout(saveTimer.current); };
  }, [title, priority, selectedCats, dueDate, notes]);

  const handleDelete = async () => {
    if (!confirmDelete) { setConfirmDelete(true); return; }
    if (saveTimer.current) clearTimeout(saveTimer.current);
    await deleteTask(uid, task.id);
    onClose();
  };

  const toggleCat = (id: string) =>
    setSelectedCats((prev) => prev.includes(id) ? prev.filter((c) => c !== id) : [...prev, id]);

  const handleAddToCalendar = () => {
    const base = dueDate ? new Date(dueDate + "T09:00:00") : new Date();
    if (!dueDate) base.setHours(9, 0, 0, 0);
    const end = new Date(base.getTime() + 15 * 60000);
    const fmt = (d: Date) => d.toISOString().replace(/[-:]/g, "").split(".")[0] + "Z";

    const catNames = categories
      .filter((c) => selectedCats.includes(c.id))
      .map((c) => `${c.icon} ${c.name}`)
      .join(", ");

    const details = [
      notes.trim(),
      catNames ? `Categories: ${catNames}` : "",
      priority ? `Priority: ${priority}` : "",
      "Source: Notelayer",
    ].filter(Boolean).join("\n\n");

    const url =
      `https://calendar.google.com/calendar/r/eventedit` +
      `?text=${encodeURIComponent(title)}` +
      `&dates=${fmt(base)}/${fmt(end)}` +
      `&details=${encodeURIComponent(details)}`;

    chrome.tabs.create({ url });
  };

  return (
    <div className="sheet-overlay" onClick={onClose}>
      <div className="sheet" onClick={(e) => e.stopPropagation()}>
        <div className="sheet__handle" />

        <div className="sheet__header">
          <button className="sheet__cancel" onClick={onClose}>Done</button>
          <h2 className="sheet__title">Edit Task</h2>
          <div className="sheet__header-actions">
            {savedFlash && <span className="sheet__saved">✓ Saved</span>}
            <button className="sheet__cal-btn" onClick={handleAddToCalendar} title="Add to Calendar">
              <svg viewBox="0 0 20 20" fill="none" width="16" height="16">
                <rect x="2" y="4" width="16" height="14" rx="2.5" stroke="currentColor" strokeWidth="1.6"/>
                <path d="M2 8h16" stroke="currentColor" strokeWidth="1.4"/>
                <path d="M6 2v3M14 2v3" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/>
                <path d="M10 12v2m-1-1h2" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/>
              </svg>
            </button>
          </div>
        </div>

        <div className="sheet__body">
          {/* Title */}
          <div className="sheet__field">
            <label className="sheet__label">Title</label>
            <input
              className="sheet__input"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Task title"
              autoFocus
            />
          </div>

          {/* Priority */}
          <div className="sheet__field">
            <label className="sheet__label">Priority</label>
            <div className="sheet__priority-row">
              {PRIORITIES.map(({ value, label }) => (
                <button
                  key={String(value)}
                  className={`sheet__priority-btn ${priority === value ? "sheet__priority-btn--active" : ""} ${value ? `sheet__priority-btn--${value}` : ""}`}
                  onClick={() => setPriority(value)}
                >
                  {label}
                </button>
              ))}
            </div>
          </div>

          {/* Categories */}
          {categories.length > 0 && (
            <div className="sheet__field">
              <label className="sheet__label">Categories</label>
              <div className="sheet__cats">
                {categories.map((cat) => {
                  const on = selectedCats.includes(cat.id);
                  return (
                    <button
                      key={cat.id}
                      className={`sheet__cat-btn ${on ? "sheet__cat-btn--selected" : ""}`}
                      onClick={() => toggleCat(cat.id)}
                    >
                      <CategoryPill category={cat} />
                      {on && <span className="sheet__cat-check">✓</span>}
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {/* Due date */}
          <div className="sheet__field">
            <label className="sheet__label">Due Date</label>
            <input
              className="sheet__input sheet__input--date"
              type="date"
              value={dueDate}
              onChange={(e) => setDueDate(e.target.value)}
            />
          </div>

          {/* Notes */}
          <div className="sheet__field">
            <label className="sheet__label">Notes</label>
            <textarea
              className="sheet__textarea"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Add notes…"
              rows={3}
            />
          </div>

          {/* Delete */}
          <button
            className={`sheet__delete ${confirmDelete ? "sheet__delete--confirm" : ""}`}
            onClick={handleDelete}
          >
            {confirmDelete ? "Tap again to confirm delete" : "Delete Task"}
          </button>
        </div>
      </div>
    </div>
  );
}
