import React, { useState, useRef, useCallback } from "react";
import type { Task, Priority, Category } from "@notelayer/shared";
import { saveTask, updateTask, reorderTasks } from "@notelayer/shared";
import { TaskRow, GroupHeader, PriorityBadge, CategoryPill } from "@notelayer/ui";
import { useTasks, useCategories } from "@notelayer/hooks";
import { TaskEditSheet } from "../components/TaskEditSheet";
import { CategoryManager } from "../components/CategoryManager";
import "./TodosView.css";

type ViewMode = "list" | "priority" | "category" | "date";

interface TodosViewProps {
  uid: string;
  onSignOut: () => void;
  onOpenNotes: () => void;
}

const PRIORITY_ORDER: Record<string, number> = { high: 0, medium: 1, low: 2, deferred: 3 };

function getPriorityLabel(p: Priority): string {
  if (p === "high") return "High Priority";
  if (p === "medium") return "Medium Priority";
  if (p === "low") return "Low Priority";
  if (p === "deferred") return "Deferred";
  return "No Priority";
}

function getDateGroup(dueDate: string | null): string {
  if (!dueDate) return "No Due Date";
  const d = new Date(dueDate);
  d.setHours(0, 0, 0, 0);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const diff = Math.round((d.getTime() - today.getTime()) / 86400000);
  if (diff < 0) return "Overdue";
  if (diff === 0) return "Today";
  if (diff === 1) return "Tomorrow";
  if (diff <= 7) return "This Week";
  if (diff <= 30) return "Later";
  return "Later";
}

const DATE_GROUP_ORDER = ["Overdue", "Today", "Tomorrow", "This Week", "Later", "No Due Date"];

