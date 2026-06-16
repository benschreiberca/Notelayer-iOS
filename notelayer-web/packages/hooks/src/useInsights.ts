import { useMemo } from "react";
import type { Task, Category } from "@notelayer/shared";

export type InsightWindow = "7d" | "30d" | "60d" | "180d" | "365d";

function windowMs(w: InsightWindow): number {
  const days = { "7d": 7, "30d": 30, "60d": 60, "180d": 180, "365d": 365 };
  return days[w] * 86400000;
}

export interface TrendPoint {
  date: string;
  created: number;
  completed: number;
}

export interface CategoryBreakdown {
  category: Category;
  total: number;
  completed: number;
  completionRate: number;
}

export interface InsightsData {
  trendPoints: TrendPoint[];
  categoryBreakdown: CategoryBreakdown[];
  totalCreated: number;
  totalCompleted: number;
  completionRate: number;
  oldestOpenTasks: Task[];
  streakDays: number;
  avgCompletionDays: number;
}

export function useInsights(
  tasks: Task[],
  categories: Category[],
  window: InsightWindow,
): InsightsData {
  return useMemo(() => {
    const now = Date.now();
    const cutoff = now - windowMs(window);

    const windowTasks = tasks.filter((t) => new Date(t.createdAt).getTime() >= cutoff);
    const completedInWindow = windowTasks.filter((t) => t.isCompleted);

    // Daily trend points
    const numDays = { "7d": 7, "30d": 30, "60d": 60, "180d": 60, "365d": 52 }[window];
    const intervalMs = windowMs(window) / numDays;
    const trendPoints: TrendPoint[] = [];
    for (let i = numDays - 1; i >= 0; i--) {
      const start = now - (i + 1) * intervalMs;
      const end = now - i * intervalMs;
      const date = new Date(end).toLocaleDateString("en-US", { month: "short", day: "numeric" });
      const created = windowTasks.filter((t) => {
        const ts = new Date(t.createdAt).getTime();
        return ts >= start && ts < end;
      }).length;
      const completed = tasks.filter((t) => {
        if (!t.isCompleted || !t.updatedAt) return false;
        const ts = new Date(t.updatedAt).getTime();
        return ts >= start && ts < end;
      }).length;
      trendPoints.push({ date, created, completed });
    }

    // Category breakdown
    const categoryBreakdown: CategoryBreakdown[] = categories.map((cat) => {
      const catTasks = windowTasks.filter((t) => t.categories.includes(cat.id));
      const catCompleted = catTasks.filter((t) => t.isCompleted);
      return {
        category: cat,
        total: catTasks.length,
        completed: catCompleted.length,
        completionRate: catTasks.length > 0 ? catCompleted.length / catTasks.length : 0,
      };
    }).filter((b) => b.total > 0).sort((a, b) => b.total - a.total);

    // Oldest open tasks (by createdAt, not completed)
    const oldestOpenTasks = [...tasks]
      .filter((t) => !t.isCompleted)
      .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())
      .slice(0, 5);

    // Completion streak
    let streakDays = 0;
    for (let i = 0; i < 365; i++) {
      const dayStart = new Date();
      dayStart.setHours(0, 0, 0, 0);
      dayStart.setDate(dayStart.getDate() - i);
      const dayEnd = new Date(dayStart);
      dayEnd.setDate(dayEnd.getDate() + 1);
      const completedToday = tasks.filter((t) => {
        if (!t.isCompleted) return false;
        const ts = new Date(t.updatedAt).getTime();
        return ts >= dayStart.getTime() && ts < dayEnd.getTime();
      });
      if (completedToday.length === 0) break;
      streakDays++;
    }

    const totalCreated = windowTasks.length;
    const totalCompleted = completedInWindow.length;
    const completionRate = totalCreated > 0 ? totalCompleted / totalCreated : 0;

    return {
      trendPoints,
      categoryBreakdown,
      totalCreated,
      totalCompleted,
      completionRate,
      oldestOpenTasks,
      streakDays,
      avgCompletionDays: 0,
    };
  }, [tasks, categories, window]);
}
