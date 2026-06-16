import React, { useState, useEffect } from "react";
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
  { value: "high", label: "High" },
  { value: "medium", label: "Medium" },
  { value: "low", label: "Low" },
  { value: "deferred", label: "Deferred" },
  { value: null, label: "None" },
];

export function TaskEditSheet({ task, categories, uid, onClose }: TaskEditSheetProps) {
  const [title, setTitle] = useState(task.title);
  const [priority, setPriority] = useState<Priority>(task.priority);
  const [selectedCats, setSelectedCats] = useState<string[]>(task.categories);
  const [dueDate, setDueDate] = useState(task.dueDate ?? "");
  const [notes, setNotes] = useState(task.taskNotes ?? "");
  const [saving, setSaving] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);

  const dirty =
    title !== task.title ||
    priority !== task.priority ||
    JSON.stringify(selectedCats) !== JSON.stringify(task.categories) ||
    dueDate !== (task.dueDate ?? "") ||
    notes !== (task.taskNotes ?? "");

  const handleSave = async () => {
    if (!title.trim()) return;
    setSaving(true);
    try {
      await updateTask(uid, task.id, {
        title: title.trim(),
        priority,
        categories: selectedCats,
        dueDate: dueDate || null,
        taskNotes: notes.trim() || null,
      });
      onClose();
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!confirmDelete) { setConfirmDelete(true); return; }
    await deleteTask(uid, task.id);
    onClose();
  };

  const toggleCat = (id: string) => {
    setSelectedCats((prev) =>
      prev.includes(id) ? prev.filter((c) => c !== id) : [...prev, id],
    );
  };

  return (
    <div className="sheet-overlay" onClick={onClose}>
      <div className="sheet" onClick={(e) => e.stopPropagation()}>
        <div className="sheet__handle" />

        <div className="sheet__header">
          <button className="sheet__cancel" onClick={onClose}>Cancel</button>
          <h2 className="sheet__title">Edit Task</h2>
          <button
            className="sheet__save"
            onClick={handleSave}
            disabled={!dirty || !title.trim() || saving}
          >
            {saving ? "…" : "Save"}
          </button>
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
          <div className="sheet__field">
            <label className="sheet__label">Categories</label>
            <div className="sheet__cats">
              {categories.map((cat) => (
                <button
                  key={cat.id}
                  className={`sheet__cat-btn ${selectedCats.includes(cat.id) ? "sheet__cat-btn--selected" : ""}`}
                  onClick={() => toggleCat(cat.id)}
                >
                  <CategoryPill category={cat} />
                  {selectedCats.includes(cat.id) && <span className="sheet__cat-check">✓</span>}
                </button>
              ))}
            </div>
          </div>

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
