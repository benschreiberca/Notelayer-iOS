import { useState } from 'react';
import SignIn from './components/auth/SignIn';
import TabBar from './components/layout/TabBar';
import TodosPage from './pages/TodosPage';
import NotesPage from './pages/NotesPage';

export default function App() {
  const [user, setUser] = useState(null);
  const [activeTab, setActiveTab] = useState('todos');

  const handleGoogleSignIn = async () => {
    // TODO: wire real signInWithPopup(auth, googleProvider)
    setUser({ displayName: 'Ben', email: 'ben@benschreiber.ca', photoURL: null });
  };

  const handleSendMagicLink = async (email) => {
    // TODO: wire real sendSignInLinkToEmail
    setUser({ displayName: email, email, photoURL: null });
  };

  if (!user) {
    return (
      <SignIn
        onGoogleSignIn={handleGoogleSignIn}
        onSendMagicLink={handleSendMagicLink}
      />
    );
  }

  return (
    <div style={{ position: 'relative', minHeight: '100dvh', overflow: 'hidden' }}>
      {activeTab === 'todos'    && <TodosPage />}
      {activeTab === 'notes'   && <NotesPage />}
      {activeTab === 'insights' && (
        <div style={{
          minHeight: '100dvh', display: 'flex', alignItems: 'center', justifyContent: 'center',
          background: 'linear-gradient(135deg, #D8E5FF 0%, #E6DAFE 50%, #FDD9EC 100%)',
          fontFamily: 'var(--font-body)', fontSize: 15, color: 'var(--text-secondary)',
        }}>
          Insights — coming soon
        </div>
      )}
      <TabBar active={activeTab} onChange={setActiveTab} />
    </div>
  );
}
