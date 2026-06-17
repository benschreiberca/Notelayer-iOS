import React, { useState } from "react";
import type { Note } from "@notelayer/shared";
import { saveNote, updateNote, deleteNote } from "@notelayer/shared";
import { NoteCard } from "@notelayer/ui";
import { useNotes } from "@notelayer/hooks";
import "./NotesView.css";

interface NotesViewProps {
  uid: string;
  onClose?: () => void;
}

export function NotesView({ uid, onClose }: NotesViewProps) {
  const { pinned, unpinned, loading } = useNotes(uid);
  const [text, setText] = useState("");
  const [inputExpanded, setInputExpanded] = useState(false);
  const [editNote, setEditNote] = useState<Note | null>(null);
  const [editText, setEditText] = useState("");
  const [saving, setSaving] = useState(false);

  const handleAdd = async () => {
    if (!text.trim()) return;
    setSaving(true);
    try {
      await saveNote(uid, { text: text.trim(), isPinned: false });
      setText("");
      setInputExpanded(false);
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (note: Note) => {
    setEditNote(note);
    setEditText(note.text);
  };

  const handleSaveEdit = async () => {
    if (!editNote || !editText.trim()) return;
    await updateNote(uid, editNote.id, { text: editText.trim() });
    setEditNote(null);
  };

  const handleDelete = async (note: Note) => {
    await deleteNote(uid, note.id);
  };

  const handlePin = async (note: Note) => {
    await updateNote(uid, note.id, { isPinned: !note.isPinned });
  };

  const total = pinned.length + unpinned.length;

  return (
    <div className="notes">
      <div className="notes__header">
        <div className="notes__header-top">
          {onClose && (
            <button className="notes__back-btn" onClick={onClose}>
              <svg viewBox="0 0 20 20" fill="none" width="16" height="16">
                <path d="M13 4l-6 6 6 6" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>
          )}
          <h1 className="notes__title">Notes</h1>
          <span className="notes__count">{total} {total === 1 ? "note" : "notes"}</span>
        </div>
      </div>

      <div className="notes__content">
        {/* Add note input */}
        <div className={`notes__add ${inputExpanded ? "notes__add--expanded" : ""}`}>
          <textarea
            className="notes__add-input"
            placeholder="Write a note…"
            value={text}
            onChange={(e) => setText(e.target.value)}
            onFocus={() => setInputExpanded(true)}
            rows={inputExpanded ? 4 : 2}
          />
          {inputExpanded && (
            <div className="notes__add-actions">
              <button
                className="notes__add-cancel"
                onClick={() => { setText(""); setInputExpanded(false); }}
              >
                Cancel
              </button>
              <button
                className="notes__add-save"
                onClick={handleAdd}
                disabled={!text.trim() || saving}
              >
                {saving ? "Saving…" : "Save Note"}
              </button>
            </div>
          )}
        </div>

        {/* Pinned section */}
        {pinned.length > 0 && (
          <>
            <div className="notes__section-label">Pinned</div>
            <div className="notes__list">
              {pinned.map((note) => (
                <NoteCard
                  key={note.id}
                  note={note}
                  onEdit={handleEdit}
                  onDelete={handleDelete}
                  onPin={handlePin}
                />
              ))}
            </div>
          </>
        )}

        {/* All notes */}
        {unpinned.length > 0 && (
          <>
            {pinned.length > 0 && <div className="notes__section-label">Notes</div>}
            <div className="notes__list">
              {unpinned.map((note) => (
                <NoteCard
                  key={note.id}
                  note={note}
                  onEdit={handleEdit}
                  onDelete={handleDelete}
                  onPin={handlePin}
                />
              ))}
            </div>
          </>
        )}

        {total === 0 && !loading && (
          <div className="notes__empty">
            <p>No notes yet. Write something above.</p>
          </div>
        )}
      </div>

      {/* Edit note overlay */}
      {editNote && (
        <div className="note-edit-overlay" onClick={() => setEditNote(null)}>
          <div className="note-edit" onClick={(e) => e.stopPropagation()}>
            <div className="note-edit__handle" />
            <div className="note-edit__header">
              <button className="note-edit__cancel" onClick={() => setEditNote(null)}>Cancel</button>
              <h2 className="note-edit__title">Edit Note</h2>
              <button
                className="note-edit__save"
                onClick={handleSaveEdit}
                disabled={!editText.trim()}
              >
                Save
              </button>
            </div>
            <textarea
              className="note-edit__area"
              value={editText}
              onChange={(e) => setEditText(e.target.value)}
              autoFocus
            />
          </div>
        </div>
      )}
    </div>
  );
}
