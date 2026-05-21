import { useState } from 'react';

const SAMPLE_NOTES = [
  { id: '1', text: 'Pick up milk, eggs, and that fancy olive oil from the farmers market.', createdAt: new Date(Date.now() - 86400000).toISOString() },
  { id: '2', text: 'The shelf above the washing machine is loose — check if it needs longer screws or wall anchors.', createdAt: new Date(Date.now() - 2 * 86400000).toISOString() },
];

export default function NotesPage() {
  const [notes, setNotes] = useState(SAMPLE_NOTES);
  const [draft, setDraft] = useState('');

  const handleAdd = () => {
    const text = draft.trim();
    if (!text) return;
    setNotes(prev => [{ id: crypto.randomUUID(), text, createdAt: new Date().toISOString() }, ...prev]);
    setDraft('');
  };

  return (
    <div style={{
      minHeight: '100dvh',
      background: 'linear-gradient(135deg, #D8E5FF 0%, #E6DAFE 50%, #FDD9EC 100%)',
    }}>
      <div style={{
        position: 'fixed', inset: 0, pointerEvents: 'none',
        background: 'linear-gradient(180deg, rgba(255,255,255,0.35) 0%, rgba(255,255,255,0.55) 100%)',
      }} />

      <div style={{ position: 'relative', zIndex: 1, padding: '16px 16px 96px' }}>
        <h2 style={{
          fontFamily: 'var(--font-display)', fontSize: 26, fontWeight: 700,
          color: 'var(--site-text)', letterSpacing: -0.3, marginBottom: 16,
        }}>
          Notes
        </h2>

        {/* Quick-add note */}
        <div style={{
          background: 'rgba(255,255,255,0.65)', border: '0.5px solid rgba(255,255,255,0.9)',
          borderRadius: 'var(--radius-lg)', padding: '12px',
          marginBottom: 12, boxShadow: 'var(--shadow-subtle)',
        }}>
          <textarea
            value={draft}
            onChange={e => setDraft(e.target.value)}
            placeholder="Type a note…"
            rows={3}
            style={{
              width: '100%', border: 'none', outline: 'none', background: 'transparent',
              fontFamily: 'var(--font-body)', fontSize: 15, color: 'var(--site-text)',
              resize: 'vertical', lineHeight: 1.5,
            }}
          />
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 }}>
            <span style={{ fontSize: 11, color: 'var(--text-tertiary)' }}>{draft.length}</span>
            <button
              onClick={handleAdd}
              disabled={!draft.trim()}
              style={{
                padding: '6px 14px', borderRadius: 'var(--radius-md)',
                background: draft.trim() ? 'var(--interactive-primary)' : 'var(--interactive-primary-disabled)',
                color: '#fff', border: 'none', cursor: draft.trim() ? 'pointer' : 'not-allowed',
                fontFamily: 'var(--font-body)', fontSize: 13, fontWeight: 'var(--fw-medium)',
                transition: 'background 0.15s',
              }}
            >
              Save Note
            </button>
          </div>
        </div>

        {/* Note list */}
        {notes.map(note => (
          <div
            key={note.id}
            style={{
              background: 'rgba(255,255,255,0.65)', border: '0.5px solid rgba(255,255,255,0.9)',
              borderRadius: 'var(--radius-lg)', padding: '12px 14px',
              marginBottom: 8, boxShadow: 'var(--shadow-subtle)',
            }}
          >
            <p style={{
              fontFamily: 'var(--font-body)', fontSize: 15, lineHeight: 1.55,
              color: 'var(--site-text)', whiteSpace: 'pre-wrap',
            }}>
              {note.text}
            </p>
            <span style={{ fontSize: 11, color: 'var(--text-tertiary)', marginTop: 6, display: 'block' }}>
              {new Date(note.createdAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
