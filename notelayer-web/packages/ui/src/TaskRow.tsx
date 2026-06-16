import React from "react";
import type { Task, Category } from "@notelayer/shared";
import { PriorityBadge } from "./PriorityBadge";
import { CategoryPill } from "./CategoryPill";
import "./TaskRow.css";

function formatDueDate(iso: string | null): string | null {
  if (!iso) return null;
  const d = new Date(iso);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const tomorrow = new Date(today);
  tomorrow.setDate(today.getDate() + 1);
  if (d.getTime() === today.getTime()) return "Today";
  if (d.getTime() === tomorrow.getTime()) return "Tomorrow";
  if (d < today) return d.toLocaleDateString("en-US", { month: "short", day: "numeric" });
  return d.toLocaleDateString("en-US", { month: "short", day: "numeric" });
}

function isDueDateOverdue(iso: string | null): boolean {
  if (!iso) return false;
  const d = new Date(iso);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return d < today;
}

interface TaskRowProps {
  task: Task;
  categories: Category[];
  onToggle: (task: Task) => void;
  onEdit: (task: Task) => void;
  dragging?: boolean;
  dragHandleProps?: React.HTMLAttributes<HTMLDivElement>;
}

export function TaskRow({ task, categories, onToggle, onEdit, dragging, dragHandleProps }: TaskRowProps) {
  const taskCategories = categories.filter((c) => task.categories.includes(c.id));
  const dueDateLabel = formatDueDate(task.dueDate);
  const overdue = isDueDateOverdue(task.dueDate) && !task.isCompleted;

  return (
    <div
      className={`task-row ${task.isCompleted ? "task-row--done" : ""} ${dragging ? "task-row--dragging" : ""}`}
      onClick={() => onEdit(task)}
    >
      {dragHandleProps && (
        <div
          className="task-row__drag"
          {...dragHandleProps}
          onClick={(e) => e.stopPropagation()}
        >
          <DragIcon />
        </div>
      )}
      <button
        className={`task-row__check ${task.isCompleted ? "task-row__check--done" : ""}`}
        onClick={(e) => { e.stopPropagation(); onToggle(task); }}
        aria-label={task.isCompleted ? "Restore task" : "Complete task"}
      >
        {task.isCompleted ? <CheckFilledIcon /> : <CheckEmptyIcon />}
      </button>
      <div className="task-row__body">
        <span className={`task-row__title ${task.isCompleted ? "task-row__title--done" : ""}`}>
          {task.title}
        </span>
        {(dueDateLabel || task.priority || taskCategories.length > 0) && (
          <div className="task-row__meta">
            {dueDateLabel && (
              <span className={`task-row__due ${overdue ? "task-row__due--overdue" : ""}`}>
                {dueDateLabel}
              </span>
            )}
            {task.priority && <PriorityBadge priority={task.priority} />}
            {taskCategories.map((cat) => (
              <CategoryPill key={cat.id} category={cat} compact />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function CheckEmptyIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
      <circle cx="11" cy="11" r="10" stroke="rgba(255,255,255,0.3)" strokeWidth="1.5" />
    </svg>
  );
}

function CheckFilledIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
      <circle cx="11" cy="11" r="10" fill="#34C759" />
      <path d="M7 11l3 3 5-5" stroke="#fff" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function DragIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
      <circle cx="5" cy="5" r="1.2" fill="rgba(255,255,255,0.3)" />
      <circle cx="5" cy="11" r="1.2" fill="rgba(255,255,255,0.3)" />
      <circle cx="11" cy="5" r="1.2" fill="rgba(255,255,255,0.3)" />
      <circle cx="11" cy="11" r="1.2" fill="rgba(255,255,255,0.3)" />
    </svg>
  );
}
