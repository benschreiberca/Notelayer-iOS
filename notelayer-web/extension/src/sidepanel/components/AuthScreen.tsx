import React, { useState } from "react";
import "./AuthScreen.css";

interface AuthScreenProps {
  onSignIn: (provider: "google" | "apple") => Promise<void>;
}

export function AuthScreen({ onSignIn }: AuthScreenProps) {
  const [loading, setLoading] = useState<null | "google" | "apple">(null);
  const [error, setError] = useState<string | null>(null);

  const handle = async (provider: "google" | "apple") => {
    setLoading(provider);
    setError(null);
    try {
      await onSignIn(provider);
    } catch (e: any) {
      setError(e?.message || "Sign in failed. Try again.");
    } finally {
      setLoading(null);
    }
  };

  return (
    <div className="auth-screen">
      <div className="auth-screen__content">
        <div className="auth-screen__logo">
          <img src="assets/icon128.png" alt="Notelayer" width="64" height="64" />
        </div>
        <h1 className="auth-screen__title">Notelayer</h1>
        <p className="auth-screen__subtitle">
          Capture from any page, synced to your iPhone
        </p>

        <button
          className="auth-screen__btn"
          onClick={() => handle("google")}
          disabled={loading !== null}
        >
          {loading === "google" ? <span className="auth-screen__btn-spinner" /> : <GoogleIcon />}
          Continue with Google
        </button>

        <button
          className="auth-screen__btn auth-screen__btn--apple"
          onClick={() => handle("apple")}
          disabled={loading !== null}
        >
          {loading === "apple" ? <span className="auth-screen__btn-spinner" /> : <AppleIcon />}
          Continue with Apple
        </button>

        {error && <p className="auth-screen__error">{error}</p>}
      </div>
    </div>
  );
}

function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
      <path d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844a4.14 4.14 0 0 1-1.796 2.716v2.259h2.908c1.702-1.567 2.684-3.875 2.684-6.615Z" fill="#4285F4"/>
      <path d="M9 18c2.43 0 4.467-.806 5.956-2.184l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 0 0 9 18Z" fill="#34A853"/>
      <path d="M3.964 10.71A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.042l3.007-2.332Z" fill="#FBBC05"/>
      <path d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 0 0 .957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58Z" fill="#EA4335"/>
    </svg>
  );
}

function AppleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="currentColor">
      <path d="M12.46 9.57c.02 2.18 1.91 2.9 1.93 2.91-.02.05-.3 1.04-1 2.06-.6.88-1.23 1.76-2.22 1.78-.97.02-1.28-.58-2.39-.58-1.11 0-1.46.56-2.38.6-.95.04-1.68-.95-2.29-1.83-1.24-1.8-2.19-5.08-.92-7.3.63-1.1 1.76-1.8 2.99-1.82.94-.02 1.82.63 2.39.63.57 0 1.64-.78 2.77-.67.47.02 1.79.19 2.64 1.43-.07.04-1.58.92-1.56 2.75M10.7 3.5c.5-.61.84-1.46.75-2.3-.72.03-1.6.48-2.12 1.09-.47.54-.88 1.4-.77 2.23.8.06 1.63-.41 2.14-1.02"/>
    </svg>
  );
}
