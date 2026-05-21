import { useState } from 'react';

export default function TaskInput({ placeholder = 'New task…', onAdd }) {
  const [value, setValue] = useState('');

  const submit = () => {
    const trimmed = value.trim();
    if (!trimmed) return;
    onAdd?.(trimmed);
    setValue('');
  };

  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '10px 12px',
      background: 'rgba(255,255,255,0.55)',
      border: '0.5px solid rgba(255,255,255,0.8)',
      borderRadius: 'var(--radius-lg)',
      margin: '6px 0',
    }}>
      <button
        onClick={submit}
        style={{
          width: 24, height: 24, borderRadius: '50%',
          background: 'var(--accent-cool-blue)',
          color: '#fff', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 16, fontWeight: 600, flexShrink: 0,
          transition: 'background 0.15s, transform 0.12s',
        }}
      >
        +
      </button>
      <input
        value={value}
        onChange={e => setValue(e.target.value)}
        onKeyDown={e => e.key === 'Enter' && submit()}
        placeholder={placeholder}
        style={{
          flex: 1, border: 'none', outline: 'none', background: 'transparent',
          fontFamily: 'var(--font-body)', fontSize: 15.5,
          color: 'var(--site-text)',
        }}
      />
    </div>
  );
}
