import { Routes, Route, NavLink, Navigate } from "react-router-dom";
import { signOut } from "firebase/auth";
import { auth } from "@notelayer/shared";
import type { User } from "firebase/auth";
import TodosPage from "../../pages/TodosPage";
import NotesPage from "../../pages/NotesPage";
import styles from "./AppShell.module.css";

export default function AppShell({ user }: { user: User }) {
  return (
    <div className={styles.shell}>
      <header className={styles.header}>
        <span className={styles.logo}>Notelayer</span>
        <div className={styles.headerRight}>
          <span className={styles.email}>{user.email || user.displayName}</span>
          <button className={styles.signout} onClick={() => signOut(auth)}>Sign out</button>
        </div>
      </header>

      <nav className={styles.tabs}>
        <NavLink to="/todos" className={({ isActive }) => `${styles.tab} ${isActive ? styles.active : ""}`}>
          Tasks
        </NavLink>
        <NavLink to="/notes" className={({ isActive }) => `${styles.tab} ${isActive ? styles.active : ""}`}>
          Notes
        </NavLink>
      </nav>

      <main className={styles.main}>
        <Routes>
          <Route path="/" element={<Navigate to="/todos" replace />} />
          <Route path="/todos" element={<TodosPage user={user} />} />
          <Route path="/notes" element={<NotesPage user={user} />} />
        </Routes>
      </main>
    </div>
  );
}
