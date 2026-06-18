import React, { useEffect, useState } from "react";
import "./ThemeSheet.css";

export interface ThemeAccent {
  id: string;
  name: string;
  hex: string;
  light: string;  // indigo300-equivalent for --accent-light
  dim: string;    // 18% opacity dim
}

export const ACCENT_PRESETS: ThemeAccent[] = [
  { id: "indigo", name: "Indigo",  hex: "#818CF8", light: "#A5B4FC", dim: "rgba(129,140,248,0.18)" },
  { id: "purple", name: "Purple",  hex: "#C084FC", light: "#D8B4FE", dim: "rgba(192,132,252,0.18)" },
  { id: "pink",   name: "Pink",    hex: "#F472B6", light: "#FBCFE8", dim: "rgba(244,114,182,0.18)" },
  { id: "blue",   name: "Blue",    hex: "#60A5FA", light: "#BFDBFE", dim: "rgba(96,165,250,0.18)"  },
  { id: "green",  name: "Green",   hex: "#4ADE80", light: "#BBF7D0", dim: "rgba(74,222,128,0.18)"  },
  { id: "amber",  name: "Amber",   hex: "#FBBF24", light: "#FDE68A", dim: "rgba(251,191,36,0.18)"  },
  { id: "red",    name: "Red",     hex: "#F87171", light: "#FECACA", dim: "rgba(248,113,113,0.18)"  },
];

const STORAGE_KEY = "notelayer_theme_accent";

export function applyAccent(accent: ThemeAccent) {
  const root = document.documentElement;
  root.style.setProperty("--accent",       accent.hex);
  root.style.setProperty("--accent-hover", accent.light);
  root.style.setProperty("--accent-active",accent.light);
  root.style.setProperty("--accent-dim",   accent.dim);
  root.style.setProperty("--accent-light", accent.light);
}

export function loadSavedTheme() {
  chrome.storage.local.get([STORAGE_KEY], (res) => {
    const id = res[STORAGE_KEY] as string | undefined;
    const found = ACCENT_PRESETS.find((a) => a.id === id);
    if (found) applyAccent(found);
  });
}

interface ThemeSheetProps {
  onClose: () => void;
}

export function ThemeSheet({ onClose }: ThemeSheetProps) {
  const [activeId, setActiveId] = useState("indigo");

  useEffect(() => {
    chrome.storage.local.get([STORAGE_KEY], (res) => {
      if (res[STORAGE_KEY]) setActiveId(res[STORAGE_KEY] as string);
    });
  }, []);

  const handleSelect = (accent: ThemeAccent) => {
    setActiveId(accent.id);
    applyAccent(accent);
    chrome.storage.local.set({ [STORAGE_KEY]: accent.id });
  };

  return (
    <div className="theme-sheet__overlay" onClick={(e) => { if (e.target === e.currentTarget) onClose(); }}>
      <div className="theme-sheet">
        <div className="theme-sheet__header">
          <h2 className="theme-sheet__title">Accent Colour</h2>
          <button className="theme-sheet__close" onClick={onClose}>Done</button>
        </div>

        <div className="theme-sheet__swatches">
          {ACCENT_PRESETS.map((a) => (
            <button
              key={a.id}
              className={`theme-sheet__swatch ${activeId === a.id ? "theme-sheet__swatch--active" : ""}`}
              style={{ background: a.hex }}
              onClick={() => handleSelect(a)}
              title={a.name}
            >
              {activeId === a.id && (
                <svg viewBox="0 0 16 16" fill="none" width="14" height="14">
                  <path d="M3 8l4 4 6-7" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              )}
            </button>
          ))}
        </div>

        <div className="theme-sheet__labels">
          {ACCENT_PRESETS.map((a) => (
            <span
              key={a.id}
              className={`theme-sheet__label ${activeId === a.id ? "theme-sheet__label--active" : ""}`}
            >
              {a.name}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}
