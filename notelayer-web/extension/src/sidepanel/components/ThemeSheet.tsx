import React, { useEffect, useState } from "react";
import "./ThemeSheet.css";

export type ThemeMode = "system" | "light" | "dark";

export interface ThemeAccent {
  id: string;
  name: string;
  hex: string;
  light: string;
  dim: string;
}

export interface ThemeWallpaper {
  id: string;
  name: string;
  lightOverlay: string;
  darkOverlay: string;
  swatchLight: string;
  swatchDark: string;
}

// From iOS ThemeAccentCatalog
export const ACCENT_PRESETS: ThemeAccent[] = [
  { id: "indigo",   name: "Indigo",   hex: "#818CF8", light: "#A5B4FC", dim: "rgba(129,140,248,0.18)" },
  { id: "blue",     name: "Blue",     hex: "#3B82F6", light: "#93C5FD", dim: "rgba(59,130,246,0.18)"  },
  { id: "purple",   name: "Lavender", hex: "#9B5DE5", light: "#C4B5FD", dim: "rgba(155,93,229,0.18)"  },
  { id: "pink",     name: "Hot Pink", hex: "#FF4FD8", light: "#F9A8D4", dim: "rgba(255,79,216,0.18)"  },
  { id: "mint",     name: "Mint",     hex: "#20C997", light: "#6EE7B7", dim: "rgba(32,201,151,0.18)"  },
  { id: "ocean",    name: "Ocean",    hex: "#0077B6", light: "#7DD3FC", dim: "rgba(0,119,182,0.18)"   },
  { id: "forest",   name: "Forest",   hex: "#2F855A", light: "#86EFAC", dim: "rgba(47,133,90,0.18)"   },
  { id: "amber",    name: "Citrus",   hex: "#FFBE0B", light: "#FDE68A", dim: "rgba(255,190,11,0.18)"  },
  { id: "sunset",   name: "Sunset",   hex: "#FB5607", light: "#FCA5A5", dim: "rgba(251,86,7,0.18)"    },
  { id: "berry",    name: "Berry",    hex: "#B5179E", light: "#F0ABFC", dim: "rgba(181,23,158,0.18)"  },
  { id: "ember",    name: "Ember",    hex: "#E63946", light: "#FCA5A5", dim: "rgba(230,57,70,0.18)"   },
  { id: "graphite", name: "Graphite", hex: "#334155", light: "#CBD5E1", dim: "rgba(51,65,85,0.18)"    },
];

// Gradient wallpapers from iOS ThemeWallpaperCatalog
export const WALLPAPER_PRESETS: ThemeWallpaper[] = [
  {
    id: "iridescent-flow",
    name: "Iridescent",
    lightOverlay: "linear-gradient(150deg, rgba(0,210,255,0.20) 0%, rgba(123,47,247,0.16) 40%, rgba(255,79,216,0.12) 75%, transparent 100%)",
    darkOverlay:  "linear-gradient(150deg, rgba(129,140,248,0.12) 0%, rgba(168,85,247,0.08) 40%, rgba(236,72,153,0.06) 75%, transparent 100%)",
    swatchLight: "linear-gradient(135deg, #00D2FF, #7B2FF7, #FF4FD8)",
    swatchDark:  "linear-gradient(135deg, #0B1020, #1B0F2B, #2A0B1F)",
  },
  {
    id: "focus-dark",
    name: "Focus",
    lightOverlay: "linear-gradient(150deg, rgba(51,65,85,0.08) 0%, rgba(15,23,42,0.05) 100%)",
    darkOverlay:  "linear-gradient(150deg, rgba(15,23,42,0.50) 0%, rgba(5,7,11,0.30) 100%)",
    swatchLight: "linear-gradient(135deg, #94A3B8, #1E293B)",
    swatchDark:  "linear-gradient(135deg, #0B0F1A, #05070B)",
  },
  {
    id: "midnight-bloom",
    name: "Midnight",
    lightOverlay: "linear-gradient(150deg, rgba(27,17,64,0.12) 0%, rgba(43,27,90,0.09) 50%, rgba(15,23,42,0.07) 100%)",
    darkOverlay:  "linear-gradient(150deg, rgba(75,0,130,0.20) 0%, rgba(50,0,100,0.15) 50%, rgba(15,0,50,0.10) 100%)",
    swatchLight: "linear-gradient(135deg, #3B1F72, #1B1140)",
    swatchDark:  "linear-gradient(135deg, #1B0F3B, #07040F)",
  },
  {
    id: "sunset-rise",
    name: "Sunset",
    lightOverlay: "linear-gradient(150deg, rgba(255,107,107,0.20) 0%, rgba(255,217,61,0.15) 50%, rgba(255,107,107,0.12) 100%)",
    darkOverlay:  "linear-gradient(150deg, rgba(180,30,30,0.20) 0%, rgba(150,80,0,0.15) 50%, rgba(180,30,30,0.12) 100%)",
    swatchLight: "linear-gradient(135deg, #FF6B6B, #FFD93D)",
    swatchDark:  "linear-gradient(135deg, #2B0B0B, #2B1A0B)",
  },
  {
    id: "arctic-glow",
    name: "Arctic",
    lightOverlay: "linear-gradient(150deg, rgba(142,197,255,0.25) 0%, rgba(224,242,255,0.20) 50%, rgba(182,231,255,0.18) 100%)",
    darkOverlay:  "linear-gradient(150deg, rgba(0,119,182,0.18) 0%, rgba(0,77,130,0.12) 50%, rgba(0,40,80,0.08) 100%)",
    swatchLight: "linear-gradient(135deg, #8EC5FF, #B6E7FF)",
    swatchDark:  "linear-gradient(135deg, #0A121A, #0D1C2B)",
  },
];

