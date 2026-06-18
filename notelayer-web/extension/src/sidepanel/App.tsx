import React, { useState, useEffect } from "react";
import { OAuthCredential, signInWithCredential, signOut } from "firebase/auth";
import { auth } from "@notelayer/shared";
import { useAuth, useCategories } from "@notelayer/hooks";
import { AuthScreen } from "./components/AuthScreen";
import { OnboardingFlow } from "./components/OnboardingFlow";
import { ThemeSheet, loadSavedTheme } from "./components/ThemeSheet";
import { TodosView } from "./views/TodosView";
import { NotesView } from "./views/NotesView";
import { InsightsView } from "./views/InsightsView";
import "./App.css";

// Apply saved accent colour before first render
loadSavedTheme();

type Tab = "todos" | "insights";

const IconTodos = () => (
  <svg viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">
    <circle cx="5" cy="7" r="2.2" stroke="currentColor" strokeWidth="1.6" />
    <circle cx="5" cy="15" r="2.2" stroke="currentColor" strokeWidth="1.6" />
    <path d="M9.5 7h8M9.5 15h8" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
    <path d="M3.5 6.8l1.2 1.1 1.8-2" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const IconInsights = () => (
  <svg viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="3" y="12" width="4" height="7" rx="1.5" fill="currentColor" opacity="0.6" />
    <rect x="9" y="7"  width="4" height="12" rx="1.5" fill="currentColor" opacity="0.8" />
    <rect x="15" y="3" width="4" height="16" rx="1.5" fill="currentColor" />
  </svg>
);

export function App() {
  const { user, loading: authLoading } = useAuth();
  const [activeTab, setActiveTab] = useState<Tab>("todos");
  const [showNotes, setShowNotes] = useState(false);
  const [showTheme, setShowTheme] = useState(false);
  const [showOnboarding, setShowOnboarding] = useState(false);
  const { categories, loading: catsLoading } = useCategories(user?.uid ?? null);

  const isExistingUser = !catsLoading && categories.length > 0;

  useEffect(() => {
    if (!user || catsLoading) return;
    // Skip onboarding for existing iOS users who already have data
    if (isExistingUser) return;
    chrome.storage.local.get(["notelayer_onboarded"], (res) => {
      if (!res.notelayer_onboarded) {
        setShowOnboarding(true);
      }
    });
  }, [user?.uid, catsLoading, isExistingUser]);

  const handleSignIn = async (provider: "google" | "apple" = "google") => {
    const result = await chrome.runtime.sendMessage({ action: "firebase-auth", provider });
    if (!result?.ok) throw new Error(result?.error || "Sign-in failed");
    const credential = OAuthCredential.fromJSON(result.credential);
    if (!credential) throw new Error("Could not parse sign-in credential.");
    await signInWithCredential(auth, credential);
  };

  const handleSignOut = async () => {
    await signOut(auth);
  };

  const handleOnboardingDone = () => {
    chrome.storage.local.set({ notelayer_onboarded: true });
    setShowOnboarding(false);
  };

  if (authLoading || (user && catsLoading)) {
    return (
      <div className="app">
        <div className="loading-full"><div className="spinner" /></div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="app">
        <AuthScreen onSignIn={handleSignIn} />
      </div>
    );
  }

  if (showOnboarding) {
    return (
      <div className="app">
        <OnboardingFlow
          user={user}
          uid={user.uid}
          categories={categories}
          isExistingUser={isExistingUser}
          onDone={handleOnboardingDone}
        />
      </div>
    );
  }

  // Notes slides in as an overlay sheet over the To-Dos view
  if (showNotes) {
    return (
      <div className="app">
        <NotesView uid={user.uid} onClose={() => setShowNotes(false)} />
      </div>
    );
  }

  return (
    <div className="app">
      {showTheme && <ThemeSheet onClose={() => setShowTheme(false)} />}
      <div className="view">
        {activeTab === "todos" && (
          <TodosView
            uid={user.uid}
            onSignOut={handleSignOut}
            onOpenNotes={() => setShowNotes(true)}
            onOpenTheme={() => setShowTheme(true)}
          />
        )}
        {activeTab === "insights" && <InsightsView uid={user.uid} />}
      </div>

      <nav className="tab-bar">
        <div className="tab-bar__inner">
          <TabButton icon={<IconTodos />}    label="To-Dos"   active={activeTab === "todos"}    onClick={() => setActiveTab("todos")} />
          <TabButton icon={<IconInsights />} label="Insights" active={activeTab === "insights"} onClick={() => setActiveTab("insights")} />
        </div>
      </nav>
    </div>
  );
}

function TabButton({ icon, label, active, onClick }: {
  icon: React.ReactNode; label: string; active: boolean; onClick: () => void;
}) {
  return (
    <button className={`tab-bar__btn ${active ? "tab-bar__btn--active" : ""}`} onClick={onClick}>
      <span className="tab-bar__icon">{icon}</span>
      {label}
    </button>
  );
}
