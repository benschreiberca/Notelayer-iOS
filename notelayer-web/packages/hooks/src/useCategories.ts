import { useState, useEffect } from "react";
import { subscribeCategories } from "@notelayer/shared";
import type { Category } from "@notelayer/shared";

export function useCategories(uid: string | null) {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!uid) {
      setCategories([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    const unsub = subscribeCategories(uid, (c) => {
      setCategories(c);
      setLoading(false);
    });
    return unsub;
  }, [uid]);

  return { categories, loading };
}
