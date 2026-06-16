import { useState, useEffect } from "react";
import { subscribeTasks } from "@notelayer/shared";
import type { Task } from "@notelayer/shared";

export function useTasks(uid: string | null) {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!uid) {
      setTasks([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    const unsub = subscribeTasks(uid, (t) => {
      setTasks(t);
      setLoading(false);
    });
    return unsub;
  }, [uid]);

  return { tasks, loading };
}
