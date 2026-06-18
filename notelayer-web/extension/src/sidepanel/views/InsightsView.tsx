import React, { useState } from "react";
import { useTasks, useCategories, useInsights } from "@notelayer/hooks";
import type { InsightWindow } from "@notelayer/hooks";
import type { Category, Task } from "@notelayer/shared";
import "./InsightsView.css";

interface InsightsViewProps {
  uid: string;
}

const WINDOWS: { value: InsightWindow; label: string }[] = [
  { value: "7d",   label: "7D"  },
  { value: "30d",  label: "30D" },
  { value: "60d",  label: "60D" },
  { value: "180d", label: "6M"  },
  { value: "365d", label: "1Y"  },
];

type Drilldown =
  | { type: "category"; category: Category }
  | { type: "stat"; key: "streak" | "rate" | "created" | "completed" | "overdue" | "open" };

export function InsightsView({ uid }: InsightsViewProps) {
  const { tasks } = useTasks(uid);
  const { categories } = useCategories(uid);
  const [window, setWindow] = useState<InsightWindow>("30d");
  const [drilldown, setDrilldown] = useState<Drilldown | null>(null);

  const insights = useInsights(tasks, categories, window);
  const { trendPoints, categoryBreakdown, totalCreated, totalCompleted, completionRate, streakDays, oldestOpenTasks } = insights;

  const maxVal = Math.max(...trendPoints.map((p) => Math.max(p.created, p.completed)), 1);
  const overdue = tasks.filter((t) => {
    if (!t.dueDate || t.isCompleted) return false;
    return new Date(t.dueDate) < new Date(new Date().setHours(0, 0, 0, 0));
  });
  const openTasks   = tasks.filter((t) => !t.isCompleted);
  const doneTasks   = tasks.filter((t) => t.isCompleted);

  // ── Drilldown view ──────────────────────────────────────────────────────
  if (drilldown) {
    let title = "";
    let taskList: Task[] = [];
    let subtitle = "";

    if (drilldown.type === "category") {
      const cat = drilldown.category;
      title = `${cat.icon} ${cat.name}`;
      const catTasks   = tasks.filter((t) => t.categories.includes(cat.id));
      const catOpen    = catTasks.filter((t) => !t.isCompleted);
      const catDone    = catTasks.filter((t) => t.isCompleted);
      subtitle = `${catOpen.length} open · ${catDone.length} done`;
      taskList = [...catOpen, ...catDone];
    } else {
      const k = drilldown.key;
      if (k === "streak")    { title = "Streak";            taskList = doneTasks.slice(0, 20); subtitle = `${streakDays} day streak`; }
      if (k === "rate")      { title = "Completion Rate";   taskList = doneTasks; subtitle = `${Math.round(completionRate * 100)}% in window`; }
      if (k === "created")   { title = "Created";           taskList = openTasks; subtitle = `${totalCreated} tasks in window`; }
      if (k === "completed") { title = "Completed";         taskList = doneTasks; subtitle = `${totalCompleted} tasks in window`; }
      if (k === "overdue")   { title = "Overdue";           taskList = overdue;   subtitle = `${overdue.length} overdue`; }
      if (k === "open")      { title = "Open Tasks";        taskList = openTasks; subtitle = `${openTasks.length} total open`; }
    }

    return (
      <div className="insights">
        <div className="insights__drill-header">
          <button className="insights__back" onClick={() => setDrilldown(null)}>
            <svg viewBox="0 0 20 20" fill="none" width="18" height="18">
              <path d="M12 5l-5 5 5 5" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
          <div>
            <h2 className="insights__drill-title">{title}</h2>
            <span className="insights__drill-sub">{subtitle}</span>
          </div>
        </div>
        <div className="insights__content">
          {taskList.length === 0 ? (
            <div className="insights__empty"><p>No tasks in this view</p></div>
          ) : (
            <div className="insights__drill-list">
              {taskList.map((t) => (
                <div key={t.id} className={`insights__drill-row ${t.isCompleted ? "insights__drill-row--done" : ""}`}>
                  <div className="insights__drill-row-dot" style={{
                    background: t.isCompleted ? "var(--success)" : "var(--border-strong)"
                  }} />
                  <div className="insights__drill-row-body">
                    <span className="insights__drill-row-title">{t.title}</span>
                    {t.dueDate && (
                      <span className="insights__drill-row-due">
                        {new Date(t.dueDate).toLocaleDateString("en-US", { month: "short", day: "numeric" })}
                      </span>
                    )}
                  </div>
                  {t.isCompleted && <span className="insights__drill-done-badge">Done</span>}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    );
  }

  // ── Overview ─────────────────────────────────────────────────────────────
  return (
    <div className="insights">
      <div className="insights__header">
        <h1 className="insights__title">Insights</h1>
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
      </div>

      <div className="insights__content">
        {/* Summary stat cards — tappable */}
        <div className="insights__stat-row">
          <StatCard label="Streak"    value={`${streakDays}d`}                       accent onClick={() => setDrilldown({ type: "stat", key: "streak" })} />
          <StatCard label="Rate"      value={`${Math.round(completionRate * 100)}%`}        onClick={() => setDrilldown({ type: "stat", key: "rate" })} />
          <StatCard label="Created"   value={totalCreated}                                   onClick={() => setDrilldown({ type: "stat", key: "created" })} />
          <StatCard label="Completed" value={totalCompleted}                                 onClick={() => setDrilldown({ type: "stat", key: "completed" })} />
        </div>

        {/* Overdue / open snapshot */}
        {(overdue.length > 0 || openTasks.length > 0) && (
          <div className="insights__block">
            <h3 className="insights__sub-title">Open Tasks</h3>
            <div className="insights__stat-row">
              <StatCard label="Open"    value={openTasks.length}                               onClick={() => setDrilldown({ type: "stat", key: "open" })} />
              {overdue.length > 0 && <StatCard label="Overdue" value={overdue.length} color="#F87171" onClick={() => setDrilldown({ type: "stat", key: "overdue" })} />}
            </div>
          </div>
        )}

        {/* Trend chart */}
        <div className="insights__block">
          <h3 className="insights__sub-title">Activity</h3>
          <div className="insights__chart-wrap">
            <div className="insights__chart">
              {trendPoints.map((p, i) => (
                <div key={i} className="insights__bar-col">
                  <div className="insights__bars">
                    <div className="insights__bar insights__bar--created"   style={{ height: `${(p.created / maxVal) * 100}%` }} title={`Created: ${p.created}`} />
                    <div className="insights__bar insights__bar--completed" style={{ height: `${(p.completed / maxVal) * 100}%` }} title={`Completed: ${p.completed}`} />
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
        </div>

        {/* Category breakdown — each row tappable */}
        {categoryBreakdown.length > 0 && (
          <div className="insights__block">
            <h3 className="insights__sub-title">By Category  <span className="insights__tap-hint">tap to drill down</span></h3>
            {categoryBreakdown.map((b) => {
              const maxTotal = Math.max(...categoryBreakdown.map((x) => x.total), 1);
              return (
                <button key={b.category.id} className="insights__cat-row insights__cat-row--tap" onClick={() => setDrilldown({ type: "category", category: b.category })}>
                  <div className="insights__cat-label">
                    {b.category.icon && <span>{b.category.icon}</span>}
                    <span className="insights__cat-name">{b.category.name}</span>
                  </div>
                  <div className="insights__cat-bar-wrap">
                    <div className="insights__cat-bar-track">
                      <div className="insights__cat-bar-fill" style={{ width: `${(b.total / maxTotal) * 100}%`, backgroundColor: b.category.color }} />
                      <div className="insights__cat-bar-fill insights__cat-bar-fill--completed" style={{ width: `${(b.completed / maxTotal) * 100}%`, backgroundColor: b.category.color, opacity: 0.35 }} />
                    </div>
                  </div>
                  <div className="insights__cat-stats">
                    <span className="insights__cat-total">{b.total}</span>
                    <span className="insights__cat-rate">{Math.round(b.completionRate * 100)}%</span>
                    <svg viewBox="0 0 12 12" fill="none" width="10" height="10" style={{ opacity: 0.4 }}>
                      <path d="M4 2.5l4 3.5-4 3.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
                    </svg>
                  </div>
                </button>
              );
            })}
          </div>
        )}

        {/* Oldest open tasks */}
        {oldestOpenTasks.length > 0 && (
          <div className="insights__block">
            <h3 className="insights__sub-title">Oldest Open Tasks</h3>
            {oldestOpenTasks.map((t) => (
              <div key={t.id} className="insights__old-task">
                <span className="insights__old-task-title">{t.title}</span>
                <span className="insights__old-task-age">
                  {Math.round((Date.now() - new Date(t.createdAt).getTime()) / 86400000)}d
                </span>
              </div>
            ))}
          </div>
        )}

        {totalCreated === 0 && (
          <div className="insights__empty">
            <p>Add tasks to see insights for this period</p>
          </div>
        )}
      </div>
    </div>
  );
}

function StatCard({
  label, value, accent, color, onClick,
}: {
  label: string; value: number | string; accent?: boolean; color?: string; onClick?: () => void;
}) {
  return (
    <button className={`insights__stat ${onClick ? "insights__stat--tap" : ""}`} onClick={onClick}>
      <span className="insights__stat-value" style={color ? { color } : accent ? { color: "var(--accent)" } : undefined}>
        {value}
      </span>
      <span className="insights__stat-label">{label}</span>
      {onClick && (
        <svg viewBox="0 0 12 12" fill="none" width="8" height="8" style={{ position: "absolute", top: 6, right: 6, opacity: 0.3 }}>
          <path d="M4 2.5l4 3.5-4 3.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
        </svg>
      )}
    </button>
  );
}