export function TodosView({ uid, onSignOut, onOpenNotes }: TodosViewProps) {
  const { tasks } = useTasks(uid);
  const { categories } = useCategories(uid);
  const [mode, setMode] = useState<ViewMode>("list");
  const [showDone, setShowDone] = useState(false);
  const [search, setSearch] = useState("");
  const [editTask, setEditTask] = useState<Task | null>(null);
  const [showCatMgr, setShowCatMgr] = useState(false);
  const [inputTitle, setInputTitle] = useState("");
  const [inputExpanded, setInputExpanded] = useState(false);
  const [inputPriority, setInputPriority] = useState<Priority>(null);
  const [inputCats, setInputCats] = useState<string[]>([]);
  const [inputDue, setInputDue] = useState("");
  const [bulkMode, setBulkMode] = useState(false);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [showMenu, setShowMenu] = useState(false);
  const [fabOpen, setFabOpen] = useState(false);

  // Drag state
  const dragId = useRef<string | null>(null);
  const dragOverId = useRef<string | null>(null);

  const active = tasks.filter((t) => !t.isCompleted);
  const done = tasks.filter((t) => t.isCompleted);
  const displayed = showDone ? done : active;
  const filtered = search
    ? displayed.filter((t) => t.title.toLowerCase().includes(search.toLowerCase()))
    : displayed;

  const handleAddTask = async () => {
    if (!inputTitle.trim()) return;
    await saveTask(uid, {
      title: inputTitle.trim(),
      priority: inputPriority,
      categories: inputCats,
      isCompleted: false,
      dueDate: inputDue || null,
      taskNotes: null,
      parentTaskId: null,
      orderIndex: Date.now(),
    });
    setInputTitle("");
    setInputPriority(null);
    setInputCats([]);
    setInputDue("");
    setInputExpanded(false);
  };

  const handleToggle = async (task: Task) => {
    await updateTask(uid, task.id, { isCompleted: !task.isCompleted });
  };

  const handleDragStart = (id: string) => { dragId.current = id; };
  const handleDragOver = (id: string) => { dragOverId.current = id; };

  const handleDrop = async () => {
    if (!dragId.current || !dragOverId.current || dragId.current === dragOverId.current) {
      dragId.current = null;
      dragOverId.current = null;
      return;
    }
    const listOrder = [...filtered].sort((a, b) => b.orderIndex - a.orderIndex);
    const fromIdx = listOrder.findIndex((t) => t.id === dragId.current);
    const toIdx = listOrder.findIndex((t) => t.id === dragOverId.current);
    const reordered = [...listOrder];
    const [moved] = reordered.splice(fromIdx, 1);
    reordered.splice(toIdx, 0, moved);
    const updates = reordered.map((t, i) => ({ id: t.id, orderIndex: reordered.length - i }));
    await reorderTasks(uid, updates);
    dragId.current = null;
    dragOverId.current = null;
  };

  const toggleSelect = (id: string) => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
  };

  const listSorted = [...filtered].sort((a, b) => b.orderIndex - a.orderIndex);

  const renderListMode = () => (
    <div className="todos__list">
      {!showDone && (
        <TaskInput
          title={inputTitle}
          expanded={inputExpanded}
          priority={inputPriority}
          cats={inputCats}
          due={inputDue}
          categories={categories}
          onTitleChange={setInputTitle}
          onExpand={setInputExpanded}
          onPriorityChange={setInputPriority}
          onCatsChange={setInputCats}
          onDueChange={setInputDue}
          onSubmit={handleAddTask}
        />
      )}
      {listSorted.length === 0 && (
        <EmptyState text={showDone ? "No completed tasks" : "No tasks — add one above"} />
      )}
      {listSorted.map((task) => (
        <div
          key={task.id}
          draggable={!showDone && !bulkMode}
          onDragStart={() => handleDragStart(task.id)}
          onDragOver={(e) => { e.preventDefault(); handleDragOver(task.id); }}
          onDrop={handleDrop}
          style={{ cursor: bulkMode ? "default" : undefined }}
        >
          {bulkMode ? (
            <div className="todos__bulk-row" onClick={() => toggleSelect(task.id)}>
              <div className={`todos__bulk-check ${selected.has(task.id) ? "todos__bulk-check--on" : ""}`} />
              <TaskRow task={task} categories={categories} onToggle={() => {}} onEdit={() => {}} />
            </div>
          ) : (
            <TaskRow
              task={task}
              categories={categories}
              onToggle={handleToggle}
              onEdit={setEditTask}
              dragHandleProps={{
                draggable: false,
                onMouseDown: (e) => e.stopPropagation(),
              }}
            />
          )}
        </div>
      ))}
    </div>
  );

  const renderPriorityMode = () => {
    const groups = ["high", "medium", "low", "deferred", null] as Priority[];
    return (
      <div className="todos__list">
        {groups.map((p) => {
          const group = filtered.filter((t) => t.priority === p);
          if (group.length === 0) return null;
          return (
            <div key={String(p)} className="todos__group">
              <GroupHeader
                label={getPriorityLabel(p)}
                color={p === "high" ? "#FF3B30" : p === "medium" ? "#FF9500" : p === "low" ? "#34C759" : undefined}
                count={group.length}
              />
              {group.map((task) => (
                <TaskRow key={task.id} task={task} categories={categories} onToggle={handleToggle} onEdit={setEditTask} />
              ))}
            </div>
          );
        })}
      </div>
    );
  };

  const renderCategoryMode = () => {
    const uncategorized = filtered.filter((t) => t.categories.length === 0);
    return (
      <div className="todos__list">
        {categories.map((cat) => {
          const group = filtered.filter((t) => t.categories.includes(cat.id));
          if (group.length === 0) return null;
          return (
            <div key={cat.id} className="todos__group">
              <GroupHeader label={cat.name} color={cat.color} count={group.length} icon={cat.icon} />
              {group.map((task) => (
                <TaskRow key={task.id} task={task} categories={categories} onToggle={handleToggle} onEdit={setEditTask} />
              ))}
            </div>
          );
        })}
        {uncategorized.length > 0 && (
          <div className="todos__group">
            <GroupHeader label="Uncategorized" count={uncategorized.length} />
            {uncategorized.map((task) => (
              <TaskRow key={task.id} task={task} categories={categories} onToggle={handleToggle} onEdit={setEditTask} />
            ))}
          </div>
        )}
      </div>
    );
  };

  const renderDateMode = () => {
    return (
      <div className="todos__list">
        {DATE_GROUP_ORDER.map((group) => {
          const groupTasks = filtered.filter((t) => getDateGroup(t.dueDate) === group);
          if (groupTasks.length === 0) return null;
          return (
            <div key={group} className="todos__group">
              <GroupHeader
                label={group}
                color={group === "Overdue" ? "#FF3B30" : group === "Today" ? "#4F8EF7" : undefined}
                count={groupTasks.length}
              />
              {groupTasks.map((task) => (
                <TaskRow key={task.id} task={task} categories={categories} onToggle={handleToggle} onEdit={setEditTask} />
              ))}
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="todos">
      {/* Header */}
      <div className="todos__header">
        <div className="todos__header-top">
          {/* App mark + title */}
          <div className="todos__title-row">
            <div className="todos__app-mark">
              <svg width="14" height="14" viewBox="0 0 20 20" fill="none">
                <path d="M4 10.5l4 4L16 5.5" stroke="#fff" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
            <h1 className="todos__title">To-Dos</h1>
          </div>

          <div className="todos__header-actions">
            {/* Notes shortcut */}
            <button className="todos__notes-btn" onClick={onOpenNotes} title="Notes">
              <svg viewBox="0 0 20 20" fill="none" width="17" height="17">
                <rect x="3" y="2" width="14" height="16" rx="3" stroke="currentColor" strokeWidth="1.6"/>
                <path d="M6.5 7h7M6.5 10.5h7M6.5 14h4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
              </svg>
            </button>

            <div className="todos__menu-wrap">
              <button className="todos__menu-btn" onClick={() => setShowMenu(!showMenu)}>
                <svg viewBox="0 0 20 20" fill="currentColor" width="18" height="18">
                  <circle cx="10" cy="4"  r="1.5"/>
                  <circle cx="10" cy="10" r="1.5"/>
                  <circle cx="10" cy="16" r="1.5"/>
                </svg>
              </button>
              {showMenu && (
                <div className="todos__menu" onClick={() => setShowMenu(false)}>
                  <button onClick={() => setShowCatMgr(true)}>Manage Categories</button>
                  <button onClick={() => { setBulkMode(!bulkMode); setSelected(new Set()); }}>
                    {bulkMode ? "Cancel Select" : "Select Tasks"}
                  </button>
                  <div className="todos__menu-divider" />
                  <button onClick={onSignOut} className="todos__menu-item--danger">Sign Out</button>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Doing / Done — iOS three-part toggle */}
        <div className="todos__doing-done">
          <div className="todos__dd-label" onClick={() => { setShowDone(false); setBulkMode(false); setSelected(new Set()); }}>
            <span className={`todos__dd-label-text ${!showDone ? "todos__dd-label-text--active" : ""}`}>Doing</span>
            <span className="todos__dd-count">{active.length}</span>
          </div>

          <label className={`todos__dd-switch ${showDone ? "todos__dd-switch--done" : ""}`}>
            <input
              type="checkbox"
              checked={showDone}
              onChange={(e) => { setShowDone(e.target.checked); setBulkMode(false); setSelected(new Set()); }}
            />
            <div className="todos__dd-track" />
            <div className="todos__dd-thumb" />
          </label>

          <div className="todos__dd-label" onClick={() => { setShowDone(true); setBulkMode(false); setSelected(new Set()); }}>
            <span className={`todos__dd-label-text ${showDone ? "todos__dd-label-text--active" : ""}`}>Done</span>
            <span className="todos__dd-count">{done.length}</span>
          </div>
        </div>

        {/* Segmented control */}
        <div className="todos__seg">
          {(["list", "priority", "category", "date"] as ViewMode[]).map((m) => (
            <button
              key={m}
              className={`todos__seg-btn ${mode === m ? "todos__seg-btn--active" : ""}`}
              onClick={() => setMode(m)}
            >
              {m.charAt(0).toUpperCase() + m.slice(1)}
            </button>
          ))}
        </div>

        {/* Search */}
        <div className="todos__search">
          <span className="todos__search-icon">🔍</span>
          <input
            className="todos__search-input"
            placeholder="Search tasks…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          {search && (
            <button className="todos__search-clear" onClick={() => setSearch("")}>✕</button>
          )}
        </div>

        {/* Bulk mode bar */}
        {bulkMode && (
          <div className="todos__bulk-bar">
            <span>{selected.size} selected</span>
            <button
              className="todos__bulk-cat-btn"
              disabled={selected.size === 0}
              onClick={() => {/* bulk category edit TBD */}}
            >
              Edit Categories
            </button>
          </div>
        )}
      </div>

      {/* Content */}
      <div className="todos__content">
        {mode === "list" && renderListMode()}
        {mode === "priority" && renderPriorityMode()}
        {mode === "category" && renderCategoryMode()}
        {mode === "date" && renderDateMode()}
      </div>

      {/* FAB — shown on priority/category/date views */}
      {mode !== "list" && !showDone && (
        <button className="todos__fab" onClick={() => setFabOpen(true)} title="Add task">
          <svg viewBox="0 0 20 20" fill="none" width="20" height="20">
            <path d="M10 4v12M4 10h12" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"/>
          </svg>
        </button>
      )}

      {/* FAB sheet — quick-add task from non-list views */}
      {fabOpen && (
        <div className="todos__fab-sheet" onClick={(e) => { if (e.target === e.currentTarget) setFabOpen(false); }}>
          <div className="todos__fab-sheet-inner">
            <TaskInput
              title={inputTitle}
              expanded={inputExpanded}
              priority={inputPriority}
              cats={inputCats}
              due={inputDue}
              categories={categories}
              onTitleChange={setInputTitle}
              onExpand={setInputExpanded}
              onPriorityChange={setInputPriority}
              onCatsChange={setInputCats}
              onDueChange={setInputDue}
              onSubmit={async () => { await handleAddTask(); setFabOpen(false); }}
            />
          </div>
        </div>
      )}

      {/* Modals */}
      {editTask && (
        <TaskEditSheet
          task={editTask}
          categories={categories}
          uid={uid}
          onClose={() => setEditTask(null)}
        />
      )}
      {showCatMgr && (
        <CategoryManager
          categories={categories}
          uid={uid}
          onClose={() => setShowCatMgr(false)}
        />
      )}
    </div>
  );
}

// ---- TaskInput component ----
interface TaskInputProps {
  title: string;
  expanded: boolean;
  priority: Priority;
  cats: string[];
  due: string;
  categories: Category[];
  onTitleChange: (v: string) => void;
  onExpand: (v: boolean) => void;
  onPriorityChange: (v: Priority) => void;
  onCatsChange: (v: string[]) => void;
  onDueChange: (v: string) => void;
  onSubmit: () => void;
}

function TaskInput({
  title, expanded, priority, cats, due, categories,
  onTitleChange, onExpand, onPriorityChange, onCatsChange, onDueChange, onSubmit,
}: TaskInputProps) {
  const P_OPTIONS: { v: Priority; label: string; color: string }[] = [
    { v: "high", label: "High", color: "#FF3B30" },
    { v: "medium", label: "Med", color: "#FF9500" },
    { v: "low", label: "Low", color: "#34C759" },
    { v: "deferred", label: "Defer", color: "rgba(255,255,255,0.3)" },
    { v: null, label: "None", color: "transparent" },
  ];

  const toggleCat = (id: string) => {
    onCatsChange(cats.includes(id) ? cats.filter((c) => c !== id) : [...cats, id]);
  };

  const handleKey = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && title.trim()) onSubmit();
    if (e.key === "Escape") onExpand(false);
  };

  return (
    <div className={`task-input ${expanded ? "task-input--expanded" : ""}`}>
      <div className="task-input__row">
        <span className="task-input__plus">+</span>
        <input
          className="task-input__field"
          placeholder="Add task…"
          value={title}
          onChange={(e) => onTitleChange(e.target.value)}
          onFocus={() => onExpand(true)}
          onKeyDown={handleKey}
        />
        {expanded && title.trim() && (
          <button className="task-input__add" onClick={onSubmit}>Add</button>
        )}
      </div>

      {expanded && (
        <div className="task-input__extras">
          {/* Priority */}
          <div className="task-input__priority">
            {P_OPTIONS.map(({ v, label, color }) => (
              <button
                key={String(v)}
                className={`task-input__p-btn ${priority === v && v !== null ? "task-input__p-btn--active" : ""}`}
                style={priority === v && v !== null ? { borderColor: color, color } : undefined}
                onClick={() => onPriorityChange(v === priority ? null : v)}
              >
                {label}
              </button>
            ))}
          </div>

          {/* Categories */}
          <div className="task-input__cats">
            {categories.map((cat) => (
              <button
                key={cat.id}
                className={`task-input__cat ${cats.includes(cat.id) ? "" : "task-input__cat--off"}`}
                onClick={() => toggleCat(cat.id)}
              >
                <CategoryPill category={cat} compact />
              </button>
            ))}
          </div>

          {/* Due date */}
          <input
            className="task-input__date"
            type="date"
            value={due}
            onChange={(e) => onDueChange(e.target.value)}
            placeholder="Due date"
          />
        </div>
      )}
    </div>
  );
}

function EmptyState({ text }: { text: string }) {
  return (
    <div className="todos__empty">
      <p>{text}</p>
    </div>
  );
}
