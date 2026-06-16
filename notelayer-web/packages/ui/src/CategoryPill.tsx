import React from "react";
import type { Category } from "@notelayer/shared";

function hexAlpha(hex: string, alpha: number): string {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

interface CategoryPillProps {
  category: Category;
  compact?: boolean;
}

export function CategoryPill({ category, compact }: CategoryPillProps) {
  return (
    <span
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: "3px",
        padding: compact ? "2px 6px" : "2px 8px",
        borderRadius: "100px",
        backgroundColor: hexAlpha(category.color, 0.18),
        border: `0.5px solid ${hexAlpha(category.color, 0.30)}`,
        fontSize: "11px",
        color: "var(--text-secondary)",
        whiteSpace: "nowrap",
        flexShrink: 0,
        lineHeight: 1.4,
      }}
    >
      <span style={{ fontSize: "10px" }}>{category.icon}</span>
      <span>{category.name}</span>
    </span>
  );
}
