import React, { useState } from "react";
import type { User } from "firebase/auth";
import type { Category } from "@notelayer/shared";
import { applyPresetCategories } from "@notelayer/shared";
import { CategoryPill } from "@notelayer/ui";
import "./OnboardingFlow.css";

// ── Preset definitions (mirrors iOS WelcomeView.swift OnboardingPreset) ──────
interface PresetCategory { name: string; icon: string; color: string; }
interface Preset { id: string; name: string; recommended: boolean; categories: PresetCategory[]; }

const PRESETS: Preset[] = [
  {
    id: "everyday-balance",
    name: "Everyday Balance",
    recommended: true,
    categories: [
      { name: "Personal",              icon: "🧠", color: "#4F8EF7" },
      { name: "Work",                  icon: "💼", color: "#FF3B30" },
      { name: "Home",                  icon: "🏠", color: "#FF9500" },
      { name: "Health",                icon: "🩺", color: "#34C759" },
      { name: "Finance and Investing", icon: "📈", color: "#2F855A" },
      { name: "Someday",               icon: "🗂️", color: "#64D2FF" },
    ],
  },
  {
    id: "life-admin",
    name: "Life Admin",
    recommended: false,
    categories: [
      { name: "Personal Admin",    icon: "📋", color: "#4F8EF7" },
      { name: "Errands",           icon: "🛒", color: "#FF9500" },
      { name: "Family and Home",   icon: "👨‍👩‍👧‍👦", color: "#FF6B6B" },
      { name: "Health and Wellness", icon: "🧘", color: "#34C759" },
      { name: "Banking and Bills", icon: "🏦", color: "#2F855A" },
      { name: "Someday",           icon: "🗂️", color: "#64D2FF" },
    ],
  },
  {
    id: "growth-projects",
    name: "Growth and Projects",
    recommended: false,
    categories: [
      { name: "Work Projects",         icon: "🧱", color: "#FF3B30" },
      { name: "Personal Projects",     icon: "🛠️", color: "#FF9500" },
      { name: "Learning",              icon: "📚", color: "#BF5AF2" },
      { name: "Relationships",         icon: "🤝", color: "#34C759" },
      { name: "Finance and Investing", icon: "📈", color: "#2F855A" },
      { name: "Someday",               icon: "🗂️", color: "#64D2FF" },
    ],
  },
];

// ── Props ─────────────────────────────────────────────────────────────────────
interface OnboardingFlowProps {
  user: User;
  uid: string;
  categories: Category[];        // live Firestore categories (empty = new user)
  isExistingUser: boolean;
  onDone: () => void;
}

