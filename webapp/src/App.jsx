import { useState } from 'react';
import SignIn from './components/auth/SignIn';
import TabBar from './components/layout/TabBar';
import TodosPage from './pages/TodosPage';
import NotesPage from './pages/NotesPage';

function InsightsPage() {
  return (
    <div style={{
      padding: '24px 16px 96px', minHeight: '100dvh',
      background: 'linear-gradient(135deg, #D8E5FF 0%, #E6DAFE 50%, #FDD9EC 100%)',
    }}>
      <div style={{
        position: 'fixed', inset: 0, pointerEvents: 'none',
        background: 'linear-gradient(180deg, rgba(255,255,255,0.35) 0%, rgba(255,255,255,0.55) 100%)',
      }} />
      <div style={{ position: 'relative', zIndex: 1 }}>
        <h2 style={{ fontFamily: 'var(--font-display)', fontSize: 26, fontWeight: 700, color: 'var(--site-text)', letterSpacing: -0.3 }}>
          Insights
        </h2>
        <p style={{ marginTop: 8, color: 'var(--text-secondary)', fontSize: 15 }}>
          Analytics dashboard — coming soon.
        </p>
      </div>
    </div>
  );
}

const PAGES = { notes: NotesPage, todos: TodosPage, insights: InsightsPage };

export default function App() {
  const [user, setUser] = useState(null); // replace with onAuthStateChanged hook
  const [tab, setTab] = useState('todos');

  const handleGoogleSignIn = async () => {
    // TODO: signInWithPopup(auth, googleProvider)
    setUser({ uid: 'demo', displayName: 'Demo User', email: 'demo@notelayer.app' });
  };

  const handleSendMagicLink = async (email) => {
    // TODO: sendSignInLinkToEmail(auth, email, emailLinkSettings)
    console.log('[Notelayer] Sending magic link to:', email);
  };

  if (!user) {
    return (
      <SignIn
        onGoogleSignIn={handleGoogleSignIn}
        onSendMagicLink={handleSendMagicLink}
      />
    );
  }

  const Page = PAGES[tab] ?? TodosPage;

  return (
    <div style={{ position: 'relative' }}>
      <Page />
      <TabBar active={tab} onChange={setTab} />
    </div>
  );
}
