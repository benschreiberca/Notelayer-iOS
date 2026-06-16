import { useState, useEffect } from "react";
import { subscribeNotes } from "@notelayer/shared";
import type { Note } from "@notelayer/shared";

export function useNotes(uid: string | null) {
  const [notes, setNotes] = useState<Note[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!uid) {
      setNotes([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    const unsub = subscribeNotes(uid, (n) => {
      setNotes(n);
      setLoading(false);
    });
    return unsub;
  }, [uid]);

  const pinned = notes.filter((n) => n.isPinned);
  const unpinned = notes.filter((n) => !n.isPinned);

  return { notes, pinned, unpinned, loading };
}
