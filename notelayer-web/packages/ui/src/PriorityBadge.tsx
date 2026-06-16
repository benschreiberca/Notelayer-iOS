import React from "react";
import type { Priority } from "@notelayer/shared";

const PRIORITY_CONFIG: Record<
  NonNullable<Priority>,
  { label: string; color: string; bg: string }
> = {
  high: { label: "High", color: "var(--priority-high)", bg: "var(--priority-high-bg)" },
  medium: { label: "Med", color: "var(--priority-medium)", bg: "var(--priority-medium-bg)" },
  low: { label: "Low", color: "var(--priority-low)", bg: "var(--priority-low-bg)" },
  deferred: {
    label: "Deferred",
    color: "var(--priority-deferred)",
    bg: "var(--priority-deferred-bg)",
  },
};

interface PriorityBadgeProps {
  priority: Priority;
}

export function PriorityBadge({ priority }: PriorityBadgeProps) {
  if (!priority) return null;
  const cfg = PRIORITY_CONFIG[priority];
  return (
    <span
      style={{
        display: "inline-flex",
        alignItems: "center",
        padding: "2px 6px",
        borderRadius: "8px",
        backgroundColor: cfg.bg,
        fontSize: "11px",
        color: cfg.color,
        fontWeight: 500,
        whiteSpace: "nowrap",
        flexShrink: 0,
        lineHeight: 1.4,
      }}
    >
      {cfg.label}
    </span>
  );
}
