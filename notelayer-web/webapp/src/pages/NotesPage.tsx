import { useEffect, useState, useRef } from "react";
import type { User } from "firebase/auth";
import { saveNote, subscribeNotes } from "@notelayer/shared";
import type { Note } from "@notelayer/shared";
import styles from "./NotesPage.module.css";

export default function NotesPage({ user }: { user: User }) {
  const [notes, setNotes] = useState<Note[]>([]);
  const [text, setText] = useState("");
  const [focused, setFocused] = useState(false);
  const ref = useRef<HTMLTextAreaElement>(null);

  useEffect(() => subscribeNotes(user.uid, setNotes), [user.uid]);

  async function handleSave() {
    if (!text.trim()) return;
    await saveNote(user.uid, { text: text.trim() });
    setText("");
    setFocused(false);
  }

  return (
    <div className={styles.page}>
      <div className={`${styles.addCard} ${focused ? styles.addFocused : ""}`}>
        <textarea
          ref={ref}
          className={styles.addInput}
          placeholder="Write a note…"
          value={text}
          rows={focused ? 4 : 2}
          onChange={(e) => setText(e.target.value)}
          onFocus={() => setFocused(true)}
        />
        {focused && (
          <div className={styles.addFooter}>
            <button className={styles.cancelBtn} onClick={() => { setText(""); setFocused(false); }}>Cancel</button>
            <button className={styles.saveBtn} onClick={handleSave} disabled={!text.trim()}>Save Note</button>
          </div>
        )}
      </div>

      {notes.length === 0 && (
        <p className={styles.empty}>No notes yet.</p>
      )}

      <div className={styles.noteList}>
        {notes.map((note) => (
          <div key={note.id} className={styles.noteCard}>
            <p className={styles.noteText}>{note.text}</p>
            <span className={styles.noteDate}>{formatDate(note.createdAt)}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function formatDate(iso: string): string {
  const d = new Date(iso);
  const now = new Date();
  const diffDays = Math.floor((now.getTime() - d.getTime()) / 86400000);
  if (diffDays === 0) return "Today";
  if (diffDays === 1) return "Yesterday";
  return d.toLocaleDateString("en-US", { month: "short", day: "numeric" });
}
