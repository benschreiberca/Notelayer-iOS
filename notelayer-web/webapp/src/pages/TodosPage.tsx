import { useEffect, useState, useRef } from "react";
import type { User } from "firebase/auth";
import { saveTask, subscribeTasks, updateTask, loadCategories } from "@notelayer/shared";
import type { Task, Category, Priority } from "@notelayer/shared";
import styles from "./TodosPage.module.css";

type ViewMode = "list" | "category";

export default function TodosPage({ user }: { user: User }) {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [viewMode, setViewMode] = useState<ViewMode>("list");
  const [showDone, setShowDone] = useState(false);
  const [search, setSearch] = useState("");
  const [title, setTitle] = useState("");
  const [priority, setPriority] = useState<Priority>("medium");
  const [selectedCat, setSelectedCat] = useState("");
  const [inputExpanded, setInputExpanded] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    loadCategories(user.uid).then(setCategories);
    return subscribeTasks(user.uid, setTasks);
  }, [user.uid]);

  const catById = Object.fromEntries(categories.map((c) => [c.id, c]));

  const filtered = tasks.filter((t) => !t.parentTaskId &&
    (search === "" || t.title.toLowerCase().includes(search.toLowerCase()))
  );
  const doing = filtered.filter((t) => !t.isCompleted);
  const done = filtered.filter((t) => t.isCompleted);

  async function handleAdd() {
    const trimmed = title.trim();
    if (!trimmed) return;
    await saveTask(user.uid, {
      title: trimmed,
      priority,
      categories: selectedCat ? [selectedCat] : [],
      isCompleted: false,
      dueDate: null,
      taskNotes: null,
      parentTaskId: null,
      orderIndex: Date.now(),
    });
    setTitle("");
    setInputExpanded(false);
    inputRef.current?.focus();
  }

  async function toggleComplete(task: Task) {
    await updateTask(user.uid, task.id, { isCompleted: !task.isCompleted });
  }

  return (
    <div className={styles.page}>
      {/* Search */}
      <div className={styles.searchRow}>
        <input
          className={styles.search}
          placeholder="Search tasks…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
      </div>

      {/* Add task */}
      <div className={styles.addCard}>
        <div className={styles.addInputRow}>
          <span className={styles.addIcon}>＋</span>
          <input
            ref={inputRef}
            className={styles.addInput}
            placeholder="New task…"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            onFocus={() => setInputExpanded(true)}
            onKeyDown={(e) => e.key === "Enter" && handleAdd()}
          />
          {title && (
            <button className={styles.addSubmit} onClick={handleAdd}>→</button>
          )}
        </div>

        {inputExpanded && (
          <div className={styles.addOptions}>
            <div className={styles.priorityRow}>
              {(["high", "medium", "low"] as Priority[]).map((p) => (
                <button
                  key={p}
                  className={`${styles.priorityBtn} ${priority === p ? styles[`p_${p}`] : ""}`}
                  onClick={() => setPriority(p)}
                >
                  {p === "high" ? "High" : p === "medium" ? "Med" : "Low"}
                </button>
              ))}
            </div>
            {categories.length > 0 && (
              <div className={styles.catScroll}>
                <button
                  className={`${styles.catChip} ${selectedCat === "" ? styles.catActive : ""}`}
                  onClick={() => setSelectedCat("")}
                >None</button>
                {categories.map((c) => (
                  <button
                    key={c.id}
                    className={`${styles.catChip} ${selectedCat === c.id ? styles.catActive : ""}`}
                    style={selectedCat === c.id ? { background: hexAlpha(c.color, 0.18), borderColor: hexAlpha(c.color, 0.5), color: c.color } : {}}
                    onClick={() => setSelectedCat(c.id)}
                  >
                    {c.icon} {c.name}
                  </button>
                ))}
              </div>
            )}
            <button className={styles.cancelAdd} onClick={() => { setInputExpanded(false); setTitle(""); }}>Cancel</button>
          </div>
        )}
      </div>

      {/* View mode */}
      <div className={styles.segmented}>
        <button className={`${styles.seg} ${viewMode === "list" ? styles.segActive : ""}`} onClick={() => setViewMode("list")}>List</button>
        <button className={`${styles.seg} ${viewMode === "category" ? styles.segActive : ""}`} onClick={() => setViewMode("category")}>Category</button>
      </div>

      {/* Task list */}
      {viewMode === "list" ? (
        <ListMode doing={doing} done={done} showDone={showDone} onToggleDone={() => setShowDone(!showDone)} catById={catById} onToggle={toggleComplete} />
      ) : (
        <CategoryMode doing={doing} categories={categories} catById={catById} onToggle={toggleComplete} />
      )}
    </div>
  );
}

