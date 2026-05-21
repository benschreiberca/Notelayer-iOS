const TABS = [
  {
    id: 'notes', label: 'Notes',
    icon: (
      <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
        <rect x="3" y="3" width="16" height="16" rx="3" stroke="currentColor" strokeWidth="1.7" />
        <path d="M7 8h8M7 12h8M7 16h5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
      </svg>
    ),
  },
  {
    id: 'todos', label: 'To-Dos',
    icon: (
      <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
        <circle cx="5" cy="6"  r="2.2" stroke="currentColor" strokeWidth="1.7" />
        <circle cx="5" cy="16" r="2.2" stroke="currentColor" strokeWidth="1.7" />
        <path d="M10 6h9M10 16h9" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
        <path d="M3.5 6l1 1 2-2.2" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
  {
    id: 'insights', label: 'Insights',
    icon: (
      <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
        <path d="M3 17l4-4 4 3 4-6 4 2" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
];

export default function TabBar({ active, onChange }) {
  return (
    <nav style={{
      position: 'fixed', bottom: 0, left: 0, right: 0,
      display: 'flex',
      background: 'rgba(255,255,255,0.85)',
      backdropFilter: 'blur(16px)',
      WebkitBackdropFilter: 'blur(16px)',
      borderTop: '0.5px solid var(--border-subtle)',
      boxShadow: '0 -4px 16px rgba(16,25,40,0.05)',
      zIndex: 100,
      paddingBottom: 'env(safe-area-inset-bottom, 0px)',
    }}>
      {TABS.map(tab => {
        const isActive = active === tab.id;
        return (
          <button
            key={tab.id}
            onClick={() => onChange(tab.id)}
            style={{
              flex: 1, display: 'flex', flexDirection: 'column',
              alignItems: 'center', gap: 3,
              padding: '10px 0 8px',
              border: 'none', background: 'transparent', cursor: 'pointer',
              color: isActive ? 'var(--interactive-primary)' : 'var(--text-tertiary)',
              transition: 'color 0.15s',
            }}
          >
            {tab.icon}
            <span style={{
              fontFamily: 'var(--font-body)', fontSize: 11,
              fontWeight: isActive ? 'var(--fw-semibold)' : 'var(--fw-regular)',
              letterSpacing: 0.1,
            }}>
              {tab.label}
            </span>
          </button>
        );
      })}
    </nav>
  );
}
