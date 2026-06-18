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

export function InsightsView({ uid }: InsightsViewProps) {
  const { tasks } = useTasks(uid);
  const { categories } = useCategories(uid);
  const [window, setWindow] = useState<InsightWindow>("30d");

  const insights = useInsights(tasks, categories, window);
  const { trendPoints, categoryBreakdown, totalCreated, totalCompleted, completionRate, streakDays, oldestOpenTasks } = insights;

  const maxVal = Math.max(...trendPoints.map((p) => Math.max(p.created, p.completed)), 1);

  const openByPriority = {
    high: tasks.filter((t) => !t.isCompleted && t.priority === "high").length,
    medium: tasks.filter((t) => !t.isCompleted && t.priority === "medium").length,
    low: tasks.filter((t) => !t.isCompleted && t.priority === "low").length,
    none: tasks.filter((t) => !t.isCompleted && !t.priority).length,
  };
  const overdue = tasks.filter((t) => {
    if (!t.dueDate || t.isCompleted) return false;
    return new Date(t.dueDate) < new Date(new Date().setHours(0, 0, 0, 0));
  }).length;

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
        {/* Summary cards */}
        <div className="insights__stat-row">
          <StatCard label="Streak" value={`${streakDays}d`} accent />
          <StatCard label="Rate" value={`${Math.round(completionRate * 100)}%`} />
          <StatCard label="Created" value={totalCreated} />
          <StatCard label="Completed" value={totalCompleted} />
        </div>

        {/* Open task snapshot */}
        {(openByPriority.high + openByPriority.medium + openByPriority.low + openByPriority.none > 0 || overdue > 0) && (
          <div className="insights__block">
            <h3 className="insights__sub-title">Open Tasks</h3>
            <div className="insights__stat-row">
              {openByPriority.high > 0 && <StatCard label="High" value={openByPriority.high} color="#FF3B30" />}
              {openByPriority.medium > 0 && <StatCard label="Med" value={openByPriority.medium} color="#FF9500" />}
              {openByPriority.low > 0 && <StatCard label="Low" value={openByPriority.low} color="#34C759" />}
              {overdue > 0 && <StatCard label="Overdue" value={overdue} color="#FF3B30" />}
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
        </div>

        {/* Category breakdown */}
        {categoryBreakdown.length > 0 && (
          <div className="insights__block">
            <h3 className="insights__sub-title">By Category</h3>
            {categoryBreakdown.map((b) => {
              const maxTotal = Math.max(...categoryBreakdown.map((x) => x.total), 1);
              return (
                <div key={b.category.id} className="insights__cat-row">
                  <div className="insights__cat-label">
                    {b.category.icon && <span>{b.category.icon}</span>}
                    <span className="insights__cat-name">{b.category.name}</span>
                  </div>
                  <div className="insights__cat-bar-wrap">
                    <div className="insights__cat-bar-track">
                      <div
                        className="insights__cat-bar-fill"
                        style={{ width: `${(b.total / maxTotal) * 100}%`, backgroundColor: b.category.color }}
                      />
                      <div
                        className="insights__cat-bar-fill insights__cat-bar-fill--completed"
                        style={{ width: `${(b.completed / maxTotal) * 100}%`, backgroundColor: b.category.color, opacity: 0.4 }}
                      />
                    </div>
                  </div>
                  <div className="insights__cat-stats">
                    <span className="insights__cat-total">{b.total}</span>
                    <span className="insights__cat-rate">{Math.round(b.completionRate * 100)}%</span>
                  </div>
                </div>
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