function ListMode({ doing, done, showDone, onToggleDone, catById, onToggle }: {
  doing: Task[]; done: Task[]; showDone: boolean;
  onToggleDone: () => void;
  catById: Record<string, Category>;
  onToggle: (t: Task) => void;
}) {
  return (
    <>
      {doing.length === 0 && !showDone && (
        <p className={styles.empty}>No tasks. Add one above.</p>
      )}
      <div className={styles.taskList}>
        {doing.map((t) => <TaskRow key={t.id} task={t} catById={catById} onToggle={onToggle} />)}
      </div>

      {done.length > 0 && (
        <button className={styles.doneToggle} onClick={onToggleDone}>
          {showDone ? "▾" : "▸"} Done ({done.length})
        </button>
      )}
      {showDone && (
        <div className={`${styles.taskList} ${styles.doneList}`}>
          {done.map((t) => <TaskRow key={t.id} task={t} catById={catById} onToggle={onToggle} />)}
        </div>
      )}
    </>
  );
}

function CategoryMode({ doing, categories, catById, onToggle }: {
  doing: Task[]; categories: Category[];
  catById: Record<string, Category>;
  onToggle: (t: Task) => void;
}) {
  const uncategorized = doing.filter((t) => t.categories.length === 0);

  return (
    <>
      {categories.map((cat) => {
        const catTasks = doing.filter((t) => t.categories.includes(cat.id));
        if (catTasks.length === 0) return null;
        return (
          <div key={cat.id} className={styles.catGroup}>
            <div className={styles.catGroupHeader} style={{ borderLeftColor: cat.color }}>
              <span>{cat.icon} {cat.name}</span>
              <span className={styles.catCount} style={{ background: hexAlpha(cat.color, 0.18), color: cat.color }}>{catTasks.length}</span>
            </div>
            <div className={styles.taskList}>
              {catTasks.map((t) => <TaskRow key={t.id} task={t} catById={catById} onToggle={onToggle} />)}
            </div>
          </div>
        );
      })}
      {uncategorized.length > 0 && (
        <div className={styles.catGroup}>
          <div className={styles.catGroupHeader} style={{ borderLeftColor: "var(--text3)" }}>
            <span>No Category</span>
            <span className={styles.catCount}>{uncategorized.length}</span>
          </div>
          <div className={styles.taskList}>
            {uncategorized.map((t) => <TaskRow key={t.id} task={t} catById={catById} onToggle={onToggle} />)}
          </div>
        </div>
      )}
    </>
  );
}

const PRIORITY_LABELS: Record<string, string> = { high: "High", medium: "Med", low: "Low" };

function TaskRow({ task, catById, onToggle }: {
  task: Task; catById: Record<string, Category>; onToggle: (t: Task) => void;
}) {
  return (
    <div className={`${styles.taskRow} ${task.isCompleted ? styles.taskDone : ""}`}>
      <button className={`${styles.checkbox} ${task.isCompleted ? styles.checkboxDone : ""}`} onClick={() => onToggle(task)}>
        {task.isCompleted && <span className={styles.checkmark}>✓</span>}
      </button>
      <div className={styles.taskBody}>
        <span className={styles.taskTitle}>{task.title}</span>
        <div className={styles.taskMeta}>
          {task.priority && (
            <span className={`${styles.priorityTag} ${styles[`pt_${task.priority}`]}`}>
              {PRIORITY_LABELS[task.priority]}
            </span>
          )}
          {task.dueDate && (
            <span className={styles.dueDateTag}>{formatDate(task.dueDate)}</span>
          )}
          {task.categories.map((cid) => {
            const cat = catById[cid];
            if (!cat) return null;
            return (
              <span
                key={cid}
                className={styles.catPill}
                style={{
                  background: hexAlpha(cat.color, 0.18),
                  borderColor: hexAlpha(cat.color, 0.3),
                  color: lighten(cat.color),
                }}
              >
                {cat.icon} {cat.name}
              </span>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function hexAlpha(hex: string, alpha: number): string {
  if (!hex || !hex.startsWith("#")) return `rgba(79,142,247,${alpha})`;
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${alpha})`;
}

function lighten(hex: string): string {
  if (!hex || !hex.startsWith("#")) return "#fff";
  const r = Math.min(255, parseInt(hex.slice(1, 3), 16) + 60);
  const g = Math.min(255, parseInt(hex.slice(3, 5), 16) + 60);
  const b = Math.min(255, parseInt(hex.slice(5, 7), 16) + 60);
  return `rgb(${r},${g},${b})`;
}

function formatDate(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleDateString("en-US", { month: "short", day: "numeric" });
}
