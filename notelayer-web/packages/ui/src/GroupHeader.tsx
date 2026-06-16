import React from "react";
import "./GroupHeader.css";

interface GroupHeaderProps {
  label: string;
  color?: string;
  count: number;
  icon?: string;
}

function hexAlpha(hex: string, alpha: number): string {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

export function GroupHeader({ label, color, count, icon }: GroupHeaderProps) {
  return (
    <div className="group-header" style={color ? { borderLeftColor: color } : undefined}>
      <span className="group-header__label" style={color ? { color: hexAlpha(color, 0.85) } : undefined}>
        {icon && <span className="group-header__icon">{icon}</span>}
        {label}
      </span>
      {count > 0 && (
        <span
          className="group-header__count"
          style={
            color
              ? {
                  backgroundColor: hexAlpha(color, 0.18),
                  color: hexAlpha(color, 0.85),
                }
              : undefined
          }
        >
          {count}
        </span>
      )}
    </div>
  );
}
