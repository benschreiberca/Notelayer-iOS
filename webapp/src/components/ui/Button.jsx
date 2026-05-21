export default function Button({
  children, onClick, variant = 'primary', disabled = false, style: extraStyle = {},
}) {
  const base = {
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
    padding: '10px 20px', borderRadius: 'var(--radius-md)',
    fontFamily: 'var(--font-body)', fontSize: 'var(--fs-14)', fontWeight: 'var(--fw-medium)',
    border: 'none', cursor: disabled ? 'not-allowed' : 'pointer',
    transition: 'background 0.15s, transform 0.2s, box-shadow 0.15s',
    opacity: disabled ? 0.5 : 1,
    ...extraStyle,
  };

  const variants = {
    primary: {
      background: 'var(--interactive-primary)',
      color: 'var(--text-on-interactive)',
      boxShadow: 'var(--shadow-btn)',
    },
    secondary: {
      background: 'var(--bg-elevated-1)',
      color: 'var(--text-primary)',
      border: '1px solid var(--border-default)',
      boxShadow: 'var(--shadow-subtle)',
    },
    ghost: {
      background: 'transparent',
      color: 'var(--interactive-primary)',
      border: '1px solid var(--border-default)',
    },
    google: {
      background: '#FFFFFF',
      color: '#1F2937',
      border: '1px solid var(--border-default)',
      boxShadow: 'var(--shadow-subtle)',
    },
  };

  return (
    <button
      onClick={disabled ? undefined : onClick}
      disabled={disabled}
      style={{ ...base, ...variants[variant] }}
      onMouseEnter={e => {
        if (!disabled) e.currentTarget.style.transform = 'translateY(-1px)';
      }}
      onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; }}
    >
      {children}
    </button>
  );
}
