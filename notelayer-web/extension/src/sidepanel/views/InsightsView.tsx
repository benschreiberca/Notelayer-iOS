import React, { useState } from "react";
import { useTasks, useCategories, useInsights } from "@notelayer/hooks";
import type { InsightWindow } from "@notelayer/hooks";
import "./InsightsView.css";

interface InsightsViewProps {
  uid: string;
}

const WINDOWS: { value: InsightWindow; label: string }[] = [
  { value: "7d", label: "7D" },
  { value: "30d", label: "30D" },
  { value: "60d", label: "60D" },
  { value: "180d", label: "6M" },
  { value: "365d", label: "1Y" },
];

type InsightTab = "trend" | "category" | "usage" | "gaps";

export function InsightsView({ uid }: InsightsViewProps) {
  const { tasks } = useTasks(uid);
  const { categories } = useCategories(uid);
  const [window, setWindow] = useState<InsightWindow>("30d");
  const [tab, setTab] = useState<InsightTab>("trend");

  const insights = useInsights(tasks, categories, window);

  return (
    <div className="insights">
      <div className="insights__header">
        <h1 className="insights__title">Insights</h1>
        {/* Window picker */}
        <div className="insights__windows">
          {WINDOWS.map((w) => (
            <button
              key={w.value}
              className={`insights__win-btn ${window === w.value ? "insights__win-btn--active" : ""}`}
              onClick={() => setWindow(w.value)}
            >
              {w.label}
            </button>
          ))}
        </div>
        {/* Tab bar */}
        <div className="insights__tabs">
          {(["trend", "category", "usage", "gaps"] as InsightTab[]).map((t) => (
            <button
              key={t}
              className={`insights__tab ${tab === t ? "insights__tab--active" : ""}`}
              onClick={() => setTab(t)}
            >
              {t.charAt(0).toUpperCase() + t.slice(1)}
            </button>
          ))}
        </div>
      </div>

      <div className="insights__content">
        {tab === "trend" && (
          <TrendView insights={insights} />
        )}
        {tab === "category" && (
          <CategoryView insights={insights} />
        )}
        {tab === "usage" && (
          <UsageView insights={insights} tasks={tasks} />
        )}
        {tab === "gaps" && (
          <GapsView insights={insights} />
        )}
      </div>
    </div>
  );
}

