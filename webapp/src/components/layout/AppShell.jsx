/* App icon mark — indigo gradient checkmark */
function AppIconMark({ size = 36 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.22, flexShrink: 0,
      background: 'linear-gradient(155deg, #A5B4FC 0%, #6366F1 60%, #4338CA 100%)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: '0 2px 6px rgba(99,102,241,0.25)',
    }}>
      <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 20 20" fill="none">
        <path d="M4 10.5l4 4L16 5.5" stroke="#fff" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    </div>
  );
}

export default function AppShell({ doingCount = 0, doneCount = 0, showing, onShowingToggle, onSettings, children }) {
  return (
    <div style={{
      display: 'flex', flexDirection: 'column',
      padding: '6px 16px 10px',
      background: 'transparent',
    }}>
      {/* Top bar */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        marginBottom: 8,
      }}>
        <AppIconMark />

        {/* Doing / Done toggle */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, fontFamily: 'var(--font-body)' }}>
          <div style={{ textAlign: 'center', minWidth: 44 }}>
            <div style={{
              fontSize: 17, fontWeight: 700, letterSpacing: -0.2, lineHeight: '20px',
              color: showing === 'doing' ? 'var(--site-text)' : '#8B93A4',
            }}>Doing</div>
            <div style={{ fontSize: 11, color: '#8B93A4', marginTop: 2 }}>{doingCount}</div>
          </div>

          <button
            onClick={onShowingToggle}
            style={{
              width: 56, height: 32, borderRadius: 'var(--radius-full)',
              background: '#E2E6EE', border: 'none', cursor: 'pointer',
              position: 'relative', padding: 0,
              boxShadow: 'inset 0 1px 2px rgba(0,0,0,0.04)',
              transition: 'background 0.2s',
            }}
          >
            <div style={{
              position: 'absolute', top: 3,
              left: showing === 'doing' ? 3 : 27,
              width: 26, height: 26, borderRadius: '50%',
              background: '#fff', boxShadow: '0 2px 4px rgba(0,0,0,0.15)',
              transition: 'left 0.2s',
            }} />
          </button>

          <div style={{ textAlign: 'center', minWidth: 44 }}>
            <div style={{
              fontSize: 17, fontWeight: 700, letterSpacing: -0.2, lineHeight: '20px',
              color: showing === 'done' ? 'var(--site-text)' : '#8B93A4',
            }}>Done</div>
            <div style={{ fontSize: 11, color: '#8B93A4', marginTop: 2 }}>{doneCount}</div>
          </div>
        </div>

        {/* Settings gear */}
        <button
          onClick={onSettings}
          style={{
            width: 40, height: 40, borderRadius: 20,
            background: 'var(--bg-elevated-1)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: 'var(--shadow-card)', border: 'none', cursor: 'pointer',
            position: 'relative',
          }}
        >
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
            <path fill="var(--indigo-500)" d="M19.14 12.936c.04-.3.06-.612.06-.936s-.02-.636-.06-.936l2.03-1.58a.484.484 0 00.12-.612l-1.92-3.324a.48.48 0 00-.588-.216l-2.394.96a7.03 7.03 0 00-1.62-.936l-.36-2.544A.487.487 0 0014.04 2.4h-4.08a.487.487 0 00-.48.408l-.36 2.544a7.03 7.03 0 00-1.62.936l-2.394-.96a.48.48 0 00-.588.216L2.6 8.868a.484.484 0 00.12.612l2.03 1.58c-.04.3-.06.612-.06.936s.02.636.06.936l-2.03 1.58a.484.484 0 00-.12.612l1.92 3.324c.132.228.396.324.588.216l2.394-.96c.504.384 1.044.708 1.62.936l.36 2.544c.036.24.24.408.48.408h4.08c.24 0 .444-.168.48-.408l.36-2.544a7.03 7.03 0 001.62-.936l2.394.96c.216.084.468 0 .588-.216l1.92-3.324a.484.484 0 00-.12-.612l-2.03-1.58zM12 15.6a3.6 3.6 0 110-7.2 3.6 3.6 0 010 7.2z"/>
          </svg>
        </button>
      </div>

      {children}
    </div>
  );
}
