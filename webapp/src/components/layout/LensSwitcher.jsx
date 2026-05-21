const LENSES = ['List', 'Priority', 'Category', 'Date'];

export default function LensSwitcher({ active, onChange }) {
  return (
    <div style={{
      display: 'flex', margin: '4px 16px 8px',
      background: '#E8ECF4', borderRadius: 'var(--radius-full)',
      padding: 4, gap: 2,
    }}>
      {LENSES.map(l => (
        <button
          key={l}
          onClick={() => onChange(l)}
          style={{
            flex: 1, border: 'none', cursor: 'pointer',
            padding: '8px 10px', borderRadius: 'var(--radius-full)',
            background: active === l ? '#fff' : 'transparent',
            fontFamily: 'var(--font-body)', fontWeight: 'var(--fw-medium)', fontSize: 14,
            color: 'var(--site-text)',
            boxShadow: active === l ? 'var(--shadow-subtle)' : 'none',
            transition: 'background 0.15s, box-shadow 0.15s',
          }}
        >
          {l}
        </button>
      ))}
    </div>
  );
}
