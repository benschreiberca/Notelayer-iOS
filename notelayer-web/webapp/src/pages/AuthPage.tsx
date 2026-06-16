import { useState } from "react";
import {
  GoogleAuthProvider, signInWithPopup,
  sendSignInLinkToEmail, isSignInWithEmailLink, signInWithEmailLink,
} from "firebase/auth";
import { auth } from "@notelayer/shared";
import styles from "./AuthPage.module.css";

const EMAIL_KEY = "notelayer_email_for_signin";
const actionCodeSettings = {
  url: `${window.location.origin}/auth`,
  handleCodeInApp: true,
};

export default function AuthPage() {
  const [email, setEmail] = useState("");
  const [emailSent, setEmailSent] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [showEmail, setShowEmail] = useState(false);

  // Handle magic link return
  if (isSignInWithEmailLink(auth, window.location.href)) {
    const saved = localStorage.getItem(EMAIL_KEY);
    if (saved) {
      signInWithEmailLink(auth, saved, window.location.href)
        .then(() => localStorage.removeItem(EMAIL_KEY))
        .catch((e) => setError(e.message));
    }
  }

  async function handleGoogle() {
    setError("");
    setLoading(true);
    try {
      await signInWithPopup(auth, new GoogleAuthProvider());
    } catch (e: any) {
      setError(e.message);
      setLoading(false);
    }
  }

  async function handleEmailLink() {
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError("Please enter a valid email address.");
      return;
    }
    setError("");
    setLoading(true);
    try {
      await sendSignInLinkToEmail(auth, email, actionCodeSettings);
      localStorage.setItem(EMAIL_KEY, email);
      setEmailSent(true);
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className={styles.page}>
      <div className={styles.card}>
        <div className={styles.logo}>N</div>
        <h1 className={styles.title}>Notelayer</h1>
        <p className={styles.subtitle}>Sign in to access your tasks and notes</p>

        {!showEmail ? (
          <>
            <button className={styles.btnGoogle} onClick={handleGoogle} disabled={loading}>
              <span className={styles.gIcon}>G</span> Continue with Google
            </button>
            <button className={styles.btnSecondary} onClick={() => setShowEmail(true)}>Continue with Email</button>
          </>
        ) : emailSent ? (
          <p className={styles.success}>Check your email for a sign-in link!</p>
        ) : (
          <>
            <button className={styles.btnBack} onClick={() => setShowEmail(false)}>← Back</button>
            <input
              className={styles.input}
              type="email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleEmailLink()}
            />
            <button className={styles.btnPrimary} onClick={handleEmailLink} disabled={loading}>
              {loading ? "Sending…" : "Send Magic Link"}
            </button>
          </>
        )}

        {error && <p className={styles.error}>{error}</p>}
      </div>
    </div>
  );
}