function TrendView({ insights }: { insights: ReturnType<typeof useInsights> }) {
  const { trendPoints, totalCreated, totalCompleted, completionRate, streakDays } = insights;
  const maxVal = Math.max(...trendPoints.map((p) => Math.max(p.created, p.completed)), 1);

  return (
    <div className="insights__section">
      {/* Summary cards */}
      <div className="insights__stat-row">
        <StatCard label="Created" value={totalCreated} />
        <StatCard label="Completed" value={totalCompleted} />
        <StatCard label="Rate" value={`${Math.round(completionRate * 100)}%`} />
        <StatCard label="Streak" value={`${streakDays}d`} accent />
      </div>

      {/* Bar chart */}
      <div className="insights__chart-wrap">
        <div className="insights__chart">
          {trendPoints.map((p, i) => (
            <div key={i} className="insights__bar-col">
              <div className="insights__bars">
                <div
                  className="insights__bar insights__bar--created"
                  style={{ height: `${(p.created / maxVal) * 100}%` }}
                  title={`Created: ${p.created}`}
                />
                <div
                  className="insights__bar insights__bar--completed"
                  style={{ height: `${(p.completed / maxVal) * 100}%` }}
                  title={`Completed: ${p.completed}`}
                />
              </div>
              {(trendPoints.length <= 14 || i % Math.ceil(trendPoints.length / 7) === 0) && (
                <span className="insights__bar-label">{p.date}</span>
              )}
            </div>
          ))}
        </div>
        <div className="insights__legend">
          <span className="insights__legend-item insights__legend-item--created">Created</span>
          <span className="insights__legend-item insights__legend-item--completed">Completed</span>
        </div>
      </div>

      {/* Oldest open tasks */}
      {insights.oldestOpenTasks.length > 0 && (
        <div className="insights__section-block">
          <h3 className="insights__sub-title">Oldest Open Tasks</h3>
          {insights.oldestOpenTasks.map((t) => (
            <div key={t.id} className="insights__old-task">
              <span className="insights__old-task-title">{t.title}</span>
              <span className="insights__old-task-age">
                {Math.round((Date.now() - new Date(t.createdAt).getTime()) / 86400000)}d old
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function CategoryView({ insights }: { insights: ReturnType<typeof useInsights> }) {
  const { categoryBreakdown } = insights;
  const maxTotal = Math.max(...categoryBreakdown.map((b) => b.total), 1);

  if (categoryBreakdown.length === 0) {
    return <EmptyInsight text="No task data for this period" />;
  }

  return (
    <div className="insights__section">
      <h3 className="insights__sub-title">Tasks by Category</h3>
      {categoryBreakdown.map((b) => (
        <div key={b.category.id} className="insights__cat-row">
          <div className="insights__cat-label">
            <span>{b.category.icon}</span>
            <span className="insights__cat-name">{b.category.name}</span>
          </div>
          <div className="insights__cat-bar-wrap">
            <div className="insights__cat-bar-track">
              <div
                className="insights__cat-bar-fill"
                style={{
                  width: `${(b.total / maxTotal) * 100}%`,
                  backgroundColor: b.category.color,
                }}
              />
              <div
                className="insights__cat-bar-fill insights__cat-bar-fill--completed"
                style={{
                  width: `${(b.completed / maxTotal) * 100}%`,
                  backgroundColor: b.category.color,
                  opacity: 0.4,
                }}
              />
            </div>
          </div>
          <div className="insights__cat-stats">
            <span className="insights__cat-total">{b.total}</span>
            <span className="insights__cat-rate">{Math.round(b.completionRate * 100)}%</span>
          </div>
        </div>
      ))}
    </div>
  );
}

function UsageView({ insights, tasks }: { insights: ReturnType<typeof useInsights>; tasks: any[] }) {
  const openByPriority = {
    high: tasks.filter((t) => !t.isCompleted && t.priority === "high").length,
    medium: tasks.filter((t) => !t.isCompleted && t.priority === "medium").length,
    low: tasks.filter((t) => !t.isCompleted && t.priority === "low").length,
    deferred: tasks.filter((t) => !t.isCompleted && t.priority === "deferred").length,
    none: tasks.filter((t) => !t.isCompleted && !t.priority).length,
  };

  const withDueDate = tasks.filter((t) => !t.isCompleted && t.dueDate).length;
  const overdue = tasks.filter((t) => {
    if (!t.dueDate || t.isCompleted) return false;
    return new Date(t.dueDate) < new Date(new Date().setHours(0, 0, 0, 0));
  }).length;

  return (
    <div className="insights__section">
      <h3 className="insights__sub-title">Open Task Breakdown</h3>
      <div className="insights__stat-row">
        <StatCard label="High" value={openByPriority.high} color="#FF3B30" />
        <StatCard label="Medium" value={openByPriority.medium} color="#FF9500" />
        <StatCard label="Low" value={openByPriority.low} color="#34C759" />
        <StatCard label="Deferred" value={openByPriority.deferred} />
      </div>

      <h3 className="insights__sub-title" style={{ marginTop: 16 }}>Due Dates</h3>
      <div className="insights__stat-row">
        <StatCard label="With Due Date" value={withDueDate} />
        <StatCard label="Overdue" value={overdue} color={overdue > 0 ? "#FF3B30" : undefined} />
      </div>
    </div>
  );
}

function GapsView({ insights }: { insights: ReturnType<typeof useInsights> }) {
  const { categoryBreakdown, totalCreated } = insights;
  const unused = categoryBreakdown.filter((b) => b.total === 0);
  const underused = categoryBreakdown.filter((b) => b.total > 0 && b.completionRate < 0.2);
  const lowComplete = categoryBreakdown.filter((b) => b.completionRate < 0.5 && b.total > 2);

  return (
    <div className="insights__section">
      {totalCreated === 0 ? (
        <EmptyInsight text="Add some tasks to see gap analysis" />
      ) : (
        <>
          {underused.length > 0 && (
            <div className="insights__section-block">
              <h3 className="insights__sub-title">Low Completion Rate</h3>
              <p className="insights__gap-desc">Categories where tasks often stay open</p>
              {underused.map((b) => (
                <div key={b.category.id} className="insights__gap-row">
                  <span>{b.category.icon} {b.category.name}</span>
                  <span className="insights__gap-stat">{Math.round(b.completionRate * 100)}% done</span>
                </div>
              ))}
            </div>
          )}
          {insights.oldestOpenTasks.length > 0 && (
            <div className="insights__section-block">
              <h3 className="insights__sub-title">Tasks Sitting Longest</h3>
              {insights.oldestOpenTasks.map((t) => (
                <div key={t.id} className="insights__gap-row">
                  <span className="insights__old-task-title">{t.title}</span>
                  <span className="insights__gap-stat">
                    {Math.round((Date.now() - new Date(t.createdAt).getTime()) / 86400000)}d
                  </span>
                </div>
              ))}
            </div>
          )}
          {underused.length === 0 && insights.oldestOpenTasks.length === 0 && (
            <EmptyInsight text="Great — no significant gaps detected!" />
          )}
        </>
      )}
    </div>
  );
}

function StatCard({ label, value, accent, color }: { label: string; value: number | string; accent?: boolean; color?: string }) {
  return (
    <div className="insights__stat">
      <span
        className="insights__stat-value"
        style={color ? { color } : accent ? { color: "var(--accent)" } : undefined}
      >
        {value}
      </span>
      <span className="insights__stat-label">{label}</span>
    </div>
  );
}

function EmptyInsight({ text }: { text: string }) {
  return (
    <div className="insights__empty">
      <p>{text}</p>
    </div>
  );
}