const STORAGE_KEY_MODE      = "notelayer_theme_mode";
const STORAGE_KEY_ACCENT    = "notelayer_theme_accent";
const STORAGE_KEY_WALLPAPER = "notelayer_theme_wallpaper";

export function resolveMode(mode: ThemeMode): "light" | "dark" {
  if (mode === "light") return "light";
  if (mode === "dark") return "dark";
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

export function applyAccent(accent: ThemeAccent) {
  const r = document.documentElement;
  r.style.setProperty("--accent",        accent.hex);
  r.style.setProperty("--accent-hover",  accent.light);
  r.style.setProperty("--accent-active", accent.light);
  r.style.setProperty("--accent-dim",    accent.dim);
  r.style.setProperty("--accent-light",  accent.light);
}

export function applyWallpaper(wallpaper: ThemeWallpaper, resolved: "light" | "dark") {
  const overlay = resolved === "dark" ? wallpaper.darkOverlay : wallpaper.lightOverlay;
  document.documentElement.style.setProperty("--wallpaper-overlay", overlay);
}

export function applyMode(mode: ThemeMode): "light" | "dark" {
  const resolved = resolveMode(mode);
  document.documentElement.dataset.theme = resolved;
  return resolved;
}

export function loadSavedTheme() {
  chrome.storage.local.get([STORAGE_KEY_MODE, STORAGE_KEY_ACCENT, STORAGE_KEY_WALLPAPER], (res) => {
    const mode = (res[STORAGE_KEY_MODE] as ThemeMode) ?? "dark";
    const resolved = applyMode(mode);
    const accent    = ACCENT_PRESETS.find((a) => a.id === res[STORAGE_KEY_ACCENT]) ?? ACCENT_PRESETS[0];
    const wallpaper = WALLPAPER_PRESETS.find((w) => w.id === res[STORAGE_KEY_WALLPAPER]) ?? WALLPAPER_PRESETS[0];
    applyAccent(accent);
    applyWallpaper(wallpaper, resolved);
  });
}

interface ThemeSheetProps {
  onClose: () => void;
}

export function ThemeSheet({ onClose }: ThemeSheetProps) {
  const [mode, setMode] = useState<ThemeMode>("dark");
  const [accentId, setAccentId] = useState("indigo");
  const [wallpaperId, setWallpaperId] = useState("iridescent-flow");

  useEffect(() => {
    chrome.storage.local.get([STORAGE_KEY_MODE, STORAGE_KEY_ACCENT, STORAGE_KEY_WALLPAPER], (res) => {
      if (res[STORAGE_KEY_MODE]) setMode(res[STORAGE_KEY_MODE] as ThemeMode);
      if (res[STORAGE_KEY_ACCENT]) setAccentId(res[STORAGE_KEY_ACCENT]);
      if (res[STORAGE_KEY_WALLPAPER]) setWallpaperId(res[STORAGE_KEY_WALLPAPER]);
    });
  }, []);

  const handleMode = (m: ThemeMode) => {
    setMode(m);
    const resolved = applyMode(m);
    const wp = WALLPAPER_PRESETS.find((w) => w.id === wallpaperId) ?? WALLPAPER_PRESETS[0];
    applyWallpaper(wp, resolved);
    chrome.storage.local.set({ [STORAGE_KEY_MODE]: m });
  };

  const handleAccent = (a: ThemeAccent) => {
    setAccentId(a.id);
    applyAccent(a);
    chrome.storage.local.set({ [STORAGE_KEY_ACCENT]: a.id });
  };

  const handleWallpaper = (w: ThemeWallpaper) => {
    setWallpaperId(w.id);
    const resolved = resolveMode(mode);
    applyWallpaper(w, resolved);
    chrome.storage.local.set({ [STORAGE_KEY_WALLPAPER]: w.id });
  };

  const resolved = resolveMode(mode);

  return (
    <div className="theme-sheet__overlay" onClick={(e) => { if (e.target === e.currentTarget) onClose(); }}>
      <div className="theme-sheet">
        <div className="theme-sheet__handle" />
        <div className="theme-sheet__header">
          <h2 className="theme-sheet__title">Appearance</h2>
          <button className="theme-sheet__close" onClick={onClose}>Done</button>
        </div>

        {/* Mode */}
        <div className="theme-sheet__section">
          <span className="theme-sheet__section-label">MODE</span>
          <div className="theme-sheet__seg">
            {(["system", "light", "dark"] as ThemeMode[]).map((m) => (
              <button
                key={m}
                className={`theme-sheet__seg-btn ${mode === m ? "theme-sheet__seg-btn--active" : ""}`}
                onClick={() => handleMode(m)}
              >
                {m === "system" ? "Auto" : m === "light" ? "☀ Light" : "☾ Dark"}
              </button>
            ))}
          </div>
        </div>

        {/* Wallpaper */}
        <div className="theme-sheet__section">
          <span className="theme-sheet__section-label">WALLPAPER</span>
          <div className="theme-sheet__wallpapers">
            {WALLPAPER_PRESETS.map((w) => {
              const swatch = resolved === "dark" ? w.swatchDark : w.swatchLight;
              const active = wallpaperId === w.id;
              return (
                <button
                  key={w.id}
                  className={`theme-sheet__wallpaper ${active ? "theme-sheet__wallpaper--active" : ""}`}
                  onClick={() => handleWallpaper(w)}
                  title={w.name}
                >
                  <div className="theme-sheet__wallpaper-swatch" style={{ background: swatch }} />
                  <span className="theme-sheet__wallpaper-name">{w.name}</span>
                  {active && <div className="theme-sheet__wallpaper-check">✓</div>}
                </button>
              );
            })}
          </div>
        </div>

        {/* Accent */}
        <div className="theme-sheet__section">
          <span className="theme-sheet__section-label">ACCENT COLOUR</span>
          <div className="theme-sheet__accents">
            {ACCENT_PRESETS.map((a) => (
              <button
                key={a.id}
                className={`theme-sheet__swatch ${accentId === a.id ? "theme-sheet__swatch--active" : ""}`}
                style={{ background: a.hex }}
                onClick={() => handleAccent(a)}
                title={a.name}
              >
                {accentId === a.id && (
                  <svg viewBox="0 0 16 16" fill="none" width="11" height="11">
                    <path d="M3 8l4 4 6-7" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                )}
              </button>
            ))}
          </div>
          <div className="theme-sheet__accent-labels">
            {ACCENT_PRESETS.map((a) => (
              <span
                key={a.id}
                className={`theme-sheet__accent-label ${accentId === a.id ? "theme-sheet__accent-label--active" : ""}`}
              >
                {a.name}
              </span>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
