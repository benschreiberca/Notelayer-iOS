import React from "react";
import type { Note } from "@notelayer/shared";
import "./NoteCard.css";

function relativeDate(iso: string): string {
  const d = new Date(iso);
  const now = new Date();
  const diffMs = now.getTime() - d.getTime();
  const diffDays = Math.floor(diffMs / 86400000);
  if (diffDays === 0) return "Today";
  if (diffDays === 1) return "Yesterday";
  if (diffDays < 7) return `${diffDays} days ago`;
  return d.toLocaleDateString("en-US", { month: "short", day: "numeric" });
}

interface NoteCardProps {
  note: Note;
  onEdit: (note: Note) => void;
  onDelete: (note: Note) => void;
  onPin: (note: Note) => void;
}

export function NoteCard({ note, onEdit, onDelete, onPin }: NoteCardProps) {
  const preview = note.text.slice(0, 180);

  return (
    <div className="note-card" onClick={() => onEdit(note)}>
      <div className="note-card__body">
        {note.title && <p className="note-card__title">{note.title}</p>}
        <p className="note-card__text">{preview}{note.text.length > 180 ? "…" : ""}</p>
      </div>
      <div className="note-card__footer">
        <span className="note-card__date">{relativeDate(note.updatedAt)}</span>
        <div className="note-card__actions" onClick={(e) => e.stopPropagation()}>
          <button
            className={`note-card__action ${note.isPinned ? "note-card__action--active" : ""}`}
            onClick={() => onPin(note)}
            title={note.isPinned ? "Unpin" : "Pin"}
          >
            📌
          </button>
          <button
            className="note-card__action note-card__action--destructive"
            onClick={() => onDelete(note)}
            title="Delete"
          >
            <TrashIcon />
          </button>
        </div>
      </div>
    </div>
  );
}

function TrashIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
      <path d="M2 3.5h10M5 3.5V2.5a.5.5 0 0 1 .5-.5h3a.5.5 0 0 1 .5.5v1m1 0v8a.5.5 0 0 1-.5.5h-5a.5.5 0 0 1-.5-.5v-8" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" />
    </svg>
  );
}