// ── Component ─────────────────────────────────────────────────────────────────
export function OnboardingFlow({ user, uid, categories, isExistingUser, onDone }: OnboardingFlowProps) {
  const [step, setStep] = useState(1);
  const [selectedPreset, setSelectedPreset] = useState(PRESETS[0]);
  const [applying, setApplying] = useState(false);

  const totalSteps = 3;
  const firstName = user.displayName?.split(" ")[0] ?? "there";

  const back = () => setStep((s) => Math.max(1, s - 1));
  const next = () => setStep((s) => Math.min(totalSteps, s + 1));

  const handleStart = async () => {
    setApplying(true);
    try {
      await applyPresetCategories(uid, selectedPreset.categories.map((c, i) => ({
        name: c.name, icon: c.icon, color: c.color, orderIndex: i,
      })));
    } catch (e) {
      console.error("[Notelayer] Failed to apply preset:", e);
    } finally {
      setApplying(false);
      onDone();
    }
  };

  // ── Shared nav bar ──
  const NavBar = ({ title }: { title: string }) => (
    <div className="ob-nav">
      <button className="ob-nav__back" onClick={back} disabled={step === 1}>
        ‹ Back
      </button>
      <span className="ob-nav__title">{title}</span>
      <button className="ob-nav__skip" onClick={onDone}>Skip</button>
    </div>
  );

  // ── Progress dots ──
  const Dots = () => (
    <div className="ob-dots">
      {Array.from({ length: totalSteps }, (_, i) => (
        <div key={i} className={`ob-dot ${step === i + 1 ? "ob-dot--active" : ""}`} />
      ))}
    </div>
  );

  // ══════════════════════════════════════════════════════════════
  //  NEW USER FLOW
  // ══════════════════════════════════════════════════════════════
  if (!isExistingUser) {
    return (
      <div className="ob">
        <NavBar title={["", "Get Started", "How It Works", "Starting Categories"][step]} />

        {/* Step 1 — Intro */}
        {step === 1 && (
          <div className="ob__body">
            <p className="ob__title">Quick Orientation</p>
            <div className="ob__video">
              <span className="ob__video-icon">▶</span>
              <p className="ob__video-label">Intro walkthrough — task entry, views, Insights</p>
            </div>
            <button className="ob__link" onClick={next}>Skip intro video →</button>
            <div className="ob__spacer" />
            <button className="ob__btn-primary" onClick={next}>Next</button>
          </div>
        )}

        {/* Step 2 — Cues */}
        {step === 2 && (
          <div className="ob__body">
            <p className="ob__title">How Notelayer Works</p>
            <div className="ob__cues">
              <Cue icon="✓"  text="Tasks can live in multiple categories at once." />
              <Cue icon="⇅"  text="Switch views: List, Priority, Category, or Date." />
              <Cue icon="⚙"  text="Experimental features can be enabled from settings later." />
            </div>
            <p className="ob__note">This flow can be reopened from Settings anytime.</p>
            <div className="ob__spacer" />
            <button className="ob__btn-primary" onClick={next}>Next</button>
          </div>
        )}

        {/* Step 3 — Preset picker */}
        {step === 3 && (
          <div className="ob__body">
            <p className="ob__title">Choose Starting Categories</p>
            <div className="ob__presets">
              {PRESETS.map((preset) => (
                <button
                  key={preset.id}
                  className={`ob__preset ${selectedPreset.id === preset.id ? "ob__preset--selected" : ""}`}
                  onClick={() => setSelectedPreset(preset)}
                >
                  <div className="ob__preset-top">
                    <span className="ob__preset-name">{preset.name}</span>
                    {preset.recommended && (
                      <span className="ob__preset-badge">Recommended</span>
                    )}
                    <span className="ob__preset-check">
                      {selectedPreset.id === preset.id ? "●" : "○"}
                    </span>
                  </div>
                  <p className="ob__preset-cats">
                    {preset.categories.map((c) => `${c.icon} ${c.name}`).join("  ·  ")}
                  </p>
                </button>
              ))}
            </div>
            <div className="ob__spacer" />
            <button className="ob__btn-primary" onClick={handleStart} disabled={applying}>
              {applying ? "Setting up…" : `Start with ${selectedPreset.name}`}
            </button>
            <button className="ob__link" onClick={onDone}>Keep Current Categories</button>
          </div>
        )}

        <Dots />
      </div>
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  EXISTING USER FLOW
  // ══════════════════════════════════════════════════════════════
  return (
    <div className="ob">
      <NavBar title={["", "Get Started", "Your Categories", "Quick Tips"][step]} />

      {/* Step 1 — Welcome back */}
      {step === 1 && (
        <div className="ob__body">
          <p className="ob__title">Welcome Back{firstName !== "there" ? `, ${firstName}` : ""}</p>
          <p className="ob__subtitle">
            Your tasks, notes, and categories are exactly as you left them — nothing was changed on sign-in.
          </p>
          <div className="ob__cues">
            <Cue icon="✓"  text="Right-click any page to save as task or note." />
            <Cue icon="📋" text="4 task views: List, Priority, Category, Date." />
            <Cue icon="📊" text="Insights to track your productivity over time." />
            <Cue icon="⌨" text="Shortcut: Cmd+Shift+L (Mac) / Ctrl+Shift+L." />
          </div>
          <div className="ob__spacer" />
          <button className="ob__btn-primary" onClick={next}>Next</button>
        </div>
      )}

      {/* Step 2 — Categories preserved */}
      {step === 2 && (
        <div className="ob__body">
          <p className="ob__title">Your Categories</p>
          <div className="ob__preserved-banner">
            <span className="ob__preserved-icon">✓</span>
            <div>
              <p className="ob__preserved-head">Your categories are ready</p>
              <p className="ob__preserved-sub">We found your existing setup and kept it exactly as-is. Nothing was overwritten.</p>
            </div>
          </div>
          <p className="ob__section-label">Your current categories</p>
          <div className="ob__pills">
            {categories.map((cat) => (
              <CategoryPill key={cat.id} category={cat} />
            ))}
          </div>
          <p className="ob__note">
            Add, edit, or reorder from <strong>⋯ → Manage Categories</strong> anytime.
          </p>
          <div className="ob__spacer" />
          <button className="ob__btn-primary" onClick={next}>Continue</button>
        </div>
      )}

      {/* Step 3 — Tips */}
      {step === 3 && (
        <div className="ob__body">
          <p className="ob__title">Quick Tips</p>
          <div className="ob__cues">
            <Cue icon="🖱" text="Right-click selected text on any page to save it instantly." />
            <Cue icon="✏" text="Tap any task to edit, set priority, or add a due date." />
            <Cue icon="📌" text="Pin important notes to keep them at the top." />
            <Cue icon="⟳" text="Drag tasks to reorder them in List view." />
          </div>
          <div className="ob__spacer" />
          <button className="ob__btn-primary" onClick={onDone}>Start Using Notelayer</button>
        </div>
      )}

      <Dots />
    </div>
  );
}

function Cue({ icon, text }: { icon: string; text: string }) {
  return (
    <div className="ob__cue">
      <span className="ob__cue-icon">{icon}</span>
      <span className="ob__cue-text">{text}</span>
    </div>
  );
}
