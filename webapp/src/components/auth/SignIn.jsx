import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Button from '../ui/Button';

export default function SignIn({ onGoogleSignIn, onSendMagicLink }) {
  const [view, setView] = useState('main'); // 'main' | 'email'
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);
  const [error, setError] = useState('');

  const handleSendLink = async () => {
    setError('');
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('Please enter a valid email address.');
      return;
    }
    try {
      await onSendMagicLink(email);
      setSent(true);
    } catch (e) {
      setError(e.message || 'Something went wrong. Try again.');
    }
  };

  return (
    <div style={{
      minHeight: '100dvh', display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center',
      padding: '24px 20px',
      background: 'linear-gradient(135deg, #D8E5FF 0%, #E6DAFE 50%, #FDD9EC 100%)',
      position: 'relative', overflow: 'hidden',
    }}>
      {/* Background blobs */}
      <div style={{
        position: 'absolute', width: 400, height: 400, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(163,183,252,0.4) 0%, transparent 70%)',
        top: '-100px', right: '-80px', pointerEvents: 'none',
      }} />
      <div style={{
        position: 'absolute', width: 300, height: 300, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(253,200,230,0.4) 0%, transparent 70%)',
        bottom: '-60px', left: '-60px', pointerEvents: 'none',
      }} />

      <div style={{
        position: 'relative', zIndex: 1,
        width: '100%', maxWidth: 400,
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 32,
      }}>
        {/* Brand mark */}
        <div className="fade-up" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
          <div style={{
            width: 72, height: 72, borderRadius: 72 * 0.22,
            background: 'linear-gradient(155deg, #A5B4FC 0%, #6366F1 60%, #4338CA 100%)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 8px 24px rgba(99,102,241,0.30)',
          }}>
            <svg width="38" height="38" viewBox="0 0 20 20" fill="none">
              <path d="M4 10.5l4 4L16 5.5" stroke="#fff" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </div>
          <div style={{ textAlign: 'center' }}>
            <h1 style={{ fontFamily: 'var(--font-display)', fontSize: 28, fontWeight: 700, color: 'var(--site-text)', letterSpacing: -0.5 }}>
              Notelayer
            </h1>
            <p style={{ fontFamily: 'var(--font-body)', fontSize: 15, color: 'var(--site-muted)', marginTop: 4 }}>
              One task list. Multiple ways to focus.
            </p>
          </div>
        </div>

        {/* Card */}
        <AnimatePresence mode="wait">
          {view === 'main' ? (
            <motion.div
              key="main"
              initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }}
              transition={{ duration: 0.25 }}
              style={{
                width: '100%', padding: '24px 20px',
                background: 'rgba(255,255,255,0.85)',
                backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)',
                borderRadius: 'var(--radius-2xl)',
                border: '0.5px solid rgba(255,255,255,0.9)',
                boxShadow: '0 8px 32px rgba(16,25,40,0.08)',
                display: 'flex', flexDirection: 'column', gap: 12,
              }}
            >
              {/* Google */}
              <button
                onClick={onGoogleSignIn}
                style={{
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
                  width: '100%', padding: '12px 20px',
                  background: '#fff', border: '1px solid var(--border-default)',
                  borderRadius: 'var(--radius-md)', cursor: 'pointer',
                  fontFamily: 'var(--font-body)', fontSize: 15, fontWeight: 'var(--fw-medium)', color: '#1F2937',
                  boxShadow: 'var(--shadow-subtle)',
                  transition: 'transform 0.2s, box-shadow 0.2s',
                }}
                onMouseEnter={e => e.currentTarget.style.transform = 'translateY(-1px)'}
                onMouseLeave={e => e.currentTarget.style.transform = 'translateY(0)'}
              >
                <img src="/google-logo.png" alt="" width={18} height={18} />
                Continue with Google
              </button>

              {/* Divider */}
              <div style={{
                display: 'flex', alignItems: 'center', gap: 10,
                color: 'var(--text-tertiary)', fontSize: 12,
              }}>
                <div style={{ flex: 1, height: '0.5px', background: 'var(--border-subtle)' }} />
                or
                <div style={{ flex: 1, height: '0.5px', background: 'var(--border-subtle)' }} />
              </div>

              {/* Email */}
              <button
                onClick={() => setView('email')}
                style={{
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
                  width: '100%', padding: '12px 20px',
                  background: 'transparent', border: '1px solid var(--border-default)',
                  borderRadius: 'var(--radius-md)', cursor: 'pointer',
                  fontFamily: 'var(--font-body)', fontSize: 15, fontWeight: 'var(--fw-medium)',
                  color: 'var(--text-primary)',
                  transition: 'transform 0.2s, background 0.15s',
                }}
                onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-1px)'; e.currentTarget.style.background = 'var(--bg-subtle)'; }}
                onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.background = 'transparent'; }}
              >
                <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                  <path d="M2 4a1 1 0 011-1h12a1 1 0 011 1v10a1 1 0 01-1 1H3a1 1 0 01-1-1V4z" stroke="currentColor" strokeWidth="1.5"/>
                  <path d="M2 4l7 6 7-6" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
                </svg>
                Continue with Email
              </button>

              <p style={{
                fontFamily: 'var(--font-body)', fontSize: 12,
                color: 'var(--text-tertiary)', textAlign: 'center', lineHeight: 1.5,
              }}>
                By signing in you agree to the Terms of Service and Privacy Policy.
              </p>
            </motion.div>
          ) : (
            <motion.div
              key="email"
              initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }}
              transition={{ duration: 0.25 }}
              style={{
                width: '100%', padding: '24px 20px',
                background: 'rgba(255,255,255,0.85)',
                backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)',
                borderRadius: 'var(--radius-2xl)',
                border: '0.5px solid rgba(255,255,255,0.9)',
                boxShadow: '0 8px 32px rgba(16,25,40,0.08)',
                display: 'flex', flexDirection: 'column', gap: 14,
              }}
            >
              <button
                onClick={() => { setView('main'); setSent(false); setError(''); }}
                style={{
                  display: 'flex', alignItems: 'center', gap: 6,
                  background: 'none', border: 'none', cursor: 'pointer',
                  color: 'var(--text-secondary)', fontFamily: 'var(--font-body)', fontSize: 14,
                  padding: 0, alignSelf: 'flex-start',
                }}
              >
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M10 3L5 8l5 5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
                Back
              </button>

              <div>
                <h3 style={{ fontFamily: 'var(--font-display)', marginBottom: 4 }}>Sign in with email</h3>
                <p style={{ fontSize: 14, color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                  We'll send a magic link to your inbox.
                </p>
              </div>

              {!sent ? (
                <>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                    <label style={{ fontSize: 12, fontWeight: 'var(--fw-semibold)', color: 'var(--text-secondary)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                      Email address
                    </label>
                    <input
                      type="email"
                      value={email}
                      onChange={e => setEmail(e.target.value)}
                      onKeyDown={e => e.key === 'Enter' && handleSendLink()}
                      placeholder="you@example.com"
                      autoFocus
                      style={{
                        padding: '10px 12px', borderRadius: 'var(--radius-md)',
                        border: error ? '1px solid var(--status-error)' : '1px solid var(--border-default)',
                        fontFamily: 'var(--font-body)', fontSize: 15,
                        color: 'var(--text-primary)', outline: 'none',
                        background: 'var(--bg-elevated-1)',
                        transition: 'border-color 0.15s',
                      }}
                      onFocus={e => e.target.style.borderColor = 'var(--border-focus)'}
                      onBlur={e => e.target.style.borderColor = error ? 'var(--status-error)' : 'var(--border-default)'}
                    />
                    {error && <span style={{ fontSize: 12, color: 'var(--status-error)' }}>{error}</span>}
                  </div>
                  <Button onClick={handleSendLink} style={{ width: '100%', padding: '12px 20px', fontSize: 15, borderRadius: 'var(--radius-md)' }}>
                    Send Magic Link
                  </Button>
                </>
              ) : (
                <div style={{
                  padding: '16px', background: 'var(--status-success-subtle)',
                  borderRadius: 'var(--radius-md)', textAlign: 'center',
                  color: 'var(--status-success)', fontSize: 14, lineHeight: 1.5,
                }}>
                  Check your inbox — a sign-in link is on its way.
                </div>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
