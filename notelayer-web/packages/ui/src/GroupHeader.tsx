import React from "react";
import "./GroupHeader.css";

interface GroupHeaderProps {
  label: string;
  color?: string;
  count: number;
  icon?: string;
  collapsed?: boolean;
  onToggleCollapse?: () => void;
}

function hexAlpha(hex: string, alpha: number): string {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

export function GroupHeader({ label, color, count, icon, collapsed, onToggleCollapse }: GroupHeaderProps) {
  const labelColor = color ? hexAlpha(color, 0.90) : undefined;
  const countBg    = color ? hexAlpha(color, 0.18) : undefined;

  return (
    <button
      className={`group-header ${onToggleCollapse ? "group-header--clickable" : ""}`}
      style={color ? { borderLeftColor: color } : undefined}
      onClick={onToggleCollapse}
      disabled={!onToggleCollapse}
    >
      <span className="group-header__label" style={labelColor ? { color: labelColor } : undefined}>
        {icon && <span className="group-header__icon">{icon}</span>}
        {label}
      </span>

      <span className="group-header__right">
        {count > 0 && (
          <span
            className="group-header__count"
            style={color ? { backgroundColor: countBg, color: labelColor } : undefined}
          >
            {count}
          </span>
        )}
        {onToggleCollapse && (
          <span className={`group-header__chevron ${collapsed ? "group-header__chevron--collapsed" : ""}`}>
            <svg viewBox="0 0 12 12" fill="none" width="10" height="10">
              <path d="M2 4.5l4 3 4-3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </span>
        )}
      </span>
    </button>
  );
}
