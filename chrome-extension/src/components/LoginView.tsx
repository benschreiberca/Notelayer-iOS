import { useState } from 'react'
import { useAuth } from '../hooks/useAuth'

export default function LoginView() {
  const { sendMagicLink } = useAuth()
  const [email, setEmail] = useState('')
  const [sent, setSent] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!email.trim()) return
    setLoading(true)
    setError('')
    try {
      await sendMagicLink(email.trim())
      setSent(true)
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to send link')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex flex-col items-center justify-center flex-1 px-6 py-8">
      {/* Logo */}
      <div className="mb-8 text-center">
        <div
          className="w-14 h-14 rounded-2xl flex items-center justify-center mx-auto mb-3"
          style={{ background: 'linear-gradient(135deg, #6366F1 0%, #4F46E5 100%)' }}
        >
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
            <path d="M9 12h6M9 16h4M7 4H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V6a2 2 0 00-2-2h-2M9 4a2 2 0 012-2h2a2 2 0 012 2v0a2 2 0 01-2 2h-2a2 2 0 01-2-2z" stroke="white" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        <h1 className="text-xl font-semibold text-white tracking-tight">Notelayer</h1>
        <p className="text-sm mt-1" style={{ color: '#9CA3AF' }}>Sign in to access your notes and to-dos</p>
      </div>

      {sent ? (
        <div className="w-full text-center">
          <div
            className="w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4"
            style={{ background: 'rgba(99,102,241,0.15)' }}
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" stroke="#6366F1" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          <p className="font-medium text-white mb-1">Check your email</p>
          <p className="text-sm" style={{ color: '#9CA3AF' }}>
            We sent a sign-in link to<br />
            <span style={{ color: '#D1D5DB' }}>{email}</span>
          </p>
          <button
            className="mt-5 text-sm"
            style={{ color: '#6366F1' }}
            onClick={() => setSent(false)}
          >
            Use a different email
          </button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="w-full space-y-3">
          <div>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="your@email.com"
              required
              autoFocus
              className="w-full px-4 py-3 rounded-xl text-sm outline-none transition-all"
              style={{
                background: '#1F2937',
                border: '1px solid #374151',
                color: '#F9FAFB',
              }}
              onFocus={(e) => (e.target.style.borderColor = '#6366F1')}
              onBlur={(e) => (e.target.style.borderColor = '#374151')}
            />
          </div>

          {error && (
            <p className="text-xs px-1" style={{ color: '#EF4444' }}>{error}</p>
          )}

          <button
            type="submit"
            disabled={loading || !email.trim()}
            className="w-full py-3 rounded-xl text-sm font-medium text-white transition-opacity"
            style={{
              background: loading || !email.trim()
                ? '#374151'
                : 'linear-gradient(135deg, #6366F1 0%, #4F46E5 100%)',
              opacity: loading ? 0.7 : 1,
              cursor: loading || !email.trim() ? 'not-allowed' : 'pointer',
            }}
          >
            {loading ? 'Sending…' : 'Send sign-in link'}
          </button>

          <p className="text-center text-xs pt-1" style={{ color: '#6B7280' }}>
            Same account as your iPhone app
          </p>
        </form>
      )}
    </div>
  )
}
